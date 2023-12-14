robbery.awake = function()
  while not BJCore do Wait(1000); end
  while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
  BJCore.Functions.TriggerServerCallback('robbery:getStartData', function(cops)
    robbery.cops = cops
    robbery.start()
  end)
end

robbery.start = function()
  RequestStreamedTextureDict("mpleaderboard")
  robbery.plyData = BJCore.Functions.GetPlayerData()
  robbery.update()
end

local polOnline = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
  polOnline = amount or 0
end)

robbery.soundLevel = 0.0
robbery.lastKeyPress = 0

robbery.update = function()
  while true do
    local sleep = 0
    local hour = GetClockHours()
    if not robbery.inHouse then
      local closest,closestType,closestDist = robbery.getClosestEntry()
      if closestDist < Config.ActDist then
        if (hour >= 21 or hour < 5) or (robbery.plyData.job.name == Config.PoliceJob) then
          if polOnline and polOnline >= Config.MinCopsOnline and not robbery.tryHouse then
            if robbery.plyData.job and robbery.plyData.job.name == Config.PoliceJob then
              BJCore.Functions.DrawText3D(closest.x, closest.y, closest.z, "[~g~E~s~] Enter",0.7)
            else
              BJCore.Functions.DrawText3D(closest.x, closest.y, closest.z, "[~r~E~s~] Break In",0.7)
            end
            if IsControlJustReleased(0, 38) then
        			BeginTextCommandBusyspinnerOn("MP_SPINLOADING")
        			EndTextCommandBusyspinnerOn(4)
              Wait(500)
              robbery.tryEnter(closest)
            end
          end
        end
      else
        if closestDist > 20 then sleep = 1000; end
      end
    else
      local exitDist = #(robbery.inHouse.exit.xyz - GetEntityCoords(PlayerPedId()))
      if exitDist and exitDist < Config.ActDist then
        BJCore.Functions.DrawText3D(robbery.inHouse.exit.x, robbery.inHouse.exit.y, robbery.inHouse.exit.z, "[~r~E~s~] Leave",0.7)
        if IsControlJustReleased(0, 38) then
          robbery.doLeave()
        end
      end

      if robbery.plyData.job.name ~= Config.PoliceJob then
        local closest,closestDist,closestPos = robbery.getClosestLoot()
        if closestDist < Config.ActDist then
          BJCore.Functions.DrawText3D(closestPos.x, closestPos.y, closestPos.z, "[~r~E~s~] Loot",0.7)
          local time = GetGameTimer()
          if IsControlJustPressed(0, 38) and ((time - robbery.lastKeyPress) > 500) then
            robbery.lastKeyPress = time
            robbery.tryLoot(closest)
          end
        end
      end
    end
    if robbery.plyData.job and robbery.plyData.job.name ~= Config.PoliceJob then
      robbery.getSoundLevel()
    end
    Wait(sleep)
  end
end

robbery.getSoundLevel = function()
  if robbery.inHouse then
    local plyPed = PlayerPedId()
    local speed = math.floor( utils.vecLength(GetEntityVelocity(plyPed)))
    local isStealth = GetPedStealthMovement(plyPed)
    local isShooting = IsPedShooting(plyPed)
    local soundAdder = 0.02
    local soundTaker = 0.01
    if isStealth then
      if speed > 0 then
        robbery.soundLevel = math.min(100.0,robbery.soundLevel + soundAdder)
      else          
        robbery.soundLevel = math.max(0.0,robbery.soundLevel - (soundTaker * 2.0))
      end
    else
      if speed > 1 then
        robbery.soundLevel = math.min(100.0,robbery.soundLevel + (soundAdder * 10.0))
      elseif speed > 0 then          
        robbery.soundLevel = math.min(100.0,robbery.soundLevel + (soundAdder * 5.0))
      else
        robbery.soundLevel = math.max(0.0,robbery.soundLevel - soundTaker)
      end
    end

    if isShooting then
      if not robbery.lastShot or (GetGameTimer() - robbery.lastShot) > 1000 then
        robbery.lastShot = GetGameTimer()
        robbery.soundLevel = math.min(100.0,robbery.soundLevel + 50.0)
      end
    end

    DrawRect(0.9,0.8, 0.010, 0.2, 15,15,15, 0.5)
    DrawRect(0.9,0.8, 0.009, 0.2*( (robbery.soundLevel or 50.0) /100.0), 155,15,15, 0.5)

    local sprite = "leaderboard_audio_3"
    if robbery.soundLevel >= 99.0 then
      if robbery.inHouse and not robbery.inHouse.pedAttacked then
        robbery.inHouse.pedAttacked = true
        if DoesEntityExist(robbery.inHouse.ped) and not IsEntityDead(robbery.inHouse.ped) then
          --TriggerServerEvent('robbery:alert',robbery.inHouse.entry)
          TriggerServerEvent('qb-hud:Server:GainStress', math.random(1, 3))

          TriggerServerEvent('MF_Trackables:Notify','A burglary alarm has been triggered at a home', robbery.inHouse.entry,'police','bande')
          TriggerServerEvent('robbery:pedAttack',robbery.inHouse.entry,robbery.inHouse.exit)
        end
      end
    elseif robbery.soundLevel > 80.0 then
      if not robbery.lastWarn or ((GetGameTimer() - robbery.lastWarn) > 5000) then
        robbery.lastWarn = GetGameTimer()
        BJCore.Functions.Notify('You\'re making alot of noise!', 'primary')
      end
    elseif robbery.soundLevel > 40.0 then
      sprite = "leaderboard_audio_2"
    else
      sprite = "leaderboard_audio_1"
    end

    DrawSprite("mpleaderboard",sprite,0.9,0.67, 0.025, 0.05, 0.0, 155,15,15, 1.0)
  else
    robbery.soundLevel = math.max(0.0,robbery.soundLevel - 0.01) 
  end
  return robbery.soundLevel
end

RegisterCommand('currentoffsetpos', function()
	if robbery.inHouse and robbery.inHouse.exit then
		local e = robbery.inHouse.exit
		local p = GetEntityCoords(PlayerPedId())
		
		print('X: '..(p.x - e.x)..', Y: '..(p.y - e.y)..', Z: '..(p.z - e.z))
	end
end)

robbery.getClosestLoot = function()
  local closest,closestDist
  local pos = GetEntityCoords(PlayerPedId())
  if robbery.inHouse and robbery.inHouse.exit then
    local t = robbery.inHouse.exit
    for k,v in pairs(robbery.currentInterior.loot) do
      local dist =  #(pos - (robbery.inHouse.exit.xyz + k))
      if not closestDist or dist < closestDist then
        closestDist = dist
        closest = k
        closestPos = robbery.inHouse.exit.xyz + k
      end
    end
  end
  if closest and closestDist then
    return closest,closestDist,closestPos
  else
    return false,99999,false
  end
end

robbery.getClosestEntry = function()
  local pos = GetEntityCoords(PlayerPedId())
  local closest,closestType,closestDist
  for k,v in pairs(Config.Entrys) do
    local dist = #(pos - v.pos.xyz)
    if not closestDist or dist < closestDist then
      closestDist = dist
      closestType = v.type
      closest = v.pos
    end
  end
  if closest and closestDist then
    return closest,closestType,closestDist
  else
    return false,false,9999
  end
end

robbery.tryEnter = function(loc)
  BJCore.Functions.TriggerServerCallback('robbery:getHouseData', function(data)
    if data and data.locked then
      robbery.plyData = BJCore.Functions.GetPlayerData()
      local job = robbery.plyData.job
      if job and job.name == 'police' then
        robbery.doEnter(loc)
      else
        local found = false
        for key,val in pairs(robbery.plyData.items) do
          if val.name == 'lockpick' then
            if val.amount and val.amount > 0 then 
              found = true
            else
              if val.amount and val.amount <= 0 then
                BJCore.Functions.Notify('You don\'t have lockpicks','error')
                return
              end
            end
          end
        end
    		BusyspinnerOff()
        if found then
          robbery.tryHouse = loc      
          while not HasAnimDictLoaded("mini@safe_cracking") do RequestAnimDict("mini@safe_cracking"); Citizen.Wait(0); end
          TaskPlayAnim(PlayerPedId(), "mini@safe_cracking", "idle_base", 8.0, 8.0, -1, 1, 0, 0, 0, 0 )  

          Citizen.Wait(1000)
          robbery.currentInterior = data
          if math.random(100) <= 50 then
            TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
          end
          TriggerEvent('bj_minigames:start', 'Lockpick', { pins = 4, timeout = 6000 }, function(data)
            TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
            TriggerEvent('robbery:LockpickSuccess')
          end, function(data)
            TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
            TriggerEvent('robbery:LockpickFail')
          end)
          if math.random(100) <= 50 then
            TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200)
          end
          TriggerServerEvent("bj-log:server:CreateLog", "crim", "Burglary", "green", "**"..plyData.name .. "** has attempted to lockpick/start a burgalry")
        end
      end
    else
      robbery.doEnter(loc)
      robbery.currentInterior = data
    end
  end,loc)
end

robbery.lockpickResult = function(res)
  ClearPedTasksImmediately(PlayerPedId())
  if res then
    robbery.doEnter(robbery.tryHouse)
    TriggerServerEvent('robbery:unlockHouse',robbery.tryHouse)
    robbery.tryHouse = nil
  else
    --exports['mythic_notify']:SendAlert('error', 'You alerted the police', 2500)
    --TriggerServerEvent('robbery:alert',robbery.tryHouse)
    TriggerServerEvent('MF_Trackables:Notify','A burglary alarm has been triggered at a home', robbery.tryHouse,'police','bande')
    robbery.tryHouse = nil
  end
end

robbery.doEnter = function(loc)
  TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
  RemoveAnimDict("mini@safe_cracking")
  if not BusyspinnerIsOn() then
	BeginTextCommandBusyspinnerOn("MP_SPINLOADING")
	EndTextCommandBusyspinnerOn(4)
  end
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Citizen.Wait(10); end

  SetEntityCoords(PlayerPedId(),loc.x, loc.y, loc.z - 20.0)
  FreezeEntityPosition(PlayerPedId(),true)
  Citizen.Wait(5000)  

  local pedHash = GetHashKey("PLAYER")
  local copHash = GetHashKey("COP")

  robbery.plyData = BJCore.Functions.GetPlayerData()
  if robbery.plyData.job.name == Config.PoliceJob then
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped,copHash)
    SetPedRelationshipGroupDefaultHash(ped,copHash)
  else
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped,plyHash)
    SetPedRelationshipGroupDefaultHash(ped,plyHash)    
  end

  SetRainFxIntensity(0.0)
  TriggerEvent('bj-weathersync:client:DisableSync') 
  SetWeatherTypePersist('EXTRASUNNY')
  SetWeatherTypeNow('EXTRASUNNY')
  SetWeatherTypeNowPersist('EXTRASUNNY')
  NetworkOverrideClockTime(23, 0, 0)  

  local nP = {x = loc.x, y = loc.y, z = loc.z - 20.0, h = loc.w - 45.0}
  --local houseHash = GetHashKey('playerhouse_tier1_full')
  local house = exports.interior:CreateTier1HouseFurnished(nP, false)
  --while not house or not house[1] or GetClosestObjectOfType(nP.x, nP.y, nP.z, 10.0, houseHash) == 0 do Citizen.Wait(10); end
  robbery.inHouse = {}
  for k,v in pairs(house) do
    if v and v.backdoor then
      robbery.inHouse["offsets"] = v
    else 
      robbery.inHouse["objects"] = v
    end
  end

  robbery.inHouse.entry = loc
  robbery.inHouse.exit = vector4(nP.x + house[2].exit.x, nP.y + house[2].exit.y, nP.z + house[2].exit.z, nP.h)
  print("exit: "..robbery.inHouse.exit)

  if robbery.lastHouse and robbery.lastHouse.exit ~= robbery.inHouse.exit then
    robbery.soundLevel = 0.0
  end

  robbery.lastHouse = robbery.inHouse

  BJCore.Functions.TriggerServerCallback('robbery:getPed', function(spawnPed,spawnLoc)
    if spawnPed then
      robbery.spawnPed(spawnLoc)
    end
  end,loc,robbery.inHouse.exit)
  BusyspinnerOff()
end

robbery.doLeave = function()
  TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.25)
  local loc = robbery.inHouse.entry
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Citizen.Wait(10); end

  robbery.plyData = BJCore.Functions.GetPlayerData()
  local plyJob = robbery.plyData.job.name
  if plyJob ~= Config.PoliceJob then
    TriggerServerEvent('robbery:leave', loc)
  end

  TriggerEvent('bj-weathersync:client:EnableSync')

  local plyPed = PlayerPedId()
  SetEntityCoords(plyPed, loc.x, loc.y, loc.z-1.0, 0, 0, 0, false)
  SetEntityHeading(plyPed, loc.w)

  Citizen.Wait(100)

  DoScreenFadeIn(1000)

  Wait(1200)

  for k,v in pairs(robbery.inHouse.objects) do
    SetEntityAsMissionEntity(v,true,true)
    DeleteObject(v)
    DeleteEntity(v)
  end

  robbery.inHouse = nil
end

RegisterCommand("leaveburglary", function(source, args, rawCommand)
  robbery.doLeave()
end, false)

robbery.pedAttacked = function(pos)
  robbery.inHouse.pedAttacked = true

  local hash = GetHashKey("csb_jackhowitzer")
  RequestModel(hash)
  while not HasModelLoaded(hash) do RequestModel(hash); Wait(10); end

  local ped = CreatePed(4, hash, pos.x,pos.y,pos.z, 273.0, true,false)
  robbery.inHouse.ped = ped
  FreezeEntityPosition(ped,true)

  local dict = 'mp_bedmid'
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do Citizen.Wait(0); end

  TaskPlayAnim(ped, dict, 'f_getout_r_bighouse', 8.0, 8.0, -1, 2, true,true,true)
  Wait(700)
  FreezeEntityPosition(ped,false)
  Wait(1300)
  ClearPedTasksImmediately(ped)

  GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL50"), 1000, false,true)
  SetPedDropsWeaponsWhenDead(ped,false)

  local relHash = GetHashKey("HATES_PLAYER")
  local plyHash = GetHashKey("PLAYER")
  local copHash = GetHashKey("COP")

  SetRelationshipBetweenGroups(5, relHash, plyHash)
  SetRelationshipBetweenGroups(5, plyHash, relHash)
  SetRelationshipBetweenGroups(2, copHash, relHash)
  SetRelationshipBetweenGroups(2, relHash, copHash)

  SetPedRelationshipGroupHash(ped,relHash)
  SetPedRelationshipGroupDefaultHash(ped,relHash)
  ClearPedTasksImmediately(ped)
  SetEntityMaxHealth(ped, 350)
  SetEntityHealth(ped, 350)
  SetPedSuffersCriticalHits(ped, false)

  TaskCombatPed(ped, PlayerPedId(), 0, 16)

  Citizen.CreateThread(function()
    Wait(120000)
    SetEntityAsNoLongerNeeded(ped)
    RemoveAnimDict('mp_bedmid')
    SetModelAsNoLongerNeeded(hash)
  end)
end

robbery.delPed = function(loc)
  if robbery.inHouse and robbery.inHouse.ped and robbery.inHouse.entry.xyz == loc.xyz then
    robbery.inHouse.pedAttacked = true
    SetEntityAsMissionEntity(robbery.inHouse.ped,true,true)
    DeleteEntity(robbery.inHouse.ped)
  end
end

robbery.tryLoot = function(pos)
  BJCore.Functions.TriggerServerCallback('robbery:tryLoot', function(looted)
    local plyPed = PlayerPedId()    
    if not looted then
      if math.random(100) <= 50 then
        TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
      end      
      FreezeEntityPosition(plyPed,true)
      exports['mythic_progbar']:Progress({
        name = "burglary_search",
        duration = 15 * 1000,
        label = "Searching",
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInteract = true
        },
        animation = { task = "PROP_HUMAN_BUM_BIN" }
      }, function(status)
        if not status then
          FreezeEntityPosition(plyPed,false)
          TriggerServerEvent('robbery:looted',robbery.currentInterior.loot[pos].tab,robbery.currentInterior.difficulty)
        end
      end)
    else
      BJCore.Functions.Notify('There is nothing to loot here', 'primary')
    end
    FreezeEntityPosition(plyPed,false)
  end, robbery.inHouse.entry, pos)
end

robbery.alertPolice = function(pos)
  robbery.plyData = BJCore.Functions.GetPlayerData()
  --TriggerServerEvent('MF_Trackables:Notify','A burglary alarm has been triggered at a home', pos,'police','bande')
end

robbery.spawnDog = function(loc)
  local forward = GetEntityForwardVector(PlayerPedId())
  local pos = GetEntityCoords(PlayerPedId())
  local nPos = pos + (forward * 10)
  local found,z = GetGroundZFor_3dCoord(nPos.x,nPos.y,nPos.z)

  local hash = GetHashKey("a_c_rottweiler")
  RequestModel(hash)
  while not HasModelLoaded(hash) do RequestModel(hash); Wait(10); end

  local relHash = GetHashKey("HATES_PLAYER")
  local plyHash = GetHashKey("PLAYER")
  local copHash = GetHashKey("COP")

  local dog = CreatePed(28, hash, nPos.x,nPos.y,(found and z or nPos.z), 0.0, true,false)

  SetPedRelationshipGroupHash(dog,relHash)
  SetPedRelationshipGroupDefaultHash(dog,relHash)

  SetRelationshipBetweenGroups(5, relHash, plyHash)
  SetRelationshipBetweenGroups(5, plyHash, relHash)
  SetRelationshipBetweenGroups(2, copHash, relHash)
  SetRelationshipBetweenGroups(2, relHash, copHash)

  TaskCombatPed(dog,PlayerPedId(),0,16)

  Citizen.CreateThread(function()
    Wait(30000)
    SetEntityAsNoLongerNeeded(dog)
    SetModelAsNoLongerNeeded(hash)
  end)
end

robbery.spawnPed = function(pos)
  local hash = GetHashKey("csb_jackhowitzer")
  RequestModel(hash)
  while not HasModelLoaded(hash) do RequestModel(hash); Wait(10); end

  local ped = CreatePed(4, hash, pos.x,pos.y,pos.z, 273.0, false,false)
  robbery.inHouse.ped = ped
  FreezeEntityPosition(ped,true)

  SetEntityInvincible(ped,true)

  local dict = 'mp_bedmid'
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do Citizen.Wait(0); end

  SetBlockingOfNonTemporaryEvents(ped, true)
  TaskSetBlockingOfNonTemporaryEvents(ped, true)

  TaskPlayAnim(ped, dict, 'f_sleep_r_loop_bighouse', 8.0, 8.0, -1, 2, false,false,false)
end

robbery.setJob = function(job)
  if not robbery.plyData then return; end
  robbery.plyData.job = job
end

RegisterNetEvent('robbery:LockpickSuccess')
AddEventHandler('robbery:LockpickSuccess', function(...)
  robbery.lockpickResult(true)
  --print("Cracked")
end)

RegisterNetEvent('robbery:LockpickFail')
AddEventHandler('robbery:LockpickFail', function(...)
  robbery.lockpickResult(false)
  --print("Failed")
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
  robbery.plyData.job = JobInfo
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
  robbery.plyData = Player
end)

utils.event(true,robbery.delPed,'robbery:delPed')
utils.event(true,robbery.pedAttacked,'robbery:pedAttacked')
utils.event(true,robbery.spawnDog,'robbery:spawnDog')
utils.event(true,robbery.alertPolice,'robbery:alertPolice')
utils.event(false,robbery.lockpickResult,'robbery:lockpickResult')

utils.thread(robbery.awake)
RegisterNetEvent('MF_Vangelico:NotifyPolice')
RegisterNetEvent('MF_Vangelico:SyncLoot')

local MFV = MF_Vangelico

local polOnline = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
  polOnline = amount or 0
end)


function MFV:Start(...)
  self.SoundID = GetSoundId() 
  self.Timer = GetGameTimer()
  self.Looted = {}
  BJCore.Functions.TriggerServerCallback('MF_Vangelico:GetLootStatus', function(loot) 
    self.LootRemaining = loot
    for k,v in pairs(self.LootRemaining) do 
      local loot = true
      local noloot = false
      local count = 0 
      for k,v in pairs(v) do
        if v == 0 then
          if not loot then
            noloot = true
          else 
            loot = false
          end 
        else
          if noloot then noloot = false; end
          loot = true
        end
      end
      if not loot and noloot then
        self.Looted[k] = true
      end
    end
    self:Update()
  end)
end

function MFV:Update()
  while true do
    Citizen.Wait(0)  
      local plyPed = PlayerPedId()
      local plyPos = GetEntityCoords(plyPed)
      if (#(plyPos - self.VangelicoPosition) < self.LoadZoneDist) and not self.DoingAction then   
        if not self.InZone then     
          self.InZone = true
        end
        if polOnline and polOnline >= self.MinPoliceOnline then  
          if not self.DeletedSeats then self:DeleteSeats(); end
          local key,val,closestDist,safe,power = self:GetClosestMarker(plyPos)
          if closestDist < self.InteractDist then
            if not safe and not power then           
              if self.UsingSafe then
                self.UsingSafe = false
                TriggerEvent('safecracker:EndGame')
              end
              local lootRemains
              for k,v in pairs(self.LootRemaining[key]) do if v and v > 0 then lootRemains = true; end; end
              if (not self.Looted or (self.Looted and not self.Looted[key])) and lootRemains then
                BJCore.Functions.DrawText3D(val.Pos.x,val.Pos.y,val.Pos.z, "[~r~E~s~] Break glass",0.7)
                if Utils:GetKeyPressed("E") then
                  self:Interact(key,val, plyPed,false,false)
                end
              end
            elseif power then
              BJCore.Functions.DrawText3D(val.x,val.y,val.z, "[~r~E~s~] Disable Door Lock",0.7)
              if Utils:GetKeyPressed("E") then
                self:Interact(key,val, plyPed,false,true)
              end
            elseif not self.SafeUsed then
              BJCore.Functions.DrawText3D(self.SafePos.x,self.SafePos.y,self.SafePos.z, "[~r~E~s~] Access safe",0.7)
              if not self.Interacting and Utils:GetKeyPressed("E") then
                self:Interact(key,val, plyPed,true,false)
              end
            end
          else
            if self.UsingSafe then
              self.UsingSafe = false
              TriggerEvent('safecracker:EndGame')
            end
          end
        end
      else
        SetModelAsNoLongerNeeded("s_m_m_security_01")
        BJCore.Functions.RemoveAnimDict('missheist_jewel')
        if self.UsingSafe then
          self.UsingSafe = false
          TriggerEvent('safecracker:EndGame')
        end
        self.InZone = false
        self.DeletedSeats = false
        self.SentCopNotify = false
        Citizen.Wait(1000)
      end
  end
end     

function MFV:DeleteSeats()
  local newPos = vector3(-625.243, -223.44, 37.78)
  TriggerEvent('safecracker:SpawnSafe', false, newPos, 0.0)
  self.DeletedSeats = true
  local objects = BJCore.Functions.GetObjects()
  for k,v in pairs(objects) do
    local model = GetEntityModel(v) % 0x100000000
    if model == self.SeatHash then 
      SetEntityAsMissionEntity(v,false)
      DeleteObject(v)
    end
  end
end

function MFV:GetClosestMarker(pos)
  local key,val,dist,safe,power
  for k,v in pairs(self.MarkerPositions) do
    local curDist = #(pos - v.Pos)
    if not dist or curDist < dist then
      key = k
      val = v
      dist = curDist
      safe = false
      power = false
    end
  end

  local curDist = #(pos - self.SafePos)
  if not dist or curDist < dist then
    key = false
    val = false
    dist = curDist
    safe = true
    power = false
  end

  for k,v in pairs(self.PowerPos) do
    local curDist = #(pos - v)
    if not dist or curDist < dist then
      key = k
      val = v
      dist = curDist
      safe = false
      power = true
    end
  end

  if not dist then return false,false,false,false,false
  else return key,val,dist,safe,power
  end
end

function MFV:Interact(key,val, plyPed, safe, power)
  if not safe and not power then
    local plyWeapon = GetCurrentPedWeapon(plyPed)

    local weapHash = GetSelectedPedWeapon(plyPed) % 0x100000000

    local matching = false
    local forced = false
    for k,v in pairs(self.WeaponDisableOverrides) do if v == weapHash then matching = true; end; end
    for k,v in pairs(self.WeaponEnableOverrides) do if v == weapHash then forced = true; end; end

    if (self.CaseSmashFilter == 3 and weapHash ~= 0xA2719263) or ((IsPedArmed(PlayerPedId(), self.CaseSmashFilter) and not matching and plyWeapon)) or forced then
      self.Looted = self.Looted or {}
      self.Looted[key] = true
      self.DoingAction = true
      TriggerServerEvent('MF_Vangelico:MarkLoot', key,val)
      local loot = self.LootRemaining[key]

      TaskTurnPedToFaceCoord(plyPed, val.Pos.x, val.Pos.y, val.Pos.z, -1)
      Wait(1500)
      BJCore.Functions.LoadAnimDict("missheist_jewel")
      TaskPlayAnim( plyPed, "missheist_jewel", "smash_case_tray_a", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
      Wait(500)

      if not HasNamedPtfxAssetLoaded("scr_jewelheist") then RequestNamedPtfxAsset("scr_jewelheist"); end
      while not HasNamedPtfxAssetLoaded("scr_jewelheist") do Citizen.Wait(0); end    

      SetPtfxAssetNextCall("scr_jewelheist")
      StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", val.Pos.x, val.Pos.y, val.Pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)                
      PlaySoundFromCoord(-1, "Glass_Smash", val.Pos.x, val.Pos.y, val.Pos.z, 0, 0, 0, 0)
      Wait(2400)

      ClearPedTasks(plyPed)

      if math.random(1, 100) <= 35 and not exports["crim"]:IsWearingGloves() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
      end

      if math.random(100) <= 30 then
        TriggerServerEvent('bj-hud:Server:GainStress', 1)
      end

      exports['mythic_progbar']:Progress({
          name = "vangelico_loot",
          duration = 20 * 1000,
          label = "Looting",
          canCancel = false,
          controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
            disableInteract = true
          },
          animation = {
            animDict = 'anim@heists@ornate_bank@grab_cash',
            anim = 'grab',
          }
      }, function(status)
        if not status then
          if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
          TriggerServerEvent('MF_Vangelico:Loot', key,val)
        end
      end)
      TriggerServerEvent('MF_Trackables:Notify', 'Vangelico Jewelry Store is being robbed', MFV.VangelicoPosition, 'police', 'bank')
      -- if not self.SentCopNotify then
      --   TriggerServerEvent('MF_Vangelico:NotifyCops')
      -- end
      self.DoingAction = false
    elseif not plyWeapon then
      exports['core']:SendAlert('error', 'You need something to break the glass with', 2500)
    elseif matching then
      exports['core']:SendAlert('error', 'You can\'t break the glass with this', 2500)     
    end
  elseif power then
    local check = 'screwdriverset'
    if key ~= 1 then check = 'gatecrack'; end
    BJCore.Functions.TriggerServerCallback('fibheist:CheckInvCount', function(itemCount)
      if itemCount > 0 then
        BJCore.Functions.TriggerServerCallback('MF_Vangelico:GetPowerState', function(canUse)
          if canUse then
            if math.random(1, 100) <= 25 and not exports["crim"]:IsWearingGloves() then
              TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
            end
            if math.random(100) <= 30 then
              TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
            end                      
            TaskTurnPedToFaceCoord(plyPed,val.x,val.y,val.z, -1)
            Wait(1500)
            FreezeEntityPosition(plyPed, true)
            if key == 1 then
              exports['mythic_progbar']:Progress({
                name = "vangelico_hack_door",
                duration = 6000,
                label = "Preparing tools",
                canCancel = false,
                controlDisables = {
                  disableMovement = true,
                  disableCarMovement = true,
                  disableMouse = false,
                  disableCombat = true,
                  disableInteract = true
                },
                animation = {
                  animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                  anim = 'machinic_loop_mechandplayer',
                }
              }, function(status)
                if not status then
                  local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
                  local animName = "machinic_loop_mechandplayer"
                  while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
                  TaskPlayAnim(PlayerPedId(), animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)
                  TriggerEvent('bj_minigames:start', 'Connection', { cable = 5, timeout = 7500 }, function(data)
                    exports['core']:SendAlert('success', 'Door locking system disabled temporarily', 5500)
                    TriggerServerEvent('fibheist:ChanceRemove', 'screwdriverset')
                    TriggerEvent('doorlock:client:disableDoor', 3, 1, true)
                    if math.random(100) <= 35 then
                      TriggerServerEvent('MF_Vangelico:AddHackRep')
                    end
                    ClearPedTasksImmediately(PlayerPedId())
                    FreezeEntityPosition(PlayerPedId(), false)
                  end, function(data)
                    TriggerServerEvent('fibheist:ChanceRemove', 'screwdriverset')
                    FreezeEntityPosition(PlayerPedId(), false)
                    ClearPedTasksImmediately(PlayerPedId())
                    exports['core']:SendAlert('error', 'Failed', 3500)
                  end)
                  if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "wirecuts", 1200); end
                  TriggerServerEvent('fibheist:ChanceRemove', 'screwdriverset') 
                end
              end)
            else
              exports['mythic_progbar']:Progress({
                name = "vangelico_hack_door2",
                duration = 6000,
                label = "Preparing device",
                canCancel = false,
                controlDisables = {
                  disableMovement = true,
                  disableCarMovement = true,
                  disableMouse = false,
                  disableCombat = true,
                  disableInteract = true
                },
                animation = { task = "WORLD_HUMAN_STAND_MOBILE" }
              }, function(status)
                if not status then
                  local animDict = "mp_fbi_heist"
                  local animName = "loop"
                  while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
                  TaskPlayAnim(PlayerPedId(), animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)
                  TriggerEvent("mhacking:show")
                  TriggerEvent("mhacking:start",5,15,self.HackingCb)
                end
              end)          
            end
          else
            exports['core']:SendAlert('inform', 'On cooldown', 2500)
          end
        end)
      else
        exports['core']:SendAlert('error', 'You don\'t have the tools to do this', 2500)
      end
    end, check)
  else 
    BJCore.Functions.TriggerServerCallback('fibheist:CheckInvCount', function(itemCount)
      if itemCount > 0 then
        self.SafeUsed = true
        BJCore.Functions.TriggerServerCallback('MF_Vangelico:GetSafeState', function(canUse)
          if canUse then
            if math.random(100) <= 50 then
              TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
            end          
            if math.random(1, 100) <= 35 and not exports["crim"]:IsWearingGloves() then
              TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
            end         
            self.UsingSafe = true
            self:SheckForStun()
            local plyPed = PlayerPedId()
            FreezeEntityPosition(plyPed,true)        
            local animDict = "mini@safe_cracking"
            local animName = "dial_turn_anti_fast_3"
            while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
            TaskPlayAnim(plyPed, animDict, animName, 1.0, 1.0, -1, 2, 0, 0, 0)
            Citizen.CreateThread(function()
              Citizen.Wait(math.random(1000,10000))
              self:SpawnGuardNPC()
            end)
            TriggerEvent('bj_minigames:start', 'Safecrack', { combinations = 6, timeout = 65000 }, function(data)
              --TriggerServerEvent('MF_PacificStandard:AddReward',self.SafeRewards)
              --exports['core']:SendAlert('success', 'Success', 2500)
              TriggerEvent('safecracker:EndGame', true, self.SafeRewards)
              ClearPedTasks(plyPed)
              FreezeEntityPosition(plyPed,false)
              self.DoingAction = false
              self.UsingSafe = false          
            end, function(data)
              ClearPedTasks(plyPed)
              FreezeEntityPosition(plyPed,false)
              self.DoingAction = false
              self.UsingSafe = false
              TriggerEvent('safecracker:EndGame', false, nil)
              --exports['core']:SendAlert('error', 'Failed', 2500)
              TriggerServerEvent('fibheist:ChanceRemove', 'stethoscope')
              if math.random(100) <= 50 then
                TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
              end              
            end)

          else
            exports['core']:SendAlert('error', 'Somebody has already cracked this safe', 2500)
          end
        end)
      else
        BJCore.Functions.Notify("You don't have the right tools to attempt this", "error")
      end
    end, 'stethoscope')
  end
end

function MFV:SheckForStun()
  Citizen.CreateThread(function( ... )
    while UsingSafe do
      local plyPed = PlayerPedId()
      if IsPedBeingStunned(plyPed) or HasEntityBeenDamagedByAnyPed(plyPed) then
        print("stunned or damaged fam")
        ClearPedTasks(plyPed)
        FreezeEntityPosition(plyPed, false)
        TriggerEvent('bj_minigames:stop', 'Safecrack')
        self.DoingAction = false
        self.UsingSafe = false
        TriggerServerEvent('MF_Vangelico:ResetSafe')
        BJCore.Functions.Notify("Safe cracking interrupted. Cracking cancelled", "error")
      end
      Citizen.Wait(1)
    end
  end)
end

function MFV:HackingCb(success)
  print(tostring(success))
  local self = MFF
  TriggerEvent('mhacking:hide')
  Wait(100) 
  ClearPedTasks(PlayerPedId())
  FreezeEntityPosition(PlayerPedId(), false)
  if success ~= 0 then  
    exports['core']:SendAlert('success', 'Door locking system disabled temporarily', 5000)
    BJCore.Functions.Notify("You need to act fast. The door locking system will reboot at some point", "primary", 10000)
    TriggerEvent('doorlock:client:disableDoor', 3, 1, true)
    if math.random(100) <= 35 then
      TriggerServerEvent('MF_Vangelico:AddHackRep')
    end
  else
    exports['core']:SendAlert('error', 'Failed', 3500)
    self.Interacting = false
  end
  TriggerServerEvent('fibheist:ChanceRemove', 'gatecrack')   
end

function MFV:Awake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    self.PlayerData = BJCore.Functions.GetPlayerData()
    self:Start()
end

function MFV:SpawnGuardNPC()
  TriggerServerEvent('MF_Trackables:Notify', 'Vangelico Jewelry Store security is requesting assistance', MFV.VangelicoPosition, 'police', 'bank')
  --TriggerServerEvent('MF_Vangelico:NotifyCops')
  local nearby = BJCore.Functions.GetPlayersInArea(self.VangelicoPosition, 15.0)

  local hk = GetHashKey('s_m_m_security_01')
  if not HasModelLoaded(hk) then RequestModel(hk); end
  while not HasModelLoaded(hk) do RequestModel(hk); Citizen.Wait(0); end
  local plyPed = PlayerPedId()

  for k,v in pairs(nearby) do
    Citizen.CreateThread(function()
      
      local plyPos = GetEntityCoords(plyPed)
      local randNum = math.random(1,#self.BobSpawnPos)
      local newPed = CreatePed(4, hk, self.BobSpawnPos[randNum], 0.0, true, true)
      local target, _ = BJCore.Functions.GetClosestPlayer(self.BobSpawnPos[randNum])
      local targetPed = GetPlayerPed(target)

      SetPedRelationshipGroupHash(newPed, GetHashKey("AMBIENT_GANG_MEXICAN"))
      SetPedRelationshipGroupDefaultHash(newPed, GetHashKey("AMBIENT_GANG_MEXICAN"))

      GiveWeaponToPed(newPed, GetHashKey('weapon_stungun'), 1000, false, true)
      SetPedDropsWeaponsWhenDead(newPed,false)

      --TaskGo
      TaskGotoEntityAiming(newPed, targetPed, 3.0, 5.0)
      Wait(5000)

      local timer = GetGameTimer() 
      local dist = #(plyPos -GetEntityCoords(newPed))
      while dist > 10.0 do
        Citizen.Wait(100)
        targetPos = GetEntityCoords(targetPed)
        dist = #(targetPos - GetEntityCoords(newPed))       
      end
      ClearPedTasksImmediately(newPed)
      Citizen.Wait(1000)
      TaskCombatPed(newPed, targetPed, 0, 16)
      TaskShootAtEntity(newPed, targetPed, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
    end)
  end
end

-- function MFV:DoNotifyPolice(...)
--   if not BJCore then return; end
--   local plyData = BJCore.Functions.GetPlayerData()
--   if plyData.job.name == self.PoliceJobName then
--     TriggerServerEvent('MF_Trackables:Notify', 'Vangelico Jewelry Store is being robbed', MFV.VangelicoPosition, 'police', 'bank')
--   end
-- end

function MFV:DoSyncLoot(loot,new,key)
  if not self.LootRemaining then return; end
  self.LootRemaining = loot
  if key and self.Looted then self.Looted[key] = true; end
  if new then
    self.SafeUsed = false
    self.Looted = {}
  end
end

function MFV:SetJob(job)
  self.CurJob = job;
  self.PlayerData = BJCore.Functions.GetPlayerData()
end

AddEventHandler('MF_Vangelico:NotifyPolice', function(...) MFV:DoNotifyPolice(...); end)
AddEventHandler('MF_Vangelico:SyncLoot', function(loot,new,key) MFV:DoSyncLoot(loot,new,key); end)
RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
  MFV.PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
  MFV.PlayerData.job = JobInfo
end)

Citizen.CreateThread(function(...) MFV:Awake(...); end)

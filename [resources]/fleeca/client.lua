local MFF = fleeca

local polOnline = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
  polOnline = amount or 0
end)

function MFF:Start(...)
  while not BJCore do Citizen.Wait(1000); end
  while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
  self.PlayerData = BJCore.Functions.GetPlayerData()
  BJCore.Functions.TriggerServerCallback('fleeca:GetBankData', function(usedActions,BankData,G4SPlates) 
    self.UsedActions = usedActions
    self.BankData = BankData
    self.G4SPlates = G4SPlates
    self.AllowFront = false
    self.FrontOpen = false
    self:Update()
  end)
end

local powerBox = false

function MFF:Update()
  local tick = 0
  local lastPolCheck = GetGameTimer()
  while true do
    local waitTime = 0

    tick = tick + 1
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closestKey,closestVal,closestDist = self:GetClosestBank(plyPos)
    if closestDist < self.LoadDist then
      if closestDist < 25 and not self.ZoneLoaded then self:HandleDoors(); end      
      if polOnline and polOnline >= self.MinPoliceOnline then
        if not self.CurBank or self.CurBank.key ~= closestKey then
          self.CurBank = { key = closestKey, val = closestVal }
          self.SafeOpen = false
        end
        if self.CurBank.key == 1 and not powerBox then
          local boxModel = GetHashKey("xm_prop_x17_powerbox_01")
          while not HasModelLoaded(boxModel) do RequestModel(boxModel) Citizen.Wait(0); end
          local obj = CreateObject(boxModel, 292.12, -294.11, 53.97, false, false, false)
          SetEntityHeading(obj, 250.00)
          FreezeEntityPosition(obj, true)
          powerBox = obj
        end

        local actKey,actVal,actDist = self:GetClosestAction(plyPos,closestKey)
        if (actVal ~= "LootVault" and actVal ~= "DeskCash") or (actVal == "LootVault" and self.SafeOpen) or (actVal == "DeskCash" and self.FrontOpen) then
          if actDist < self.ActionDist and (not self.UsedActions[actKey] or self.PlayerData.job and self.PlayerData.job.name == "police") then
            if not self.CurAction or self.CurAction.key ~= actKey then
              self.CurAction = { key = actKey, val = actVal }
              self.CurText = "[~r~E~s~] " .. self.TextAddons[actVal]
            end

            if self.CurAction and not self.Interacting then
              if self.PlayerData.job and self.PlayerData.job.name ~= "police" and not self.UsedActions[actKey] then
                BJCore.Functions.DrawText3D(actKey.x, actKey.y, actKey.z, self.CurText, 0.7)
                if Utils:GetKeyPressed(self.InteractKey) then
                  self:Interact(self.CurAction,self.CurBank)
                end
              elseif self.CurAction and (self.CurAction.val == "OpenVault" or self.CurAction.val == "HackVault") and self.PlayerData.job and self.PlayerData.job.name == "police" then
                BJCore.Functions.DrawText3D(actKey.x, actKey.y, actKey.z, "[~g~E~s~] Restore & Re-Open Bank", 0.7)
                if Utils:GetKeyPressed(self.InteractKey) then
                  BJCore.Functions.Notify('Please make sure doorways are clear. The bank doors will be closed and secured in 5 seconds...','primary',5000)
                  Citizen.Wait(5000)
                  self:RestoreBank(self.CurBank)
                end
              end
            end
          end
        end
      else
        waitTime = 1000
      end
    else
      if powerBox and DoesEntityExist(powerBox) then DeleteObject(powerBox) powerBox = false; end
      self.ZoneLoaded = false
      self.CurBank = false
      self.SafeOpen = false
      self.FrontOpen = false
      waitTime = 1000
    end

    if self.MovedDoors then
      for k,v in pairs(self.MovedDoors) do
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos - GetEntityCoords(v))
        if dist > 50.0 then
          DeleteObject(v)
          table.remove(self.MovedDoors, k)
        end
      end
    end

    Citizen.Wait(waitTime)
  end
end

function MFF:RestoreBank(bank)
  BJCore.Functions.Notify('Bank has been restored and re-opened','primary',5500)
  TriggerServerEvent("fleeca:RestoreBank", bank.key)
  TriggerServerEvent("banking:openBank", bank.key)
end

function MFF:HandleDoors()
  local bankKey,bankVal,bankDist = self:GetClosestBank(GetEntityCoords(PlayerPedId()))
  local bankPos = self.Banks[bankKey]
  for k,v in pairs(self.BankData[bankKey]) do
    if type(k) ~= "string" then
      local doorObj = GetClosestObjectOfType(bankPos,30.0,k,0,0,0)
      if doorObj then 
        FreezeEntityPosition(doorObj,true)
        if v["locked"] == false and v["open"] == "open" then
          FreezeEntityPosition(doorObj,false)
        elseif v["locked"] == true and GetEntityHeading(doorObj) ~= v["closed"] then
          SetEntityHeading(doorObj,v["closed"])
        elseif v["locked"] == false and GetEntityHeading(doorObj) ~= v["open"] then
          SetEntityHeading(doorObj,v["open"])
        end
        if self.VaultHashes[GetEntityModel(doorObj)] and v["locked"] == false then
          self.SafeOpen = true
        end
        if (GetEntityModel(doorObj) == -131754413 or GetEntityModel(doorObj) == -1185205679) and v["locked"] == false then
          self.FrontOpen = true
        end
      end
    end
  end
  self.ZoneLoaded = true
end

RegisterNetEvent("fleeca:setDoor")
AddEventHandler("fleeca:setDoor", function()
  self = MFF
  for k,v in pairs(BlaineDoors) do
  	local doors = GetClosestObjectOfType(-106.88, 6469.62, 31.63, 30.0, k, 0, 0, 0)
  	FreezeEntityPosition(doors,true)
  	SetEntityHeading(doors,v)
  end
  self.ZoneLoaded = true
end)

function MFF:GetClosestBank(plyPos)
  local closestKey,closestVal,closestDist
  for k,v in pairs(self.Banks) do
    local dist = #(plyPos - v)
    if not closestDist or dist < closestDist then
      closestKey = k
      closestVal = v
      closestDist = dist
    end
  end
  if not closestDist then return false,false,999999
  else return closestKey,closestVal,closestDist
  end
end

function MFF:GetClosestAction(plyPos,key)
  local closestKey,closestVal,closestDist
  for k,v in pairs(self.Actions[key]) do
    local dist = #(plyPos - k)
    if not closestDist or dist < closestDist then
      closestKey = k
      closestVal = v
      closestDist = dist
    end
  end
  if not closestDist then return false,false,999999
  else return closestKey,closestVal,closestDist
  end
end

function MFF:Interact(closest,curbank)
  if self.Interacting then return; end
  if math.random(100) <= 50 then
    TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
  end
  self.Interacting = closest
  if closest.val == "LockpickDoor" then
   BJCore.Functions.TriggerServerCallback('fleeca:GetLockpickCount', function(count)
      if count and count > 0 then
        if not self.BankData[self.CurBank.key]["silentAlarm"] then
          TriggerServerEvent('fleeca:NotifyPolice', closest.key)
          if closest.key ~= vector3( -109.02,6468.38,31.63) then 
            TriggerServerEvent('MF_Trackables:Notify','Fleeca Vault has been compromised', closest.key,'police','bank')
          else
            TriggerServerEvent('MF_Trackables:Notify','Vault at Blaine County Savings Bank has been compromised', closest.key,'police','bank')
          end
        end
        self.IsLockpicking = true
        local plyPed = PlayerPedId()
        local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
        local animName = "machinic_loop_mechandplayer"
        while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
        FreezeEntityPosition(plyPed, true)
        TaskPlayAnim(plyPed, animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)
        SetCursorLocation(0.5, 0.5)   
        TriggerEvent('bj_minigames:start', 'Lockpick', { pins = 4, timeout = 6000 }, function(data)
          TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
          TriggerServerEvent('banking:closeBank',self.CurBank.key)
          ClearPedTasks(plyPed)
          FreezeEntityPosition(plyPed, false)          
          TriggerEvent("fleeca:LockpickSuccess")
        end, function(data)
          TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
          self.IsLockpicking = false
          self.Interacting = false
          ClearPedTasks(plyPed)
          FreezeEntityPosition(plyPed, false)        
          BJCore.Functions.Notify('Failed','error')
        end)
        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
          TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
        end        
        if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
      else
        BJCore.Functions.Notify('You don\'t have any lockpicks','error')
        self.Interacting = false
      end
    end)
  elseif closest.val == "HackVault" then
    self:HackVaultDoor(closest)
  elseif closest.val == "ThermiteDoor" then
    if not self.BankData[self.CurBank.key]["silentAlarm"] then
      TriggerServerEvent('fleeca:NotifyPolice', closest.key)
      TriggerServerEvent('MF_Trackables:Notify','Blaine County Savings Bank\'s doors are being tampered with', closest.key,'police','bank')
    end
    TriggerEvent('thermite:start', function(result,msg)
      self.IsLockpicking = true
      if result then
        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
          TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
        end       
        MFF:LockpickComplete(false)
      else
        self.Interacting = false
        self.IsLockpicking = false
      end
      BJCore.Functions.Notify(msg,'primary')
    end, 0.6,2.0,0.2)
  elseif closest.val == "LootID" then
    self:LootHandler(closest,true,curbank)
  elseif closest.val == "OpenVault" then
    BJCore.Functions.TriggerServerCallback('fleeca:CanOpenVault', function(result)
      if result.canOpen then
        if not self.BankData[self.CurBank.key]["silentAlarm"] then
          TriggerServerEvent('fleeca:NotifyPolice', closest.key)
          TriggerServerEvent('MF_Trackables:Notify','Fleeca Bank\'s vault has been compromised', closest.key,'police','bank')
        end
        if result.hackLevel == -1 then
          self:HandleVaultDoor(self.Interacting)
        else
          local hackLevel = MFF.HackLevelAdjustments[result.hackLevel]
          local hacks = {}
          for i=1, hackLevel.numberOfHacks do
            table.insert(hacks, math.random(hackLevel.min, hackLevel.max))
          end
          self.IsLockpicking = true
          self.BankCardSlot = result.slot
          TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
          TriggerEvent('mhacking:seqstart', hacks, hackLevel.time, self.FleecaHackingCb)
          if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
            TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
          end
        end
      else
        BJCore.Functions.Notify(result.reason,'error')
        self.Interacting = false
      end
    end, self.CurBank.key)
  elseif closest.val == "LootVault" then
    BJCore.Functions.TriggerServerCallback('fleeca:GetDrillCount', function(count)
      if count and count > 0 then
        self:LootHandler(closest,false,curbank)
      else
        BJCore.Functions.Notify('You need a drill open this box','error')
        self.Interacting = false
      end
    end)
  elseif closest.val == "FrontDoor" then
    if self.AllowFront and self.AllowFront == self.CurBank.key then
      self.IsLockpicking = true
      if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
      end      
      MFF:LockpickComplete(false)
      TriggerServerEvent('banking:closeBank',self.CurBank.key)    
    else
      BJCore.Functions.Notify("You haven't found the keys to this door",'error')
      self.Interacting = false
    end
  elseif closest.val == "DeskCash" then
    BJCore.Functions.TriggerServerCallback('fleeca:GetLockpickCount', function(count)
      if count and count > 0 then
        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
          TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
        end        
        self.IsLockpicking = true
        local plyPed = PlayerPedId()
        local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
        local animName = "machinic_loop_mechandplayer"
        while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
        TaskTurnPedToFaceCoord(plyPed, closest.key.x, closest.key.y, closest.key.z, -1)
        Wait(2000)
        FreezeEntityPosition(plyPed, true)
        TaskPlayAnim(plyPed, animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)   
        TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = 3, speed = 5, attempts = 1, stages = math.random(3,5), stageTimeout = 3000 }, function(data)
          TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
          self.IsLockpicking = false
          ClearPedTasks(plyPed)
          FreezeEntityPosition(plyPed, false) 
          BJCore.Functions.Notify('Success','success')
          self:LootHandler(closest,true,curbank)
        end, function(data)
          TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
          self.IsLockpicking = false
          self.Interacting = false
          ClearPedTasks(plyPed)
          FreezeEntityPosition(plyPed, false)        
          BJCore.Functions.Notify('Failed','error')
        end)
        if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
      else
        BJCore.Functions.Notify('You don\'t have any lockpicks','error')
        self.Interacting = false
      end
    end)
  elseif closest.val == "HackAlarm" then
    BJCore.Functions.TriggerServerCallback('fleeca:GetHackDeviceCount', function(count)
      if count and count > 0 then
        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
          TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
        end         
        local plyPed = PlayerPedId()
        self.IsLockpicking = true
        TaskTurnPedToFaceCoord(plyPed, closest.key.x, closest.key.y, closest.key.z, -1)
        Wait(2000)
        FreezeEntityPosition(plyPed, true)
        TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
        exports['mythic_progbar']:Progress({
          name = "fleeca_hack_alarm",
          duration = 4000,
          label = "Preparing device",
          canCancel = false,
          controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
            disableInteract = true
          },
        }, function(status)
          if not status then
            TriggerServerEvent('fibheist:ChanceRemove', 'repairkit')
            TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_STAND_MOBILE", 0, false)
            TriggerEvent("utk_fingerprint:Start", 4, 3, 2, function(outcome, reason)
              if outcome == true then
                print("success")
                self.IsLockpicking = false
                ClearPedTasks(plyPed)
                FreezeEntityPosition(plyPed, false)
                self.UsedActions[closest.key] = true
                TriggerServerEvent('fleeca:SyncBankData', closest.key, true)
                TriggerServerEvent("fleeca:DisableAlarm", self.CurBank)
                self.Interacting = false
                BJCore.Functions.Notify('Bank alarm system disabled temporarily. Backup system will turn on soon', 'primary',10000)
              elseif outcome == false then
                TriggerServerEvent('MF_Trackables:Notify','Fleeca Bank\'s alarm system has been tampered with', closest.key,'police','bank')
                self.IsLockpicking = false
                self.Interacting = false
                ClearPedTasks(plyPed)
                FreezeEntityPosition(plyPed, false)        
                -- Alert police
              end
            end)
          end
        end)
      else
        BJCore.Functions.Notify('You need a toolkit to access this','error',5500)
        self.Interacting = false        
      end
    end)
  end
end

function MFF:LootHandler(closest,desk,curbank)
  BJCore.Functions.TriggerServerCallback('fleeca:TryLoot',function(isLooted)
    if not isLooted then
      local plyPed = PlayerPedId()

      if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
      end      

      TaskTurnPedToFaceCoord(plyPed, closest.key.x, closest.key.y, closest.key.z, -1)
      Wait(2000)
      FreezeEntityPosition(plyPed,true)

      local doReward = true
      self.Busy = false

      if desk then
        self.Busy = true
        exports['mythic_progbar']:Progress({
          name = "fleeca_desk_cash",
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
          self.Busy = false
        end)
      else
        self.Drilling = true
        self.DrillResult = false
        TriggerEvent('Drilling:Start')
        while self.Drilling do Citizen.Wait(0); end
        TriggerServerEvent('fibheist:ChanceRemove', 'drill')
        if not self.DrillingResult then 
          doReward = false; 
        else
          self.Busy = true
          exports['mythic_progbar']:Progress({
          name = "fleeca_box",
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
            self.Busy = false
          end)
        end
      end
      while self.Busy do Citizen.Wait(0); end

      ClearPedTasksImmediately(plyPed)
      FreezeEntityPosition(plyPed,false)
      self.Interacting = false

      if doReward then
        self.UsedActions[closest.key] = true
        TriggerServerEvent('fleeca:RewardPlayer', closest.key, desk, curbank)
      end

      TriggerServerEvent('fleeca:SyncBankData', closest.key, doReward)
    else
      BJCore.Functions.Notify('Somebody else is looting this already','primary')
      self.Interacting = false
    end
  end,closest)
end

RegisterNetEvent('Drilling:Finish')
AddEventHandler('Drilling:Finish', function(result) if MFF.Drilling then MFF.DrillingResult = result; MFF.Drilling = false; end; end)

function MFF:LockpickComplete(isaVault)
  if not self.IsLockpicking then return; end
  self.IsLockpicking = false
  local plyPed = PlayerPedId()
  FreezeEntityPosition(plyPed,false)
  
    local closest,closestDist
    local allObjs = BJCore.Functions.GetObjects()
    for k,v in pairs(allObjs) do
      local modelHash = GetEntityModel(v)
      local revHash = modelHash % 0x100000000
      local kHash = nil
      if isaVault then
        kHash = self.VaultHashes
      else
        kHash = self.DoorHashes
      end
      if kHash[modelHash] or kHash[modelHash] then
        local dist = #(self.Interacting.key - GetEntityCoords(v))
        if not closestDist or dist < closestDist then
          closest = v
          closestDist = dist
        end
      end
    end

    if not closest or closestDist > self.LoadDist then 
      self.Interacting = false
      return 
    end

    local players = BJCore.Functions.GetPlayersInArea(self.Interacting.key, 80)   
    for k,v in pairs(players) do
      local newV = GetPlayerServerId(v)
      TriggerServerEvent('fleeca:SyncDoor', newV, self.Interacting.key, isaVault)
    end

    TriggerServerEvent('fleeca:SyncBankData', self.Interacting.key, true)
    timer = GetGameTimer()
    Citizen.CreateThread(function()
      while (GetGameTimer() - timer) < 500 do
        Citizen.Wait(0)
        DisableControlAction(0,18,true) -- disable attack
        DisableControlAction(0,24,true) -- disable attack
        DisableControlAction(0,25,true) -- disable aim
        DisableControlAction(0,47,true) -- disable weapon
        DisableControlAction(0,58,true) -- disable weapon
        DisableControlAction(0,69,true) -- disable weapon
        DisableControlAction(0,92,true) -- disable weapon
        DisableControlAction(0,106,true) -- disable weapon
        DisableControlAction(0,122,true) -- disable weapon
        DisableControlAction(0,135,true) -- disable weapon
        DisableControlAction(0,142,true) -- disable weapon
        DisableControlAction(0,144,true) -- disable weapon
        DisableControlAction(0,176,true) -- disable weapon
        DisableControlAction(0,223,true) -- disable melee
        DisableControlAction(0,229,true) -- disable melee
        DisableControlAction(0,237,true) -- disable melee
        DisableControlAction(0,257,true) -- disable melee
        DisableControlAction(0,263,true) -- disable melee
        DisableControlAction(0,264,true) -- disable melee
        DisableControlAction(0,257,true) -- disable melee
        DisableControlAction(0,140,true) -- disable melee
        DisableControlAction(0,141,true) -- disable melee
        DisableControlAction(0,142,true) -- disable melee
        DisableControlAction(0,143,true) -- disable melee
        DisableControlAction(0,329,true) -- disable melee
        DisableControlAction(0,347,true) -- disable melee
      end
    end)
    Citizen.Wait(200)
    self.Interacting = false
end

function MFF:LockpickFail(...)
  if not self.IsLockpicking then return; end
  self.IsLockpicking = false
  local plyPed = PlayerPedId()
  FreezeEntityPosition(plyPed,false)
  BJCore.Functions.Notify('You have failed the lockpick the door','error')
  self.Interacting = false
end

function MFF:Awake(...)
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    self:Start()
end

function MFF:HandleVaultDoor(closest)
  local plyPed = PlayerPedId()

  TaskTurnPedToFaceCoord(plyPed, closest.key.x, closest.key.y, closest.key.z, -1)
  Wait(2000)
  FreezeEntityPosition(plyPed,true)

  exports['mythic_progbar']:Progress({
    name = "fleeca_open_vault",
    duration = 20 * 1000,
    label = "Interacting",
    canCancel = false,
    controlDisables = {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true,
      disableInteract = true
    },
    animation = { task = "PROP_HUMAN_ATM" }
  }, function(status)
    self.UsedActions[closest.key] = true
    TriggerServerEvent('fleeca:SyncBankData', closest.key, true)
    TriggerServerEvent("fleeca:SetRobbed", self.CurBank)

    ClearPedTasksImmediately(plyPed)
    FreezeEntityPosition(plyPed,false)
    Wait(100)

    self.IsLockpicking = true
    BJCore.Functions.Notify('Access granted. Vault opening...','success')
    MFF:LockpickComplete(true)
    self.SafeOpen = true
  end)
end

function MFF:HackVaultDoor(closest)
  local self = MFF
  BJCore.Functions.TriggerServerCallback('fleeca:CanOpenVault', function(result)
    if result.canOpen then
      if not self.BankData[self.CurBank.key]["silentAlarm"] then
        TriggerServerEvent('fleeca:NotifyPolice', closest.key)
        TriggerServerEvent('MF_Trackables:Notify','Blaine County Savings Bank\'s vault has been compromised', closest.key,'police','bank')
      end
      if result.hackLevel == -1 then
        self:HandleVaultDoor(self.Interacting)
      else
        local hackLevel = MFF.HackLevelAdjustments[result.hackLevel]
        local hacks = {}
        for i=1, hackLevel.numberOfHacks do
          table.insert(hacks, math.random(hackLevel.min, hackLevel.max))
        end
        local plyPed = PlayerPedId()
  
        TaskTurnPedToFaceCoord(plyPed, closest.key.x, closest.key.y, closest.key.z, -1)
        Wait(2000)
  
        FreezeEntityPosition(plyPed,true)
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
        self.IsLockpicking = true
        self.BankCardSlot = result.slot
        TriggerEvent('mhacking:seqstart', hacks, hackLevel.time, self.HackingCb)
        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
          TriggerServerEvent("evidence:server:CreateFingerDrop", closest.key)
        end
      end
    else
      BJCore.Functions.Notify(result.reason,'error')
      self.Interacting = false
    end
  end, self.CurBank.key)
end

function MFF.FleecaHackingCb(success, remainingTime, finish)
  if finish or not success then
    local self = MFF
    TriggerEvent('mhacking:hide')
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    if success then
      TriggerServerEvent('banking:closeBank', self.CurBank.key)
      TriggerServerEvent('fleeca:RemoveCard', self.BankCardSlot)
      BJCore.Functions.Notify('Success','success')
      self:HandleVaultDoor(self.Interacting)
    else
      BJCore.Functions.Notify('Failed','error')
      self.Interacting = false
    end
    self.BankCardSlot = nil
  end
end

function MFF.HackingCb(success, remainingTime, finish)
  if finish or not success then
    local self = MFF
    TriggerEvent('mhacking:hide')
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    if success then
      TriggerServerEvent('banking:closeBank', self.CurBank.key)
      TriggerServerEvent('fleeca:RemoveCard', self.BankCardSlot)
      self.UsedActions[vector3( -105.58,6471.56,31.63)] = true
      TriggerServerEvent('fleeca:SyncBankData', vector3( -105.58,6471.56,31.63), true)       
      BJCore.Functions.Notify('Access granted. Vault opening...','success')
      MFF:LockpickComplete(true)
      self.SafeOpen = true
    else
      BJCore.Functions.Notify('You have failed to hack the vault security','error')
      self.Interacting = false
    end
    self.BankCardSlot = nil
  end
end

function MFF:NotifyPolice(data)
  --exports['mythic_notify']:SendAlert('inform', 'Somebody is robbing a Fleeca Bank', 5000)
  Citizen.CreateThread(function(...)
    local blipA = AddBlipForRadius(data.x, data.y, data.z, 50.0)
    SetBlipHighDetail(blipA, true)
    SetBlipColour(blipA, 1)
    SetBlipAlpha (blipA, 128)

    local blipB = AddBlipForCoord(data.x, data.y, data.z)
    SetBlipSprite               (blipB, 458)
    SetBlipDisplay              (blipB, 4)
    SetBlipScale                (blipB, 1.0)
    SetBlipColour               (blipB, 1)
    SetBlipAsShortRange         (blipB, true)
    SetBlipHighDetail           (blipB, true)
    BeginTextCommandSetBlipName ("STRING")
    AddTextComponentString      ("Robbery In Progress")
    EndTextCommandSetBlipName   (blipB)

    local timer = GetGameTimer()
    while GetGameTimer() - timer < 30000 do
      Citizen.Wait(0)
    end

    RemoveBlip(blipA)
    RemoveBlip(blipB)
  end)
end

function MFF:SyncDoor(location, isVault)
  if not location then return; end
  Citizen.CreateThread(function(...)
    local isaVault = false
    self.MovedDoors = self.MovedDoors or {}
    local closest,closestDist
    local allObjs = BJCore.Functions.GetObjects()
    for k,v in pairs(allObjs) do
      --print(k,v)
      local modelHash = GetEntityModel(v)
      local revHash = modelHash % 0x100000000
      local kHash = nil
      if isVault then
        kHash = self.VaultHashes
      else
        kHash = self.DoorHashes
      end      
      if kHash[modelHash] or kHash[revHash] then
        local dist = #(location - GetEntityCoords(v))
        if not closestDist or dist < closestDist then
          if modelHash == 2121050683 or revHash == 2121050683 or modelHash == -1185205679 or revHash == -1185205679 or modelHash == -63539571 then isaVault = true; else isaVault = false; end
          closest = v
          closestDist = dist
        end
      end
    end
    
    if not closest or closestDist > self.LoadDist then 
      self.Interacting = false
      return 
    end

    SetEntityAsMissionEntity(closest,false)
    local heading = GetEntityHeading(closest)
    if GetEntityModel(closest) == -1591004109 then
      FreezeEntityPosition(closest, false)
    else
      local tick = 0
      while ((heading - 100.0) < GetEntityHeading(closest)) and tick < 350 do
        Citizen.Wait(0)
        tick = tick + 1
        local heading = GetEntityHeading(closest)
        if GetEntityModel(closest) == -1185205679 then
          SetEntityHeading(closest, heading + 0.3)
        else
          SetEntityHeading(closest, heading - 0.3)
        end
      end
    end
    if isaVault then self.SafeOpen = true; end
    if (GetEntityModel(closest) == -131754413 or GetEntityModel(closest) == -1185205679) then self.FrontOpen = true; end
    table.insert(self.MovedDoors, closest)
    TriggerServerEvent('fleeca:SyncDoorState',self.CurBank,GetEntityModel(closest))
  end)
end

RegisterNetEvent('fleeca:SyncDoor')
AddEventHandler('fleeca:SyncDoor', function(location,isVault) MFF:SyncDoor(location,isVault); end)

RegisterNetEvent('fleeca:NotifyPolice')
AddEventHandler('fleeca:NotifyPolice', function(data) MFF:NotifyPolice(data); end)

RegisterNetEvent('fleeca:SyncBankData')
AddEventHandler('fleeca:SyncBankData', function(data) MFF.UsedActions = data; end)

RegisterNetEvent('fleeca:SyncDoorState')
AddEventHandler('fleeca:SyncDoorState', function(data) MFF.BankData = data; end)

RegisterNetEvent('fleeca:AllowFrontDoor')
AddEventHandler('fleeca:AllowFrontDoor', function(curbank) MFF.AllowFront = curbank end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
  MFF.PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
  MFF.PlayerData.job = JobInfo
end)

RegisterNetEvent('fleeca:RestoreBank')
AddEventHandler('fleeca:RestoreBank', function() MFF.ZoneLoaded = false; end)

RegisterNetEvent('fleeca:LockpickSuccess')
AddEventHandler('fleeca:LockpickSuccess', function(...)
  BJCore.Functions.Notify('Successfully lockpicked the door','success')
  MFF:LockpickComplete(false)
  --print("Cracked")
end)

RegisterNetEvent('fleeca:LockpickFail')
AddEventHandler('fleeca:LockpickFail', function(...)
  MFF:LockpickFail()
  --print("Failed")
end)

Citizen.CreateThread(function(...) MFF:Awake(...); end)

-- Start G4S trucks

--MFF.SpawnedG4S = {}
MFF.G4SPlates = {}
MFF.CurrentG4S = {}

-- RegisterNetEvent('fleeca:StartG4S')
-- AddEventHandler('fleeca:StartG4S', function()
--   local self = MFF
--   local randNum = math.random(1,#self.G4SSpawnLocs)
--   local spawnLoc = self.G4SSpawnLocs[randNum]
--   print('spawn loc: '..spawnLoc)
--   local hash = GetHashKey('stockade')
--   while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end  
--   local veh = CreateVehicle(hash, spawnLoc.x, spawnLoc.y, spawnLoc.z, spawnLoc.w, true, false)
--   -- local plate = 'G4S'..math.random(10000,99999)
--   -- SetVehicleNumberPlateText(veh, plate)
--   SetEntityAsMissionEntity(veh,true,true)
--   local id = NetworkGetNetworkIdFromEntity(veh)
--   SetNetworkIdCanMigrate(id, true)
--   SetModelAsNoLongerNeeded(hash)

--   local pedHash = -520477356
--   while not HasModelLoaded(pedHash) do RequestModel(pedHash); Citizen.Wait(0); end

--   local driver = CreatePedInsideVehicle(veh, 5, pedHash, -1, 1, 1)
--   local passenger = CreatePedInsideVehicle(veh, 5, pedHash, 0, 1, 1)
--   GiveWeaponToPed(driver, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
--   GiveWeaponToPed(passenger, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
--   SetNetworkIdCanMigrate(PedToNet(driver),true)
--   SetNetworkIdCanMigrate(PedToNet(passenger),true)
--   SetPedDropsWeaponsWhenDead(driver, false)
--   SetPedDropsWeaponsWhenDead(passenger, false)
--   SetModelAsNoLongerNeeded(pedHash)

--   SetVehicleDoorsLocked(veh,2)
--   SetVehicleDoorsLockedForAllPlayers(veh,true)
--   SetVehicleDoorsLockedForNonScriptPlayers(veh,true)

--   TaskVehicleDriveWander(driver, veh, 15.0, 524476)
--   SetPedKeepTask(driver,true)
--   SetPedKeepTask(passenger,true)
--   SetVehicleDoorsLocked(veh,2)
--   TriggerServerEvent('fleeca:SyncG4SPlate', plate)
--   --table.insert(self.SpawnedG4S,id)
-- end)

RegisterNetEvent('fleeca:SyncG4SPlate')
AddEventHandler('fleeca:SyncG4SPlate', function(data) MFF.G4SPlates = data; end)

Citizen.CreateThread(function()
  local self = MFF
  while true do
    Citizen.Wait(0)

    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)

    --if polOnline and polOnline >= self.MinPoliceOnline then
      local veh = GetClosestVehicle2(plyPos, 5.5, GetHashKey('stockade'))
      local text = GetOffsetFromEntityInWorldCoords(veh, 0.0, -4.25, 0.0)       
      local dist = #(plyPos - text)
      if DoesEntityExist(veh) then
        --deldeadGuards()
        local plate = GetVehicleNumberPlateText(veh)
        if not self.isRobbing and self.G4SPlates[plate] and self.G4SPlates[plate]["rob"] and not self.Lootable then
          if dist < 2.0 then
            local text = GetOffsetFromEntityInWorldCoords(veh, 0.0, -4.25, 0.0)
            --DrawMarker(27, text.x, text.y, text.z-0.55, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 255, 0, 0, 100, 0, 0, 0, 0)
            BJCore.Functions.DrawText3D(text.x, text.y, text.z+0.3, "[~r~E~s~] Rob", 0.7)
            if dist < 1.0 then
              if Utils:GetKeyPressed(self.InteractKey) then
                if GetEntitySpeed(veh) < 1 then
                  BJCore.Functions.TriggerServerCallback('fibheist:CheckInvCount', function(count)
                    if count and count >= 1 then 
                      TriggerServerEvent("fleeca:ManagePlate", plate, "rob", false)
                      FreezeEntityPosition(plyPed,true)
                      self.isRobbing = true
                      --TriggerEvent('llrp_crim:startLockpick', 'fleeca:G4SLockpickSuccess', 'fleeca:G4SLockpickFail')
                      MFF.G4SRob(plate)
                      self.CurrentG4S = plate
                      local vehPos = GetEntityCoords(veh)
                      TriggerServerEvent('fleeca:NotifyPolice', vehPos)
                      TriggerServerEvent('MF_Trackables:Notify','Gruppe 6 truck distress call received', vehPos,'police','bank')
                    else
                      BJCore.Functions.Notify("You need an advanced lockpick for this",'error')
                    end
                  end, 'advancedlockpick')
                else
                  BJCore.Functions.Notify("You can't rob this vehicle while it's moving",'error',5000)
                end
              end
            end
          end
        end

        if plate == self.CurrentG4S and self.Lootable and GetEntitySpeed(veh) < 1 then
          local text = GetOffsetFromEntityInWorldCoords(veh, 0.0, -4.25, 0.0)
          --DrawMarker(27, text.x, text.y, text.z-0.55, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 0, 255, 0, 100, 0, 0, 0, 0)
          BJCore.Functions.DrawText3D(text.x, text.y, text.z+0.3, "[~r~E~s~] Loot", 0.7)
          if dist < 1.0 then 
            if Utils:GetKeyPressed(self.InteractKey) then
              if GetEntitySpeed(veh) < 1 then
                self.G4SLoot(self.CurrentG4S, GetEntityCoords(veh))
              else
                BJCore.Functions.Notify("You can't loot the truck while it's moving",'error')
              end
            end
          end
        end

        if self.G4SPlates[plate] and not self.G4SPlates[plate]["rob"] and self.G4SPlates[plate]["glovebox"] then
          if GetPedInVehicleSeat(veh, 0) == PlayerPedId() then
            local text = GetOffsetFromEntityInWorldCoords(veh, 0.7, 1.5, 0.0)
            BJCore.Functions.DrawText3D(text.x, text.y, text.z+1.3, "[~r~E~s~] Search")
            if Utils:GetKeyPressed(self.InteractKey) then
              self:G4SSearchGloveBox(plate)
            end
          end
        end

      else
        Citizen.Wait(500)
      end
    --end
  end
end)

function MFF.G4SRob(plate)
  local self = MFF
  local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
  local anim = "machinic_loop_mechandplayer"

  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Citizen.Wait(100)
  end  
  local plyPed = PlayerPedId()
  TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 16, -1, false, false, false)  
  FreezeEntityPosition(plyPed,true)
  TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = 3, speed = 4, attempts = 1, stages = math.random(6,8), stageTimeout = 3200 }, function(data)
    TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 2))
    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    exports['mythic_progbar']:Progress({
      name = "g4s_rob",
      duration = 50 * 1000,
      label = "Opening rear door",
      canCancel = false,
      controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
        disableInteract = true
      },
      animation = {task = 'PROP_HUMAN_BUM_BIN'}
    }, function(status)
      if not status then
        ClearPedTasksImmediately(plyPed)
        FreezeEntityPosition(PlayerPedId(),false)
        TriggerServerEvent("fleeca:RequstSpawnGuards", VehToNet(GetClosestVehicle2(GetEntityCoords(plyPed), 5.5, GetHashKey('stockade'))))
        self.isRobbing = false
        self.Lootable = true
      else
        BJCore.Functions.Notify("Cancelled", "error")
        self.isRobbing = false
        TriggerServerEvent("fleeca:ManagePlate", plate, "rob", true)
      end
    end)
  end, function(data)
    BJCore.Functions.Notify("Failed", "error")
    self.isRobbing = false
    ClearPedTasksImmediately(plyPed)
    FreezeEntityPosition(plyPed,false)
    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    TriggerServerEvent("fleeca:ManagePlate", plate, "rob", true)
    TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 2))
  end)
  TriggerServerEvent('fibheist:ChanceRemove', 'advancedlockpick')
end

-- RegisterCommand("g4s", function(source, args, rawCommand)
--   TriggerEvent('fleeca:StartG4S')
-- end, false)

function MFF.G4SSearchGloveBox(plate)
  local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
  local anim = "machinic_loop_mechandplayer"

  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Citizen.Wait(100)
  end
  TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 16, -1, false, false, false)  
  TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = 2, speed = 4, attempts = 1, stages = math.random(4,6), stageTimeout = 2800 }, function(data)
    TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 2))
    exports['mythic_progbar']:Progress({
      name = "g4s_search",
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
    }, function(status)
      if not status then
        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        TriggerServerEvent("fleeca:ManagePlate", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), "glovebox", false)
        TriggerServerEvent("fleeca:server:LootGlovebox", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
      end
    end)  
  end, function(data)
    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 2))
    BJCore.Functions.Notify("Failed. Glovebox security lock has been engaged", "error", 7000)
  end)  
  TriggerServerEvent('fibheist:ChanceRemove', 'advancedlockpick')
  if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
    TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
  end
end

function MFF.G4SLoot(plate, loc)
  local self = MFF
  BJCore.Functions.TriggerServerCallback('fleeca:G4SLootCash',function(canLoot)
    if canLoot then
      local plyPed = PlayerPedId()  
      TaskTurnPedToFaceCoord(plyPed, loc.x, loc.y, loc.z, -1)
      Wait(1500)

      exports['mythic_progbar']:Progress({
        name = "g4s_loot",
        duration = 180 * 1000,
        label = "Looting truck",
        canCancel = true,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInteract = true
        },
        animation = {
          animDict = "mp_take_money_mg",
          anim = "stand_cash_in_bag_loop",
        }
      }, function(status)
        if not status then
          ClearPedTasksImmediately(plyPed)
          FreezeEntityPosition(plyPed,false)
          Wait(1000)
        else
          TriggerServerEvent("fleeca:ManagePlate", plate, "loot", true)
        end
      end)
    else
      BJCore.Functions.Notify('Somebody else has already looted this','error')
    end
    self.Lootable = false
    self.CurrentG4S = {}
  end, plate)
end

RegisterNetEvent('fleeca:G4SLockpickSuccess')
AddEventHandler('fleeca:G4SLockpickSuccess', function(...)
  BJCore.Functions.Notify('Lockpick successful','success')
  MFF.G4SRob()
  --print("Cracked")
end)

RegisterNetEvent('fleeca:G4SLockpickFail')
AddEventHandler('fleeca:G4SLockpickFail', function(...)
  local self = MFF
  BJCore.Functions.Notify('Lockpick failed','error')
  FreezeEntityPosition(PlayerPedId(),false)
  self.isRobbing = false
  self.Lootable = false
  --print("Failed")
end)

RegisterNetEvent("fleeca:createGuards")
AddEventHandler("fleeca:createGuards", function(veh)
  MFF.createG4SPed(veh)
end)

function MFF.createG4SPed(veh)
  local self = MFF
  local pos = GetEntityCoords(PlayerPedId())
  local hashKey = -520477356
  --local veh = GetClosestVehicle2(pos, 5.5, GetHashKey('stockade'))
  local veh = NetToVeh(veh)
  local p1, p2 = GetPedInVehicleSeat(veh, -1), GetPedInVehicleSeat(veh, 0)
  if p1 ~= 0 and p1 ~= -1 and DoesEntityExist(p1) and not IsPedAPlayer(p1) then TriggerServerEvent("RequestEntityDelete", PedToNet(p1)); end
  if p2 ~= 0 and p2 ~= -1 and DoesEntityExist(p2) and not IsPedAPlayer(p2) then TriggerServerEvent("RequestEntityDelete", PedToNet(p2)); end
  local pedType = 5
  
  while not HasModelLoaded(hashKey) do RequestModel(hashKey); Citizen.Wait(0) end

  guard = CreatePedInsideVehicle(veh, pedType, hashKey, 0, 1, 1)
  guard2 = CreatePedInsideVehicle(veh, pedType, hashKey, 1, 1, 1)
  guard3 =  CreatePedInsideVehicle(veh, pedType, hashKey, 2, 1, 1)
  guard4 =  CreatePedInsideVehicle(veh, pedType, hashKey, -1, 1, 1)    

--  Guard 1

  SetPedShootRate(guard,  750)
  SetPedCombatAttributes(guard, 46, true)
  SetPedFleeAttributes(guard, 0, 0)
  SetPedAsEnemy(guard,true)
  SetPedMaxHealth(guard, 3500)
  SetEntityHealth(guard, 3500)
  SetPedArmour(guard, 100) 
  SetPedAlertness(guard, 3)
  SetPedCombatRange(guard, 0)
  SetPedCombatMovement(guard, 3)
  GiveWeaponToPed(guard, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
  SetPedRelationshipGroupHash(guard, GetHashKey("HATES_PLAYER"))
  --TaskCombatPed(guard, PlayerPedId(), 0,16)
  --TaskLeaveVehicle(guard, veh, 0)
  TaskCombatHatedTargetsAroundPed(guard, 20.0)
  SetPedDropsWeaponsWhenDead(guard, false)

  --  Guard 2

  SetPedShootRate(guard2,  750)
  SetPedCombatAttributes(guard2, 46, true)
  SetPedFleeAttributes(guard2, 0, 0)
  SetPedAsEnemy(guard2,true)
  SetPedMaxHealth(guard2, 3500)
  SetEntityHealth(guard2, 3500)
  SetPedArmour(guard2, 100) 
  SetPedAlertness(guard2, 3)
  SetPedCombatRange(guard2, 0)
  SetPedCombatMovement(guard2, 3)
  TaskCombatPed(guard2, PlayerPedId(), 0,16)
  --TaskLeaveVehicle(guard2, veh, 0)
  GiveWeaponToPed(guard2, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
  SetPedRelationshipGroupHash(guard2, GetHashKey("HATES_PLAYER"))
  TaskCombatHatedTargetsAroundPed(guard2, 20.0)
  SetPedDropsWeaponsWhenDead(guard2, false)

  --  Guard 3

  SetPedShootRate(guard3,  750)
  SetPedCombatAttributes(guard3, 46, true)
  SetPedFleeAttributes(guard3, 0, 0)
  SetPedAsEnemy(guard3,true)
  SetPedMaxHealth(guard3, 3500)
  SetEntityHealth(guard3, 3500)    
  SetPedArmour(guard3, 100)   
  SetPedAlertness(guard3, 3)
  SetPedCombatRange(guard3, 0)
  SetPedCombatMovement(guard3, 3)
  GiveWeaponToPed(guard3, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
  SetPedRelationshipGroupHash(guard3, GetHashKey("HATES_PLAYER"))
  --TaskCombatPed(guard3, PlayerPedId(), 0,16)
  --TaskLeaveVehicle(guard3, veh, 0)
  TaskCombatHatedTargetsAroundPed(guard3, 20.0)
  SetPedDropsWeaponsWhenDead(guard3, false)

  --  Guard 4

  SetPedShootRate(guard4,  750)
  SetPedCombatAttributes(guard4, 46, true)
  SetPedFleeAttributes(guard4, 0, 0)
  SetPedAsEnemy(guard4,true)
  SetPedMaxHealth(guard4, 3500)
  SetEntityHealth(guard4, 3500)  
  SetPedArmour(guard4, 100)    
  SetPedAlertness(guard4, 3)
  SetPedCombatRange(guard4, 0)
  SetPedCombatMovement(guard4, 3)
  --TaskCombatPed(guard4, PlayerPedId(), 0,16)
  --TaskLeaveVehicle(guard4, veh, 0)
  GiveWeaponToPed(guard4, GetHashKey("WEAPON_COMBATPDW"), 5000, true, true)
  SetPedRelationshipGroupHash(guard4, GetHashKey("HATES_PLAYER"))
  TaskCombatHatedTargetsAroundPed(guard4, 20.0)
  SetPedDropsWeaponsWhenDead(guard4, false)    

  SetModelAsNoLongerNeeded(-520477356)
  self.isRobbing = false
  self.Lootable = true
end

deldeadGuards = function()
    local handle, ped = FindFirstPed()
    local success
    repeat
        local pos = GetEntityCoords(ped)
        local dist = #(storePos - pos)

        if dist < 10.0 then
        	if GetEntityModel(ped) == -520477356 and IsEntityDead(ped) and not IsPedAPlayer(ped) then Wait(1000) TriggerServerEvent('storerobbery:requestDelete', PedToNet(ped)); end
        end
        
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return ped
end

function GetClosestVehicle2(plyPos, radius, modelHash)
    if not plyPos or not radius then return end
    local handle, veh = FindFirstVehicle()
    local success, retVeh
    repeat
        local firstDist = #(GetEntityCoords(veh) - plyPos)
        if firstDist < radius and (not modelHash or modelHash == GetEntityModel(veh)) and (not retVeh or firstDist < #(GetEntityCoords(retVeh) - GetEntityCoords(veh))) then
            retVeh = veh
        end
        success, veh = FindNextVehicle(handle)
    until not success
        EndFindVehicle(handle)

    return retVeh
end

AddEventHandler("fleeca:client:dospawnstuff", function(pos)
  Citizen.CreateThread(function()
    -- local cull = {}
    local hash = GetHashKey('stockade')
    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end  
    local veh = CreateVehicle(hash, pos.x, pos.y, pos.z, pos.w, true, true)
    local plate = 'GRUP6'..math.random(100,999)
    SetVehicleNumberPlateText(veh, plate) 
    SetEntityAsMissionEntity(veh, true, true)
    -- SetNetworkIdCanMigrate(VehToNet(veh), true)
    -- NetworkRegisterEntityAsNetworked(veh)
    -- SetNetworkIdExistsOnAllMachines(VehToNet(veh), true)
    SetModelAsNoLongerNeeded(hash)
    -- cull[1] = VehToNet(veh)
    local pedHash = -520477356
    while not HasModelLoaded(pedHash) do RequestModel(pedHash); Citizen.Wait(0); end
    local driver = CreatePedInsideVehicle(veh, 5, pedHash, -1, 1, 1)
    Wait(100)
    TaskVehicleDriveWander(driver, veh, 15.0, 524476)
    SetPedKeepTask(driver,true)
    -- cull[2] = PedToNet(driver)    
    local passenger = CreatePedInsideVehicle(veh, 5, pedHash, 0, 1, 1)
    -- cull[3] = PedToNet(passenger)
    GiveWeaponToPed(driver, GetHashKey("WEAPON_COMBATPDW"), 5000, true, false)
    --Wait(100)
    GiveWeaponToPed(passenger, GetHashKey("WEAPON_COMBATPDW"), 5000, true, false)
    SetPedDropsWeaponsWhenDead(driver, false)
    SetPedDropsWeaponsWhenDead(passenger, false)
    SetPedAsCop(driver, true)
    SetPedAsCop(passenger, true)
    SetPedArmour(driver, 100)
    SetPedArmour(passenger, 100)    
    SetEntityAsMissionEntity(driver)
    SetEntityAsMissionEntity(passenger)
    -- NetworkRegisterEntityAsNetworked(driver)
    -- NetworkRegisterEntityAsNetworked(passenger)
    -- SetNetworkIdCanMigrate(PedToNet(driver),true)
    -- SetNetworkIdCanMigrate(PedToNet(passenger),true)
    -- SetNetworkIdExistsOnAllMachines(PedToNet(driver), true)
    -- SetNetworkIdExistsOnAllMachines(PedToNet(passenger), true)
    -- TriggerServerEvent("fleeca:server:MaxCulling", cull)
    print("Handed to client")
    TriggerServerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..MFF.PlayerData.name.."** has created money truck at "..tostring(pos))
    TriggerServerEvent('fleeca:SyncG4SPlate', plate)
    SetModelAsNoLongerNeeded(pedHash)
  end)
end)

function getRandomTruckSpawn()
  local rndSpawn = MFF.G4SSpawnLocs[math.random(#MFF.G4SSpawnLocs)]
  TriggerServerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..MFF.PlayerData.name.."** has used Gruppe6 intel and will spawn a money truck at "..tostring(rndSpawn))
  local doSpawn = false
  Citizen.CreateThread(function()
    BJCore.Functions.Notify("Bank Truck location added to your gps")
    local blipTruck = AddBlipForRadius(rndSpawn.x, rndSpawn.y, rndSpawn.z, 70.0)
    SetBlipHighDetail(blipTruck, true)
    SetBlipColour(blipTruck, 1)
    SetBlipAlpha (blipTruck, 128)
    doSpawn = true
    while doSpawn do
      local dist = #(GetEntityCoords(PlayerPedId()) - rndSpawn.xyz)
      if dist < 70 then
        RemoveBlip(blipTruck)
        BJCore.Functions.Notify("You're close by")
        TriggerEvent("fleeca:client:dospawnstuff", rndSpawn)
        doSpawn = false
      end
      Citizen.Wait(0)
    end
  end)
end

-- RegisterCommand("testtruck", function()
--   getRandomTruckSpawn()
-- end, false)

exports('getRandomTruckSpawn', getRandomTruckSpawn);
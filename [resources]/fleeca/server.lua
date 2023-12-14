RegisterNetEvent('fleeca:SyncBankData')
RegisterNetEvent('fleeca:SyncDoorState')
RegisterNetEvent('fleeca:RewardPlayer')
RegisterNetEvent('fleeca:NotifyPolice')
RegisterNetEvent('fleeca:SyncDoor')
RegisterNetEvent('fleeca:SyncG4SPlate')
RegisterNetEvent('fleeca:ManagePlate')
RegisterNetEvent('fleeca:RemoveCard')

local MFF = fleeca

function MFF:BankTemplate()
  local BankData = {
    [1] = { -- Pink Cage
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,
      [ -131754413] = { ["locked"] = true, ["open"] = 149.66, ["closed"] = 249.86 },
      [ 2121050683] = { ["locked"] = true, ["open"] = 149.66, ["closed"] = 249.86 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 159.86 }    
    },
    [2] = { -- Legion
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,      
      [ -131754413] = { ["locked"] = true, ["open"] = 149.64, ["closed"] = 249.84 },
      [ 2121050683] = { ["locked"] = true, ["open"] = 149.64, ["closed"] = 249.84 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 159.92 }     
    },
    [3] = { -- Rockford Hills
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,                 
      [ -131754413] = { ["locked"] = true, ["open"] = 196.66, ["closed"] = 296.86 },
      [ 2121050683] = { ["locked"] = true, ["open"] = 196.66, ["closed"] = 296.86 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 206.86 }      
    },
    [4] = { -- Great Ocean
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,                 
      [ -131754413] = { ["locked"] = true, ["open"] = 257.34, ["closed"] = 357.54 },
      [  -63539571] = { ["locked"] = true, ["open"] = 257.34, ["closed"] = 357.54 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 267.54 }      
    },
    [5] = { -- Route 68
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,                 
      [ -131754413] = { ["locked"] = true, ["open"] = 344.99, ["closed"] =  90.00 },
      [ 2121050683] = { ["locked"] = true, ["open"] = 344.99, ["closed"] =  90.00 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 359.97 }      
    },
    [6] = { -- Hawick Ave
      ["robbed"] =  false,
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,              
      [ -131754413] = { ["locked"] = true, ["open"] = 150.65, ["closed"] = 250.85 },
      [ 2121050683] = { ["locked"] = true, ["open"] = 150.65, ["closed"] = 250.85 },
      [-1591004109] = { ["locked"] = true, ["open"] = "open", ["closed"] = 160.86 }       
    },
    [7] = { -- Blaine County Savings Bank
      ["robbed"] =  false, 
      ["front"] = false,
      ["card"] = false,
      ["silentAlarm"] = false,                
      [-1185205679] = { ["locked"] = true, ["open"] = 300.00, ["closed"] =  45.00 },
      [-1184592117] = { ["locked"] = true, ["open"] = 300.00, ["closed"] =  45.00 },
      [ 1309269072] = { ["locked"] = true, ["open"] = 214.79, ["closed"] = -45.00 },
      [ 1622278560] = { ["locked"] = true, ["open"] = 300.00, ["closed"] =  45.00 }
    },
  }
  return BankData
end

hasRobbed = {} 
hasDisabledAlarm = {}

function MFF:DoTimer()  
  local delTab = {}   
  local time = GetGameTimer()   
  for key,val in pairs(hasRobbed) do     
    if (time - val) > (self.ResetTimer * 60 * 1000) then
      self:ResetBank(key)
      delTab[key] = true
    end
  end
  for k,v in pairs(delTab) do hasRobbed[k] = nil; end 

  local delTab2 = {}
  for key,val in pairs(hasDisabledAlarm) do
    if (time - val) > (90 * 1000) then
      self:ClearAlarm(key)
      delTab2[key] = true
    end    
  end
  for k,v in pairs(delTab2) do hasDisabledAlarm[k] = nil; end
end

RegisterServerEvent("fleeca:SetRobbed")
AddEventHandler("fleeca:SetRobbed", function(bank)
  local bank = bank.key
  MFF.BankData[bank]['robbed'] = true
  hasRobbed[bank] = GetGameTimer()
end)

RegisterServerEvent("fleeca:DisableAlarm")
AddEventHandler("fleeca:DisableAlarm", function(bank)
  local bank = bank.key
  MFF.BankData[bank]['silentAlarm'] = true
  hasDisabledAlarm[bank] = GetGameTimer()
  print("disabled alarm for bank: "..bank)
  TriggerClientEvent('fleeca:SyncBankData', -1, MFF.BankData)
end)

function MFF:Awake(...)
  while not BJCore do Citizen.Wait(0); end
  self:Start()
end

function MFF:Start()
  while not BJCore do Citizen.Wait(0) end
  self.UsedAction = {}
  self.G4SPlates = {}
  self.BankData = self:BankTemplate()
  for k,v in pairs(self.Actions) do
    for key,val in pairs(v) do
      self.UsedAction[key] = false
    end
  end
  self:Update()
end

function MFF:Update()
  while true do
    Wait(1000)
    self:DoTimer()
  end
end

function MFF:ClearAlarm(k)
  self.BankData[k]["silentAlarm"] = false
  TriggerClientEvent('fleeca:SyncDoorState', -1, self.BankData)
end

function MFF:ResetBank(bank)
  for k,v in pairs(self.Actions[bank]) do
    self.UsedAction[k] = false
  end
  for k,v in pairs(self.BankData[bank]) do
    if type(k) ~= "string" then
      self.BankData[bank][k]["locked"] = true
    else
      self.BankData[bank][v] = false
    end
  end
  TriggerEvent("banking:openBank", bank)
  TriggerClientEvent('fleeca:SyncBankData', -1, self.UsedAction)
  TriggerClientEvent('fleeca:SyncDoorState', -1, self.BankData)
end

function MFF:SetUpBanks()
  self.UsedAction = {}
  self.BankData = {}
  for k,v in pairs(self.Actions) do
    for key,val in pairs(v) do
      self.UsedAction[key] = false
    end
  end 
  self.BankData = self:BankTemplate()
  TriggerClientEvent('fleeca:SyncBankData', -1, self.UsedAction)
  TriggerClientEvent('fleeca:SyncDoorState', -1, self.BankData)
end

function MFF:GetBankData()
  if not self.UsedAction then
    self:SetUpBanks()
  end
  return self.UsedAction,self.BankData,self.G4SPlates
end

function MFF:SyncBankData(data,val)
  self.UsedAction[data] = val
  TriggerClientEvent('fleeca:SyncBankData', -1, self.UsedAction)
end

function MFF:SyncDoorState(curbank,hash)
  for k,v in pairs(self.BankData[curbank.key]) do
    if k == hash then
      self.BankData[curbank.key][k]["locked"] = false
    end
  end 
  if hash == -131754413 or hash == -1185205679 then self.BankData[curbank.key]["front"] = true; end
  TriggerClientEvent('fleeca:SyncDoorState', -1, self.BankData)
end

function MFF:RewardPlayer(data,desk,curbank)
  local src = source
  local pData = BJCore.Functions.GetPlayer(src)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(src); end
  if desk then
    local chance = math.random(100)
    if chance <= 5 and not self.BankData[curbank.key]["card"] then 
      pData.Functions.AddItem('repairkit', 1)
      self.BankData[curbank.key]["card"] = true
    end
    local camount = math.random(self.DeskLootTable["cash"].min, self.DeskLootTable["cash"].max)
    pData.Functions.AddItem('cashband', camount)
    TriggerClientEvent('BJCore:Notify', src,'You have found '..camount..' bands of money','primary')
  else
    local lootta
    if curbank.key == 7 then
      lootta = self.BlaineLootTable
    else
      lootta = self.LootTable
    end
    for k,v in pairs(lootta) do
      if k == "cash" then
        local camount = math.random(v.min,v.max)
        pData.Functions.AddItem('moneybag', camount)
        TriggerClientEvent("evidence:client:SetStatus", src, "inkedhands", 1500)
        TriggerClientEvent('BJCore:Notify', src,'You have found '..camount..' bags of money','primary')
      else
        local amount = math.random(0,v)
        if amount > 0 then
          pData.Functions.AddItem(k,amount)
        end
      end
    end
    local chance = math.random(100)
    if not self.BankData[curbank.key]["front"] and chance <= 10 then
      self.BankData[curbank.key]["front"] = true
      TriggerClientEvent('BJCore:Notify',src,"You found keys to the front office. Check to see if you can open the door",'primary',5500)
      TriggerClientEvent('fleeca:AllowFrontDoor', src, curbank.key)
    end
  end
end


function MFF:NotifyPolice(data)
  for k,v in pairs(BJCore.Functions.GetPlayers()) do
    local pData = BJCore.Functions.GetPlayer(v)
    while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(v); end
    if pData.PlayerData.job.name == self.PoliceJobName then
      TriggerClientEvent('fleeca:NotifyPolice', v, data)
    end
  end
end

function MFF:GetDrillCount(source)  
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  local count = pData.Functions.GetItemByName('drill')
  if count then count = count.amount; end
  if count and count > 0 then return count else return false; end
end

function MFF:GetIdCount(source,remove)  
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  if pData ~= nil and pData.PlayerData.job ~= nil and pData.PlayerData.job.name == 'police' then return 1; end
  local count = pData.Functions.GetItemByName('repairkit')
  if count then count = count.amount; end
  if count and count > 0 then
    if remove then pData.Functions.RemoveItem('repairkit', 1); end
    return count 
  else 
    return false
  end
end

function MFF:RemoveBankCard(source,slot)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  local item = pData.Functions.GetItemBySlot(slot)
  if item and item.name == 'bankcard' then
    pData.Functions.RemoveItem('bankcard', 1, slot)
    local hackerRep = pData.PlayerData.metadata["hackerrep"]
    if not hackerRep then hackerRep = 0 end
    pData.Functions.SetMetaData('hackerrep', hackerRep + math.random(3,5))
  end
end

function MFF:CanOpenVault(source,bank)  
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  if pData ~= nil and pData.PlayerData.job ~= nil and pData.PlayerData.job.name == 'police' then return {canOpen = true, hackLevel = -1}; end
  local result = {canOpen = false, hackLevel = 10, reason = 'No valid bank cards', slot = nil}
  for k,v in pairs(pData.PlayerData.items) do
    if v.name == 'bankcard' and v.info and v.info.bank == MFF.BankReferences[bank] then
      if v.info.expires and v.info.expires > os.time() then
        result.canOpen = true
        result.reason = nil
        result.slot = k
        break
      else
        result.reason = 'Bank card has expired'
      end
    end
  end

  if result.canOpen then
    local hackerRep = pData.PlayerData.metadata["hackerrep"]
    hackerRep = math.floor(hackerRep / 10)
    if hackerRep == 0 then
      result.hackLevel = 10
    else
      result.hackLevel = 11 - hackerRep
      if result.hackLevel <= 0 then
        result.hackLevel = 1
      end
    end
  end
  
  return result
end

function MFF:SyncDoor(target,location,isaVault)
  TriggerClientEvent('fleeca:SyncDoor', target, location, isaVault)
end

function MFF:TryLoot(loot)
  for k,v in pairs(self.UsedAction) do
    if k == loot.key then
      local ret = v or false
      self.UsedAction[k] = true
      return ret
    end
  end
end

function MFF:GetLockpickCount(source)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  local item = pData.Functions.GetItemByName('lockpick')
  if item and item.amount ~= 0 then return item.amount
  else return 0; end
end

function MFF:GetHackDeviceCount(source)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  local item = pData.Functions.GetItemByName('repairkit')
  if item and item.amount ~= 0 then return item.amount
  else return 0; end
end

function MFF:G4STimer()
  local self = MFF
  while true do
    Wait(self.G4SSpawnTimer * 60 * 1000)
    local players = BJCore.Functions.GetPlayers()
    if #players > 0 then
      self:SpawnBankTruck()
    end
  end
end

-- RegisterCommand("teststockade", function()
-- 	MFF:SpawnBankTruck()
-- end, true)

local CREATE_AUTOMOBILE = GetHashKey("CREATE_AUTOMOBILE")
function CreateAutomobile(hash, coords, angle)
    local v = Citizen.InvokeNative(CREATE_AUTOMOBILE, hash, coords.x, coords.y, coords.z)

    if DoesEntityExist(v) then
        SetEntityHeading(v, angle+0.0)
        return v
    end
    return nil
end

local testPos = vector4(-415.17, -35.53, 45.89, 244.46)
local timedOut = false
function MFF:SpawnBankTruck()
  if timedOut then TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "Previous spawn attemp Timed out. Attempted new spawn."); end
  timedOut = false
  Citizen.CreateThread(function()
    local pos = self.G4SSpawnLocs[math.random(1,#self.G4SSpawnLocs)]
    print("attempt spawn: "..tostring(pos))
    local bankTruck = CreateAutomobile(GetHashKey("stockade"), pos, pos.w)
    --local bankTruck = CreateVehicle(GetHashKey("stockade"), pos.x, pos.y, pos.z, pos.w, true, false)
    print("spawned truck: "..bankTruck)
    while not DoesEntityExist(bankTruck) do Citizen.Wait(0) print("exist veh"); end
    SetEntityHeading(bankTruck, pos.w)
    local vehId = NetworkGetNetworkIdFromEntity(bankTruck)
    SetEntityDistanceCullingRadius(bankTruck, 100000.0)
    TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "Created Bank Truck ID: "..vehId.."at "..tostring(pos).." waiting for suitable client.")
    local timeout = 300000 -- Timeout after 5 mins of searching for suitable client
    local notfound = true
    while notfound do
      local uhTest = bankTruck
      for k,v in pairs(BJCore.Functions.GetPlayers()) do
        local ped = GetPlayerPed(v)
        local dist = #(GetEntityCoords(ped) - pos.xyz)
        if dist < 65 then
          print("found client: "..tostring(v))
          -- local driver = CreatePedInsideVehicle(bankTruck, 5, -520477356, -1, true, true)
          -- local passenger = CreatePedInsideVehicle(bankTruck, 5, -520477356, 0, true, true)
          Wait(50)
          local driver = CreatePed(5, -520477356, pos.x+0.5, pos.y+0.3, pos.z, pos.w, true, false)
          Wait(100)
          local count = 3000
          while not DoesEntityExist(driver) and count > 0 do Citizen.Wait(0) count = count - 1; print("waiting driver"); end
          if not driver or driver == nil or driver == 0 or driver == -1 then print("timed out driver") DeleteEntity(bankTruck) DeleteEntity(uhTest) timedOut = true TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "Bank Truck ID: "..vehId.." has failed to spawn ped driver") break; end
          SetEntityDistanceCullingRadius(driver, 100000.0)

          local passenger = CreatePed(5, -520477356, pos.x+0.3, pos.y+0.5, pos.z, pos.w, true, false)
          Wait(100)
          count = 3000
          while not DoesEntityExist(passenger) and count > 0 do Citizen.Wait(0) count = count - 1; print("waiting passenger"); end
          if not passenger or passenger == nil or passenger == 0 or passenger == -1 then print("timed out passenger") DeleteEntity(bankTruck) DeleteEntity(uhTest) timedOut = true TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "Bank Truck ID: "..vehId.." has failed to spawn ped passenger") break; end
          SetEntityDistanceCullingRadius(passenger, 100000.0)
          Wait(100)
          SetPedIntoVehicle(passenger, bankTruck, 0)
          SetPedIntoVehicle(driver, bankTruck, -1)  
          print("sending to client: "..tostring(v))        
          TriggerClientEvent("fleeca:client:dospawnstuff", v, vehId, NetworkGetNetworkIdFromEntity(driver), NetworkGetNetworkIdFromEntity(passenger))
          local Player = BJCore.Functions.GetPlayer(v)
          TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "Initial client event handed to client **"..Player.PlayerData.name.."** at spawn: "..tostring(pos).." trunk ID: "..vehId)
          notfound = false
          break
        end
      end
      timeout = timeout - 50
      if timeout <= 0 then DeleteEntity(bankTruck) DeleteEntity(uhTest) timedOut = true print("timed out finding client") break; end -- If timeout then delete vehicle
      Citizen.Wait(50)
    end
    if timedOut then self:SpawnBankTruck(); end
  end)
end

function MFF:SyncG4SPlate(plate)
  local self = MFF
  if not self.G4SPlates[plate] then
    self.G4SPlates[plate] = {
    	["rob"] = true,
    	["loot"] = true,
    	["glovebox"] = true,
    }
  else
    self.G4SPlates[plate] = nil
  end  
  TriggerClientEvent('fleeca:SyncG4SPlate', -1, self.G4SPlates)
end

function MFF:ManagePlate(plate, action, b)
	print("plate: "..plate.." | action: "..action.." | b: "..tostring(b))
	local self = MFF
	if self.G4SPlates[plate] then
		self.G4SPlates[plate][action] = b
		TriggerClientEvent('fleeca:SyncG4SPlate', -1, self.G4SPlates)
    end
end

RegisterNetEvent("fleeca:RequstSpawnGuards")
AddEventHandler("fleeca:RequstSpawnGuards", function(veh)
  local src = source
  local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))   
  TriggerClientEvent("fleeca:createGuards", owner, veh)
end)

function MFF:G4SLootCash(src,plate)
  if self.G4SPlates[plate]["loot"] then
    self.G4SPlates[plate]["loot"] = false
    Citizen.CreateThread(function(...)
      local pData = BJCore.Functions.GetPlayer(src)
      while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(src); end
      
      TriggerClientEvent('fleeca:SyncG4SPlate', -1, self.G4SPlates)
      Wait(1500)
      local tick = 0
      local truckCash = 25
      local amount = math.random(truckCash-3,truckCash+3)
      local tickPercentage = math.floor(180 / amount)
      while tick < 180 do
        tick = tick + 1
        if tick % tickPercentage == 0 then
          pData.Functions.AddItem("cashband", 1, "G4S loot")
          TriggerClientEvent('inventory:client:ItemBox', pData.PlayerData.source, BJCore.Shared.Items["cashband"], "add")
        end
        Wait(1000)
      end
      TriggerClientEvent('BJCore:Notify',pData.PlayerData.source,'You looted '..amount..' bands of cash.','primary')

      TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..pData.PlayerData.name.."** has found "..amount.." bands of cash in the back of a Bank Truck: "..plate)
    end)
    return true
  else
    return false
  end
end

local randomItems = {
	"handcuffs",
	"radio",
	"painkillers",
	"joint",
	"coffee",
}

local randomAmmo = {
	"pistol_ammo",
	"rifle_ammo",
	"smg_ammo",
	"shotgun_ammo",
}

RegisterNetEvent("fleeca:server:LootGlovebox")
AddEventHandler("fleeca:server:LootGlovebox", function(plate)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		local item = false
		local chance = math.random(100)
		if chance <= 70 then
            item = Player.Functions.AddItem('blackusb', 1, nil, {
            	['bank'] = MFF.BankReferences[math.random(#MFF.BankReferences)],
            	['expires'] = os.time() + (24*60*60),
              ['encrypted'] = true
            })
		elseif chance <= 77 then
            item = Player.Functions.AddItem('weapon_combatpistol', 1, nil, {
            	serial = tostring("GRUP6" .. BJCore.Shared.RandomInt(1) .. BJCore.Shared.RandomStr(2) .. BJCore.Shared.RandomInt(3) .. BJCore.Shared.RandomStr(4))
            })
		elseif chance <= 85 then
            item = randomAmmo[math.random(1,#randomAmmo)]
		elseif chance <= 90 then
            item = randomItems[math.random(1,#randomItems)]
		else
			TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..Player.PlayerData.name.."** has found nothing in the glovebox of Bank Truck: "..plate)
            TriggerClientEvent('BJCore:Notify', src, 'You found nothing', 'primary')
		end
		if item then
			Player.Functions.AddItem(item, 1)
			TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[item], "add")
			TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..Player.PlayerData.name.."** has found "..BJCore.Shared.Items[item]["label"].." in the glovebox of Bank Truck: "..plate)
		end
	end
end)

RegisterNetEvent("fleeca:RestoreBank")
AddEventHandler("fleeca:RestoreBank", function(curbank)
  for k,v in pairs(MFF.BankData[curbank]) do
    if type(k) ~= "string" then
      MFF.BankData[curbank][k]["locked"] = true
    end 
  end
  TriggerClientEvent('fleeca:SyncDoorState', -1, MFF.BankData)
  TriggerClientEvent('fleeca:RestoreBank', -1)
end)

RegisterNetEvent("fleeca:server:MaxCulling")
AddEventHandler("fleeca:server:MaxCulling", function(tab)
  for k,v in pairs(tab) do
    local ent = NetworkGetEntityFromNetworkId(v)
    if DoesEntityExist(ent) then
      print("setting max cull: "..ent)
      SetEntityDistanceCullingRadius(ent, 100000.0)
    end
  end
end)

Citizen.CreateThread(function(...) MFF:Awake(...); end)
--Citizen.CreateThread(function(...) MFF:G4STimer(...); end)

AddEventHandler('fleeca:NotifyPolice', function(data) MFF:NotifyPolice(data); end)
AddEventHandler('fleeca:RewardPlayer', function(data,id,curbank) MFF:RewardPlayer(data,id,curbank); end)
AddEventHandler('fleeca:SyncBankData', function(...) MFF:SyncBankData(...); end)
AddEventHandler('fleeca:SyncDoorState', function(...) MFF:SyncDoorState(...); end)
AddEventHandler('fleeca:RemoveCard', function(slot) MFF:RemoveBankCard(source, slot); end)
AddEventHandler('fleeca:SyncG4SPlate', function(plate) MFF:SyncG4SPlate(plate); end)
AddEventHandler('fleeca:ManagePlate', function(plate, action, b) MFF:ManagePlate(plate, action, b); end)
AddEventHandler('fleeca:SyncDoor', function(target,location,isaVault) MFF:SyncDoor(target,location,isaVault); end)
BJCore.Functions.RegisterServerCallback('fleeca:GetBankData', function(source,cb) cb(MFF:GetBankData()); end)
BJCore.Functions.RegisterServerCallback('fleeca:GetDrillCount', function(source,cb) cb(MFF:GetDrillCount(source)); end)
BJCore.Functions.RegisterServerCallback('fleeca:GetLockpickCount', function(source,cb) cb(MFF:GetLockpickCount(source) or 0); end)
BJCore.Functions.RegisterServerCallback('fleeca:GetHackDeviceCount', function(source,cb) cb(MFF:GetHackDeviceCount(source) or 0); end)
BJCore.Functions.RegisterServerCallback('fleeca:CanOpenVault', function(source,cb,bank) cb(MFF:CanOpenVault(source,bank) or 0); end)
BJCore.Functions.RegisterServerCallback('fleeca:TryLoot', function(source,cb,loot) cb(MFF:TryLoot(loot)); end)
BJCore.Functions.RegisterServerCallback('fleeca:G4SLootCash', function(source,cb,plate) cb(MFF:G4SLootCash(source,plate)); end)

RegisterCommand('givetestcard', function(source, args, rawCommand)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end

  pData.Functions.AddItem('bankcard', 1, nil, {
    ['bank'] = 'FLC001',
    ['expires'] = os.time() + (24*60*60),
    ['encrypted'] = true,
  })
end, true)

RegisterCommand('givetestblack', function(source, args, rawCommand)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end

  pData.Functions.AddItem('blackusb', 1, nil, {
    ['bank'] = 'FLC001',
    ['expires'] = os.time() + (24*60*60),
    ['encrypted'] = false,
  })
end, true)
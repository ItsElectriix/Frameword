local MFV = MF_Vangelico
RegisterNetEvent('MF_Vangelico:MarkLoot')
RegisterNetEvent('MF_Vangelico:Loot')
RegisterNetEvent('MF_Vangelico:NotifyCops')
RegisterNetEvent('MF_Vangelico:AddHackRep')

function MFV:Update(...)
  while true do
    Wait(self.RefreshTimer * 60 * 1000 )
    self:RefreshLootTable()
  end
end

function MFV:Loot(source,key,val)
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); end
  for k,v in pairs(self.LootRemaining[key]) do 
    if v > 0 then 
      pData.Functions.AddItem(k,v)
      TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[k], "add")
      TriggerEvent("bj-log:server:CreateLog", "crim", "Vangelico Store", "green", "**"..pData.PlayerData.name .. "** has looted item(s): "..BJCore.Shared.Items[k]['label'].." amount: "..v.." from Vangelico Store Heist")
  		self.LootRemaining[key][k] = 0
	end
    Wait(500)
  end
  --self:PoliceNotify()
end

function MFV:PoliceNotify()
  if self.DoingNotify then return; end
  Citizen.CreateThread(function(...)
    self.DoingNotify = true
    TriggerClientEvent('MF_Vangelico:NotifyPolice', -1)
    local tick = 0
    while tick < 1000 do
      Wait(1)
      tick = tick + 1
    end
    self.DoingNotify = false
  end)
end

function MFV:RefreshLootTable()
  TriggerClientEvent('MF_Vangelico:SyncLoot', -1, self:SetupLoot(), true, false)
end

function MFV:GetLootStatus()
  if not self.LootRemaining then return self:SetupLoot()
  else return self.LootRemaining
  end
end

function MFV:SetupLoot()  
  self.SafeStatus = true
  self.PowerStatus = true
  self.LootRemaining = {}
  for k,v in pairs(self.MarkerPositions) do 
    self.LootRemaining[k] = {}
    local lootRemaining = self.LootRemaining[k]
    local lootTable = self.LootTable[v.Loot]
    local lootAmount = lootTable[v.Amount]
    for k,v in pairs(lootAmount) do
      lootRemaining[k] = math.random(0,v)
    end
  end
  return self.LootRemaining
end

function MFV:AddHackRep(source)  
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); end
  pData.Functions.SetMetaData("hackerrep", pData.PlayerData.metadata["hackerrep"] + 1)
end

function MFV:HandlePower()
  Citizen.Wait(90*1000)
  MFV.PowerStatus = true
end

function MFV:Awake(...)
  while not BJCore do Citizen.Wait(0); end
  self:Update()
end

RegisterNetEvent('fibheist:ChanceRemove')
AddEventHandler('fibheist:ChanceRemove', function(item)
  local _source = source  
    local pData = BJCore.Functions.GetPlayer(_source)
    while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(_source); end
    local chance = math.random(100)
    if chance <= 10 then 
      pData.Functions.RemoveItem(item, 1) 
      TriggerClientEvent('BJCore:Notify',_source,BJCore.Shared.Items[item].label.." has broken",'primary')
      TriggerClientEvent('inventory:client:ItemBox', _source, BJCore.Shared.Items[item], "remove")
      TriggerEvent("bj-log:server:CreateLog", "default", "Item Broke", "green", "**"..pData.PlayerData.name .. "**'s "..BJCore.Shared.Items[item]['label'].. " has broken (removed from inv on a random chance when used)")
    end
end)

BJCore.Functions.RegisterServerCallback('fibheist:CheckInvCount', function(source, cb, item)
  local pData = BJCore.Functions.GetPlayer(source)
  
  local item = pData.Functions.GetItemByName(item)
  
  if item ~= nil and item.amount ~= nil then
    cb(item.amount)
  else
    cb(0)
  end
end)


RegisterNetEvent('MF_Vangelico:ResetSafe')
AddEventHandler('MF_Vangelico:ResetSafe', function() MFV.SafeStatus = true; end)
BJCore.Functions.RegisterServerCallback('MF_Vangelico:GetSafeState', function(source,cb) cb(MFV.SafeStatus); MFV.SafeStatus = false; end)
BJCore.Functions.RegisterServerCallback('MF_Vangelico:GetPowerState', function(source,cb) cb(MFV.PowerStatus); MFV.PowerStatus = false if not MFV.PowerStatus then MFV:HandlePower(); end; end)
BJCore.Functions.RegisterServerCallback('MF_Vangelico:GetLootStatus', function(source,cb) cb(MFV:GetLootStatus()); end)
AddEventHandler('MF_Vangelico:Loot', function(key,val) MFV:Loot(source,key,val); end)
AddEventHandler('MF_Vangelico:MarkLoot', function(key,val) TriggerClientEvent('MF_Vangelico:SyncLoot', -1, MFV.LootRemaining, false, key); end)
AddEventHandler('MF_Vangelico:NotifyCops', function(...) MFV:PoliceNotify(...); end)
AddEventHandler('MF_Vangelico:AddHackRep', function() MFV:AddHackRep(source); end)

Citizen.CreateThread(function(...) MFV:Awake(...); end)
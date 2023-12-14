playersafes.Characters = {}

function playersafes:Start(...)
    exports['ghmattimysql']:execute('SELECT * FROM safes WHERE deleted = @del',{['@del'] = 0},function(data)
        if data and data[1] then 
            self.Safes = data
            self.ClientSafes = {}
            for k,v in pairs(self.Safes) do
                self.Safes[k].location = json.decode(self.Safes[k].location)
                table.insert(self.ClientSafes, {
                    citizenid = self.Safes[k].citizenid,
                    location = self.Safes[k].location,
                    pin = self.Safes[k].pin,
                    safeid = self.Safes[k].safeid
                })
            end
        else 
            self.Safes = {}
            self.ClientSafes = {}
        end
        self.Bins = {}
        self.Started = true
    end)
end

table.match = function(table,safeid)
    for k,v in pairs(table) do
        if safeid == v.safeid then return k; end
    end
    return false
end

function playersafes:UseSafeItem(source)
    if GetPlayerRoutingBucket(source) ~= 0 then TriggerClientEvent('BJCore:Notify', source, "You cannot place a safe here", "error") return; end
    local pData = BJCore.Functions.GetPlayer(source)
    while not pData do pData = BJCore.Functions.GetPlayer(source); Citizen.Wait(0); end
    if not pData.Functions.GetItemByName('playersafe') then return; end
    if pData.Functions.GetItemByName('playersafe').amount <= 0 then return; end
    pData.Functions.RemoveItem('playersafe', 1)  

    local citizenid = pData.PlayerData.citizenid
    local safeid = CreateStorageItemId(citizenid)

    local newSafe = {
        citizenid = citizenid,
        location = {},
        items = {},
        safeid = safeid,
        pin = 123456,
    }
    TriggerClientEvent('playersafes:SpawnSafe', source, newSafe)
end

function playersafes:SafeSpawned(v)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    self.Safes = self.Safes or {}
    local safeCount = 0
    for k,v in pairs(self.Safes) do if k > safeCount then safeCount = k; end; end
    self.Safes[safeCount+1] = v
    local tooBusy = true
    exports['ghmattimysql']:execute('INSERT INTO safes (citizenid, location, safeid, pin) VALUES (@citizenid, @location, @safeid, @pin)',{['@citizenid'] = v.citizenid, ['@location'] = json.encode(v.location),['@safeid'] = v.safeid, ['@pin'] = v.pin},function(...) tooBusy = false; end)
    while tooBusy do Citizen.Wait(0); end
    local clientSafe = {
        citizenid = v.citizenid,
        location = v.location,
        safeid = v.safeid,
        pin = v.pin
    }
    table.insert(self.ClientSafes, clientSafe)
    TriggerClientEvent('playersafes:SafeAdded',-1,clientSafe,safeCount+1)
    TriggerEvent("bj-log:server:CreateLog", "default", "Player Safes", "green", "**"..Player.PlayerData.name .. "** has **placed** a safe down at coords: "..BJCore.Common.Dump(v.location).." | safe id: "..v.safeid)
end

RegisterNetEvent('playersafes:SafeSpawned')
AddEventHandler('playersafes:SafeSpawned', function(safe) playersafes:SafeSpawned(safe); end)
RegisterNetEvent("playersafes:PickupSafe")
AddEventHandler('playersafes:PickupSafe', function(...) playersafes:PickupSafe(source,...); end)

RegisterNetEvent("playersafes:UpdatePin")
AddEventHandler('playersafes:UpdatePin', function(id, pin)
    self = playersafes
    local foundKey
    for k, v in pairs(self.Safes) do
        if v.safeid == id then foundKey = k; end
    end
    if foundKey and self.Safes[foundKey] then
        local isBusy = true
        exports['ghmattimysql']:execute('UPDATE safes SET pin = @pin WHERE safeid=@safeid',{['@safeid'] = id, ['@pin'] = pin},function(...) isBusy = false; end)
        self.Safes[foundKey].pin = pin
        self.ClientSafes[foundKey].pin = pin
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'New Safe Pin: '..tostring(pin), length = 5000 })
        while isBusy do Citizen.Wait(0); end
    end
    TriggerClientEvent('playersafes:SetSafes', -1, self.ClientSafes)
end)

function playersafes:PickupSafe(source,safe)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.AddItem('playersafe', 1) then
        for k,v in pairs(self.Safes) do
            if v.safeid == safe.safeid then 
                local isBusy = true
                exports['ghmattimysql']:execute('UPDATE safes SET deleted = @del WHERE safeid=@safeid',{['@del'] = 1, ['@safeid'] = v.safeid},function(...) isBusy = false; end)
                TriggerEvent("bj-log:server:CreateLog", "default", "Player Safes", "green", "**"..Player.PlayerData.name .. "** has **picked up** a safe from coords: "..BJCore.Common.Dump(v.location).." | safe id: "..v.safeid)
                self.Safes[k] = nil
                self.ClientSafes[k] = nil
                while isBusy do Citizen.Wait(0); end
            end
        end 
        TriggerClientEvent('playersafes:DelSafe',-1,safe)
        TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items['playersafe'], "add")
    else
        TriggerClientEvent('BJCore:Notify', source, "You don't have enough inventory space to pick up this safe. Pickup cancelled", "error", 10000)
    end
end

function playersafes:GetStartup(s,...)
    TriggerClientEvent('playersafes:GotStartup',s,self.ClientSafes,self.Bins)
end

RegisterNetEvent('playersafes:UseSafeItem')
AddEventHandler('playersafes:UseSafeItem', function(...) local _source = source; playersafes:UseSafeItem(_source); end)
RegisterNetEvent('playersafes:GetStartup')
AddEventHandler('playersafes:GetStartup', function(...) local _source = source; while not playersafes.Started do Wait(0); end playersafes:GetStartup(_source,...); end)
Citizen.CreateThread(function(...) playersafes:Start(...); end)

RegisterNetEvent("storage:server:CreateBin")
AddEventHandler("storage:server:CreateBin", function(data)
    self = playersafes
    if self.Bins[data.binid] == nil then
        self.Bins[data.binid] = data
        TriggerClientEvent('bins:SyncBins', -1, self.Bins)
    end
end)

BJCore.Functions.CreateUseableItem("playersafe", function(source, item) 
    playersafes:UseSafeItem(source); 
end)

function CreateStorageItemId()
    local UniqueFound = false
    local Id = nil
    while not UniqueFound do
        Id = BJCore.Shared.RandomInt(4)..os.time()
        BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM `stashitems` WHERE `stash` LIKE '%"..Id.."%'", function(result)
            if result[1].count == 0 then
                UniqueFound = true
            end
        end)
    end
    return Id
end
exports("CreateStorageItemId", CreateStorageItemId)

local StorageItems = {
    ["cardboardbox"] = {
        maxweight = 10000,
        slots = 10
    },
    ["plasticbag"] = {
        maxweight = 5000,
        slots = 3
    },
}

for k,v in pairs(StorageItems) do
    BJCore.Functions.CreateUseableItem(k, function(source, item)
        if item.info == nil then print("[STORAGE] - Player ID: "..source.." has tried to use/open a storage item that has no stash ID. Item incorrectly created.") return; end
        if item.info.stashId == nil then print("[STORAGE] - Player ID: "..source.." has tried to use/open a storage item that has no stash ID. Item incorrectly created.") return; end
        TriggerClientEvent("storage:client:OpenStorageItem", source, item, StorageItems[item.name])
    end)
end

local CashStorageMax = {
    ["briefcase"] = 10000,
    ["suitcase"] = 100000, 
}

for k,v in pairs(CashStorageMax) do
    BJCore.Functions.CreateUseableItem(k, function(source, item)
        TriggerClientEvent("storage:client:OpenCashStorageItem", source, item, v)
    end)
end

-- RegisterCommand("cashitem", function(s, a, r)
--     local Player = BJCore.Functions.GetPlayer(s)
--     local info = {
--         cash = 0
--     }
--     Player.Functions.AddItem("briefcase", 1, nil, info)
--     Player.Functions.AddItem("suitcase", 1, nil, info)
-- end)

-- RegisterCommand("storageitem", function(s, a, r)
--     local Player = BJCore.Functions.GetPlayer(s)
--     local info = {
--         cash = 0
--     }
--     Player.Functions.AddItem("cardboardbox", 1, nil, {stashId = CreateStorageItemId()})
--     Wait(25)
--     Player.Functions.AddItem("plasticbag", 1, nil, {stashId = CreateStorageItemId()})
-- end)

RegisterNetEvent("storage:server:manageCashStorage")
AddEventHandler("storage:server:manageCashStorage", function(action, amount, itemData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemBySlot(itemData.slot)
    if item == nil then return; end
    if item.name ~= itemData.name then return; end
    if item.info == nil then return; end
    if item.info.cash == nil then return; end
    if action == "add" then
        if item.info.cash + amount <= CashStorageMax[item.name] then
            if Player.Functions.RemoveMoney("cash", amount) then
                local newInfo = Player.PlayerData.items[itemData.slot].info
                newInfo.cash = newInfo.cash + amount
                Player.Functions.UpdateItemInfo(item.slot, newInfo)
                TriggerClientEvent('BJCore:Notify', src, BJCore.Config.Currency.Symbol..amount.." stored", "success")
                TriggerClientEvent("storage:client:OpenCashStorageItem", src, Player.Functions.GetItemBySlot(itemData.slot), CashStorageMax[itemData.name])
                TriggerEvent("bj-log:server:CreateLog", "playermoney", "Cash stored", "green", GetPlayerName(src).." **("..Player.PlayerData.citizenid..")** has stored "..BJCore.Config.Currency.Symbol..amount.." in a money sorage item ("..BJCore.Shared.Items[item.name].label..") | New Total: "..BJCore.Config.Currency.Symbol..newInfo.cash)
            else
                TriggerClientEvent('BJCore:Notify', src, "Not enough cash to do this", "error")
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "You can't store this amount of cash. Try less", "error")
        end
    elseif action == "remove" then
        if item.info.cash - amount >= 0 then
            if Player.Functions.AddMoney("cash", amount) then
                local newInfo = Player.PlayerData.items[item.slot].info
                newInfo.cash = newInfo.cash - amount
                Player.Functions.UpdateItemInfo(item.slot, newInfo)
                TriggerClientEvent('BJCore:Notify', src, BJCore.Config.Currency.Symbol..amount.." removed", "success")
                TriggerClientEvent("storage:client:OpenCashStorageItem", src, Player.Functions.GetItemBySlot(itemData.slot), CashStorageMax[itemData.name])
                TriggerEvent("bj-log:server:CreateLog", "playermoney", "Cash removed", "green", GetPlayerName(src).." **("..Player.PlayerData.citizenid..")** has removed "..BJCore.Config.Currency.Symbol..amount.." in a money sorage item ("..BJCore.Shared.Items[item.name].label..") | New Total: "..BJCore.Config.Currency.Symbol..newInfo.cash)
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "There's not enough stored cash to do this", "error")
        end
    end
end)
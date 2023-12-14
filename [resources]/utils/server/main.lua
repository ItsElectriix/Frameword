RegisterServerEvent('tbh:afkKick')
AddEventHandler('tbh:afkKick', function()
	if serverType ~= 'DEV' then
		DropPlayer(source, "You were kicked for being AFK.")
	end
end)

RegisterServerEvent("TBH:SyncAll")
AddEventHandler("TBH:SyncAll", function(event, args)
	if args ~= nil then
		TriggerClientEvent(event, -1, table.unpack(args))
	else
		TriggerClientEvent(event, -1)
	end
end)

RegisterServerEvent('shops:server:UpdateShopItems')
AddEventHandler('shops:server:UpdateShopItems', function(shop, itemData, amount)
    Config.Locations[shop]["products"][itemData.slot].amount =  Config.Locations[shop]["products"][itemData.slot].amount - amount
    if Config.Locations[shop]["products"][itemData.slot].amount <= 0 then 
        Config.Locations[shop]["products"][itemData.slot].amount = 0
    end
    TriggerClientEvent('shops:client:SetShopItems', -1, shop, Config.Locations[shop]["products"])
end)

RegisterServerEvent('shops:server:RestockShopItems')
AddEventHandler('shops:server:RestockShopItems', function(shop)
    if Config.Locations[shop]["products"] ~= nil then 
        local randAmount = math.random(10, 50)
        for k, v in pairs(Config.Locations[shop]["products"]) do 
            Config.Locations[shop]["products"][k].amount = Config.Locations[shop]["products"][k].amount + randAmount
        end
        TriggerClientEvent('shops:client:RestockShopItems', -1, shop, randAmount)
    end
end)

local Notes = {}

RegisterServerEvent("notes:server:SaveNoteData")
AddEventHandler('notes:server:SaveNoteData', function(text, pos, noteId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    noteId = noteId ~= nil and noteId or CreateNoteId()
    if Notes[noteId] == nil then
        Notes[noteId] = text
        TriggerClientEvent("notes:client:AddNoteDrop", -1, noteId, pos)
        TriggerEvent("bj-log:server:CreateLog", "default", "Notes", "green", "**"..Player.PlayerData.name .. "** has created a note with text: *"..text.."* \nat coords "..pos)
    else
        Notes[noteId] = text
        TriggerClientEvent("notes:client:SetActiveStatus", -1, noteId, false)
    end
end)

RegisterServerEvent("notes:server:SetActiveStatus")
AddEventHandler('notes:server:SetActiveStatus', function(noteId, status)
    print(noteId)
    TriggerClientEvent("notes:client:SetActiveStatus", -1, noteId, status)
end)

RegisterServerEvent("notes:server:OpenNoteData")
AddEventHandler('notes:server:OpenNoteData', function(noteId)
    if Notes[noteId] ~= nil then
        TriggerClientEvent("notes:client:OpenNotepad", source, noteId, Notes[noteId])
        TriggerClientEvent("notes:client:SetActiveStatus", -1, noteId, true)
    end
end)

RegisterServerEvent("notes:server:RemoveNoteData")
AddEventHandler('notes:server:RemoveNoteData', function(noteId)
    Notes[noteId] = nil
    TriggerClientEvent("notes:client:RemoveNote", -1, noteId)
end)

function CreateNoteId()
    local noteId = math.random(1, 9999)
    while (Notes[noteId] ~= nil) do 
        noteId = math.random(1, 9999)
    end
    return noteId
end

RegisterNetEvent("notes:server:SaveToPaper", function(data)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem("papernote", 1, nil, {
            note  = data.text
        })
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items['papernote'], "add")
    end
end)

BJCore.Functions.CreateUseableItem("papernote", function(source, item)
    if item.info ~= nil and item.info.note == nil then TriggerClientEvent('BJCore:Notify', source, "This note is empty", "error") return; end
    TriggerClientEvent("notes:client:OpenSavedNote", source, item.info.note)
end)

BJCore.Commands.Add("notes", "Open Notepad", {}, false, function(source, args)
    TriggerClientEvent("notes:client:OpenNotepad", source)
end)

-- Casino
local ItemList = {
    ["casinochips"] = 1,
}

RegisterServerEvent("casino:server:sell")
AddEventHandler("casino:server:sell", function()
    local src = source
    local price = 0
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    price = price + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                end
            end
        end
    end
    if price > 0 then
        Player.Functions.AddMoney("cash", price, "sold-casino-chips")
        TriggerClientEvent('BJCore:Notify', src, "You sold your chips for "..BJCore.Config.Currency.Symbol..price)
        TriggerEvent("bj-log:server:CreateLog", "casino", "Chips", "blue", "**"..GetPlayerName(src) .. "** got "..BJCore.Config.Currency.Symbol..price.." for selling the Casino Chips")
    elseif price == 0 then
        TriggerClientEvent('BJCore:Notify', src, "You have no chips")
    end
end)

function SetExports()
    exports["blackjack"]:SetGetChipsCallback(function(source)
        local Player = BJCore.Functions.GetPlayer(source)
        local Chips = Player.Functions.GetItemByName("casinochips")

        if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
            Chips = Chips
        end

        return TriggerClientEvent('BJCore:Notify', src, "You have no chips")
    end)

    exports["blackjack"]:SetTakeChipsCallback(function(source, amount)
        local Player = BJCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.RemoveItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items['casinochips'], "remove")
            TriggerEvent("bj-log:server:CreateLog", "casino", "Chips", "yellow", "**"..GetPlayerName(source) .. "** bet "..BJCore.Config.Currency.Symbol..amount.." in chips on a blackjack table")
        end
    end)

    exports["blackjack"]:SetGiveChipsCallback(function(source, amount)
        local Player = BJCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.AddItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items['casinochips'], "add")
            TriggerClientEvent('BJCore:Notify', source, "You have received "..amount .." chips", "primary")
            TriggerEvent("bj-log:server:CreateLog", "casino", "Chips", "red", "**"..GetPlayerName(source) .. "** received "..BJCore.Config.Currency.Symbol..amount.." in chips from a blackjack table")
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if ("blackjack" == resourceName) then
        Citizen.Wait(1000)
        SetExports()
    end
end)

--SetExports()

-- Cash safes
local safeDataReady = false
local safeSqlCache = {}
Citizen.CreateThread(function()
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes`", function(safes)
        if safes[1] ~= nil then
            safeSqlCache = safes
            for _, d in pairs(safes) do
                for safe, s in pairs(Config.Safes) do
                    if d.safe == safe then
                        Config.Safes[safe].money = d.money
                        d.transactions = json.decode(d.transactions)
                        if d.transactions ~= nil and next(d.transactions) ~= nil then
                            Config.Safes[safe].transactions = d.transactions
                        end
                        syncToClient(Config.Safes[safe], safe)
                    end
                end
            end
            safeDataReady = true
        end
    end)
end)

function syncToClient(data, safe)
    local clientTab = {}
    clientTab.money = data.money
    clientTab.coords = data.coords
    TriggerClientEvent('moneysafe:client:UpdateSafe', -1, clientTab, safe)
end

RegisterNetEvent("moneysafe:server:GetMoneySafeData")
AddEventHandler("moneysafe:server:GetMoneySafeData", function()
    local src = source
    while not safeDataReady do Citizen.Wait(250); end
    local retTab = {}
    for k,v in pairs(Config.Safes) do 
        retTab[k] = {}
        retTab[k].money = v.money
    end
    TriggerClientEvent("moneysafe:client:GotMoneySafeData", src, retTab)
end)

RegisterNetEvent('moneysafe:server:LoadSafe')
AddEventHandler('moneysafe:server:LoadSafe', function(safeName, safeCoords)
    if source ~= nil and type(source) == 'number' and source > 0 then
        return
    end

    if Config.Safes[safeName] ~= nil then
        Config.Safes[safeName].coords = safeCoords
        syncToClient(Config.Safes[safeName], safeName)
    else
        local safe = false
        for _,d in pairs(safeSqlCache) do
            if d.safe == safeName then
                safe = d
                safe.transactions = json.decode(d.transactions)
                break
            end
        end
        if safe == false then
            safe = {
                money = 0,
                coords = safeCoords,
                transactions = {},
            }
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes` WHERE `safe` = '"..safeName.."'", function(result)
                if result == nil or #result < 1 then
                    BJCore.Functions.ExecuteSql(false, "INSERT INTO `moneysafes` (`safe`, `money`, `transactions`) VALUES ('"..safeName.."', '"..safe.money.."', '"..json.encode(safe.transactions).."')")
                end
            end)
        end
        Config.Safes[safeName] = safe
        syncToClient(safe, safeName)
    end
end)

BJCore.Commands.Add("deposit", "Deposit money in safe", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local amount = tonumber(args[1]) or 0

    TriggerClientEvent('moneysafe:client:DepositMoney', source, amount)
end)

BJCore.Commands.Add("withdraw", "Withdraw money from safe", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local amount = tonumber(args[1]) or 0

    TriggerClientEvent('moneysafe:client:WithdrawMoney', source, amount)
end)

function AddTransaction(safe, type, amount, Player, Automated, Desc)
    local cid = nil
    local name = nil
    local _source = nil
    if not Automated then
        local src = source
        local Ply = BJCore.Functions.GetPlayer(src)
        if Ply ~= nil then Player = Ply; end
        cid = Player.PlayerData.citizenid
        name = Player.PlayerData.name
        _source = Player.PlayerData.source
    else
        cid = "N/A"
        name = "Fine\'s"
        _source = "Automatic"
    end
    if Config.Safes[safe].transactions == nil then
        Config.Safes[safe].transactions = {}
    end
    table.insert(Config.Safes[safe].transactions, {
        type = type,
        amount = amount,
        safe = safe,
        citizenid = cid,
    })
    TriggerEvent("bj-log:server:sendLog", cid, type, {safe = safe, type = type, amount = amount, citizenid = cid})
    local label = "Withdraw out"
    local color = "red"
    if type == "deposit" then
        label = "Deposited in"
        color = "green"
    end
    if Desc and Desc ~= nil then
        TriggerEvent("bj-log:server:CreateLog", "moneysafes", type, color, "**" .. name .. "** (citizenid: *" .. cid .. "* | id: *(" .. _source .. ")* has **"..BJCore.Config.Currency.Symbol .. amount .. "** " .. label .. " the **" .. safe .. "** safe. Description: "..Desc)
    else
        TriggerEvent("bj-log:server:CreateLog", "moneysafes", type, color, "**" .. name .. "** (citizenid: *" .. cid .. "* | id: *(" .. _source .. ")* has **"..BJCore.Config.Currency.Symbol .. amount .. "** " .. label .. " the **" .. safe .. "** safe.")
    end
end

RegisterServerEvent('moneysafe:server:DepositMoney')
AddEventHandler('moneysafe:server:DepositMoney', function(safe, amount, sender)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.cash >= amount then
        Player.Functions.RemoveMoney('cash', amount)
    elseif Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount)
    else
        TriggerClientEvent('BJCore:Notify', src, "You don\'t have enough cash", "error")
        return
    end
    if sender == nil then
        AddTransaction(safe, "deposit", amount, Player, false)
    else
        AddTransaction(safe, "deposit", amount, {}, true)
    end
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes` WHERE `safe` = '"..safe.."'", function(result)
        if result[1] ~= nil then
            Config.Safes[safe].money = (Config.Safes[safe].money + amount)
            BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        else
            Config.Safes[safe].money = amount
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `moneysafes` (`safe`, `money`, `transactions`) VALUES ('"..safe.."', '"..Config.Safes[safe].money.."', '"..json.encode(Config.Safes[safe].transactions).."')")
        end
        syncToClient(Config.Safes[safe], safe)
        TriggerClientEvent('BJCore:Notify', src, "You have deposited "..BJCore.Config.Currency.Symbol..amount.." into the safe", "success")
    end)
end)

RegisterNetEvent('moneysafe:server:DepositMoneyDirect')
AddEventHandler('moneysafe:server:DepositMoneyDirect', function(safe, amount, sender)
    AddTransaction(safe, "deposit", amount, {}, true)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes` WHERE `safe` = '"..safe.."'", function(result)
        if result[1] ~= nil then
            Config.Safes[safe].money = (Config.Safes[safe].money + amount)
            BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        else
            Config.Safes[safe].money = amount
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `moneysafes` (`safe`, `money`, `transactions`) VALUES ('"..safe.."', '"..Config.Safes[safe].money.."', '"..json.encode(Config.Safes[safe].transactions).."')")
        end
        syncToClient(Config.Safes[safe], safe)
        --TriggerClientEvent('BJCore:Notify', src, "You have deposited "..BJCore.Config.Currency.Symbol..amount.." into the safe", "success")
    end)
end)

AddEventHandler('moneysafe:server:DepositMoneyFromInvoice', function(safe, amount, payee, sender)
    table.insert(Config.Safes[safe].transactions, {
        type = "deposit-from-invoice",
        amount = amount,
        safe = safe,
        citizenid = sender,
    })
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes` WHERE `safe` = '"..safe.."'", function(result)
        if result[1] ~= nil then
            Config.Safes[safe].money = (Config.Safes[safe].money + amount)
            BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        else
            Config.Safes[safe].money = amount
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `moneysafes` (`safe`, `money`, `transactions`) VALUES ('"..safe.."', '"..Config.Safes[safe].money.."', '"..json.encode(Config.Safes[safe].transactions).."')")
        end
        syncToClient(Config.Safes[safe], safe)
        --TriggerClientEvent('BJCore:Notify', src, "You have deposited "..BJCore.Config.Currency.Symbol..amount.." into the safe", "success")
    end)
end)

RegisterServerEvent('moneysafe:server:WithdrawMoney')
AddEventHandler('moneysafe:server:WithdrawMoney', function(safe, amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    if (Config.Safes[safe].money - amount) >= 0 then 
        AddTransaction(safe, "withdraw", amount, Player, false)
        Config.Safes[safe].money = (Config.Safes[safe].money - amount)
        BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        syncToClient(Config.Safes[safe], safe)
        TriggerClientEvent('BJCore:Notify', src, "You took "..BJCore.Config.Currency.Symbol..amount.." from the safe", "success")
        Player.Functions.AddMoney('cash', amount)
    else
        TriggerClientEvent('BJCore:Notify', src, "There is not enough money in the safe", "error")
    end
end)

AddEventHandler('moneysafe:server:WithdrawMoneyForPurchase', function(safe, amount, cb)
    local src = source

    if not Config.Safes[safe] then
        cb(false)
    elseif (Config.Safes[safe].money - amount) >= 0 then 
        AddTransaction(safe, "withdraw", amount, Player, true)
        Config.Safes[safe].money = (Config.Safes[safe].money - amount)
        BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        syncToClient(Config.Safes[safe], safe)
        TriggerClientEvent('BJCore:Notify', src, "You paid "..BJCore.Config.Currency.Symbol..amount.." from the job safe", "success")
        cb(true)
    else
        TriggerClientEvent('BJCore:Notify', src, "There is not enough money in the safe", "error")
        cb(false)
    end
end)

BJCore.Functions.RegisterServerCallback("moneysafe:server:CanPay", function(source, cb, amount, desc)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local safe = Player.PlayerData.job.name
    if Player ~= nil then
        if Config.Safes[safe] ~= nil then
            print(Config.Safes[safe].money)
            if (Config.Safes[safe].money - amount) >= 0 then
                AddTransaction(safe, "withdraw", amount, Player, false, desc)
                Config.Safes[safe].money = (Config.Safes[safe].money - amount)
                BJCore.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
                syncToClient(Config.Safes[safe], safe)
                TriggerClientEvent('BJCore:Notify', src, "Purchase successful", "success")                
                cb(true)
            else
                cb(false)
            end
        else
            print("[MONEYSAFES] - Trying to pay with moneysafe that doesn't exist for job: "..Player.PlayerData.job.name)
            cb(false)
        end
    end
end)

exports('DoesMoneysafeExist', function(safe)
    if Config.Safes[safe] then
        return true
    end
    return false
end)

exports('GetMoneysafe', function(safe)
    if Config.Safes[safe] then
        return Config.Safes[safe]
    end
    return false
end)

RegisterNetEvent("utils:server:savePlate")
AddEventHandler("utils:server:savePlate", function(old, new)
    old = string.gsub(old, "%s+", "")
    new = string.upper(new)
    local src = source
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..old.."'", function(owned)
        if owned[1] ~= nil then
            BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..new.."'", function(result)
                if result[1] ~= nil then
                    TriggerClientEvent('BJCore:Notify', src, "Plate: "..new.." is being used on another owned vehicle", "error", 6000)
                else
                    BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET plate = '"..new.."' WHERE `plate` = '"..old.."'")
                    TriggerClientEvent("utils:confirmPlate", src, new)
                    TriggerClientEvent('BJCore:Notify', src, "Vehicle plate: "..old.." has been changed to "..new, "primary", 6000)
                end
            end)
        else
            TriggerClientEvent('BJCore:Notify', src, "This isn't an owned vehicle", "error", 3000)
        end
    end)
end)
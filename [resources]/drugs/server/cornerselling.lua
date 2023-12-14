BJCore.Functions.RegisterServerCallback('drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    local AvailableDrugs = {}
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = BJCore.Shared.Items[item.name]["label"]
            })
        end
    end

    if next(AvailableDrugs) ~= nil then
        cb(AvailableDrugs, Player.PlayerData.metadata["dealerrep"] or 0)
    else
        cb(nil)
    end
end)

RegisterServerEvent('drugs:server:sellCornerDrugs')
AddEventHandler('drugs:server:sellCornerDrugs', function(item, amount, price)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local AvailableDrugs = false

    if Player.Functions.RemoveItem(item, amount) then
        Player.Functions.AddItem("cashroll", price)

        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item], "remove")
        if math.random(100) <= 20 then
            Player.Functions.SetMetaData("dealerrep", Player.PlayerData.metadata["dealerrep"] + 1)
        end
        TriggerEvent("bj-log:server:CreateLog", "crim", "Drug Corner Selling", "green", "**"..Player.PlayerData.name .. "** has sold drug "..BJCore.Shared.Items[item]['label'].." amount:"..amount.." for x"..price.." "..BJCore.Shared.Items['cashroll']['label'])
    end
    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            if not AvailableDrugs then AvailableDrugs = {}; end
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = BJCore.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)

RegisterServerEvent('drugs:server:robCornerDrugs')
AddEventHandler('drugs:server:robCornerDrugs', function(item, amount, price)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local AvailableDrugs = false

    Player.Functions.RemoveItem(item, amount)

    TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item], "remove")
    TriggerEvent("bj-log:server:CreateLog", "crim", "Drug Corner Selling", "green", "**"..Player.PlayerData.name .. "** has been robbed selling drugs. Drug taken: "..BJCore.Shared.Items[item]['label'].." amount: "..amount)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            if not AvailableDrugs then AvailableDrugs = {}; end
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = BJCore.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)
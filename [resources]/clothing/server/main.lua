BJCore.Commands.Add("skin", "Skin menu", {}, false, function(source, args)
	TriggerClientEvent("bj-clothing:client:openMenu", source)
end, "admin")

RegisterServerEvent("bj-clothing:saveSkin")
AddEventHandler('bj-clothing:saveSkin', function(model, skin, new)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    if model ~= nil and skin ~= nil then
        if new then
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `playerskins` (`citizenid`, `model`, `skin`, `active`) VALUES ('"..Player.PlayerData.citizenid.."', '"..model.."', '"..skin.."', 1)")
        else
            BJCore.Functions.ExecuteSql(false, "UPDATE `playerskins` SET `model` = @model, `skin` = @skin WHERE `citizenid` = @citizenid", nil, {
                ["model"] = model,
                ["skin"] = skin,
                ["citizenid"] = Player.PlayerData.citizenid
            })
        end
    end
end)

RegisterServerEvent("bj-clothing:loadPlayerSkin")
AddEventHandler('bj-clothing:loadPlayerSkin', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result and result[1] ~= nil then
            print("[CLOTHING] ID "..tostring(src)..": got clothing/model data sending to client")
            TriggerClientEvent("bj-clothing:loadSkin", src, false, result[1].model, result[1].skin)
        else
            print("[CLOTHING] ID "..tostring(src)..": no saved data. create first char event")
            TriggerClientEvent("bj-clothing:loadSkin", src, true)
        end
    end)
end)

RegisterServerEvent("bj-clothing:saveOutfit")
AddEventHandler("bj-clothing:saveOutfit", function(outfitName, model, skinData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = "outfit-"..math.random(1, 10).."-"..math.random(1111, 9999)
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_outfits` (`citizenid`, `outfitname`, `model`, `skin`, `outfitId`) VALUES ('"..Player.PlayerData.citizenid.."', '"..outfitName.."', '"..model.."', '"..json.encode(skinData).."', '"..outfitId.."')", function()
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = @citizenid AND outfitId = @outfitid", function(result)
                if result and result[1] ~= nil then
                    TriggerClientEvent('bj-clothing:client:addOutfit', src, Player.PlayerData.citizenid, result[1])
                end
            end, {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@outfitid'] = outfitId
            })
        end)
    end
end)

RegisterServerEvent("bj-clothing:server:removeOutfit")
AddEventHandler("bj-clothing:server:removeOutfit", function(outfitName, outfitId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "DELETE FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `outfitname` = '"..outfitName.."' AND `outfitId` = '"..outfitId.."'", function()
        TriggerClientEvent('bj-clothing:client:deleteOutfit', src, Player.PlayerData.citizenid, outfitId)
    end)
end)

BJCore.Functions.RegisterServerCallback('bj-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local anusVal = {}

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result and result[1] ~= nil then
            for k, v in pairs(result) do
                result[k].skin = json.decode(result[k].skin)
                anusVal[k] = v
            end
            cb(anusVal)
        end
        cb(anusVal)
    end)
end)

RegisterNetEvent("bj-clothing:server:HandleBucket")
AddEventHandler("bj-clothing:server:HandleBucket", function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        if GetPlayerRoutingBucket(src) == 0 then
            SetPlayerRoutingBucket(src, src)
        else
            SetPlayerRoutingBucket(src, 0)
        end
    end
end)

RegisterServerEvent('bj-clothing:print')
AddEventHandler('bj-clothing:print', function(data)
    print(data)
end)

BJCore.Commands.Add("hat", "Put your helmet/cap/hat on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustfacewear", source, 1, nil, GetClothingItemByType(source, "hat")) -- Hat
end)

BJCore.Commands.Add("glasses", "Put your glasses on or off", {}, false, function(source, args)
	TriggerClientEvent("bj-clothing:client:adjustfacewear", source, 2, nil, GetClothingItemByType(source, "glasses"))
end)

BJCore.Commands.Add("mask", "Put your mask on or off", {}, false, function(source, args)
	TriggerClientEvent("bj-clothing:client:adjustfacewear", source, 4, nil, GetClothingItemByType(source, "mask"))
end)

BJCore.Commands.Add("bag", "Put your bag on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustfacewear", source, 5, nil, GetClothingItemByType(source, "bag"))
end)

BJCore.Commands.Add("shirt", "Put your t-shirt on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustClothing", source, 3, nil, GetClothingItemByType(source, "shirt"))
end)

BJCore.Commands.Add("pants", "Put your pants on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustClothing", source, 4, nil, GetClothingItemByType(source, "pants"))
end)

BJCore.Commands.Add("shoes", "Put your shoes on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustClothing", source, 6, nil, GetClothingItemByType(source, "shoes"))
end)

BJCore.Commands.Add("vest", "Put your vest on or off", {}, false, function(source, args)
    TriggerClientEvent("bj-clothing:client:adjustClothing", source, 9, nil, GetClothingItemByType(source, "vest"))
end)

function GetClothingItemByType(src, type)
    local ret = false
    local Player = BJCore.Functions.GetPlayer(src)
    if Player then
        for k,v in pairs(Player.PlayerData.items) do
            print("item data: "..BJCore.Common.Dump(v))
            if v.type == "clothing" and v.name == type then
                print("found hat")
                if v.info ~= nil and v.info.Prop ~= nil then
                    print("found hat with correct info")
                    ret = Player.PlayerData.items[k]
                    break
                end
            end
        end
    end
    return ret
end

local PropItems = {
    [1] = "hat",
    [2] = "glasses",
    [4] = "mask",
    [5] = "bag"
}

local VariationItems = {
    [3] = "shirt",
    [4] = "pants",
    [6] = "shoes",
    [9] = "vest"
}

RegisterNetEvent("clothing:server:createFacewear", function(type, propData)
    print("propData: "..BJCore.Common.Dump(propData))
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player then
        TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[PropItems[type]], "add")
        Player.Functions.AddItem(PropItems[type], 1, nil, propData)
    end
end)

RegisterNetEvent("clothing:server:createClothing", function(type, propData)
    print("type: "..tostring(type))
    print("propData: "..BJCore.Common.Dump(propData))
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player then
        TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[VariationItems[type]], "add")
        Player.Functions.AddItem(VariationItems[type], 1, nil, propData)
    end
end)

for k,v in pairs(PropItems) do
    BJCore.Functions.CreateUseableItem(v, function(source, item)
        local Player = BJCore.Functions.GetPlayer(source)
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
            TriggerClientEvent("bj-clothing:client:adjustfacewear", source, k, item.info)
        end
    end)
end

for k,v in pairs(VariationItems) do
    BJCore.Functions.CreateUseableItem(v, function(source, item)
        local Player = BJCore.Functions.GetPlayer(source)
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
            TriggerClientEvent("bj-clothing:client:adjustClothing", source, k, item.info)
        end
    end)
end
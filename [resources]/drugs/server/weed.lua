local openWorldPlants = {}
BJCore.Functions.RegisterServerCallback('weed:server:getBuildingPlants', function(source, cb, building)
    local buildingPlants = {}

    exports['ghmattimysql']:execute('SELECT * FROM weed_plants WHERE building = @building', {['@building'] = building}, function(plants)
        for i = 1, #plants, 1 do
            plants[i].coords = json.decode(plants[i].coords)
            table.insert(buildingPlants, plants[i])
        end

        if buildingPlants ~= nil then
            cb(buildingPlants)
        else    
            cb(nil)
        end
    end)
end)

RegisterServerEvent('weed:server:placePlant')
AddEventHandler('weed:server:placePlant', function(currentHouse, coords, sort, zone)
    local random = math.random(1, 2)
    local gender
    if random == 1 then gender = "male" else gender = "female" end
    if currentHouse then
        BJCore.Functions.ExecuteSql(true, "INSERT INTO `weed_plants` (`building`, `coords`, `gender`, `sort`) VALUES ('"..currentHouse.."', '"..coords.."', '"..gender.."', '"..sort.."')")
        TriggerClientEvent('weed:client:refreshHousePlants', -1, currentHouse)
    else
        BJCore.Functions.ExecuteSql(true, "INSERT INTO `weed_plants` (`coords`, `gender`, `sort`, `openWorld`, `zone`) VALUES ('"..coords.."', '"..gender.."', '"..sort.."', '1', '"..zone.."')")
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `weed_plants` WHERE `coords` = '"..coords.."'", function(plant)
            if plant and plant[1] ~= nil then
                plant[1].coords = json.decode(plant[1].coords)
                TriggerClientEvent('weed:client:addOpenWorldPlant', -1, plant[1].id, plant[1])
            end
        end)
    end  
end)

RegisterServerEvent('weed:server:removeDeadPlant')
AddEventHandler('weed:server:removeDeadPlant', function(building, plantId)
    local src = source
    BJCore.Functions.ExecuteSql(true, "DELETE FROM `weed_plants` WHERE `id` = '"..plantId.."'")
    if building then
        TriggerClientEvent('weed:client:refreshHousePlants', -1, building)
    else
        TriggerClientEvent('weed:client:removeOpenWorldPlant', -1, plantId)
    end
end)

if GetConvar("server_type", "DEV") == "LIVE" then
    Citizen.CreateThread(function()
        while true do
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `weed_plants`", function(housePlants)
                for k, v in pairs(housePlants) do
                    if housePlants[k].food >= 50 then
                        BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `food` = '"..(housePlants[k].food - 1).."' WHERE `id` = '"..housePlants[k].id.."'")
                        if housePlants[k].health + 1 < 100 then
                            BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `health` = '"..(housePlants[k].health + 1).."' WHERE `id` = '"..housePlants[k].id.."'")
                        end
                    end

                    if housePlants[k].food < 50 then
                        if housePlants[k].food - 1 >= 0 then
                            BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `food` = '"..(housePlants[k].food - 1).."' WHERE `id` = '"..housePlants[k].id.."'")
                        end
                        if housePlants[k].health - 1 >= 0 then
                            BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `health` = '"..(housePlants[k].health - 1).."' WHERE `id` = '"..housePlants[k].id.."'")
                        end
                    end
                end
                recacheOpenWorld()
                TriggerClientEvent('weed:client:refreshPlantStats', -1)
            end)

            Citizen.Wait((60 * 1000) * 19.2)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `weed_plants`", function(housePlants)
                for k, v in pairs(housePlants) do
                    if housePlants[k].health > 50 then
                        local Grow = math.random(3,6)
                        if housePlants[k].progress + Grow < 100 then
                            BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `progress` = '"..(housePlants[k].progress + 1).."' WHERE `id` = '"..housePlants[k].id.."'")
                        elseif housePlants[k].progress + Grow >= 100 then
                            if housePlants[k].stage ~= Config.WeedPlants[housePlants[k].sort]["highestStage"] then
                                if housePlants[k].stage == "stage-a" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-b' WHERE `id` = '"..housePlants[k].id.."'")
                                elseif housePlants[k].stage == "stage-b" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-c' WHERE `id` = '"..housePlants[k].id.."'")
                                elseif housePlants[k].stage == "stage-c" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-d' WHERE `id` = '"..housePlants[k].id.."'")
                                elseif housePlants[k].stage == "stage-d" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-e' WHERE `id` = '"..housePlants[k].id.."'")
                                elseif housePlants[k].stage == "stage-e" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-f' WHERE `id` = '"..housePlants[k].id.."'")
                                elseif housePlants[k].stage == "stage-f" then
                                    BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `stage` = 'stage-g' WHERE `id` = '"..housePlants[k].id.."'")
                                end
                                BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `progress` = '0' WHERE `id` = '"..housePlants[k].id.."'")
                            end
                        end
                    end
                end
                recacheOpenWorld()
                TriggerClientEvent('weed:client:refreshPlantStats', -1)
            end)

            Citizen.Wait((60 * 1000) * 7)
        end
    end)
end

BJCore.Functions.CreateUseableItem("weed_white-widow_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'white-widow', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_skunk_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'skunk', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_purple-haze_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'purple-haze', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'og-kush', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_amnesia_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'amnesia', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_ak47_seed", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('weed:client:placePlant', source, 'ak47', item, hasReqItems(source))
end)

BJCore.Functions.CreateUseableItem("weed_nutrition", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("vineyard:client:feedPlant", source, item, 'food')
    TriggerClientEvent('weed:client:feedPlant', source, item)
end)

function hasReqItems(source)
    local Player = BJCore.Functions.GetPlayer(source)
    local plantPot = Player.Functions.GetItemByName('plantpot')
    local soil = Player.Functions.GetItemByName('soil')
    if plantPot ~= nil and soil ~= nil then
        return true
    else
        return false
    end
end

RegisterServerEvent('weed:server:removeSeed')
AddEventHandler('weed:server:removeSeed', function(item, seed, removeMats)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item.name, 1, item.slot)
    TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item.name], "remove")
    if removeMats then
        Player.Functions.RemoveItem('soil', 1)
        Player.Functions.RemoveItem('plantpot', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["plantpot"], "remove")
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["soil"], "remove")
    end
end)

RegisterServerEvent('weed:server:harvestPlant')
AddEventHandler('weed:server:harvestPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local sndAmount = math.random(12, 26)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `weed_plants` WHERE id = '"..plantId.."'", function(result)
        if result[1] ~= nil then
            if math.random(100) >= 70 then
                Player.Functions.AddItem('weed_'..plantName..'_seed', amount)
                TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items['weed_'..plantName..'_seed'], "add")
            end
            Player.Functions.AddItem('weed_'..plantName, sndAmount)
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items['weed_'..plantName], "add")
            BJCore.Functions.ExecuteSql(true, "DELETE FROM `weed_plants` WHERE id = '"..plantId.."'")
            TriggerClientEvent('BJCore:Notify', src, 'Harvest complete', 'success', 3500)
            if house then
                TriggerClientEvent('weed:client:refreshHousePlants', -1, house)
            else
                TriggerClientEvent('weed:client:removeOpenWorldPlant', -1, plantId)
            end
        else
            TriggerClientEvent('BJCore:Notify', src, 'This plant doesn\'t exist anymore', 'error', 3500)
        end
    end)
end)

RegisterServerEvent('weed:server:feedPlant')
AddEventHandler('weed:server:feedPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `weed_plants` WHERE `id` = '"..plantId.."'", function(plantStats)
        local newAmount = plantStats[1].food + amount
        if newAmount > 100 then newAmount = 100; end
        BJCore.Functions.ExecuteSql(true, "UPDATE `weed_plants` SET `food` = '"..newAmount.."' WHERE `id` = '"..plantId.."'")
        Player.Functions.RemoveItem('weed_nutrition', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items['weed_nutrition'], "remove")
        if house then
            TriggerClientEvent('weed:client:refreshHousePlants', -1, house)
        else
            TriggerClientEvent('weed:client:updatePlantStats', -1, plantId, newAmount)
        end
    end)
end)

local openWorldReady = false
Citizen.CreateThread(function()
    exports['ghmattimysql']:execute('SELECT * FROM weed_plants WHERE `openWorld` = @openWorld', {['@openWorld'] = "1"}, function(plants)
        if plants and plants[1] ~= nil then
            openWorldPlants = plants
        end
        openWorldReady = true
    end)
end)

RegisterNetEvent("weed:server:getOpenWorldPlants")
AddEventHandler("weed:server:getOpenWorldPlants", function(zone)
    local src = source
    if not zone or zone == nil then return; end
    while not openWorldReady do Citizen.Wait(100); end
    local retTab = {}
    for k,v in pairs(openWorldPlants) do
        if v.zone == zone then
            if type(v.coords) ~= "table" then
                v.coords = json.decode(v.coords)
            end
            retTab[v.id] = openWorldPlants[k]
        end
    end
    TriggerClientEvent("weed:client:syncOpenWorldPlants", src, retTab)
end)

RegisterNetEvent("weedcache")
AddEventHandler("weedcache", function()
    openWorldReady = false
    exports['ghmattimysql']:execute('SELECT * FROM weed_plants WHERE `openWorld` = @openWorld', {['@openWorld'] = "1"}, function(plants)
        if plants and plants[1] ~= nil then
            openWorldPlants = plants
        end
        openWorldReady = true
    end)
end)

function recacheOpenWorld()
    openWorldReady = false
    exports['ghmattimysql']:execute('SELECT * FROM weed_plants WHERE `openWorld` = @openWorld', {['@openWorld'] = "1"}, function(plants)
        if plants and plants[1] ~= nil then
            openWorldPlants = plants
        end
        openWorldReady = true
    end)
end

local isLoggedIn = true
local housePlants = {}
local insideHouse = false
local currentHouse = nil
local currentHousePlants = {}

local openWorldZone = {}
local openWorldPlants = {}
local currentOpenWorldPlants = {}
local curPlant = nil

RegisterNetEvent('weed:client:getHousePlants')
AddEventHandler('weed:client:getHousePlants', function(house)    
    BJCore.Functions.TriggerServerCallback('weed:server:getBuildingPlants', function(plants)
        currentHouse = house
        housePlants[currentHouse] = plants
        insideHouse = true
        spawnHousePlants()
        plantTick()
    end, house)
end)

function spawnHousePlants()
    Citizen.CreateThread(function()
        if not plantSpawned then
            for k, v in pairs(housePlants[currentHouse]) do
                local plantData = {
                    ["plantCoords"] = {["x"] = housePlants[currentHouse][k].coords.x, ["y"] = housePlants[currentHouse][k].coords.y, ["z"] = housePlants[currentHouse][k].coords.z},
                    ["plantProp"] = GetHashKey(Config.WeedPlants[housePlants[currentHouse][k].sort]["stages"][housePlants[currentHouse][k].stage]),
                }

                plantProp = CreateObject(plantData["plantProp"], plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], false, false, false)
                FreezeEntityPosition(plantProp, true)
                SetEntityAsMissionEntity(plantProp, false, false)
                --PlaceObjectOnGroundProperly(plantProp)
                Citizen.Wait(20)
                PlaceObjectOnGroundProperly(plantProp)
                table.insert(currentHousePlants, plantProp)
            end
            plantSpawned = true
        end
    end)
end

function despawnHousePlants()
    Citizen.CreateThread(function()
        if plantSpawned then
            for k, v in pairs(currentHousePlants) do
                if DoesEntityExist(v) then
                    SetEntityAsMissionEntity(v, true, true)
                    DeleteEntity(v)
                end
            end
            currentHousePlants = {}
            plantSpawned = false
        end
    end)
end

local ClosestTarget = 0

function plantTick()
    Citizen.CreateThread(function()
        while insideHouse do
            Citizen.Wait(0)
            if plantSpawned then
                local ped = PlayerPedId()
                for k, v in pairs(housePlants[currentHouse]) do
                    local gender = "M"
                    if housePlants[currentHouse][k].gender == "female" then gender = "F" end

                    local plantData = {
                        ["plantCoords"] = {["x"] = housePlants[currentHouse][k].coords.x, ["y"] = housePlants[currentHouse][k].coords.y, ["z"] = housePlants[currentHouse][k].coords.z},
                        ["plantStage"] = housePlants[currentHouse][k].stage,
                        ["plantProp"] = GetHashKey(Config.WeedPlants[housePlants[currentHouse][k].sort]["stages"][housePlants[currentHouse][k].stage]),
                        ["plantSort"] = {
                            ["name"] = housePlants[currentHouse][k].sort,
                            ["label"] = Config.WeedPlants[housePlants[currentHouse][k].sort]["label"],
                        },
                        ["plantStats"] = {
                            ["food"] = housePlants[currentHouse][k].food,
                            ["health"] = housePlants[currentHouse][k].health,
                            ["progress"] = housePlants[currentHouse][k].progress,
                            ["stage"] = housePlants[currentHouse][k].stage,
                            ["highestStage"] = Config.WeedPlants[housePlants[currentHouse][k].sort]["highestStage"],
                            ["gender"] = gender,
                            ["plantId"] = housePlants[currentHouse][k].id,
                        }
                    }

                    local plyDistance = #(GetEntityCoords(ped) - vector3(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"]))

                    if plyDistance < 0.8 then

                        ClosestTarget = k
                        if plantData["plantStats"]["health"] > 0 then
                            if PlayerData.job.name == 'police' and Config.WhitelistWeed[PlayerData.citizenid] == nil then
                                BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], "[~r~E~w~] Destroy Plant")
                                if IsControlJustPressed(0, 38) then
                                    destroyPlant(currentHouse, plantData["plantStats"]["plantId"])
                                end   
                            elseif plantData["plantStage"] ~= plantData["plantStats"]["highestStage"] then
                                BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Type: '..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | Nutrition: ~b~'..plantData["plantStats"]["food"]..'% ~w~ | Health: ~b~'..plantData["plantStats"]["health"]..'%')
                            else
                                BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"] + 0.2, '[~g~E~w~] Harvest')
                                BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Type: ~g~'..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | Nutrition: ~b~'..plantData["plantStats"]["food"]..'% ~w~ | Health: ~b~'..plantData["plantStats"]["health"]..'%')
                                if IsControlJustPressed(0, 38) then
                                    harvestPlant(currentHouse, plantData)
                                end
                            end
                        elseif plantData["plantStats"]["health"] == 0 then
                            BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Plant is dead | [~r~E~w~] Remove')
                            if IsControlJustPressed(0, 38) then
                                destroyPlant(currentHouse, plantData["plantStats"]["plantId"])
                            end
                        end
                    end
                end
            end
        end
    end)
end

RegisterNetEvent('weed:client:leaveHouse')
AddEventHandler('weed:client:leaveHouse', function()
    despawnHousePlants()
    SetTimeout(1000, function()
        if currentHouse ~= nil then
            insideHouse = false
            housePlants[currentHouse] = nil
            currentHouse = nil
        end
    end)
end)

RegisterNetEvent('weed:client:refreshHousePlants')
AddEventHandler('weed:client:refreshHousePlants', function(house)
    if currentHouse ~= nil and currentHouse == house then
        despawnHousePlants()
        SetTimeout(500, function()
            BJCore.Functions.TriggerServerCallback('weed:server:getBuildingPlants', function(plants)
                currentHouse = house
                housePlants[currentHouse] = plants
                spawnHousePlants()
            end, house)
        end)
    end
end)

RegisterNetEvent('weed:client:refreshPlantStats')
AddEventHandler('weed:client:refreshPlantStats', function()
    if insideHouse then
        despawnHousePlants()
        SetTimeout(500, function()
            BJCore.Functions.TriggerServerCallback('weed:server:getBuildingPlants', function(plants)
                housePlants[currentHouse] = plants
                spawnHousePlants()
            end, currentHouse)
        end)
    end
    TriggerServerEvent("weed:server:getOpenWorldPlants", openWorldZone)
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(100)
    end
end

RegisterNetEvent('weed:client:placePlant')
AddEventHandler('weed:client:placePlant', function(type, item, hasReqItem)
    local ped = PlayerPedId()
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.75, 0)
    local plantData = {
        ["plantCoords"] = {["x"] = plyCoords.x, ["y"] = plyCoords.y, ["z"] = plyCoords.z},
        ["plantModel"] = Config.WeedPlants[type]["stages"]["stage-a"],
        ["plantLabel"] = Config.WeedPlants[type]["label"]
    }
    local ClosestPlant = 0
    for k, v in pairs(Config.WeedProps) do
        if ClosestPlant == 0 then
            ClosestPlant = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 0.8, GetHashKey(v), false, false, false)
        end
    end

    if currentHouse ~= nil then
        if not hasReqItem then BJCore.Functions.Notify("You don't have the required items to plant this", "error") return; end
        if ClosestPlant == 0 then
            exports['mythic_progbar']:Progress({
                name = "plant_weed_plant",
                duration = 12000,
                label = "Planting",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
                animation = {
                    animDict = "amb@world_human_gardener_plant@male@base",
                    anim = "base",
                    flags = 16,
                },        
            }, function(status)
                if not status then
                    ClearPedTasks(ped)

                    TriggerServerEvent('weed:server:placePlant', currentHouse, json.encode(plantData["plantCoords"]), type, false)
                    TriggerServerEvent('weed:server:removeSeed', item, type, true)
                else
                    ClearPedTasks(ped)
                    BJCore.Functions.Notify("Cancelled", "error")
                end
            end)
        else
            BJCore.Functions.Notify('Too close to another plant', 'error', 3500)
        end
    elseif canPlantSurface() then
        if ClosestPlant == 0 then
            exports['mythic_progbar']:Progress({
                name = "plant_weed_plant",
                duration = 18000,
                label = "Planting",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
                animation = {task = 'world_human_gardener_plant'}    
            }, function(status)
                if not status then
                    ClearPedTasks(ped)
                
                    TriggerServerEvent('weed:server:placePlant', false, json.encode(plantData["plantCoords"]), type, GetNameOfZone(GetEntityCoords(ped)))
                    TriggerServerEvent('weed:server:removeSeed', item, type, false)
                else
                    ClearPedTasks(ped)
                    BJCore.Functions.Notify("Cancelled", "error")
                end
            end)
        else
            BJCore.Functions.Notify('Too close to another plant', 'error', 3500)
        end
    else
        BJCore.Functions.Notify('You can\'t plant this here', 'error', 3500)
    end
end)

RegisterNetEvent('weed:client:feedPlant')
AddEventHandler('weed:client:feedPlant', function(item)
    local closest, closestV, closestDist = getClosestPlant()
    if currentHouse == nil and closestDist > 1.0 then return; end
    local plyPed = PlayerPedId()
    local curPlant = nil
    if currentHouse == nil then
        if closestDist > 1.0 then return; end
        curPlant = openWorldPlants[closest]
    else
        if ClosestTarget == 0 then return; end
        curPlant = housePlants[currentHouse][ClosestTarget]
        local plyDistance = #(GetEntityCoords(plyPed) - vector3(curPlant.coords.x, curPlant.coords.y, curPlant.coords.z))
        if plyDistance > 1.0 then return; end
    end

    if curPlant == nil then return; end

    local plantData = {}
    local gender = "M"
    if curPlant.gender == "female" then 
        gender = "F" 
    end

    plantData = {
        ["plantCoords"] = {["x"] = curPlant.coords.x, ["y"] = curPlant.coords.y, ["z"] = curPlant.coords.z},
        ["plantStage"] = curPlant.stage,
        ["plantProp"] = GetHashKey(Config.WeedPlants[curPlant.sort]["stages"][curPlant.stage]),
        ["plantSort"] = {
            ["name"] = curPlant.sort,
            ["label"] = Config.WeedPlants[curPlant.sort]["label"],
        },
        ["plantStats"] = {
            ["food"] = curPlant.food,
            ["health"] = curPlant.health,
            ["progress"] = curPlant.progress,
            ["stage"] = curPlant.stage,
            ["highestStage"] = Config.WeedPlants[curPlant.sort]["highestStage"],
            ["gender"] = gender,
            ["plantId"] = curPlant.id,
        }
    }

    if plantData["plantStats"]["food"] == 100 then
        BJCore.Functions.Notify('This plant doesn\'t need to be fed', 'error', 3500)
    else
        exports['mythic_progbar']:Progress({
            name = "water_weed_plant",
            duration = math.random(24000, 38000),
            label = "Feeding Plant",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "timetable@gardener@filling_can",
                anim = "gar_ig_5_filling_can",
                flags = 16,
            },        
        }, function(status)
            if not status then
                ClearPedTasks(plyPed)
                local newFood = math.random(12, 18)
                TriggerServerEvent('weed:server:feedPlant', currentHouse or false, newFood, plantData["plantSort"]["name"], plantData["plantStats"]["plantId"])
            else
                ClearPedTasks(plyPed)
                BJCore.Functions.Notify("Cancelled", "error")
            end
        end)
    end
end)

RegisterCommand("surf", function()
    canPlantSurface()
end)

function canPlantSurface()
    local ret = false
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local num = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z+4, plyPos.x, plyPos.y, plyPos.z-2.0, 2, 1, plyPed, 7)
    local arg1, arg2, arg3, arg4, arg5, arg6 = GetShapeTestResultIncludingMaterial(num)
    print("surface: "..arg5)
    if Config.WeedAllowedSurfaces[arg5] then ret = true; end
    return ret
end

Citizen.CreateThread(function()
    while BJCore == nil do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    PlayerData = BJCore.Functions.GetPlayerData()
    openWorldZone = GetNameOfZone(GetEntityCoords(PlayerPedId()))
    TriggerServerEvent("weed:server:getOpenWorldPlants", openWorldZone)
    while true do
        local plyPos = GetEntityCoords(PlayerPedId())
        local curZone = GetNameOfZone(plyPos)
        if openWorldZone ~= curZone then
            openWorldZone = curZone
            TriggerServerEvent("weed:server:getOpenWorldPlants", openWorldZone)
        end
        local nearby = false
        local closest, closestV, closestDist = getClosestPlant()
        if closestDist < 15 then
            nearby = true
            local gender = "M"
            if closestV.gender == "female" then gender = "F" end

            local plantData = {
                ["plantCoords"] = {["x"] = closestV.coords.x, ["y"] = closestV.coords.y, ["z"] = closestV.coords.z},
                ["plantStage"] = closestV.stage,
                ["plantProp"] = GetHashKey(Config.WeedPlants[closestV.sort]["stages"][closestV.stage]),
                ["plantSort"] = {
                    ["name"] = closestV.sort,
                    ["label"] = Config.WeedPlants[closestV.sort]["label"],
                },
                ["plantZone"] = closestV.zone,
                ["plantStats"] = {
                    ["food"] = closestV.food,
                    ["health"] = closestV.health,
                    ["progress"] = closestV.progress,
                    ["stage"] = closestV.stage,
                    ["highestStage"] = Config.WeedPlants[closestV.sort]["highestStage"],
                    ["gender"] = gender,
                    ["plantId"] = closestV.id,
                }
            }
            if closestDist < 0.8 then
                ClosestTarget = closest
                if plantData["plantStats"]["health"] > 0 then
                    if PlayerData.job.name == 'police' and Config.WhitelistWeed[PlayerData.citizenid] == nil then
                        BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], "[~r~E~w~] Destroy Plant")
                        if IsControlJustPressed(0, 38) then
                            destroyPlant(currentHouse, plantData["plantStats"]["plantId"])
                        end   
                    elseif plantData["plantStage"] ~= plantData["plantStats"]["highestStage"] then
                        BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Type: '..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | Nutrition: ~b~'..plantData["plantStats"]["food"]..'% ~w~ | Health: ~b~'..plantData["plantStats"]["health"]..'%')
                    else
                        BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"] + 0.2, '[~g~E~w~] Harvest')
                        BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Type: ~g~'..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | Nutrition: ~b~'..plantData["plantStats"]["food"]..'% ~w~ | Health: ~b~'..plantData["plantStats"]["health"]..'%')
                        if IsControlJustPressed(0, 38) then
                            harvestPlant(currentHouse, plantData)
                        end
                    end
                elseif plantData["plantStats"]["health"] == 0 then
                    BJCore.Functions.DrawText3D(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 'Plant is dead | [~r~E~w~] Remove')
                    if IsControlJustPressed(0, 38) then
                        destroyPlant(currentHouse, plantData["plantStats"]["plantId"])
                    end
                end
            end
        end
        if not nearby or insideHouse then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
end)

function getClosestPlant()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closest,closestDist
    for k,v in pairs(openWorldPlants) do
        if v ~= nil then
            local v3 = vector3(v.coords.x, v.coords.y, v.coords.z)
            local dist = #(plyPos - v3)
            if (not closestDist or dist < closestDist) then
                closest = k
                closestV = v
                closestDist = dist
            end
            if dist < 75 and not currentOpenWorldPlants[k] then
                createPlant(k)
            elseif dist >= 75 and currentOpenWorldPlants[k] then
                SetEntityAsMissionEntity(currentOpenWorldPlants[k], true, true)
                DeleteObject(currentOpenWorldPlants[k])
                currentOpenWorldPlants[k] = false
            end
            if currentOpenWorldPlants[k] then
                if GetEntityModel(currentOpenWorldPlants[k]) ~= GetHashKey(Config.WeedProps[openWorldPlants[k].stage]) then
                    SetEntityAsMissionEntity(currentOpenWorldPlants[k], true, true)
                    DeleteObject(currentOpenWorldPlants[k])
                    currentOpenWorldPlants[k] = false
                end
            end
        end
    end
    if closestDist then return closest,closestV,closestDist
    else return false,false,999999; end
end

function createPlant(key)
    local plantObject = CreateObject(GetHashKey(Config.WeedProps[openWorldPlants[key].stage]), openWorldPlants[key]["coords"]["x"], openWorldPlants[key]["coords"]["y"], openWorldPlants[key]["coords"]["z"], false, false, false)
    SetEntityAlpha(plantObject,  0.0)
    FreezeEntityPosition(plantObject, true)
    SetEntityAsMissionEntity(plantObject, false, false)
    Citizen.Wait(20)
    PlaceObjectOnGroundProperly(plantObject)
    Citizen.Wait(100)
    local plantPos = GetEntityCoords(plantObject)
    SetEntityCoords(plantObject, plantPos.x, plantPos.y, plantPos.z - 0.48)
    FreezeEntityPosition(plantObject, true)
    ResetEntityAlpha(plantObject)
    currentOpenWorldPlants[key] = plantObject
end

function destroyPlant(house, id)
    exports['mythic_progbar']:Progress({
        name = "destroy_weed_plant",
        duration = math.random(24000, 48000),
        label = "Removing Plant",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {task = 'world_human_gardener_plant'}  
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('weed:server:removeDeadPlant', house or false, id)
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end

function harvestPlant(house, data)
    exports['mythic_progbar']:Progress({
        name = "harvest_weed_plant",
        duration = math.random(24000, 48000),
        label = "Harvesting Plant",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        },        
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            if data["plantStats"]["gender"] == "M" then
                amount = math.random(1, 5)
            else
                amount = math.random(3, 8)
            end
            TriggerServerEvent('weed:server:harvestPlant', currentHouse or false, amount, data["plantSort"]["name"], data["plantStats"]["plantId"])
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end

RegisterNetEvent("weed:client:updatePlantStats")
AddEventHandler("weed:client:updatePlantStats", function(id, stats)
    if openWorldPlants[id] ~= nil then
        openWorldPlants[id].food = stats
    end
end)

RegisterNetEvent("weed:client:removeOpenWorldPlant")
AddEventHandler("weed:client:removeOpenWorldPlant", function(id) 
    if openWorldPlants[id] ~= nil then
        if DoesEntityExist(currentOpenWorldPlants[id]) then
            SetEntityAsMissionEntity(currentOpenWorldPlants[id], true, true) 
            DeleteEntity(currentOpenWorldPlants[id])
            currentOpenWorldPlants[id] = false
        end
        openWorldPlants[id] = nil
    end
end)

RegisterNetEvent("weed:client:addOpenWorldPlant")
AddEventHandler("weed:client:addOpenWorldPlant", function(id, data) if openWorldZone == data.zone then openWorldPlants[id] = data; end end)
RegisterNetEvent("weed:client:syncOpenWorldPlants")
AddEventHandler("weed:client:syncOpenWorldPlants", function(data) openWorldPlants = data end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for k,v in pairs(currentOpenWorldPlants) do
        if DoesEntityExist(v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
    end
    for k,v in pairs(currentHousePlants) do
        if DoesEntityExist(v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
    end
end)

RegisterCommand("plant", function(s,a,r)
    local ped = PlayerPedId()
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.75, 0)
    local plantObject = CreateObject(GetHashKey(a[1]), plyCoords.x, plyCoords.y, plyCoords.z, false, false, false)
    SetEntityAlpha(plantObject,  0.0)
    FreezeEntityPosition(plantObject, true)
    SetEntityAsMissionEntity(plantObject, false, false)
    Citizen.Wait(20)
    PlaceObjectOnGroundProperly(plantObject)
    Citizen.Wait(100)
    local plantPos = GetEntityCoords(plantObject)
    SetEntityCoords(plantObject, plantPos.x, plantPos.y, plantPos.z - 0.48)
    FreezeEntityPosition(plantObject, true)
    ResetEntityAlpha(plantObject)
end)

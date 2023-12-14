local currentHouseGarage = nil
local hasGarageKey = nil
local currentGarage = nil
local OutsideVehicles = {}

RegisterNetEvent('garages:client:setHouseGarage')
AddEventHandler('garages:client:setHouseGarage', function(house, hasKey)
    currentHouseGarage = house
    hasGarageKey = hasKey
end)

RegisterNetEvent('garages:client:houseGarageConfig')
AddEventHandler('garages:client:houseGarageConfig', function(garageConfig)
    HouseGarages = garageConfig
end)

RegisterNetEvent('garages:client:addHouseGarage')
AddEventHandler('garages:client:addHouseGarage', function(house, garageInfo)
    HouseGarages[house] = garageInfo
end)

-- function AddOutsideVehicle(plate, veh)
--     OutsideVehicles[plate] = veh
--     TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
-- end

RegisterNetEvent('garages:client:takeOutInsurance')
AddEventHandler('garages:client:takeOutInsurance', function(vehicle, coords, spawnLocked)
    if OutsideVehicles ~= nil and next(OutsideVehicles) ~= nil then
        if OutsideVehicles[vehicle.plate] ~= nil then
            local VehExists = DoesEntityExist(OutsideVehicles[vehicle.plate])
            if not VehExists then
                BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
                    BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                        BJCore.Functions.SetVehicleProperties(veh, properties)
                        enginePercent = round(vehicle.engine / 10, 0)
                        bodyPercent = round(vehicle.body / 10, 0)
                        currentFuel = vehicle.fuel

                        if vehicle.plate ~= nil then
                            DeleteVehicle(OutsideVehicles[vehicle.plate])
                            OutsideVehicles[vehicle.plate] = veh
                            TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                        end

                        if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                            TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                        end
                        
                        if vehicle.drivingdistance ~= nil then
                            local amount = round(vehicle.drivingdistance / 1000, -2)
                            TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                            TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                        end

                        if vehicle.vehicle == "urus" then
                            SetVehicleExtra(veh, 1, false)
                            SetVehicleExtra(veh, 2, true)
                        end

                        SetEntityHeading(veh, coords.w)
                        exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                        TriggerEvent('keys:addNew', veh, GetPlate(veh))
                        SetEntityAsMissionEntity(veh, true, true)
                        doCarDamage(veh, vehicle)
                        TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                        closeMenuFull()
                        if spawnLocked then
                            SetVehicleDoorsLocked(vehicle, 2)
                        end
                    end, vehicle.plate)
                end, coords, true)
            else
                BJCore.Functions.Notify('You can\'t have two of the same vehicle out', 'error', 5000)
                AddTemporaryBlip(OutsideVehicles[vehicle.plate])
            end
        else
            BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
                BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                    BJCore.Functions.SetVehicleProperties(veh, properties)
                    enginePercent = round(vehicle.engine / 10, 0)
                    bodyPercent = round(vehicle.body / 10, 0)
                    currentFuel = vehicle.fuel

                    if vehicle.plate ~= nil then
                        OutsideVehicles[vehicle.plate] = veh
                        TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                    end

                    if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                        TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                    end

                    SetEntityHeading(veh, coords.w)
                    exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                    TriggerEvent('keys:addNew', veh, GetPlate(veh))
                    SetEntityAsMissionEntity(veh, true, true)
                    doCarDamage(veh, vehicle)
                    TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                    closeMenuFull()
                    if spawnLocked then
                        SetVehicleDoorsLocked(vehicle, 2)
                    end
                end, vehicle.plate)
            end, coords, true)
        end
    else
        BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                BJCore.Functions.SetVehicleProperties(veh, properties)
                enginePercent = round(vehicle.engine / 10, 0)
                bodyPercent = round(vehicle.body / 10, 0)
                currentFuel = vehicle.fuel

                if vehicle.plate ~= nil then
                    OutsideVehicles[vehicle.plate] = veh
                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                end

                if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                    TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                end
                
                if vehicle.drivingdistance ~= nil then
                    local amount = round(vehicle.drivingdistance / 1000, -2)
                    TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                    TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                end

                SetEntityHeading(veh, coords.w)
                exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                TriggerEvent('keys:addNew', veh, GetPlate(veh))
                SetEntityAsMissionEntity(veh, true, true)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                closeMenuFull()
                if spawnLocked then
                    SetVehicleDoorsLocked(vehicle, 2)
                end
            end, vehicle.plate)
        end, coords, true)
    end

    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
end)

RegisterNetEvent('garages:client:takeOutDepot')
AddEventHandler('garages:client:takeOutDepot', function(vehicle)
    if OutsideVehicles ~= nil and next(OutsideVehicles) ~= nil then
        if OutsideVehicles[vehicle.plate] ~= nil then
            local VehExists = DoesEntityExist(OutsideVehicles[vehicle.plate])
            if not VehExists then
                BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
                    BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                        BJCore.Functions.SetVehicleProperties(veh, properties)
                        enginePercent = round(vehicle.engine / 10, 0)
                        bodyPercent = round(vehicle.body / 10, 0)
                        currentFuel = vehicle.fuel

                        if vehicle.plate ~= nil then
                            DeleteVehicle(OutsideVehicles[vehicle.plate])
                            OutsideVehicles[vehicle.plate] = veh
                            TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                        end

                        if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                            TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                        end
                        
                        if vehicle.drivingdistance ~= nil then
                            local amount = round(vehicle.drivingdistance / 1000, -2)
                            TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                            TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                        end

                        if vehicle.vehicle == "urus" then
                            SetVehicleExtra(veh, 1, false)
                            SetVehicleExtra(veh, 2, true)
                        end

                        SetEntityHeading(veh, Depots[currentGarage].takeVehicle.h)
                        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                        exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                        TriggerEvent('keys:addNew', veh, GetPlate(veh))
                        SetEntityAsMissionEntity(veh, true, true)
                        doCarDamage(veh, vehicle)
                        TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                        closeMenuFull()
                        SetVehicleEngineOn(veh, true, true)
                    end, vehicle.plate)
                end, Depots[currentGarage].spawnPoint, true)
            else
                BJCore.Functions.Notify('You can\'t have two of the same vehicle out', 'error', 5000)
                AddTemporaryBlip(OutsideVehicles[vehicle.plate])
            end
        else
            BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
                BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                    BJCore.Functions.SetVehicleProperties(veh, properties)
                    enginePercent = round(vehicle.engine / 10, 0)
                    bodyPercent = round(vehicle.body / 10, 0)
                    currentFuel = vehicle.fuel

                    if vehicle.plate ~= nil then
                        OutsideVehicles[vehicle.plate] = veh
                        TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                    end

                    if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                        TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                    end

                    SetEntityHeading(veh, Depots[currentGarage].takeVehicle.h)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                    TriggerEvent('keys:addNew', veh, GetPlate(veh))
                    SetEntityAsMissionEntity(veh, true, true)
                    doCarDamage(veh, vehicle)
                    TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                    closeMenuFull()
                    SetVehicleEngineOn(veh, true, true)
                    
                end, vehicle.plate)
            end, Depots[currentGarage].spawnPoint, true)
        end
    else
        BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                BJCore.Functions.SetVehicleProperties(veh, properties)
                enginePercent = round(vehicle.engine / 10, 0)
                bodyPercent = round(vehicle.body / 10, 0)
                currentFuel = vehicle.fuel

                if vehicle.plate ~= nil then
                    OutsideVehicles[vehicle.plate] = veh
                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                end

                if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                    TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                end
                
                if vehicle.drivingdistance ~= nil then
                    local amount = round(vehicle.drivingdistance / 1000, -2)
                    TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                    TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                end

                SetEntityHeading(veh, Depots[currentGarage].takeVehicle.h)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                TriggerEvent('keys:addNew', veh, GetPlate(veh))
                SetEntityAsMissionEntity(veh, true, true)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                closeMenuFull()
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, Depots[currentGarage].spawnPoint, true)
    end

    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
end)

function AddTemporaryBlip(vehicle)  
    local VehicleCoords = GetEntityCoords(vehicle)
    local TempBlip = AddBlipForCoord(VehicleCoords)
    local VehicleData = BJCore.Shared.VehicleModels[GetEntityModel(vehicle)]

    SetBlipSprite (TempBlip, 225)
    SetBlipDisplay(TempBlip, 4)
    SetBlipScale  (TempBlip, 0.85)
    SetBlipAsShortRange(TempBlip, true)
    SetBlipColour(TempBlip, 0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Temp Blip: "..VehicleData["name"])
    EndTextCommandSetBlipName(TempBlip)
    BJCore.Functions.Notify("Your "..VehicleData["name"].." is temporary (1min) shown on the map", "primary", 10000)

    SetTimeout(60 * 1000, function()
        --BJCore.Functions.Notify('Your vehicle is not located on the map anymore', 'error')
        RemoveBlip(TempBlip)
    end)
end

function MenuGarage(type)
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("My "..type, "GarageList", type)
    Menu.addButton("Close menu", "close", nil) 
end

function MenuDepot()
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = "Depot"
    ClearMenu()
    Menu.addButton("Vehicle depot", "DepotList", nil)
    Menu.addButton("Close Menu", "close", nil) 
end

function MenuHouseGarage(house)
    TriggerEvent('police:client:pauseKeybind', true)
    ped = PlayerPedId();
    MenuTitle = HouseGarages[house].label
    ClearMenu()
    Menu.addButton("My vehicle", "HouseGarage", house)
    Menu.addButton("Close Menu", "close", nil) 
end
exports("MenuHouseGarage", MenuHouseGarage)

function yeet(label)
    print(label)
end

function HouseGarage(house)
    BJCore.Functions.TriggerServerCallback("garages:server:GetHouseVehicles", function(result)
        ped = PlayerPedId();
        MenuTitle = "House Garage:"
        ClearMenu()

        if result == nil then
            BJCore.Functions.Notify("You have no vehicles in your garage", "primary", 5000)
            closeMenuFull()
        else
            Menu.addButton(HouseGarages[house].label, "yeet", HouseGarages[house].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel
                curGarage = HouseGarages[house].label

                if v.state == 0 then
                    v.state = "Out/Hayes Depot"
                elseif v.state == 1 then
                    v.state = "Garage"
                elseif v.state == 2 then
                    v.state = "Police Impound"
                elseif v.state == 3 then
                    v.state = "Repossessed"
                end
                local label = "Unknown Model/Brand"
                if BJCore.Shared.VehicleModels[tonumber(v.hash)] ~= nil then
                    if BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"] ~= nil then
                        label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    else
                        print("missing name in Shared.VehicleModels for model: "..v.hash)
                    end
                    if BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"] ~= nil and BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"] ~= nil then
                        label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"].." "..BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    end
                else
                    print("missing data in Shared.VehicleModels for model: "..v.hash)
                end

                Menu.addButton(label, "TakeOutGarageVehicle", v, v.state, " Engine: " .. enginePercent.."%", " Body: " .. bodyPercent.."%", " Fuel: "..currentFuel.."%")
            end
        end
        Menu.addButton("Back", "MenuHouseGarage", house)
    end, house)
end

function getPlayerVehicles(garage)
    local vehicles = {}

    return vehicles
end

function DepotList()
    BJCore.Functions.TriggerServerCallback("garages:server:GetDepotVehicles", function(result)
        ped = PlayerPedId();
        MenuTitle = "Vehicle Impound:"
        ClearMenu()

        if result == nil then
            BJCore.Functions.Notify("You have no vehicles at the impound", "primary", 5000)
            closeMenuFull()
        else
            Menu.addButton(Depots[currentGarage].label, "yeet", Depots[currentGarage].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel


                if v.state == 0 then
                    v.state = "Impounded"
                    local label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    if BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"] ~= nil then
                        label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"].." "..BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    end
                    Menu.addButton(label, "TakeOutDepotVehicle", v, v.state .. " ("..BJCore.Config.Currency.Symbol..v.depotprice..")", " Motor: " .. enginePercent.."%", " Body: " .. bodyPercent.."%", " Fuel: "..currentFuel.."%")                    
                end
            end
        end
            
        Menu.addButton("Back", "MenuDepot",nil)
    end)
end

function GarageList(type)
    BJCore.Functions.TriggerServerCallback("garages:server:GetUserVehicles", function(result)
        ped = PlayerPedId();
        MenuTitle = "Stored Vehicles:"
        ClearMenu()

        if result == nil then
            BJCore.Functions.Notify("You have no "..type.." at this garage", "primary", 5000)
            closeMenuFull()
        else
            Menu.addButton(Garages[type][currentGarage].label, "yeet", Garages[type][currentGarage].label)

            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel
                curGarage = Garages[type][v.garage].label
                v.gtype = type

                if v.state == 0 then
                    v.state = "Out"
                elseif v.state == 1 then
                    v.state = "Garage"
                elseif v.state == 2 then
                    v.state = "Impounded"
                elseif v.state == 3 then
                    v.state = "Repossessed"
                end

                local label = "Unknown Model/Brand"
                if BJCore.Shared.VehicleModels[tonumber(v.hash)] ~= nil then
                    if BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"] ~= nil then
                        label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    else
                        print("missing name in Shared.VehicleModels for model: "..v.hash)
                    end
                    if BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"] ~= nil and BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"] ~= nil then
                        label = BJCore.Shared.VehicleModels[tonumber(v.hash)]["brand"].." "..BJCore.Shared.VehicleModels[tonumber(v.hash)]["name"]
                    end
                else
                    print("missing data in Shared.VehicleModels for model: "..v.hash)
                end
                Menu.addButton(label, "TakeOutVehicle", v, v.state, " Motor: " .. enginePercent .. "%", " Body: " .. bodyPercent.. "%", " Fuel: "..currentFuel.. "%")
            end
        end
            
        --Menu.addButton("Back", "MenuGarage", nil)
    end, currentGarage)
end

-- Citizen.CreateThread(function()
--     while true do
--         if VehPlate ~= nil then
--             local veh = OutsideVehicles[VehPlate]
--             local Damage = GetVehicleBodyHealth(veh)
--         end

--         Citizen.Wait(1000)
--     end
-- end)

function TakeOutVehicle(vehicle)
    if vehicle.state == "Garage" then
        enginePercent = round(vehicle.engine / 10, 1)
        bodyPercent = round(vehicle.body / 10, 1)
        currentFuel = vehicle.fuel

        if vehicle.gtype == "vehicle" then
            vehicle.gtype = "vehicles"
        elseif vehicle.gtype == "boat" then
            vehicle.gtype = "boats"
        end
        
        local spawnPoint = nil
        if type(Garages[vehicle.gtype][currentGarage].spawnPoint) == "vector4" then spawnPoint = Garages[vehicle.gtype][currentGarage].spawnPoint; end
        if type(Garages[vehicle.gtype][currentGarage].spawnPoint) == "table" then
            for k,v in pairs(Garages[vehicle.gtype][currentGarage].spawnPoint) do
                if BJCore.Functions.IsSpawnPointClear(v.xyz, 2.5) then
                    spawnPoint = v
                    break
                end
            end
        end
        if spawnPoint == nil then BJCore.Functions.Notify("No available spawn point", "error") return; end
        BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)

                if vehicle.plate ~= nil then
                    OutsideVehicles[vehicle.plate] = veh
                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                end

                if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                    TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                end

                if vehicle.vehicle == "urus" then
                    SetVehicleExtra(veh, 1, false)
                    SetVehicleExtra(veh, 2, true)
                end
                
                if vehicle.drivingdistance ~= nil then
                    local amount = round(vehicle.drivingdistance / 1000, -2)
                    --TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                    TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                end

                BJCore.Functions.SetVehicleProperties(veh, properties)
                local h = 0
                if type(spawnPoint) ~= "vector4" then
                    h = spawnPoint.h
                else
                    h = spawnPoint.w
                end
                SetEntityHeading(veh, h)
                exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                doCarDamage(veh, vehicle)
                SetEntityAsMissionEntity(veh, true, true)
                TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                closeMenuFull()
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                TriggerEvent('keys:addNew', veh, GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, spawnPoint, true)
    elseif vehicle.state == "Out" then
        BJCore.Functions.Notify("Your vehicle has already been taken out", "error", 2500)
    elseif vehicle.state == "Impounded" then
        BJCore.Functions.Notify("This vehicle has been impounded", "error", 4000)
    elseif vehicle.state == "Repossessed" then
        BJCore.Functions.Notify("This vehicle has been Repossessed", "error", 4000)
    end
end

function TakeOutDepotVehicle(vehicle)
    if vehicle.state == "Impounded" then
        TriggerServerEvent("garages:server:PayDepotPrice", vehicle)
    end
end

function TakeOutGarageVehicle(vehicle)
    if vehicle.state == "Garage" then
        BJCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
            BJCore.Functions.TriggerServerCallback('garages:server:GetVehicleProperties', function(properties)
                BJCore.Functions.SetVehicleProperties(veh, properties)
                enginePercent = round(vehicle.engine / 10, 1)
                bodyPercent = round(vehicle.body / 10, 1)
                currentFuel = vehicle.fuel

                if vehicle.plate ~= nil then
                    OutsideVehicles[vehicle.plate] = veh
                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                end
                
                
                if vehicle.drivingdistance ~= nil then
                    local amount = round(vehicle.drivingdistance / 1000, -2)
                    TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                    TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', vehicle.drivingdistance, vehicle.plate)
                end

                if vehicle.vehicle == "urus" then
                    SetVehicleExtra(veh, 1, false)
                    SetVehicleExtra(veh, 2, true)
                end

                if vehicle.status ~= nil and next(vehicle.status) ~= nil then
                    TriggerServerEvent('vehicletuning:server:LoadStatus', vehicle.status, vehicle.plate)
                end

                SetEntityHeading(veh, HouseGarages[currentHouseGarage].takeVehicle.h)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                exports['legacyfuel']:SetFuel(veh, vehicle.fuel)
                TriggerEvent('keys:addNew', veh, GetPlate(veh))
                SetEntityAsMissionEntity(veh, true, true)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('garages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
                closeMenuFull()
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, HouseGarages[currentHouseGarage].takeVehicle, true)
    end
end

RegisterNetEvent("garages:client:getCurVehicle")
AddEventHandler("garages:client:getCurVehicle", function(job)
    local curVeh = GetVehiclePedIsIn(PlayerPedId())
    if curVeh ~= 0 then
        TriggerServerEvent("garages:server:returnVehicleData", BJCore.Shared.VehicleModels[GetEntityModel(curVeh)].model, job)
    else
        BJCore.Functions.Notify("You must be in a vehicle to do this", "error")
    end
end)

AddEventHandler("garages:client:doCarDamage", function(currentVeh, vehProps)
    doCarDamage(currentVeh, vehProps)
end)

function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false 
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end
    
    if engine > 1000.0 then
        engine = 1000.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 900.0 then
		smash = true
	end

	if body < 800.0 then
		damageOutside = true
	end

	if body < 500.0 then
		damageOutside2 = true
	end

    Citizen.Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end

function close()
    TriggerEvent('police:client:pauseKeybind', false)
    Menu.hidden = true
end

function closeMenuFull()
    TriggerEvent('police:client:pauseKeybind', false)
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        Citizen.Wait(5)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inGarageRange = false

        for k, v in pairs(Garages["vehicles"]) do
            local takeDist = #(pos - vector3(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z))
            if takeDist <= 15 then
                inGarageRange = true
                DrawMarker(2, v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, false, false, false, false)
                if takeDist <= 1.5 then
                    if not IsPedInAnyVehicle(ped) then
                        BJCore.Functions.DrawText3D(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z + 0.5, '[~g~E~w~] Garage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            close()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        end
                        if IsControlJustPressed(0, 38) then
                            MenuGarage("vehicles")
                            Menu.hidden = not Menu.hidden
                            currentGarage = k
                        end
                    else
                        BJCore.Functions.DrawText3D(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z, v.label)
                    end
                end

                Menu.renderGUI()

                if takeDist >= 4 and not Menu.hidden then
                    closeMenuFull()
                end
            end

            local putDist = #(pos - vector3(v.putVehicle.x, v.putVehicle.y, v.putVehicle.z))

            if putDist <= 25 and IsPedInAnyVehicle(ped) then
                inGarageRange = true
                DrawMarker(2, v.putVehicle.x, v.putVehicle.y, v.putVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, false, false, false, false)
                if putDist <= 1.5 then
                    BJCore.Functions.DrawText3D(v.putVehicle.x, v.putVehicle.y, v.putVehicle.z + 0.5, '[~g~E~w~] Store Vehicle')
                    if IsControlJustPressed(0, 38) then
                        local curVeh = GetVehiclePedIsIn(ped)
                        local plate = string.gsub(GetPlate(curVeh), "%s+", "")
                        BJCore.Functions.TriggerServerCallback('garages:server:checkVehicleOwner', function(owned)
                            if owned then
                                local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
                                local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
                                local totalFuel = exports['legacyfuel']:GetFuel(curVeh)
        
                                TriggerServerEvent('garages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, k, BJCore.Functions.GetVehicleProperties(curVeh))
                                TriggerServerEvent('garages:server:updateVehicleState', 1, plate, k)
                                TriggerServerEvent('vehiclemod:server:saveStatus', plate)
                                BJCore.Functions.DeleteVehicle(curVeh)
                                if plate ~= nil then
                                    OutsideVehicles[plate] = veh
                                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                                end
                                BJCore.Functions.Notify("Vehicle stored in "..v.label, "primary", 4500)
                            else
                                BJCore.Functions.Notify("You don't own this vehicle", "error", 3500)
                            end
                        end, Entity(curVeh).state.plate, "vehicle")
                    end
                end
            end
        end

        if not inGarageRange then
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        Citizen.Wait(5)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inGarageRange = false

        if HouseGarages ~= nil and currentHouseGarage ~= nil then
            if hasGarageKey and HouseGarages[currentHouseGarage] ~= nil then
                local takeDist = GetDistanceBetweenCoords(pos, HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z)
                if takeDist <= 15 then
                    inGarageRange = true
                    DrawMarker(2, HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 0, 222, false, false, false, false, false, false, false)
                    if takeDist < 2.0 then
                        if not IsPedInAnyVehicle(ped) then
                            BJCore.Functions.DrawText3D(HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z + 0.5, '[~g~E~w~] Garage')
                            if IsControlJustPressed(1, 177) and not Menu.hidden then
                                close()
                                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            end
                            if IsControlJustPressed(0, 38) then
                                MenuHouseGarage(currentHouseGarage)
                                Menu.hidden = not Menu.hidden
                            end
                        elseif IsPedInAnyVehicle(ped) then
                            BJCore.Functions.DrawText3D(HouseGarages[currentHouseGarage].takeVehicle.x, HouseGarages[currentHouseGarage].takeVehicle.y, HouseGarages[currentHouseGarage].takeVehicle.z + 0.5, '[~g~E~w~] Store Vehicle')
                            if IsControlJustPressed(0, 38) then
                                local curVeh = GetVehiclePedIsIn(ped)
                                local plate = GetPlate(curVeh)
                                BJCore.Functions.TriggerServerCallback('garages:server:checkVehicleHouseOwner', function(owned)
                                    if owned then
                                        local bodyDamage = round(GetVehicleBodyHealth(curVeh), 1)
                                        local engineDamage = round(GetVehicleEngineHealth(curVeh), 1)
                                        local totalFuel = exports['legacyfuel']:GetFuel(curVeh)
                
                                        TriggerServerEvent('garages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, currentHouseGarage, BJCore.Functions.GetVehicleProperties(curVeh))
                                        TriggerServerEvent('garages:server:updateVehicleState', 1, plate, currentHouseGarage)
                                        BJCore.Functions.DeleteVehicle(curVeh)
                                        if plate ~= nil then
                                            OutsideVehicles[plate] = veh
                                            TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                                        end
                                        BJCore.Functions.Notify("Vehicle stored in "..HouseGarages[currentHouseGarage].label, "primary", 4500)
                                    else
                                        BJCore.Functions.Notify("You don't own this vehicle", "error", 3500)
                                    end
                                end, plate, currentHouseGarage)
                            end
                        end
                        
                        Menu.renderGUI()
                    end

                    if takeDist > 1.99 and not Menu.hidden then
                        closeMenuFull()
                    end
                end
            end
        end
        
        if not inGarageRange then
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
    if DepotsEnabled then
        Citizen.Wait(1000)
        while true do
            Citizen.Wait(5)
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inGarageRange = false

            for k, v in pairs(Depots) do
                local takeDist = GetDistanceBetweenCoords(pos, Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z)
                if takeDist <= 15 then
                    inGarageRange = true
                    DrawMarker(2, Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, false, false, false, false)
                    if takeDist <= 1.5 then
                        if not IsPedInAnyVehicle(ped) then
                            BJCore.Functions.DrawText3D(Depots[k].takeVehicle.x, Depots[k].takeVehicle.y, Depots[k].takeVehicle.z + 0.5, '[~g~E~w~] Garage')
                            if IsControlJustPressed(1, 177) and not Menu.hidden then
                                close()
                                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            end
                            if IsControlJustPressed(0, 38) then
                                MenuDepot()
                                Menu.hidden = not Menu.hidden
                                currentGarage = k
                            end
                        end
                    end

                    Menu.renderGUI()

                    if takeDist >= 4 and not Menu.hidden then
                        closeMenuFull()
                    end
                end
            end

            if not inGarageRange then
                Citizen.Wait(5000)
            end
        end
    end
end)

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

Citizen.CreateThread(function()
    while BJCore == nil do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    while true do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local inGarageRange = false

        for k, v in pairs(Garages["boats"]) do
            local takeDist = #(plyPos - v.garagePoint)
            if takeDist <= 15 then
                inGarageRange = true
                DrawMarker(2, v.garagePoint.x, v.garagePoint.y, v.garagePoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, false, false, false, false)
                if takeDist <= 1.5 then
                    if not IsPedInAnyBoat(plyPed) then
                        BJCore.Functions.DrawText3D(v.garagePoint.x, v.garagePoint.y, v.garagePoint.z + 0.5, '[~g~E~w~] Boat Garage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            close()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        end
                        if IsControlJustPressed(0, 38) then
                            MenuGarage("boats")
                            Menu.hidden = not Menu.hidden
                            currentGarage = k
                        end
                    else
                        BJCore.Functions.DrawText3D(v.garagePoint.x, v.garagePoint.y, v.garagePoint.z, Garages["boats"][k].label)
                    end
                end

                Menu.renderGUI()

                if takeDist >= 4 and not Menu.hidden then
                    closeMenuFull()
                end
            end

            local putDist = #(plyPos - v.spawnPoint.xyz)
            if putDist <= 25 and IsPedInAnyBoat(plyPed) then
                inGarageRange = true
                DrawMarker(2, v.spawnPoint.x, v.spawnPoint.y, v.spawnPoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, false, false, false, false)
                if putDist <= 3.0 then
                    BJCore.Functions.DrawText3D(v.spawnPoint.x, v.spawnPoint.y, v.spawnPoint.z + 0.5, '[~g~E~w~] Store Boat')
                    if IsControlJustPressed(0, 38) then
                        local curVeh = GetVehiclePedIsIn(plyPed)
                        local plate = string.gsub(GetPlate(curVeh), "%s+", "")
                        BJCore.Functions.TriggerServerCallback('garages:server:checkVehicleOwner', function(owned)
                            if owned then
                                local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
                                local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
                                local totalFuel = exports['legacyfuel']:GetFuel(curVeh)
        
                                TriggerServerEvent('garages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, k, BJCore.Functions.GetVehicleProperties(curVeh))
                                TriggerServerEvent('garages:server:updateVehicleState', 1, plate, k)
                                TriggerServerEvent('vehiclemod:server:saveStatus', plate)
                                BJCore.Functions.DeleteVehicle(curVeh)
                                if plate ~= nil then
                                    OutsideVehicles[plate] = veh
                                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                                end
                                BJCore.Functions.Notify("Boat stored in "..v.label, "primary", 4500)
                            else
                                BJCore.Functions.Notify("You don't own this boat", "error", 3500)
                            end
                        end, Entity(curVeh).state.plate, "boat")
                    end
                end
            end
        end

        for k, v in pairs(Garages["aircraft"]) do
            local takeDist = #(plyPos - v.garagePoint)
            if takeDist <= 15 then
                inGarageRange = true
                DrawMarker(2, v.garagePoint.x, v.garagePoint.y, v.garagePoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, false, false, false, false)
                if takeDist <= 1.5 then
                    if not IsPedInAnyPlane(plyPed) and not IsPedInAnyHeli(plyPed) then
                        BJCore.Functions.DrawText3D(v.garagePoint.x, v.garagePoint.y, v.garagePoint.z + 0.5, '[~g~E~w~] Aircraft Garage')
                        if IsControlJustPressed(1, 177) and not Menu.hidden then
                            close()
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        end
                        if IsControlJustPressed(0, 38) then
                            MenuGarage("aircraft")
                            Menu.hidden = not Menu.hidden
                            currentGarage = k
                        end
                    else
                        BJCore.Functions.DrawText3D(v.garagePoint.x, v.garagePoint.y, v.garagePoint.z, Garages["aircraft"][k].label)
                    end
                end

                Menu.renderGUI()

                if takeDist >= 4 and not Menu.hidden then
                    closeMenuFull()
                end
            end

            local putDist = #(plyPos - v.spawnPoint.xyz)
            if putDist <= 25 and (IsPedInAnyPlane(plyPed) or IsPedInAnyHeli(plyPed)) then
                inGarageRange = true
                DrawMarker(2, v.spawnPoint.x, v.spawnPoint.y, v.spawnPoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, false, false, false, false)
                if putDist <= 3.0 then
                    BJCore.Functions.DrawText3D(v.spawnPoint.x, v.spawnPoint.y, v.spawnPoint.z + 0.5, '[~g~E~w~] Store Aircraft')
                    if IsControlJustPressed(0, 38) then
                        local curVeh = GetVehiclePedIsIn(plyPed)
                        local plate = string.gsub(GetPlate(curVeh), "%s+", "")
                        BJCore.Functions.TriggerServerCallback('garages:server:checkVehicleOwner', function(owned)
                            if owned then
                                local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
                                local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
                                local totalFuel = exports['legacyfuel']:GetFuel(curVeh)
        
                                TriggerServerEvent('garages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, k, BJCore.Functions.GetVehicleProperties(curVeh))
                                TriggerServerEvent('garages:server:updateVehicleState', 1, plate, k)
                                TriggerServerEvent('vehiclemod:server:saveStatus', plate)
                                BJCore.Functions.DeleteVehicle(curVeh)
                                if plate ~= nil then
                                    OutsideVehicles[plate] = veh
                                    TriggerServerEvent('garages:server:UpdateOutsideVehicles', OutsideVehicles)
                                end
                                BJCore.Functions.Notify("Aircraft stored in "..v.label, "primary", 4500)
                            else
                                BJCore.Functions.Notify("You don't own this aircraft", "error", 3500)
                            end
                        end, Entity(curVeh).state.plate, "aircraft")
                    end
                end
            end
        end
        if not inGarageRange then
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)

function GetPlate(veh)
    local ret = GetVehicleNumberPlateText(veh)
    if Entity(veh).state.plate ~= nil then
        ret = Entity(veh).state.plate
    end
    return ret
end
exports("GetPlate", GetPlate)
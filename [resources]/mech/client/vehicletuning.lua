ModdedVehicles = {}
VehicleStatus = {}
ClosestPlate = nil
isLoggedIn = true
PlayerJob = {}

onDuty = false

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            SetClosestPlate()
        end
        Citizen.Wait(1000)
    end
end)

function SetClosestPlate()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    for id,_ in pairs(Config.Plates) do
        if current ~= nil then
            if #(pos - Config.Plates[id].coords.xyz) < dist then
                current = id
                dist = #(pos - Config.Plates[id].coords.xyz)
            end
        else
            dist = #(pos - Config.Plates[id].coords.xyz)
            current = id
        end
    end
    ClosestPlate = current
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        -- Set mech jobs on duty by default
        -- if Config.Locations[PlayerJob.name] ~= nil then
        --     if not PlayerJob.onduty then
        --         TriggerServerEvent("BJCore:ToggleDuty")
        --     end
        -- end
    end)
    isLoggedIn = true
    BJCore.Functions.TriggerServerCallback('vehicletuning:server:GetAttachedVehicle', function(plates)
        for k, v in pairs(plates) do
            Config.Plates[k].AttachedVehicle = v.AttachedVehicle
        end
    end)
    BJCore.Functions.TriggerServerCallback('vehicletuning:server:GetDrivingDistances', function(retval)
        DrivingDistance = retval
    end)
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = PlayerJob.onduty
end)

RegisterNetEvent('BJCore:Client:SetDuty')
AddEventHandler('BJCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

function isMechJob()
    local ret = false
    for k,v in pairs(Config.Locations) do
        if PlayerJob and PlayerJob.name == k then
            ret = true
            break
        end
    end
    return ret
end

local CurGarage, CurAction = false, false
Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            if isMechJob() then
                local nearby = false
                local plyPed = PlayerPedId()
                local plyPos = GetEntityCoords(plyPed)
                local closestGarage, closestGarageVal, closestGarageDist = GetClosestGarage(plyPos)
                if closestGarageDist <= 30 then
                    nearby = true
                    if not CurGarage or CurGarage.key ~= closestGarage then
                        CurGarage = { key = closestGarage, val = closestGarageVal }
                    end
                    if nearby and CurGarage then
                        local actKey, actVal, actDist = GetClosestAction(plyPos, closestGarage)
                        if not CurAction or CurAction.key ~= actKey then
                            CurAction = { key = actKey, val = actVal }
                        end
                        if actDist < 1.5 then
                            local text = Config.ActionText[actKey]
                            if actKey == "duty" then
                                if onDuty then
                                    text = "Go Off "..text
                                else
                                    text = "Go On "..text
                                end
                            elseif actKey == "vehicle" then
                                Menu.renderGUI()
                                if IsPedInAnyVehicle(PlayerPedId()) then text = "Store Vehicle"; end
                            end
                            if onDuty or actKey == "duty" then
                                BJCore.Functions.DrawText3D(actVal.x, actVal.y, actVal.z, "[~g~E~s~] "..text)
                                if BJCore.Functions.GetKeyPressed("E") then
                                    HandleAction(CurAction)
                                end
                            end
                        end
                    end
                    if onDuty then
                        for k, v in pairs(Config.Plates) do
                            if v.AttachedVehicle == nil then
                                local PlateDistance = #(plyPos - v.coords.xyz)
                                if PlateDistance < 10 then
                                    DrawMarker(2, v.coords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                                    if PlateDistance < 2 then
                                        local veh = GetVehiclePedIsIn(PlayerPedId())
                                        if IsPedInAnyVehicle(PlayerPedId()) then
                                            BJCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z + 0.3, "[~g~E~w~] Use Platform")
                                            if IsControlJustPressed(0, 38) then
                                                if (IsThisModelABike(GetEntityModel(veh)) and CurGarage.key == "handlebar") or (not IsThisModelABike(GetEntityModel(veh)) and CurGarage.key == "grovestcustom")  then
                                                    DoScreenFadeOut(150)
                                                    Wait(150)
                                                    Config.Plates[ClosestPlate].AttachedVehicle = veh
                                                    SetEntityCoords(veh, v.coords)
                                                    SetEntityHeading(veh, v.coords.w)
                                                    FreezeEntityPosition(veh, true)
                                                    Wait(500)
                                                    DoScreenFadeIn(250)
                                                    TriggerServerEvent('vehicletuning:server:SetAttachedVehicle', veh, k)
                                                else
                                                    BJCore.Functions.Notify("Vehicle not suitable for this platform", "error")    
                                                end                                                    
                                            end
                                        end
                                    end
                                end
                            else
                                local PlateDistance = #(plyPos - v.coords.xyz)
                                if PlateDistance < 3 then
                                    inRange = true
                                    BJCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[~g~E~w~] Options")
                                    if IsControlJustPressed(0, 38) then
                                        OpenMenu()
                                        Menu.hidden = not Menu.hidden
                                    end
                                    Menu.renderGUI()
                                end
                            end
                        end
                    end
                else
                    CurGarage = false
                    CurAction = false
                end
                if not nearby then Citizen.Wait(1000); end
            else
                Citizen.Wait(1000)
            end
        end
        Citizen.Wait(0)
    end
end)

function HandleAction(act)
    if act.key == "stash" then
        local name = "Grove Street Customs Inv"
        if PlayerJob.name == "handlebar" then name = "HandleBar Haven Inv"
        elseif PlayerJob.name == "mechanic" then name = "Bennys Mechanics Inv"; end
        TriggerEvent("inventory:client:SetCurrentStash", PlayerJob.name.."stash")
        TriggerServerEvent("inventory:server:OpenInventory", "stash", PlayerJob.name.."stash", {
            maxweight = 4000000,
            slots = 500,
        }, name)        
    elseif act.key == "vehicle" then
        if IsPedInAnyVehicle(PlayerPedId()) then
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        else
            VehicleList()
            Menu.hidden = not Menu.hidden 
        end
    elseif act.key == "duty" then
        TriggerServerEvent("BJCore:ToggleDuty")
    end
end

function GetClosestGarage(plyPos)
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.Locations) do
        local dist = #(plyPos - v["duty"].xyz)
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

function GetClosestAction(plyPos, key)
    local closestKey,closestVal,closestDist
    for k,v in pairs(Config.Locations[key]) do
        local dist = #(plyPos - v.xyz)
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

function niks()
    print('niks')
end

function OpenMenu()
    ClearMenu()
    Menu.addButton("Options", "VehicleOptions", nil)
    Menu.addButton("Close Menu", "CloseMenu", nil) 
end

function VehicleList()
    ClearMenu()
    for k, v in pairs(Config.Vehicles[CurGarage.key]) do
        Menu.addButton(v, "SpawnListVehicle", k) 
    end
    Menu.addButton("Close menu", "CloseMenu", nil) 
end

function SpawnListVehicle(model)
    local coords = {
        x = Config.Locations[CurGarage.key]["vehicle"].x,
        y = Config.Locations[CurGarage.key]["vehicle"].y,
        z = Config.Locations[CurGarage.key]["vehicle"].z,
        h = Config.Locations[CurGarage.key]["vehicle"].w,
    }
    local plate = "AC"..math.random(1111, 9999)
    BJCore.Functions.SpawnVehicle(model, function(veh)
        SetVehicleNumberPlateText(veh, "ACBV"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.h)
        exports['legacyfuel']:SetFuel(veh, 100.0)
        Menu.hidden = true
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function VehicleOptions()
    ClearMenu()
    Menu.addButton("Disconnect vehicle", "UnattachVehicle", nil)
    -- Menu.addButton("Check Status", "CheckStatus", nil)
    Menu.addButton("Components", "PartsMenu", nil)
    Menu.addButton("Close Menu", "CloseMenu", nil)
end

function PartsMenu()
    ClearMenu()
    local plate = GetVehicleNumberPlateText(Config.Plates[ClosestPlate].AttachedVehicle)
    if VehicleStatus[plate] ~= nil then
        for k, v in pairs(Config.ValuesLabels) do
            if math.ceil(VehicleStatus[plate][k]) ~= Config.MaxStatusValues[k] then
                local percentage = math.ceil(VehicleStatus[plate][k])
                if percentage > 100 then
                    percentage = math.ceil(VehicleStatus[plate][k]) / 10
                end
                Menu.addButton(v..": "..percentage.."%", "PartMenu", k) 
            else
                local percentage = math.ceil(Config.MaxStatusValues[k])
                if percentage > 100 then
                    percentage = math.ceil(Config.MaxStatusValues[k]) / 10
                end
                Menu.addButton(v..": "..percentage.."%", "NoDamage", nil) 
            end
        end
    else
        for k, v in pairs(Config.ValuesLabels) do
            local percentage = math.ceil(Config.MaxStatusValues[k])
            if percentage > 100 then
                percentage = math.ceil(Config.MaxStatusValues[k]) / 10
            end
            Menu.addButton(v..": "..percentage.."%", "NoDamage", nil) 
        end
    end
    Menu.addButton("Back", "VehicleOptions", nil) 
    Menu.addButton("Close menu", "CloseMenu", nil) 
end

function CheckStatus()
    local plate = GetVehicleNumberPlateText(Config.Plates[ClosestPlate].AttachedVehicle)
    SendStatusMessage(VehicleStatus[plate])
end

function PartMenu(part)
    ClearMenu()
    Menu.addButton("Repair ("..BJCore.Shared.Items[Config.RepairCostAmount[part].item]["label"].." "..Config.RepairCostAmount[part].costs.."x)", "RepairPart", part)
    Menu.addButton("Back", "VehicleOptions", nil)
    Menu.addButton("Close menu", "CloseMenu", nil) 
end

function NoDamage(part)
    ClearMenu()
    Menu.addButton("There is no damage to this part", "PartsMenu", part)
    Menu.addButton("Back", "VehicleOptions", nil)
    Menu.addButton("Close Menu", "CloseMenu", nil) 
end

function RepairPart(part)
    local plate = GetVehicleNumberPlateText(Config.Plates[ClosestPlate].AttachedVehicle)
    local PartData = Config.RepairCostAmount[part]

    BJCore.Functions.TriggerServerCallback('bj-inventory:server:GetStashItems', function(StashItems)
        for k, v in pairs(StashItems) do
            if v.name == PartData.item then
                if v.amount >= PartData.costs then
                    exports['mythic_progbar']:Progress({
                        name = "grovest_repair2",
                        duration = math.random(5000, 10000),
                        label = "Repairing "..Config.ValuesLabels[part],
                        useWhileDead = false,
                        canCancel = true,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        },
                    }, function(status)
                        if not status then
                            if (v.amount - PartData.costs) <= 0 then
                                StashItems[k] = nil
                            else
                                v.amount = (v.amount - PartData.costs)
                            end
                            TriggerEvent('vehicletuning:client:RepaireeePart', part)
                            TriggerServerEvent('bj-inventory:server:SaveStashItems', PlayerJob.name.."stash", StashItems)
                            SetTimeout(250, function()
                                PartsMenu()
                            end)
                        else
                            BJCore.Functions.Notify("Cancelled", "error")
                        end
                    end)  
                    break
                else
                    BJCore.Functions.Notify('They\'re not enough materials in storage', 'error')
                end
                break
            else
                BJCore.Functions.Notify('They\'re not enough materials in storage', 'error')
            end
        end
    end, PlayerJob.name.."stash")
end

--

RegisterNetEvent('vehicletuning:client:RepaireeePart')
AddEventHandler('vehicletuning:client:RepaireeePart', function(part)
    local veh = Config.Plates[ClosestPlate].AttachedVehicle
    local plate = GetVehicleNumberPlateText(veh)
    if part == "engine" then
        SetVehicleEngineHealth(veh, Config.MaxStatusValues[part])
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", Config.MaxStatusValues[part])
    elseif part == "body" then
        SetVehicleBodyHealth(veh, Config.MaxStatusValues[part])
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", Config.MaxStatusValues[part])
        SetVehicleFixed(veh)
    else
        TriggerServerEvent("vehiclemod:server:updatePart", plate, part, Config.MaxStatusValues[part])
    end
    BJCore.Functions.Notify("De "..Config.ValuesLabels[part].." is gerepareerd")
end)

function UnattachVehicle()
    local coords = Config.Locations["exit"]
    DoScreenFadeOut(150)
    Wait(150)
    FreezeEntityPosition(Config.Plates[ClosestPlate].AttachedVehicle, false)
    SetEntityCoords(Config.Plates[ClosestPlate].AttachedVehicle, Config.Plates[ClosestPlate].coords)
    SetEntityHeading(Config.Plates[ClosestPlate].AttachedVehicle, Config.Plates[ClosestPlate].coords.w)
    TaskWarpPedIntoVehicle(PlayerPedId(), Config.Plates[ClosestPlate].AttachedVehicle, -1)
    Wait(500)
    DoScreenFadeIn(250)
    Config.Plates[ClosestPlate].AttachedVehicle = nil
    TriggerServerEvent('vehicletuning:server:SetAttachedVehicle', false, ClosestPlate)
end

RegisterNetEvent('vehicletuning:client:SetAttachedVehicle')
AddEventHandler('vehicletuning:client:SetAttachedVehicle', function(veh, key)
    if veh ~= false then
        Config.Plates[key].AttachedVehicle = veh
    else
        Config.Plates[key].AttachedVehicle = nil
    end
end)

local effectTimer = 0
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        if (IsPedInAnyVehicle(PlayerPedId(), false)) then
            local veh = GetVehiclePedIsIn(PlayerPedId(),false)
            if not IsThisModelABicycle(GetEntityModel(veh)) and GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                local engineHealth = GetVehicleEngineHealth(veh)
                local bodyHealth = GetVehicleBodyHealth(veh)
                local plate = GetVehicleNumberPlateText(veh)
                if VehicleStatus[plate] == nil then 
                    TriggerServerEvent("vehiclemod:server:setupVehicleStatus", plate, engineHealth, bodyHealth)
                else
					if VehicleStatus[plate]["engine"] ~= engineHealth then
						TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", engineHealth)
					end
					if VehicleStatus[plate]["body"] ~= bodyHealth then
						TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", bodyHealth)
					end
                    effectTimer = effectTimer + 1
                    if effectTimer >= math.random(10, 15) then
                        ApplyEffects(veh)
                        effectTimer = 0
                    end
                end
            else
                effectTimer = 0
                Citizen.Wait(1000)
            end
        else
            effectTimer = 0
            Citizen.Wait(2000)
        end
    end
end)

RegisterNetEvent('vehiclemod:client:setVehicleStatus')
AddEventHandler('vehiclemod:client:setVehicleStatus', function(plate, status)
    VehicleStatus[plate] = status
end)

RegisterNetEvent('vehiclemod:client:setVehicleStatusList')
AddEventHandler('vehiclemod:client:setVehicleStatusList', function(vehiclesToUpdate)
    for k,v in pairs(vehiclesToUpdate) do
		VehicleStatus[k] = v
	end
end)

RegisterNetEvent('vehiclemod:client:getVehicleStatus')
AddEventHandler('vehiclemod:client:getVehicleStatus', function(plate, status)
    if not (IsPedInAnyVehicle(PlayerPedId(), false)) then
        local veh = GetVehiclePedIsIn(PlayerPedId(), true)
        if veh ~= nil and veh ~= 0 then
            local vehpos = GetEntityCoords(veh)
            local pos = GetEntityCoords(PlayerPedId())
            if #(pos - vehpos) < 5.0 then
                if not IsThisModelABicycle(GetEntityModel(veh)) then
                    local plate = GetVehicleNumberPlateText(veh)
                    if VehicleStatus[plate] ~= nil then 
                        SendStatusMessage(VehicleStatus[plate])
                    else
                        BJCore.Functions.Notify("No status know", "error")
                    end
                else
                    BJCore.Functions.Notify("Not a valid vehicle", "error")
                end
            else
                BJCore.Functions.Notify("You are not close enough to the vehicle", "error")
            end
        else
            BJCore.Functions.Notify("You must be in the vehicle first", "error")
        end
    else
        BJCore.Functions.Notify("You must be outside the vehicle", "error")
    end
end)

RegisterNetEvent('vehiclemod:client:fixEverything')
AddEventHandler('vehiclemod:client:fixEverything', function()
    if (IsPedInAnyVehicle(PlayerPedId(), false)) then
        local veh = GetVehiclePedIsIn(PlayerPedId(),false)
        if not IsThisModelABicycle(GetEntityModel(veh)) and GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
            local plate = GetVehicleNumberPlateText(veh)
            TriggerServerEvent("vehiclemod:server:fixEverything", plate)
        else
            BJCore.Functions.Notify("You are not a driver or on a bicycle", "error")
        end
    else
        BJCore.Functions.Notify("You are not in a vehicle", "error")
    end
end)

RegisterNetEvent('vehiclemod:client:setPartLevel')
AddEventHandler('vehiclemod:client:setPartLevel', function(part, level)
    if (IsPedInAnyVehicle(PlayerPedId(), false)) then
        local veh = GetVehiclePedIsIn(PlayerPedId(),false)
        if not IsThisModelABicycle(GetEntityModel(veh)) and GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
            local plate = GetVehicleNumberPlateText(veh)
            if part == "engine" then
                SetVehicleEngineHealth(veh, level)
                TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", GetVehicleEngineHealth(veh))
            elseif part == "body" then
                SetVehicleBodyHealth(veh, level)
                TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", GetVehicleBodyHealth(veh))
            else
                TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level)
            end
        else
            BJCore.Functions.Notify("You are not a driver or on a bicycle", "error")
        end
    else
        BJCore.Functions.Notify("You are not in a vehicle", "error")
    end
end)
local openingDoor = false

RegisterNetEvent('vehiclemod:client:repairPart')
AddEventHandler('vehiclemod:client:repairPart', function(part, level, needAmount)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        local veh = GetVehiclePedIsIn(PlayerPedId(), true)
        if veh ~= nil and veh ~= 0 then
            local vehpos = GetEntityCoords(veh)
            local pos = GetEntityCoords(PlayerPedId())
            if #(pos - vehpos) < 5.0 then
                if not IsThisModelABicycle(GetEntityModel(veh)) then
                    local plate = GetVehicleNumberPlateText(veh)
                    if VehicleStatus[plate] ~= nil and VehicleStatus[plate][part] ~= nil then
                        local lockpickTime = (1000 * level)
                        if part == "body" then
                            lockpickTime = lockpickTime / 10
                        end
                        ScrapAnim(lockpickTime)
                        exports['mythic_progbar']:Progress({
                            name = "grovest_repair",
                            duration = lockpickTime,
                            label = "Repairing",
                            useWhileDead = false,
                            canCancel = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "mp_car_bomb",
                                anim = "car_bomb_mechanic",
                                flags = 16,
                            },
                        }, function(status)
                            if not status then
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                if part == "body" then
                                    SetVehicleBodyHealth(veh, GetVehicleBodyHealth(veh) + level)
                                    SetVehicleFixed(veh)
                                    TriggerServerEvent("vehiclemod:server:updatePart", plate, part, GetVehicleBodyHealth(veh))
                                    TriggerServerEvent("BJCore:Server:RemoveItem", Config.RepairCost[part], needAmount)
                                    TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[Config.RepairCost[part]], "remove")
                                elseif part ~= "engine" then
                                    TriggerServerEvent("vehiclemod:server:updatePart", plate, part, GetVehicleStatus(plate, part) + level)
                                    TriggerServerEvent("BJCore:Server:RemoveItem", Config.RepairCost[part], level)
                                    TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[Config.RepairCost[part]], "remove")
                                end
                            else
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                BJCore.Functions.Notify("Cancelled", "error")
                            end
                        end)
                    else
                        BJCore.Functions.Notify("Not a valid part", "error")
                    end
                else
                    BJCore.Functions.Notify("Not a valid vehicle", "error")
                end
            else
                BJCore.Functions.Notify("You are not close enough to the vehicle", "error")
            end
        else
            BJCore.Functions.Notify("You must be in the vehicle first", "error")
        end
    else
        BJCore.Functions.Notify("You are not in a vehicle", "error")
    end
end)

function ScrapAnim(time)
    local time = time / 1000
    loadAnimDict("mp_car_bomb")
    TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(2000)
            time = time - 2
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
            end
        end
    end)
end

function ApplyEffects(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    if GetVehicleClass(vehicle) ~= 13 and GetVehicleClass(vehicle) ~= 21 and GetVehicleClass(vehicle) ~= 16 and GetVehicleClass(vehicle) ~= 15 and GetVehicleClass(vehicle) ~= 14 then
        if VehicleStatus[plate] ~= nil then 
            local chance = math.random(1, 100)
            if VehicleStatus[plate]["radiator"] <= 80 and (chance >= 1 and chance <= 20) then
                local engineHealth = GetVehicleEngineHealth(vehicle)
                if VehicleStatus[plate]["radiator"] <= 80 and VehicleStatus[plate]["radiator"] >= 60 then
                    SetVehicleEngineHealth(vehicle, engineHealth - math.random(10, 15))
                elseif VehicleStatus[plate]["radiator"] <= 59 and VehicleStatus[plate]["radiator"] >= 40 then
                    SetVehicleEngineHealth(vehicle, engineHealth - math.random(15, 20))
                elseif VehicleStatus[plate]["radiator"] <= 39 and VehicleStatus[plate]["radiator"] >= 20 then
                    SetVehicleEngineHealth(vehicle, engineHealth - math.random(20, 30))
                elseif VehicleStatus[plate]["radiator"] <= 19 and VehicleStatus[plate]["radiator"] >= 6 then
                    SetVehicleEngineHealth(vehicle, engineHealth - math.random(30, 40))
                else
                    SetVehicleEngineHealth(vehicle, engineHealth - math.random(40, 50))
                end
            end

            if VehicleStatus[plate]["axle"] <= 80 and (chance >= 21 and chance <= 40) then
                if VehicleStatus[plate]["axle"] <= 80 and VehicleStatus[plate]["axle"] >= 60 then
                    for i=0,360 do					
                        SetVehicleSteeringScale(vehicle,i)
                        Citizen.Wait(5)
                    end
                elseif VehicleStatus[plate]["axle"] <= 59 and VehicleStatus[plate]["axle"] >= 40 then
                    for i=0,360 do	
                        Citizen.Wait(10)
                        SetVehicleSteeringScale(vehicle,i)
                    end
                elseif VehicleStatus[plate]["axle"] <= 39 and VehicleStatus[plate]["axle"] >= 20 then
                    for i=0,360 do
                        Citizen.Wait(15)
                        SetVehicleSteeringScale(vehicle,i)
                    end
                elseif VehicleStatus[plate]["axle"] <= 19 and VehicleStatus[plate]["axle"] >= 6 then
                    for i=0,360 do
                        Citizen.Wait(20)
                        SetVehicleSteeringScale(vehicle,i)
                    end
                else
                    for i=0,360 do
                        Citizen.Wait(25)
                        SetVehicleSteeringScale(vehicle,i)
                    end
                end
            end

            if VehicleStatus[plate]["brakes"] <= 80 and (chance >= 41 and chance <= 60) then
                if VehicleStatus[plate]["brakes"] <= 80 and VehicleStatus[plate]["brakes"] >= 60 then
                    SetVehicleHandbrake(vehicle, true)
                    Citizen.Wait(1000)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["brakes"] <= 59 and VehicleStatus[plate]["brakes"] >= 40 then
                    SetVehicleHandbrake(vehicle, true)
                    Citizen.Wait(3000)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["brakes"] <= 39 and VehicleStatus[plate]["brakes"] >= 20 then
                    SetVehicleHandbrake(vehicle, true)
                    Citizen.Wait(5000)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["brakes"] <= 19 and VehicleStatus[plate]["brakes"] >= 6 then
                    SetVehicleHandbrake(vehicle, true)
                    Citizen.Wait(7000)
                    SetVehicleHandbrake(vehicle, false)
                else
                    SetVehicleHandbrake(vehicle, true)
                    Citizen.Wait(9000)
                    SetVehicleHandbrake(vehicle, false)
                end
            end

            if VehicleStatus[plate]["clutch"] <= 80 and (chance >= 61 and chance <= 80) then
                if VehicleStatus[plate]["clutch"] <= 80 and VehicleStatus[plate]["clutch"] >= 60 then
                    SetVehicleHandbrake(vehicle, true)
                    SetVehicleEngineOn(vehicle,0,0,1)
                    SetVehicleUndriveable(vehicle,true)
                    Citizen.Wait(50)
                    SetVehicleEngineOn(vehicle,1,0,1)
                    SetVehicleUndriveable(vehicle,false)
                    for i=1,360 do
                        SetVehicleSteeringScale(vehicle, i)
                        Citizen.Wait(5)
                    end
                    Citizen.Wait(500)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["clutch"] <= 59 and VehicleStatus[plate]["clutch"] >= 40 then
                    SetVehicleHandbrake(vehicle, true)
                    SetVehicleEngineOn(vehicle,0,0,1)
                    SetVehicleUndriveable(vehicle,true)
                    Citizen.Wait(100)
                    SetVehicleEngineOn(vehicle,1,0,1)
                    SetVehicleUndriveable(vehicle,false)
                    for i=1,360 do
                        SetVehicleSteeringScale(vehicle, i)
                        Citizen.Wait(5)
                    end
                    Citizen.Wait(750)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["clutch"] <= 39 and VehicleStatus[plate]["clutch"] >= 20 then
                    SetVehicleHandbrake(vehicle, true)
                    SetVehicleEngineOn(vehicle,0,0,1)
                    SetVehicleUndriveable(vehicle,true)
                    Citizen.Wait(150)
                    SetVehicleEngineOn(vehicle,1,0,1)
                    SetVehicleUndriveable(vehicle,false)
                    for i=1,360 do
                        SetVehicleSteeringScale(vehicle, i)
                        Citizen.Wait(5)
                    end
                    Citizen.Wait(1000)
                    SetVehicleHandbrake(vehicle, false)
                elseif VehicleStatus[plate]["clutch"] <= 19 and VehicleStatus[plate]["clutch"] >= 6 then
                    SetVehicleHandbrake(vehicle, true)
                    SetVehicleEngineOn(vehicle,0,0,1)
                    SetVehicleUndriveable(vehicle,true)
                    Citizen.Wait(200)
                    SetVehicleEngineOn(vehicle,1,0,1)
                    SetVehicleUndriveable(vehicle,false)
                    for i=1,360 do
                        SetVehicleSteeringScale(vehicle, i)
                        Citizen.Wait(5)
                    end
                    Citizen.Wait(1250)
                    SetVehicleHandbrake(vehicle, false)
                else
                    SetVehicleHandbrake(vehicle, true)
                    SetVehicleEngineOn(vehicle,0,0,1)
                    SetVehicleUndriveable(vehicle,true)
                    Citizen.Wait(250)
                    SetVehicleEngineOn(vehicle,1,0,1)
                    SetVehicleUndriveable(vehicle,false)
                    for i=1,360 do
                        SetVehicleSteeringScale(vehicle, i)
                        Citizen.Wait(5)
                    end
                    Citizen.Wait(1500)
                    SetVehicleHandbrake(vehicle, false)
                end
            end

            if VehicleStatus[plate]["fuel"] <= 80 and (chance >= 81 and chance <= 100) then
                local fuel = exports['legacyfuel']:GetFuel(vehicle)
                if VehicleStatus[plate]["fuel"] <= 80 and VehicleStatus[plate]["fuel"] >= 60 then
                    exports['legacyfuel']:SetFuel(vehicle, fuel - 2.0)
                elseif VehicleStatus[plate]["fuel"] <= 59 and VehicleStatus[plate]["fuel"] >= 40 then
                    exports['legacyfuel']:SetFuel(vehicle, fuel - 4.0)
                elseif VehicleStatus[plate]["fuel"] <= 39 and VehicleStatus[plate]["fuel"] >= 20 then
                    exports['legacyfuel']:SetFuel(vehicle, fuel - 6.0)
                elseif VehicleStatus[plate]["fuel"] <= 19 and VehicleStatus[plate]["fuel"] >= 6 then
                    exports['legacyfuel']:SetFuel(vehicle, fuel - 8.0)
                else
                    exports['legacyfuel']:SetFuel(vehicle, fuel - 10.0)
                end
            end
        end
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function GetVehicleStatusList(plate)
    local retval = nil
    if VehicleStatus[plate] ~= nil then 
        retval = VehicleStatus[plate]
    end
    return retval
end

function GetVehicleStatus(plate, part)
    local retval = nil
    if VehicleStatus[plate] ~= nil then 
        retval = VehicleStatus[plate][part]
    end
    return retval
end

function SetVehicleStatus(plate, part, level)
    TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level)
end

function SendStatusMessage(statusList)
    if statusList ~= nil then 
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message normal"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>'.. Config.ValuesLabels["engine"] ..' (engine):</strong> {1} <br><strong>'.. Config.ValuesLabels["body"] ..' (body):</strong> {2} <br><strong>'.. Config.ValuesLabels["radiator"] ..' (radiator):</strong> {3} <br><strong>'.. Config.ValuesLabels["axle"] ..' (axle):</strong> {4}<br><strong>'.. Config.ValuesLabels["brakes"] ..' (brakes):</strong> {5}<br><strong>'.. Config.ValuesLabels["clutch"] ..' (clutch):</strong> {6}<br><strong>'.. Config.ValuesLabels["fuel"] ..' (fuel):</strong> {7}</div></div>',
            args = {'Voertuig Status', round(statusList["engine"]) .. "/" .. Config.MaxStatusValues["engine"] .. " ("..BJCore.Shared.Items["advancedrepairkit"]["label"]..")", round(statusList["body"]) .. "/" .. Config.MaxStatusValues["body"] .. " ("..BJCore.Shared.Items[Config.RepairCost["body"]]["label"]..")", round(statusList["radiator"]) .. "/" .. Config.MaxStatusValues["radiator"] .. ".0 ("..BJCore.Shared.Items[Config.RepairCost["radiator"]]["label"]..")", round(statusList["axle"]) .. "/" .. Config.MaxStatusValues["axle"] .. ".0 ("..BJCore.Shared.Items[Config.RepairCost["axle"]]["label"]..")", round(statusList["brakes"]) .. "/" .. Config.MaxStatusValues["brakes"] .. ".0 ("..BJCore.Shared.Items[Config.RepairCost["brakes"]]["label"]..")", round(statusList["clutch"]) .. "/" .. Config.MaxStatusValues["clutch"] .. ".0 ("..BJCore.Shared.Items[Config.RepairCost["clutch"]]["label"]..")", round(statusList["fuel"]) .. "/" .. Config.MaxStatusValues["fuel"] .. ".0 ("..BJCore.Shared.Items[Config.RepairCost["fuel"]]["label"]..")"}
        })
    end
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 1) .. "f", num))
end

-- Menu Functions

CloseMenu = function()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

ClearMenu = function()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function noSpace(str)
    local normalisedString = string.gsub(str, "%s+", "")
    return normalisedString
end

local jobVehicle
local jobVehiclePlate
local hasVehicleOut = false
local vehiclePackages = 0
local packageObject = nil
local onJob = false
local hasStartedDeliveryJob = false

local loc

-- Notification ID's
local startNotifID = 'DELIVERY_START'
local packagesNotifID = 'DELIVERY_PACKAGES'

RegisterNetEvent('delivery:toggle')
AddEventHandler('delivery:toggle', function()
    if hasStartedDeliveryJob then 
        hasVehicleOut = false
        hasStartedDeliveryJob = false
        onJob = false
        vehiclePackages = 0
        packageObject = nil
        RemoveJobBlip()
        BJCore.Functions.Notify('Stopped deliveries', 'primary', 10000)
        return 
    end
    hasStartedDeliveryJob = true
    BJCore.Functions.Notify('Head to the delivery depot marker on the map to start', 'primary', 10000)
    startDeliveryJob()
end)

function startDeliveryJob()
    Citizen.CreateThread(function() 
        while not BJCore do Wait(1000); end
        while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
        PlayerData = BJCore.Functions.GetPlayerData()

        TriggerEvent('blipManager:toggleBlip', 'deliverydepot', true)
        while hasStartedDeliveryJob do
            --if not hasStartedDeliveryJob then 
                local playerPed = PlayerPedId()
                local playerPos = GetEntityCoords(playerPed)
        
                local dist = #(Config.JobStarts.Delivery - playerPos)
                if dist < 20 then
                    nearby = true
                    DrawMarker(2, Config.JobStarts.Delivery.x, Config.JobStarts.Delivery.y, Config.JobStarts.Delivery.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                    if dist < Config.InteractDist then
                        if not hasVehicleOut then
                            exports['core']:PersistentAlert('start', startNotifID, 'inform', 'Press [E] to Spawn Delivery Vehicle')
                            if BJCore.Functions.GetKeyPressed("E") then
                                BJCore.Functions.SpawnVehicle('boxville2', function(cbVeh)
                                    jobVehicle = cbVeh 
                                    local plate = 'GOPOST'..tostring(math.random(10, 99))
                                    SetVehicleNumberPlateText(cbVeh, plate)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), cbVeh, -1)
                                    exports['legacyfuel']:SetFuel(cbVeh, 100.0)
                                    jobVehiclePlate = GetVehicleNumberPlateText(cbVeh)
                                    TriggerEvent('keys:addNew', cbVeh, GetVehicleNumberPlateText(cbVeh))
                                    --StoreVehicleData(jobVehicle, jobVehiclePlate)
                                end, vector4(60.36, 113.83, 78.99, 162.21), true)
                                exports['core']:PersistentAlert('end', startNotifID)
                                hasVehicleOut = true
                                hasStartedDeliveryJob = true
                            end
                        else
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                exports['core']:PersistentAlert('start', 'endjob', 'inform', 'Press [E] to Store Delivery Vehicle and Stop Deliveries')
                                if BJCore.Functions.GetKeyPressed("E") then
                                    DeleteEntity(jobVehicle)
                                    hasVehicleOut = false
                                    hasStartedDeliveryJob = false
                                    onJob = false
                                    vehiclePackages = 0
                                    packageObject = nil
                                    exports['core']:PersistentAlert('end', 'endjob')
                                end
                            end                         
                        end
                    else
                        exports['core']:PersistentAlert('end', 'endjob')
                        exports['core']:PersistentAlert('end', startNotifID)
                    end
                end
            --end
            if not nearby then Citizen.Wait(750); end
            Citizen.Wait(0)
        end
        TriggerEvent('blipManager:toggleBlip', 'deliverydepot', false)
    end)

    -- Job loop
    local restocknotif = false
    local delivernotif = false
    local takeoutnotif = false
    Citizen.CreateThread(function() 
        while hasStartedDeliveryJob do
            Citizen.Wait(5)

            if hasVehicleOut then

                local ped = PlayerPedId()
                local playerPos = GetEntityCoords(ped)

                -- Display vehicle packages
                if IsPedInAnyVehicle(ped, false) and GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)) == jobVehiclePlate then
                    exports['core']:PersistentAlert('start', packagesNotifID, 'inform', 'Vehicle Packages: '..vehiclePackages)
                else
                    exports['core']:PersistentAlert('end', packagesNotifID)
                end

                -- Restocking vehicle concept.
                if vehiclePackages <= 0 then
                    if not restocknotif then
                        restocknotif = true
                        exports['core']:PersistentAlert('start', 'restock', 'inform', "Press [E] at the orange marker at the GoPostal Hub to restock deliveries")
                    end
                    onJob = false
                    for k,v in pairs(Config.DeliveryRestock) do
                        local dist = #(playerPos - Config.DeliveryRestock[k])
                        if dist < Config.InteractDist + 15.0 and IsPedInAnyVehicle(ped) then
                            DrawMarker(27, 64.58, 125.55, 78.252, 0,0,0,0,0,0,3.0,3.0,1.0,255,165,0,165,0,0,0,0)
                            if BJCore.Functions.GetKeyPressed("E") then
                                vehiclePackages = math.random(8,15)
                                JobStart()
                            end
                        end
                    end
                else
                    restocknotif = false
                    exports['core']:PersistentAlert('end', 'restock')
                end

                -- Remove / Put Package Back in
                if onJob and packageObject == nil then
                    if #(GetEntityCoords(JobVehicle) - GetEntityCoords(PlayerPedId())) > 5.0 then
                        local vehFront = VehicleInFront()
                         local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
                         local vehicle = GetClosestVehicle(x, y, z, 5.0, 0, 71)
                         if vehFront > 0 and vehicle ~= nil then
                            --print('~b~Press ~g~E ~b~To Grab A Package From Trunk')
                            if BJCore.Functions.GetKeyPressed("E") then
                               SetVehicleDoorOpen(vehFront, 2, false, false)
                               SetVehicleDoorOpen(vehFront, 3, false, false)
                               exports['core']:PersistentAlert('end', 'takeout')
                               Citizen.Wait(200)
                               LoadModel("prop_cs_cardbox_01")
                                local pos = GetEntityCoords(PlayerPedId(), false)
                                packageObject = CreateObject(GetHashKey("prop_cs_cardbox_01"), pos.x, pos.y, pos.z, true, true, true)
                                AttachEntityToEntity(packageObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
                                LoadAnim("anim@heists@box_carry@")
                                TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                            end
                        end
                    end
                    if not IsPedInAnyVehicle(PlayerPedId(), false) then
                        if not takeoutnotif then
                            exports['core']:PersistentAlert('start', 'takeout', 'inform', "Press [E] at the rear of the vehicle to take package out")
                        end
                        -- local d1,d2 = GetModelDimensions(GetEntityModel(JobVehicle))
                        -- local moveto = GetOffsetFromEntityInWorldCoords(JobVehicle, 0.0,d2["y"]+0.5,0.0)
                        -- if packageObject == nil then
                        --     BJCore.Functions.DrawText3D(moveto["x"],moveto["y"],moveto["z"],"[~g~E~s~] Move here to take out package", 0.7)
                        -- end
                    end
                elseif onJob and packageObject ~= nil and #(GetEntityCoords(JobVehicle) - GetEntityCoords(PlayerPedId())) > 5.0 then

                    local vehFront = VehicleInFront()
                    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
                    local vehicle = GetClosestVehicle(x, y, z, 5.0, 0, 71)
                    if vehFront > 0 and vehicle ~= nil then
                        -- local d1,d2 = GetModelDimensions(GetEntityModel(JobVehicle))
                        -- local moveto = GetOffsetFromEntityInWorldCoords(JobVehicle, 0.0,d2["y"]-0.5,0.0)
                        -- if packageObject == nil then
                        --     BJCore.Functions.DrawText3D(moveto["x"],moveto["y"],moveto["z"],"Move here to take out package [~g~E~s~]", 0.7)
                        -- end
                        --print('~b~Press ~g~E ~b~To Put The Package Back In Trunk')
                        if BJCore.Functions.GetKeyPressed("E") then
                            DeleteObject(packageObject)
                            packageObject = nil
                            StopAnimTask(PlayerPedId(), "anim@heists@box_carry@", "idle", 1.0)                        
                            Citizen.Wait(200)
                            SetVehicleDoorShut(vehFront, 2, false)
                            SetVehicleDoorShut(vehFront, 3, false)
                        end
                    end
                end

                -- TODO: Work on this.
                if onJob then
                    local location = vector3(Config.DeliveryDestinations[loc].x,Config.DeliveryDestinations[loc].y,Config.DeliveryDestinations[loc].z)
                    local deliveryDist = #(playerPos - location)
                    if deliveryDist < 10.0 then
                        DrawMarker(21, Config.DeliveryDestinations[loc].x,Config.DeliveryDestinations[loc].y,Config.DeliveryDestinations[loc].z + 2.0, 0, 0, 0, 180.0, 0, 0.0, 1.0, 1.0, 1.0, 255, 165, 0, 165, true, true, 2, false)
                    end
                    if deliveryDist < Config.InteractDist and packageObject ~= nil then
                        if not delivernotif then
                            BJCore.Functions.DrawText3D(Config.DeliveryDestinations[loc].x,Config.DeliveryDestinations[loc].y,Config.DeliveryDestinations[loc].z, "[~g~E~s~] Deliver")
                        end
                        if BJCore.Functions.GetKeyPressed("E") then
                            DeliverPackage()
                        end
                    end
                end
            else
                exports['core']:PersistentAlert('end', 'takeout')
                exports['core']:PersistentAlert('end', packagesNotifID)
                Citizen.Wait(500)
            end
        end
    end)
end

function JobStart() 
    onJob = true
    if loc == nil then
        area = math.random(1,10)
        if area == 1 then 
    		loc = math.random(1,56)
    	end
    	if area == 2 then 
    		loc = math.random(57,102)
    	end
    	if area == 3 then 
    		loc = math.random(103,148)
    	end
    	if area == 4 then 
    		loc = math.random(149,201)
    	end
    	if area == 5 then 
    		loc = math.random(202,255)
    	end
    	if area == 6 then 
    		loc = math.random(256,285)	
    	end
    	if area == 7 then 
    		loc = math.random(286,329)
    	end
    	if area == 8 then 
    		loc = math.random(330,352)
    	end
    	if area == 9 then 
    		loc = math.random(253,373)
    	end
    	if area == 10 then 
    		loc = math.random(374,392)
        end
    end
    SetJobBlip(Config.DeliveryDestinations[loc].x,Config.DeliveryDestinations[loc].y,Config.DeliveryDestinations[loc].z)
    BJCore.Functions.Notify('Drive to the Marked Location', "primary")
end

function DeliverPackage()
    delivernotif = true
    --payment = payment + math.floor(Config.DeliveryDestinations[loc].money) 
    TriggerServerEvent('delivery:reward', loc)

	if vehiclePackages == 0 then
		onJob = false
        -- Notification
		RemoveJobBlip()
    else
        loc = nil
        DeleteObject(packageObject)
        packageObject = nil
        StopAnimTask(PlayerPedId(), "anim@heists@box_carry@", "idle", 1.0)
        SetVehicleDoorShut(jobVehicle, 2, false)
        SetVehicleDoorShut(jobVehicle, 3, false)        
        vehiclePackages = vehiclePackages - 1
        if vehiclePackages == 0 then
            RemoveJobBlip()
        else
            JobStart()
        end
	end
end

function SetJobBlip(x,y,z)
    if DoesBlipExist(missionblip) then RemoveBlip(missionblip) end
    missionblip = AddBlipForCoord(x,y,z)
    SetBlipSprite(missionblip, 164)
    SetBlipColour(missionblip, 53)
    SetBlipRoute(missionblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destination")
    EndTextCommandSetBlipName(missionblip)
end

function RemoveJobBlip()
    if DoesBlipExist(missionblip) then RemoveBlip(missionblip) end
end

-- -- Run this because the callback doesn't like to store things outside of it :/
-- function StoreVehicleData(vehicle, plate) 
--     jobVehicle = vehicle
--     print(jobVehicle)
--     jobVehiclePlate = plate
-- end

function vecDist(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(((v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) ))
end

function VehicleInFront()
 local ped = PlayerPedId()
 local pos = GetEntityCoords(ped)
 local entityWorld = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
 local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, ped, 0)
 local a, b, c, d, result = GetRaycastResult(rayHandle) 
 return result 
end

function LoadModel(model)
  RequestModel(model)

  while not HasModelLoaded(model) do
    Citizen.Wait(10)
  end
end

function LoadAnim(animDict)
  RequestAnimDict(animDict)

  while not HasAnimDictLoaded(animDict) do
    Citizen.Wait(10)
  end
end
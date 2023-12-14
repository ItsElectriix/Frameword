local CurrentPlate = nil
local JobsDone = 0
local NpcOn = false
local CurrentLocation = {}
local CurrentBlip = nil
local LastVehicle = 0
local VehicleSpawned = false

local selectedVeh = nil

local CurrentlyTowedVehicle = nil
AddEventHandler("mech:client:menuFlatbed", function()
	local plyPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(plyPed, true)

	local towmodel = GetHashKey('flatbed')
	local isVehicleTow = IsVehicleModel(vehicle, towmodel)

	if isVehicleTow then
		local coordA = GetEntityCoords(plyPed, 1)
		local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 5.0, 0.0)
		local targetVehicle = getVehicleInDirection(coordA, coordB)

		if not CurrentlyTowedVehicle then
			NetworkRequestControlOfEntity(targetVehicle)
			CleanDetachedVehicles()
			if targetVehicle ~= 0 then
				if vehicle ~= targetVehicle then
					towanim(targetVehicle)
			        exports['mythic_progbar']:Progress({
			            name = "flatbed_veh",
			            duration = 8000,
			            label = "Tasking",
			            canCancel = true,
			            controlDisables = {
			                disableMovement = true,
			                disableCarMovement = true,
			                disableMouse = false,
			                disableCombat = true,
			                disableInteract = true
			            },
			        }, function(status)
			            if not status then
							ClearPedTasksImmediately(plyPed)
							local driverPed = GetPedInVehicleSeat(targetVehicle, -1)
							if not IsPedInAnyVehicle(plyPed, true) and not DoesEntityExist(driverPed) then

								if #(GetEntityCoords(targetVehicle) - GetEntityCoords(vehicle)) < 15.0 and GetEntitySpeed(targetVehicle < 3.0) then
									SetEntityAsMissionEntity(targetVehicle,true,true)
									NetworkRequestControlOfEntity(vehicle)
									Wait(20)											
									AttachEntityToEntity(targetVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.01, -2.8, 1.1, 0, 0, 0, 1, 1, 0, 1, 0, 1)
									CurrentlyTowedVehicle = targetVehicle
									exports['mythic_notify']:SendAlert('success', "Attach success")
									if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
								end
							end         
			            else
			                ClearPedTasksImmediately(plyPed)
			                BJCore.Functions.Notify("Cancelled", "error")
			                ClearAllPedProps(plyPed)
			            end
			        end)					
				else
					exports['mythic_notify']:SendAlert('error', "Cant attach own vehicle")
				end
			else
				exports['core']:SendAlert('error', "Target Vehicle not found")
			end
		else
			NetworkRequestControlOfEntity(targetVehicle)
			NetworkRequestControlOfEntity(CurrentlyTowedVehicle)
			local ctvehicleID = NetworkGetNetworkIdFromEntity(CurrentlyTowedVehicle)				
			AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), -0.25, -10.0, 1.1, 0, 0, 0, false, false, false, false, 0, true)
			DetachEntity(CurrentlyTowedVehicle, true, true)
			Citizen.Wait(150)
			SetVehicleOnGroundProperly(CurrentlyTowedVehicle)
			CurrentlyTowedVehicle = nil
			exports['core']:SendAlert('success', "Dettach success")
		end
	else
		print("no last tow vehicle model")
	end
end)

function CleanDetachedVehicles()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local handle, vehicleFound = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(vehicleFound)
        local distance = GetDistanceBetweenCoords(plyPos, pos, true)
        if distance < 15.0 then

      		if IsEntityAttached(vehicleFound) then
        		DetachEntity(vehicleFound, true, true)
				local drop = GetOffsetFromEntityInWorldCoords(vehicleFound, 0.0,-5.5,0.0)
				DetachEntity(vehicleFound, true, true)
				SetEntityCoords(vehicleFound,drop)
			end

        end
        success, vehicleFound = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
end

function towanim(veh)
    local plyPed = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do Citizen.Wait(0); end

    TaskTurnPedToFaceEntity(plyPed, veh, 1.0)
    Citizen.Wait(1500)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 10.0, 'towtruck', 0.2)
    if not IsEntityPlayingAnim(plyPed, "mini@repair", "fixing_a_player", 3) then
        TaskPlayAnim(plyPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
    end
end

local cleanReq = {"cleaningkit"}

AddEventHandler("mech:client:menuOnClean", function(isMech)
	if PlayerData.items and not hasItem(cleanReq) then BJCore.Functions.Notify("You don't have cleaning items to do this action", "error") return; end
    local plyPed = PlayerPedId()
    local coordA = GetEntityCoords(plyPed)
    local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 100.0, 0.0)
    local targetVehicle = GetVehiclePedIsIn(plyPed, false)
    if targetVehicle == nil or targetVehicle == 0 then targetVehicle = getVehicleInDirection(coordA, coordB); end
    if targetVehicle ~= 0 and IsVehicleStopped(targetVehicle) then	
        exports['mythic_progbar']:Progress({
            name = "clean_veh",
            duration = math.random(15000,25000),
            label = "Cleaning",
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
                disableInteract = true
            },
			animation = {task = 'WORLD_HUMAN_MAID_CLEAN'}
        }, function(status)
            if not status then
                --ClearPedTasks(plyPed)
                TriggerServerEvent("bj_gameplay:requestClean", VehToNet(targetVehicle))
                ClearAllPedProps(plyPed)
                if math.random(100) > 70 and not isMech then
                	TriggerServerEvent("mech:server:removeItem", "cleaningkit", 1)
                end                
            else
                ClearPedTasksImmediately(plyPed)
                BJCore.Functions.Notify("Cleaning cancelled", "error")
                ClearAllPedProps(plyPed)
            end
        end)
    else
        if targetVehicle ~= 0 and not IsVehicleStopped(targetVehicle) then
            exports['core']:SendAlert('error', 'Vehicle is moving', 2500) 
        else
            exports['core']:SendAlert('error', 'Vehicle not found. Try again?', 2500)
        end
    end   
end)

local recoveryReq = {
    "repairkit",
    "advancedrepairkit",
    "bikerepairkit",
}

AddEventHandler("mech:client:menuOnRepair", function()
	if PlayerData.items and hasItem(recoveryReq) then
		TriggerEvent("mech:client:UseRepairItem", false, true, false)
	else
		BJCore.Functions.Notify("You don't have any repir kit items to do this action", "error")
	end
end)

local reapiring, fixingvehicle = false, false
RegisterNetEvent("mech:client:UseRepairItem")
AddEventHandler("mech:client:UseRepairItem", function(isAdvanced, isRecovery, isBike)
    local plyPed = PlayerPedId()
    local coordA = GetEntityCoords(plyPed)
    local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 100.0, 0.0)
    local targetVehicle = GetVehiclePedIsIn(plyPed, false)
    if targetVehicle == nil or targetVehicle == 0 then targetVehicle = getVehicleInDirection(coordA, coordB); end
    if targetVehicle ~= 0 and IsVehicleStopped(targetVehicle) then
        if IsThisModelABike(GetEntityModel(targetVehicle)) and not isBike then BJCore.Functions.Notify("You can't use this repair kit on a bike", "error") return; end

        local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
        local moveto = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0,d2["y"]+0.5,0.0)
        if IsThisModelABike(GetEntityModel(targetVehicle))  then 
            moveto = GetEntityCoords(targetVehicle)
            if GetVehiclePedIsIn(plyPed, false) ~= nil then
                BJCore.Functions.Notify("Get off the bike to repair", "error")
                Citizen.Wait(1000)
            end
        end
        local dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
        local count = 1000

        while dist > 1.0 and count > 0 do
            dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
            Citizen.Wait(1)
            count = count - 1
            BJCore.Functions.DrawText3D(moveto["x"],moveto["y"],moveto["z"],"Move here to repair", 0.7)
        end

        if reapiring then return; end
        reapiring = true

        if dist < 1.0 then
            fixingvehicle = true

            local repairlength = 1000
            if IsThisModelABike(GetEntityModel(targetVehicle)) then
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 4) + 2000
            elseif isAdvanced then
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 5) + 2000
            else
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 3) + 2000
            end
            TaskTurnPedToFaceEntity(plyPed, targetVehicle, 1.0)
            Citizen.Wait(1000)
            SetVehicleDoorOpen(targetVehicle, 4, 0, 0)
            exports['mythic_progbar']:Progress({
                name = "repair_kit",
                duration = repairlength,
                label = "Repairing",
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                    disableInteract = true
                },
                animation = {
                    animDict = "mini@repair",
                    anim = "fixing_a_player",
                }
            }, function(status)
                if not status then
                    ClearPedTasksImmediately(plyPed)
                    SetVehicleDoorShut(targetVehicle, 4, 1, 1)
                    TriggerServerEvent('mech:server:requestRepair', VehToNet(targetVehicle), isAdvanced)
                    exports['core']:SendAlert('success', 'Vehicle repaired', 2500)
                    DamageRandomComponent(targetVehicle)
                    if isAdvanced then
                    	DamageRandomComponent(targetVehicle)
                        TriggerServerEvent("mech:server:removeItem", "advancedrepairkit", 1)
                    else
                        if math.random(100) > 80 and not isRecovery then
                            if isBike then
                                TriggerServerEvent("mech:server:removeItem", "bikerepairkit", 1)
                            else
                                TriggerServerEvent("mech:server:removeItem", "repairkit", 1)
                            end
                        end
                        if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
                    end
                else
                    ClearPedTasksImmediately(plyPed)
                    SetVehicleDoorShut(targetVehicle, 4, 1, 1)
                    exports['core']:SendAlert('error', 'Repair cancelled', 2500)
                end
            end)
        end
        fixingvehicle = false
    else
        if targetVehicle ~= 0 and not IsVehicleStopped(targetVehicle) then
            exports['core']:SendAlert('error', 'Vehicle is moving', 2500) 
        else
            exports['core']:SendAlert('error', 'Vehicle not found. Try again?', 2500)
        end              
    end
    reapiring = false
end)

RegisterNetEvent('mech:client:doRepair')
AddEventHandler('mech:client:doRepair', function(veh, isAdvanced)
    local targetVehicle = NetToVeh(veh)
    if isAdvanced then
        if GetVehicleEngineHealth(targetVehicle) < 900.0 then
            SetVehicleEngineHealth(targetVehicle, 900.0)
        end
        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
            SetVehicleBodyHealth(targetVehicle, 945.0)
        end

    else

        if GetVehicleEngineHealth(targetVehicle) < 200.0 then
            SetVehicleEngineHealth(targetVehicle, 200.0)
        end
        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
            SetVehicleBodyHealth(targetVehicle, 945.0)
        end
    end                    

    for i = 0, 5 do
        SetVehicleTyreFixed(targetVehicle, i) 
    end
end)

local unlockReq = {
    "lockpick",
    "advancedlockpick",
}

local openingDoor = false
AddEventHandler("mech:client:menuOnUnlock", function()
	if PlayerData.items and hasItem(unlockReq) then
	    local vehicle = BJCore.Functions.GetClosestVehicle()
	    if vehicle ~= nil and vehicle ~= 0 then
	        local vehpos = GetEntityCoords(vehicle)
	        local plyPed = PlayerPedId()
	        local pos = GetEntityCoords(plyPed)
	        if #(pos - vehpos) < 1.5 then
	            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
	            if (vehLockStatus > 1) then
	                LockpickDoorAnim()
		            exports['mythic_progbar']:Progress({
		                name = "unlock_vehicle",
		                duration = 60000,
		                label = "Unlocking",
		                canCancel = true,
		                controlDisables = {
		                    disableMovement = true,
		                    disableCarMovement = true,
		                    disableMouse = false,
		                    disableCombat = true,
		                    disableInteract = true
		                },
		            }, function(status)
		                if not status then
		                    ClearPedTasksImmediately(plyPed)
		                    openingDoor = false
		                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
		                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
		                    SetVehicleDoorsLocked(vehicle, 0)
		                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
		                    TriggerServerEvent('vehiclelock:lockPick', GetVehicleNumberPlateText(vehicle))
		                    BJCore.Functions.Notify("Door open")
		                else
		                    ClearPedTasksImmediately(plyPed)
		                    openingDoor = false
		                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
		                    exports['core']:SendAlert('error', 'Unlocking cancelled', 2500)
		                end
		            end)
	                if math.random(100) <= 50 then TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200); end
	            end
	        end
	    end
	else
		BJCore.Functions.Notify("You don't have any items required to do this action", "error")
	end
end)

function LockpickDoorAnim()
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            if not openingDoor then
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)   
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = #(coordFrom - GetEntityCoords(vehicle))
    
    if distance > 3 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

local DamageComponents = {
    "radiator",
    "axle",
    "clutch",
	"fuel",
	"brakes",
}

function DamageRandomComponent(vehicle)
	local dmgFctr = math.random() + math.random(0, 2)
	local randomComponent = DamageComponents[math.random(1, #DamageComponents)]
	local randomDamage = (math.random() + math.random(0, 1)) * dmgFctr
	SetVehicleStatus(GetVehicleNumberPlateText(vehicle), randomComponent, GetVehicleStatus(GetVehicleNumberPlateText(vehicle), randomComponent) - randomDamage)
end

function hasItem(tab)
	if not PlayerData then return false; end
	local ret = false
	for k,v in pairs(PlayerData.items) do
        for _,item in pairs(tab) do
        	if v.name == item then
        		ret = true
        		break
        	end
        end
	end
	return ret
end

RegisterNetEvent("mech:client:attemptFakePlate", function(plate)
    local plyPed = PlayerPedId()
    if IsPedInAnyVehicle(plyPed, false) then return; end
    local coordA = GetEntityCoords(plyPed, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 5.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)
    if targetVehicle ~= 0 then
        if (Entity(targetVehicle).state.plate and Entity(targetVehicle).state.plate ~= nil) then
            if exports["vehiclelock"]:hasKey(targetVehicle) then
                if (isCloseToHood(targetVehicle, plyPed, 2.0) or isCloseToBoot(targetVehicle, plyPed, 2.0)) then
                    if not Entity(targetVehicle).state.fakeplate or Entity(targetVehicle).state.fakeplate == nil then
                        TriggerServerEvent("BJCore:Server:RemoveItem", "platekit", 1)
                        exports['mythic_progbar']:Progress({
                            name = "applying_fake_plate",
                            duration = 10000,
                            label = "Applying",
                            canCancel = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                                disableInteract = true
                            },
                            animation = {
                                animDict = "mini@repair",
                                anim = "fixing_a_player",
                            }
                        }, function(status)
                            if not status then
                                TriggerServerEvent("mech:server:applyFakePlate", VehToNet(targetVehicle), plate)
                            else
                                ClearPedTasks(PlayerPedId())
                                BJCore.Functions.Notify("Cancelled", "error")
                            end
                        end)
                    else
                        BJCore.Functions.Notify("Cannot do this", "error")
                    end
                else
                    BJCore.Functions.Notify("Move to front or rear of vehicle")
                end
            else
                BJCore.Functions.Notify("You can't do this to a vehicle you don't have keys to", "error")
            end
        else
            BJCore.Functions.Notify("You can't use this on this vehicle", "error")
        end
    else
        BJCore.Functions.Notify("Target vehicle not found", "error")
    end
end)

RegisterNetEvent("mech:client:applyFakePlate", function(vehicle, plate)
    vehicle = NetToVeh(vehicle)
    local rndPlateType = math.random(1,6)-1
    SetVehicleNumberPlateTextIndex(vehicle, rndPlateType)
    SetVehicleNumberPlateText(vehicle, plate)
    TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'fakeplate', plate)
    TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'fakeplateindex', rndPlateType)
end)

AddEventHandler("mech:client:attemptRemovePlate", function()
    local plyPed = PlayerPedId()
    if IsPedInAnyVehicle(plyPed, false) then return; end
    local coordA = GetEntityCoords(plyPed, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 5.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)
    if targetVehicle ~= 0 then
        if (isCloseToHood(targetVehicle, plyPed, 2.0) or isCloseToBoot(targetVehicle, plyPed, 2.0)) then
            if (Entity(targetVehicle).state.fakeplate and Entity(targetVehicle).state.fakeplate ~= nil) then
                exports['mythic_progbar']:Progress({
                    name = "removing_fake_plate",
                    duration = 10000,
                    label = "Removing",
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                        disableInteract = true
                    },
                    animation = {
                        animDict = "mini@repair",
                        anim = "fixing_a_player",
                    }
                }, function(status)
                    if not status then
                        TriggerServerEvent("mech:server:removeFakePlate", VehToNet(targetVehicle))
                    else
                        ClearPedTasks(PlayerPedId())
                        BJCore.Functions.Notify("Cancelled", "error")
                    end
                end)
            end
        else
            BJCore.Functions.Notify("Move to front or rear of vehicle")
        end
    else
        BJCore.Functions.Notify("Target vehicle not found", "error")
    end
end)

RegisterNetEvent("mech:client:removeFakePlate", function(veh)
    veh = NetToVeh(veh)
    SetVehicleNumberPlateTextIndex(veh, Entity(veh).state.plateindex)
    SetVehicleNumberPlateText(veh, Entity(veh).state.plate)
    TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(veh), 'fakeplate', nil)
    TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(veh), 'fakeplateindex', nil)
end)

local ModelData = {}

function GetModelData(pEntity, pModel)
    if ModelData[pModel] then return ModelData[pModel] end

    local modelInfo = {}

    local coords = getTrunkOffset(pEntity)
    local boneCoords, engineCoords = GetWorldPositionOfEntityBone(pEntity, GetEntityBoneIndexByName(pEntity, 'engine'))

    if #(boneCoords - coords) <= 2.0 then
        engineCoords = coords
        modelInfo = { engine = { position = 'trunk', door = 4 }, trunk = { position = 'front', door = 5 } }
    else
        engineCoords = getFrontOffset(pEntity)
        modelInfo = { engine = { position = 'front', door = 4 }, trunk = { position = 'trunk', door = 5 } }
    end

    local hasBonnet = DoesVehicleHaveDoor(pEntity, 4)
    local hasTrunk = DoesVehicleHaveDoor(pEntity, 5)

    if hasBonnet then
        local bonnetCoords = GetWorldPositionOfEntityBone(pEntity, GetEntityBoneIndexByName(pEntity, 'bonnet'))
        
        if #(engineCoords - bonnetCoords) <= 2.0 then
            modelInfo.engine.door = 4
            modelInfo.trunk.door = hasTrunk and 5 or 3
        elseif hasTrunk then
            modelInfo.engine.door = 5
            modelInfo.trunk.door = 4
        end
    elseif hasTrunk then
        local bootCoords = GetWorldPositionOfEntityBone(pEntity, GetEntityBoneIndexByName(pEntity, 'boot'))

        if #(engineCoords - bootCoords) <= 2.0 then
            modelInfo.engine.door = 5
        end
    end

    ModelData[pModel] = modelInfo

    return modelInfo
end

function getTrunkOffset(pEntity)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(pEntity))
    return GetOffsetFromEntityInWorldCoords(pEntity, 0.0, minDim.y - 0.5, 0.0)
end

function getFrontOffset(pEntity)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(pEntity))
    return GetOffsetFromEntityInWorldCoords(pEntity, 0.0, maxDim.y + 0.5, 0.0)
end

function isCloseToTrunk(pEntity, pPlayerPed, pDistance, pMustBeOpen)
    return #(getTrunkOffset(pEntity) - GetEntityCoords(pPlayerPed)) <= (pDistance or 1.0) and GetVehicleDoorLockStatus(pEntity) == 1 and (not pMustBeOpen or GetVehicleDoorAngleRatio(pEntity, 5) >= 0.1)
end

function isCloseToHood(pEntity, pPlayerPed, pDistance, pMustBeOpen)
    return #(getFrontOffset(pEntity) - GetEntityCoords(pPlayerPed)) <= (pDistance or 1.0) and GetVehicleDoorLockStatus(pEntity) == 1 and (not pMustBeOpen or GetVehicleDoorAngleRatio(pEntity, 4) >= 0.1)
end

function isCloseToEngine(pEntity, pPlayerPed, pDistance, pModel)
    local model = pModel or GetEntityModel(pEntity)
    local modelData = GetModelData(pEntity, model)

    local playerCoords = GetEntityCoords(pPlayerPed)

    local engineCoords = modelData.engine.position == 'front' and getFrontOffset(pEntity) or getTrunkOffset(pEntity)

    return #(engineCoords - playerCoords) <= pDistance
end

function isCloseToBoot(pEntity, pPlayerPed, pDistance, pModel)
    local model = pModel or GetEntityModel(pEntity)
    local modelData = GetModelData(pEntity, model)

    local playerCoords = GetEntityCoords(pPlayerPed)

    local engineCoords = modelData.trunk.position == 'front' and getFrontOffset(pEntity) or getTrunkOffset(pEntity)

    return #(engineCoords - playerCoords) <= pDistance
end
local ffires = {}
RegisterNetEvent('utils:btf')
AddEventHandler("utils:btf", function()
	exports['core']:SendAlert('success', "Let's go back to the future! Get to 88MPH.")
	Citizen.CreateThread(function()
		while GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), true)) * 2.236936 < 88 do
			Wait(50)
		end
		
		local count = 0
		
		while count < 60 do
			if count == 44 then
				TriggerServerEvent("TBH:SyncAll", "TBH:EndBtf", GetEntityCoords(PlayerPedId()))
			end
			Wait(10)
			SetEntityInvincible(PlayerPedId(), true)
			local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), -1.0, -1.0, 0.0))
			
			--table.insert(fires, StartScriptFire(x, y, z, 1, true))
			--table.insert(fires, StartScriptFire(x2, y2, z2, 1, true))
			TriggerServerEvent("TBH:SyncAll", "TBH:SyncFire", {x, y, z})
			x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.0, -1.0, 0.0))
			TriggerServerEvent("TBH:SyncAll", "TBH:SyncFire", {x, y, z})
			count = count + 2
		end
		
		local WaypointHandle = GetFirstBlipInfoId(8)

        if DoesBlipExist(WaypointHandle) then
            local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

            for height = 1, 1000 do
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

                local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

                if foundGround then
                    SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

                    break
                end

                Citizen.Wait(5)
            end
        end
	end)
end)

RegisterNetEvent("TBH:EndBtf")
AddEventHandler("TBH:EndBtf", function(x, y, z)
	ForceLightningFlash()
	local plyPos = GetEntityCoords(PlayerPedId())
	if GetDistanceBetweenCoords(x, y, z, plyPos.x, plyPos.y, plyPos.z) < 100 then
		Citizen.CreateThread(function()
			AnimpostfxPlay("Dont_tazeme_bro", 1000, false)
			ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.4)
			Wait(1000)
			AnimpostfxStop("Dont_tazeme_bro")
			local amp = 0.4
			while amp > 0 do
				Wait(100)
				amp = amp - 0.05
				SetGameplayCamShakeAmplitude(amp)
			end
			StopGameplayCamShaking(true)
			Wait(60000)
			while #ffires > 0 do
				Wait(500)
				RemoveScriptFire(table.remove(ffires, 1))
				if #ffires > 0 then
					RemoveScriptFire(table.remove(ffires, 1))
				end
			end
		end)
	end
end)

RegisterNetEvent("TBH:SyncFire")
AddEventHandler("TBH:SyncFire", function(x, y, z)
	if #ffires > 20 then
		RemoveScriptFire(table.remove(ffires, 1))
	end
	table.insert(ffires, StartScriptFire(x, y, z, 1, true))
end)

local posgun = false
RegisterNetEvent('utils:posgun')
AddEventHandler("utils:posgun", function()
	posgun = not posgun
	if not posgun then
		exports['core']:SendAlert('success', "PosGun disabled")
		return
	end
	exports['core']:SendAlert('success', "PosGun enabled")
	Citizen.CreateThread(function()
		while posgun do
			Wait(0)
			if IsPlayerFreeAiming(PlayerId()) then
				local result, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
				if IsPedShooting(PlayerPedId()) then
					local c = GetEntityCoords(entity)
					local r = GetEntityHeading(entity)
					local modelHash = GetEntityModel(entity)
					local modelName = GetHashNameForProp(entity, 0, 0, 0)
					if modelName == 0 then modelName = "N/A" end
					if modelHash == 0 then TriggerEvent("chatMessage", "[POSGUN]", "#ff0000", "No hash was found for the shot entity.") else
					    TriggerEvent("chatMessage", "[POSGUN]", "#ffffff", "Name: " .. modelName .. " | Hash: "..modelHash.." | Pos: "..string.format("%.3f", c.x)..", "..string.format("%.3f", c.y)..", "..string.format("%.3f", c.z).." | Rotation: "..string.format("%.3f", r))
					    RequestNamedPtfxAsset("scr_rcbarry2")
					    SetPtfxAssetNextCall("scr_rcbarry2")
					    StartParticleFxNonLoopedOnEntity("scr_clown_appears", -1, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)  
					end
				end
			end
		end
	end)
end)

local delgun = false
RegisterNetEvent('utils:delgun')
AddEventHandler("utils:delgun", function()
	delgun = not delgun
	if not delgun then
		exports['core']:SendAlert('error', "DelGun disabled")
		return
	end
	exports['core']:SendAlert('success', "DelGun enabled")
	TriggerServerEvent('tbh_util:log', _source, 'Toggle Delgun', "Toggle Delgun")
	Citizen.CreateThread(function()
		while delgun do
			Wait(0)
			if IsPlayerFreeAiming(PlayerId()) then
				local result, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
				if IsPedShooting(PlayerPedId()) then
					SetEntityAsMissionEntity(entity, true, true)
					NetworkRequestControlOfEntity(entity)
					local count = 0
					while not NetworkHasControlOfEntity(entity) and count < 10 do
						count = count + 1
						print(count)
						Wait(100)
					end
					local modelHash = GetEntityModel(entity)
					DeleteEntity(entity)
					TriggerEvent("chatMessage", "[DELGUN]", "#ffffff", "Hash: "..modelHash)
				end
			end
		end
	end)
end)

RegisterCommand("heading", function(source, args, rawCommand)
    local heading = GetEntityHeading(PlayerPedId())
    exports['core']:SendAlert('success', "Current Heading: "..tostring(heading))
end)

-- RegisterCommand("attach", function(source, args, rawCommand)
-- 	if HasPermission(clientPermissions.attach) then
-- 		if #args > 0 then
-- 			local currWeapon = GetSelectedPedWeapon(PlayerPedId())
-- 			local found = false
-- 			for k,v in ipairs(ESX.GetWeaponList()) do
-- 				local weaponHash = GetHashKey(v.name)
	
-- 				if currWeapon == weaponHash then
-- 					found = true
-- 					TriggerServerEvent("TBH:AddComponentToWeapon", v.name, args[1])
-- 				end
-- 			end
			
-- 			if not found then
-- 				exports['core']:SendAlert('error', "Weapon not found")
-- 			end
-- 		else
-- 			exports['core']:SendAlert('error', "Input component")
-- 		end
-- 	end
-- end)

-- RegisterCommand("detach", function(source, args, rawCommand)
-- 	if HasPermission(clientPermissions.attach) then
-- 		if #args > 0 then
-- 			local currWeapon = GetSelectedPedWeapon(PlayerPedId())
-- 			local found = false
-- 			for k,v in ipairs(ESX.GetWeaponList()) do
-- 				local weaponHash = GetHashKey(v.name)
	
-- 				if currWeapon == weaponHash then
-- 					found = true
-- 					TriggerServerEvent("TBH:RemoveComponentToWeapon", v.name, args[1])
-- 				end
-- 			end
			
-- 			if not found then
-- 				exports['core']:SendAlert('error', "Weapon not found")
-- 			end
-- 		else
-- 			exports['core']:SendAlert('error', "Input component")
-- 		end
-- 	end
-- end)

-- RegisterCommand("tint", function(source, args, rawCommand)
-- 	if HasPermission(clientPermissions.tint) then
-- 		if #args > 0 and tonumber(args[1]) ~= nil then
-- 			local tintNum = tonumber(args[1])
-- 			local weaponHash = GetSelectedPedWeapon(PlayerPedId())
-- 			if tintNum < GetWeaponTintCount(weaponHash) then
-- 				SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), tintNum)
-- 				exports['core']:SendAlert('success', "Tint set: "..tostring(tintNum))
-- 			else
-- 				exports['core']:SendAlert('error', "Tint does not exist")
-- 			end
-- 		end
-- 	end
-- end)

RegisterNetEvent('utils:setped')
AddEventHandler("utils:setped", function()
	if args[1] ~= nil then
		local model = GetHashKey(args[1])
		if IsModelInCdimage(model) and IsModelValid(model) then
    		RequestModel(model)
    		while not HasModelLoaded(model) do
        		Citizen.Wait(0)
    		end
    		SetPlayerModel(PlayerId(), model)
			TriggerServerEvent('TBH:AddSyncedPed', args[1])
    		if skin ~= "mp_f_freemode_01" and skin ~= "mp_m_freemode_01" then 
        		SetPedRandomComponentVariation(PlayerPedId(), true)
    		else
        		SetPedComponentVariation(PlayerPedId(), 11, 0, 240, 0)
        		SetPedComponentVariation(PlayerPedId(), 8, 0, 240, 0)
        		SetPedComponentVariation(PlayerPedId(), 11, 6, 1, 0)
    		end
			SetModelAsNoLongerNeeded(model)
			exports['core']:SendAlert('success', "Ped model set")
			TriggerServerEvent('tbh_util:log', _source, 'Ped Changed', "Changed ped")
		else
			exports['core']:SendAlert('success', "Ped model not found")
		end
	else
		exports['core']:SendAlert('success', "Ped key needed")
	end
end)

RegisterCommand('livery', function(source, args, rawCommand)
    local livery = args[1]
	
	if IsPedInAnyVehicle(PlayerPedId(), false) then
	
		local vehicle = GetVehiclePedIsUsing(PlayerPedId())
		
		if GetVehicleLiveryCount(vehicle) > 0 then
			if tonumber(livery) <= GetVehicleLiveryCount(vehicle) - 1 then 
				SetVehicleLivery(vehicle, tonumber(livery))
				
				exports['core']:SendAlert('success', "Vehicle livery changed")
			end	
	 
		end
		if GetVehicleLiveryCount(vehicle) <= 0 then
            exports['core']:SendAlert('error', "This vehicle has no liveries")
		end
    end
	
	if not IsPedInAnyVehicle(PlayerPedId(), false) then
        exports['core']:SendAlert('error', "You must be in a vehicle the change liveries")
	end

end)

RegisterNetEvent('utils:aidrive')
AddEventHandler("utils:aidrive", function()
    local blip = GetFirstBlipInfoId(8)

    if not aiDrive then
        local coord = GetBlipCoords(blip)
        TaskVehicleDriveToCoord(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId()), coord.x, coord.y, 0.0, 20.0, 0, GetEntityModel(GetVehiclePedIsIn(PlayerPedId())), 786603, 1, true)
        exports['core']:SendAlert('success', "Driving to waypoint")
        aiDrive = true
    else
        TaskVehiclePark(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId()), GetEntityCoords(GetVehiclePedIsIn(PlayerPedId())), 1, 0, 0.0, false)
        exports['core']:SendAlert('success', "Stopped Driving")
        aiDrive = false
    end
end)

togglefob = true
RegisterNetEvent('utils:togglefob')
AddEventHandler("utils:togglefob", function()
	local ped = PlayerPedId()
	if togglefob then
		SetPedCanBeKnockedOffVehicle(ped, 1)
		exports['core']:SendAlert('inform', "You can no longer fall off bikes")
		togglefob = false
	else
		SetPedCanBeKnockedOffVehicle(ped, 0)
		exports['core']:SendAlert('inform', "You can fall off bikes")
		togglefob = true
	end
end)

-- RegisterCommand("reviveall", function(source, args, rawCommand)
-- 	if HasPermission(clientPermissions.reviveAll) then
-- 		TriggerServerEvent("TBH:SyncAll", "ems:client:revive")
-- 		TriggerServerEvent('tbh_util:log', _source, 'Admin Command', "Used `reviveall`")
-- 	end
-- end)

RegisterNetEvent("utils:goCommand")
AddEventHandler("utils:goCommand", function(pos, name, vehicle)
    SetEntityCoords(PlayerPedId(), pos) -- Teleport
    if vehicle ~= 0 then
        local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
        for i = -1, maxPassengers - 1, 1 do
            local ped = GetPedInVehicleSeat(vehicle, i)
            if ped == nil or ped == 0 then
                SetPedIntoVehicle(PlayerPedId(), vehicle, i)
                break
            end
        end
    end
    exports['core']:SendAlert('inform', "You teleported to " .. name)
end)

RegisterNetEvent('utils:armour')
AddEventHandler("utils:armour", function()
	SetPedArmour(PlayerPedId(), 100)
	TriggerServerEvent('tbh_util:log', _source, 'Admin Command', "Used `armour`")
end)

RegisterCommand("position", function(source)
	local position = GetEntityCoords(GetPlayerPed(PlayerId()))
	local coords = string.format("%0.2f, %0.2f, %0.2f", position.x, position.y, position.z)
	exports['core']:SendAlert('success', "Your position: " .. coords, 15000)
	print(coords)
end)

RegisterNetEvent('utils:plate')
AddEventHandler("utils:plate", function(text)
	veh = GetVehiclePedIsUsing(PlayerPedId())
	if veh ~= nil then
    	if veh == 0 then
			exports['core']:SendAlert('error', "You need to be in a vehicle")
            return
		end
		plate = table.concat(text, ' ')
		SetVehicleNumberPlateText(veh, plate)
		exports['core']:SendAlert('success', "Your vehicle's plate has been changed to ".. plate)
		TriggerServerEvent('tbh_util:log', _source, 'Admin Command', "Changed vehicle plate")
	end
end)

RegisterNetEvent('utils:plateSave')
AddEventHandler("utils:plateSave", function(text)
	veh = GetVehiclePedIsUsing(PlayerPedId())
	if veh ~= nil then
    	if veh == 0 then
			exports['core']:SendAlert('error', "You need to be in a vehicle")
            return
		end
		local bkPlate = GetVehicleNumberPlateText(veh)
		plate = table.concat(text, ' ')
		TriggerServerEvent("utils:server:savePlate", bkPlate, plate)
	end
end)

RegisterNetEvent("utils:confirmPlate")
AddEventHandler("utils:confirmPlate", function(plate)
	veh = GetVehiclePedIsUsing(PlayerPedId())
	if veh ~= nil or veh ~= 0 or veh ~= -1 then
		SetVehicleNumberPlateText(veh, plate)
	end
end)

-- playerTrack = false

-- RegisterCommand("playertrack", function(source, args)
-- 	if HasPermission(clientPermissions.playerTrack) then
-- 		local player = tonumber(args[1])
-- 		if playerTrack then
-- 			playerTrack = false
-- 			exports['core']:SendAlert('inform', "Stopped tracking")
-- 			return
-- 		else
-- 			playerTrack = true
-- 		end
		
-- 		thePlayer = GetPlayerPed(GetPlayerFromServerId(player))
-- 		exports['core']:SendAlert('success', "Now tracking: ".. GetPlayerName(GetPlayerFromServerId(player)))
	
-- 		Citizen.CreateThread(function()
-- 			while true and playerTrack do
-- 				Citizen.Wait(200)
-- 				thePlayerCoords = GetEntityCoords(thePlayer)
-- 				Citizen.InvokeNative(0xFE43368D2AA4F2FC, thePlayerCoords.x, thePlayerCoords.y)
-- 			end
-- 	    end)
-- 	    TriggerServerEvent('tbh_util:log', _source, 'Admin Command', "Used `playertrack` on "..GetPlayerName(GetPlayerFromServerId(player)))
-- 	end
-- end)

RegisterNetEvent('utils:fix')
AddEventHandler("utils:fix", function()
	local playerPed = PlayerPedId()
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleEngineHealth(vehicle, 1000)
		SetVehicleBodyHealth(vehicle, 1000)
		SetVehicleEngineOn( vehicle, true, true )
		SetVehicleFixed(vehicle)
		exports['core']:SendAlert('success', "Vehicle has been fixed")
	else
		exports['core']:SendAlert('error', "You are not in a vehicle")
	end
end)

RegisterNetEvent('utils:clean')
AddEventHandler("utils:clean", function()
	local playerPed = PlayerPedId()
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleDirtLevel(vehicle, 0)
		exports['core']:SendAlert('success', "Your vehicle has been cleaned")
	else
		exports['core']:SendAlert('error', "You are not in a vehicle")
	end
end)

RegisterCommand("gpsoff", function()
	ped = GetPlayerPed(PlayerId())
	pos = GetEntityCoords(ped)

	SetNewWaypoint(pos)
	ClearGpsPlayerWaypoint()
	exports['core']:SendAlert('success', 'Cleared!')
end)

local invis = true
RegisterNetEvent('utils:invis')
AddEventHandler("utils:invis", function()
	if HasPermission(clientPermissions.invis) then
		invis = not invis
		SetEntityVisible(PlayerPedId(), invis, true)
		NetworkSetEntityInvisibleToNetwork(playerPed, invis)
	end
end)

-- local staffShowId = false
-- RegisterCommand("toggleids", function()
-- 	if HasPermission(clientPermissions.toggleids) then
-- 		staffShowId = not staffShowId
-- 		runTickStaffId()
-- 	end
-- end)

-- function runTickStaffId()
-- 	Citizen.CreateThread(function()
-- 		while staffShowId do
-- 			Citizen.Wait(0)
-- 			if IsControlPressed(0, 20) or staffShowId then
-- 				--for i=0,255 do
-- 				--    N_0x31698aa80e0223f8(i)
-- 				--end
-- 				x1, y1, z1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
-- 				for _, id in ipairs(GetActivePlayers()) do
					
-- 					x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
-- 					distance = math.floor(GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2, true))

-- 					if distance < 1 or (staffShowId and distance < 75) then
-- 						BJCore.Functions.DrawText3D(x2, y2, z2 + 1.5, GetPlayerServerId(id), 0.7)
-- 					end
-- 				end
-- 			elseif not IsControlPressed(0, 20) then
				
-- 			end
-- 		end
-- 	end)
-- end

local Objectfinder = false
RegisterCommand("objectfinder", function(src)
    Objectfinder = not Objectfinder
	runTickObjectFinder()
end)

function runTickObjectFinder()
	Citizen.CreateThread(function()
		while Objectfinder do 
			if Objectfinder then
				GetObject()
			end
			Citizen.Wait(1)
		end
	end)
end

local Pedfinder = false
RegisterCommand("pedfinder", function(src)
    Pedfinder = not Pedfinder
	runTickPedFinder()
end)

function runTickPedFinder()
	Citizen.CreateThread(function()
		while Pedfinder do 
			if Pedfinder then
				getNPC()
			end
			Citizen.Wait(1)
		end
	end)
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    --DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function GetObject()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstObject()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local h = GetEntityHeading(ped)
        local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
        if distance < 5.0 then
            distanceFrom = distance
            rped = ped
            --FreezeEntityPosition(ped, inFreeze)
	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Pos: " .. pos .. " H: ".. string.format("%.3f", h) .. " IN CONTACT" )
	    	else
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Pos: " .. pos .. " H: ".. string.format("%.3f", h) .. "" )
	    	end
        end
        success, ped = FindNextObject(handle)
    until not success
    EndFindObject(handle)
    return rped
end

local showcoords = false
RegisterCommand("showcoords", function()
	showcoords = not showcoords
	runTickCoords()
end)

function runTickCoords()
	Citizen.CreateThread(function()
		while showcoords do
			Citizen.Wait(0)
			local plyPed = PlayerPedId()
			local plyX, plyY, plyZ = table.unpack(GetEntityCoords(plyPed))
			local plyH = GetEntityHeading(plyPed)

			DrawGenericText(("~g~X~w~: %s ~g~Y~w~: %s ~g~Z~w~: %s ~g~H~w~: %s"):format(FormatCoord(plyX), FormatCoord(plyY), FormatCoord(plyZ), FormatCoord(plyH)))			
		end
	end)
end

function DrawGenericText(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(4)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end

FormatCoord = function(coord)
	if coord == nil then; return "unknown"; end
	return tonumber(string.format("%.2f", coord))
end

RegisterNetEvent('utils:maxammo')
AddEventHandler("utils:maxammo", function()
	local bool, wHash = GetCurrentPedWeapon(PlayerPedId())
	if bool then
		local _,max = GetMaxAmmo(PlayerPedId(),wHash)
		SetPedAmmo(PlayerPedId(), wHash, max)
		exports['core']:SendAlert('success', 'Max ammo set')
	else
		exports['core']:SendAlert('error', 'You\'re not holding a weapon')
	end
end)

lastObj = nil
RegisterCommand("spawnobject", function(s,a,r)
	local pos = GetEntityCoords(PlayerPedId())
	BJCore.Functions.SpawnLocalObject(a[1], pos, function(obj)
		lastObj = obj
		FreezeEntityPosition(obj, true)
		PlaceObjectOnGroundProperly(obj)
	end)
end, true)

RegisterCommand("moveobj", function(s,a,r)
	local pos = GetEntityCoords(lastObj)
	if a[1] == "up" then
		SetEntityCoords(lastObj, pos.x, pos.y, pos.z+1.0)
	elseif a[1] == "down" then
		SetEntityCoords(lastObj, pos.x, pos.y, pos.z-1.0)
	end
end, true)
local lastRadar = nil
-- Determines if player is close enough to trigger cam
function HandlespeedCam(speedCam, hasBeenBusted)
	local plyPed = PlayerPedId()
	local plyPos = GetEntityCoords(plyPed)
	local isInMarker  = false
	if #(plyPos - speedCam.xyz) < 20.0 then
		isInMarker  = true
	end

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
		HasAlreadyEnteredMarker = true
		lastRadar = hasBeenBusted

		local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
		if IsPedInAnyVehicle(plyPed, false) then
			if GetPedInVehicleSeat(vehicle, -1) == plyPed then
				if GetVehicleClass(vehicle) ~= 18 then
                    local plate = GetVehicleNumberPlateText(vehicle)
					BJCore.Functions.TriggerServerCallback('police:IsPlateFlagged', function(result)
						if result then
							local coords = GetEntityCoords(PlayerPedId())
							local blipsettings = {
								x = coords.x,
								y = coords.y,
								z = coords.z,
								sprite = 488,
								color = 1,
								scale = 0.9,
								text = "Speed camera #"..hasBeenBusted.." - Flagged vehicle"
							}
							local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
							local street1 = GetStreetNameFromHashKey(s1)
							local street2 = GetStreetNameFromHashKey(s2)
							if street2 == nil then
                                TriggerServerEvent('MF_Trackables:Notify',"Speed camera #"..hasBeenBusted.." - Flagged vehicle "..plate, coords, 'police','bank')
							else
                                TriggerServerEvent('MF_Trackables:Notify',"Speed camera #"..hasBeenBusted.." - Flagged vehicle "..plate, coords, 'police','bank')
							end
							TriggerServerEvent("police:server:FlaggedPlateTriggered", hasBeenBusted, plate, street1, street2, blipsettings)
						end
                    end, plate)
				end
			end
		end
	end
		
	if not isInMarker and HasAlreadyEnteredMarker and lastRadar == hasBeenBusted then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			for key, value in pairs(Config.Radars) do
				HandlespeedCam(value, key)
			end
			Citizen.Wait(200)
		else
			Citizen.Wait(2500)
		end
	end
end)
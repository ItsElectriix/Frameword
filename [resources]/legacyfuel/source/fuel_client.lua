local isNearPump = false
local isFueling = false
local currentFuel = 0.0
local currentCost = 0.0
local currentCash = 1000
local fuelSynced = false
local pData = {}

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
	end
end

Citizen.CreateThread(function()
    DecorRegister(Config.FuelDecor, 1)
    while not BJCore do Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
    pData = BJCore.Functions.GetPlayerData()
	while true do
		Citizen.Wait(1000)

		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped)

			if GetPedInVehicleSeat(vehicle, -1) == ped then
				ManageFuelUsage(vehicle)
			end
		else
			if fuelSynced then
				fuelSynced = false
			end
		end
	end
end)

function FindNearestFuelPump()
	local coords = GetEntityCoords(PlayerPedId())
	local fuelPumps = {}
	local handle, object = FindFirstObject()
	local success

	repeat
		if Config.PumpModels[GetEntityModel(object)] then
			table.insert(fuelPumps, object)
		end

		success, object = FindNextObject(handle, object)
	until not success

	EndFindObject(handle)

	local pumpObject = 0
	local pumpDistance = 1000

	for k,v in pairs(fuelPumps) do
		local dstcheck = GetDistanceBetweenCoords(coords, GetEntityCoords(v))

		if dstcheck < pumpDistance then
			pumpDistance = dstcheck
			pumpObject = v
		end
	end

	return pumpObject, pumpDistance
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(250)

		local pumpObject, pumpDistance = FindNearestFuelPump()

		if pumpDistance < 3.5 then
			isNearPump = pumpObject

            pData = BJCore.Functions.GetPlayerData()
			currentCash = pData.money.cash
		else
			isNearPump = false
			if pumpDistance > 50.0 then
				Citizen.Wait(math.ceil(pumpDistance * 10))
			end
		end
	end
end)

AddEventHandler('fuel:startFuelUpTick', function(pumpObject, ped, vehicle)
	currentFuel = GetVehicleFuelLevel(vehicle)

	while isFueling do
		Citizen.Wait(500)

		local oldFuel = DecorGetFloat(vehicle, Config.FuelDecor)
		local fuelToAdd = math.random(10, 20) / 10.0
		local extraCost = fuelToAdd / 1.7 -- The higher the number, the less the price will cost.

		if not pumpObject then
			if GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100 >= 0 then
				currentFuel = oldFuel + fuelToAdd

				SetPedAmmo(ped, 883325847, math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100))
				TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100))
			else
				isFueling = false
			end
		else
			currentFuel = oldFuel + fuelToAdd
		end

		if currentFuel > 100 then
			currentFuel = 100			
			isFueling = false
		end

		currentCost = currentCost + extraCost

		if currentCash >= currentCost then
			TriggerServerEvent('fuel:SetFuel',VehToNet(vehicle),currentFuel)
			--SetFuel(vehicle, currentFuel)
		else
			isFueling = false
		end
	end

	if pumpObject then
		TriggerServerEvent('fuel:pay', currentCost)
	end

	currentCost = 0.0
end)

function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)

	return math.floor(num * mult + 0.5) / mult
end

AddEventHandler('fuel:refuelFromPump', function(pumpObject, ped, vehicle)
	TaskTurnPedToFaceEntity(ped, vehicle, 1000)
	Citizen.Wait(1000)
	local b, hash = GetCurrentPedWeapon(ped)
	local hasJerry = false
	if hash == GetHashKey("weapon_petrolcan") then
		hasJerry = true
		BJCore.Functions.LoadAnimDict("weapon@w_sp_jerrycan")
		TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 2.0, 8.0, -1, 49, 0, 0, 0, 0)
	else
	    SetCurrentPedWeapon(ped, -1569615261, true)
		BJCore.Functions.LoadAnimDict("timetable@gardener@filling_can")
		TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
	end

	TriggerEvent('fuel:startFuelUpTick', pumpObject, ped, vehicle)

	while isFueling do
		Citizen.Wait(1)

		for k,v in pairs(Config.DisableKeys) do
			DisableControlAction(0, v)
		end

		local vehicleCoords = GetEntityCoords(vehicle)

		if pumpObject then
			local stringCoords = GetEntityCoords(pumpObject)
			local extraString = ""
			extraString = "\nCost: ~g~"..BJCore.Config.Currency.Symbol .. Round(currentCost, 1)

			BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.CancelFuelingPump .. extraString, 2)
			BJCore.Functions.DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, Round(currentFuel, 1) .. "L")
		else
			BJCore.Functions.DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, Config.Strings.CancelFuelingJerryCan .. "\nGas can: ~g~" .. Round(GetAmmoInPedWeapon(ped, 883325847) / 4500 * 100, 1) .. "L | Vehicle: " .. Round(currentFuel, 1) .. "L",2)
		end

        if hasJerry then
			if not IsEntityPlayingAnim(ped, "weapon@w_sp_jerrycan", "fire", 3) then
				TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 2.0, 8.0, -1, 49, 0, 0, 0, 0)
			end  	
        else
			if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
				TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
			end
		end

		if IsControlJustReleased(0, 38) or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) or (isNearPump and GetEntityHealth(pumpObject) <= 0) then
			isFueling = false
		end
	end

	ClearPedTasks(ped)
	BJCore.Functions.RemoveAnimDict("weapon@w_sp_jerrycan")
	BJCore.Functions.RemoveAnimDict("timetable@gardener@filling_can")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		local ped = PlayerPedId()

		if not isFueling and ((isNearPump and GetEntityHealth(isNearPump) > 0) or (GetSelectedPedWeapon(ped) == 883325847 and not isNearPump)) then
			if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
				local pumpCoords = GetEntityCoords(isNearPump)

				BJCore.Functions.DrawText3D(pumpCoords.x, pumpCoords.y, pumpCoords.z + 1.2, Config.Strings.ExitVehicle)
			else
				local vehicle = GetPlayersLastVehicle()
				local vehicleCoords = GetEntityCoords(vehicle)

				if DoesEntityExist(vehicle) and GetDistanceBetweenCoords(GetEntityCoords(ped), vehicleCoords) < 2.5 then
					if not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
						local stringCoords = GetEntityCoords(isNearPump)
						local canFuel = true

						if GetSelectedPedWeapon(ped) == 883325847 then
							stringCoords = vehicleCoords

							if GetAmmoInPedWeapon(ped, 883325847) < 100 then
								canFuel = false
							end
						end

						if GetVehicleFuelLevel(vehicle) < 100 and canFuel then	
			                if GetSelectedPedWeapon(ped) == 883325847 then 
								BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.EToRefuel)

								if IsControlJustReleased(0, 38) then
									isFueling = true

									TriggerEvent('fuel:refuelFromPump', isNearPump, ped, vehicle)
								end
							elseif currentCash > 0 then
								BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.EToRefuel)

								if IsControlJustReleased(0, 38) then
									isFueling = true

									TriggerEvent('fuel:refuelFromPump', isNearPump, ped, vehicle)
								end
							else
								BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.NotEnoughCash)
							end
						elseif not canFuel then
							BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.JerryCanEmpty)
						else
							BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.FullTank)
						end
					end
				elseif isNearPump then
					local stringCoords = GetEntityCoords(isNearPump)
					if currentCash >= Config.JerryCanCost then

						BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.PurchaseJerryCan)

						if IsControlJustReleased(0, 38) then
							local info = {
								ammo = 4500
							}
                            TriggerServerEvent("BJCore:Server:AddItem", "weapon_petrolcan", 1, nil, info)
							TriggerServerEvent('fuel:pay', Config.JerryCanCost)
						end
					else
						BJCore.Functions.DrawText3D(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.NotEnoughCash)
					end
				else
					Citizen.Wait(250)
				end
			end
		else
			Citizen.Wait(250)
		end
	end
end)

function CreateBlip(coords)
	local blip = AddBlipForCoord(coords)

	SetBlipSprite(blip, 361)
	SetBlipScale(blip, 0.65)
	SetBlipColour(blip, 1)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Gas Station")
	EndTextCommandSetBlipName(blip)

	return blip
end

Citizen.CreateThread(function()
	local currentGasBlip = 0

	while true do
		Citizen.Wait(10000)

		local coords = GetEntityCoords(PlayerPedId())
		local closest = 1000
		local closestCoords

		for k,v in pairs(Config.GasStations) do
			local dstcheck = GetDistanceBetweenCoords(coords, v)

			if dstcheck < closest then
				closest = dstcheck
				closestCoords = v
			end
		end

		if DoesBlipExist(currentGasBlip) then
			RemoveBlip(currentGasBlip)
		end

		currentGasBlip = CreateBlip(closestCoords)
	end
end)

function GetFuel(vehicle)
	return DecorGetFloat(vehicle, Config.FuelDecor)
end

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then	
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
	end
end

RegisterNetEvent("fuel:SetFuel")
AddEventHandler("fuel:SetFuel", function(veh,fuel)
	local vehicle = NetToVeh(veh)
	SetFuel(vehicle, fuel)
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon')
AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
end)
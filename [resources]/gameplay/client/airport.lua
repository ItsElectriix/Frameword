local cars = {
	`italirsx`,
	`brioso2`,
	`veto`,
	`veto2`,
	`weevil`,
	`manchez2`,
	`verus`,
}

local carSpawns = {
	vector4(4463.693, -4468.253, 4.244259, 208.87),
	vector4(4468.202, -4465.702, 4.244259, 205.15),
	vector4(4472.705, -4464.326, 4.244259, 202.15),
	vector4(4478.206, -4463.165, 4.244259, 195.21),
	vector4(4483.61, -4462.301, 4.244259, 192.29),
	vector4(4488.956, -4461.431, 4.244259, 185.65),
	vector4(4494.868, -4458.152, 4.244259, 180.15),
	vector4(4500.854, -4456.158, 4.244259, 175.15)
}

local isFlightController = false

function CreatePlane(x, y, z, heading, destination)

	modelHash = GetHashKey("nimbus")
	pilotModel = GetHashKey("s_m_m_pilot_01")
	
	DoScreenFadeOut(200)
	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end

	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		Citizen.Wait(0)
	end

	RequestModel(pilotModel)
	while not HasModelLoaded(pilotModel) do
		Citizen.Wait(0)
	end

	if HasModelLoaded(modelHash) and HasModelLoaded(pilotModel) then
		SetEntityCoords(PlayerPedId(), x, y, z)
		ClearAreaOfEverything(x, y, z, 1500, false, false, false, false, false)

		AirPlane = CreateVehicle(modelHash, x, y, z-1.0, heading, true, false)
        FreezeEntityPosition(AirPlane, true)
		local finish = GetGameTimer() + 5000
		while not DoesEntityExist(AirPlane) and GetGameTimer() < finish do
			Wait(1)
		end
        Wait(100)
        SetVehicleLandingGear(AirPlane, 0)
        while GetLandingGearState(AirPlane) ~= 0 do
            SetVehicleLandingGear(AirPlane, 0)
            Wait(10)
        end
        FreezeEntityPosition(AirPlane, false)
		SetVehicleOnGroundProperly(AirPlane)
		SetVehicleEngineOn(AirPlane, true, true, true)
		SetEntityProofs(AirPlane, true, true, true, true, true, true, true, false)
		SetVehicleHasBeenOwnedByPlayer(AirPlane, true)

		pilot = CreatePedInsideVehicle(AirPlane, 6, pilotModel, -1, true, false)

		SetBlockingOfNonTemporaryEvents(pilot, true)

		local netVehid = NetworkGetNetworkIdFromEntity(AirPlane)
		SetNetworkIdCanMigrate(netVehid, true)
		NetworkRegisterEntityAsNetworked(VehToNet(AirPlane))
        while VehToNet(AirPlane) == 0 do
            Wait(1)
        end
        netVehid = NetworkGetNetworkIdFromEntity(AirPlane)

		local netPedid = NetworkGetNetworkIdFromEntity(pilot)
		SetNetworkIdCanMigrate(netPedid, true)
		NetworkRegisterEntityAsNetworked(pilot)

		totalSeats = GetVehicleModelNumberOfSeats(modelHash) - 3
		TaskWarpPedIntoVehicle(PlayerPedId(), AirPlane, 2)

		SetModelAsNoLongerNeeded(modelHash)
		SetModelAsNoLongerNeeded(pilotModel)
	end

    TriggerServerEvent('bj_gameplay:airport:populateFlight', startZone, VehToNet(AirPlane), totalSeats)

	Wait(800)
	DoScreenFadeIn(500)
	Wait(1000)

    Citizen.CreateThread(function()
        Wait(15000)
        TriggerServerEvent('bj_gameplay:airport:flightStarted', startZone)
        if destination == "SANAND" then
            TaskVehicleDriveToCoordLongrange(pilot, AirPlane, -1027.711, -3321.794, 13.97225, GetVehicleModelMaxSpeed(modelHash), 16777216, 0.0)
            Wait(10000)
            TaskPlaneMission(pilot, AirPlane, 0, 0, 2275.08, -4716.232, 40.7943, 4, GetVehicleModelMaxSpeed(modelHash), 1.0, -1.0, 10.0, 40.0)
        elseif destination == "AIRP" then
            TaskVehicleDriveToCoordLongrange(pilot, AirPlane, 3949.541, -4693.096, 4.18445, GetVehicleModelMaxSpeed(modelHash), 16777216, 0.0)
            Wait(15000)
            TaskPlaneMission(pilot, AirPlane, 0, 0, 237.282, -3708.991, 40.6289, 4, GetVehicleModelMaxSpeed(modelHash), 1.0, -1.0, 5.0, 40.0)
        end
    end)
end

function CreateCar()
	local spawn = nil
	for _,v in ipairs(carSpawns) do
		if #BJCore.Functions.GetVehiclesInArea(v.xyz, 5.5) == 0 then
			spawn = v
			break
		end
	end

	if spawn == nil then
		return
	end

	modelHash = cars[math.random(1, #cars)]
	
	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		Citizen.Wait(0)
	end

	if HasModelLoaded(modelHash) then
		
		Car = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
		local finish = GetGameTimer() + 5000
		while not DoesEntityExist(Car) and GetGameTimer() < finish do
			Wait(1)
		end
		SetVehicleOnGroundProperly(Car)
		SetVehicleHasBeenOwnedByPlayer(Car, true)

		local netVehid = NetworkGetNetworkIdFromEntity(Car)
		SetNetworkIdCanMigrate(netVehid, true)
		NetworkRegisterEntityAsNetworked(VehToNet(Car))

		SetModelAsNoLongerNeeded(modelHash)

		if DoesEntityExist(Car) then
			TriggerEvent('keys:addNew', Car, GetVehicleNumberPlateText(Car))
			local name = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
			if name then
				BJCore.Functions.Notify("Welcome to the island! I've left a "..name.." for you to explore the island with. Keys are in the car.", "primary", 10000)
			else
				BJCore.Functions.Notify("Welcome to the island! I've left a car for you to explore the island with. Keys are in the car.", "primary", 10000)
			end
		end
	end
end

RegisterNetEvent('bj_gameplay:airport:joinFlight')
AddEventHandler('bj_gameplay:airport:joinFlight', function(start, veh, seat)
    queuePosition = nil
    isFlightController = false
    DoScreenFadeOut(200)
	while not IsScreenFadedOut() do
		Citizen.Wait(0)
	end
    if start == 'AIRP' then
        SetEntityCoords(PlayerPedId(), -1463.077, -3060.17, 14.5409)
    elseif start == 'SANAND' then
        SetEntityCoords(PlayerPedId(), 4474.957, -4510.133, 4.18719)
    end
    local entity = NetToVeh(veh)
    while not DoesEntityExist(entity )do
        entity = NetToVeh(veh)
        Wait(10)
    end
    TaskWarpPedIntoVehicle(PlayerPedId(), entity, seat)
    AirPlane = entity
	Wait(800)
	DoScreenFadeIn(500)
end)

local queuePosition = nil

function IsPlayerNearAirport()
	local coords = GetEntityCoords(PlayerPedId())
	for k,v in pairs(StartPoints) do
		if #(coords - v.coords) < 2.0 then
			if not queuePosition and not IsPedInAnyPlane(PlayerPedId()) then
                if Config.AirportConfig[v.start] ~= nil and Config.AirportConfig[v.start].Price > 0 then
				    BJCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[~g~E~w~] Travel to ~y~"..v.desc..'~w~ for ~r~'..BJCore.Config.Currency.Symbol..tostring(Config.AirportConfig[v.start].Price), 0.7)
                else
                    BJCore.Functions.DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[~g~E~w~] Travel to ~y~"..v.desc, 0.7)
                end
			end
			return v
		end
	end
end

Citizen.CreateThread(function()
	while BJCore == nil do
        Citizen.Wait(200)
    end
    for k,v in pairs(StartPoints) do
		AddTextEntry("AIRPORTS"..tostring(k), "Press ~INPUT_CONTEXT~ to travel to "..v.desc)
	end
	while true do
		local idle = 500
		local airport = IsPlayerNearAirport()
		if airport and not queuePosition then
			idle = 2
			if IsControlJustPressed(0, 38) then
				if airport.dest == "SANAND" then
					if IsEntityInZone(PlayerPedId(), "AIRP") then
						startZone = airport.start
						planeDest = airport.dest
                        BJCore.Functions.TriggerServerCallback('bj_gameplay:airport:buyTicket', function(isQueued)
                            if not isQueued then
                                queuePosition = nil
                            end
                        end, startZone)
                        queuePosition = airport.coords
						--CreatePlane(-1463.077, -3070.17, 14.5409, 234.1125, planeDest)
					else
						BJCore.Functions.Notify("No plane is scheduled to that location right now.")
					end
				elseif airport.dest == "AIRP" then
					if not IsEntityInZone(PlayerPedId(), "AIRP") then
						startZone = airport.start
						planeDest = airport.dest
                        BJCore.Functions.TriggerServerCallback('bj_gameplay:airport:buyTicket', function(isQueued)
                            if not isQueued then
                                queuePosition = nil
                            end
                        end, startZone)
                        queuePosition = airport.coords
						--CreatePlane(4474.957, -4500.133, 4.18719, 106.26074981689, planeDest)
					else
						BJCore.Functions.Notify("No plane is scheduled to that location right now.")
					end
				end
			end
		end

        if queuePosition then
            local coords = GetEntityCoords(PlayerPedId())

            if #(coords - queuePosition) > Config.WaitingPlaneAreaLimit then
                TriggerServerEvent('bj_gameplay:airport:leaveQueue', startZone)
                queuePosition = nil
            end
        end

		if not landing then
			if isFlightController and IsEntityInAir(AirPlane) then
				SetVehicleLandingGear(AirPlane, 1)
			end

			if startZone == "AIRP" and planeDest == "SANAND" then
				if #(vector3(3964.122, -4688.734, 4.183741) - GetEntityCoords(PlayerPedId())) < 1750.0 then
                    if isFlightController then
					    TaskPlaneLand(pilot, AirPlane, 3964.122, -4688.734, 4.183741+1.0001, 4453.131, -4509.515, 4.184302+1.0001)
					    SetPedKeepTask(pilot, true)
                    end
					landing = true
				end
			elseif startZone == "SANAND" and planeDest == "AIRP" then
				if IsEntityInZone(AirPlane, "RICHM") or IsEntityInZone(AirPlane, "OCEANA") then
                    if isFlightController then
					    TaskPlaneLand(pilot, AirPlane, -1055.289, -3305.662, 13.96993+1.0001, -1476.158, -3062.396, 13.94807+1.0001)
					    SetPedKeepTask(pilot, true)
                    end
					landing = true
				end
			end
		end

		if landing == true then
			if not IsEntityInAir(AirPlane) and IsPedInVehicle(PlayerPedId(), AirPlane, false) then
                if isFlightController then
				    TaskVehicleTempAction(pilot, Airplane, 27, -1)
				    SetVehicleHandbrake(AirPlane, true)
                end

				if GetEntitySpeed(AirPlane) == 0.0 then
                    print('Speed 0')
					if IsEntityInZone(PlayerPedId(), "AIRP") then
						Wait(500)
						DoScreenFadeOut(200)
						while not IsScreenFadedOut() do
							Citizen.Wait(0)
						end
                        print('TP')

						SetEntityCoords(PlayerPedId(), -1042.0395, -2740.7780, 20.1692)
						SetEntityHeading(PlayerPedId(), 340.2285)
                        
                        print('TP Done')
						Wait(800)
						DoScreenFadeIn(500)
					else
						TaskLeaveVehicle(PlayerPedId(), AirPlane, 0)
					end
				end
			end

			if not IsPedInVehicle(PlayerPedId(), AirPlane, false) then
                if isFlightController then
				    SetVehicleHandbrake(AirPlane, false)
				    SetBlockingOfNonTemporaryEvents(pilot, false)
			
				    Wait(5000)

                    print('Getting control')
                    while not NetworkHasControlOfEntity(AirPlane) do
                        NetworkRequestControlOfEntity(AirPlane)
                        Wait(10)
                    end

                    print('Set as not needed')
                    SetEntityAsNoLongerNeeded(pilot)
				    SetEntityAsNoLongerNeeded(AirPlane)

                    Wait(100)

                    print('Deleting')
				    DeleteEntity(pilot)
				    DeleteEntity(AirPlane)
                    
                    TriggerServerEvent('bj_gameplay:airport:flightEnded', startZone)
                end

				--if planeDest == "SANAND" then
				--	CreateCar()
				--end

				startZone = nil
				planeDest = nil
				landing = false
			end
		end

		if planeDest then
			idle = 0
		end

		Citizen.Wait(idle)
	end
end)

RegisterNetEvent('bj_gameplay:airport:doFlightPrep')
AddEventHandler('bj_gameplay:airport:doFlightPrep', function(start, dest)
    queuePosition = nil
    isFlightController = true
    if start == 'AIRP' then
        CreatePlane(-1463.077, -3070.17, 16.5409, 234.1125, dest)
    elseif start == 'SANAND' then
        CreatePlane(4474.957, -4500.133, 6.18719, 106.26074981689, planeDest)
    end
end)
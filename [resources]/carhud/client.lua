-- GENERAL PARAMETERS
local enableController = true               -- Enable controller inputs

-- SEATBELT PARAMETERS
local seatbeltInput = 29                   -- Toggle seatbelt on/off with K or DPAD down (controller)
local seatbeltPlaySound = true              -- Play seatbelt sound
local seatbeltDisableExit = true            -- Disable vehicle exit when seatbelt is enabled
local seatbeltEjectSpeed = 45.0             -- Speed threshold to eject player (MPH)
local seatbeltEjectAccel = 100.0            -- Acceleration threshold to eject player (G's)

-- CRUISE CONTROL PARAMETERS
local cruiseInput = 244                     -- Toggle cruise on/off with CAPSLOCK or A button (controller)

-- Globals
local pedInVeh = false
local pedIsDriver = false
local vehicleEngineOn = false
local vehicleClass = 0
local heading = nil
local streetName = nil
local zoneName = nil
local currentFuel = 0.0
local showUI = false

BJCore = nil
Citizen.CreateThread(function()
    while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(1000); end
    showUI = true
    SendNUIMessage({
        type = "enableUi"
    })
end)

-- RegisterCommand("carhud", function()
-- 	SendNUIMessage({
--         type = "enableUi"
-- 	})
-- end)

local currSpeed = 0.0
local cruiseSpeed = 999.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
local cruiseIsOn = false
local seatbeltIsOn = false
local prevSpeed = 0.0
local isHeli = false
local altitude = 0
local altitudeSea = 0

-- MinimapScaleform = {
--     scaleform = nil,
-- }

-- Citizen.CreateThread(function()
--     MinimapScaleform.scaleform = RequestScaleformMovie("minimap")
--     SetRadarBigmapEnabled(true, false)
--     Wait(0)
-- 	SetRadarBigmapEnabled(false, false)
-- end)

-- function SetHealthArmorType(type)
--     BeginScaleformMovieMethod(MinimapScaleform.scaleform, "SETUP_HEALTH_ARMOUR")
--     ScaleformMovieMethodAddParamInt(type)
--     EndScaleformMovieMethod()
-- end

-- Main thread
local player, position, vehicle
local function InitializeCarHud()
	Citizen.CreateThread(function()
		while true do
			player = PlayerPedId()
			position = GetEntityCoords(player)
			vehicle = GetVehiclePedIsIn(player, false)   
			
			-- Set vehicle states
			if IsPedInAnyVehicle(player, false) then
				pedInVeh = true
				if (GetPedInVehicleSeat(vehicle, -1) == player) then
					pedIsDriver = true
				end
				vehicleEngineOn = GetIsVehicleEngineRunning(vehicle)
				if IsPedInAnyHeli(player) or IsPedInAnyPlane(player) then
					isHeli = true
				end
				vehicleClass = GetVehicleClass(vehicle)
			else
				-- Reset states when not in car
				pedInVeh = false
				pedIsDriver = false
				vehicleEngineOn = false
				vehicleClass = 0
				cruiseIsOn = false
                seatbeltIsOn = false
				isHeli = false
            end
            TriggerEvent("carhud:seatbelt:client", seatbeltIsOn)
            Citizen.Wait(500)
		end		
	end)
	Citizen.CreateThread(function()
		while true do
			-- Loop forever and update HUD every frame
			Citizen.Wait(7)
			
			-- Display remainder of HUD when engine is on and vehicle is not a bicycle
			if pedInVeh and vehicleClass ~= 13 then
				if seatbeltDisableExit and seatbeltIsOn then
					-- Disable vehicle exit when seatbelt is on
					DisableControlAction(0, 75)
				end

				if vehicleEngineOn then
					-- Save previous speed and get current speed
					prevSpeed = currSpeed
					currSpeed = GetEntitySpeed(vehicle)
				
					-- Set PED flags
					SetPedConfigFlag(player, 32, true)
				
					
					-- When player in driver seat, handle cruise control
					if pedIsDriver then

					else
						cruiseIsOn = false
					end
					
					if isHeli then
						isHeli = true
						altitude = GetEntityHeightAboveGround(vehicle)
						altitudeSea = GetEntityCoords(vehicle).z - 1
					end
				end
					
			end
			
			--SetHealthArmorType(3)
			SetPedHelmet(PlayerPedId(), false)
	
			if pedInVeh and showUI then
			    DisplayRadar(true)
				if IsBigmapActive() then
					SetBigmapActive(false, false)
				end
			else
				Citizen.Wait(500)
			    DisplayRadar(false)
			end
		end
	end)	
end
InitializeCarHud()

RegisterKeyMapping('-seatbelt', 'Seatbelt~', 'keyboard', 'B')
RegisterCommand('-seatbelt', function()
	if not pedInVeh then return; end
	local vehicleClass = GetVehicleClass(vehicle)
	if vehicleClass ~= 8 then
        seatbeltIsOn = not seatbeltIsOn
		if seatbeltPlaySound then
			PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
		end
	end
end, false)

RegisterKeyMapping('-limiter', 'Speed Limiter~', 'keyboard', 'M')
RegisterCommand('-limiter', function()
	if not pedInVeh then return; end
	if not pedIsDriver then return; end
	if not GetIsVehicleEngineRunning(vehicle) then return; end
	cruiseIsOn = not cruiseIsOn
	cruiseSpeed = currSpeed
	if not cruiseIsOn then
		SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
	else
		SetEntityMaxSpeed(vehicle, cruiseSpeed)
	end
end, false)

-- Secondary thread to update strings
local function UpdateHudVars()
	Citizen.CreateThread(function()
		local timeText = nil
		while true do
			-- Update time text string
			local hour = GetClockHours()
			local minute = GetClockMinutes()
			timeText = ("%.2d"):format((hour == 0) and 12 or hour) .. ":" .. ("%.2d"):format( minute)
	
			-- Get heading and zone from lookup tables and street name from hash
			heading = GetEntityHeading(player)
			zoneName = GetNameOfZone(position.x, position.y, position.z)
			streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
				
			-- Update fuel when in a vehicle
			if pedInVeh then
				-- Display remainign fuel in liters
				if IsVehicleEngineOn(vehicle) then currentFuel = exports['legacyfuel']:GetFuel(vehicle); end
			end
			
			SendNUIMessage({
				type = 'uiUpdate',
				time = {
					time = timeText,
					type = ((hour < 12) and "AM" or "PM")
				},
				location = {
					heading = heading,
					streetName = streetName,
					zoneName = zoneName
				},
				inVehicle = pedInVeh,
				seatbelt = seatbeltIsOn,
				cruise = cruiseIsOn,
				cruiseSpeed = cruiseSpeed,
				speed = currSpeed,
				fuel = currentFuel,
				isHeli = isHeli,
				altitude = altitude,
				altitudeSea = altitudeSea				
			})
			Citizen.Wait(250)
		end
	end)
end
UpdateHudVars()

AddEventHandler('hud:toggle', function(show)
    showUI = show
	if show then
		SendNUIMessage({
			type = 'enableUi'
		})
	else 
		SendNUIMessage({
			type = 'disableUi'
		})
	end
end)

RegisterNetEvent("BJCore:Client:OnPlayerUnload")
AddEventHandler("BJCore:Client:OnPlayerUnload", function()
    showUI = false
	SendNUIMessage({
		type = 'disableUi'
	})
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    showUI = false
	SendNUIMessage({
		type = 'enableUi'
	})
end)

--RegisterCommand("limit", function(source, args, rawCommand)
--	if cruiseIsOn then
--		cruiseIsOn = false
--	else
--		local limit = nil
--		if #args > 0 then
--			limit = tonumber(args[1])
--		end
    
--		if limit ~= nil then
--			cruiseSpeed = limit / 2.237
--			cruiseIsOn = true
--			exports['mythic_notify']:SendAlert('success', "Limit set to: "..tostring(limit).." MPH")
--		else
--			exports['mythic_notify']:SendAlert('error', "Please enter a number")
--		end
--	end
--end)
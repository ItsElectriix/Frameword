BJCore = nil
local closestScrapyard = 0
local emailSend = false
local isBusy = false

Citizen.CreateThread(function()
	while BJCore == nil do
		TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("scrapyard:server:LoadVehicleList")
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        SetClosestScrapyard()
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		if closestScrapyard ~= 0 then
			local pos = GetEntityCoords(PlayerPedId())
			if #(pos - Config.CSLocations[closestScrapyard]["deliver"]) < 10.0 then
				if IsPedInAnyVehicle(PlayerPedId()) then
					local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
					if vehicle ~= 0 and vehicle ~= nil then 
						local vehpos = GetEntityCoords(vehicle)
						if #(pos - vehpos) < 2.5 and not isBusy then
							BJCore.Functions.DrawText3D(vehpos.x, vehpos.y, vehpos.z, "[~r~E~w~] Scrap vehicle")
							if IsControlJustReleased(0, Keys["E"]) then
								if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
									if IsVehicleValid(GetEntityModel(vehicle)) then 
										ScrapVehicle(vehicle)
									else
										BJCore.Functions.Notify("This vehicle can\'t be scrapped", "error")
									end
								else
									BJCore.Functions.Notify("You're not the driver", "error")
								end
							end
						end
					end
				end
			end
			if #(pos - Config.CSLocations[closestScrapyard]["list"]) < 1.5 then
				if not IsPedInAnyVehicle(PlayerPedId()) and not emailSend then
					BJCore.Functions.DrawText3D(Config.CSLocations[closestScrapyard]["list"].x, Config.CSLocations[closestScrapyard]["list"].y, Config.CSLocations[closestScrapyard]["list"].z, "~g~E~w~ - E-mail vehicle list")
					if IsControlJustReleased(0, Keys["E"]) then
						CreateListEmail()
					end
				end
			end
		end
	end
end)

RegisterNetEvent('scrapyard:client:setNewVehicles')
AddEventHandler('scrapyard:client:setNewVehicles', function(vehicleList)
	Config.CSCurrentVehicles = vehicleList
end)

function CreateListEmail()
	if Config.CSCurrentVehicles ~= nil and next(Config.CSCurrentVehicles) ~= nil then 
		emailSend = true
		local vehicleList = ""
		for k, v in pairs(Config.CSCurrentVehicles) do
			if Config.CSCurrentVehicles[k] ~= nil then 
				local vehicleInfo = BJCore.Shared.Vehicles[v]
				if vehicleInfo ~= nil then 
					vehicleList = vehicleList  .. vehicleInfo["brand"] .. " " .. vehicleInfo["name"] .. "<br />"
				end
			end
		end
		SetTimeout(math.random(15000, 20000), function()
			emailSend = false
			TriggerServerEvent('phone:server:sendNewMail', {
				sender = "Scrappy & Sons",
				subject = "Vehicle list",
				message = "You can only scrap a number of vehicles.<br />You can keep everything you scrap for yourself as long as you dont bother me.<br /><br /><strong>Vehicle list:</strong><br />".. vehicleList,
				button = {}
			})
		end)
	else
		BJCore.Functions.Notify("You can\'t scrap any cars now", "error")
	end
end

function ScrapVehicle(vehicle)
	isBusy = true
	local scrapTime = math.random(45000, 60000)
	ScrapVehicleAnim(scrapTime)
	ScrapVehicleAudio(scrapTime)
	exports['mythic_progbar']:Progress({
        name = "scrap_vehicle",
        duration = scrapTime,
        label = "Scrapping vehicle",
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
			StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
			TriggerServerEvent("scrapyard:server:ScrapVehicle", GetVehicleKey(GetEntityModel(vehicle)))
			SetEntityAsMissionEntity(vehicle, true, true)
			DeleteVehicle(vehicle)
			isBusy = false
		else
			StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
			isBusy = false
			BJCore.Functions.Notify("Cancelled", "error")			
        end
    end)
end

function IsVehicleValid(vehicleModel)
	local retval = false
	if Config.CSCurrentVehicles ~= nil and next(Config.CSCurrentVehicles) ~= nil then 
		for k, v in pairs(Config.CSCurrentVehicles) do
			if Config.CSCurrentVehicles[k] ~= nil and GetHashKey(Config.CSCurrentVehicles[k]) == vehicleModel then 
				retval = true
			end
		end
	end
	return retval
end

function GetVehicleKey(vehicleModel)
	local retval = 0
	if Config.CSCurrentVehicles ~= nil and next(Config.CSCurrentVehicles) ~= nil then 
		for k, v in pairs(Config.CSCurrentVehicles) do
			if GetHashKey(Config.CSCurrentVehicles[k]) == vehicleModel then 
				retval = k
			end
		end
	end
	return retval
end

function SetClosestScrapyard()
	local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
	for id, scrapyard in pairs(Config.CSLocations) do
		if current ~= nil then
			if #(pos - Config.CSLocations[id]["main"]) < dist then
				current = id
				dist = #(pos - Config.CSLocations[id]["main"])
			end
		else
			dist = #(pos - Config.CSLocations[id]["main"])
			current = id
		end
	end
	closestScrapyard = current
end

function ScrapVehicleAnim(time)
    time = (time / 1000)
    loadAnimDict("mp_car_bomb")
    TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
    local openingDoor = true
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

function ScrapVehicleAudio(time)
	local totaltime = (time / 1000)
	time = (time / 1000)
	local lastplayed = time
	local openingDoor = true
	Citizen.CreateThread(function()
        while openingDoor do
        	local chance = math.random(100)
        	local diff = lastplayed - time
        	if diff >= 6.5 and chance <= 50 then
	        	TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 10.0, 'mechdrill', 0.02)
	        	lastplayed = time
	        end
            Citizen.Wait(1000)
			time = time - 1
            if time <= 6.5 then
                openingDoor = false
            end
        end
    end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end
inJail = false
jailTime = 0
currentJob = "electrician"
CellsBlip = nil
TimeBlip = nil
ShopBlip = nil

Citizen.CreateThread(function()
    TriggerEvent('prison:client:JailAlarm', false)
	while true do 
		Citizen.Wait(7)
		if jailTime > 0 and inJail then 
			Citizen.Wait(1000 * 60)
			if jailTime > 0 and inJail then
				jailTime = jailTime - 1
				if jailTime <= 0 then
					jailTime = 0
					BJCore.Functions.Notify("Your time is up! Check your time to be set free", "success", 10000)
				end
				TriggerServerEvent("prison:server:SetJailStatus", jailTime)
			end
		else
			Citizen.Wait(5000)
		end
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
	BJCore.Functions.TriggerServerCallback('prison:server:IsAlarmActive', function(active)
		if active then
			TriggerEvent('prison:client:JailAlarm', true)
		end
	end)

	PlayerJob = BJCore.Functions.GetPlayerData().job
end)

function CreateCellsBlip()
	if CellsBlip ~= nil then
		RemoveBlip(CellsBlip)
	end
	CellsBlip = AddBlipForCoord(Config.JailLocations["yard"].coords.x, Config.JailLocations["yard"].coords.y, Config.JailLocations["yard"].coords.z)

	SetBlipSprite (CellsBlip, 238)
	SetBlipDisplay(CellsBlip, 4)
	SetBlipScale  (CellsBlip, 0.8)
	SetBlipAsShortRange(CellsBlip, true)
	SetBlipColour(CellsBlip, 4)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Cells")
	EndTextCommandSetBlipName(CellsBlip)

	if TimeBlip ~= nil then
		RemoveBlip(TimeBlip)
	end
	TimeBlip = AddBlipForCoord(Config.JailLocations["freedom"].coords.x, Config.JailLocations["freedom"].coords.y, Config.JailLocations["freedom"].coords.z)

	SetBlipSprite (TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale  (TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Check time")
	EndTextCommandSetBlipName(TimeBlip)

	if ShopBlip ~= nil then
		RemoveBlip(ShopBlip)
	end
	ShopBlip = AddBlipForCoord(Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z)

	SetBlipSprite (ShopBlip, 52)
	SetBlipDisplay(ShopBlip, 4)
	SetBlipScale  (ShopBlip, 0.5)
	SetBlipAsShortRange(ShopBlip, true)
	SetBlipColour(ShopBlip, 0)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Canteen")
	EndTextCommandSetBlipName(ShopBlip)
end

--[[
	Locations n stuff
]]
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		if isLoggedIn then
			if inJail then
				local pos = GetEntityCoords(PlayerPedId())
				if #(pos - Config.JailLocations["freedom"].coords.xyz) < 1.5 then
					BJCore.Functions.DrawText3D(Config.JailLocations["freedom"].coords.x, Config.JailLocations["freedom"].coords.y, Config.JailLocations["freedom"].coords.z, "[~g~E~w~] Check time")
					if IsControlJustReleased(0, 38) then
						TriggerEvent("prison:client:Leave")
					end
				-- elseif (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.JailLocations["freedom"].coords.x, Config.JailLocations["freedom"].coords.y, Config.JailLocations["freedom"].coords.z, true) < 2.5) then
				-- 	BJCore.Functions.DrawText3D(Config.JailLocations["freedom"].coords.x, Config.JailLocations["freedom"].coords.y, Config.JailLocations["freedom"].coords.z, "Check time")
				end  

				if #(pos - Config.JailLocations["shop"].coords.xyz) < 1.5 then
					BJCore.Functions.DrawText3D(Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, "[~g~E~w~] Canteen")
					if IsControlJustReleased(0, 38) then
                        local ShopItems = {}
                        ShopItems.label = "Prison Canteen"
                        ShopItems.items = Config.CanteenItems
                        ShopItems.slots = #Config.CanteenItems
                        TriggerServerEvent("inventory:server:OpenInventory", "shop", "Prisoncanteen_"..math.random(1, 99), ShopItems)
					end
					-- DrawMarker(2, Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				-- elseif (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, true) < 2.5) then
				-- 	BJCore.Functions.DrawText3D(Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, "Canteen")
				-- 	DrawMarker(2, Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				-- elseif (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, true) < 10) then
				-- 	DrawMarker(2, Config.JailLocations["shop"].coords.x, Config.JailLocations["shop"].coords.y, Config.JailLocations["shop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 255, 55, 22, 222, false, false, false, 1, false, false, false)
				end  
			end
		else
			Citizen.Wait(5000)
		end
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	-- BJCore.Functions.GetPlayerData(function(PlayerData)
	-- 	if PlayerData.metadata["injail"] > 0 then
	-- 		TriggerEvent("prison:client:Enter", PlayerData.metadata["injail"])
	-- 	end
	-- end)
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
	isLoggedIn = false
	inJail = false
	currentJob = nil
	RemoveBlip(currentBlip)
end)

RegisterNetEvent('prison:client:Enter')
AddEventHandler('prison:client:Enter', function(time)
	BJCore.Functions.Notify("You are in prison for "..time.." month(s)", "primary")
	TriggerEvent("chatMessage", "SYSTEM", "warning", "Your items has been confiscated. You'll get everything back once your time is up")
	if not IsScreenFadedOut() then
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
	end
    local gender = "male"
    if BJCore.Functions.GetPlayerData().charinfo.gender == '1' then gender = "female" end
    TriggerEvent("bj-clothing:client:loadOutfit", Config.JailOutfits[gender])
	local RandomStartPosition = Config.JailLocations.spawns[math.random(1, #Config.JailLocations.spawns)]
	FreezeEntityPosition(PlayerPedId(), true)
	SetEntityCoords(PlayerPedId(), RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, 0, 0, 0, false)
	SetEntityHeading(PlayerPedId(), RandomStartPosition.coords.h)
	RequestCollisionAtCoord(RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do RequestCollisionAtCoord(RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9); Citizen.Wait(50) end
    FreezeEntityPosition(PlayerPedId(), false) 
	Citizen.Wait(500)
	print(BJCore.Common.Dump(RandomStartPosition.animation))
	TriggerEvent('animations:client:EmoteCommandStart', {RandomStartPosition.animation})

	inJail = true
	jailTime = time
	currentJob = "electrician"
	TriggerServerEvent("prison:server:SetJailStatus", jailTime)
	TriggerServerEvent("prison:server:SaveJailItems", jailTime)

	TriggerServerEvent("InteractSound_SV:PlayOnSource", "cell", 0.5)

	CreateCellsBlip()
	
	Citizen.Wait(2000)

	DoScreenFadeIn(1000)
	BJCore.Functions.Notify("Jail time mate. Do some work to get some time reduction, current job: "..Config.JailJobs[currentJob], 'primary', 10000)
end)

RegisterNetEvent('prison:client:Leave')
AddEventHandler('prison:client:Leave', function()
	if jailTime > 0 then 
		BJCore.Functions.Notify("You still have "..jailTime.." month(s) in jail")
	else
		jailTime = 0
		TriggerServerEvent("prison:server:SetJailStatus", 0)
		TriggerServerEvent("prison:server:GiveJailItems")
		TriggerEvent("chatMessage", "SYSTEM", "warning", "Your items have been returned to you")
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil
		BJCore.Functions.Notify("You're free! We'll see you real soon...")
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		SetEntityCoords(PlayerPedId(), Config.JailLocations["outside"].coords.x, Config.JailLocations["outside"].coords.y, Config.JailLocations["outside"].coords.z, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), Config.JailLocations["outside"].coords.h)
		TriggerEvent("clothing:client:restoreOutfit")

		Citizen.Wait(500)

		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('prison:client:UnjailPerson')
AddEventHandler('prison:client:UnjailPerson', function()
	if jailTime > 0 then
		TriggerServerEvent("prison:server:SetJailStatus", 0)
		TriggerServerEvent("prison:server:GiveJailItems")
		TriggerEvent("chatMessage", "SYSTEM", "warning", "Your items have been returned to you")
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil
		BJCore.Functions.Notify("You're free! We'll probably see you real soon...")
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		SetEntityCoords(PlayerPedId(), Config.JailLocations["outside"].coords.x, Config.JailLocations["outside"].coords.y, Config.JailLocations["outside"].coords.z, 0, 0, 0, false)
		SetEntityHeading(PlayerPedId(), Config.JailLocations["outside"].coords.h)
		TriggerEvent("clothing:client:restoreOutfit")

		Citizen.Wait(500)

		DoScreenFadeIn(1000)
	end
end)

-- Prison work
currentLocation = 0
currentBlip = nil
isWorking = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if inJail and currentJob ~= nil then 
            if currentLocation ~= 0 then
                if not DoesBlipExist(currentBlip) then
                    CreateJobBlip()
                end
                local pos = GetEntityCoords(PlayerPedId())
                if #(pos - Config.JailLocations.jobs[currentJob][currentLocation].coords.xyz) < 40.0 and not isWorking then
                    DrawMarker(2, Config.JailLocations.jobs[currentJob][currentLocation].coords.x, Config.JailLocations.jobs[currentJob][currentLocation].coords.y, Config.JailLocations.jobs[currentJob][currentLocation].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 150, 200, 50, 222, false, false, false, true, false, false, false)
                    if #(pos - Config.JailLocations.jobs[currentJob][currentLocation].coords.xyz) < 1.0 and not isWorking then
                        isWorking = true
			            exports['mythic_progbar']:Progress({
			                name = "work_electric",
			                duration =  math.random(10000, 20000),
			                label = "Working",
			                useWhileDead = false,
			                canCancel = true,
			                controlDisables = {
			                    disableMovement = true,
			                    disableCarMovement = true,
			                    disableMouse = false,
			                    disableCombat = true,
			                },
			                animation = {
			                    animDict = "anim@gangops@facility@servers@",
			                    anim = "hotwire",
			                    flags = 16,
			                },			                
			            }, function(status)
			                if not status then
	                            isWorking = false
	                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
	                            JobDone()
			                else
	                            isWorking = false
	                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
	                            BJCore.Functions.Notify("Cancelled", "error")
			                end
			            end)                           
                    end
                end
            else
                currentLocation = math.random(1, #Config.JailLocations.jobs[currentJob])
                CreateJobBlip()
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

function JobDone()
    if math.random(1, 100) <= 40 then
        BJCore.Functions.Notify("Good work! You've reduced your sentence")
        jailTime = jailTime - math.random(1, 2)
    end
    local newLocation = math.random(1, #Config.JailLocations.jobs[currentJob])
    while (newLocation == currentLocation) do
        Citizen.Wait(100)
        newLocation = math.random(1, #Config.JailLocations.jobs[currentJob])
    end
    currentLocation = newLocation
    CreateJobBlip()
end

function CreateJobBlip()
    if currentLocation ~= 0 then
        if DoesBlipExist(currentBlip) then
            RemoveBlip(currentBlip)
        end
        currentBlip = AddBlipForCoord(Config.JailLocations.jobs[currentJob][currentLocation].coords.x, Config.JailLocations.jobs[currentJob][currentLocation].coords.y, Config.JailLocations.jobs[currentJob][currentLocation].coords.z)

        SetBlipSprite (currentBlip, 402)
        SetBlipDisplay(currentBlip, 4)
        SetBlipScale  (currentBlip, 0.8)
        SetBlipAsShortRange(currentBlip, true)
        SetBlipColour(currentBlip, 1)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Current Task')
        EndTextCommandSetBlipName(currentBlip)

        local Chance = math.random(100)
        local Odd = math.random(100)
        if Chance == Odd then
            TriggerServerEvent('BJCore:Server:AddItem', 'phone', 1)
            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items["phone"], "add")
            BJCore.Functions.Notify("You found a phone", "success")
        end
    end
end
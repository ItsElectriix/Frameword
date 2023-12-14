local fuelingPos = {
	[1] = vector3(611.20, 2855.85, 40.50),
	[2] = vector3(652.63, 2921.93, 42.47),
	[3] = vector3(652.18, 3014.25, 44.37),
	[4] = vector3(597.75, 3018.73, 42.17),
	[5] = vector3(497.46, 2959.80, 42.47),
    [6] = vector3(542.37, 2876.40, 43.47),
    [7] = vector3(580.70, 2927.57, 41.57), 
    [8] = vector3(695.19, 2886.55, 50.53), 
}

local spawnedPeds = {}
local NPCPos = {
	["start"] = vector4(501.00, -2134.29, 4.92, 207.86),
    ["vehicle"] = vector4(522.48, -2123.36, 5.32, 172.23),
	["sell"] = {
        vector4(-709.37, -906.73, 18.22, 297.85),
        vector4(2671.01, 3283.73, 54.24, 258.68),
    },
    ["transform"] = vector4(589.59, -2718.06, 5.06, 266.47)
}
local isNearFueler = false

local fuelSell = {
    [1] = {
        name = "refinedfuel",
        price = 24,
        amount = 0,
        info = {},
        type = "item",
        slot = 1,
    },
}

local timePerRaw = 5 -- in seconds

local curVeh = nil 
local isFueling = false
Citizen.CreateThread(function()
	while true do
		local sleep = 0
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)
		local isNear = false
        local lastPress = 0
		for k,v in pairs(NPCPos) do
            if type(v) == "vector4" then
                local dist = #(plyPos - v.xyz)
                if k ~= "vehicle" then
        			if dist < 40 then
        				if spawnedPeds[v] == nil or not DoesEntityExist(spawnedPeds[v]) then
                            createJobPed('s_m_m_dockwork_01', v)
        				end
        			else
        				if spawnedPeds[v] ~= nil then
        					DeleteEntity(spawnedPeds[v])
        					spawnedPeds[v] = nil
        				end
        			end
                end   
    			if dist < 2 then
    				isNear = true
    				local text = nil
                    if k == "transform" then
                        text = "[~g~E~w~] Refine Raw Fuel"
                    elseif k == "vehicle" then
                        if IsPedInAnyVehicle(PlayerPedId(), true) then 
                            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                            if veh == curVeh then
                                text = "[~g~E~w~] Return Vehicle"
                            end
                        end
                    else
                        text = "Fueler"
                    end
                    if text ~= nil then
        				BJCore.Functions.DrawText3D(v.x, v.y, v.z+1.0, text)
                    end
                    if k == "vehicle" or k == "transform" then
                        if text == "[~g~E~w~] Return Vehicle" then
                            if BJCore.Functions.GetKeyPressed("E") then
                                DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                                curVeh = nil
                                stage = 0
                                isFueling = false
                                stage = "clear"
                                createBlips()
                                stage = 0
                                BJCore.Functions.Notify("Fueler run complete", "success")
                            end
                        else
                            if BJCore.Functions.GetKeyPressed("E") and GetGameTimer() - lastPress >= 1000 then
                                lastPress = GetGameTimer()
                                BJCore.Functions.TriggerServerCallback("jobs:server:transformRaw", function(amount)
                                    if amount > 0 then
                                        exports['mythic_progbar']:Progress({
                                            name = "transform_raw_fuel",
                                            duration = timePerRaw*amount*1000,
                                            label = "Refining raw fuel",
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
                                                TriggerServerEvent("jobs:server:convertFinal", amount, "fueler")
                                                BJCore.Functions.Notify("Return vehicle back to start location to complete fueler run", "primary", 7000)
                                                SetNewWaypoint(522.48, -2123.36)
                                            else
                                                BJCore.Functions.Notify("Cancelled", "error")
                                            end
                                        end)
                                    else
                                        BJCore.Functions.Notify("You don't have any raw fuel to refine")
                                    end
                                end, "fueler")
                            end
                        end
    				else
    					if not isNearFueler then
    						isNearFueler = true
    						TriggerEvent('isNearFueler', isNearFueler)
    					end
    				end
    			else
    	            if k == "start" and isNearFueler then
    	            	isNearFueler = false
    	            	TriggerEvent('isNearFueler', isNearFueler)
    	            end
    			end
            end
		end
		if not isNear then sleep = 1000; end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local isNear = false
        for k,v in pairs(NPCPos["sell"]) do
            local dist = #(plyPos - v.xyz)
            if dist < 30 then
                if spawnedPeds[v] == nil or not DoesEntityExist(spawnedPeds[v]) then
                    createJobPed("s_m_m_dockwork_01", v)
                end
                if dist < 2 then
                    isNear = true
                    BJCore.Functions.DrawText3D(v.x, v.y, v.z+1.0, "[~g~E~w~] Sell Oil")
                    if BJCore.Functions.GetKeyPressed("E") then
                        local ShopItems = {}
                        ShopItems.label = "Fuel"
                        ShopItems.items = fuelSell
                        ShopItems.slots = #fuelSell
                        TriggerServerEvent("inventory:server:OpenInventory", "saleshop", "Itemsale_fuel", ShopItems)
                    end
                end
            else
                if spawnedPeds[v] ~= nil then
                    DeleteEntity(spawnedPeds[v])
                    spawnedPeds[v] = nil
                end
                
            end
        end
        if not isNear then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
end)

function createJobPed(model, pos)
    local phash = GetHashKey(model)
    while not HasModelLoaded(phash) do RequestModel(phash); Citizen.Wait(0); end
    local vped = CreatePed(4, phash, pos, false, true)
    SetEntityVisible(vped, true, false)
    SetBlockingOfNonTemporaryEvents(vped, true)
    SetPedCanPlayAmbientAnims(vped, true)
    SetPedCanRagdollFromPlayerImpact(vped, false)
    SetEntityInvincible(vped, true)
    FreezeEntityPosition(vped, true)
    TaskStartScenarioInPlace(vped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    spawnedPeds[pos] = vped
end

AddEventHandler("fueler:client:toggleFuelRun", function()
	if not isFueling then
        startRawStage()
	else
		BJCore.Functions.Notify("Stopped fuel run", "primary")
        isFueling = false
	end
end)

local curMine = nil
local doPickaxe = false
local stage = 0
function startRawStage()
    BJCore.Functions.Notify("Started fuel run, get into vehicle and go to marked destination", "primary", 5000)
    isFueling = true
    spawnTanker()
    stage = 1
    createBlips()
    local centralPos = vector3(605.68, 2957.97, 40.78)
    local closeNotify = false
    local lastPress = 0
	Citizen.CreateThread(function()
		while isFueling do
			local plyPed = PlayerPedId()
			local plyPos = GetEntityCoords(plyPed)
            local transformNotify = false
            for k,v in pairs(fuelingPos) do
                local dist = #(plyPos - v)
                if dist < 50 then
                    if not closeNotify then
                        closeNotify = true
                        BJCore.Functions.Notify("Collect fuel from marked locations", "primary")
                        DeleteWaypoint()
                        stage = 2
                        createBlips()
                    end
                    if dist < 8 then
                        BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Collect Raw Fuel")
                        if BJCore.Functions.GetKeyPressed("E")  and GetGameTimer() - lastPress >= 1000 then
                            lastPress = GetGameTimer()
                            exports['mythic_progbar']:Progress({
                                name = "collecting_raw_fuel",
                                duration = math.random(4000, 7000),
                                label = "Collecting",
                                useWhileDead = false,
                                canCancel = true,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                },
                                animation = {
                                    animDict = "amb@world_human_bum_wash@male@low@idle_a",
                                    anim = "idle_a",
                                    flags = 14,
                                },
                            }, function(status)
                                if not status then
                                    if not transformNotify then
                                        transformNotify = true
                                        BJCore.Functions.Notify("Go to refiner location to refine raw fuel", "primary", 5000)
                                        SetNewWaypoint(NPCPos["transform"].x, NPCPos["transform"].y)
                                    end
                                    TriggerServerEvent("jobs:server:collect", "fueler")
                                else
                                    BJCore.Functions.Notify("Cancelled", "error")
                                end
                            end)
                        end
                    end
                end
            end
			Citizen.Wait(0)
		end
	end)
end

function spawnTanker()
    BJCore.Functions.SpawnVehicle('phantom', function(cbVeh)
        curVeh = cbVeh 
       BJCore.Functions.SpawnVehicle('tanker', function(trailer)
           AttachVehicleToTrailer(cbVeh, trailer, 1.1)
       end, NPCPos["vehicle"], true)
        local plate = 'FUEL'..tostring(math.random(100, 999))
        SetVehicleNumberPlateText(cbVeh, plate)
        exports['legacyfuel']:SetFuel(cbVeh, 100.0)
        TriggerEvent('keys:addNew', cbVeh, GetVehicleNumberPlateText(cbVeh))
    end, NPCPos["vehicle"], true)
    while true do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= nil then
            if veh == curVeh then
                BJCore.Functions.Notify("Go to marked location", "primary")
                return
            end
        end
    end
end

local stage1Blip = nil
local stage2Blip = {}
local stage3Blip = nil
function createBlips()
    if stage == 1 then
        stage1Blip = AddBlipForCoord(605.68, 2957.97, 40.78)

        SetBlipSprite (stage1Blip, 1)
        SetBlipDisplay(stage1Blip, 4)
        SetBlipScale  (stage1Blip, 0.8)
        SetBlipAsShortRange(stage1Blip, true)
        SetBlipColour(stage1Blip, 1)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Raw Fuel Collection')
        EndTextCommandSetBlipName(stage1Blip)
        SetNewWaypoint(605.68, 2957.97)
    elseif stage == 2 then
        RemoveBlip(stage1Blip)
        stage1Blip = nil

        for k,v in pairs(fuelingPos) do
            curBlip = AddBlipForCoord(v.x, v.y, v.z)

            SetBlipSprite (curBlip, 1)
            SetBlipDisplay(curBlip, 4)
            SetBlipScale  (curBlip, 0.8)
            SetBlipAsShortRange(curBlip, true)
            SetBlipColour(curBlip, 1)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName('Raw Fuel')
            EndTextCommandSetBlipName(curBlip)
            table.insert(stage2Blip, curBlip)
        end
        stage3Blip = AddBlipForCoord(NPCPos["transform"].x, NPCPos["transform"].y, NPCPos["transform"].z)

        SetBlipSprite (stage3Blip, 1)
        SetBlipDisplay(stage3Blip, 4)
        SetBlipScale  (stage3Blip, 0.8)
        SetBlipAsShortRange(stage3Blip, true)
        SetBlipColour(stage3Blip, 1)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Refiner')
        EndTextCommandSetBlipName(stage3Blip)
    elseif stage == "clear" then
        for k,v in pairs(stage2Blip) do
            RemoveBlip(v)
        end
        stage2Blip = {}
        RemoveBlip(stage3Blip)
        stage3Blip = nil
    end
end

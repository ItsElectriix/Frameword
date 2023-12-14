local miningPos = {
	[1] = vector4(2996.04, 2799.63, 43.93, 304.27),
	[2] = vector4(3002.71, 2788.59, 44.41, 288.37),
	[3] = vector4(3004.14, 2775.41, 43.01, 256.59),
	[4] = vector4(3002.84, 2759.29, 43.11, 239.01),
	[5] = vector4(2996.27, 2750.31, 44.29, 170.70),
    [6] = vector4(2998.59, 2752.19, 43.95, 241.34),
    [7] = vector4(2974.03, 2774.27, 38.15, 70.37)
}

local jobPos = {
	["start"] = vector4(2954.06, 2751.77, 42.48, 224.62),
	["wash"] = vector3(1890.1383, 298.16482, 163.09254),
}

local spawnedPeds = {}
local isMining, enabledMiningJob = false, false

function miningTick()
	Citizen.CreateThread(function()
		while enabledMiningJob do
			local plyPos = GetEntityCoords(PlayerPedId())
			local minPos = jobPos["start"]
			local dist = #(plyPos - minPos.xyz)
			if dist < 40 then
				if spawnedPeds[minPos] == nil or not DoesEntityExist(spawnedPeds[minPos]) then
					local phash = GetHashKey('s_m_y_construct_02')
					while not HasModelLoaded(phash) do RequestModel(phash); Citizen.Wait(0); end
					local vped = CreatePed(4, phash, minPos, false, true)
					SetEntityVisible(vped, true, false)
					SetBlockingOfNonTemporaryEvents(vped, true)
					SetPedCanPlayAmbientAnims(vped, true)
					SetPedCanRagdollFromPlayerImpact(vped, false)
					SetEntityInvincible(vped, true)
					FreezeEntityPosition(vped, true)
					TaskStartScenarioInPlace(vped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
					spawnedPeds[minPos] = vped
				end
				if dist < 2 then
					local text = "[~g~E~w~] Start Mining"
					if isMining then text = "[~g~E~w~] Stop Mining"; end
					BJCore.Functions.DrawText3D(minPos.x, minPos.y, minPos.z+1.0, text)
					if BJCore.Functions.GetKeyPressed("E") then
						if not isMining then
							startMining()
						else
							BJCore.Functions.Notify("Mining stopped", "primary")
							isMining = false
						end
					end
				end
			else
				Citizen.Wait(1000)
				if dist > 200 and isMining then
					BJCore.Functions.Notify("Moved too far away from quarry. Mining stopped", "error")
					isMining = false
				end
				if spawnedPeds[minPos] ~= nil then
					DeleteEntity(spawnedPeds[minPos])
					spawnedPeds[minPos] = nil
				end
			end
			Citizen.Wait(0)
		end
	end)
end


AddEventHandler("mining:client:toggleMining", function()
	if not enabledMiningJob then
		enabledMiningJob = true
		createJobBlips()
        miningTick()
	else
		BJCore.Functions.Notify("Disabled mining job", "primary")
        isMining = false
        enabledMiningJob = false
        for k,v in pairs(jobBlips) do
        	RemoveBlip(v)
        end
        jobBlips = {}
	end
end)

local jobBlips = {}
function createJobBlips()
    quarryBlip = AddBlipForCoord(jobPos["start"])

    SetBlipSprite (quarryBlip, 162)
    SetBlipDisplay(quarryBlip, 4)
    SetBlipScale  (quarryBlip, 0.8)
    SetBlipAsShortRange(quarryBlip, true)
    SetBlipColour(quarryBlip, 47)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Mining Quarry')
    EndTextCommandSetBlipName(quarryBlip)
    table.insert(jobBlips, quarryBlip)

    washBlip = AddBlipForCoord(jobPos["wash"])
    washRadBlip = AddBlipForRadius(jobPos["wash"], 70.0)
    SetBlipSprite(washRadBlip, 9)
    SetBlipColour(washRadBlip, 0)
    SetBlipAlpha(washRadBlip, 125)
    SetBlipSprite (washBlip, 162)
    SetBlipDisplay(washBlip, 4)
    SetBlipScale  (washBlip, 0.8)
    SetBlipAsShortRange(washBlip, true)
    SetBlipColour(washBlip, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Stone Washing')
    EndTextCommandSetBlipName(washBlip)
    table.insert(jobBlips, washBlip)
    table.insert(jobBlips, washRadBlip)
end

local curMine, doPickaxe, curBlip = nil, false, nil
function startMining()
	if not BJCore.Functions.HasItem("pickaxe") then BJCore.Functions.Notify("You need a pickaxe to do this job", "error") return; end
    isMining = true
    BJCore.Functions.Notify("Started mining, go to task location to begin", "primary", 4000)
	Citizen.CreateThread(function()
		while isMining do
			local plyPed = PlayerPedId()
			local plyPos = GetEntityCoords(plyPed)
			if curMine == nil then
				curMine = miningPos[math.random(#miningPos)]
				createMineBlip(curMine)
			end
			local dist = #(plyPos - curMine.xyz)
			if dist < 30 then
				DrawMarker(2, curMine.x, curMine.y, curMine.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 150, 200, 50, 222, false, false, false, true, false, false, false)
				if dist < 2 then
	                BJCore.Functions.DrawText3D(curMine.x, curMine.y, curMine.z, "[~g~E~w~] Mine")
	                if BJCore.Functions.GetKeyPressed("E") then
	                	TaskAchieveHeading(plyPed, curMine.w, 1000)
	                	Citizen.Wait(1000)
	                    local model = loadModel(GetHashKey("prop_tool_pickaxe"))
	                    local axe = CreateObject(model, plyPos, true, false, false)
	                    AttachEntityToEntity(axe, plyPed, GetPedBoneIndex(plyPed, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)
	                    doPickaxe = true
	                    doMining(plyPed)
                    	DeleteEntity(axe)
                    	FreezeEntityPosition(plyPed, false)
                    	ClearPedTasks(plyPed)
                    	curMine = miningPos[math.random(#miningPos)]
                    	createMineBlip(curMine)
	                end
	            end
			else
                Citizen.Wait(500)
			end
			Citizen.Wait(0)
		end
	    if curBlip ~= nil and DoesBlipExist(curBlip) then
	    	RemoveBlip(curBlip)
	    	curBlip = nil
	    end
	    curMine = nil
	end)
end

function doMining(plyPed)
    local percent = 0
    BJCore.Functions.PersistentNotify("start", "pickaxe", "[MOUSE 1] to pickaxe | Completion: "..percent.."%", "primary")
    while doPickaxe do
        Citizen.Wait(0)
        SetCurrentPedWeapon(plyPed, GetHashKey('WEAPON_UNARMED'))
        FreezeEntityPosition(plyPed, true)
        DisableControlAction(0, 24, true)
        if IsDisabledControlJustReleased(0, 24) then
            local dict = loadDict('melee@hatchet@streamed_core')
            TaskPlayAnim(plyPed, dict, 'plyr_rear_takedown_b', 8.0, -8.0, -1, 2, 0, false, false, false)
            local timer = GetGameTimer() + 800
            while GetGameTimer() <= timer do Citizen.Wait(0) DisableControlAction(0, 24, true); end
            local adder = percent + math.random(3, 8)
            if adder > 100 then adder = 100;  end
            percent = adder
            BJCore.Functions.PersistentNotify("start", "pickaxe", "[MOUSE 1] to pickaxe | Completion: "..percent.."%", "primary")
            ClearPedTasks(plyPed)
            if percent == 100 then
            	Citizen.Wait(500)
	            doPickaxe = false
                BJCore.Functions.Notify("Task complete", "success")
                BJCore.Functions.PersistentNotify("end", "pickaxe")
                TriggerServerEvent("mining:server:manageItems", "mine")
            end
        elseif IsControlJustReleased(0, 194) then
            doPickaxe = false
            BJCore.Functions.Notify("Cancelled")
            break
        end
    end
end

function createMineBlip(pos)
    if curBlip ~= nil and DoesBlipExist(curBlip) then
    	RemoveBlip(curBlip)
    end
    curBlip = AddBlipForCoord(pos.x, pos.y, pos.z)

    SetBlipSprite (curBlip, 1)
    SetBlipDisplay(curBlip, 4)
    SetBlipScale  (curBlip, 0.8)
    SetBlipAsShortRange(curBlip, true)
    SetBlipColour(curBlip, 1)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Current Task')
    EndTextCommandSetBlipName(curBlip)
end

function loadModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) RequestModel(model) end
    return model
end

function loadDict(dict, anim)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(0) RequestAnimDict(dict) end
    return dict
end

local isWashingStone = false
RegisterNetEvent("mining:client:washStone")
AddEventHandler("mining:client:washStone", function()
	local dist = #(GetEntityCoords(PlayerPedId()) - jobPos["wash"])
	if dist > 80 then BJCore.Functions.Notify("You must be in the stone washing area", "error") return; end
	if not IsEntityInWater(PlayerPedId()) then BJCore.Functions.Notify("You need to be in water to wash stones", "error") return; end
	if BJCore.Functions.HasItem("stone") then
        isWashingStone = true
	    Citizen.CreateThread(function()
	        while isWashingStone do
	            local busy = true
	            exports['mythic_progbar']:Progress({
	                name = "wash_stone",
	                duration = math.random(7000, 12000),
	                label = "Washing",
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
	                	if dist > 80 then BJCore.Functions.Notify("You've moved away from washing area") return; end
                        TriggerServerEvent("mining:server:manageItems", "wash")
	                else
	                    BJCore.Functions.Notify("Cancelled", "error")
	                    return
	                end
	                busy = false
	            end)
	            while busy do Citizen.Wait(500); end
	            Citizen.Wait(0)
	        end
	    end)
	end
end)

RegisterNetEvent("mining:client:cancelAction")
AddEventHandler("mining:client:cancelAction", function()
	isMining, isWashingStone = false, false
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(data)
    if isMining then
    	if not hasItem(data.items, "pickaxe") then
    		BJCore.Functions.Notify("You no longer have a pickaxe. Mining stopped", "error") isMining = false
    	end
	elseif isWashingStone then
    	if not hasItem(data.items, "stone") then
    		BJCore.Functions.Notify("You no longer have stone to wash", "error") isWashingStone = false
    	end
	end 
end)

function hasItem(tab, item)
	local found = false
    for k,v in pairs(tab) do
        if v.name == item then
        	found = true
        	break
        end
    end
    return found
end
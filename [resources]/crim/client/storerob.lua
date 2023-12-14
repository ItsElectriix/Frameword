DecorRegister("Crim.isRobbable", 2)
local safeEnabled = false
local canRob = false
RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    if amount and amount ~= nil and amount >= Config.StoreRobMinCops then
        canRob = true
    else
        canRob = false
    end	
end)

storeData = {}
start = function()
	while not BJCore do Wait(1000); end
	while not BJCore.Functions.IsPlayerLoaded do Wait(1000); end
    BJCore.Functions.TriggerServerCallback('storerobbery:getStartData', function(data)
		storeData = data
	end)
end

RegisterNetEvent("storerobbery:eventHandler")
AddEventHandler("storerobbery:eventHandler", function(event, eventData)
	if event == "create_bag" then
		BagThread(eventData)
	else
		-- print("Wrong event handler.")
	end
end)

RegisterNetEvent("storerobbery:syncData")
AddEventHandler("storerobbery:syncData", function(data)
    storeData = data
end)

local storeID = {}
local recentSpawn = false
local myspawns = {}
Citizen.CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        if not IsPedInAnyVehicle(PlayerPedId(), true) then
            local minDist = 999.0
            for i = 1, #storeData do
                local v3 = vector3(storeData[i]["pos"].x, storeData[i]["pos"].y, storeData[i]["pos"].z)
                local storeDist = #(GetEntityCoords(plyPed) - v3)
                if storeDist < minDist then
                    minDist = storeDist
                    storeID = i
                end
            end
            if minDist > 30.0 then
                storeID = 0
                Wait(math.ceil(minDist*5))
                if #myspawns > 0 then
                    for i = 1, #myspawns do
                        if DoesEntityExist(myspawns[i]) then TriggerServerEvent('storerobbery:requestDelete', PedToNet(myspawns[i])); end
                    end
                end
                myspawns = {}
                
            else
                local inveh = IsPedInAnyVehicle(plyPed, true)
                if not recentSpawn and not inveh then
                    SpawnPed(storeID)
                end
                
                Wait(1)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function SpawnPed(i)
	recentSpawn = true
	pedType = GetHashKey("mp_m_shopkeep_01")
	local storePos = storeData[i]["pos"]

    RequestModel(pedType)
    while not HasModelLoaded(pedType) do Citizen.Wait(0); end
    local IsPedNearCoords = IsPedNearCoords(storePos)
    if not IsPedNearCoords then
    	if GetPedType(pedType) ~= nil then
			local shopPed = CreatePed(GetPedType(pedType), pedType, storePos, 1, 1)
			DecorSetBool(shopPed, "Crim.isRobbable", true)
			myspawns[#myspawns+1] = shopPed

			SetPedKeepTask(shopPed, true)
			SetPedDropsWeaponsWhenDead(shopPed,false)
			SetBlockingOfNonTemporaryEvents(shopPed, true)
	        --SetPedFleeAttributes(shopPed, 0, 0)
	        --SetPedCombatAttributes(shopPed, 46, true)
	        SetPedSeeingRange(shopPed, 0.0)
	        SetPedHearingRange(shopPed, 0.0)
	        SetPedAlertness(shopPed, 0.0)
			SetEntityAsMissionEntity(shopPed, true, true)
			SetNetworkIdCanMigrate(PedToNet(shopPed), true)
		end
	end
	SetModelAsNoLongerNeeded(pedType)
	Citizen.Wait(10000)
	recentSpawn = false
end

function IsPedNearCoords(storePos)
    local handle, ped = FindFirstPed()
    local pedfound = false
    local success
    repeat
        local pos = GetEntityCoords(ped)
        local v3 = vector3(storePos.x, storePos.y, storePos.z)
        local dist = #(v3 - pos)

        if dist < 5.0 then
        	if IsEntityDead(ped) and not IsPedAPlayer(ped) then TriggerServerEvent('storerobbery:requestDelete', PedToNet(ped)); end
        	pedfound = true
        end
        
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    if pedfound then

    else

    end
    return pedfound
end

RegisterNetEvent("storerobbery:deletePed")
AddEventHandler("storerobbery:deletePed", function(ped)
	local lped = NetToPed(ped)
	SetEntityAsMissionEntity(lped, true, true)
	NetworkRequestControlOfEntity(lped)
	while not NetworkHasControlOfEntity(lped) do NetworkRequestControlOfEntity(lped); Citizen.Wait(0); end
	DeleteEntity(lped)
end)

Citizen.CreateThread(function()
	Citizen.Wait(100)
	while true do
		local sleepThread = 500
		
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)
		if not IsPedInAnyVehicle(PlayerPedId(), true) then
            for storeID, storeData in pairs(storeData) do
                local dstCheck = #(pedCoords - storeData['pos'].xyz)
                
                if dstCheck <= 10.0 then
                    sleepThread = 5

                    if IsPedArmed(ped, 7) then
                        local isAiming, entityFound, entityAimingAt = IsPlayerFreeAiming(PlayerId()), GetEntityPlayerIsFreeAimingAt(PlayerId())
                        -- Support for melee weapons
                        if not isAiming then
                        	isAiming = IsPedInMeleeCombat(PlayerPedId())
                        end
                        if not entityFound then
                        	entityFound, entityAimingAt = GetPlayerTargetEntity(PlayerId())
                        end                 

                        if isAiming then
                            if entityFound and GetEntityModel(entityAimingAt) == Config.ClerkData["model"] then
                                if not canRob then
                                    BJCore.Functions.Notify('Not enough police online to do this','error')
                                    sleepThread = 5000
                                else
                                	print("robbed", tostring(storeData['robbed']))
                                	print("robbed type", type(storeData['robbed']))
                                    if not storeData['robbed'] then 
                                        if DecorGetBool(entityAimingAt, "Crim.isRobbable") then
                                            StartRobberyThread(entityAimingAt)
                                        else
                                            BJCore.Functions.Notify('Can\'t rob this clerk right now','error')
                                            sleepThread = 5000
                                        end
                                    else
                                        BJCore.Functions.Notify('Can\'t rob this store right now','error')
                                        sleepThread = 5000
                                    end
                                end
                            end
                        end
                    end
                end	
            end
        else
            Citizen.Wait(500)
        end
	  	Citizen.Wait(sleepThread)
	end
end)

Citizen.CreateThread(function(...) start(...); end)

GlobalFunction = function(event, data)
    local options = {
        event = event,
        data = data
    }

    TriggerServerEvent("storerobbery:globalEvent", options)
end

getClosestStore = function()
    local closest,closestDist
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(storeData) do
        local v3 = vector3(v["pos"].x, v["pos"].y, v["pos"].z)
	    local dist =  #(pos - v3)
	    if not closestDist or dist < closestDist then
		    closestDist = dist
		    closest = k
		end
	end
    if closest and closestDist then
        return closest,closestDist
    else
        return false,99999
    end
end

StartRobberyThread = function(pedEntity)
	if IsPedDeadOrDying(pedEntity) then DecorSetBool(pedEntity, "Crim.isRobbable", false) return end
	local clerkCoords = GetEntityCoords(pedEntity)
	TriggerServerEvent("bj-log:server:CreateLog", "crim", "Store Robbery", "green", "**"..PlayerData.name.."** ("..PlayerData.citizenid..") has started a store robbery at coords: "..clerkCoords)

	RequestNetworkControl({
		pedEntity
	})

	DecorSetBool(pedEntity, "Crim.isRobbable", false)

	local scaredPercent = 0

	TriggerServerEvent('MF_Trackables:Notify', 'Shop Robbery in Progress', clerkCoords, 'police', 'bank')
	TriggerServerEvent('storerobbery:NotifyPolice', clerkCoords)

    if math.random(100) <= 50 then
        TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 2))
    end 

	while scaredPercent < 100 do
		Citizen.Wait(0)

		if not IsEntityPlayingAnim(pedEntity, "missheist_agency2ahands_up", "handsup_anxious", 3) then
			PlayAnimation(pedEntity, "missheist_agency2ahands_up", "handsup_anxious", { ["flag"] = 11 })
		end

		if IsPedDeadOrDying(pedEntity) then
			return
		end

		local dist = #(clerkCoords - GetEntityCoords(PlayerPedId()))
		if dist > 10 then
			DecorSetBool(pedEntity, "Crim.isRobbable", true)
			BJCore.Functions.Notify('You\'ve moved too far away from the store clerk','error')
			return
		end

		local isAiming, entityFound, entityAimingAt = IsPlayerFreeAiming(PlayerId()), GetEntityPlayerIsFreeAimingAt(PlayerId())

		if isAiming then
			if IsPedShooting(PlayerPedId()) then
				scaredPercent = scaredPercent + 0.7
			end

			if entityFound and entityAimingAt == clerk then
				scaredPercent = scaredPercent + 0.10
			end

			scaredPercent = scaredPercent + 0.01
		else
			scaredPercent = scaredPercent + 0.01
		end

		DrawTimerBar(scaredPercent > 100 and 100 or scaredPercent)
	end
	TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 5))

	SetStreamedTextureDictAsNoLongerNeeded("timerbars")

	RobPed(pedEntity)
end

RobPed = function(pedEntity)
    local store = getClosestStore()
    TriggerServerEvent("storerobbery:setRobbed",store)
	local closestTill = GetClosestObjectOfType(GetEntityCoords(pedEntity), 4.0, 303280717, false)

	if not DoesEntityExist(closestTill) then
		return
	end

	LoadModels({
		GetHashKey("p_poly_bag_01_s"),
		"mp_am_hold_up"
	})
	
	local cashBag = CreateObject(GetHashKey("p_poly_bag_01_s"), GetEntityCoords(closestTill) - vector3(0.0, 0.0, 5.0), true)

	RequestNetworkControl({
		pedEntity,
		closestTill,
		cashBag
	})

	local scene = NetworkCreateSynchronisedScene(GetEntityCoords(closestTill) - vector3(0.0, 0.0, 0.1), GetEntityRotation(closestTill) + vector3(0.0, 0.0, -180.0), 2, false, false, 1065353216, 0, 1.3)
        
	NetworkAddPedToSynchronisedScene(pedEntity, scene, "mp_am_hold_up", "holdup_victim_20s", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(cashBag, scene, "mp_am_hold_up", "holdup_victim_20s_bag", 4.0, -8.0, 1)
	NetworkAddEntityToSynchronisedScene(closestTill, scene, "mp_am_hold_up", "holdup_victim_20s_till", 4.0, -8.0, 1)
	
	NetworkStartSynchronisedScene(scene)

	local started = GetGameTimer()

	while GetGameTimer() - started < 15000 do
		Citizen.Wait(5)

		if IsPedDeadOrDying(pedEntity) then
			DeleteEntity(cashBag)

			return
		end
	end

	GlobalFunction("create_bag", { ["cash"] = math.random(Config.ClerkData["cash"][1], Config.ClerkData["cash"][2]), ["networkedBag"] = ObjToNet(cashBag) })
	BJCore.Functions.Notify("The shop clerk mumbles: 'I have no more cash on me, try the cash registers!",'primary',5000)
	BJCore.Functions.TriggerServerCallback("crim:server:checkForIntel", function(has)
		if has then
			BJCore.Functions.Notify("You have intel for this store - look for the safe!", "success")
			safeEnabled = true
			SafeThread(store)
		end
	end, 'store', store)
	
	Wait(1000)
	
	CleanupModels({
		GetHashKey("p_poly_bag_01_s"),
		"mp_am_hold_up"
	})
	local rand = math.random()
	if rand <= 0.7 then
		local started = GetGameTimer()

		while GetGameTimer() - started < 5000 do
			Citizen.Wait(5)
	
			if IsPedDeadOrDying(pedEntity) then
				return
			end
		end
		SetPedDropsWeaponsWhenDead(pedEntity, false)
		GiveWeaponToPed(pedEntity, GetHashKey("weapon_dbshotgun"), 1000, false, true)

		local relHash = GetHashKey("HATES_PLAYER")
		local plyHash = GetHashKey("PLAYER")
		local copHash = GetHashKey("COP")

		SetRelationshipBetweenGroups(5, relHash, plyHash)
		SetRelationshipBetweenGroups(5, plyHash, relHash)
		SetRelationshipBetweenGroups(2, copHash, relHash)
		SetRelationshipBetweenGroups(2, relHash, copHash)

		SetPedRelationshipGroupHash(pedEntity, relHash)
		SetPedRelationshipGroupDefaultHash(pedEntity, relHash)
		ClearPedTasksImmediately(pedEntity)
		SetEntityMaxHealth(pedEntity, 350)
		SetEntityHealth(pedEntity, 350)
		SetPedSuffersCriticalHits(pedEntity, false)

		TaskCombatPed(pedEntity, PlayerPedId(), 0, 16)
	end
end

local UsingSafe = false
function SafeThread(store)
	Citizen.CreateThread(function()
		while safeEnabled do
            local dist = #(GetEntityCoords(PlayerPedId()) - Config.StoreSafes[store])
            if dist <= 2 then
            	BJCore.Functions.DrawText3D(Config.StoreSafes[store].x, Config.StoreSafes[store].y, Config.StoreSafes[store].z, "[~r~E~s~] Crack Safe")
            	if BJCore.Functions.GetKeyPressed('E') then
				    BJCore.Functions.TriggerServerCallback('fibheist:CheckInvCount', function(itemCount)
				        if itemCount > 0 then
					        BJCore.Functions.TriggerServerCallback("crim:server:checkStoreSafe", function(canUse)
					            if canUse then
						            if math.random(100) <= 50 then
						                TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
						            end          
						            if math.random(1, 100) <= 35 and not exports["crim"]:IsWearingGloves() then
						                TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
						            end         
						            local plyPed = PlayerPedId()
						            FreezeEntityPosition(plyPed,true)
						            local animDict = "mini@safe_cracking"
						            local animName = "dial_turn_anti_fast_3"
						            while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
						            TaskPlayAnim(plyPed, animDict, animName, 1.0, 1.0, -1, 2, 0, 0, 0)
						            CheckForDamage(store)
						            UsingSafe = true
						            TriggerEvent('bj_minigames:start', 'Safecrack', { combinations = 6, timeout = 65000 }, function(data)
						                ClearPedTasks(plyPed)
						                FreezeEntityPosition(plyPed,false)
										TriggerServerEvent('crim:server:RewardStoreSafe', store)
						                UsingSafe = false
						                safeEnabled = false
						            end, function(data)
							            BJCore.Functions.Notify("Failed. Safe's extra security enabled", "error")
						                ClearPedTasks(plyPed)
						                FreezeEntityPosition(plyPed,false)
						                TriggerServerEvent('fibheist:ChanceRemove', 'stethoscope')
						                if math.random(100) <= 50 then
							                TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
						                end
						                UsingSafe = false
						                safeEnabled = false
						            end)
					            else
						            exports['core']:SendAlert('error', 'Somebody has already cracked this safe', 2500)
					            end
					        end, store)
				        else
					        BJCore.Functions.Notify("You don't have the right tools to attempt this", "error")
				        end
				    end, 'stethoscope')
            	end
            end
			Citizen.Wait(0)
		end
	end)
end

function CheckForDamage(store)
  Citizen.CreateThread(function()
    while UsingSafe do
      local plyPed = PlayerPedId()
      if IsPedBeingStunned(plyPed) or HasEntityBeenDamagedByAnyPed(plyPed) then
        print("stunned or damaged fam")
        ClearPedTasks(plyPed)
        FreezeEntityPosition(plyPed, false)
        TriggerEvent('bj_minigames:stop', 'Safecrack')
        TriggerServerEvent('crim:server:ResetStoreSafe', store)
        BJCore.Functions.Notify("Safe cracking interrupted. Cracking cancelled", "error")
		break
      end
      Citizen.Wait(1)
    end
  end)
end

BagThread = function(bagData)

	Citizen.CreateThread(function()
		if not NetworkDoesEntityExistWithNetworkId(bagData["networkedBag"]) then return end

		local bagEntity = NetToObj(bagData["networkedBag"])

		while DoesEntityExist(bagEntity) do
			local sleepThread = 500

			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)

			local bagCoords = GetEntityCoords(bagEntity)

			local distanceCheck = #(pedCoords - bagCoords)
		
			if distanceCheck <= 1.1 then
				sleepThread = 5

				local displayText = "~INPUT_DETONATE~ to grab " .. bagData["cash"] .. " cash rolls"

				BJCore.Functions.DisplayHelpText(displayText)

				if IsControlJustPressed(0, 47) then
					PlayAnimation(PlayerPedId(), "pickup_object", "pickup_low", { ["speed"] = 8.0, ["speedMultiplier"] = 8.0, ["duration"] = -1, ["flag"] = 16 })
					
					Citizen.Wait(500)

					RequestNetworkControl({
						bagEntity
					})

					AttachEntityToEntity(bagEntity, ped, GetPedBoneIndex(ped, 6286), 0.1, -0.11, 0.08, 0.0, -75.0, -75.0, 1, 1, 0, 0, 2, 1)

					Citizen.Wait(900)

					if DoesEntityExist(bagEntity) then
			            if math.random(100) <= 30 then
			                TriggerServerEvent('bj-hud:Server:GainStress', math.random(1, 3))
			            end							

						TriggerServerEvent("storerobbery:receiveBagCash", bagData["cash"], storeID)
		                if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
		                    TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
		                end

						DeleteObject(bagEntity)
					end
					registersThread()
				end
			end

			Citizen.Wait(sleepThread)
		end
	end)
end

local registerCount = 0
local robbedRegisters = {}
local eventStarted = false
local interacting = false
local alertSend = false
registersThread = function()
	eventStarted = true
	local startCoords = GetEntityCoords(PlayerPedId())
	local spawnSafe = false
	while eventStarted do

		local curCoords = GetEntityCoords(PlayerPedId())
		local registerObject = GetClosestObjectOfType(curCoords, 2.0, 303280717, 0, 0, 0)
		if registerObject and not robbedRegisters[registerObject] and not interacting then
			local objCoords = GetEntityCoords(registerObject)
			if objCoords ~= vector3(0,0,0) then
				BJCore.Functions.DrawText3D(objCoords.x,objCoords.y,objCoords.z,'[~r~H~s~] Rob Cash Register',0.7)
				if #(GetEntityCoords(PlayerPedId()) - objCoords) < 1.5 then
					if IsControlJustPressed(0,74) then
						BJCore.Functions.TriggerServerCallback('storerobbery:GetLockpickCount', function(count)
							if count and count > 0 then
				                if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
				                    TriggerServerEvent("evidence:server:CreateFingerDrop", GetEntityCoords(PlayerPedId()))
				                end 						
								TaskTurnPedToFaceCoord(PlayerPedId(),objCoords,-1)
								FreezeEntityPosition(PlayerPedId(), true)
								interacting = true
								TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = 3, speed = 5, attempts = 1, stages = math.random(3,5), stageTimeout = 3000 }, function(data)
									TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
									TriggerEvent('storerobbery:LockpickSuccess')
								   
								end, function(data)
									TriggerServerEvent('fibheist:ChanceRemove', 'lockpick')
									TriggerEvent('storerobbery:LockpickFail')
									notifyRegisters(objCoords)
								end)
								if math.random(100) <= 50 then
						            TriggerEvent("evidence:client:SetStatus", "scratchhands", 1200)
						        end
							else
		                        BJCore.Functions.Notify('You don\'t have any lockpicks','error')
							end
						end)
						local curCoords = GetEntityCoords(PlayerPedId())
					end
				end
			end
		end
		if #(curCoords - startCoords) > 25.0 then
			eventStarted = false
			safeEnabled = false
		end
		if registerCount >= 2 then
			eventStarted = false
		end
		if not eventStarted then interacting = false; registerCount = 0; for k in pairs(robbedRegisters) do robbedRegisters[k] = nil; end; end

		Wait(1)
	end
end

function notifyRegisters(pos)
	if alertSend then return; end
	TriggerServerEvent('MF_Trackables:Notify', 'Shop Robbery in Progress', pos, 'police', 'bank')
	TriggerServerEvent('storerobbery:NotifyPolice', pos)
	alertSend = true
    SetTimeout(1 * (60 * 1000), function()
        alertSend = false
    end)
end

RegisterNetEvent('storerobbery:NotifyPolice')
AddEventHandler('storerobbery:NotifyPolice', function(data)
    Citizen.CreateThread(function(...)
	    local blipA = AddBlipForRadius(data.x, data.y, data.z, 50.0)
	    SetBlipHighDetail(blipA, true)
	    SetBlipColour(blipA, 1)
	    SetBlipAlpha (blipA, 128)

	    local blipB = AddBlipForCoord(data.x, data.y, data.z)
	    SetBlipSprite               (blipB, 458)
	    SetBlipDisplay              (blipB, 4)
	    SetBlipScale                (blipB, 1.0)
	    SetBlipColour               (blipB, 1)
	    SetBlipAsShortRange         (blipB, true)
	    SetBlipHighDetail           (blipB, true)
	    BeginTextCommandSetBlipName ("STRING")
	    AddTextComponentString      ("Store Robbery In Progress")
	    EndTextCommandSetBlipName   (blipB)

	    local timer = GetGameTimer()
	    while GetGameTimer() - timer < 30000 do
	      Citizen.Wait(0)
	    end

	    RemoveBlip(blipA)
	    RemoveBlip(blipB)
    end)
end)

RegisterNetEvent('storerobbery:LockpickSuccess')
AddEventHandler('storerobbery:LockpickSuccess', function(...)
    BJCore.Functions.Notify('Successfully lockpicked the register','success')
    exports['mythic_progbar']:Progress({
        name = "storerob_loot",
        duration = 30 * 1000,
        label = "Looting Cash Register",
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
          disableInteract = true
        },
        animation = {
          animDict = "mp_take_money_mg",
          anim = "stand_cash_in_bag_loop",
        }
      }, function(status)
        if not status then
        	local plyPed = PlayerPedId()
			ClearPedTasksImmediately(plyPed)
			FreezeEntityPosition(plyPed,false)
			Wait(1000)
			local registerObject = GetClosestObjectOfType(GetEntityCoords(plyPed), 2.0, 303280717, 0, 0, 0)
			registerCount = registerCount + 1
			robbedRegisters[registerObject] = true
			interacting = false
			TriggerServerEvent("storerobbery:receiveBagCash",math.random(Config.ClerkData["cashregister"][1], Config.ClerkData["cashregister"][2]))
			BJCore.Functions.Notify("Looted", "success")
        end
    end)
end)

RegisterNetEvent('storerobbery:LockpickFail')
AddEventHandler('storerobbery:LockpickFail', function(...)
	BJCore.Functions.Notify('Lockpick failed','error')
	local plyPed = PlayerPedId()
	ClearPedTasksImmediately(plyPed)
	FreezeEntityPosition(plyPed,false)
	interacting = false
end)

DrawButtons = function(buttonsToDraw)
	Citizen.CreateThread(function()
		local instructionScaleform = RequestScaleformMovie("instructional_buttons")
	
		while not HasScaleformMovieLoaded(instructionScaleform) do
			Wait(0)
		end
	
		PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")
		PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
		PushScaleformMovieFunctionParameterBool(0)
		PopScaleformMovieFunctionVoid()
	
		for buttonIndex, buttonValues in ipairs(buttonsToDraw) do
			PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
			PushScaleformMovieFunctionParameterInt(buttonIndex - 1)
	
			PushScaleformMovieMethodParameterButtonName(buttonValues["button"])
			PushScaleformMovieFunctionParameterString(buttonValues["label"])
			PopScaleformMovieFunctionVoid()
		end
	
		PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
		PushScaleformMovieFunctionParameterInt(-1)
		PopScaleformMovieFunctionVoid()
		DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)
	end)
end

DrawScriptMarker = function(markerData)
    DrawMarker(markerData["type"] or 1, markerData["pos"] or vector3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, markerData["sizeX"] or 1.0, markerData["sizeY"] or 1.0, markerData["sizeZ"] or 1.0, markerData["r"] or 1.0, markerData["g"] or 1.0, markerData["b"] or 1.0, 100, false, true, 2, false, false, false, false)
end

DrawScriptText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords["x"], coords["y"], coords["z"])
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

PlayAnimation = function(ped, dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

LoadModels = function(models)
	for index, model in ipairs(models) do
		if IsModelValid(model) then
			while not HasModelLoaded(model) do
				RequestModel(model)
	
				Citizen.Wait(10)
			end
		else
			while not HasAnimDictLoaded(model) do
				RequestAnimDict(model)
	
				Citizen.Wait(10)
			end    
		end
	end
end

CleanupModels = function(models)
	for index, model in ipairs(models) do
		if IsModelValid(model) then
			SetModelAsNoLongerNeeded(model)
		else
			RemoveAnimDict(model)  
		end
	end
end

RequestNetworkControl = function(entitys)
	for index, entity in ipairs(entitys) do
		while not NetworkHasControlOfEntity(entity) do
			NetworkRequestControlOfEntity(entity)

			Citizen.Wait(0)
		end
	end
end

DrawTimerBar = function(percent)
	if not percent then percent = 0 end

	local correction = ((1.0 - math.floor(GetSafeZoneSize(), 2)) * 100) * 0.005
	local X, Y, W, H = 1.0 - correction, 1.455 - correction, percent * 0.00085, 0.0125
	
	if not HasStreamedTextureDictLoaded("timerbars") then
		RequestStreamedTextureDict("timerbars")

		while not HasStreamedTextureDictLoaded("timerbars") do
			Citizen.Wait(0)
		end
	end
	
	Set_2dLayer(0)
	DrawSprite("timerbars", "all_black_bg", X, Y, 0.15, 0.0325, 0.0, 255, 255, 255, 180)
	
	Set_2dLayer(1)
	DrawRect(X + 0.0275, Y, 0.085, 0.0125, 100, 0, 0, 180)
	
	Set_2dLayer(2)
	DrawRect(X - 0.015 + (W / 2), Y, W, H, 150, 0, 0, 180)
	
	SetTextColour(255, 255, 255, 180)
	SetTextFont(0)
	SetTextScale(0.3, 0.3)
	SetTextCentre(true)
	SetTextEntry("STRING")
	AddTextComponentString("SCARED")
	Set_2dLayer(3)
	DrawText(X - 0.04, Y - 0.012)
end

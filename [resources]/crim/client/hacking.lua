SpawnedAnonPed = nil
insideAnon = false
shutDoor = false

Citizen.CreateThread(function()
	while true do
		local nearby = false
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)	
		local LastPressed = 0	
    	local doorObj = 0
    	if #(plyPos.xyz - vector3(744.53, -1906.11, 29.66)) < 35 and not shutDoor then
			local doorObj = GetClosestObjectOfType(744.09,-1906.70,29.57,5.0,-1430323452,0,0,0)
			FreezeEntityPosition(doorObj, true)
			SetEntityHeading(doorObj, 265.00)
			shutDoor = true
		else
			shutDoor = false
    	end 
    	if #(plyPos.xyz - Config.StartHackLoc.xyz) < 20 then
            if SpawnedAnonPed == nil or not DoesEntityExist(SpawnedAnonPed) then
				CreateAnonPed(Config.StartHackLoc)
			end
			if #(plyPos.xyz - Config.StartHackLoc.xyz) < 10 then
				nearby = true
				if #(plyPos.xyz - Config.StartHackLoc.xyz) < 1.6 then
                    BJCore.Functions.DrawText3D(Config.StartHackLoc.x,Config.StartHackLoc.y,Config.StartHackLoc.z+1,"[~r~E~s~] Talk")
                    if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - LastPressed > 1000 then
                    	LastPressed = GetGameTimer()
                    	ClearPedTasks(SpawnedAnonPed)
                    	Wait(3000)
                    	TaskStartScenarioInPlace(SpawnedAnonPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
                    	Wait(math.random(5000, 8000))
                        BJCore.Functions.TriggerServerCallback("crim:server:getRep", function(rep)
                        	if rep and rep >= 40 then
                        		BJCore.Functions.Notify("Come through")
                        		FreezeEntityPosition(PlayerPedId(), true)
                        		DoScreenFadeOut(1500)
                        		Wait(1500)
                        		TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
                        		SetEntityCoords(PlayerPedId(), 744.53, -1906.11, 29.66)
                        		SetEntityHeading(PlayerPedId(), 281.06)
                        		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
                        		FreezeEntityPosition(PlayerPedId(), false)
                        		DoScreenFadeIn(1500)
                        		insideAnon = true
								TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hacker Hub", "green", "**"..PlayerData.name.."** has been allowed entry.")
                        		doAnonRoom()
                        	else
                        		BJCore.Functions.Notify("Access is only permitted to those who do tech support", "error", 10000)
								TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hacker Hub", "green", "**"..PlayerData.name.."** has been denied entry.")
                        		Wait(500)
                        		ClearPedTasks(SpawnedAnonPed)
                        		Wait(2500)
                        		TaskGoStraightToCoord(SpawnedAnonPed, Config.StartHackLoc.xyz, 1.0, -1, Config.StartHackLoc.w, 2.0)
                        		Wait(1000)
                        		TaskStartScenarioInPlace(SpawnedAnonPed, 'WORLD_HUMAN_LEANING', 0, true)
                        	end
                        end, 'hackerrep')
                    end                    
				end
			end
		else
			if DoesEntityExist(SpawnedAnonPed) then
				DeleteEntity(SpawnedAnonPed)
				SpawnedAnonPed = nil
			end
    	end
    	if not nearby then Citizen.Wait(1000); end
		Citizen.Wait(1)
	end
end)

-- RegisterCommand("testanon", function()
-- 	insideAnon = true
-- 	doAnonRoom()
-- end)

function CreateAnonPed(pos)
	local modelHash = `a_m_y_stlat_01`
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
    SpawnedAnonPed = CreatePed(4, modelHash, pos, false, true)
    TaskStartScenarioInPlace(SpawnedAnonPed, 'WORLD_HUMAN_LEANING', 0, true)
    SetEntityAsMissionEntity(SpawnedAnonPed, true, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetBlockingOfNonTemporaryEvents(SpawnedAnonPed, true)
    SetEntityInvincible(SpawnedAnonPed, true)
end

local interacting = false
function doAnonRoom()
	local exit = vector3(744.53, -1906.11, 29.66)
	while insideAnon do
		local plyPed = PlayerPedId()
		local plyPos = GetEntityCoords(plyPed)
		if not interacting then
			if #(plyPos - exit) < 2.0 then
				BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~r~E~s~] Exit")
				if IsControlJustReleased(0, Keys["E"]) then
	        		FreezeEntityPosition(PlayerPedId(), true)
	        		DoScreenFadeOut(1500)
	        		Wait(1500)
	        		TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
	        		SetEntityCoords(PlayerPedId(), 387.68, 3585.51, 33.29)
	        		SetEntityHeading(PlayerPedId(), 338.38)
	        		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
	        		FreezeEntityPosition(PlayerPedId(), false)
	        		DoScreenFadeIn(1500)
	        		insideAnon = false
				end
			end

			for k,v in pairs(Config.HackLocations) do
				local dist = #(plyPos - v.pos)
				if dist <= 1.8 then
					BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~r~E~s~] "..v.text)
					if IsControlJustReleased(0, Keys["E"]) then
						checkReq(Config.HackLocations[k])
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end

function checkReq(act)
	local hasLvl, hasCrypto, hasItem = not act.reqLvl, not act.reqCrypto, not act.reqItem
	if act.reqLvl then
		local curLvl = PlayerData.metadata["hackerrep"] or 0
        hasLvl = (curLvl >= act.reqLvl)
	end
	if act.reqItem then
	    for k,v in pairs(PlayerData.items) do
	        if v.name == act.reqItem then
		        hasItem = (v.amount >= act.reqItemAmount)
	        end
	    end
	end	
	if act.reqCrypto then
	    BJCore.Functions.TriggerServerCallback("crim:server:GetCrypto", function(count)
	    	if count and count >= act.reqCrypto then
                hasCrypto = true
	    	end
	    end)
	end
	if hasLvl and hasCrypto and hasItem then
        doAnonAction(act)
	else
		if not hasLvl then
			BJCore.Functions.Notify("You need a higher hacker rep to do this", "error")
		end
		if not hasCrypto then
			BJCore.Functions.Notify("You need "..act.reqCrypto.." IMP(s) to do this", "error")
		end
		if not hasItem then
			BJCore.Functions.Notify("You need x"..act.reqItemAmount.." "..BJCore.Shared.Items[act.reqItem].label.." to do this", "error")
        end
	end
end

function doAnonAction(act)
	interacting = true
	if act.type == "decryptcrypto" then
		TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hacker Hub: Decrypt Cryptostick", "green", "**"..PlayerData.name.."** started crypto stick decryption.")
		TriggerEvent("crypto:client:AttemptDecrypt")
	elseif act.type == "store" then
		TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hacker Hub: Intel", "green", "**"..PlayerData.name.."** started store intel task.")
        local animDict = "mp_fbi_heist"
        local animName = "loop"
        while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
        TaskPlayAnim(PlayerPedId(), animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)	
        exports['mythic_progbar']:Progress({
	        name = "anon_prep",
	        duration = 6000,
	        label = "Preparing",
	        canCancel = false,
	        controlDisables = {
	            disableMovement = true,
	            disableCarMovement = true,
	            disableMouse = false,
	            disableCombat = true,
	            disableInteract = true
	        },
	        clearTasks = false
        }, function(status)
	        if not status then
				FreezeEntityPosition(PlayerPedId(), true)
				local count, busy, failed = 0, false, false
				for i = 1, 3, 1 do
					if failed then break; end
					busy = true
			        TriggerEvent('bj_minigames:start', 'Hackconnect', { difficulty = 5, timer = 15000, background = 1 }, function(data)
			        	count = count + 1
			        	BJCore.Functions.Notify(count.."/3 tasks complete")
						if count == 3 then	
				        	ClearPedTasks(PlayerPedId())
					        FreezeEntityPosition(PlayerPedId(), false)
					        interacting = false
				            TriggerServerEvent("crim:server:rewardIntel", 'store')
						end
						busy = false
			        end, function(data)
				        ClearPedTasks(PlayerPedId())
				        FreezeEntityPosition(PlayerPedId(), false)
				        interacting = false
				        failed = true
				        busy = false
				        BJCore.Functions.Notify("Failed", "error")
			        end)
			        while busy do Citizen.Wait(0); end
			    end	            
	        end
        end)
    elseif act.type == "decrypt" then
		TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hacker Hub: Decrypt", "green", "**"..PlayerData.name.."** started usb decrypt task.")
    	BJCore.Functions.TriggerServerCallback("crim:server:hasEncryptedItem", function(item)
    		if item then
		        local animDict = "mp_fbi_heist"
		        local animName = "loop"
		        while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(0); end
		        TaskPlayAnim(PlayerPedId(), animDict, animName, 3.0, 1.0, -1, 31, 0, 0, 0)
		        exports['mythic_progbar']:Progress({
			        name = "anon_prep",
			        duration = 6000,
			        label = "Preparing",
			        canCancel = false,
			        controlDisables = {
			            disableMovement = true,
			            disableCarMovement = true,
			            disableMouse = false,
			            disableCombat = true,
			            disableInteract = true
			        },
			        clearTasks = false
		        }, function(status)
			        if not status then
						FreezeEntityPosition(PlayerPedId(), true)
						local count, busy, failed = 0, false, false
						for i = 1, 3, 1 do
							if failed then break; end
							busy = true
					        TriggerEvent('bj_minigames:start', 'Bruteforce', { difficulty = 5, timer = 10000, background = 1 }, function(data)
					        	count = count + 1
					        	BJCore.Functions.Notify(count.."/3 tasks complete")
								if count == 3 then
						        	ClearPedTasks(PlayerPedId())
							        FreezeEntityPosition(PlayerPedId(), false)
							        interacting = false
						            TriggerServerEvent("crim:server:doDecrypt", item)
								end
								busy = false
					        end, function(data)
						        ClearPedTasks(PlayerPedId())
						        FreezeEntityPosition(PlayerPedId(), false)
						        interacting = false
						        failed = true
						        BJCore.Functions.Notify("Failed", "error")
						        busy = false
					        end)
					        while busy do Citizen.Wait(0); end
					    end
			        end
		        end)
		    else
				BJCore.Functions.Notify("You don't have any items to decrypt", "error")
				interacting = false
		    end
    	end)
	end
end

AddEventHandler("crim:client:InteractionComplete", function() interacting = false; end)
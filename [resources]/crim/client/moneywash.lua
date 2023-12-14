local CurHint = false

function MWAwake()
	while BJCore == nil do Citizen.Wait(1000); end
	while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
	TriggerServerEvent('moneywash:server:GetHint')
	while not CurHint do Citizen.Wait(250); end
	MWUpdate()
end

local SpawnedHintPed = nil
local SpawnedStartPed = nil
local MissionStage = 0 -- Stage 0 = Nothing, Stage 1 = Hint Given, Stage 2 = Doing wash runs
local LastHintGiven = 0
local MissionVehicle = 0

local tasking = false

local laundry = vector4(1131.12, -989.14, 45.11, 272.39) -- inked bags > bands location
local SpawnedLaundryPed = nil
local insideLaundry = false

function MWUpdate(...)
	while true do
		local LastPressed = 0
		local nearby = false
		local plyPos = GetEntityCoords(PlayerPedId())
		for k, v in pairs(Config.MWHintLocations) do
			if #(plyPos.xyz - v.xyz) < 50 then
				if SpawnedHintPed == nil or not DoesEntityExist(SpawnedHintPed) then
					CreateHintPed(v)
				end
				
				if #(plyPos.xyz - v.xyz) < 10 then
					nearby = true
					if #(plyPos.xyz - v.xyz) < 1 then
                        BJCore.Functions.DrawText3D(v.x,v.y,v.z,"[~r~E~s~] Talk")
                        if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - LastPressed > 1000 and MissionStage ~= 2 then
                        	LastPressed = GetGameTimer()
                            GiveHint()
                        elseif MissionStage == 2 then
                        	BJCore.Functions.Notify("You already have an active task", "error")
                        end
					end
				end
			else
				if DoesEntityExist(SpawnedHintPed) then
					DeleteEntity(SpawnedHintPed)
					SpawnedHintPed = nil
				end
			end
		end

        if MissionStage == 1 then
        	if #(plyPos.xyz - CurHint.pos.xyz) < 50 then
				if SpawnedStartPed == nil or not DoesEntityExist(SpawnedStartPed) then
					CreateStartPed(CurHint.pos)
				end
				if #(plyPos.xyz - CurHint.pos.xyz) < 10 then
					nearby = true
					if #(plyPos.xyz - CurHint.pos.xyz) < 1 then
                        BJCore.Functions.DrawText3D(CurHint.pos.x,CurHint.pos.y,CurHint.pos.z,"[~r~E~s~] Talk")
                        if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - LastPressed > 1000 and MissionStage ~= 2 and MissionStage ~= 0 then
                        	LastPressed = GetGameTimer()
                            StartWashRun()
                        elseif MissionStage == 2 then
                        	BJCore.Functions.Notify("You already have an active task", "error")
                        end
					end
				end				
        	end
        elseif MissionStage == 2 then
        	if DoesEntityExist(SpawnedStartPed) then
        		SetEntityAsNoLongerNeeded(SpawnedStartPed)
        		-- Wait(math.random(3000,5000))
        		-- DeleteEntity(SpawnedStartPed)
        		SpawnedStartPed = nil
        	end
        end

        if laundry then
        	local doorObj = 0
        	if #(plyPos.xyz - laundry.xyz) < 20 then
        		doorObj = GetClosestObjectOfType(laundry.xyz,5.0,1416200171,0,0,0)
        		FreezeEntityPosition(doorObj, true)
                if SpawnedLaundryPed == nil or not DoesEntityExist(SpawnedLaundryPed) then
					CreateLaundryPed(laundry)
				end
				if #(plyPos.xyz - laundry.xyz) < 10 then
					nearby = true
					if #(plyPos.xyz - vector3(1132.62, -988.85, 46.11)) < 0.8 then
	                    BJCore.Functions.DrawText3D(laundry.x,laundry.y,laundry.z+1,"[~r~E~s~] Talk")
	                    if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - LastPressed > 1000 then
	                    	LastPressed = GetGameTimer()
	                    	ClearPedTasks(SpawnedLaundryPed)
	                    	Wait(3000)
	                    	TaskStartScenarioInPlace(SpawnedLaundryPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
	                    	Wait(math.random(5000, 8000))
	                        BJCore.Functions.TriggerServerCallback("crim:server:getRep", function(rep)
	                        	if rep and rep >= 100 then
	                        		BJCore.Functions.Notify("Come through")
	                        		FreezeEntityPosition(PlayerPedId(), true)
	                        		DoScreenFadeOut(1500)
	                        		Wait(1500)
	                        		TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
	                        		SetEntityCoords(PlayerPedId(), 1138.11, -3199.20, -39.67)
	                        		SetEntityHeading(PlayerPedId(), 0.77)
	                        		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
	                        		FreezeEntityPosition(PlayerPedId(), false)
	                        		DoScreenFadeIn(1500)
	                        		insideLaundry = true
	                        		TriggerEvent('isInLaundry', insideLaundry)
	                        		doLaundryRoom()
	                        		-- teleport to wash interior
	                        	else
	                        		BJCore.Functions.Notify("Access is only permitted to those well known in the laundry business", "error", 10000)
	                        		Wait(500)
	                        		ClearPedTasks(SpawnedLaundryPed)
	                        		Wait(2500)
	                        		TaskGoStraightToCoord(SpawnedLaundryPed, laundry.xyz, 1.0, -1, laundry.w, 2.0)
	                        		Wait(1000)
	                        		TaskStartScenarioInPlace(SpawnedLaundryPed, 'WORLD_HUMAN_LEANING', 0, true)
	                        	end
	                        end, "washrep")
	                    end                    
					end
				end
			else
				if DoesEntityExist(doorObj) then
					DeleteEntity(doorObj)
				end
				if DoesEntityExist(SpawnedLaundryPed) then
					DeleteEntity(SpawnedLaundryPed)
					SpawnedLaundryPed = nil
				end
        	end
        end

		if not nearby then
			Citizen.Wait(1000)
		end
		Citizen.Wait(1)
	end
end

local actions = {
    ["gather_money"] = {
        drawText    = "Sort",                 
        progText    = "Sorting",
        step        = "sort",          

        requireItem = "repairkit",
        requireRate = 1,

        rewardRate  = 1,
        rewardItem  = "goldbar",

        location    = vector3(1119.55,-3197.79,-40.39),
        offset      = vector3(-0.8, 0.896, 0.6),
        rotation    = vector3(0.0, 0.0, 180.0),
        time        = 24000,
        act         = "Money",
        scene       = 1,

        extraProps  = {
            [1] = {
	            model = "bkr_prop_money_counter",
	            pos   = vector3(-0.25,0.22,0.4),
	            rot   = vector3(0.0,0.0,180.0),
            },
            [2] = {
	            model = "bkr_prop_moneypack_03a",
	            pos   = vector3(-0.7,-0.25,0.4),
	            rot   = vector3( 0.0, 0.00,0.0),
            },
            [3] = {
	            model = "bkr_prop_moneypack_03a",
	            pos   = vector3(-0.7,-0.25,0.55),
	            rot   = vector3( 0.0, 0.00,0.00),
            }
        }
    },
    ["package_money"] = {
        drawText    = "Cut",
        progText    = "Cutting",
        step        = "cut",        

        requireRate = 1,               
        requireItem = "goldbar",   
        requireCash = false,            

        rewardRate  = 1,                
        rewardItem  = "phone",      
        rewardCash  = false,            

        location    = vector3(1122.27,-3197.82,-40.39),
        offset      = vector3(2.15, 0.67, 0.6),
        rotation    = vector3(0.0, 0.0, 180.0),
        time        = 45000,
        act         = "Money",
        scene       = 2,
    },
    ["clean_money"] = {
        drawText    = "Clean",
        progText    = "Washing",
        step        = "wash",        

        requireRate = 1,                
        requireItem = "phone",      
        requireCash = false,            

        rewardRate  = 10,            
        rewardItem  = "cashband",            
        rewardCash  = false,            

        location    = vector3(1122.40,-3194.63,-40.39),
        offset      = vector3(0.15, 0.0, 0.0),
        rotation    = vector3(0.0, 0.0, 65.0),
        time        = 45000,
        act         = "Money",
        scene       = 3,
    }
}

-- RegisterCommand("washtest", function( ... )
-- 	insideLaundry = true
-- 	doLaundryRoom()
-- end)

local WashConfig = {
	["moneybag"] = {
		["sort"] = 4,
		["wash"] = 2
	},
	["cashband"] = {
		["sort"] = 2,
		["wash"] = 1
	},
	["cashroll"] = {
		["sort"] = 1,
		["wash"] = 1
	},
}
local TasksRemaining = {}

local LaundryStep = 0
function doLaundryRoom()
	local exit = vector3(1138.11, -3199.20, -39.67)
	local start = vector3(1129.60, -3194.13, -40.40)
	local lastpress = 0
	Citizen.CreateThread(function()
		while insideLaundry do
			local plyPed = PlayerPedId()
			local plyPos = GetEntityCoords(plyPed)
			if #(plyPos - exit) < 2 then
				BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z, "[~r~E~s~] Exit")
				if IsControlJustReleased(0, Keys["E"]) then
            		FreezeEntityPosition(PlayerPedId(), true)
            		BJCore.Functions.PersistentNotify("end", "moneywash")
            		DoScreenFadeOut(1500)
            		Wait(1500)
            		TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
            		SetEntityCoords(PlayerPedId(), 1132.62, -988.85, 46.11)
            		SetEntityHeading(PlayerPedId(), 258.11)
            		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
            		FreezeEntityPosition(PlayerPedId(), false)
            		DoScreenFadeIn(1500)
            		insideLaundry = false
            		TriggerEvent('isInLaundry', insideLaundry)
            		if LaundryStep > 0 then
            			LaundryStep = 0
            			TasksRemaining = {}
            			BJCore.Functions.Notify("Current order cancelled")
            		end	
				end
			end
            
            if LaundryStep > 0 then
	            local closestAct, actDist = GetClosestAction()
	            if actDist < 1.0 and not tasking then
	            	BJCore.Functions.DrawText3D(actions[closestAct].location.x, actions[closestAct].location.y, actions[closestAct].location.z, "[~r~E~s~] "..actions[closestAct].drawText)
					if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - lastpress > 1000 then
	                    lastpress = GetGameTimer()
	                    if TasksRemaining[actions[closestAct].step] and TasksRemaining[actions[closestAct].step] > 0 then     	
			            	SceneHandler(actions[closestAct])
			            else
			            	BJCore.Functions.Notify("You don't have remaining tasks for this step", "error")
			            end
		            end
	            end
	        end
			Citizen.Wait(0)
		end
	end)
end

AddEventHandler("moneywash:client:CancelCurrent", function()
	if LaundryStep > 0 then
		BJCore.Functions.PersistentNotify("end", "moneywash")
		LaundryStep = 0
		TasksRemaining = {}
		BJCore.Functions.Notify("Current order cancelled")
	else
		BJCore.Functions.Notify("Nothing to cancel", "error")
	end
end)

AddEventHandler("moneywash:client:StartOrder", function(item)
	if LaundryStep == 0 then
	    BJCore.Functions.TriggerServerCallback('fibheist:CheckInvCount', function(count)
	    	if count and count > 0 then
	            BJCore.Functions.Notify(count.." "..BJCore.Shared.Items[item].label.."(s) received")
	            Wait(1000)
	            BJCore.Functions.Notify("Calculating tasks...")
	            Wait(4500)
	            TasksRemaining["item"] = item
	            TasksRemaining["amount"] = count
	            TasksRemaining["sort"] = WashConfig[item]["sort"]*count
	            TasksRemaining["wash"] = WashConfig[item]["wash"]*count
	            BJCore.Functions.Notify("Complete all tasks to process this order of "..count.." "..BJCore.Shared.Items[item].label.."(s)", "primary", 10000)
	            BJCore.Functions.PersistentNotify("start", "moneywash", "Tasks: Sort "..TasksRemaining["sort"].." | Wash "..TasksRemaining["wash"], "primary")
	            LaundryStep = 1
	    	else
	    		BJCore.Functions.Notify("You have no "..BJCore.Shared.Items[item].label.." to process", "error")
	    	end
	    end, item)
	else
		BJCore.Functions.Notify("You have ongoing tasks", "error")
	end
end)

AddEventHandler("moneywash:client:CheckOrders", function()
	TriggerServerEvent("moneywash:server:getPlayerOrders")
end)

RegisterNetEvent("moneywash:client:collectOrder")
AddEventHandler("moneywash:client:collectOrder", function(ID) if not insideLaundry then return BJCore.Functions.Notify("You're not at the Laundry location", "error"); end TriggerServerEvent("moneywash:server:giveOrder", ID) end)

function GetClosestAction()
    local plyPos = GetEntityCoords(PlayerPedId())
    local closest,closestDist
    for k,v in pairs(actions) do
        local dist = #(plyPos - v.location)
        if not closestDist or dist < closestDist then
	        closestDist = dist
	        closest = k
        end
    end
    return (closest or false),(closestDist or 9999)
end

SceneDicts = {
    Money = {
	    [1] = 'anim@amb@business@cfm@cfm_counting_notes@',
	    [2] = 'anim@amb@business@cfm@cfm_cut_sheets@',
	    [3] = 'anim@amb@business@cfm@cfm_drying_notes@',
    }
}

PlayerAnims = {
    Money = {
	    [1] = 'note_counting_v2_counter',
	    [2] = 'extended_load_tune_cut_billcutter',
	    [3] = 'loading_v3_worker',
    }
}

SceneAnims = {
    Money = {
	    [1] = {
	        binmoney  = 'note_counting_v2_binmoney',
	        moneybin  = 'note_counting_v2_moneybin',
	        money1    = 'note_counting_v2_moneyunsorted',
	        money2    = 'note_counting_v2_moneyunsorted^1',
	        wrap1     = 'note_counting_v2_moneywrap',
	        wrap2     = 'note_counting_v2_moneywrap^1',
	    },
	    [2] = {
	        cutter    = 'extended_load_tune_cut_papercutter',
	        singlep1  = 'extended_load_tune_cut_singlemoneypage',
	        singlep2  = 'extended_load_tune_cut_singlemoneypage^1',
	        singlep3  = 'extended_load_tune_cut_singlemoneypage^2',
	        table     = 'extended_load_tune_cut_table',
	        stack     = 'extended_load_tune_cut_moneystack',
	        strip1    = 'extended_load_tune_cut_singlemoneystrip',
	        strip2    = 'extended_load_tune_cut_singlemoneystrip^1',
	        strip3    = 'extended_load_tune_cut_singlemoneystrip^2',
	        strip4    = 'extended_load_tune_cut_singlemoneystrip^3',
	        strip5    = 'extended_load_tune_cut_singlemoneystrip^4',
	        sinstack  = 'extended_load_tune_cut_singlestack',
	    },
	    [3] = {
	        bucket    = 'loading_v3_bucket',
	        money1    = 'loading_v3_money01',
	        money2    = 'loading_v3_money01^1',
	    }
    },
}

SceneItems = {
    Money = {
	    [1] = {
	        binmoney  = 'bkr_prop_coke_tin_01',
	        moneybin  = 'bkr_prop_tin_cash_01a',
	        money1    = 'bkr_prop_money_unsorted_01',
	        money2    = 'bkr_prop_money_unsorted_01',
	        wrap1     = 'bkr_prop_money_wrapped_01',
	        wrap2     = 'bkr_prop_money_wrapped_01',
	    },
	    [2] = {
	        cutter    = 'bkr_prop_fakeid_papercutter',
	        singlep1  = 'bkr_prop_cutter_moneypage',
	        singlep2  = 'bkr_prop_cutter_moneypage',
	        singlep3  = 'bkr_prop_cutter_moneypage',
	        table     = 'bkr_prop_fakeid_table',
	        stack     = 'bkr_prop_cutter_moneystack_01a',
	        strip1    = 'bkr_prop_cutter_moneystrip',
	        strip2    = 'bkr_prop_cutter_moneystrip',
	        strip3    = 'bkr_prop_cutter_moneystrip',
	        strip4    = 'bkr_prop_cutter_moneystrip',
	        strip5    = 'bkr_prop_cutter_moneystrip',
	        sinstack  = 'bkr_prop_cutter_singlestack_01a',
	    },
	    [3] = {
	        bucket    = 'bkr_prop_money_pokerbucket',
	        money1    = 'bkr_prop_money_unsorted_01',
	        money2    = 'bkr_prop_money_unsorted_01',
	    }
    },
}

local Scenes = Scenes.Synchronised
local startTime
local sceneObjects = {}
function SceneHandler(action)
	tasking = true
	local plyPed = PlayerPedId()

	local sceneType = action.act
	local doScene = action.scene
	local actPos = action.location - action.offset
	local actRot = action.rotation

	local animDict = SceneDicts[sceneType][doScene]
	local actItems = SceneItems[sceneType][doScene]
	local actAnims = SceneAnims[sceneType][doScene]
	local plyAnim = PlayerAnims[sceneType][doScene]

	while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict); Wait(0); end

	local count = 1
	local objectCount = 0
	for k,v in pairs(actItems) do
		local hash = GetHashKey(v)
		while not HasModelLoaded(hash) do RequestModel(hash); Wait(0); end
		sceneObjects[k] = CreateObject(hash,actPos,true)
		SetModelAsNoLongerNeeded(hash)
		objectCount = objectCount + 1
		while not DoesEntityExist(sceneObjects[k]) do Wait(0); end
		SetEntityCollision(sceneObjects[k],false,false)
	end

	local scenes = {}
	local sceneConfig = Scenes.SceneConfig(actPos,actRot,2,false,false,1.0,0,1.0)

	for i=1,math.max(1,math.ceil(objectCount/3)),1 do
		scenes[i] = Scenes.Create(sceneConfig)
	end

	local pedConfig = Scenes.PedConfig(plyPed,scenes[1],animDict,plyAnim)
	Scenes.AddPed(pedConfig)

	for k,animation in pairs(actAnims) do      
		local targetScene = scenes[math.ceil(count/3)]
		local entConfig = Scenes.EntityConfig(sceneObjects[k],targetScene,animDict,animation)
		Scenes.AddEntity(entConfig)
		count = count + 1
	end

	local extras = {}
	if action.extraProps then
		for k,v in pairs(action.extraProps) do
			LoadModel(v.model)
			local obj = CreateObject(GetHashKey(v.model), actPos + v.pos, true,true,true)
			while not DoesEntityExist(obj) do Wait(0); end
			SetEntityRotation(obj,v.rot)
			FreezeEntityPosition(obj,true)
			extras[#extras+1] = obj
		end
	end

	startTime = GetGameTimer()

	for i=1,#scenes,1 do
		Scenes.Start(scenes[i])
	end

    exports['mythic_progbar']:Progress({
        name = "moneywash_scene",
        duration = action.time,
        label = action.progText,
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
			for i=1,#scenes,1 do
				Scenes.Stop(scenes[i])
			end

			for k,v in pairs(extras) do
				DeleteObject(v)
			end

			RemoveAnimDict(animDict)
	        TasksRemaining[action.step] = TasksRemaining[action.step] - 1
	        BJCore.Functions.Notify("Task complete", "success")
	        BJCore.Functions.PersistentNotify("start", "moneywash", "Tasks: Sort "..TasksRemaining["sort"].." | Wash "..TasksRemaining["wash"], "primary")
	        CheckComplete()
			for k,v in pairs(sceneObjects) do NetworkFadeOutEntity(v,false,false); end
			tasking = false
        else
        	tasking = false
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end

-- AddEventHandler("checkfam", function()
-- 	CheckComplete()
-- end)

function CheckComplete()
	local finished = true
    for k,v in pairs(TasksRemaining) do
    	if k ~= "amount" and k ~= "item" then
	        if v > 0 then
	        	finished = false
	        	break
	        end
	    end
    end
    if finished then
    	BJCore.Functions.PersistentNotify("end", "moneywash")
    	BJCore.Functions.Notify("All tasks complete. Placing order...", "success")
    	LaundryStep = 0
    	Wait(3000)
        TriggerServerEvent("moneywash:server:PlaceOrder", TasksRemaining["item"], TasksRemaining["amount"])
    	TasksRemaining = {}
    end
end

function LoadModel(model)
    local hash = (type(model) == "number" and model or GetHashKey(model))
    while not HasModelLoaded(hash) do
	    RequestModel(hash)
	    Wait(0)
    end
end

function CreateLaundryPed(pos)
	local modelHash = `g_m_y_pologoon_02`
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
    SpawnedLaundryPed = CreatePed(4, modelHash, pos, false, true)
    TaskStartScenarioInPlace(SpawnedLaundryPed, 'WORLD_HUMAN_LEANING', 0, true)
    SetEntityAsMissionEntity(SpawnedLaundryPed, true, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetBlockingOfNonTemporaryEvents(SpawnedLaundryPed, true)
    SetEntityInvincible(SpawnedLaundryPed, true)
end

function CreateHintPed(pos)
	local modelHash = `g_m_y_salvagoon_02`
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
    SpawnedHintPed = CreatePed(4, modelHash, pos, false, true)
    TaskStartScenarioInPlace(SpawnedHintPed, 'WORLD_HUMAN_AA_SMOKE', 0, true)
    SetEntityAsMissionEntity(SpawnedHintPed, true, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetBlockingOfNonTemporaryEvents(SpawnedHintPed, true)
    SetEntityInvincible(SpawnedHintPed, true)
end

local randomDelay = 0 
function GiveHint()
	if LastHintGiven == 0 or GetGameTimer() - LastHintGiven > 300000 then
		BJCore.Functions.Notify("I'll be in touch...", "primary")
        LastHintGiven = GetGameTimer()
        randomDelay = math.random(20000, 45000) 
		SetTimeout(randomDelay, function()
			MissionStage = 1
			TriggerServerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..PlayerData.name .. "** has requested money wash hint.")
			TriggerServerEvent('phone:server:sendNewMail', {
				sender = "Unknown",
				subject = "Re: Laundry Man",
				message = "I know a guy that can help you out. He moves around a lot but I\'m sure you\'ll work it out. <br />When you find him, approach alone. Do as he says then move along quickly. <br /><br />You\'ll find him ".. CurHint.hint,
			})
			randomDelay = 0
		end)
	elseif randomDelay ~= 0 and GetGameTimer() - LastHintGiven <= randomDelay then
		BJCore.Functions.Notify("Wait to be contacted. Piss off!", "error")
	else
		BJCore.Functions.Notify("I've recently emailed you mate. Stop bothering me!", "error")
	end
end

function CreateStartPed(pos)
	local modelHash 
	if type(CurHint.ped) == "string" then modelHash = GetHashKey(CurHint.ped); else modelHash = CurHint.ped; end
	while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
    SpawnedStartPed = CreatePed(4, modelHash, pos, false, true)
    TaskStartScenarioInPlace(SpawnedStartPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetEntityAsMissionEntity(SpawnedStartPed, true, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetBlockingOfNonTemporaryEvents(SpawnedStartPed, true)
    SetEntityInvincible(SpawnedStartPed, true)
end

local DropOffCount = 0
function StartWashRun()
	TriggerServerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..PlayerData.name .. "** has started a money wash run.")
    BJCore.Functions.Notify("Get in this car. I'll tell you where to go for these drop offs", "primary", 6000)
	PlayAmbientSpeech1(SpawnedStartPed, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
	DropOffCount = 0
	CreateMissionVehicle()
    local stolen = math.random(100)
    if stolen <= 70 then
	    BJCore.Functions.Notify("The vehicle is stolen so keep an eye out for cops!", "primary", 6000)
	    TriggerServerEvent('moneywash:server:ReportStolen', BJCore.Shared.VehicleModels[GetEntityModel(MissionVehicle)].name, GetVehicleNumberPlateText(MissionVehicle))
	end	
	MissionStage = 2
	RunningTick()
	StartMission()
end

local CashDropOffs = {
	[1] =  { ['x'] = 74.5,['y'] = -762.17,['z'] = 31.68,['h'] = 160.98},
	[2] =  { ['x'] = 100.58,['y'] = -644.11,['z'] = 44.23,['h'] = 69.11},
	[3] =  { ['x'] = 175.45,['y'] = -445.95,['z'] = 41.1,['h'] = 92.72},
	[4] =  { ['x'] = 130.3,['y'] = -246.26,['z'] = 51.45,['h'] = 219.63},
	[5] =  { ['x'] = 198.1,['y'] = -162.11,['z'] = 56.35,['h'] = 340.09},
	[6] =  { ['x'] = 341.0,['y'] = -184.71,['z'] = 58.07,['h'] = 159.33},
	[7] =  { ['x'] = -26.96,['y'] = -368.45,['z'] = 39.69,['h'] = 251.12},
	[8] =  { ['x'] = -155.88,['y'] = -751.76,['z'] = 33.76,['h'] = 251.82},
	[9] =  { ['x'] = -305.02,['y'] = -226.17,['z'] = 36.29,['h'] = 306.04},
	[10] =  { ['x'] = -347.19,['y'] = -791.04,['z'] = 33.97,['h'] = 3.06},
	[11] =  { ['x'] = -703.75,['y'] = -932.93,['z'] = 19.22,['h'] = 87.863},
	[12] =  { ['x'] = -659.35,['y'] = -256.83,['z'] = 36.23,['h'] = 118.92},
	[13] =  { ['x'] = -934.18,['y'] = -124.28,['z'] = 37.77,['h'] = 205.79},
	[14] =  { ['x'] = -1214.3,['y'] = -317.57,['z'] = 37.75,['h'] = 18.39},
	[15] =  { ['x'] = -822.83,['y'] = -636.97,['z'] = 27.9,['h'] = 160.23},
	[16] =  { ['x'] = 308.04,['y'] = -1386.09,['z'] = 31.79,['h'] = 47.23},
	[17] =  { ['x'] = -654.14,['y'] = -688.27,['z'] = 30.80,['h'] = 279.80},
	[18] =  { ['x'] = 354.31,['y'] = -965.59,['z'] = 29.43,['h'] = 357.90},
	[19] =  { ['x'] = 1126.54,['y'] = -345.27,['z'] = 67.11,['h'] = 206.83},
	[20] =  { ['x'] = 1163.37,['y'] = -455.85,['z'] = 66.98,['h'] = 167.61},
	[21] =  { ['x'] = 135.86,['y'] = 199.23,['z'] = 106.82,['h'] = 313.86},
	[22] =  { ['x'] = 275.63,['y'] = -592.65,['z'] = 43.26,['h'] = 70.71},
	[23] =  { ['x'] = 283.53,['y'] = -914.14,['z'] = 29.02,['h'] = 67.84},						
}

local carpick = {
    [1] = "felon",
    [2] = "kuruma",
    [3] = "sultan",
    [4] = "granger",
    [5] = "tailgater",
}

function CreateMissionVehicle()
	if DoesEntityExist(MissionVehicle) then
	    SetVehicleHasBeenOwnedByPlayer(MissionVehicle,false)
		SetEntityAsNoLongerNeeded(MissionVehicle)
		DeleteEntity(MissionVehicle)
	end
    local RandomVeh = GetHashKey(carpick[math.random(#carpick)])
    BJCore.Functions.SpawnVehicle(RandomVeh, function(veh)
    	MissionVehicle = veh
        SetEntityHeading(veh, CurHint.veh.w)
        exports['legacyfuel']:SetFuel(veh, math.random(70,100) + 0.0)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
    end, CurHint.veh, true)
    SetVehicleHasBeenOwnedByPlayer(MissionVehicle,true)

    while true do
    	Citizen.Wait(1)
    	 BJCore.Functions.DrawText3D(CurHint.veh["x"], CurHint.veh["y"], CurHint.veh["z"], "Delivery Vehicle")
    	 if #(GetEntityCoords(PlayerPedId()) - vector3(CurHint.veh["x"], CurHint.veh["y"], CurHint.veh["z"])) < 8.0 then
    	 	return
    	 end
    end
end

local rnd = 0
local deliveryPed = 0
local LastPressed = 0
function StartMission()
	if tasking then return; end
	
	rnd = math.random(1,#CashDropOffs)
	CreateBlip()
	local pedCreated = false

	tasking = true
	BJCore.Functions.PersistentNotify("end", "WashNotif")
	local toolong = 600000
	while tasking do

		Citizen.Wait(1)
		local plyPos = GetEntityCoords(PlayerPedId())
		local dstcheck = #(plyPos - vector3(CashDropOffs[rnd]["x"],CashDropOffs[rnd]["y"],CashDropOffs[rnd]["z"])) 
		local vehPos = GetEntityCoords(MissionVehicle)
		local dstcheck2 = #(plyPos - vehPos) 

		local veh = GetVehiclePedIsIn(PlayerPedId(),false)
		if dstcheck < 40.0 and not pedCreated and (MissionVehicle == veh or dstcheck2 < 15.0) then
			pedCreated = true
			DeleteCreatedPed()
			CreateDropOffPed()
			BJCore.Functions.Notify("You are close to the drop off")
		end
		toolong = toolong - 1
		if toolong < 0 then
		    SetVehicleHasBeenOwnedByPlayer(MissionVehicle,false)
			SetEntityAsNoLongerNeeded(MissionVehicle)
			tasking = false
			MissionStage = 0
			BJCore.Functions.Notify("You've taken too long to complete the current drop off. Task cancelled", "error")
		end
		if dstcheck < 2.0 and pedCreated then
			local pedPos = GetEntityCoords(deliveryPed)
			BJCore.Functions.DrawText3D(pedPos["x"],pedPos["y"],pedPos["z"], "[~r~E~s~]")  

			if not IsPedInAnyVehicle(PlayerPedId()) and IsControlJustReleased(0,38) and GetGameTimer() - LastPressed > 500 then
				LastPressed = GetGameTimer()
				TaskTurnPedToFaceEntity(deliveryPed, PlayerPedId(), 1.0)
				Citizen.Wait(1500)
				PlayAmbientSpeech1(deliveryPed, "Generic_Hi", "Speech_Params_Force")
				DoDropOff()
				tasking = false
			end
		end
	end
	DeleteCreatedPed()
	DeleteBlip()
end

RegisterNetEvent("moneywash:client:cancelrun")
AddEventHandler("moneywash:client:cancelrun", function()
	BJCore.Functions.Notify("Tasking cancelled", "error")
	tasking = false
	MissionStage = 0	
end)

function DoDropOff()
	local success = true

	Citizen.Wait(1000)
	playerAnim()
	Citizen.Wait(800)

	PlayAmbientSpeech1(deliveryPed, "Chat_State", "Speech_Params_Force")

	if DoesEntityExist(deliveryPed) and not IsEntityDead(deliveryPed) then

		local counter = math.random(50,200)
		while counter > 0 do
			local crds = GetEntityCoords(deliveryPed)
			counter = counter - 1
			Citizen.Wait(1)
		end
	
		if success then
			local counter = math.random(100,300)
			while counter > 0 do
				local crds = GetEntityCoords(deliveryPed)
				counter = counter - 1
				Citizen.Wait(1)
			end
			giveAnim()
		end
	
		local crds = GetEntityCoords(deliveryPed)
		local crds2 = GetEntityCoords(PlayerPedId())
	
		if #(crds - crds2) > 3.0 or not DoesEntityExist(deliveryPed) or IsEntityDead(deliveryPed) then
			success = false
		end
		
		DeleteBlip()
		if success then
			PlayAmbientSpeech1(deliveryPed, "Generic_Thanks", "Speech_Params_Force_Shouted_Critical")
			TriggerServerEvent('moneywash:deliverySuccess')

			Citizen.Wait(2000)
		else
			BJCore.Functions.Notify("Drop off failed", "error")
		end
	
		DeleteCreatedPed()
	end
end

function RunningTick()
	Citizen.CreateThread(function()
	    while MissionStage == 2 do
			if not DoesEntityExist(MissionVehicle) or GetVehicleEngineHealth(MissionVehicle) < 200.0 or GetVehicleBodyHealth(MissionVehicle) < 200.0 then
				MissionStage = 0
				tasking = false
				BJCore.Functions.Notify("You've trashed the vehicle. You won't be given any more drop offs", "error")
			else
				if tasking then
			        Citizen.Wait(20000)
			    else
			    	BJCore.Functions.PersistentNotify("start", "WashNotif", "Waiting on drop off location...", "primary")
			    	Citizen.Wait(math.random(30000,65000))
				    DropOffCount = DropOffCount + 1
				    if DropOffCount == 8 then
				    	--Citizen.Wait(1200000)
						BJCore.Functions.PersistentNotify("end", "WashNotif")
						BJCore.Functions.Notify("You've finished this drop run. Request a new one to continue")						
						DropOffCount = 0
						MissionStage = 0
					else
						StartMission()
				    end
				end
			end
	    end
	end)
end

function CreateDropOffPed()
    local hashKey = `a_m_m_business_01`
    RequestModel(hashKey)
    while not HasModelLoaded(hashKey) do
        RequestModel(hashKey)
        Citizen.Wait(100)
    end

	deliveryPed = CreatePed(5, hashKey, CashDropOffs[rnd]["x"],CashDropOffs[rnd]["y"],CashDropOffs[rnd]["z"], CashDropOffs[rnd]["h"], 0, 0)

    ClearPedTasks(deliveryPed)
    ClearPedSecondaryTask(deliveryPed)
    TaskSetBlockingOfNonTemporaryEvents(deliveryPed, true)
    SetPedFleeAttributes(deliveryPed, 0, 0)
    SetPedCombatAttributes(deliveryPed, 17, 1)

    SetPedSeeingRange(deliveryPed, 0.0)
    SetPedHearingRange(deliveryPed, 0.0)
    SetPedAlertness(deliveryPed, 0)
    SetPedKeepTask(deliveryPed, true)
end

function DeleteCreatedPed()
	if DoesEntityExist(deliveryPed) then 
		SetPedKeepTask(deliveryPed, false)
		TaskSetBlockingOfNonTemporaryEvents(deliveryPed, false)
		ClearPedTasks(deliveryPed)
		TaskWanderStandard(deliveryPed, 10.0, 10)
		SetPedAsNoLongerNeeded(deliveryPed)

		Citizen.Wait(20000)
		DeletePed(deliveryPed)
	end
end

local blip = 0
function DeleteBlip()
	if DoesBlipExist(blip) then
		RemoveBlip(blip)
	end
end

function CreateBlip()
	DeleteBlip()
	if MissionStage == 2 then
		blip = AddBlipForCoord(CashDropOffs[rnd]["x"],CashDropOffs[rnd]["y"],CashDropOffs[rnd]["z"])
	end
    SetBlipSprite(blip, 500)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drop Off")
    EndTextCommandSetBlipName(blip)
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

function playerAnim()
	loadAnimDict("mp_safehouselost@")
    TaskPlayAnim(PlayerPedId(), "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
end

function giveAnim()
    if DoesEntityExist(deliveryPed) and not IsEntityDead(deliveryPed) then 
        loadAnimDict("mp_safehouselost@")
        if IsEntityPlayingAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 3) then 
            TaskPlayAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
        else
            TaskPlayAnim(deliveryPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
        end     
    end
end

RegisterNetEvent('moneywash:client:SetHint')
AddEventHandler('moneywash:client:SetHint', function(data) CurHint = data; end)
Citizen.CreateThread(function(...) MWAwake(...); end)

RegisterNetEvent('moneywash:client:repNotif')
AddEventHandler('moneywash:client:repNotif', function()
	TriggerServerEvent('phone:server:sendNewMail', {
		sender = "Unknown",
		subject = "Re: Laundry Man",
		message = "Hey,<br /><br /> I've seen you around here a fair bit.<br/>Come find us at the Express Laundry near Mom's Famous Tacos and I'll show you a few things to help you get going on your own.",
	})
end)

--

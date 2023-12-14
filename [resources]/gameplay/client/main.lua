local PlayerLoaded = false
PlayerData = {}
RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    PlayerLoaded = true
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

local entityEnumerator = { __gc = function(enum) if enum.destructor and enum.handle then enum.destructor(enum.handle) end enum.destructor = nil enum.handle = nil end }
local function EnumerateEntities(initFunc, moveFunc, disposeFunc) return coroutine.wrap(function() local iter, id = initFunc() if not id or id == 0 then disposeFunc(iter) return end local enum = {handle = iter, destructor = disposeFunc} setmetatable(enum, entityEnumerator) local next = true repeat coroutine.yield(id) next, id = moveFunc(iter) until not next enum.destructor, enum.handle = nil, nil disposeFunc(iter) end) end
function EnumerateObjects() return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) end
function EnumeratePeds() return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) end
function EnumerateVehicles() return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) end
function EnumeratePickups() return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup) end

--- Trains and Trams fam ---
-- TTconfig = {
--     enableTrams = true,
--     enableTrains = true,
--     closeDoors = true,
--     closeDoorsAtStations = true,
--     text = "You are on line ~BLIP_536~ the next station is ~g~~a~"
-- }
-- local trains = {}
-- local inTram = false
-- local currentNode = nil
-- local stations = {
--     { node = 179,  name = "Strawberry",      },
--     { node = 271,  name = "Puerto Del Sol",  },
--     { node = 388,  name = "LSIA Parking",    },
--     { node = 434,  name = "LSIA Terminal 4", },
--     { node = 530,  name = "LSIA Terminal 4", },
--     { node = 578,  name = "LSIA Parking",    },
--     { node = 689,  name = "Puerto Del Sol",  },
--     { node = 782,  name = "Strawberry",      },
--     { node = 1078, name = "Burton",          },
--     { node = 1162, name = "Portola Drive",   },
--     { node = 1233, name = "Del Perro",       },
--     { node = 1331, name = "Little Seoul",    },
--     { node = 1397, name = "Pillbox South",   },
--     { node = 1522, name = "Davis",           },
--     { node = 1649, name = "Davis",           },
--     { node = 1791, name = "Pillbox South",   },
--     { node = 1869, name = "Little Seoul",    },
--     { node = 1977, name = "Del Perro",       },
--     { node = 2066, name = "Portola Drive",   },
--     { node = 2153, name = "Burton",          },
--     -- this last station is here because this track ends at 2245 and first next station is at 179
--     { node = 2246, name = "Strawberry"       }
-- }

-- local doors = {left = {0, 2}, right = {1, 3}}

-- Citizen.CreateThread(function()
--     if TTconfig.enableTrains or TTconfig.enableTrams then
--         if TTconfig.enableTrains then SwitchTrainTrack(0, true) end
--         if TTconfig.enableTrams then SwitchTrainTrack(3, true) end
--         SetTrainTrackSpawnFrequency(0, 120000)
--         SetRandomTrains(1)
--     end
--     AddTextEntry("NEXT_STATION_NOTIFICATION", TTconfig.text)
-- end)

-- CreateThread(function()
--     while true do
--         Wait(1000)
--         local player = PlayerPedId()
--         local coords = GetEntityCoords(player)
--         trains = GetTrams(coords)
--         if #trains >= 1 then
--             local train = trains[1][1]
--             if train ~= nil then
--                 currentNode = GetTrainCurrentTrackNode(train)
--             else
--                 currentNode = nil
--             end
--         end
--         inTram = IsPedInAnyTrain(player)
--     end
-- end)

-- function drawThere(coords, text)
--     SetDrawOrigin(coords)
--     BeginTextCommandDisplayText("STRING")
--     AddTextComponentSubstringPlayerName(text)
--     EndTextCommandDisplayText(0.0, 0.0)
--     ClearDrawOrigin()
-- end

-- CreateThread(function()
--     while true do
--         Wait(0)
--         if inTram and currentNode ~= nil then
--             local nextst = "Unknown"
--             for _, station in ipairs(stations) do
--                 if currentNode < station.node then
--                     nextst = station.name
--                     break
--                 end
--             end

--             BeginTextCommandDisplayHelp("NEXT_STATION_NOTIFICATION")
--             AddTextComponentSubstringPlayerName(nextst)
--             EndTextCommandDisplayHelp(0, 0, 1, -1)
--         else
--             Citizen.Wait(1000)
--         end
--     end
-- end)

-- CreateThread(function()
--     while true do
--         Wait(0)
--         for _, train in pairs(trains) do
--             if train[2] < 200 then
--                 if train[3] > 0.5 then
--                     SetVehicleDoorsShut(train[1], true)
--                 elseif TTconfig.closeDoorsAtStations then
--                     if DoesEntityExist(GetTrainCarriage(train[1], 1)) then
--                         --drawThere(GetEntityCoords(train[1]), "right")
--                         shutSide(train[1], "right")
--                     else
--                         --drawThere(GetEntityCoords(train[1]), "left")
--                         shutSide(train[1], "left")
--                     end
--                 end
--             end
--         end

--         --DrawBox(GetEntityCoords(trains[1][1]) - 1, GetEntityCoords(trains[1][1]) + 1, 255, 255, 255, 100)
--     end
-- end)

-- function shutSide(vehicle, side)
--     if doors[side] then
--         for _, door in pairs(doors[side]) do
--             SetVehicleDoorShut(vehicle, door, true)
--         end
--     end
-- end

-- function compareCoords(a, b) return a[2] < b[2] end

-- function GetTrams(coords)
--     local trams = {}
--     for vehicle in EnumerateVehicles() do
--         local distance = #(GetEntityCoords(vehicle) - coords)
--         if distance <= 100 and GetEntityModel(vehicle) == `metrotrain` then
--             table.insert(trams, {vehicle, distance, GetEntitySpeed(vehicle)})
--         end
--     end
--     table.sort(trams, compareCoords)
--     return trams
-- end
---

--- Car control  UI ---
CCControls = {["Toggle"] = 303} -- U
ctrl = {}  
local lastVeh, lastData  
ctrl.update = function()    
	Wait(1000)    
	SendNUIMessage({var='onChange', value='http://gameplay/posted'})     
end

AddEventHandler("gameplay:carControl", function() 
    Wait(GetFrameTime()*10) 
    local veh = GetVehiclePedIsIn(PlayerPedId())   
    if lastVeh and veh == lastVeh then            
        ctrl.display(lastData)          
    else           
        lastData = nil           
        ctrl.display()        
    end   
    lastVeh = veh    
end)

ctrl.display = function(data)   
	local enable, states = ctrl.getStates((data or nil)) 
	ctrl.msg('SetEnabledOptions', enable)   
	ctrl.msg('SetCheckedOptions', states)   
	ctrl.msg('SetAlpha', {[0]=1})   
	ctrl.focus(true)  
end  

local gotOptions = false  
ctrl.refresh = function(options)  
	windows = {    
		[8]  = gotOptions['8'],    
		[9]  = gotOptions['9'],    
		[10] = gotOptions['10'],    
		[11] = gotOptions['11'],  
	}   
	local enable, states = ctrl.getStates(windows)  
	ctrl.msg('SetEnabledOptions', enable)  
	ctrl.msg('SetCheckedOptions', states)  
	gotOptions = false  
end  

ctrl.getStates = function(windows)   
	local veh = GetVehiclePedIsIn(PlayerPedId(), false)   
	local driving = (GetPedInVehicleSeat(veh, -1) == PlayerPedId())   
	local inFront = (GetPedInVehicleSeat(veh, 0) == PlayerPedId())    
	local states = {}    
	tick = 0   
	for i=tick, tick + 3, 1 do states[i] = (GetPedInVehicleSeat(veh, i-tick-1) ~= 0 and true or false); end    
	tick = tick + 4   
	for i=tick, tick + 3, 1 do     
		states[i] = (DoesVehicleHaveDoor(veh, i-tick) and GetVehicleDoorAngleRatio(veh, i-tick) ~= 0.0 or false);    
	end    
	tick = tick + 4   
	for i=tick, tick + 3, 1 do     
        local win = (windows and windows[i].checked)
		if win == nil then win = (RollUpWindow(veh,i-tick) and false); end     
		states[i] = win;   
	end    
	tick = tick + 4   
	for i=tick,tick+3,1 do      
		states[i] = (DoesVehicleHaveDoor(veh, i-tick+4) and GetVehicleDoorAngleRatio(veh, i-tick+4) ~= 0.0 or false);    
	end      
	tick = tick + 3   
	states[tick] = GetIsVehicleEngineRunning(veh)   
	states[tick+1] = IsVehicleInteriorLightOn(veh)    
	local enable = {}   
	tick = 0   
	for i=tick, tick + 3, 1 do      
		if i-tick > 1 then       
			if not driving or not inFront then         
				enable[i] = (IsVehicleSeatFree(veh, i-tick-1) or false);        
			else         
				enable[i] = false        
			end     
		else       
			if driving or inFront then         
				enable[i] = (IsVehicleSeatFree(veh, i-tick-1) or false);        
			else         
				enable[i] = false        
			end     
		end    
	end    
	tick = tick + 4   
	for i=tick ,tick + 3, 1 do      
		if i-tick > 1 then       
			if not driving or not inFront then         
				enable[i] = (DoesVehicleHaveDoor(veh, i-tick) or false);       
			else         
				enable[i] = false        
			end     
		else       
			if driving or inFront then         
				enable[i] = (DoesVehicleHaveDoor(veh, i-tick) or false);        
			else         
				enable[i] = false        
			end     
		end   
	end    
	tick = tick + 4   
	for i=tick, tick + 3, 1 do     
		local win = (windows and windows[i].enabled)     
		if win == nil then win = (IsVehicleWindowIntact(veh, i-tick) or false); end     
		if i-tick > 1 then       
			if not driving or not inFront then         
				enable[i] = (DoesVehicleHaveDoor(veh, i-tick) or false);        
			end     
		else       
			if driving or inFront then         
				enable[i] = (DoesVehicleHaveDoor(veh, i-tick) or false);        
			end     
		end   
	end    
	tick = tick + 4   
	for i=tick, tick + 3, 1 do     
		enable[i] = ((driving or inFront) and DoesVehicleHaveDoor(veh, i-tick+4) or false);    
	end   
	tick = tick + 3    
	enable[tick] = (not EngineDisabled and ((driving or inFront) and GetVehicleEngineHealth(veh) > 0) or false)   
	enable[tick + 1] = true   
	return enable, states  
end  

ctrl.msg = function(f, a)   
	SendNUIMessage({     
		func = f,     
		args = a   
	})  
end  

ctrl.focus = function(f)   
	SetNuiFocus(f, f)  
end  

ctrl.setDoor = function(d, s)   
	local v = GetVehiclePedIsIn(PlayerPedId(), false)   
	if s then     
		SetVehicleDoorOpen(v, d.door, false, false)   
	else     
		SetVehicleDoorShut(v, d.door, false, false)   
	end  
end  

ctrl.setSeat = function(d, s)   
	local v = GetVehiclePedIsIn(PlayerPedId(), false)   
	if IsVehicleSeatFree(v,d.seat) then     
		TaskWarpPedIntoVehicle(PlayerPedId(), v, d.seat)   
	end   
	lastData = gotOptions   
	gotOptions = false   
	SendNUIMessage({var='options',ret='http://gameplay/gotOpts'})   
	while not gotOptions do Wait(0); end   
	ctrl.refresh(gotOptions); 
end   

ctrl.setWindow = function(d, s)   
	local v = GetVehiclePedIsIn(PlayerPedId(), false)   
	if s then     
		RollDownWindow(v, d.window)   
	else     
		RollUpWindow(v, d.window)   
	end   
	SendNUIMessage({var='options', ret='http://gameplay/gotOpts'})  
end  

ctrl.setEngine = function(d, s)
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	if s == true then if not exports["vehiclelock"]:hasKey(v) then BJCore.Functions.Notify("You don't have keys to this vehicle", "error") return; end; end
	SetVehicleEngineOn(v, s, false, true, true)
end

ctrl.setIntLight = function(d, s)   
	local v = GetVehiclePedIsIn(PlayerPedId(), false)    
	SetVehicleInteriorlight(v, s) 
end  

ctrl.cbIds = {    
	[0] = {seat = -1, func = ctrl.setSeat},   
	[1] = {seat = 0, func = ctrl.setSeat},    
	[2] = {seat = 1, func = ctrl.setSeat},    
	[3] = {seat = 2, func = ctrl.setSeat},    
	[4] = {door = 0, func = ctrl.setDoor},    
	[5] = {door = 1, func = ctrl.setDoor},    
	[6] = {door = 2, func = ctrl.setDoor},    
	[7] = {door = 3, func = ctrl.setDoor},    
	[8] = {window = 0, func = ctrl.setWindow},    
	[9] = {window = 1, func = ctrl.setWindow},    
	[10] = {window = 2, func = ctrl.setWindow},    
	[11] = {window = 3, func = ctrl.setWindow},    
	[12] = {door = 4, func = ctrl.setDoor},    
	[13] = {door = 5, func = ctrl.setDoor},    
	[14] = {door = 6, func = ctrl.setDoor},    
	[15] = {func = ctrl.setEngine},    
	[16] = {func = ctrl.setIntLight}, 
}   

ctrl.posted = function(args)    
	local f = ctrl.cbIds[args.id]    
	f.func(f, args.checked)  
end   

ctrl.gotOpts = function(o)    
	lastData = {      
		[8] = o['8'],      
		[9] = o['9'],      
		[10] = o['10'],      
		[11] = o['11'],    
	}    
	if not gotOptions then gotOptions = o end  
end   

ctrl.close = function()    
	ctrl.focus(false)    
	ctrl.msg('SetAlpha', {[0]=0})  
end   

RegisterNUICallback('posted', ctrl.posted)  
RegisterNUICallback('gotOpts', ctrl.gotOpts)  
RegisterNUICallback('close', ctrl.close)  
AddEventHandler('DisableEngine', function(...) EngineDisabled = true; end) 
AddEventHandler('EnableEngine', function(...) EngineDisabled = false; end)  
Citizen.CreateThread(ctrl.update)
---

--- Car Control Commands ---
RegisterCommand('engine', function(source, args)
	if (IsPedSittingInAnyVehicle(PlayerPedId())) then
		local vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
		local enable, states = ctrl.getStates(nil)   
		
		if states[15] == 1 then
			SetVehicleEngineOn(vehicle,false,false,true)
		else
			if exports["vehiclelock"]:hasKey(vehicle) then
				SetVehicleUndriveable(vehicle,false)
				SetVehicleEngineOn(vehicle,true,false,true)
			else
                BJCore.Functions.Notify("You don't have keys to this vehicle", "error")
			end
		end
	end
end)

RegisterCommand('door', function(source, args)
	if args[1] == nil then
		BJCore.Functions.Notify("You must input a door number",'error')
		return
	end

	local doorNum = tonumber(args[1]) - 1
	if doorNum < 0 then
		doorNum = 0
	end
	OpenDoor(PlayerPedId(), doorNum)
end)

RegisterCommand('trunk', function()
	OpenDoor(PlayerPedId(), 5)
end)

RegisterCommand('boot', function()
	OpenDoor(PlayerPedId(), 5)
end)

RegisterCommand('hood', function()
	OpenDoor(PlayerPedId(), 4)
end)

RegisterCommand('bonnet', function()
	OpenDoor(PlayerPedId(), 4)
end)

function OpenDoor(player, doorNum)
	local vehicle = GetVehiclePedIsIn(player,true)
	local isopen = GetVehicleDoorAngleRatio(vehicle,doorNum) and GetVehicleDoorAngleRatio(vehicle,doorNum)
	local distanceToVeh = #(GetEntityCoords(player) - GetEntityCoords(vehicle))
	
	if distanceToVeh <= 3.5 then
		if (isopen == 0) then
			SetVehicleDoorOpen(vehicle,doorNum,0,0)
		else
			SetVehicleDoorShut(vehicle,doorNum,0)
		end
	else
		BJCore.Functions.Notify("You must in a vehicle to do that",'error')
	end
end

RegisterCommand('seat', function(source, args)
	if args[1] == nil then
		BJCore.Functions.Notify("You must input a seat number",'error')
		return
	end

	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	
	local seatNum = tonumber(args[1]) - 2
	if seatNum < -1 then
		seatNum = -1
	end
	
	seatNum = math.floor(seatNum)
	
	if IsVehicleSeatFree(vehicle, seatNum) then
		SetPedIntoVehicle(PlayerPedId(), vehicle, seatNum)
	end
end)

RegisterCommand('neon', function(source, args)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	
	if vehicle ~= nil then
		SetVehicleNeonLightEnabled(vehicle, 0, not IsVehicleNeonLightEnabled(vehicle, 0))
		SetVehicleNeonLightEnabled(vehicle, 1, not IsVehicleNeonLightEnabled(vehicle, 1))
		SetVehicleNeonLightEnabled(vehicle, 2, not IsVehicleNeonLightEnabled(vehicle, 2))
		SetVehicleNeonLightEnabled(vehicle, 3, not IsVehicleNeonLightEnabled(vehicle, 3))
	end
end)
---

--- Trunk logic ---
DecorRegister('Vehicle.trunkInUse', 2)

local blacklistModels = {
    [1] = "jester",
    [2] = "infernus",
    [3] = "zentorno",
    [4] = "turismor",
    [5] = "bullet",
    [6] = "panto",
    [7] = "brioso",
    [8] = "comet2",
    [9] = "comet3",
    [10] = "comet4",
    [11] = "comet5",
    [12] = "ninef",
    [13] = "ninef2",
    [14] = "furoregt",
    [15] = "trophytruck",
    [16] = "guardian",   
}

function blacklistedModel(veh)
    for i=1,#blacklistModels do
        if GetEntityModel(veh) == GetHashKey(blacklistModels[i]) then
            return true
        end
    end
    return false
end

local trunkVeh = nil
local inTrunk = false
RegisterCommand("git", function() TriggerEvent('gameplay:getintrunk'); end)
TriggerEvent("chat:addSuggestion", "/git", 'Get in the trunk of closest vehicle (Get in trunk)')

AddEventHandler('gameplay:getintrunk', function()
    local veh = BJCore.Functions.VehicleInFront()
    if veh == 0 then BJCore.Functions.Notify("No vehicle found",'error') return; end
    local lockStatus = GetVehicleDoorLockStatus(veh) 
    if lockStatus ~= 1 and lockStatus ~= 0 then 
        BJCore.Functions.Notify("The vehicle is locked", 'error')
        return
    end 
    if GetVehicleDoorAngleRatio(veh, 5) == 0.0 then   
        BJCore.Functions.Notify("The trunk is closed",'error')
        return
    end
    putinTrunk(veh)
end)

RegisterCommand("pit", function() TriggerEvent('gameplay:putintrunk'); end)
TriggerEvent("chat:addSuggestion", "/pit", 'Put person in trunk (Put in trunk)')

AddEventHandler('gameplay:putintrunk', function()
    local closestPlayer = BJCore.Functions.GetClosestPlayerRadius(3)
    if closestPlayer then
        local closestPed = GetPlayerPed(closestPlayer)
		local veh = BJCore.Functions.VehicleInFront()
        if veh == 0 then BJCore.Functions.Notify("No vehicle found",'error') return; end
        local lockStatus = GetVehicleDoorLockStatus(veh) 
        if lockStatus ~= 1 and lockStatus ~= 0 then 
            BJCore.Functions.Notify("The vehicle is locked", 'error')
            return
        end 
        if GetVehicleDoorAngleRatio(veh, 5) == 0.0 then   
            BJCore.Functions.Notify("The trunk is closed",'error')
            return
        end
		--StopLift()
		TriggerServerEvent("bj_gameplay:requestTrunk", GetPlayerServerId(closestPlayer), veh, false)
    else
        BJCore.Functions.Notify("No person nearby",'error')
    end
end)

RegisterCommand("dot", function() TriggerEvent('dragouttrunk'); end)
TriggerEvent("chat:addSuggestion", "/dot", 'Drag person out of trunk (Drag out trunk)')

AddEventHandler('gameplay:dragouttrunk', function()
    local closestPlayer = BJCore.Functions.GetClosestPlayerRadius(3)
    if closestPlayer then
        local veh = BJCore.Functions.VehicleInFront()
        if veh == 0 then BJCore.Functions.Notify("No vehicle found",'error') return; end
        local lockStatus = GetVehicleDoorLockStatus(veh) 
        if lockStatus ~= 1 and lockStatus ~= 0 then 
            BJCore.Functions.Notify("The vehicle is locked", 'error')
            return
        end 
        if GetVehicleDoorAngleRatio(veh, 5) == 0.0 then   
            BJCore.Functions.Notify("The trunk is closed",'error')
            return
        end
        TriggerServerEvent("bj_gameplay:requestTrunk", GetPlayerServerId(closestPlayer), false, true)
    else
        BJCore.Functions.Notify("No person nearby",'error')
    end	
end)

RegisterNetEvent('bj_gameplay:handleTrunk')
AddEventHandler('bj_gameplay:handleTrunk', function(veh)
    if veh then 
        putinTrunk()
    else
        inTrunk = false
        TriggerServerEvent("BJCore:Server:SetMetaData", "intrunk", false)
    end
end)

local cam = nil
function trunkCam()
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local plyPed = PlayerPedId()
        SetCamCoord(cam, GetEntityCoords(plyPed))
        SetCamRot(cam, 0.0, 0.0, 0.0)
        SetCamActive(cam,  true)
        RenderScriptCams(true,  false,  0,  true,  true)
        SetCamCoord(cam, GetEntityCoords(plyPed))
    end
    AttachCamToEntity(cam, PlayerPedId(), 0.0, -2.5, 1.0, true)
    SetCamRot(cam, -30.0, 0.0, GetEntityHeading(PlayerPedId()))
end

function disableCam()
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
end

local trunkNotif = "TRNK_NOTIF"
function putinTrunk(veh)
    if veh == nil or veh == 0 then veh = BJCore.Functions.VehicleInFront(); end
	local blacklist = blacklistedModel(veh)
	if blacklist then BJCore.Functions.Notify("Trunk not available on this model", 'error') return; end
	if not DecorGetBool(veh, 'Vehicle.trunkInUse') then
		local model = GetEntityModel(veh)
		if not DoesVehicleHaveDoor(veh, 6) and DoesVehicleHaveDoor(veh, 5) and IsThisModelACar(model) then
			SetVehicleDoorOpen(veh, 5, 1)
			local plyPed = PlayerPedId()

			local d1,d2 = GetModelDimensions(model)

			local trunkDic = "fin_ext_p1-7"
			local trunkAnim = "cs_devin_dual-7"
			BJCore.Functions.LoadAnimDict(trunkDic)

			SetBlockingOfNonTemporaryEvents(plyPed, true)                  
			--SetPedKeepTask(plyPed, true)   
			DetachEntity(plyPed)
			ClearPedTasks(plyPed)
			ClearPedSecondaryTask(plyPed)
			ClearPedTasksImmediately(plyPed)
			TaskPlayAnim(plyPed, trunkDic, trunkAnim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)

			AttachEntityToEntity(plyPed, veh, 0, -0.1,d1["y"]+0.85,d2["z"]-0.87, 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
			inTrunk = true
			trunkVeh = veh
			TriggerServerEvent("BJCore:Server:SetMetaData", "intrunk", true)
			DecorSetBool(veh, 'Vehicle.trunkInUse', true)
			exports['core']:PersistentAlert('start', trunkNotif, 'inform', "Controls: [F] Exit vehicle | [H] Open/Close Trunk")

			while inTrunk do
				trunkCam()

				if IsPedCuffed(plyPed) then
					Citizen.Wait(0)
				else
					Citizen.Wait(0)
					if IsControlJustReleased(0, 74) then
						TriggerServerEvent("gameplay:server:toggleTrunkDoor",VehToNet(veh))
					end

					if IsControlJustReleased(0, 23) then
						inTrunk = false
					end
				end

				if not IsEntityPlayingAnim(plyPed, trunkDic, trunkAnim, 3) then
					TaskPlayAnim(plyPed, trunkDic, trunkAnim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
				end

				if not DoesEntityExist(veh) then
					inTrunk = false
				end
			end
            exports['core']:PersistentAlert('end', trunkNotif)
            TriggerServerEvent("BJCore:Server:SetMetaData", "intrunk", false)
			DecorSetBool(veh, 'Vehicle.trunkInUse', false)
			BJCore.Functions.RemoveAnimDict(trunkDic)
			SetVehicleDoorOpen(veh, 5, 1, 0)
			disableCam()
			DetachEntity(plyPed)
			Citizen.Wait(10)
			if DoesEntityExist(veh) then 
				local dropPosition = GetOffsetFromEntityInWorldCoords(veh, 0.0,d1["y"]-0.6,0.0)
				SetEntityCoords(plyPed,dropPosition["x"],dropPosition["y"],dropPosition["z"])
			else
				ClearPedTasks(plyPed)
				local plyCoords = GetEntityCoords(plyPed)
				SetEntityCoords(plyped, plyCoords.x, plyCoords.y, plyCoords.x+2)
			end
			trunkVeh = nil
		end
	else
		BJCore.Functions.Notify("Trunk occupied",'error')
	end
end

RegisterNetEvent("gameplay:client:toggleTrunkDoor")
AddEventHandler("gameplay:client:toggleTrunkDoor", function(veh)
	local veh = NetToVeh(veh)
	if GetVehicleDoorAngleRatio(veh, 5) > 0.0 then
		SetVehicleDoorShut(veh, 5, false)
	else
		SetVehicleDoorOpen(veh, 5, false)
	end
end)
---

-- --- Veh sale ---
local sellAnywhere = true
local salesYard = vector3(178.38,-1150.32,29.30)
local salesRadius = 20.0
--

local isConfirming = false
local forSale = {}
local next = next

Citizen.CreateThread(function(...)
    while not BJCore do Wait(1000); end
    BJCore.Functions.TriggerServerCallback('VehSales:GetStartData', function(retTab) forSale = retTab; end)
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    playerData = BJCore.Functions.GetPlayerData()
    local lastPlate = 'SUKDIK'
    local drawText = 'YUTU'
    local lastTimer = GetGameTimer()
    while true do
        Citizen.Wait(0)
        if next(forSale) ~= nil then
            local closest,closestDist
            local plyPos = GetEntityCoords(PlayerPedId())
            for k,v in pairs(forSale) do
                local dist = #(plyPos - v.loc)
                if not closestDist or dist < closestDist then
                    closestDist = dist
                    closest = v
                end
            end
            if closestDist and closestDist < 10 then
                if not lastPlate or closest.vehProps.plate ~= lastPlate then
                    isConfirming = false
                    if closest.owner ~= playerData.citizenid then
	                    drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] [~g~E~s~] Purchase ["..BJCore.Config.Currency.Symbol.."~r~"..closest.price.."~s~]"
                    else
	                    drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] [~g~E~s~] Reclaim ["..BJCore.Config.Currency.Symbol.."~r~"..closest.price.."~s~]"
                    end
                    local turbs = 'No'
                    if closest.vehProps.modTurbo and closest.vehProps.modTurbo > 0 then turbs = 'Yes'; end
                    drawTextB = "[Turbo : ~r~"..turbs.."~s~] [Engine : ~r~"..tostring(closest.vehProps.modEngine).."~s~] [Gearbox : ~r~"..tostring(closest.vehProps.modTransmission).."~s~]"
                    drawTextC = "[Suspension : ~r~"..tostring(closest.vehProps.modSuspension).."~s~] [Armor : ~r~"..tostring(closest.vehProps.modArmor).."~s~] [Brakes : ~r~"..tostring(closest.vehProps.modBrakes).."~s~]"
                    lastPlate = closest.vehProps.plate
                end
                BJCore.Functions.DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 1.0, drawText)
                BJCore.Functions.DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 0.9, drawTextB)
                BJCore.Functions.DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 0.8, drawTextC)
                if IsControlJustPressed(0,38) and closestDist < 5.0 and GetGameTimer() - lastTimer > 150 then
                    lastTimer = GetGameTimer()
                    if not isConfirming then
                        if closest.owner ~= playerData.citizenid then
                            drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] [~g~E~s~] Confirm purchase ["..BJCore.Config.Currency.Symbol.."~g~"..closest.price.."~s~]"
                        else
                            lastPlate = false
                            BuyVehicle(closest)
                        end
                        isConfirming = true
                    else
                        lastPlate = false
                        isConfirming = false
                        BuyVehicle(closest)
                    end
                end
            else
                if closestDist and closestDist > 20 then Citizen.Wait(700); end
                lastPlate = false
                isConfirming = false
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function AddCar(vehId,loc,price,props,id)
    local veh = NetworkGetEntityFromNetworkId(vehId)
    if DoesEntityExist(veh) then
	    SetEntityAsMissionEntity(veh,true,true)
	    SetVehicleDoorsLocked(veh,2)
	    SetVehicleDoorsLockedForAllPlayers(veh,true)
	    SetEntityInvincible(veh,true)
	    SetVehicleEngineOn(veh,false,true,true)
	end
    table.insert(forSale,{veh = vehId, loc = loc, price = price, vehProps = props, owner = id})
end

function BuyVehicle(closest)
    BJCore.Functions.TriggerServerCallback('VehSales:TryBuy', function(can,msg)
        if can then
            BJCore.Functions.Notify(msg,'primary')
            local veh = NetworkGetEntityFromNetworkId(closest.veh)
            TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
            TriggerServerEvent('VehSales:BuyVeh', closest)
        else
            BJCore.Functions.Notify(msg,'primary')
        end
    end,closest)
end

RegisterNetEvent("VehSales:AttemptSell")
AddEventHandler("VehSales:AttemptSell", function(price)
	local plyPed = PlayerPedId()
    if not price or not price[1] then BJCore.Functions.Notify("You need to enter a price",'error'); return; end
    if type(price) == "table" then price = tonumber(price[1]); end
    if not price or type(price) ~= "number" or price <= 0 then BJCore.Functions.Notify("Only use numbers with the sellCar command", 'error',4000); return; end
    if not IsPedInAnyVehicle(plyPed,false) then BJCore.Functions.Notify("You must be in a vehicle",'error'); return; end
    if not sellAnywhere and #(GetEntityCoords(plyPed) - salesYard) > salesRadius then BJCore.Functions.Notify("You must be at the sales location to do that",'primary'); return; end
    local veh = GetVehiclePedIsIn(plyPed,false)
    local vehProps = BJCore.Functions.GetVehicleProperties(veh)
    BJCore.Functions.TriggerServerCallback('VehSales:TrySell', function(canSell,msg)
        if not canSell then
            BJCore.Functions.Notify(msg,'primary',5000)
        else
            TaskLeaveVehicle(plyPed,veh,0)
            TaskEveryoneLeaveVehicle(veh)
            local vehId = NetworkGetNetworkIdFromEntity(veh)
            TriggerServerEvent('VehSales:AddSale',vehId,GetEntityCoords(veh),price,vehProps)
        end
    end, vehProps)
end)

function RemoveVeh(veh)
    local vehi = veh
    print(veh.veh)
    print(vehi.veh)
    local veh = NetworkGetEntityFromNetworkId(veh.veh)
    SetEntityAsMissionEntity(veh,true,true)
    SetVehicleDoorsLocked(veh,0)
    SetVehicleDoorsLockedForAllPlayers(veh,false)
    SetEntityInvincible(veh,false)

    for k,v in pairs(forSale) do
        if v.vehProps.plate == vehi.vehProps.plate then forSale[k] = nil; end
    end
end

RegisterNetEvent("VehSales:AddToSale")
AddEventHandler("VehSales:AddToSale", function(veh,loc,price,props,id) AddCar(veh,loc,price,props,id); end)
RegisterNetEvent("VehSales:RemoveFromSale")
AddEventHandler("VehSales:RemoveFromSale", function(data) RemoveVeh(data); end)
---

--- Recoil ---
-- local recoils = {
-- 	[453432689] = 0.3, -- PISTOL
-- 	[3219281620] = 0.5, -- PISTOL MK2
-- 	[1593441988] = 0.2, -- COMBAT PISTOL
-- 	[-1716589765] = 0.6, -- PISTOL .50
-- 	[-1076751822] = 0.2, -- SNS PISTOL
-- 	[-771403250] = 0.5, -- HEAVY PISTOL	
-- 	[137902532] = 0.4, -- VINTAGE PISTOL
-- 	[-598887786] = 0.9, -- MARKSMAN PISTOL
-- 	[-1045183535] = 0.6, -- REVOLVER
-- 	[584646201] = 0.3, -- AP PISTOL
-- 	[911657153] = 0.1, -- STUN GUN
-- 	[1198879012] = 0.9, -- FLARE GUN
-- 	[324215364] = 0.5, -- MICRO SMG
-- 	[-619010992] = 0.3, -- MACHINE PISTOL	
-- 	[736523883] = 0.4, -- SMG
-- 	[2024373456] = 0.1, -- SMG MK2
-- 	[-270015777] = 0.1, -- ASSAULT SMG
-- 	[171789620] = 0.2, -- COMBAT PDW
-- 	[-1660422300] = 0.7, -- MG
-- 	[ 2144741730] = 0.7, -- COMBAT MG
-- 	[3686625920] = 0.1, -- COMBAT MG MK2
-- 	[1627465347] = 0.1, -- GUSENBERG
-- 	[-1121678507] = 0.1, -- MINI SMG		
-- 	[-1074790547] = 0.5, -- ASSAULT RIFLE
-- 	[961495388] = 0.2, -- ASSAULT RIFLE MK2
-- 	[-2084633992] = 0.6, -- CARBINE RIFLE
-- 	[4208062921] = 0.1, -- CARBINE RIFLE MK2
-- 	[-1357824103] = 0.1, -- ADVANCED RIFLE
-- 	[-1063057011] = 0.3, -- SPECIAL CARBINE
-- 	[2132975508] = 0.2, -- BULLPUP RIFLE
-- 	[1649403952] = 0.3, -- COMPACT RIFLE		
-- 	[487013001] = 0.4, -- PUMP SHOTGUN
-- 	[1432025498] = 0.35, -- PUMP SHOTGUN MK2
-- 	[2017895192] = 0.7, -- SAWNOFF SHOTGUN
-- 	[-494615257] = 0.4, -- ASSAULT SHOTGUN
-- 	[1654528753] = 0.2, -- BULLPUP SHOTGUN
-- 	[100416529] = 0.5, -- SNIPER RIFLE
-- 	[205991906] = 0.7, -- HEAVY SNIPER
-- 	[177293209] = 0.6, -- HEAVY SNIPER MK2
-- 	[-952879014] = 0.5, -- MARKSMAN RIFLE
-- 	[856002082] = 1.2, -- REMOTE SNIPER
-- 	[-1568386805] = 1.0, -- GRENADE LAUNCHER
-- 	[1305664598] = 1.0, -- GRENADE LAUNCHER SMOKE
-- 	[-1312131151] = 0.0, -- RPG
-- 	[1752584910] = 0.0, -- STINGER
-- 	[1119849093] = 0.01, -- MINIGUN
-- 	[3231910285] = 0.2, -- SPECIAL CARBINE
-- 	[-1768145561] = 0.15, -- SPECIAL CARBINE MK2
-- 	[-2066285827] = 0.15, -- BULLPUP RIFLE MK2
-- 	[-1466123874] = 0.7, -- MUSKET
-- 	[984333226] = 0.2, -- HEAVY SHOTGUN
-- 	[3342088282] = 0.3, -- MARKSMAN RIFLE
-- 	[1785463520] = 0.25, -- MARKSMAN RIFLE MK2
-- 	[1672152130] = 0.0, -- HOMING LAUNCHER
-- 	[2138347493] = 0.0, -- FIREWORK
-- 	[1834241177] = 2.4, -- RAILGUN
-- 	[-879347409] = 0.6, -- REVOLVER MK2
-- 	[-275439685] = 0.7, -- DOUBLE BARREL SHOTGUN
-- 	[317205821] = 0.2, -- AUTO SHOTGUN
-- 	[125959754] = 0.5, -- COMPACT LAUNCHER		
-- }

-- Citizen.CreateThread(function()
-- 	while true do
-- 		if IsPedShooting(PlayerPedId()) and not IsPedDoingDriveby(PlayerPedId()) then
-- 			local _,wep = GetCurrentPedWeapon(PlayerPedId())
-- 			print("wep", wep)
-- 			_,cAmmo = GetAmmoInClip(PlayerPedId(), wep)
-- 			print(recoils[wep])
-- 			if recoils[wep] and recoils[wep] ~= 0 then
-- 				print("recoil")
-- 				tv = 0
-- 				if GetFollowPedCamViewMode() ~= 4 then
-- 					repeat 
-- 						Wait(0)
-- 						p = GetGameplayCamRelativePitch()
-- 						SetGameplayCamRelativePitch(p+0.1, 0.2)
-- 						tv = tv+0.1
-- 					until tv >= recoils[wep]
-- 				else
-- 					repeat 
-- 						Wait(0)
-- 						p = GetGameplayCamRelativePitch()
-- 						if recoils[wep] > 0.1 then
-- 							SetGameplayCamRelativePitch(p+0.6, 1.2)
-- 							tv = tv+0.6
-- 						else
-- 							SetGameplayCamRelativePitch(p+0.016, 0.333)
-- 							tv = tv+0.1
-- 						end
-- 					until tv >= recoils[wep]
-- 				end
-- 			end
-- 		end

-- 		Citizen.Wait(0)
-- 	end
-- end)

Citizen.CreateThread( function()
	while true do 
		if IsPedArmed(PlayerPedId(), 6) then
		    Citizen.Wait(1)
		else
		 	Citizen.Wait(1500)
		 end  

	    if IsPedShooting(PlayerPedId()) then
	    	local ply = PlayerPedId()
	    	local GamePlayCam = GetFollowPedCamViewMode()
	    	local Vehicled = IsPedInAnyVehicle(ply, false)
	    	local MovementSpeed = math.ceil(GetEntitySpeed(ply))

	    	if MovementSpeed > 69 then
	    		MovementSpeed = 69
	    	end

	        local _,wep = GetCurrentPedWeapon(ply)
	        local group = GetWeapontypeGroup(wep)
	        local p = GetGameplayCamRelativePitch()
	        local cameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(ply))

	        local recoil = math.random(100,140+MovementSpeed)/100
	        local rifle = false

          	if group == 970310034 then
          		rifle = true
          	end

          	if cameraDistance < 5.3 then
          		cameraDistance = 1.5
          	else
          		if cameraDistance < 8.0 then
          			cameraDistance = 4.0
          		else
          			cameraDistance = 7.0
          		end
          	end

	        if Vehicled then
	        	recoil = recoil + (recoil * cameraDistance)
	        else
	        	recoil = recoil * 0.8
	        end

	        if GamePlayCam == 4 then
	        	recoil = recoil * 0.7
		        if rifle then
		        	recoil = recoil * 0.1
		        end
	        end

	        if rifle then
	        	recoil = recoil * 0.7
	        end

	        local rightleft = math.random(4)
	        local h = GetGameplayCamRelativeHeading()
	        local hf = math.random(10,40+MovementSpeed)/100

	        if Vehicled then
	        	hf = hf * 2.0
	        end

	        if rightleft == 1 then
	        	SetGameplayCamRelativeHeading(h+hf)
	        elseif rightleft == 2 then
	        	SetGameplayCamRelativeHeading(h-hf)
	        end 
	        local set = p+recoil
	       	SetGameplayCamRelativePitch(set,0.8)
	      -- 	print(GetGameplayCamRelativePitch())
	    end
	end
end)
---

--- Blip Manager ---
local kvpKey = nil
local BlipData = {}

local blipManager = {
    ["pd"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["hospital"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["ammunation"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["shop"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["slaughterhouse"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["fishmonger"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["hotdog"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["recycle"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["deliverydepot"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["tool"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["bank"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["garage"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["impound"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["paint"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["benny"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["vangelico"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    -- ["houses"] = {
    --     ["enabled"] = false,
    --     ["blipId"] = false
    -- },
    ["grovecustom"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["cityhall"] = {
        ["enabled"] = false,
        ["blipId"] = false
    }, 
    ["drivingschool"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["motel"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["carwash"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["clothes"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["tattoo"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["barbers"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["casino"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["pdm"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["craftsman"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["airport"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["apartments"] = {
        ["enabled"] = false,
        ["blipId"] = false
    },
    ["offices"] = {
        ["enabled"] = false,
        ["blipId"] = false
    }
    -- ["gas"] = 
    --     ["enabled"] = false,
    --     ["blipId"] = false
    -- },
}

Citizen.CreateThread(function()
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    kvpKey = "blipManagerData"
    local temp_blipData = GetResourceKvpString(kvpKey)
    if temp_blipData == nil then
        createDefaultBlipData()
    else
        BlipData = json.decode(temp_blipData)                                          
    end
    setBlips()
end)

function createDefaultBlipData()
    local data = blipManager
    SetResourceKvp(kvpKey, json.encode(data))
    local temp_blipData = GetResourceKvpString(kvpKey)
    if temp_blipData ~= nil then BlipData = json.decode(temp_blipData); end
end

function setBlips()
    for k,v in pairs(blipManager) do
        if BlipData[k] then
            if BlipData[k]["enabled"] then
                blipManager[k]["enabled"] = true
            end
        else
            BlipData[k] = blipManager[k]
        end
    end
    Citizen.CreateThread(function()
        for k,v in pairs(blipManager) do
            if v["enabled"] and k ~= "gas" then
                blipManager[k]["blipId"] = {}
                for _,pos in pairs(Config.BlipSettings[k]["pos"]) do
                    local blip = AddBlipForCoord(pos)

                    SetBlipSprite(blip, Config.BlipSettings[k]["sprite"])
                    SetBlipScale(blip, 0.65)
                    SetBlipAsShortRange(blip, true)
                    SetBlipHighDetail(blip, true)
                    if Config.BlipSettings[k]["colour"] then SetBlipColour(blip, Config.BlipSettings[k]["colour"]); end

                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(Config.BlipSettings[k]["text"])
                    EndTextCommandSetBlipName(blip)
                    local nextIndex = #blipManager[k]["blipId"] + 1
                    blipManager[k]["blipId"][nextIndex] = blip 
                end
            -- elseif v and k == "gas" then
            --     print("enable petrol stations")
            --     --TriggerEvent
            end
        end
    end)
end

RegisterNetEvent("blipManager:toggleAllBlip")
AddEventHandler("blipManager:toggleAllBlip", function(ttype)
    if ttype == "on" then
        for k,v in pairs(blipManager) do
        	if not blipManager[k]["enabled"] then
        		blipManager[k]["enabled"] = true
        		blipManager[k]["blipId"] = {}
	            for _,pos in pairs(Config.BlipSettings[k]["pos"]) do
	                local blip = AddBlipForCoord(pos)

	                SetBlipSprite(blip, Config.BlipSettings[k]["sprite"])
	                SetBlipScale(blip, 0.65)
	                SetBlipAsShortRange(blip, true)
	                SetBlipHighDetail(blip, true)
	                if Config.BlipSettings[k]["colour"] then SetBlipColour(blip, Config.BlipSettings[k]["colour"]); end

	                BeginTextCommandSetBlipName('STRING')
	                AddTextComponentSubstringPlayerName(Config.BlipSettings[k]["text"])                  
	                EndTextCommandSetBlipName(blip)
	                local nextIndex = #blipManager[k]["blipId"] + 1
	                blipManager[k]["blipId"][nextIndex] = blip 
	            end        		
        	end
        end
    elseif ttype == "off" then
    	for k,v in pairs(blipManager) do
    		if blipManager[k]["enabled"] then
                blipManager[k]["enabled"] = false
                for _,blips in pairs(blipManager[k]["blipId"]) do
                	RemoveBlip(blips)
                end
                blipManager[k]["blipId"] = false
    		end
    	end        
    end
    SetResourceKvp(kvpKey, json.encode(blipManager)) 
end)

--local next = next
RegisterNetEvent("blipManager:toggleBlip")
AddEventHandler("blipManager:toggleBlip", function(type, enabled)
    if enabled == nil then
        blipManager[type]["enabled"] = not blipManager[type]["enabled"]
    else
        blipManager[type]["enabled"] = enabled
    end
    print(tostring(blipManager[type]["enabled"]))
    print(BJCore.Common.Dump(blipManager[type]["blipId"]))
    if blipManager[type]["enabled"] and not blipManager[type]["blipId"] then
        Citizen.CreateThread(function()
            blipManager[type]["blipId"] = {}
            for _,pos in pairs(Config.BlipSettings[type]["pos"]) do
                local blip = AddBlipForCoord(pos)

                SetBlipSprite(blip, Config.BlipSettings[type]["sprite"])
                SetBlipScale(blip, 0.65)
                SetBlipAsShortRange(blip, true)
                SetBlipHighDetail(blip, true)
                if Config.BlipSettings[type]["colour"] then SetBlipColour(blip, Config.BlipSettings[type]["colour"]); end

                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.BlipSettings[type]["text"])                  
                EndTextCommandSetBlipName(blip)
                local nextIndex = #blipManager[type]["blipId"] + 1
                blipManager[type]["blipId"][nextIndex] = blip 
            end
        end)
    elseif not blipManager[type]["enabled"] and blipManager[type]["blipId"] then
        for k,v in pairs(blipManager[type]["blipId"]) do
            RemoveBlip(v)
        end
        blipManager[type]["blipId"] = false
    end
    SetResourceKvp(kvpKey, json.encode(blipManager)) 
end)

RegisterNetEvent("blipManager:togglePublicJobs")
AddEventHandler("blipManager:togglePublicJobs", function(type)
    TriggerEvent('blipManager:toggleBlip', 'slaughterhouse')
	TriggerEvent('blipManager:toggleBlip', 'fishmonger')
	TriggerEvent('blipManager:toggleBlip', 'hotdog')
    TriggerEvent('blipManager:toggleBlip', 'recycle')
    TriggerEvent('blipManager:toggleBlip', 'deliverydepot')
	if blipManager["slaughterhouse"]["enabled"] or blipManager["fishmonger"]["enabled"] or blipManager["hotdog"]["enabled"] or blipManager["hotdog"]["recycle"] then
		BJCore.Functions.Notify("You can start public jobs using the Z menu", "primary", 10000)
	end
end)

function DrawText3DMe(x,y,z, text)
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  local px,py,pz = table.unpack(GetGameplayCamCoord())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

  local scale = ((1/dist)*2)*(1/GetGameplayCamFov())*50

  if onScreen then

      -- Formalize the text
      SetTextColour(255, 255, 255, 255)
      SetTextScale(0.0*scale, 0.55*scale)
      SetTextFont(0)
      SetTextProportional(1)
      SetTextCentre(true)
      if dropShadow then
          SetTextDropshadow(10, 100, 100, 100, 255)
      end

      -- Calculate width and height
      BeginTextCommandWidth("STRING")
      AddTextComponentString(text)
      local height = GetTextScaleHeight(0.55*scale, 0)
      local width = EndTextCommandGetWidth(0)

      -- Diplay the text
      SetTextEntry("STRING")
      AddTextComponentString(text)
      EndTextCommandDisplayText(_x, _y)
	  
	  DrawRect(_x, _y+scale/45, width, height, 33, 33, 33, 75)
  end
end

local pedDisplaying = {}

local function Display(ped, text)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(playerCoords - pedCoords)

    if dist <= 100 then

        pedDisplaying[ped] = (pedDisplaying[ped] or 1) + 1
        local display = true

        Citizen.CreateThread(function()
            Wait(5000)
            display = false
        end)

        local offset = pedDisplaying[ped] * 0.1
        while display do
            if HasEntityClearLosToEntity(playerPed, ped, 17 ) then
                local x, y, z = table.unpack(GetEntityCoords(ped))
                z = z + offset
                DrawText3DMe(x, y, z, text)
            end
            Wait(0)
        end

        pedDisplaying[ped] = pedDisplaying[ped] - 1
    end
end

RegisterNetEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text, serverId)
    local player = GetPlayerFromServerId(serverId)
    if player ~= -1 then
        local ped = GetPlayerPed(player)
        Display(ped, text)
    end
end)

RegisterNetEvent('gameplay:client:rollDice')
AddEventHandler('gameplay:client:rollDice', function(times, weight)
	rollAnim()
	local strg = ""
	for i = 1, times do
		if i == 1 then
			strg = strg .. " " .. math.random(weight) .. "/" .. weight
		else
			strg = strg .. " | " .. math.random(weight) .. "/" .. weight
		end
	end
	TriggerServerEvent('3dme:server:shareText', "Dice rolled: "..strg)
end)

function rollAnim()
    loadAnimDict( "anim@mp_player_intcelebrationmale@wank" ) 
    Citizen.Wait(500)
    TaskPlayAnim( GetPlayerPed(-1), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(1500)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 2.0, 'dice', 0.2)
    ClearPedTasks(GetPlayerPed(-1))
end

local CurrentPings = {}

RegisterNetEvent('pings:client:DoPing')
AddEventHandler('pings:client:DoPing', function(id)
    local player = GetPlayerFromServerId(id)
    local ped = GetPlayerPed(player)
    local pos = GetEntityCoords(ped)
    print(pos)
    local coords = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
    }
    if not exports['police']:IsHandcuffed() then
        TriggerServerEvent('pings:server:SendPing', id, coords)
    else
        BJCore.Functions.Notify('You can\'t ping while in cuffs', 'error')
    end
end)

RegisterNetEvent('pings:client:AcceptPing')
AddEventHandler('pings:client:AcceptPing', function(PingData, SenderName)
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)

    if not exports['police']:IsHandcuffed() then
        TriggerServerEvent('pings:server:SendLocation', PingData, SenderName)
    else
        BJCore.Functions.Notify('You can\'t ping while in cuffs', 'error')
    end
end)

RegisterNetEvent('pings:client:SendLocation')
AddEventHandler('pings:client:SendLocation', function(PingData, SenderName)
    BJCore.Functions.Notify('The location has been set on your GPS', 'success')

    CurrentPings[PingData.sender] = AddBlipForCoord(PingData.coords.x, PingData.coords.y, PingData.coords.z)
    SetBlipSprite(CurrentPings[PingData.sender], 280)
    SetBlipDisplay(CurrentPings[PingData.sender], 4)
    SetBlipScale(CurrentPings[PingData.sender], 1.1)
    SetBlipAsShortRange(CurrentPings[PingData.sender], false)
    SetBlipColour(CurrentPings[PingData.sender], 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(SenderName)
    EndTextCommandSetBlipName(CurrentPings[PingData.sender])

    SetTimeout((60 * 1000), function()
        BJCore.Functions.Notify('Ping has expired', 'primary')
        RemoveBlip(CurrentPings[PingData.sender])
        CurrentPings[PingData.sender] = nil
    end)
end)

--
local particleEffects = {}

local particleList = {
    ["vehExhaust"] = {["dic"] = "core",["name"] = "veh_exhaust_truck_rig",["loopAmount"] = 25,["timeCheck"] = 12000},
    ["lavaPour"] = {["dic"] = "core",["name"] = "ent_amb_foundry_molten_pour",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["lavaSteam"] = {["dic"] = "core",["name"] = "ent_amb_steam_pipe_hvy",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["spark"] = {["dic"] = "core",["name"] = "ent_amb_sparking_wires",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["smoke"] = {["dic"] = "core",["name"] = "exp_grd_grenade_smoke",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["test"] = {["dic"] = "core",["name"] = "ent_amb_steam_pipe_hvy",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["bbq"] = {["dic"] = "core",["name"] = "ent_anim_bbq",["loopAmount"] = 1,["timeCheck"] = 12000},
    ["confetti"] = {["dic"] = "scr_xs_celebration",["name"] = "scr_xs_confetti_burst",["loopAmount"] = 1,["timeCheck"] = 12000},
}

RegisterNetEvent("particle:StartClientParticle")
AddEventHandler("particle:StartClientParticle", function(x,y,z,particleId,allocatedID,rX,rY,rZ)
    if #(vector3(x,y,z) - GetEntityCoords(PlayerPedId())) < 100 then

    local particleDictionary = particleList[particleId].dic
    local particleName = particleList[particleId].name
    local loopAmount = particleList[particleId].loopAmount

    if not HasNamedPtfxAssetLoaded(particleDictionary) then
        RequestNamedPtfxAsset(particleDictionary)
        while not HasNamedPtfxAssetLoaded(particleDictionary) do
            Wait(1)
        end
    end

    for i=0,loopAmount do
        --UseParticleFxAssetNextCall(particleDictionary)
        SetPtfxAssetNextCall(particleDictionary)
       local particle =  StartParticleFxLoopedAtCoord(particleName, x, y, z, rX,rY,rZ, 1.0, false, false, false, false)

        local object = {["particle"] = particle,["id"] = allocatedID}
        particleEffects[#particleEffects+1]=object
        Citizen.Wait(0)
    end
  
    end
end)

RegisterNetEvent("particle:StopParticleClient")
AddEventHandler("particle:StopParticleClient", function(allocatedID)
    for k, particle in pairs(particleEffects) do
        if allocatedID == particle.id then
            RemoveParticleFx(particle.particle, true)
        end
    end
end)

local RPHintCooldown = {}

Citizen.CreateThread(function()
	while true do
		local plyPos = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.RPHintLocations) do
			local notify = false
			local dist = #(plyPos - v.pos)
			if dist < v.range then
				if RPHintCooldown[k] == nil or RPHintCooldown[k] == 0 then
					RPHintCooldown[k] = v.cooldown*2
					BJCore.Functions.Notify(v.hint, "primary", v.notifyTime*1000)
				end
			end
		end
		for k,v in pairs(RPHintCooldown) do
			if RPHintCooldown[k] - 1 >= 0 then
				RPHintCooldown[k] = RPHintCooldown[k] - 1
			end
		end
		Citizen.Wait(500)
	end
end)
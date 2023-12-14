BJCore.Functions = {}
BJCore.RequestId = 0

BJCore.Functions.getKey = function(key)
    local Keys = {
        ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
        ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
        ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
        ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
        ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
        ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
        ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
        ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
        ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
    }

    return Keys[key]
end

BJCore.Functions.GetPlayerData = function(cb)
    if cb ~= nil then
        cb(BJCore.PlayerData)
    else
        return BJCore.PlayerData
    end
end

BJCore.Functions.IsPlayerLoaded = function()
	return isLoggedIn
end

BJCore.Functions.DrawText = function(x, y, width, height, scale, r, g, b, a, text)
	SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

BJCore.Functions.DrawText3D = function(x, y, z, text, linecount)
	if not linecount or linecount == nil or linecount == 0 then
		linecount = 0.7
	end
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 470
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03 * linecount, 0, 0, 0, 68)
    ClearDrawOrigin()
end

BJCore.Functions.GetCoords = function(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = heading
    }
end

BJCore.Functions.SpawnVehicle = function(model, cb, coords, isnetworked)
    local model = (type(model)=="number" and model or GetHashKey(model))
    local coords = coords ~= nil and coords or BJCore.Functions.GetCoords(PlayerPedId())
    local isnetworked = isnetworked ~= nil and isnetworked or true

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)

    SetEntityAsMissionEntity(veh, true, true)
	SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
	SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")

    SetModelAsNoLongerNeeded(model)
    TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))

    if cb ~= nil then
        cb(veh)
    end
end

BJCore.Functions.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		while not HasModelLoaded(model) do RequestModel(model) Citizen.Wait(5); end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		SetVehRadioStation(vehicle, 'OFF')

		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

BJCore.Functions.DeleteVehicle = function(vehicle)
	NetworkRequestControlOfEntity(vehicle)
	
    local timeout = 2000
	while timeout > 0 and not NetworkHasControlOfEntity(vehicle) do
		Wait(100)
		timeout = timeout - 100
	end
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

BJCore.Functions.GetVehicleInDirection = function()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

BJCore.Functions.GetClosestPlayerRadius = function(radius)
    local players = BJCore.Functions.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(targetCoords - plyCoords)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
	print("closest player is dist: " .. tostring(closestDistance))
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

BJCore.Functions.LoadAnimDict = function(dict)
	while (not HasAnimDictLoaded(dict)) do RequestAnimDict(dict) Citizen.Wait(5); end
end

BJCore.Functions.RemoveAnimDict = function(dict)
	RemoveAnimDict(dict)
end

BJCore.Functions.VehicleInFront = function()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end

function SendAlert(ttype,text,time)
	if ttype == 'inform' then ttype = 'primary'; end
	BJCore.Functions.Notify(text,ttype,time or 3000)
end

exports('SendAlert', SendAlert);

BJCore.Functions.Notify = function(text, textype, length, style) -- [text] = message, [type] = primary | error | success, [length] = time till fadeout.
    local ttype = textype ~= nil and textype or "primary"
    local length = length ~= nil and length or 5000
    SendNUIMessage({
        type = ttype,
        length = length,
        text = text,
        style = style,
    })
end

function SendAlert(ttype,text,time)
	if ttype == 'inform' then ttype = 'primary'; end
	BJCore.Functions.Notify(text,ttype,time or 3000)
end

function PersistentAlert(action, id, ttype, text, style)
	if ttype == 'inform' then ttype = 'primary'; end
	BJCore.Functions.PersistentNotify(action, id, text, ttype, style)
end

exports('PersistentAlert', PersistentAlert);

BJCore.Functions.PersistentNotify = function(action, id, text, textype, style)
	if action:upper() == 'START' then
		SendNUIMessage({
			persist = action,
			id = id,
			type = textype,
			text = text,
			style = style
		})
	elseif action:upper() == 'END' then
		SendNUIMessage({
			persist = action,
			id = id
		})
	end
end

BJCore.Functions.TriggerServerEvent = function(...)
    exports[GetCurrentResourceName()]:TriggerServerEvent(...)
end

BJCore.Functions.TriggerServerCallback = function(name, cb, ...)
	BJCore.ServerCallbacks[name] = cb
    TriggerServerEvent("BJCore:Server:TriggerServerCallback", name, ...)
end

BJCore.Functions.TriggerCallback = BJCore.Functions.TriggerServerCallback -- Backwards compatibility

BJCore.Functions.EnumerateEntities = function(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
    end)
end

BJCore.Functions.GetVehicles = function()
    local vehicles = {}
	for vehicle in BJCore.Functions.EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) do
		table.insert(vehicles, vehicle)
	end
	return vehicles
end

BJCore.Functions.GetPeds = function(ignoreList)
    local ignoreList = ignoreList or {}
	local peds       = {}
	for ped in BJCore.Functions.EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
		local found = false

        for j=1, #ignoreList, 1 do
			if ignoreList[j] == ped then
				found = true
			end
		end

		if not found then
			table.insert(peds, ped)
		end
	end

	return peds
end

BJCore.Functions.GetPlayers = function()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

BJCore.Functions.GetClosestVehicle = function(coords)
	--[[local coordFrom = coords
	local playerPed = PlayerPedId()

	if coordFrom == nil then
		coordFrom = GetEntityCoords(playerPed)
	end
	local coordTo = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 255.0, 0.0)

	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 25 then vehicle = nil end

	return vehicle ~= nil and vehicle or 0]]--
	
	local vehicles        = BJCore.Functions.GetVehicles()
	local closestDistance = -1
	local closestVehicle  = -1
	local coords          = coords

	if coords == nil then
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end
	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = #(vehicleCoords - coords)

		if closestDistance == -1 or closestDistance > distance then
			closestVehicle  = vehicles[i]
			closestDistance = distance
		end
	end
	return closestVehicle
end

BJCore.Functions.GetClosestPed = function(coords, ignoreList)
	local ignoreList      = ignoreList or {}
	local peds            = BJCore.Functions.GetPeds(ignoreList)
	local closestDistance = -1
    local closestPed      = -1
    
    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end

	for i=1, #peds, 1 do
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = #(pedCoords - coords)

		if closestDistance == -1 or closestDistance > distance then
			closestPed      = peds[i]
			closestDistance = distance
		end
	end

	return closestPed, closestDistance
end


BJCore.Functions.GetClosestPlayer = function(coords)
	if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
	end
	
	local closestPlayers = BJCore.Functions.GetPlayersFromCoords(coords)
    local closestDistance = -1
    local closestPlayer = -1

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() and closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

BJCore.Functions.GetPlayersFromCoords = function(coords, distance)
    local players = BJCore.Functions.GetPlayers()
    local closePlayers = {}

    if coords == nil then
		coords = GetEntityCoords(PlayerPedId())
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
		local target = GetPlayerPed(player)
		local targetCoords = GetEntityCoords(target)
		local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
		if targetdistance <= distance then
			table.insert(closePlayers, player)
		end
    end
    
    return closePlayers
end

BJCore.Functions.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)

		if cb ~= nil then
			cb(obj)
		end
	end)
end

BJCore.Functions.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

BJCore.Functions.GetClosestObject = function(filter, coords)
	local objects         = BJCore.Functions.GetObjects()
	local closestDistance = -1
	local closestObject   = -1
	local filter          = filter
	local coords          = coords

	if type(filter) == 'string' then
		if filter ~= '' then
			filter = {filter}
		end
    end

    local hashedFilters = {}
    
    for k=1, #filter, 1 do
        if type(filter[k]) == 'string' then
            table.insert(hashedFilters, GetHashKey(filter[k]))
        else
            table.insert(hashedFilters, filter[k])
        end
    end
    
    filter = hashedFilters

	if coords == nil then
		local playerPed = PlayerPedId()
		coords          = GetEntityCoords(playerPed)
	end

	for i=1, #objects, 1 do
		local foundObject = false

		if filter == nil or (type(filter) == 'table' and #filter == 0) then
			foundObject = true
		else
			local objectModel = GetEntityModel(objects[i])

			for j=1, #filter, 1 do
				if objectModel == filter[j] then
					foundObject = true
				end
			end
		end

		if foundObject then
			local objectCoords = GetEntityCoords(objects[i])
			local distance     = #(objectCoords - coords)

			if closestDistance == -1 or closestDistance > distance then
				closestObject   = objects[i]
				closestDistance = distance
			end
		end
	end

	return closestObject, closestDistance
end

BJCore.Functions.GetPlayersInArea = function(coords, area)
	local players       = BJCore.Functions.GetPlayers()
	local playersInArea = {}

	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = #(targetCoords - coords)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

BJCore.Functions.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

BJCore.Functions.HasItem = function(item)
    if item == nil then return false; end
	local retval, busy = false, true
	BJCore.Functions.TriggerServerCallback('BJCore:HasItem', function(result)
		if result then
			retval = true
		end
		busy = false
	end, item)
	while busy do Citizen.Wait(0); end
	return retval
end

BJCore.Functions.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
    }, function(cancelled)
        if not cancelled then
            if onFinish ~= nil then
                onFinish()
            end
        else
            if onCancel ~= nil then
                onCancel()
            end
        end
    end)
end

BJCore.Functions.GetVehicleProperties = function(vehicle)
	local color1, color2               = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	local livery = GetVehicleLivery(vehicle)
	if livery == -1 then
		livery = GetVehicleMod(vehicle, 48)
	end
	
    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        color1 = { r = r, g = g, b = b }
    end

    if GetIsVehicleSecondaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        color2 = { r = r, g = g, b = b }
    end

    local nR, nG, nB = GetVehicleNeonLightsColour(vehicle)
    local neonColor = {r = nR, g = nG, b = nB}

	local plate = GetVehicleNumberPlateText(vehicle)
	if Entity(vehicle).state.plate ~= nil then
		plate = Entity(vehicle).state.plate
	end
	local plateIndex = GetVehicleNumberPlateTextIndex(vehicle)
	if Entity(vehicle).state.plateindex ~= nil then
		plateIndex = Entity(vehicle).state.plateindex
	end

	return {

		model             = GetEntityModel(vehicle),

		plate             = plate,
		plateIndex        = plateIndex,

		fakePlate         = Entity(vehicle).state.fakeplate,
		fakePlateIndex    = Entity(vehicle).state.fakeplateindex,

		health            = GetEntityHealth(vehicle),
		dirtLevel         = GetVehicleDirtLevel(vehicle),

		color1            = color1,
		color2            = color2,

		pearlescentColor  = pearlescentColor,
		wheelColor        = wheelColor,

		wheels            = GetVehicleWheelType(vehicle),
		windowTint        = GetVehicleWindowTint(vehicle),

		neonEnabled       = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3)
		},

		extras            = {
			
		},

		neonColor         = neonColor,
		xenonColor        = GetVehicleXenonLightsColor(vehicle),
		tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

		modSpoilers       = GetVehicleMod(vehicle, 0),
		modFrontBumper    = GetVehicleMod(vehicle, 1),
		modRearBumper     = GetVehicleMod(vehicle, 2),
		modSideSkirt      = GetVehicleMod(vehicle, 3),
		modExhaust        = GetVehicleMod(vehicle, 4),
		modFrame          = GetVehicleMod(vehicle, 5),
		modGrille         = GetVehicleMod(vehicle, 6),
		modHood           = GetVehicleMod(vehicle, 7),
		modFender         = GetVehicleMod(vehicle, 8),
		modRightFender    = GetVehicleMod(vehicle, 9),
		modRoof           = GetVehicleMod(vehicle, 10),

		modEngine         = GetVehicleMod(vehicle, 11),
		modBrakes         = GetVehicleMod(vehicle, 12),
		modTransmission   = GetVehicleMod(vehicle, 13),
		modHorns          = GetVehicleMod(vehicle, 14),
		modSuspension     = GetVehicleMod(vehicle, 15),
		modArmor          = GetVehicleMod(vehicle, 16),

		modTurbo          = IsToggleModOn(vehicle, 18),
		modSmokeEnabled   = IsToggleModOn(vehicle, 20),
		modXenon          = IsToggleModOn(vehicle, 22),

		modFrontWheels    = GetVehicleMod(vehicle, 23),
		modBackWheels     = GetVehicleMod(vehicle, 24),

		modPlateHolder    = GetVehicleMod(vehicle, 25),
		modVanityPlate    = GetVehicleMod(vehicle, 26),
		modTrimA          = GetVehicleMod(vehicle, 27),
		modOrnaments      = GetVehicleMod(vehicle, 28),
		modDashboard      = GetVehicleMod(vehicle, 29),
		modDial           = GetVehicleMod(vehicle, 30),
		modDoorSpeaker    = GetVehicleMod(vehicle, 31),
		modSeats          = GetVehicleMod(vehicle, 32),
		modSteeringWheel  = GetVehicleMod(vehicle, 33),
		modShifterLeavers = GetVehicleMod(vehicle, 34),
		modAPlate         = GetVehicleMod(vehicle, 35),
		modSpeakers       = GetVehicleMod(vehicle, 36),
		modTrunk          = GetVehicleMod(vehicle, 37),
		modHydrolic       = GetVehicleMod(vehicle, 38),
		modEngineBlock    = GetVehicleMod(vehicle, 39),
		modAirFilter      = GetVehicleMod(vehicle, 40),
		modStruts         = GetVehicleMod(vehicle, 41),
		modArchCover      = GetVehicleMod(vehicle, 42),
		modAerials        = GetVehicleMod(vehicle, 43),
		modTrimB          = GetVehicleMod(vehicle, 44),
		modTank           = GetVehicleMod(vehicle, 45),
		modWindows        = GetVehicleMod(vehicle, 46),
		modLivery         = livery,
		modCustomTyres	  = GetVehicleModVariation(vehicle, 23)
	}
end

BJCore.Functions.SetVehicleProperties = function(vehicle, props)
	SetVehicleModKit(vehicle, 0)

	if props.plate ~= nil then
		SetVehicleNumberPlateText(vehicle, props.plate)
		TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'plate', props.plate)
	end

	if props.plateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
		TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'plateindex', props.plateIndex)
	end

	if props.fakePlate ~= nil then
		SetVehicleNumberPlateText(vehicle, props.fakePlate)
		TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'fakeplate', props.fakePlate)
	end

	if props.fakePlateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle, props.fakePlateIndex)
		TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(vehicle), 'fakeplateindex', props.fakePlateIndex)
	end

	if props.health ~= nil then
		SetEntityHealth(vehicle, props.health)
	end

	if props.dirtLevel ~= nil then
		SetVehicleDirtLevel(vehicle, props.dirtLevel)
	end

	if props.color1 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
        ClearVehicleCustomPrimaryColour(vehicle)
        if type(props.color1) == 'table' then
            SetVehicleColours(vehicle, 1, color2)
            SetVehicleCustomPrimaryColour(vehicle, props.color1.r, props.color1.g, props.color1.b)
        else
            SetVehicleColours(vehicle, props.color1, color2)
        end
	end

	if props.color2 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
        ClearVehicleCustomSecondaryColour(vehicle)
        if type(props.color2) == 'table' then
            SetVehicleColours(vehicle, 1, color2)
            SetVehicleCustomSecondaryColour(vehicle, props.color2.r, props.color2.g, props.color2.b)
        else
            SetVehicleColours(vehicle, color1, props.color2)
        end
	end

	if props.pearlescentColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
	end

	if props.wheelColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
	end

	if props.wheels ~= nil then
		SetVehicleWheelType(vehicle, props.wheels)
	end

	if props.windowTint ~= nil then
		SetVehicleWindowTint(vehicle, props.windowTint)
	end

	if props.neonEnabled ~= nil then
		SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
		SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
		SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
		SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
	end

	if props.neonColor ~= nil then
		SetVehicleNeonLightsColour(vehicle, props.neonColor.r, props.neonColor.g, props.neonColor.b)
	end

	if props.modSmokeEnabled ~= nil then
		ToggleVehicleMod(vehicle, 20, true)
	end

	if props.tyreSmokeColor ~= nil then
		SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
	end

	if props.modSpoilers ~= nil then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper ~= nil then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper ~= nil then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt ~= nil then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust ~= nil then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame ~= nil then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille ~= nil then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood ~= nil then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender ~= nil then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender ~= nil then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof ~= nil then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine ~= nil then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes ~= nil then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission ~= nil then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns ~= nil then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension ~= nil then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor ~= nil then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end

	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
	end

	if props.xenonColor ~= nil then
		SetVehicleXenonLightsColor(vehicle, props.xenonColor)
	end

	if props.modFrontWheels ~= nil then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end

	if props.modBackWheels ~= nil then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end

	if props.modPlateHolder ~= nil then
		SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
	end

	if props.modVanityPlate ~= nil then
		SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
	end

	if props.modTrimA ~= nil then
		SetVehicleMod(vehicle, 27, props.modTrimA, false)
	end

	if props.modOrnaments ~= nil then
		SetVehicleMod(vehicle, 28, props.modOrnaments, false)
	end

	if props.modDashboard ~= nil then
		SetVehicleMod(vehicle, 29, props.modDashboard, false)
	end

	if props.modDial ~= nil then
		SetVehicleMod(vehicle, 30, props.modDial, false)
	end

	if props.modDoorSpeaker ~= nil then
		SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
	end

	if props.modSeats ~= nil then
		SetVehicleMod(vehicle, 32, props.modSeats, false)
	end

	if props.modSteeringWheel ~= nil then
		SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
	end

	if props.modShifterLeavers ~= nil then
		SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
	end

	if props.modAPlate ~= nil then
		SetVehicleMod(vehicle, 35, props.modAPlate, false)
	end

	if props.modSpeakers ~= nil then
		SetVehicleMod(vehicle, 36, props.modSpeakers, false)
	end

	if props.modTrunk ~= nil then
		SetVehicleMod(vehicle, 37, props.modTrunk, false)
	end

	if props.modHydrolic ~= nil then
		SetVehicleMod(vehicle, 38, props.modHydrolic, false)
	end

	if props.modEngineBlock ~= nil then
		SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
	end

	if props.modAirFilter ~= nil then
		SetVehicleMod(vehicle, 40, props.modAirFilter, false)
	end

	if props.modStruts ~= nil then
		SetVehicleMod(vehicle, 41, props.modStruts, false)
	end

	if props.modArchCover ~= nil then
		SetVehicleMod(vehicle, 42, props.modArchCover, false)
	end

	if props.modAerials ~= nil then
		SetVehicleMod(vehicle, 43, props.modAerials, false)
	end

	if props.modTrimB ~= nil then
		SetVehicleMod(vehicle, 44, props.modTrimB, false)
	end

	if props.modTank ~= nil then
		SetVehicleMod(vehicle, 45, props.modTank, false)
	end

	if props.modWindows ~= nil then
		SetVehicleMod(vehicle, 46, props.modWindows, false)
	end

	if props.modLivery ~= nil then
		SetVehicleMod(vehicle, 48, props.modLivery, false)
		SetVehicleLivery(vehicle, props.modLivery)
	end
	if props.modCustomTyres ~= nil and props.modCustomTyres then 
		SetVehicleMod(vehicle, 23, props.modCustomTyres, true)
	end
end

BJCore.Functions.IsSpawnPointClear = function(coords, maxDistance) return #BJCore.Functions.GetVehiclesInArea(coords, maxDistance) == 0 end
BJCore.Functions.GetVehiclesInArea = function(coords, area)
	local vehicles       = BJCore.Functions.GetVehicles()
	local vehiclesInArea = {}

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = #(vehicleCoords -coords)

		if distance <= area then
			table.insert(vehiclesInArea, vehicles[i])
		end
	end

	return vehiclesInArea
end

BJCore.Functions.GetClosestAction = function(plyPos, tab, key)
    local closestKey, closestVal, closestDist
    for k,v in pairs(tab) do
        local dist = #(plyPos - v[key])
        if not closestDist or dist < closestDist then
            closestKey = k
            closestVal = v
            closestDist = dist
        end
    end
    if not closestDist then return false, false, 999999
    else return closestKey, closestVal, closestDist
    end
end

BJCore.Functions.DisplayHelpText = function(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

BJCore.Functions.GetKeyPressed = function(key)
    if not key then return false; end
    local numKey = BJCore.Functions.getKey(key)
    if (IsDisabledControlJustPressed(0, numKey) or IsControlJustPressed(0, numKey)) then return true
    else return false; end
end

ShowingOnscreenKeyboard = false
BJCore.Functions.IsOnscreenKeyboard = function()
	return ShowingOnscreenKeyboard
end

BJCore.Functions.GetOnscreenKeyboardInput = function(TextEntry, ExampleText, MaxStringLenght)
    -- TextEntry        --> The Text above the typing field in the black square
    -- ExampleText      --> An Example Text, what it should say in the typing field
    -- MaxStringLenght  --> Maximum String Lenght

    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    ShowingOnscreenKeyboard = true -- Blocks new input while typing

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        ShowingOnscreenKeyboard = false
        return result
    else
        Citizen.Wait(500)
        ShowingOnscreenKeyboard = false
        return nil
    end
end

BJCore.Functions.GetSurfaceType = function()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local num = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z+4, plyPos.x, plyPos.y, plyPos.z-2.0, 2, 1, plyPed, 7)
    local arg1, arg2, arg3, arg4, arg5, arg6 = GetShapeTestResultIncludingMaterial(num)
    return arg5
end

local entityEnumerator = { __gc = function(enum) if enum.destructor and enum.handle then enum.destructor(enum.handle) end enum.destructor = nil enum.handle = nil end }
local function EnumerateEntities(initFunc, moveFunc, disposeFunc) return coroutine.wrap(function() local iter, id = initFunc() if not id or id == 0 then disposeFunc(iter) return end local enum = {handle = iter, destructor = disposeFunc} setmetatable(enum, entityEnumerator) local next = true repeat coroutine.yield(id) next, id = moveFunc(iter) until not next enum.destructor, enum.handle = nil, nil disposeFunc(iter) end) end
function EnumerateObjects() return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) end
function EnumeratePeds() return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) end
function EnumerateVehicles() return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) end
function EnumeratePickups() return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup) end
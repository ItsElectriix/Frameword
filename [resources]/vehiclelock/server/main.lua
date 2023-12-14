local vehicleData = {}
local vehicleLockData = {}
local sharedPlates = {}
local vehicleKeysReady = false

function Awake(...)
	while not BJCore do Citizen.Wait(0); end

	exports['ghmattimysql']:execute('SELECT citizenid, plate FROM player_vehicles', {}, function(result)
		if #result > 0 then
			for i = 1, #result do
				local plateStripped = string.gsub(result[i].plate, "%s+", "")
                local owners = result[i].citizenid
                if owners ~= nil then
	                if vehicleData[owners] == nil then
	                	vehicleData[owners] = {}
	                end
	                vehicleData[owners][plateStripped] = true
					vehicleLockData[plateStripped] = { owner = citizenid, lockstatus = false }
				else
					print("[VEHICLELOCK] - "..result[i].plate.." is missing citizenid in database")
				end
			end
		end
		vehicleKeysReady = true
    end)
end

RegisterServerEvent('vehiclelock:transferOwner')
AddEventHandler('vehiclelock:transferOwner', function(plate, ownerID)
	if plate and ownerID then
        local plateStripped = stripPlate(plate)
        local pData = BJCore.Functions.GetPlayer(ownerID)

		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)
			while not vehicleLockData[plateStripped] do Wait(0) end
            vehicleLockData[plateStripped].owner = pData.PlayerData.citizenid
		else
            vehicleLockData[plateStripped].owner = pData.PlayerData.citizenid
        end
        TriggerClientEvent("vehiclelock:syncToClients", -1, vehicleLockData)
	end
end)

RegisterServerEvent('vehiclelock:lockPick')
AddEventHandler('vehiclelock:lockPick', function(plate)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if plate then
		local plateStripped = stripPlate(plate)

		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)
			while not vehicleLockData[plateStripped] do Wait(0) end
			vehicleLockData[plateStripped].lockstatus = false
		else
			vehicleLockData[plateStripped].lockstatus = false
        end
        TriggerEvent("bj-log:server:CreateLog", "default", "Vehicle Locks/Keys", "green", "**"..Player.PlayerData.name .. "** has unlocked vehicle reg: "..plate.." with a lockpick.")
	end
end)

RegisterServerEvent('vehiclelock:getLockStatus')
AddEventHandler('vehiclelock:getLockStatus', function(plate, call, allow)
	if not plate then return end
	local plateStripped = stripPlate(plate)
	local _source = source

	if call == 'outside' then
		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)
			setvehicleLocks(plate, plateStripped, call)
		else
			setvehicleLocks(plate, plateStripped, call)
		end
	elseif call == 'inside' then
		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)

			if allow then			
				setvehicleLocks(plate, plateStripped, call)
			else
				setvehicleLocks(nil, nil, 'notauth')
			end
		else
			if allow then			
				if vehicleLockData[plateStripped].lockstatus == true then 
					vehicleLockData[plateStripped].lockstatus = 4
				elseif vehicleLockData[plateStripped].lockstatus == 4 then 
					vehicleLockData[plateStripped].lockstatus = false
				elseif vehicleLockData[plateStripped].lockstatus == false then
					vehicleLockData[plateStripped].lockstatus = true			
				end
				setvehicleLocks(plate, plateStripped, call)
			else
				setvehicleLocks(nil, nil, 'notauth')			
			end
		end		
	elseif call == 'exiting'  then
		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)

			if vehicleLockData[plateStripped].lockstatus == true or vehicleLockData[plateStripped].lockstatus == 4 then
				vehicleLockData[plateStripped].lockstatus = false
				setvehicleLocks(plate, plateStripped, call)
			end
		else
			if vehicleLockData[plateStripped].lockstatus == true or vehicleLockData[plateStripped].lockstatus == 4 then
				vehicleLockData[plateStripped].lockstatus = false
				setvehicleLocks(plate, plateStripped, call)
			end
			setvehicleLocks(plate, plateStripped, call)
		end
	elseif call == 'remote' then
		if not vehicleLockData[plateStripped] then
			getlockStatus(plate)

			if allow then			
				setvehicleLocks(plate, plateStripped, call)
			else
				setvehicleLocks(nil, nil, 'notauth')
			end
		else
			if allow then			
				vehicleLockData[plateStripped].lockstatus = not vehicleLockData[plateStripped].lockstatus
				setvehicleLocks(plate, plateStripped, call)
			else
				setvehicleLocks(nil, nil, 'notauth')			
			end
		end
	end
end)

getlockStatus = function(plate)
	local plateStripped = stripPlate(plate)

	if vehicleLockData[plateStripped] then
		return(vehicleLockData[plateStripped].lockstatus)
	else
		vehicleLockData[plateStripped] = {owner = 'lol', lockstatus = false}		
		return(vehicleLockData[plateStripped].lockstatus)
	end
end

setvehicleLocks = function(plate, plateStripped, call)
	local _source = source

	if call == 'notauth' then
		TriggerClientEvent('vehiclelock:setvehicleLock', _source, nil, nil, call, false)
		return
	end

	local players = nil
	local players = GetPlayers()

	TriggerClientEvent('vehiclelock:setvehicleLock', _source, plate, vehicleLockData[plateStripped].lockstatus, call, true)
	
	for _,player in pairs(players) do
		if _source ~= tonumber(player) then
			TriggerClientEvent('vehiclelock:setvehicleLock', player, plate, vehicleLockData[plateStripped].lockstatus, call, false)
		end
	end
end

isAuthorised = function(plate, justOwner)
	local _source = source
	local pData = BJCore.Functions.GetPlayer(_source)
	local identifier = pData.PlayerData.stean
	local plateStripped = stripPlate(plate)

	if vehicleLockData[plateStripped].owner == identifier then
		return true
	elseif sharedPlates[plateStripped] and not justOwner then
		for i=1,#sharedPlates[plateStripped] do
			if sharedPlates[plateStripped][i] == identifier then
				return true
			end
		end
	end
end

stripPlate = function(plate)
	return string.gsub(plate, "%s+", "")
end

BJCore.Functions.RegisterServerCallback('vehiclelock:giveKey', function(source, cb, plate, target)
	local _source = source
	local Player = BJCore.Functions.GetPlayer(_source)
	local owner = smdKash(source)
	local sharedOwner = smdKash(target)
	local plateStripped = stripPlate(plate)	

	local plateCheck = nil

	if vehicleLockData[plateStripped] and vehicleLockData[plateStripped].owner == owner then
		if(sharedPlates[plateStripped])then
			for k,v in pairs(sharedPlates[plateStripped]) do
				if v == sharedOwner then 
					cb('alreadyKey')
					plateCheck = true
					return
				end
				plateCheck = false
			end

			if not plateCheck then
				table.insert(sharedPlates[plateStripped], sharedOwner)
				cb('added')
				TriggerClientEvent('BJCore:Notify',target,'You have received keys for vehicle: '..plate..' (temp)','primary',5500)
			end
		else
			sharedPlates[plateStripped] = {sharedOwner}
			cb('added')
			TriggerClientEvent('BJCore:Notify', target, 'You have received keys for vehicle: '..plate..' (temp)','primary',5500)
		end
	else
		cb('notOwner')
	end
end)

BJCore.Functions.RegisterServerCallback('vehiclelock:isOwner', function(source, cb, plate)
	local _source = source
	local ply = smdKash(_source)
	local plateStripped = stripPlate(plate)

	if vehicleLockData[plateStripped] then
		if vehicleLockData[plateStripped].owner == ply then
			cb(true)
		elseif sharedPlates[plateStripped] then
			for i=1,#sharedPlates[plateStripped] do
				if sharedPlates[plateStripped][i] == ply then
					cb(true)
				end
			end
		else
			cb(false)
		end
	else
		cb(false)
	end
end)

RegisterNetEvent("vehiclelock:addNewKey")
AddEventHandler("vehiclelock:addNewKey", function(plate)
	local src = source
	local pData = BJCore.Functions.GetPlayer(src)
	vehicleData[pData.PlayerData.citizenid][plate] = true
end)

RegisterServerEvent('vehiclelock:giveKeys')
AddEventHandler('vehiclelock:giveKeys', function(t, plate)
    local _source = source
    local Player = BJCore.Functions.GetPlayer(_source)
    local Target = BJCore.Functions.GetPlayer(t)
    TriggerClientEvent('BJCore:Notify',_source,'You have given keys for vehicle: '..plate,'primary')
    TriggerEvent("bj-log:server:CreateLog", "default", "Vehicle Locks/Keys", "green", "**"..Player.PlayerData.name .. "** has given keys to **"..Target.PlayerData.name.."** for vehicle reg: "..plate..".")
    TriggerClientEvent("keys:receiveKeys", t, plate)
end)

RegisterServerEvent('vehiclelock:getVehicleData')
AddEventHandler('vehiclelock:getVehicleData', function()
	local src = source
	while not vehicleKeysReady do Citizen.Wait(1000); end
    local pData = BJCore.Functions.GetPlayer(src)
    if vehicleData[pData.PlayerData.citizenid] == nil then
    	vehicleData[pData.PlayerData.citizenid] = {}
    end
    TriggerClientEvent("vehiclelock:syncToClients", src, vehicleData[pData.PlayerData.citizenid])
end)

Citizen.CreateThread(function(...) Awake(...); end)
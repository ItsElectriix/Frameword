Config = {}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

-- priority list can be any identifier. (hex steamid, steamid32, ip) Integer = power over other people with priority
-- a lot of the steamid converting websites are broken rn and give you the wrong steamid. I use https://steamid.xyz/ with no problems.
-- you can also give priority through the API, read the examples/readme.
Config.Priority = {}

-- require people to run steam
Config.RequireSteam = true

-- "whitelist" only server
Config.PriorityOnly = false

-- disables hardcap, should keep this true
Config.DisableHardCap = true

-- will remove players from connecting if they don't load within: __ seconds; May need to increase this if you have a lot of downloads.
-- i have yet to find an easy way to determine whether they are still connecting and downloading content or are hanging in the loadscreen.
-- This may cause session provider errors if it is too low because the removed player may still be connecting, and will let the next person through...
-- even if the server is full. 10 minutes should be enough
Config.ConnectTimeOut = 180

-- will remove players from queue if the server doesn't recieve a message from them within: __ seconds
Config.QueueTimeOut = 90

-- will give players temporary priority when they disconnect and when they start loading in
Config.EnableGrace = true

-- how much priority power grace time will give
Config.GracePower = 99

-- how long grace time lasts in seconds
Config.GraceTime = 300

-- on resource start, players can join the queue but will not let them join for __ milliseconds
-- this will let the queue settle and lets other resources finish initializing
Config.JoinDelay = 30000

-- will show how many people have temporary priority in the connection message
Config.ShowTemp = false

-- simple localization
Config.Language = {
    joining = "\xF0\x9F\x8E\x89Loading in..",
    connecting = "\xE2\x8F\xB3Connecting...",
    idrr = "\xE2\x9D\x97[Queue] Error: Failed to retrieve IDs, try restarting your game.",
    err = "\xE2\x9D\x97[Queue] There is a error",
    pos = "\xF0\x9F\x90\x8CYou are %d/%d in the queue \xF0\x9F\x95\x9C%s",
    connectingerr = "\xE2\x9D\x97[Queue] Error: Cannot add to the queue..",
    timedout = "\xE2\x9D\x97[Queue] Error: Timed out",
    wlonly = "\xE2\x9D\x97[Queue] You must have a whitelist to join the server..",
    steam = "\xE2\x9D\x97 [Queue] Error: Steam must be open.."
}

Citizen.CreateThread(function()
	loadDatabaseQueue()
end)

function loadDatabaseQueue()
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `queue`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				Config.Priority[v.steam] = tonumber(v.priority)
			end
		end
	end)
end

BJCore.Commands.Add("reloadqueuepriority", "Reload queue", {{name="id", help="ID of the player"}, {name="priority", help="Priority level"}}, true, function(source, args)
	loadDatabaseQueue()
	TriggerClientEvent('chatMessage', source, "SYSTEM", "normal", "REFRESH")	
end, "god")

BJCore.Commands.Add("addpriority", "Give queue priority", {{name="id", help="ID of the player"}, {name="priority", help="Priority level"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
	local level = tonumber(args[2])
	if Player ~= nil then
        AddPriority(Player.PlayerData.source, level)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "normal", "you gave " .. GetPlayerName(Player.PlayerData.source) .. " priority level ("..level..")")	
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not online!")	
	end
end, "admin")

BJCore.Commands.Add("removepriority", "Take priority away from someone", {{name="id", help="ID of the player"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
        RemovePriority(Player.PlayerData.source)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "normal", "You removed priority from " .. GetPlayerName(Player.PlayerData.source))	
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not online!")	
	end
end, "admin")

function AddPriority(source, level)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		Config.Priority[GetPlayerIdentifiers(source)[1]] = level
		BJCore.Functions.ExecuteSql(true, "DELETE FROM `queue` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		BJCore.Functions.ExecuteSql(true, "INSERT INTO `queue` (`name`, `steam`, `license`, `priority`) VALUES ('"..GetPlayerName(source).."', '"..GetPlayerIdentifiers(source)[1].."', '"..GetPlayerIdentifiers(source)[2].."', '"..level.."')")
		Player.Functions.UpdatePlayerData()
	end
end

function RemovePriority(source)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		Config.Priority[GetPlayerIdentifiers(source)[1]] = nil
		BJCore.Functions.ExecuteSql(true, "DELETE FROM `queue` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
	end
end

RegisterCommand('_t_cq', function(source, args, raw)
	if source == nil or tonumber(source) ~= 0 then
		print('This is a server command only.')
		return
	end
	if #args < 4 then
		-- Not enough args
		return
	end

	local type, name, steam, prio = args[1], args[2], args[3], args[4]

	BJCore.Functions.ExecuteSql(true, "DELETE FROM `queue` WHERE `steam` = @steam", {['@steam'] = steam})
	if args[1] == 'set' then
		Config.Priority[steam] = tonumber(prio)
		BJCore.Functions.ExecuteSql(true, "INSERT INTO `queue` (`name`, `steam`, `license`, `priority`) VALUES (@name, @steam, '', @level)", {
			['@name'] = name,
			['@steam'] = steam,
			['@level'] = prio
		})
	else
		Config.Priority[steam] = nil
	end
end, true)
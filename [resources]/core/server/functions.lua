BJCore.Functions = {}

BJCore.Functions.ExecuteSql = function(wait, query, cb, params)
	local rtndata = {}
	local waiting = true
	exports['ghmattimysql']:execute(query, params and params or {}, function(data)
		if cb ~= nil and wait == false then
			cb(data and data or {})
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata and rtndata or {})
		end
	end
	return (rtndata and rtndata or {})
end

BJCore.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~=nil and idtype or BJConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

BJCore.Functions.GetSource = function(identifier)
	for src, player in pairs(BJCore.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

BJCore.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return BJCore.Players[source]
	else
		return BJCore.Players[BJCore.Functions.GetSource(source)]
	end
end

BJCore.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(BJCore.Players) do
		local cid = citizenid
		if BJCore.Players[src].PlayerData.citizenid == cid then
			return BJCore.Players[src]
		end
	end
	return nil
end

BJCore.Functions.CreateVIN = function()
    local UniqueFound = false
    local vin = nil

    while not UniqueFound do
        vin = tostring('1' .. BJCore.Shared.RandomStr(2) .. BJCore.Shared.RandomInt(4) .. BJCore.Shared.RandomStr(4) .. BJCore.Shared.RandomInt(6))
        BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM player_vehicles WHERE vin = @vin", function(result)
            if result[1].count == 0 then
                UniqueFound = true
            end
        end, {
            ['@vin'] = vin
        })
    end
    return vin
end

BJCore.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(BJCore.Players) do
		local cid = citizenid
		if BJCore.Players[src].PlayerData.charinfo.phone == number then
			return BJCore.Players[src]
		end
	end
	return nil
end

BJCore.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(BJCore.Players) do
		table.insert(sources, k)
	end
	return sources
end

BJCore.Functions.RegisterServerEvent = function(...)
    exports[GetCurrentResourceName()]:RegisterServerEvent(...)
end

BJCore.Functions.RegisterServerCallback = function(name, cb)
	BJCore.ServerCallbacks[name] = cb
end

BJCore.Functions.CreateCallback = BJCore.Functions.RegisterServerCallback

BJCore.Functions.TriggerServerCallback = function(name, source, cb, ...)
	if BJCore.ServerCallbacks[name] ~= nil then
		BJCore.ServerCallbacks[name](source, cb, ...)
	end
end

BJCore.Functions.CreateUseableItem = function(item, cb)
	BJCore.UseableItems[item] = cb
end

BJCore.Functions.CanUseItem = function(item)
	return BJCore.UseableItems[item] ~= nil
end

BJCore.Functions.UseItem = function(source, item)
	BJCore.UseableItems[item.name](source, item)
end

BJCore.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check our Discord for further information: "..BJCore.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

BJCore.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (BJCore.Config.Server.whitelist) then
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM `whitelist` WHERE `"..BJCore.Config.IdentifierType.."` = '".. BJCore.Functions.GetIdentifier(source).."'", function(result)
			local data = result[1]
			if data ~= nil then
				for _, id in pairs(identifiers) do
					if data.steam == id or data.license == id then
						rtn = true
					end
				end
			end
		end)
		if not rtn then
			if BJCore.Config.Server.UseDiscordAPI and BJCore.Config.Server.DiscordWhitelistedRole then
				local roles = BJCore.DiscordAPI.GetDiscordRoles(source)
				if roles then
					for _,id in pairs(roles) do
						if id == BJCore.Config.Server.DiscordWhitelistedRole then
							rtn = true
							break
						end
					end
				end
			end
		end
	else
		rtn = true
	end
	return rtn
end

BJCore.Functions.AddPermission = function(source, permission, server)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		BJCore.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = {
			steam = GetPlayerIdentifiers(source)[1],
			license = GetPlayerIdentifiers(source)[2],
			permission = permission:lower(),
		}
		if server == "dev" then
			BJCore.Functions.ExecuteSql(true, "DELETE FROM `permissions_dev` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
			BJCore.Functions.ExecuteSql(true, "INSERT INTO `permissions_dev` (`name`, `steam`, `license`, `permission`) VALUES ('"..GetPlayerName(source).."', '"..GetPlayerIdentifiers(source)[1].."', '"..GetPlayerIdentifiers(source)[2].."', '"..permission:lower().."')")
		else
			BJCore.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
			BJCore.Functions.ExecuteSql(true, "INSERT INTO `permissions` (`name`, `steam`, `license`, `permission`) VALUES ('"..GetPlayerName(source).."', '"..GetPlayerIdentifiers(source)[1].."', '"..GetPlayerIdentifiers(source)[2].."', '"..permission:lower().."')")
		end
		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('BJCore:Client:OnPermissionUpdate', source, permission)
	end
end

BJCore.Functions.RemovePermission = function(source, server)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		BJCore.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = nil	
		if server == "dev" then
			BJCore.Functions.ExecuteSql(true, "DELETE FROM `permissions_dev` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		else
			BJCore.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		end
		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('BJCore:Client:OnPermissionUpdate', source, "user")
	end
end

BJCore.Functions.HasPermission = function(source, permission)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if BJCore.Config.Server.PermissionList[steamid] ~= nil then 
			if BJCore.Config.Server.PermissionList[steamid].steam == steamid and BJCore.Config.Server.PermissionList[steamid].license == licenseid then
				if permission == "helper" then
					if BJCore.Config.Server.PermissionList[steamid].permission == permission or BJCore.Config.Server.PermissionList[steamid].permission == "mod" or BJCore.Config.Server.PermissionList[steamid].permission == "admin" or BJCore.Config.Server.PermissionList[steamid].permission == "senioradmin" or BJCore.Config.Server.PermissionList[steamid].permission == "god" then
						retval = true
					end
				elseif permission == "mod" then
					if BJCore.Config.Server.PermissionList[steamid].permission == permission or BJCore.Config.Server.PermissionList[steamid].permission == "admin" or BJCore.Config.Server.PermissionList[steamid].permission == "senioradmin" or BJCore.Config.Server.PermissionList[steamid].permission == "god" then
						retval = true
					end
				elseif permission == "admin" then
					if BJCore.Config.Server.PermissionList[steamid].permission == permission or BJCore.Config.Server.PermissionList[steamid].permission == "senioradmin" or BJCore.Config.Server.PermissionList[steamid].permission == "god" then
						retval = true
					end
				elseif permission == "senioradmin" then
					if BJCore.Config.Server.PermissionList[steamid].permission == permission or BJCore.Config.Server.PermissionList[steamid].permission == "god" then
						retval = true
					end
				else
					if BJCore.Config.Server.PermissionList[steamid].permission == permission then
						retval = true
					end
				end
			end
		end
	end
	return retval
end

BJCore.Functions.GetPermission = function(source)
	local retval = "user"
	local Player = BJCore.Functions.GetPlayer(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	if Player ~= nil then
		if BJCore.Config.Server.PermissionList[Player.PlayerData.steam] ~= nil then 
			if BJCore.Config.Server.PermissionList[Player.PlayerData.steam].steam == steamid and BJCore.Config.Server.PermissionList[Player.PlayerData.steam].license == licenseid then
				retval = BJCore.Config.Server.PermissionList[Player.PlayerData.steam].permission
			end
		end
	end
	return retval
end

BJCore.Functions.IsOptin = function(source)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	if BJCore.Functions.HasPermission(source, "admin") or BJCore.Functions.HasPermission(source, "helper") then
		retval = BJCore.Config.Server.PermissionList[steamid].optin
	end
	return retval
end

BJCore.Functions.ToggleOptin = function(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	if BJCore.Functions.HasPermission(source, "admin") or BJCore.Functions.HasPermission(source, "helper") then
		BJCore.Config.Server.PermissionList[steamid].optin = not BJCore.Config.Server.PermissionList[steamid].optin
	end
end

BJCore.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
	local identifiers = BJCore.Functions.ExtractIdentifiers(source)
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `bans` WHERE `steam` = @steam OR `license` = @license OR `ip` = @ip", function(result)
		if result[1] ~= nil then 
			if os.time() < result[1].expire then
				retval = true
				local timeTable = os.date("*t", tonumber(result[1].expire))
				message = "You have been banned from the server\nYour ban expires "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
			else
				BJCore.Functions.ExecuteSql(true, "DELETE FROM `bans` WHERE `id` = "..result[1].id)
			end
		end
	end, {
		["steam"] = identifiers.steam,
		["license"] = identifiers.license,
		["ip"] = identifiers.ip,
	})
	return retval, message
end

BJCore.Functions.ExtractIdentifiers = function(source)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

-- Player joined
RegisterServerEvent("BJCore:PlayerJoined")
AddEventHandler('BJCore:PlayerJoined', function()
	local src = source
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	TriggerEvent("bj-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..GetPlayerIdentifiers(src)[1]..") left..")
	TriggerEvent("bj-log:server:sendLog", GetPlayerIdentifiers(src)[1], "joined", {})
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (BJCore.Players[src] == nil)) then return false end
    TriggerEvent("bj-log:server:CreateLog", BJCore.Players[src].PlayerData.job.name.."_duty", "Duty Alert", "green", "**"..BJCore.Players[src].PlayerData.charinfo.firstname.." "..BJCore.Players[src].PlayerData.charinfo.lastname.."** ("..BJCore.Players[src].PlayerData.citizenid..") has gone **Off Duty** (Disconnected)")
	BJCore.Players[src].Functions.SetMetaData("lastlogout", os.time())
	BJCore.Players[src].Functions.Save()
	BJCore.Players[src] = nil
end)

-- Checking everything before joining
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
	deferrals.defer()
	local src = source
	deferrals.update("\nChecking name...")
	local name = GetPlayerName(src)
	if name == nil then 
		BJCore.Functions.Kick(src, 'Please don\'t use a blank Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if(string.match(name, "[*%%'=`\"]")) then
        BJCore.Functions.Kick(src, 'You have a character in your username ('..string.match(name, "[*%%'=`\"]")..') that is not allowed.\nPlease remove this out of your Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if (string.match(name, "drop") or string.match(name, "table") or string.match(name, "database")) then
        BJCore.Functions.Kick(src, 'Your username contains a word (drop/table/database) that is not allowed.\nPlease change your Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	deferrals.update("\nChecking identifiers...")
    local identifiers = GetPlayerIdentifiers(src)
	local steamid = identifiers[1]
	local license = identifiers[2]
    if (BJConfig.IdentifierType == "steam" and (steamid:sub(1,6) == "steam:") == false) then
        BJCore.Functions.Kick(src, 'You need to open Steam to play.', setKickReason, deferrals)
        CancelEvent()
		return false
	elseif (BJConfig.IdentifierType == "license" and (steamid:sub(1,6) == "license:") == false) then
		BJCore.Functions.Kick(src, 'No Social Club license found.', setKickReason, deferrals)
        CancelEvent()
		return false
    end
    if BJConfig.Server.DiscordWhitelistedRole then
	    local hasDiscord = false
	    for k,v in pairs(identifiers) do
	    	if string.find(v, "discord") then
	    		hasDiscord = true
	    		break
	    	end
	    end
	    if not hasDiscord then
			BJCore.Functions.Kick(src, 'Discord was not found. Please make sure Discord is running before launching FiveM.', setKickReason, deferrals)
	        CancelEvent()
	        return false
	    end
	end
	deferrals.update("\nChecking ban status...")
    local isBanned, Reason = BJCore.Functions.IsPlayerBanned(src)
    if(isBanned) then
        BJCore.Functions.Kick(src, Reason, setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking whitelist status...")
    if(not BJCore.Functions.IsWhitelisted(src)) then
        BJCore.Functions.Kick(src, 'You aren\'t whitelisted.', setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking server status...")
    if(BJCore.Config.Server.closed and not IsPlayerAceAllowed(src, "bjadmin.join")) then
		BJCore.Functions.Kick(src, 'the server is closed:\n'..BJCore.Config.Server.closedReason, setKickReason, deferrals)
        CancelEvent()
        return false
	end
	TriggerEvent("bj-log:server:CreateLog", "joinleave", "Queue", "orange", "**"..name .. "** ("..json.encode(GetPlayerIdentifiers(src))..") in queue..")
	TriggerEvent("bj-log:server:sendLog", GetPlayerIdentifiers(src)[1], "left", {})
	TriggerEvent("connectqueue:playerConnect", src, setKickReason, deferrals)
end)

RegisterServerEvent("BJCore:server:CloseServer")
AddEventHandler('BJCore:server:CloseServer', function(reason)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    if BJCore.Functions.HasPermission(source, "admin") or BJCore.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason specified"
        BJCore.Config.Server.closed = true
        BJCore.Config.Server.closedReason = reason
        TriggerClientEvent("bjadmin:client:SetServerStatus", -1, true)
	else
		BJCore.Functions.Kick(src, "You don't have permissions for this", nil, nil)
    end
end)

RegisterServerEvent("BJCore:server:OpenServer")
AddEventHandler('BJCore:server:OpenServer', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if BJCore.Functions.HasPermission(source, "admin") or BJCore.Functions.HasPermission(source, "god") then
        BJCore.Config.Server.closed = false
        TriggerClientEvent("bjadmin:client:SetServerStatus", -1, false)
    else
        BJCore.Functions.Kick(src, "You don't have permissions for this", nil, nil)
    end
end)

RegisterServerEvent("BJCore:UpdatePlayer")
AddEventHandler('BJCore:UpdatePlayer', function(data, isLogout)
	if isLogout == nil then isLogout = false; end
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	
	if Player ~= nil then
		Player.PlayerData.position = data.position

		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)
		
		if not isLogout then
			Player.Functions.AddMoney("bank", Player.PlayerData.job.payment)
			TriggerClientEvent('BJCore:Notify', src, "You received your paycheck of "..BJCore.Config.Currency.Symbol..Player.PlayerData.job.payment)
		end
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)
		TriggerClientEvent('mooseUI:client:UpdateStatus',src, {hunger=newHunger, thirst=newThirst})
		Player.Functions.Save()
	end
end)

RegisterServerEvent("BJCore:UpdatePlayerPosition")
AddEventHandler("BJCore:UpdatePlayerPosition", function(position)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = position
	end
end)

RegisterServerEvent("BJCore:Server:TriggerServerCallback")
AddEventHandler('BJCore:Server:TriggerServerCallback', function(name, ...)
	local src = source
	BJCore.Functions.TriggerServerCallback(name, src, function(...)
		TriggerClientEvent("BJCore:Client:TriggerServerCallback", src, name, ...)
	end, ...)
end)

RegisterServerEvent("BJCore:Server:UseItem")
AddEventHandler('BJCore:Server:UseItem', function(item)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if BJCore.Functions.CanUseItem(item.name) then
			BJCore.Functions.UseItem(src, item)
		end
	end
end)

RegisterServerEvent("BJCore:Server:RemoveItem")
AddEventHandler('BJCore:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player.Functions.RemoveItem(itemName, amount, slot) then
		TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[itemName], "remove")
	end
end)

RegisterServerEvent("BJCore:Server:AddItem")
AddEventHandler('BJCore:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player.Functions.AddItem(itemName, amount, slot, info) then
		TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[itemName], "add")
	end
end)

RegisterServerEvent('BJCore:Server:SetMetaData')
AddEventHandler('BJCore:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player ~= nil then 
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = BJCore.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if BJCore.Commands.List[command] ~= nil then
			local Player = BJCore.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (BJCore.Functions.HasPermission(source, "god") or BJCore.Functions.HasPermission(source, BJCore.Commands.List[command].permission)) then
					if (BJCore.Commands.List[command].argsrequired and #BJCore.Commands.List[command].arguments ~= 0 and args[#BJCore.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out")
					    local agus = ""
					    for name, help in pairs(BJCore.Commands.List[command].arguments) do
							if help then
								if help.name then
					    			agus = agus .. " ["..help.name.."]"
								else
									agus = agus .. " ["..name.."]"
								end
							end
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						BJCore.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command")
				end
			end
		end
	end
end)

RegisterServerEvent('BJCore:CallCommand')
AddEventHandler('BJCore:CallCommand', function(command, args)
	if BJCore.Commands.List[command] ~= nil then
		local Player = BJCore.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (BJCore.Functions.HasPermission(source, "god")) or (BJCore.Functions.HasPermission(source, BJCore.Commands.List[command].permission)) or (BJCore.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (BJCore.Commands.List[command].argsrequired and #BJCore.Commands.List[command].arguments ~= 0 and args[#BJCore.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out")
					local agus = ""
					for name, help in pairs(BJCore.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					BJCore.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command")
			end
		end
	end
end)

RegisterServerEvent("BJCore:AddCommand")
AddEventHandler('BJCore:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	BJCore.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("BJCore:ToggleDuty")
AddEventHandler('BJCore:ToggleDuty', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('BJCore:Notify', src, "You are now off duty")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('BJCore:Notify', src, "You are now on duty")
	end
	TriggerClientEvent("BJCore:Client:SetDuty", src, Player.PlayerData.job.onduty)
end)

Citizen.CreateThread(function()
	if GetConvar("server_type", "DEV") == "LIVE" then
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM `permissions`", function(result)
			if result[1] ~= nil then
				for k, v in pairs(result) do
					BJCore.Config.Server.PermissionList[v.steam] = {
						steam = v.steam,
						license = v.license,
						permission = v.permission,
						optin = true,
					}
				end
			end
		end)
	else
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM `permissions_dev`", function(result)
			if result[1] ~= nil then
				for k, v in pairs(result) do
					BJCore.Config.Server.PermissionList[v.steam] = {
						steam = v.steam,
						license = v.license,
						permission = v.permission,
						optin = true,
					}
				end
			end
		end)		
	end
end)

BJCore.Functions.RegisterServerCallback('BJCore:HasItem', function(source, cb, itemName)
	local retval = false
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		if Player.Functions.GetItemByName(itemName) ~= nil then
			retval = true
		end
	end
	cb(retval)
end)	

RegisterServerEvent('BJCore:Command:CheckOwnedVehicle')
AddEventHandler('BJCore:Command:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..VehiclePlate.."'", function(result)
			if result[1] ~= nil then
				BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '1' WHERE `citizenid` = '"..result[1].citizenid.."'")
				TriggerEvent('bj-garages:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
			end
		end)
	end
end)

RegisterServerEvent('BJCore:TeleportToPlayer')
AddEventHandler('BJCore:TeleportToPlayer', function(target)
	local src = source
	TriggerClientEvent('BJCore:Command:TeleportToPlayer', src, GetEntityCoords(GetPlayerPed(target)))
end)

RegisterServerEvent('BJCore:RequestVehicleDelete')
AddEventHandler('BJCore:RequestVehicleDelete', function(veh)
	local src = source
	local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
	TriggerClientEvent("bj-core:client:DeleteVehicleReceived", owner, veh)
end)

RegisterServerEvent('BJCore:RequestEntityDelete')
AddEventHandler('BJCore:RequestEntityDelete', function(id)
    local src = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(id))
    if owner == 0 then owner = -1; end
    DeleteEntity(NetworkGetEntityFromNetworkId(id))
    if DoesEntityExist(NetworkGetEntityFromNetworkId(id)) then
	    TriggerClientEvent("bj-core:client:DeleteEntityReceived", owner, id)
	end
end)

--AddEventHandler('onResourceStop', function(resourceName)
--	if (GetCurrentResourceName() ~= resourceName) then
--	  return
--	end
--	print('[Core] Resource stopping. Saving data.')
--	for k,v in pairs(BJCore.Players) do
--		v.Functions.Save()
--	end
--end)

RegisterNetEvent("BJCore:SetEntityStateBag", function(entNetId, keyName, data)
	Entity(NetworkGetEntityFromNetworkId(entNetId)).state:set(keyName, data, true)
end)

RegisterNetEvent("BJCore:SetPlayerStateBag", function(target, keyName, data)
    Player(target).state:set(keyName, data, true)
end)

tracked = {}
RegisterNetEvent('DiscordAPI:PlayerLoaded')
AddEventHandler('DiscordAPI:PlayerLoaded', function()
	local license = BJCore.Functions.ExtractIdentifiers(source).license
	if tracked[license] == nil then 
		tracked[license] = true
	end
end)
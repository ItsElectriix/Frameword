BJCore.Commands = {}
BJCore.Commands.List = {}

BJCore.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	BJCore.Commands.List[name:lower()] = {
		name = name:lower(),
		permission = permission ~= nil and permission:lower() or "user",
		help = help,
		arguments = arguments,
		argsrequired = argsrequired,
		callback = callback,
	}
end

BJCore.Commands.Refresh = function(source)
	local Player = BJCore.Functions.GetPlayer(tonumber(source))
	if Player ~= nil then
		for command, info in pairs(BJCore.Commands.List) do
			if BJCore.Functions.HasPermission(source, "god") or BJCore.Functions.HasPermission(source, BJCore.Commands.List[command].permission) then
				TriggerClientEvent('chat:addSuggestion', source, "/"..command, info.help, info.arguments)
			end
		end
	end
end

BJCore.Commands.Add("tp", "Teleport to a player or location", {{name="id/x", help="ID of player or X position"}, {name="y", help="Y position"}, {name="z", help="Z position"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if (args[1] ~= nil and (args[2] == nil and args[3] == nil)) then
        -- tp to player
        local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
        if Target ~= nil then
            TriggerClientEvent('bj-admin:setLastPos', Player.PlayerData.source, GetEntityCoords(GetPlayerPed(source)), false)
            Wait(10)
            TriggerClientEvent('BJCore:Command:TeleportToPlayer', source, GetEntityCoords(GetPlayerPed(Target.PlayerData.source)))
            TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported to **"..Target.PlayerData.name.."** using the /tp command.")
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
        end
    else
        -- tp to location
        if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
            for k,v in pairs(args) do
                args[k] = args[k]:gsub('%,', '')
            end
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            TriggerClientEvent('bj-admin:setLastPos', Player.PlayerData.source, GetEntityCoords(GetPlayerPed(source)), false)
            Wait(10)
            TriggerClientEvent('BJCore:Command:TeleportToCoords', source, x, y, z)
            TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported to coords: x:"..x.." y:"..y.." z:"..z.." using the /tp command.")
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Not every argument has been entered (x, y, z)")
        end
    end
end, "helper")

BJCore.Commands.Add("addpermission", "Grant permissions to someone (god/senioradmin/admin/mod)", {{name="id", help="ID of player"}, {name="permission", help="Permission level"}, {name="server", help="live/dev"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if args[3] == 'live' or args[3] == 'dev' then
		if Target ~= nil then
			BJCore.Functions.AddPermission(Target.PlayerData.source, permission, args[3])
			TriggerEvent("bj-log:server:CreateLog", "bans", "Added Perms", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has given **"..permission.."** perms to **"..Target.PlayerData.name.."** on "..args[3].." using the /addpermission command.")
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")	
		end
	else
		TriggerClientEvent('BJCore:Notify', source, "Server not correctly specified", "error")
	end
end, "god")

BJCore.Commands.Add("removepermission", "Remove permissions from player", {{name="id", help="ID of player"}, {name="server", help="live/dev"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if args[2] == 'live' or args[2] == 'dev' then
		if Target ~= nil then
			BJCore.Functions.RemovePermission(Target.PlayerData.source, args[2])
			TriggerEvent("bj-log:server:CreateLog", "bans", "Removed Perms", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has removed all perms from **"..Target.PlayerData.name.."** on "..args[2].." using the /removepermission command")
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Permissions removed")
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")	
		end
	else
		TriggerClientEvent('BJCore:Notify', source, "Server not correctly specified", "error")
	end
end, "god")

BJCore.Commands.Add("car", "Spawn a vehicle", {{name="model", help="Model name of the vehicle"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	TriggerClientEvent('BJCore:Command:SpawnVehicle', source, args[1])
	TriggerEvent("bj-log:server:CreateLog", "bans", "Spawn Vehicle", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has spawned or attempted to spawn vehicle model **"..args[1].."** using the /car command.")
end, "admin")

BJCore.Commands.Add("debug", "Turn debug mode on / off", {}, false, function(source, args)
	TriggerClientEvent('debug:toggle', source)
end, "god")

BJCore.Commands.Add("dv", "Despawn a vehicle", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	TriggerClientEvent('BJCore:Command:DeleteVehicle', source)
	TriggerEvent("bj-log:server:CreateLog", "bans", "Delete Vehicle", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used delete vehicle function using the /dv command")
end, "helper")

BJCore.Commands.Add("tpm", "Teleport to your waypoint", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	TriggerClientEvent('bj-admin:setLastPos', Player.PlayerData.source, GetEntityCoords(GetPlayerPed(source)), false)
	Wait(10)
	TriggerClientEvent('BJCore:Command:GoToMarker', source)
	TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used teleport to waypoint function using the /tpm command")
end, "helper")

BJCore.Commands.Add("givemoney", "Give money to a player", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Target ~= nil then
		Target.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
		TriggerEvent("bj-log:server:CreateLog", "bans", "Give Money", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has given **"..Target.PlayerData.name.."** "..BJCore.Config.Currency.Symbol..args[3].." in (type) "..args[2].." using the /givemoney command.")
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "admin")

BJCore.Commands.Add("setmoney", "set a players money amount", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Target ~= nil then
		Target.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
		TriggerEvent("bj-log:server:CreateLog", "bans", "Give Money", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set **"..Target.PlayerData.name.."**'s (type) "..args[2].." to "..BJCore.Config.Currency.Symbol..args[3].." using the /setmoney command.")
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "admin")

BJCore.Commands.Add("setjob", "Assign a job to a player", {{name="id", help="Player ID"}, {name="job", help="Job name"}, {name="grade", help="Job grade number"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Target ~= nil then
		if Target.Functions.SetJob(tostring(args[2]), tonumber(args[3])) then
			Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
			TriggerClientEvent('BJCore:Notify', tonumber(args[1]), "Set Job: "..Target.PlayerData.job.label.." | Grade: "..Target.PlayerData.job.grade.name, "primary")
			TriggerEvent("bj-log:server:CreateLog", "bans", "Set Job", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set **"..Target.PlayerData.name.."**'s job to "..args[2].." using the /setjob command.")
		else
			if BJCore.Shared.Jobs[tostring(args[2])] == nil then
                TriggerClientEvent('BJCore:Notify', source, "Job: "..args[2].." does not exists", "error")
			else
                TriggerClientEvent('BJCore:Notify', source, "Job Grade: "..args[3].." does not exists", "error")
			end
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "helpers")

BJCore.Commands.Add("job", "Check your current job", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Job: "..Player.PlayerData.job.label.." | Grade: "..Player.PlayerData.job.grade.name)
end)

BJCore.Commands.Add("setgang", "Assign a player to a gang", {{name="id", help="Player ID"}, {name="gang", help="Name of a gang"}, {name="grade", help="Gang grade number"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Target ~= nil then
		if Target.Functions.SetGang(tostring(args[2]), tonumber(args[3])) then
			Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
			TriggerClientEvent('BJCore:Notify', tonumber(args[1]), "Set Gang: "..Target.PlayerData.job.label.." | Grade: "..Target.PlayerData.gang.grade.name, "primary")
			TriggerEvent("bj-log:server:CreateLog", "bans", "Set Gang", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set **"..Target.PlayerData.name.."**'s gang to "..args[2].." using the /setgang command.")
		else
			if BJCore.Shared.Gangs[tostring(args[2])] == nil then
                TriggerClientEvent('BJCore:Notify', source, "Gang: "..args[2].." does not exists", "error")
			else
                TriggerClientEvent('BJCore:Notify', source, "Gang Grade: "..args[3].." does not exists", "error")
			end
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "admin")

BJCore.Commands.Add("gang", "See what gang you're in", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.PlayerData.gang.name ~= "none" then
		TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Gang: "..Player.PlayerData.gang.label.." | Grade: "..Player.PlayerData.gang.grade.name)
	else
		TriggerClientEvent('BJCore:Notify', source, "You're not in a gang", "error")
	end
end)

BJCore.Commands.Add("testnotify", "test notify", {{name="text", help="Test notification"}}, true, function(source, args)
	TriggerClientEvent('BJCore:Notify', source, table.concat(args, " "), "success")
end, "god")

BJCore.Commands.Add("clearinv", "Clear the inventory of a player", {{name="id", help="Player ID"}}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local playerId = args[1] ~= nil and args[1] or source 
	local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
	if Target ~= nil then
		Target.Functions.ClearInventory()
		TriggerEvent("bj-log:server:CreateLog", "bans", "Clear Inv", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has cleared **"..Target.PlayerData.name.."**'s inventory using the /clearinv command.")
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "admin")

BJCore.Commands.Add("ooc", "Out of Character message", {}, false, function(source, args)
	local message = table.concat(args, " ")
	local playerCoords = GetEntityCoords(GetPlayerPed(source))
	local Players = BJCore.Functions.GetPlayers()
	local Player = BJCore.Functions.GetPlayer(source)

	if BJCore.Config.UseGlobalOoc then
		TriggerClientEvent('chatMessage', -1, "Global | OOC " .. GetPlayerName(source), "normal", message)
	else
		for k, v in pairs(BJCore.Functions.GetPlayers()) do
			local pos = GetEntityCoords(GetPlayerPed(v))
			local dist = #(pos - playerCoords)
			if dist < 20.0 then
				TriggerClientEvent("chatMessage", v, "OOC " .. GetPlayerName(source), "normal", message)
			else
				if BJCore.Functions.HasPermission(v, "mod") and BJCore.Functions.IsOptin(v) then
					TriggerClientEvent('chatMessage', v, "Global | OOC " .. GetPlayerName(source), "normal", message)
				end
			end
		end
	end
	TriggerEvent("bj-log:server:CreateLog", "ooc", "OOC", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
end)

BJCore.Commands.Add("resetui", "Reset UI's", {}, false, function(source, args)
	TriggerClientEvent('core:resetUi', tonumber(source))
end)

-- BJCore.Commands.Add("clearinv", "Clear the inventory of a player", {{name="id", help="Player ID"}}, false, function(source, args)
-- 	local playerId = args[1] ~= nil and args[1] or source 
-- 	local Player = BJCore.Functions.GetPlayer(tonumber(playerId))
-- 	if Player ~= nil then
-- 		Player.Functions.ClearInventory()
-- 	else
-- 		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
-- 	end
-- end, "admin")

BJCore.Commands.Add("addwhitelist", "Add player to whitelist", {{name="steamhex", help="Steam Hex ID e.g 'steam:123abc456'"}, {name="name", help="Player name"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if args[1] ~= nil and args[2] ~= nil then
		BJCore.Functions.ExecuteSql(false, "INSERT INTO `whitelist` (`steam`, `name`, `admin`) VALUES ('"..args[1].."', '"..args[2].."', '"..GetPlayerName(source).."')")
		TriggerClientEvent('BJCore:Notify', source, args[2].." | "..args[1].." has been added to whitelist")
		TriggerEvent("bj-log:server:CreateLog", "bans", "Add Whitelist", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has added "..args[2].." | "..args[1].." to whitelist using the /addwhitelist command.")
	else
		TriggerClientEvent('BJCore:Notify', source, "Missing parameters. Try again noob")
	end
end, "helper")

BJCore.Commands.Add("go", "Teleport/Goto target player", {{name="id", help="ID of target player"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
    local oPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if not oPlayer and oPlayer == nil then TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "Player doesn't exist", length = 2500 }); return end
    local otherPlayer = oPlayer.PlayerData.source
    local otherPed = GetPlayerPed(otherPlayer)
    local otherCoords = GetEntityCoords(otherPed)
    local vehicle = GetVehiclePedIsIn(otherPed, false)
    TriggerClientEvent('bj-admin:setLastPos', Player.PlayerData.source, GetEntityCoords(GetPlayerPed(source)), false)
    Wait(10)
    TriggerClientEvent("utils:goCommand", source, otherCoords, GetPlayerName(otherPlayer), vehicle)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported to **"..oPlayer.PlayerData.name.."** using the /go command.")
end, "helper")

BJCore.Commands.Add("maxammo", "Set max ammo on current weapon", {}, false, function(source, args)
    TriggerClientEvent("utils:maxammo", source)
end, "god")

BJCore.Commands.Add("invis", "Toggle invis", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("bj-admin:toggleInvis", source)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Invisible", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used /invis command.")
end, "helper")

BJCore.Commands.Add("clean", "Clean current vehicle", {}, false, function(source, args)
    TriggerClientEvent("utils:clean", source)
end, "god")

BJCore.Commands.Add("fix", "Fix current vehicle", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("utils:fix", source)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Fix Vehicle", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used the fixed vehicle function using the /fix command.")
end, "admin")

BJCore.Commands.Add("armour", "Set meax armour", {}, false, function(source, args)
    TriggerClientEvent("utils:armour", source)
end, "god")

BJCore.Commands.Add("togglefob", "Toggle fob", {}, false, function(source, args)
    TriggerClientEvent("utils:togglefob", source)
end, "god")

BJCore.Commands.Add("aidrive", "AI Drive", {}, false, function(source, args)
    TriggerClientEvent("utils:aidrive", source)
end, "god")

BJCore.Commands.Add("setped", "Set ped model", {}, false, function(source, args)
    TriggerClientEvent("utils:setped", source)
end, "senioradmin")

BJCore.Commands.Add("delgun", "Delete gun", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("utils:delgun", source)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Del Gun", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used the del gun function using the /delgun command.")
end, "mod")

BJCore.Commands.Add("posgun", "Position info gun", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("utils:posgun", source)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Pos Gun", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used the pos gun function using the /posgun command.")
end, "senioradmin")

BJCore.Commands.Add("btf", "BTF", {}, false, function(source, args)
    TriggerClientEvent("utils:btf", source)
end, "god")

BJCore.Commands.Add("plate", "Change plate on current vehicle (not persistent)", {}, true, function(source, args)
    TriggerClientEvent("utils:plate", source, args)
end, "admin")

BJCore.Commands.Add("changeplate", "Change and save plate on current vehicle if owned", {}, true, function(source, args)
    TriggerClientEvent("utils:plateSave", source, args)
end, "admin")

BJCore.Commands.Add("toggleduty", "Toggle duty", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetJobDuty(not Player.PlayerData.job.onduty)
		Wait(50)
		local duty = 'On'
		if not Player.PlayerData.job.onduty then duty = 'Off'; end
		TriggerClientEvent('BJCore:Notify', source, duty.." Duty", "success")
	end
end, "god")

RegisterCommand('_t_item', function(source, args, raw)
	if source == nil or tonumber(source) ~= 0 then
		print('This is a server command only.')
		return
	end
	if #args < 3 then
		-- Not enough args
		print('Not enough args')
		return
	end

	local citizenid, item, amount = args[1], args[2], tonumber(args[3])

	if not BJCore.Shared.Items[item] then
		print('Couldn\'t find item for command: '..raw)
		return
	end

	local Player = BJCore.Functions.GetPlayerByCitizenId(citizenid)

	if Player == nil then
		local itemInfo = BJCore.Shared.Items[item]
		exports['ghmattimysql']:execute("UPDATE `players` SET inventory = JSON_ARRAY_APPEND(inventory, '$', CAST(@item AS JSON)) WHERE citizenid = @citizenid", {
			['@citizenid'] = citizenid,
			['@item'] = json.encode({
				name = itemInfo["name"], 
				amount = tonumber(amount),
				info = "", 
				label = itemInfo["label"], 
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "", 
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				image = itemInfo["image"], 
				shouldClose = itemInfo["shouldClose"],
				combinable = itemInfo["combinable"]
			})
		}, function(result) end)
	else
		Player.Functions.AddItem(item, amount)
		TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, BJCore.Shared.Items[item], "add")
		TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, 'You received '..tostring(amount)..'x '..BJCore.Shared.Items[item]['label']..' as donation rewards')
	end
end, true)

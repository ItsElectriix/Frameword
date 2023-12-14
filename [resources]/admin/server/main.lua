BJCore = nil

TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

local permissions = {
    ["kick"] = "helper",
    ["ban"] = "mod",
    ["noclip"] = "helper",
    ["kickall"] = "admin",
}

AddEventHandler('explosionEvent', function(sender, ev)
    print("explosionEvent: "..GetPlayerName(sender).." | ID: "..tostring(sender))
end)

RegisterServerEvent('bj-admin:server:togglePlayerNoclip')
AddEventHandler('bj-admin:server:togglePlayerNoclip', function(playerId, reason)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
    if BJCore.Functions.HasPermission(src, permissions["noclip"]) then
        TriggerClientEvent("bj-admin:client:toggleNoclip", playerId)
        TriggerEvent("bj-log:server:CreateLog", "bans", "No Clip Target", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has toggled No Clip for **"..Target.PlayerData.name.."** using admin/staff menu")
    end
end)

RegisterServerEvent('bj-admin:server:killPlayer')
AddEventHandler('bj-admin:server:killPlayer', function(playerId)
    local src = source
    if not BJCore.Functions.HasPermission(src, "helper") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:server:killPlayer", src) return; end
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
    TriggerClientEvent('hospital:client:KillPlayer', playerId)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Kill Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has killed **"..Target.PlayerData.name.."** using admin/staff menu")
end)

RegisterServerEvent('bj-admin:server:kickPlayer')
AddEventHandler('bj-admin:server:kickPlayer', function(playerId, reason)
    local src = source
    if not BJCore.Functions.HasPermission(src, "helper") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:server:kickPlayer", src) return; end
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
    if BJCore.Functions.HasPermission(src, permissions["kick"]) then
        TriggerEvent("bj-log:server:CreateLog", "bans", "Kick Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has kicked **"..Target.PlayerData.name.."** from the server with reason: "..BJCore.Common.Dump(reason))
        DropPlayer(playerId, "You have been kicked from the server:\n"..reason.."\n\n🔸 Join our Discord for further information: "..BJCore.Config.Server.discord)
    end
end)

RegisterServerEvent('bj-admin:server:Freeze')
AddEventHandler('bj-admin:server:Freeze', function(playerId, toggle)
    local src = source
    if not BJCore.Functions.HasPermission(src, "helper") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:server:Freeze", src) return; end
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
    TriggerClientEvent('bj-admin:client:Freeze', playerId, toggle)
    if toggle then
        TriggerEvent("bj-log:server:CreateLog", "bans", "Freeze Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has frozen **"..Target.PlayerData.name.."** using admin/staff menu.")
    else
        TriggerEvent("bj-log:server:CreateLog", "bans", "Freeze Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has unfrozen **"..Target.PlayerData.name.."** using admin/staff menu.")
    end
end)

RegisterServerEvent('bj-admin:server:serverKick')
AddEventHandler('bj-admin:server:serverKick', function(reason)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if BJCore.Functions.HasPermission(src, permissions["kickall"]) then
        TriggerEvent("bj-log:server:CreateLog", "bans", "Kick all", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used kill all function using admin/staff menu.")
        for k, v in pairs(BJCore.Functions.GetPlayers()) do
            if v ~= src then 
                DropPlayer(v, "You have been kicked from the server:\n"..reason.."\n\n🔸 Join our Discord for further information: "..BJCore.Config.Server.discord)
            end
        end
    end
end)

BJCore.Commands.Add("kick", "Kick target ID from server", {{name="ID", help="Player"}, {name="Reason", help="Mention a reason"}}, true, function(source, args)
    local src = source
    TriggerEvent("bj-admin:server:kickPlayer", tonumber(args[1]), args[2])
end, "helper")

RegisterServerEvent('bj-admin:server:banPlayer')
AddEventHandler('bj-admin:server:banPlayer', function(playerId, time, reason)
    local src = source
    if not BJCore.Functions.HasPermission(src, "helper") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:server:banPlayer", src) return; end
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(playerId))
    if BJCore.Functions.HasPermission(src, permissions["ban"]) then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date("*t", banTime)
        --TriggerClientEvent('chatMessage', -1, "BANHAMMER", "error", GetPlayerName(playerId).." has been banned for: "..reason.." "..suffix[math.random(1, #suffix)])
        local identifiers = BJCore.Functions.ExtractIdentifiers(tonumber(playerId))  
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `bans` (`name`, `steam`, `license`, `discord`,`ip`, `reason`, `expire`, `bannedby`) VALUES (@name, @steam, @license, @discord, @ip, @reason, @expire, @bannedby)", nil, {
            ["name"] = GetPlayerName(tonumber(playerId)),
            ["steam"] = identifiers.steam,
            ["license"] = identifiers.license,
            ["discord"] = identifiers.discord,
            ["ip"] = identifiers.ip,
            ["reason"] = reason,
            ["expire"] = banTime,
            ["bannedby"] = GetPlayerName(src),
        })
        TriggerEvent("bj-log:server:CreateLog", "bans", "Banned Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has kicked **"..Target.PlayerData.name.."** from the server with reason: "..BJCore.Common.Dump(reason))
        DropPlayer(playerId, "You have been banned from the server:\n"..reason.."\n\nBan expires: "..timeTable["day"].. "/" .. timeTable["month"] .. "/" .. timeTable["year"] .. " " .. timeTable["hour"].. ":" .. timeTable["min"] .. "\n🔸 Join our Discord for further information: "..BJCore.Config.Server.discord)
    end
end)

RegisterServerEvent('bj-admin:server:revivePlayer')
AddEventHandler('bj-admin:server:revivePlayer', function(target)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(target)) 
    TriggerClientEvent('hospital:client:Revive', target)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Revive Player", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has revived **"..Target.PlayerData.name.."** using the admin/staff menu.")
end)

BJCore.Commands.Add("announce", "Announce a message to everyone", {}, false, function(source, args)
    local msg = table.concat(args, " ")
    TriggerClientEvent('chatMessage', -1, "SYSTEM", "error", msg)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Announement", "orange", "**"..GetPlayerName(source) .. "** has announced: "..msg)
end, "mod")

BJCore.Commands.Add("admin", "Open admin menu", {}, false, function(source, args)
    local group = BJCore.Functions.GetPermission(source)
    local dealers = nil
    TriggerClientEvent('bj-admin:client:openMenu', source, group, dealers)
end, "helper")

BJCore.Commands.Add("report", "Send a report to admins (only when necessary)", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('bj-admin:client:SendReport', -1, GetPlayerName(source), source, msg)
    TriggerClientEvent('chatMessage', source, "REPORT Send", "normal", msg)
    TriggerEvent("bj-log:server:CreateLog", "report", "Report", "green", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Report:** " ..msg, false)
    TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "reportreply", {message=msg})
end)

BJCore.Commands.Add("staffchat", "Send a message to all staff members", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")

    TriggerClientEvent('bj-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "helper")

BJCore.Commands.Add("givenuifocus", "Give nui focus", {{name="id", help="Player id"}, {name="focus", help="Set focus on/off"}, {name="mouse", help="Set mouse on/off"}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]

    TriggerClientEvent('bj-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, "mod")

BJCore.Commands.Add("s", "Send a message to all staff members", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")

    TriggerClientEvent('bj-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "helper")

BJCore.Commands.Add("warn", "Warn a player", {{name="ID", help="Player"}, {name="Reason", help="Mention a reason"}}, true, function(source, args)
    local targetPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = BJCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, " ")

    local myName = senderPlayer.PlayerData.name

    local warnId = "WARN-"..math.random(1111, 9999)

    if targetPlayer ~= nil then
        TriggerClientEvent('chatMessage', targetPlayer.PlayerData.source, "SYSTEM", "error", "You have been warned by: "..GetPlayerName(source)..", Reason: "..msg)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You have warned "..GetPlayerName(targetPlayer.PlayerData.source).." for: "..msg)
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_warns` (`senderIdentifier`, `targetIdentifier`, `reason`, `warnId`) VALUES ('"..senderPlayer.PlayerData.steam.."', '"..targetPlayer.PlayerData.steam.."', '"..msg.."', '"..warnId.."')")
        TriggerEvent("bj-log:server:CreateLog", "bans", "Warning", "orange", "**"..GetPlayerName(source) .. "** has warned: **"..GetPlayerName(targetPlayer.PlayerData.source).." for/reason: "..msg)
    else
        TriggerClientEvent('BJCore:Notify', source, 'This player is not online', 'error')
    end 
end, "helper")

BJCore.Commands.Add("checkwarns", "Warn a player", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(result)
            print(json.encode(result))
            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has "..tablelength(result).." warnings")
        end)
    else
        local targetPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))

        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(warnings)
            local selectedWarning = tonumber(args[2])

            if warnings[selectedWarning] ~= nil then
                local sender = BJCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)

                TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has been warned by "..sender.PlayerData.name..", Reason: "..warnings[selectedWarning].reason)
            end
        end)
    end
end, "helper")

BJCore.Commands.Add("delwarn", "Delete warnings of a person", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, true, function(source, args)
    local targetPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(warnings)
        local selectedWarning = tonumber(args[2])

        if warnings[selectedWarning] ~= nil then
            local sender = BJCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerEvent("bj-log:server:CreateLog", "bans", "Warning Removed", "orange", "**"..GetPlayerName(source) .. "** has removed ("..selectedWarning..") warning on: **"..GetPlayerName(targetPlayer.PlayerData.source)..", Removed Warning: "..warnings[selectedWarning].reason)
            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "You have deleted warning ("..selectedWarning..") , Reason: "..warnings[selectedWarning].reason)
            BJCore.Functions.ExecuteSql(false, "DELETE FROM `player_warns` WHERE `warnId` = '"..warnings[selectedWarning].warnId.."'")
        end
    end)
end, "admin")

function tablelength(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

BJCore.Commands.Add("reportr", "Reply to a report", {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
    local Player = BJCore.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', playerId, "STAFF - "..GetPlayerName(source), "warning", msg)
        TriggerClientEvent('BJCore:Notify', source, "Sent reply")
        TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "reportreply", {otherCitizenId=OtherPlayer.PlayerData.citizenid, message=msg})
        for k, v in pairs(BJCore.Functions.GetPlayers()) do
            if BJCore.Functions.HasPermission(v, "helper") then
                if BJCore.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "ReportReply("..source..") - "..GetPlayerName(source), "warning", msg)
                end
            end
        end
        TriggerEvent("bj-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)

    else
        TriggerClientEvent('BJCore:Notify', source, "Player is not online", "error")
    end
end, "helper")

BJCore.Commands.Add("setmodel", "Change to a model you like", {{name="model", help="Name of the model"}, {name="id", help="Id of the Player (empty for yourself)"}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])

    if model ~= nil or model ~= "" then
        if target == nil then
            TriggerClientEvent('bj-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = BJCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('bj-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('BJCore:Notify', source, "This person is not online", "error")
            end
        end
    else
        TriggerClientEvent('BJCore:Notify', source, "You did not set a model", "error")
    end
end, "senioradmin")

BJCore.Commands.Add("setspeed", "Change to a speed you like..", {}, false, function(source, args)
    local speed = args[1]

    if speed ~= nil then
        TriggerClientEvent('bj-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('BJCore:Notify', source, "You did not set a speed.. (`fast` for super-run, `normal` for normal)", "error")
    end
end, "god")


BJCore.Commands.Add("admincar", "Save vehicle in your garage", {}, false, function(source, args)
    local ply = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('bj-admin:client:SaveCar', source)
end, "senioradmin")

RegisterServerEvent('bj-admin:server:SaveCar')
AddEventHandler('bj-admin:server:SaveCar', function(mods, vehicle, hash, plate, vType)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] == nil then
            BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `type`, `hash`, `mods`, `plate`, `state`) VALUES ('"..Player.PlayerData.steam.."', '"..Player.PlayerData.citizenid.."', '"..vehicle.model.."', '"..vType.."', '"..vehicle.hash.."', '"..json.encode(mods).."', '"..plate.."', 0)")
            TriggerClientEvent('BJCore:Notify', src, 'The vehicle is now yours', 'success', 5000)
        else
            TriggerClientEvent('BJCore:Notify', src, 'This vehicle is already yours..', 'error', 3000)
        end
    end)
end)

BJCore.Commands.Add("reporttoggle", "Toggle incoming reports", {}, false, function(source, args)
    BJCore.Functions.ToggleOptin(source)
    if BJCore.Functions.IsOptin(source) then
        TriggerClientEvent('BJCore:Notify', source, "You are receiving reports", "success")
    else
        TriggerClientEvent('BJCore:Notify', source, "You are not receiving reports", "error")
    end
end, "helper")

RegisterCommand("kickall", function(source, args, rawCommand)
    local src = source
    
    if src > 0 then
        local reason = table.concat(args, ' ')
        local Player = BJCore.Functions.GetPlayer(src)

        if BJCore.Functions.HasPermission(src, "senioradmin") then
            if args[1] ~= nil then
                TriggerEvent("bj-log:server:CreateLog", "bans", "Kick All", "red", "**"..GetPlayerName(source) .. "** has used Kick All")
                for k, v in pairs(BJCore.Functions.GetPlayers()) do
                    local Player = BJCore.Functions.GetPlayer(v)
                    if Player ~= nil then 
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'Include a reason')
            end
        else
            TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'You can\'t do this. Nice try though')
        end
    else
        for k, v in pairs(BJCore.Functions.GetPlayers()) do
            local Player = BJCore.Functions.GetPlayer(v)
            if Player ~= nil then 
                DropPlayer(Player.PlayerData.source, "Server restart, check our Discord for more information (discord.link.here)")
            end
        end
    end
end, false)

RegisterServerEvent('bj-admin:server:bringTp')
AddEventHandler('bj-admin:server:bringTp', function(targetId, coords)
    local src = source
    if not BJCore.Functions.HasPermission(src, "helper") then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:server:bringTp", src) return; end
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(targetId)     
    TriggerClientEvent('bj-admin:client:bringTp', targetId, coords)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported **"..Target.PlayerData.name.."** to them using the bring option in admin/staff menu.")
end)

BJCore.Functions.RegisterServerCallback('bj-admin:server:hasPermissions', function(source, cb, group)
    local src = source
    local retval = false

    if BJCore.Functions.HasPermission(src, group) then
        retval = true
    end
    cb(retval)
end)

RegisterServerEvent('bj-admin:server:setPermissions')
AddEventHandler('bj-admin:server:setPermissions', function(targetId, group)
    targetId = tonumber(targetId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(targetId)
    local server = "dev"
    if GetConvar("server_type", "DEV") == "LIVE" then server = "live"; end
    BJCore.Functions.AddPermission(targetId, group.rank, server)
    TriggerClientEvent('BJCore:Notify', targetId, 'Your permission levels have been set to '..group.label)
    TriggerClientEvent('BJCore:Notify', src, 'You changed '..GetPlayerName(targetId)..'\'s group to '..group.label)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Set Permission", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set **"..Target.PlayerData.name.."** permission to "..group.rank.." using the admin/staff menu.")
end)

RegisterServerEvent('bj-admin:server:OpenSkinMenu')
AddEventHandler('bj-admin:server:OpenSkinMenu', function(targetId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(targetId)     
    TriggerClientEvent("bj-clothing:client:openMenu", targetId)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Send to Skin", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has sent **"..Target.PlayerData.name.."** to the skin creator menu.")
end)

RegisterServerEvent('bj-admin:server:SendReport')
AddEventHandler('bj-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    local Players = BJCore.Functions.GetPlayers()

    if BJCore.Functions.HasPermission(src, "helper") then
        if BJCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "REPORT - "..name.." ("..targetSrc..")", "report", msg)
        end
    end
end)

RegisterServerEvent('bj-admin:server:StaffChatMessage')
AddEventHandler('bj-admin:server:StaffChatMessage', function(name, msg)
    local src = source
    local Players = BJCore.Functions.GetPlayers()

    if BJCore.Functions.HasPermission(src, "helper") then
        if BJCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
        end
    end
end)

BJCore.Commands.Add("setammo", "Staff: Set manual ammo for a weapon.", {{name="amount", help="Amount of bullets, for example: 20"}, {name="weapon", help="Name of the weapen, for example: WEAPON_VINTAGEPISTOL"}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('bj-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('bj-weapons:client:SetWeaponAmmoManual', src, "current", amount)
    end
end, 'god')

BJCore.Commands.Add("nc", "Toggle noclip", {}, false, function(source, args)
    TriggerClientEvent('bj-admin:client:toggleNoclip', source)
end, 'helper')

BJCore.Commands.Add("bring", "Teleport target player to you", {{name="id", help="ID of target player"}}, true, function(source, args)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target ~= nil then
        TriggerClientEvent('bj-admin:client:bringTp', Target.PlayerData.source, GetEntityCoords(GetPlayerPed(src)))
        TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported **"..Target.PlayerData.name.."** to them using the /bring command.")
    end
end, "helper")

BJCore.Commands.Add("return", "Teleport yourself back to last position before using a teleport", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('bj-admin:client:bringTp', Player.PlayerData.source, 'last')
    TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported back to their last position using the /return command.")
end, "helper")

RegisterNetEvent('bj-admin:server:GetPlayers')
AddEventHandler('bj-admin:server:GetPlayers', function()
    local data = {}
    for k, v in pairs(GetPlayers()) do
        table.insert(data, {
            ['ped'] = GetPlayerPed(v),
            ['name'] = GetPlayerName(v),
            ['serverid'] = v,
        })
    end
    TriggerClientEvent('bj-admin:server:ReturnPlayers', source, data)
    print(BJCore.Common.Dump(data))
end)

RegisterNetEvent('bj-admin:TeleportLog')
AddEventHandler('bj-admin:TeleportLog', function(targetId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(targetId)     
    TriggerEvent("bj-log:server:CreateLog", "bans", "Teleport", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has teleported to **"..Target.PlayerData.name.."** using the go to option in admin/staff menu") 
end)

RegisterNetEvent('bj-admin:OpenInventoryLog')
AddEventHandler('bj-admin:OpenInventoryLog', function(targetId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(targetId))     
    TriggerEvent("bj-log:server:CreateLog", "bans", "Open Inventory", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has opened **"..Target.PlayerData.name.."**'s inventory using admin/staff menu") 
end)

RegisterNetEvent('bj-admin:InvisLog')
AddEventHandler('bj-admin:InvisLog', function(targetId, bool)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if bool then
        TriggerEvent("bj-log:server:CreateLog", "bans", "Invisible", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has ENABLED invisble on themselves using admin/staff menu")
    else
        TriggerEvent("bj-log:server:CreateLog", "bans", "Invisible", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has DISABLED invisble on themselves using admin/staff menu")
    end 
end)

RegisterNetEvent('bj-admin:GodLog')
AddEventHandler('bj-admin:GodLog', function( bool)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if bool then
        TriggerEvent("bj-log:server:CreateLog", "bans", "God Mode", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has ENABLED godmode on themselves using admin/staff menu")
    else
        TriggerEvent("bj-log:server:CreateLog", "bans", "God Mode", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has DISABLED godmode on themselves using admin/staff menu")
    end 
end)

BJCore.Commands.Add("removewhitelist", "Remove player from whitelist", {{name="steamhex", help="Steam Hex ID e.g 'steam:123abc456'"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if args[1] ~= nil then
        BJCore.Functions.ExecuteSql(true, "DELETE FROM `whitelist` WHERE `steam` = '"..args[1].."'", function(result)
            if result then
                TriggerClientEvent('BJCore:Notify', source, args[1].." has been removed from whitelist")
                TriggerEvent("bj-log:server:CreateLog", "bans", "Remove Whitelist", "red", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has removed "..args[1].." from whitelist using the /removewhitelist command.")
            else
                TriggerClientEvent('BJCore:Notify', source, "No matching steam:hex found. Try again")
            end
        end)
    else
        TriggerClientEvent('BJCore:Notify', source, "Missing parameters. Try again noob")
    end
end, "admin")

BJCore.Commands.Add("donocar", "Give dono vehicle to target player", {{name="id", help="ID of target player"}}, true, function(source, args)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target ~= nil then
        TriggerClientEvent('bj-admin:client:getVehicle', Player.PlayerData.source, Target.PlayerData.source, 'dono')
    end
end, "admin")

RegisterNetEvent('admin:server:saveVehicleToPlayer')
AddEventHandler('admin:server:saveVehicleToPlayer', function(vehicle, cType, target, vType)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)
    local tData = BJCore.Functions.GetPlayer(target)
    local cid = tData.PlayerData.citizenid
    local plate = exports["vehicleshop"]:GeneratePlate()
    local isDono = 0
    if cType == 'dono' then isDono = 1; end

    BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `type`, `hash`, `mods`, `plate`, `state`, `is_dono`) VALUES ('"..tData.PlayerData.steam.."', '"..cid.."', '"..vehicle.."', '"..vType.."', '"..GetHashKey(vehicle).."', '{}', '"..plate.."', 0,'"..isDono.."')")
    TriggerClientEvent("BJCore:Notify", src, "Vehicle: "..vehicle.." with plate: "..plate.." has been saved to "..tData.PlayerData.name.."'s character ("..cid..")", "success", 10000)
    TriggerClientEvent('bj-admin:client:setVehicle', src, plate)
    local donoText = 'No'
    if isDono == 1 then donoText = 'Yes'; end
    TriggerEvent("bj-log:server:CreateLog", "bans", "Vehicle to Player", "red", "**"..pData.PlayerData.name.."** has given vehicle: "..vehicle.." with plate: "..plate.." to "..tData.PlayerData.name.."'s character ("..cid.."). Donation Vehicle: "..donoText)
end)

RegisterServerEvent('BJCore:RequestEntityDelete1')
AddEventHandler('BJCore:RequestEntityDelete1', function(id)
    local src = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(id))
    if owner == 0 then owner = -1; end
    DeleteEntity(NetworkGetEntityFromNetworkId(id))
    if DoesEntityExist(NetworkGetEntityFromNetworkId(id)) then
        TriggerClientEvent("bj-core:client:DeleteEntityReceived1", owner, id)
    end
end)

BJCore.Commands.Add("setmetadata", "Set metadata on target player", {{name="id", help="ID of target player"}, {name="name", help="Metadata name"}, {name="value", help="Value to set metadata to"}}, false, function(source, args)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target ~= nil then
        if Target.PlayerData.metadata[args[2]] ~= nil then
            if tonumber(args[3]) then
                args[3] = tonumber(args[3])
            end
            Target.Functions.SetMetaData(args[2], args[3])
        else
            TriggerClientEvent("BJCore:Notify", source, "Metadata type "..args[2].." not found", "error")
        end
    else
        TriggerClientEvent("BJCore:Notify", source, "Target player not found", "error")
    end
end, "god")

AutoAnnounce = {
    [1] = {
        message = "Join my discord fam",
        minutes = 30, -- every X minutes this will be posted
    }
}

AutoAnnouncer = false
if AutoAnnouncer then
    Citizen.CreateThread(function()
        for k,v in pairs(AutoAnnounce) do
            AutoAnnounce[k].lastSent = 0
        end
        local lastTime = GetGameTimer()
        while true do
            for k,v in pairs(AutoAnnounce) do
                if GetGameTimer() - v.lastSent >= (v.minutes*60*1000) then
                    AutoAnnounce[k].lastSent = GetGameTimer()
                    TriggerClientEvent('chatMessage', -1, "SYSTEM", "autoannounce", v.message)
                end
            end
            Citizen.Wait(60*1000)
        end
    end)
end

BJCore.Functions.RegisterServerCallback("admin:server:checkPerms", function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player then
        if BJCore.Functions.HasPermission(source, "helper") then
            cb(true)
        else
            cb(false)
        end
    end
end)
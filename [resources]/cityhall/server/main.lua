BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

local DrivingSchools = {
    -- "PAE31194",
    -- "TRB56419",
    -- "UNA59325",
    -- "LWR55470",
    -- "APJ79416",
    -- "FUN28030",
    "GMH27059",-- Wrighty
    "DJY66414", -- Jabba
    "OHC01182", -- Josh
    "GCO13804", -- Emsi
    "IHI07177", -- Ash
    --"FNS25981", -- QB
}

RegisterServerEvent('cityhall:server:requestId')
AddEventHandler('cityhall:server:requestId', function(identityData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    local licenses = {
        ["driver"] = true,
        ["business"] = false
    }

    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Motor Vehicles"
    end

    if Player.Functions.RemoveMoney('cash', Config.IdAndLicensePrice, 'Requested new '..identityData.label) or 
       Player.Functions.RemoveMoney('bank', Config.IdAndLicensePrice, 'Requested new '..identityData.label) then
        TriggerClientEvent('BJCore:Notify', src, 'You requested your '..identityData.label..' for '..BJCore.Config.Currency.Symbol..Config.IdAndLicensePrice, 'success', 3500)
        Player.Functions.AddItem(identityData.item, 1, nil, info)

        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[identityData.item], 'add')
    else
        TriggerClientEvent('BJCore:Notify', src, 'You don\'t have enough money', "error", 5000)
    end
end)

RegisterServerEvent('cityhall:server:sendDriverTest')
AddEventHandler('cityhall:server:sendDriverTest', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    TriggerEvent("bj-log:server:CreateLog", "default", "City Hall", "green", "**"..Player.PlayerData.name .. "** has requested driving lessons")
    for k, v in pairs(DrivingSchools) do 
        local SchoolPlayer = BJCore.Functions.GetPlayerByCitizenId(v)
        if SchoolPlayer ~= nil then 
            TriggerClientEvent("cityhall:client:sendDriverEmail", SchoolPlayer.PlayerData.source,  Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = "City Hall",
                subject = "Request driving lessons",
                message = "Dear,<br /><br />We just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact us:<br />Name: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "<br />Phone number: <strong>"..Player.PlayerData.charinfo.phone.."</strong><br/><br/>Kind regards,<br />City Hall Los Santos",
                button = {}
            }
            TriggerEvent("phone:server:sendNewMailToOffline", v, mailData)
        end
    end
    TriggerClientEvent('BJCore:Notify', src, 'An email has been sent to driving schools, you will be contacted when they can', "success", 5000)
end)

RegisterServerEvent('cityhall:server:ApplyJob')
AddEventHandler('cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local JobInfo = BJCore.Shared.Jobs[job]

    Player.Functions.SetJob(job, 1)

    TriggerClientEvent('BJCore:Notify', src, 'Congratulations with your new job! ('..JobInfo.label..')')
end)

BJCore.Commands.Add("givedlicense", "Give drivers license to a person", {{"id", "Player ID"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    --if IsWhitelistedSchool(Player.PlayerData.citizenid) then
    if Player.PlayerData.job.name == "drivinginstructor" or IsWhitelistedSchool(Player.PlayerData.citizenid) then    
        local SearchedPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
        if SearchedPlayer ~= nil then
            local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
            if not driverLicense then
                local licenses = {
                    ["driver"] = true,
                    ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
                }
                SearchedPlayer.Functions.SetMetaData("licences", licenses)
                TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "You passed! Pick up your driver's license at the city hall", "success", 5000)
                TriggerEvent("bj-log:server:CreateLog", "default", "City Hall", "green", "**"..Player.PlayerData.name .. "** has issued **"..SearchedPlayer.PlayerData.name.."** a driving license.")
            else
                TriggerClientEvent('BJCore:Notify', src, "Not authorised for this", "error")
            end
        end
    end
end)

BJCore.Commands.Add("givegunlicense", "Give gun license to a person", {{"id", "Player ID"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        local SearchedPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
        if SearchedPlayer ~= nil then
            local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["gun"]
            if not driverLicense then
                local licenses = {
                    ["gun"] = true,
                    ["driver"] = SearchedPlayer.PlayerData.metadata["licences"]["driver"],
                    ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"],

                }
                SearchedPlayer.Functions.SetMetaData("licences", licenses)
                TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "You have been given a weapons license", "success", 5000)
                TriggerEvent("bj-log:server:CreateLog", "default", "City Hall", "green", "**"..Player.PlayerData.name .. "** has issued **"..SearchedPlayer.PlayerData.name.."** a gun/weapons license.")
            else
                TriggerClientEvent('BJCore:Notify', src, "Not authorised for this", "error")
            end
        end
    end
end)

BJCore.Commands.Add("takegunlicense", "Take gun license to a person", {{"id", "Player ID"}}, true, function(source, args)
    local src = tonumber(source)
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" then
        local SearchedPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
        if SearchedPlayer ~= nil then
            local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
            if driverLicense then
                local licenses = {
                    ["gun"] = false,
                    ["driver"] = SearchedPlayer.PlayerData.metadata["licences"]["driver"],
                    ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
                }
                SearchedPlayer.Functions.SetMetaData("licences", licenses)
                TriggerClientEvent('BJCore:Notify', src, "License seized", "error")
            else
                TriggerClientEvent('BJCore:Notify', src, "This person has no gun license", "error")
            end
        end
    end
end)

function IsWhitelistedSchool(citizenid)
    local retval = false
    for k, v in pairs(DrivingSchools) do 
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('cityhall:server:banPlayer')
AddEventHandler('cityhall:server:banPlayer', function()
    local src = source
    --TriggerClientEvent('chatMessage', -1, "BJ Anti-Cheat", "error", GetPlayerName(src).." has been banned for sending POST Request's ")
    BJCore.Functions.ExecuteSql(false, "INSERT INTO `bans` (`name`, `steam`, `license`, `discord`,`ip`, `reason`, `expire`, `bannedby`) VALUES ('"..GetPlayerName(src).."', '"..GetPlayerIdentifiers(src)[1].."', '"..GetPlayerIdentifiers(src)[2].."', '"..GetPlayerIdentifiers(src)[3].."', '"..GetPlayerIdentifiers(src)[4].."', 'Abuse localhost:13172 for POST requests', 2145913200, '"..GetPlayerName(src).."')")
    DropPlayer(src, "This is not how things work right? ;).")
end)

BJCore.Commands.Add("setlawyer", "Register someone as a lawyer", {{name="id", help="Id of the player"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" or BJCore.Functions.HasPermission(source, "god") then
        if OtherPlayer ~= nil then 
            local lawyerInfo = {
                id = math.random(100000, 999999),
                firstname = OtherPlayer.PlayerData.charinfo.firstname,
                lastname = OtherPlayer.PlayerData.charinfo.lastname,
                citizenid = OtherPlayer.PlayerData.citizenid,
            }
            OtherPlayer.Functions.SetJob("lawyer", 1)
            OtherPlayer.Functions.AddItem("lawyerpass", 1, false, lawyerInfo)
            TriggerClientEvent("BJCore:Notify", source, "You have hired " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. " as a lawyer")
            TriggerClientEvent("BJCore:Notify", OtherPlayer.PlayerData.source, "You are now a lawyer")
            TriggerClientEvent('inventory:client:ItemBox', OtherPlayer.PlayerData.source, BJCore.Shared.Items["lawyerpass"], "add")
        else
            TriggerClientEvent("BJCore:Notify", source, "Player not found", "error")
        end
    else
        TriggerClientEvent("BJCore:Notify", source, "You don't have access to this", "error")
    end
end)

BJCore.Commands.Add("removelawyer", "Remove someone as a lawyer", {{name="id", help="ID of the player"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" or BJCore.Functions.HasPermission(source, "god") then
        if OtherPlayer ~= nil then
        OtherPlayer.Functions.SetJob("unemployed", 1)
            TriggerClientEvent("BJCore:Notify", OtherPlayer.PlayerData.source, "You are now unemployed")
            TriggerClientEvent("BJCore:Notify", source, "You have dismissed " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. " as a lawyer")
        else
            TriggerClientEvent("BJCore:Notify", source, "Player not found", "error")
        end
    else
        TriggerClientEvent("BJCore:Notify", source, "You don't have access to this", "error")
    end
end)

BJCore.Functions.CreateUseableItem("lawyerpass", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("cityhall:client:showLawyerLicense", -1, GetEntityCoords(GetPlayerPed(source)), item.info)
    end
end)
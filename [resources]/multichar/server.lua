BJCore = nil

TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

RegisterServerEvent('bj-core:multichar:server:playerJoin')
AddEventHandler('bj-core:multichar:server:playerJoin', function()
    local src = source
    local id
    for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            id = v
            break
        end
    end

    if not id then
        DropPlayer(src, "[Core] We were unable to detect your SteamID, try to reconnect with Steam open.")
    else
        TriggerClientEvent('bj-core:multichar:client:setupCharacters', src)
    end
end)

RegisterServerEvent('bj-core:multichar:server:charSelect')
AddEventHandler('bj-core:multichar:server:charSelect', function(cData)
    local src = source
    print("[MULTICHAR] loading char: "..tostring(src))
    if BJCore.Player.Login(src, cData) then
        print('^2[Core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData..') has successfully loaded')
        BJCore.Commands.Refresh(src)
        --loadHouseData()
        TriggerEvent('BJCore:Server:OnPlayerLoaded')
        TriggerClientEvent('BJCore:Client:OnPlayerLoaded', src)
        
        --TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("bj-log:server:sendLog", cData, "characterloaded", {})
        TriggerEvent("bj-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.." | "..src..") loaded..")
    end
end)

local DefaultSlotCount = 4
BJCore.Functions.RegisterServerCallback("bj-core:multichar:server:getChar", function(source, cb)
    local steamId = GetPlayerIdentifiers(source)[1]
    local plyCharsData = {}
    local charNum = DefaultSlotCount
    
    exports['ghmattimysql']:execute('SELECT cid, citizenid, charinfo, job, money FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
        if result and result ~= nil then
            for i = 1, (#result), 1 do
                result[i].charinfo = json.decode(result[i].charinfo)
                result[i].money = json.decode(result[i].money)
                result[i].job = json.decode(result[i].job)

                table.insert(plyCharsData, result[i])
            end
        end
        exports['ghmattimysql']:execute('SELECT * FROM char_whitelist WHERE steam = @steam', {['@steam'] = steamId}, function(data)
            if data and data[1] ~= nil then
                charNum = data[1].num
            end
            cb({plyChars = plyCharsData, numChar = charNum})
        end)

    end)
end)

BJCore.Commands.Add("managechars", "Grant extra char slots to target or check current char slots on target", {{name="id", help="ID of player"}, {name="action", help="Number of chars | check"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if Target ~= nil then
        local steamId = Target.PlayerData.steam
        if args[2] == 'check' then
            local charNum = 1
            exports['ghmattimysql']:execute('SELECT * FROM char_whitelist WHERE steam = @steam', {['@steam'] = steamId}, function(data)
                if data and data[1] ~= nil then
                    charNum = data[1].num
                end
                TriggerClientEvent('BJCore:Notify', source, Target.PlayerData.name.." - Char Slots allowed: "..charNum, "primary", 7000)
            end)
        elseif tonumber(args[2]) then
            local numChar = tonumber(args[2])
            if numChar == 0 then
                TriggerClientEvent('BJCore:Notify', source, "Cannot set allowed char slots to 0", "error")
            elseif numChar > 4 then
                TriggerClientEvent('BJCore:Notify', source, "Cannot set allowed char slots greater than 4", "error")
            elseif numChar == DefaultSlotCount then
                BJCore.Functions.ExecuteSql(true, "DELETE FROM `char_whitelist` WHERE `steam` = '"..steamId.."'")
                TriggerClientEvent('BJCore:Notify', source, Target.PlayerData.name.." successfully set to 1 char slot", "primary", 7000)
                TriggerEvent("bj-log:server:CreateLog", "admin", "Char Num Set", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set "..steamId.."'s allowed char slots to "..args[2])
            elseif numChar > 1 then
                BJCore.Functions.ExecuteSql(true, "INSERT INTO `char_whitelist` (`steam`, `num`) VALUES ('"..steamId.."','"..numChar.."')")
                TriggerClientEvent('BJCore:Notify', source, Target.PlayerData.name.." successfully set to "..args[2].." char slots", "primary", 7000)
                TriggerEvent("bj-log:server:CreateLog", "admin", "Char Num Set", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has set "..steamId.."'s allowed char slots to "..args[2])                
            end
        else
            TriggerClientEvent('BJCore:Notify', source, "Incorrect parameters", "error")
        end
    else
        TriggerClientEvent('BJCore:Notify', source, "Player not found", "error")
    end
end, "god")

BJCore.Functions.RegisterServerCallback('bj-core:multichar:server:refreshChars', function(source, cb)
    local id = GetPlayerIdentifiers(source)[1]

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @identifier', {['@identifier'] = id}, function(result)
        if result then                     
            cb(result)
        end
    end)
end)

RegisterServerEvent('bj-core:multichar:server:deleteChar')
AddEventHandler('bj-core:multichar:server:deleteChar', function(cid)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]

    exports['ghmattimysql']:execute('DELETE FROM players WHERE steam = @identifier AND citizenid = @cid', {['@identifier'] = identifier, ['@cid'] = cid})
    TriggerEvent("bj-log:server:CreateLog", "default", "Character Deletion", "green", "**"..identifier .. "** has deleted character id: "..cid)
end)

BJCore.Commands.Add("logout", "Logout and go to char selection", {}, false, function(source, args)
    doLogout(source)
end, "mod")

RegisterNetEvent('bj-core:multichar:server:logout')
AddEventHandler('bj-core:multichar:server:logout', function() local src = source doLogout(src); end)

RegisterNetEvent('bj-core:multichar:server:sendToLogout')
AddEventHandler('bj-core:multichar:server:sendToLogout', function(target) local src = source doLogout(target); end)

function doLogout(s)
    local Player = BJCore.Functions.GetPlayer(s)
    local MyItems = Player.PlayerData.items
    BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET `inventory` = '"..BJCore.EscapeSqli(json.encode(MyItems)).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
    BJCore.Player.Logout(s)
    --Wait(750)
    --TriggerClientEvent('bj-core:multichar:client:sendToCharSelect', s)
end
BJCore.Commands.Add("closeNUI", "Give item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
    TriggerClientEvent('qb-multicharacter:client:closeNUI', source)
end)

BJCore.Functions.RegisterServerCallback("bj-core:multichar:server:getSkin", function(source, cb, cid)
    local src = source

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..cid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('bj-core:multichar:server:createCharacter')
AddEventHandler('bj-core:multichar:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if BJCore.Player.Login(src, false, newData) then
        print('^2[core]^7 '..GetPlayerName(src)..' has successfully loaded')
        BJCore.Commands.Refresh(src)
        --loadHouseData()

        TriggerClientEvent('bj-core:multichar:client:spawnNewChar', src)
        TriggerEvent('BJCore:Server:OnPlayerLoaded')
        TriggerClientEvent('BJCore:Client:OnPlayerLoaded', src)
        GiveStarterItems(src)
	end
end)

function GiveStarterItems(source)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    for k, v in pairs(BJCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end


-- RegisterServerEvent('bj-core:multichar:server:createCharacter')
-- AddEventHandler('bj-core:multichar:server:createCharacter', function(cData)
--     local src = source
--     local identifier = GetPlayerIdentifiers(src)[1]
--     local license = GetPlayerIdentifiers(src)[2]
--     local name = GetPlayerName(src)
--     local cid = cData.cid

--     local bsn = math.random(100000000, 999999999)
--     local randomNum = math.random(100000000000, 999999999999)
--     local giroNum = math.random(1, 9)

--     exports['ghmattimysql']:execute('INSERT INTO players (`identifier`, `license`, `name`, `cid`, `cash`, `bank`, `bsn`, `banknumber`, `slotname`, `firstname`, `title`, `lastname`, `sex`, `dob`, `position`, `phone`) VALUES (@identifier, @license, @name, @cid, @cash, @bank, @bsn, @banknumber, @slotname, @firstname, @title, @lastname, @sex, @dob, @position, @phone)', {
--         ['identifier'] = identifier,
--         ['license'] = license,
--         ['name'] = name,
--         ['cid'] = cid,
--         ['cash'] = BJConfig.DefaultSettings.defaultCash,
--         ['bank'] = BJConfig.DefaultSettings.defaultBank,
--         ['bsn'] = bsn,
--         ['banknumber'] = "BNK0" ..giroNum.. "BJ" ..randomNum,
--         ['slotname'] = cData.slotname,
--         ['firstname'] = cData.firstname,
--         ['title'] = cData.title,
--         ['lastname'] = cData.lastname,
--         ['sex'] = cData.sex,
--         ['dob'] = cData.dob,
--         ['position'] = json.encode(BJConfig.spawnPosition),
--         ['phone'] = "0" .. math.random(600000000,699999999),
--         ['status'] = json.encode(BJConfig.defaultStatus)
--     })
--     TriggerClientEvent('bj-core:multichar:client:setupCharacters', src)
-- end)


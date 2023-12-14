local doorInfo = {}
local locationAccess = {}
local isNight = false

function autoLock()
    for a = 1, #doorInfo do
        for b = 1, #doorInfo[a].doors do
            if doorInfo[a].doors[b].autoLock
                and not doorInfo[a].doors[b].isLocked
                and doorInfo[a].doors[b].relock
                then
                if doorInfo[a].doors[b].autoLockCooldown <= 0 then
                    doorInfo[a].doors[b].isLocked = true
                    doorInfo[a].doors[b].autoLockCooldown = 0
                    doorInfo[a].doors[b].relock = false
                    local area = doorInfo[a].location
                    local pos = doorInfo[a].doors[b].doorPos
                    local isDouble = doorInfo[a].doors[b].doubleDoor
                    if isDouble then pos = doorInfo[a].doors[b].textPos; end
                    TriggerClientEvent('doorlock:client:setState', -1, area, pos, true, isDouble)
                else
                    doorInfo[a].doors[b].autoLockCooldown = doorInfo[a].doors[b].autoLockCooldown - 5
                end
            end
        end
    end
    SetTimeout(5000, autoLock)
end
autoLock()

Citizen.CreateThread(function()
    while not BJCore do Citizen.Wait(0); end
    doorInfo = doorList
    exports['ghmattimysql']:execute('CREATE TABLE IF NOT EXISTS `doorlocklocations` (`id` int NOT NULL AUTO_INCREMENT, `location` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL, `access` json NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;', {}, function() end)
    exports['ghmattimysql']:execute("SELECT * FROM doorlocklocations" , { }, function(locations)
        if locations[1] ~= nil then
            for k,v in pairs(locations) do
                locationAccess[v.location] = json.decode(v.access)
            end
        end
    end)
end)

BJCore.Commands.Add("listaccess", "List all people with access to a location", {}, false, function(source, args)
	TriggerClientEvent('doorlock:client:listAccessCommand', source)
end)

BJCore.Commands.Add("grantaccess", "Grant a person access to a locations doors/storage", {{name="citizenid",help="CitizenID of the person"}}, true, function(source, args)
	TriggerClientEvent('doorlock:client:grantAccessCommand', source, args)
end)

BJCore.Commands.Add("revokeaccess", "Revoke access from a person to a locations doors/storage", {{name="citizenid",help="CitizenID of the person"}}, true, function(source, args)
	TriggerClientEvent('doorlock:client:revokeAccessCommand', source, args)
end)

RegisterServerEvent('doorlock:server:grantLocationAccess')
AddEventHandler('doorlock:server:grantLocationAccess', function(location, target)
    local _src = tonumber(source)
    exports['ghmattimysql']:execute('SELECT citizenid, charinfo FROM players WHERE citizenid = @citizenid LIMIT 1;', {
        ['@citizenid'] = target
    }, function(players)
        if #players > 0 then
            if locationAccess[location] then
                local exists = false
                for _,v in ipairs(locationAccess[location]) do
                    if target == v then
                        exists = true
                        break
                    end
                end
                if not exists then
                    table.insert(locationAccess[location], target)
                    exports['ghmattimysql']:execute("UPDATE doorlocklocations SET access = @access WHERE location = @location" , {
                        ['@location'] = location,
                        ['@access'] = json.encode(locationAccess[location])
                    }, function() end)
                end
            else
                locationAccess[location] = {
                    target
                }
                exports['ghmattimysql']:execute("INSERT INTO doorlocklocations (location, access) VALUES (@location, @access)" , {
                    ['@location'] = location,
                    ['@access'] = json.encode(locationAccess[location])
                }, function() end)
            end
            TriggerClientEvent('doorlock:client:syncLocationAccess', -1, location, locationAccess[location])
            local charinfo = json.decode(players[1].charinfo)
            TriggerClientEvent('BJCore:Notify', _src, 'You have granted access to '..charinfo.firstname..' '..charinfo.lastname, 'success')
        else
            TriggerClientEvent('BJCore:Notify', _src, 'Could not find citizen', 'error')
        end
    end)
end)

RegisterServerEvent('doorlock:server:revokeLocationAccess')
AddEventHandler('doorlock:server:revokeLocationAccess', function(location, target)
    local _src = tonumber(source)
    if locationAccess[location] then
        local i = nil
        for k,v in ipairs(locationAccess[location]) do
            if v == target then
                i = k
                break
            end
        end
        if i then
            table.remove(locationAccess[location], i)

            exports['ghmattimysql']:execute("UPDATE doorlocklocations SET access = @access WHERE location = @location" , {
                ['@location'] = location,
                ['@access'] = json.encode(locationAccess[location])
            }, function() end)
            TriggerClientEvent('doorlock:client:syncLocationAccess', -1, location, locationAccess[location])
            TriggerClientEvent('BJCore:Notify', _src, 'You have revoked access from '..target, 'success')
        else
            TriggerClientEvent('BJCore:Notify', _src, 'Could not find citizen', 'error')
        end
    end
end)

RegisterServerEvent('doorlock:server:syncDoors')
AddEventHandler('doorlock:server:syncDoors', function()
	TriggerClientEvent('doorlock:client:syncDoors', source, doorInfo, locationAccess)
end)

RegisterServerEvent('doorlock:server:setState')
AddEventHandler('doorlock:server:setState', function(area, pos, status, doubleDoor)
    local cArea = area
    local cPos = pos
    local cStatus = status
    if doubleDoor then
        for a = 1, #doorInfo do
            if doorInfo[a].location == cArea then
                for b = 1, #doorInfo[a].doors do
                    if doorInfo[a].doors[b].textPos == cPos then
                        doorInfo[a].doors[b].isLocked = status
                    end
                end
            end
        end
        TriggerClientEvent('doorlock:client:setState', -1, cArea, cPos, cStatus, true)
    else
        for a = 1, #doorInfo do
            if doorInfo[a].location == cArea then
                for b = 1, #doorInfo[a].doors do
                    if doorInfo[a].doors[b].doorPos == cPos then
                        doorInfo[a].doors[b].isLocked = status
                    end
                end
            end
        end
        TriggerClientEvent('doorlock:client:setState', -1, cArea, cPos, cStatus, false)
    end
end)

RegisterServerEvent('doorlock:server:lockAtNight')
AddEventHandler('doorlock:server:lockAtNight', function(toggle)
    if toggle then
        if not isNight then
            for a = 1, #doorInfo do
                for b = 1, #doorInfo[a].doors do
                    if doorInfo[a].doors[b].lockAtNight
                        and not doorInfo[a].doors[b].isLocked
                        and not isNight
                        then
                        doorInfo[a].doors[b].isLocked = true
                    end
                end
            end
            isNight = true
        end
    else
        if isNight then
            for a = 1, #doorInfo do
                for b = 1, #doorInfo[a].doors do
                    if doorInfo[a].doors[b].lockAtNight
                        and doorInfo[a].doors[b].isLocked
                        and isNight
                        then
                        doorInfo[a].doors[b].isLocked = false
                    end
                end
            end
            isNight = false
        end
    end
end)

RegisterServerEvent('doorlock:server:autoLock')
AddEventHandler('doorlock:server:autoLock', function(area, pos, double)
    local isDouble = double
    for a = 1, #doorInfo do
        if doorInfo[a].location == area then
            for b = 1, #doorInfo[a].doors do
                if doorInfo[a].doors[b].doorPos == pos then
                    doorInfo[a].doors[b].isLocked = false
                    doorInfo[a].doors[b].autoLockCooldown = doorInfo[a].doors[b].autoLockTimer
                    doorInfo[a].doors[b].relock = true
                    break
                elseif doorInfo[a].doors[b].textPos == pos then
                    doorInfo[a].doors[b].isLocked = false
                    doorInfo[a].doors[b].autoLockCooldown = doorInfo[a].doors[b].autoLockTimer
                    doorInfo[a].doors[b].relock = true
                    break           
                end
            end
        end
    end
	TriggerClientEvent('doorlock:client:setState', -1, area, pos, false, isDouble)
end)

function tablematch(a, b)
    return table.concat(a) == table.concat(b)
end
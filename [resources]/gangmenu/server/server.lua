BJCore = nil
Accounts = {}
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

function getEmployeesTable(players, job)
    local employees = {}
    local added = {}
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if Player.PlayerData.gang.name == job then
                table.insert(employees, {
                    source = Player.PlayerData.citizenid, 
                    grade = {
                        level = Player.PlayerData.gang.grade.level and Player.PlayerData.gang.grade.level or 1,
                        name = Player.PlayerData.gang.grade.name and Player.PlayerData.gang.grade.name or 'Unknown'
                    },
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
                })
                added[Player.PlayerData.citizenid] = true
            end
        end
	end
    for key, value in pairs(players) do
        local isOnline = BJCore.Functions.GetPlayerByCitizenId(value.citizenid)

        if added[value.citizenid] then
            -- already added
        elseif isOnline then
            if isOnline.PlayerData.gang.name == job then
                table.insert(employees, {
                    source = isOnline.PlayerData.citizenid, 
                    grade = {
                        level = isOnline.PlayerData.gang.grade.level and isOnline.PlayerData.gang.grade.level or 1,
                        name = isOnline.PlayerData.gang.grade.name and isOnline.PlayerData.gang.grade.name or 'Unknown'
                    },
                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                })
            end
        else
            local job = json.decode(value.job)
            table.insert(employees, {
                source = value.citizenid, 
                grade =  (job and job.grade) and job.grade or {
                    level = 1,
                    name = BJCore.Shared.Gangs[job.name].grades[1].name
                },
                name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
            })
        end
    end
    return employees
end

RegisterServerEvent("bj-gangmenu:server:openMenu")
AddEventHandler("bj-gangmenu:server:openMenu", function()
    local src = source
    local xPlayer = BJCore.Functions.GetPlayer(src)
    local job = xPlayer.PlayerData.gang
    local employees = {}
    if isGangBoss(job) or Config.Gangs[job.name] ~= nil or xPlayer.PlayerData.job.name == "police" then
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `gang` LIKE '%".. job.name .."%'", function(players)
            if players[1] ~= nil then
                employees = getEmployeesTable(players, job.name)
            end

            local safe = exports['utils']:GetMoneysafe(job.name)
            TriggerClientEvent('bj-gangmenu:client:openMenu', src, employees, job.name, safe and safe.money or nil)
        end)
    else
        TriggerClientEvent('BJCore:Notify', src, "You are not the boss", "error")
    end
end)


RegisterServerEvent('bj-gangmenu:server:fireEmployee')
AddEventHandler('bj-gangmenu:server:fireEmployee', function(data)
    local src = source
    local xPlayer = BJCore.Functions.GetPlayer(src)
    local xEmployee = BJCore.Functions.GetPlayerByCitizenId(data.source)

    if not isGangBoss(xPlayer.PlayerData.gang) then
        TriggerClientEvent('BJCore:Notify', src, "You are not the boss", "error")
        return
    end

    if xEmployee then
        if xEmployee.Functions.SetGang("none", 1) then
            TriggerEvent('bj-logs:server:createLog', 'gangmenu', 'Gang Fire', "Successfully fired " .. GetPlayerName(xEmployee.PlayerData.source) .. ' (' .. xPlayer.PlayerData.gang.name .. ')', src)

            TriggerClientEvent('BJCore:Notify', src, "Fired successfully!", "success")
            TriggerClientEvent('BJCore:Notify', xEmployee.PlayerData.source , "You got fired.", "success")

            Wait(500)
            local employees = {}
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `job` LIKE '%".. xPlayer.PlayerData.gang.name .."%'", function(players)
                if players[1] ~= nil then
                    employees = getEmployeesTable(players, xPlayer.PlayerData.gang.name)
                    TriggerClientEvent('bj-gangmenu:client:refreshPage', src, 'employee', employees)
                end
            end)
        else
            TriggerClientEvent('BJCore:Notify', src, "Error.", "error")
        end
    else
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '" .. data.source .. "' LIMIT 1", function(player)
            if player[1] ~= nil then
                xEmployee = player[1]

                local jobConf = BJCore.Shared.Gangs["none"]
			    local jobgrade = jobConf.grades[1]

                local job = {
                    name = "unemployed",
			        label = jobConf.label,
			        grade = {
                        name = jobgrade.name,
                        level = 1
                    },
                }

                BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `gang` = '"..json.encode(job).."' WHERE `citizenid` = '".. data.source .."'")
                TriggerClientEvent('BJCore:Notify', src, "Fired successfully!", "success")
                TriggerEvent('bj-logs:server:createLog', 'gangmenu', 'Fire', "Successfully fired " .. data.source .. ' (' .. xPlayer.PlayerData.gang.name .. ')', src)
                
                Wait(500)
                local employees = {}
                BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `gang` LIKE '%".. xPlayer.PlayerData.gang.name .."%'", function(players)
                    if players[1] ~= nil then
                        employees = getEmployeesTable(players, xPlayer.PlayerData.gang.name)

                        TriggerClientEvent('bj-gangmenu:client:refreshPage', src, 'employee', employees)
                    end
                end)
            else
                TriggerClientEvent('BJCore:Notify', src, "Error. Could not find player.", "error")
            end
        end)
    end
end)

RegisterServerEvent('bj-gangmenu:server:giveJob')
AddEventHandler('bj-gangmenu:server:giveJob', function(data)
    local src = source
    local xPlayer = BJCore.Functions.GetPlayer(src)
    local xTarget = BJCore.Functions.GetPlayerByCitizenId(data.source)

    if isGangBoss(xPlayer.PlayerData.gang) then
        if xTarget and xTarget.Functions.SetGang(xPlayer.PlayerData.gang.name) then
            TriggerClientEvent('BJCore:Notify', src, "You recruit " .. (xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname) .. " to " .. xPlayer.PlayerData.gang.label .. ".", "success")
            TriggerClientEvent('BJCore:Notify', xTarget.PlayerData.source , "You've been recruited to " .. xPlayer.PlayerData.gang.label .. ".", "success")
            TriggerEvent('bj-logs:server:createLog', 'gangmenu', 'Recruit', "Successfully recruited " .. (xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname) .. ' (' .. xPlayer.PlayerData.gang.name .. ')', src)
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You are not the boss", "error")
    end
end)

RegisterServerEvent('bj-gangmenu:server:updateGrade')
AddEventHandler('bj-gangmenu:server:updateGrade', function(data)
    local src = source
    local xPlayer = BJCore.Functions.GetPlayer(src)
    local xEmployee = BJCore.Functions.GetPlayerByCitizenId(data.source)

    if xEmployee then
        if xEmployee.Functions.SetGang(xPlayer.PlayerData.gang.name, tonumber(data.grade)) then
            xEmployee = BJCore.Functions.GetPlayerByCitizenId(data.source)
            TriggerClientEvent('BJCore:Notify', src, "Promoted successfully!", "success")
            TriggerClientEvent('BJCore:Notify', xEmployee.PlayerData.source , "You just got promoted [" .. xEmployee.PlayerData.gang.grade.name .."].", "success")

            Wait(500)
            local employees = {}
            BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `gang` LIKE '%".. xPlayer.PlayerData.gang.name .."%'", function(players)
                if players[1] ~= nil then
                    employees = getEmployeesTable(players, xPlayer.PlayerData.gang.name)

                    TriggerClientEvent('bj-gangmenu:client:refreshPage', src, 'employee', employees)
                end
            end)
        else
            TriggerClientEvent('BJCore:Notify', src, "Error.", "error")
        end
    else
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '" .. data.source .. "' LIMIT 1", function(player)
            if player[1] ~= nil then
                xEmployee = player[1]
                local job = BJCore.Shared.Gangs[xPlayer.PlayerData.gang.name]
                local employeejob = json.decode(xEmployee.job)
                employeejob.grade = job.grades[tonumber(data.grade)]
                employeejob.grade.level = tonumber(data.grade)
                BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `gang` = '"..json.encode(employeejob).."' WHERE `citizenid` = '".. data.source .."'")
                TriggerClientEvent('BJCore:Notify', src, "Promoted successfully!", "success")
                
                Wait(500)
                local employees = {}
                BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `gang` LIKE '%".. xPlayer.PlayerData.gang.name .."%'", function(players)
                    if players[1] ~= nil then
                        employees = getEmployeesTable(players, xPlayer.PlayerData.gang.name)

                        TriggerClientEvent('bj-gangmenu:client:refreshPage', src, 'employee', employees)
                    end
                end)
            else
                TriggerClientEvent('BJCore:Notify', src, "Error. Could not find player.", "error")
            end
        end)
    end
end)

RegisterServerEvent('bj-gangmenu:server:updateNearbys')
AddEventHandler('bj-gangmenu:server:updateNearbys', function(data)
    local src = source
    local players = {}
    local xPlayer = BJCore.Functions.GetPlayer(src)
    for _, player in pairs(data) do
        local xTarget = BJCore.Functions.GetPlayer(player)
        if xTarget and xTarget.PlayerData.gang.name ~= xPlayer.PlayerData.gang.name then
            table.insert(players, {
                source = xTarget.PlayerData.citizenid,
                name = xTarget.PlayerData.charinfo.firstname .. ' ' .. xTarget.PlayerData.charinfo.lastname
            })
        end
    end

    TriggerClientEvent('bj-gangmenu:client:refreshPage', src, 'recruits', players)
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

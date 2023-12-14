BJCore = nil
PlayerJob = {}

Citizen.CreateThread(function()
   while BJCore == nil do
        TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
        Citizen.Wait(200)
    end

    while not BJCore.Functions.IsPlayerLoaded() do
        Citizen.Wait(10)
    end
    PlayerJob = BJCore.Functions.GetPlayerData().job
end)

local isInMenu = false

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        PlayerJob = BJCore.Functions.GetPlayerData().job
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    PlayerJob = BJCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 20, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        if BJCore and BJCore.Functions.IsPlayerLoaded() then
            if PlayerJob.name ~= nil and PlayerJob.grade ~= nil then
                local jobCfg = Config.Jobs[PlayerJob.name]
                if jobCfg and jobCfg.Grades[PlayerJob.grade.level] then
                    local pos = GetEntityCoords(PlayerPedId())
                    local isNearby = false
                    for k, v in pairs(jobCfg.Positions) do
                        local dist = #(pos - v)
                        if dist < 10 then
                            isNearby = true
                            if dist < 1 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Boss Menu")
                                --DrawMarker(25, v.x, v.y, v.z-0.96, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 0, 0)
                                if BJCore.Functions.GetKeyPressed("E") then
                                    TriggerServerEvent("bj-bossmenu:server:openMenu")
                                end
                            elseif dist < 3 then
                                BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Boss Menu")
                                --DrawMarker(25, v.x, v.y, v.z-0.96, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 0, 0)
                            end
                        end
                    end

                    Citizen.Wait(isNearby and 0 or 250)
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(7500)
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

RegisterNetEvent('bj-bossmenu:client:openMenu')
AddEventHandler('bj-bossmenu:client:openMenu', function(employees, jobName, safe)
    local employeesHTML, gradesHTML, recruitHTML = '', '', ''

    for _, player in pairs(employees) do
        if player.name then
            if player.grade ~= nil and player.grade.level then
                if isPlayerJobBoss(jobName, player.grade.level) then
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow option-enabled' id="player-]] .. player.source  .. [["><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                else
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]] .. player.source  .. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                end
            end
        end
    end

    if BJCore.Shared.Jobs[jobName] and BJCore.Shared.Jobs[jobName].grades then
        for level, grade in pairs(BJCore.Shared.Jobs[jobName].grades) do
            if isPlayerJobBoss(jobName, level) then
                gradesHTML = gradesHTML .. [[<div class='grade-box box-shadow option-enabled' id="grade-]] .. tostring(level) .. [["><span id='option-text'>]] .. grade.name .. [[</span></div>]]
            else
                gradesHTML = gradesHTML .. [[<div class='grade-box box-shadow' id="grade-]] .. tostring(level) .. [["><span id='option-text'>]] .. grade.name .. [[</span></div>]]
            end
        end
    end

    isInMenu = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        open = true,
        class = 'open',
        employees = employeesHTML,
        grades = gradesHTML,
    })
    
    if safe then
        SendNUIMessage({
            open = true,
            class = 'refresh-society',
            amount = safe,
        })
    else
        SendNUIMessage({
            open = true,
            class = 'hide-society'
        })
    end
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
RegisterNetEvent('bj-bossmenu:client:refreshPage')
AddEventHandler('bj-bossmenu:client:refreshPage', function(data, list)
    if data == 'employee' then
        local employeesHTML = ''
        for _, player in pairs(list) do
            if player.grade ~= nil and player.grade.level then
                if isPlayerJobBoss(jobName, player.grade.level) then
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow option-enabled' id="player-]] .. player.source  .. [["><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                else
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]] .. player.source  .. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                end
            end
        end
        
        isInMenu = true
        SendNUIMessage({
            open = true,
            class = 'refresh-players',
            employees = employeesHTML,
        })
    elseif data == 'recruits' then
        local recruitsHTML = ''

        if #list > 0 then
            for _, player in pairs(list) do
                recruitsHTML = recruitsHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-user-tag givejob"></i></span></span><span id='option-text'>]] .. player.name .. '</span></div>'
            end
        else
            recruitsHTML = [[<div class='player-box box-shadow option-enabled'><span class='hoster-options'"><span style="position: relative; top: 15%; margin-left: 27%;"></span></span><span id='option-text'>There is no players nearby.</span></div>]]
        end
        
        isInMenu = true
        SendNUIMessage({
            open = true,
            class = 'refresh-recruits',
            recruits = recruitsHTML,
        })
    end
end)

RegisterNetEvent('moneysafe:client:UpdateSafe')
AddEventHandler('moneysafe:client:UpdateSafe', function(data, job)
    if BJCore and BJCore.Functions.IsPlayerLoaded() and PlayerJob.name == job then
        SendNUIMessage({
            open = true,
            class = 'refresh-society',
            amount = data.money,
        })
    end
end)

RegisterNUICallback('openStash', function(data)
    isInMenu = false
    SendNUIMessage({open = false})
    SetNuiFocus(false, false)
    
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerJob.name, {
        maxweight = 4000000,
        slots = 500,
    })

    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerJob.name)
end)

RegisterNUICallback('outfit', function(data)
    isInMenu = false
    SendNUIMessage({open = false})
    SetNuiFocus(false, false)
   
    TriggerEvent('bj-clothing:client:openOutfitMenu')
    
end)

RegisterNUICallback('giveJob', function(data)
    TriggerServerEvent('bj-bossmenu:server:giveJob', data)
end)

RegisterNUICallback('openRecruit', function(data)
    CreateThread(function()
        local playerPed = PlayerPedId()
        local players = { GetPlayerServerId(PlayerId()) }
        for k,v in pairs(BJCore.Functions.GetPlayersFromCoords(GetEntityCoords(playerPed), 10.0)) do
            if v and v ~= PlayerId() then
                table.insert(players, GetPlayerServerId(v))
            end
        end

        TriggerServerEvent("bj-bossmenu:server:updateNearbys", players)
    end)
end)

RegisterNUICallback('changeGrade', function(data)
    TriggerServerEvent('bj-bossmenu:server:updateGrade', data)
end)

RegisterNUICallback('fireEmployee', function(data)
    TriggerServerEvent('bj-bossmenu:server:fireEmployee', data)
end)

RegisterNUICallback('closeNUI', function()
    isInMenu = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('withdraw', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("moneysafe:server:WithdrawMoney", PlayerJob.name, amount)
end)

RegisterNUICallback('deposit', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("moneysafe:server:DepositMoney", PlayerJob.name, amount)
end)

RegisterCommand('closeboss', function()
    isInMenu = false
    SendNUIMessage({
        open = false,
    })
    SetNuiFocus(false, false)
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


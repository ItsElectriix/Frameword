BJCore = nil
PlayerJob = {}
PlayerGang = {}

Citizen.CreateThread(function()
   while BJCore == nil do
        TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
        Citizen.Wait(200)
    end

    while not BJCore.Functions.IsPlayerLoaded() do
        Citizen.Wait(10)
    end
    PlayerGang = BJCore.Functions.GetPlayerData().gang
end)

local isInMenu = false

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        PlayerGang = BJCore.Functions.GetPlayerData().gang
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    PlayerGang = BJCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('BJCore:Client:OnGangUpdate')
AddEventHandler('BJCore:Client:OnGangUpdate', function(JobInfo)
    PlayerGang = JobInfo
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerJob = Player.job
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
    while not BJCore do Citizen.Wait(250); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(250); end
    while true do
        if PlayerGang.name ~= nil and PlayerGang.grade ~= nil then
            local isNearby = false
            for gang,data in pairs(Config.Gangs) do
                for _,pos in pairs(data.Positions) do
                    local plyPos = GetEntityCoords(PlayerPedId())
                    local dist = #(pos - plyPos)
                    if dist < 10 then
                        if PlayerGang.name == gang or PlayerJob.name == "police" then
                            isNearby = true
                            if dist < 1 then
                                BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "[~g~E~w~] Gang Menu")
                                --DrawMarker(25, pos.x, pos.y, pos.z-0.96, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 0, 0)
                                if BJCore.Functions.GetKeyPressed("E") then
                                    TriggerServerEvent("bj-gangmenu:server:openMenu", gang)
                                end
                            elseif dist < 3 then
                                BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "Gang Menu")
                                --DrawMarker(25, pos.x, pos.y, pos.z-0.96, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 200, 0, 0, 0, 0)
                            end
                        end
                    end
                end
            end
            if not isNearby then Citizen.Wait(500); end
            Citizen.Wait(1)
        else
            Citizen.Wait(7500)
        end
    end
end)

RegisterNetEvent('bj-gangmenu:client:openMenu')
AddEventHandler('bj-gangmenu:client:openMenu', function(employees, jobName, safe)
    local employeesHTML, gradesHTML, recruitHTML = '', '', ''

    for _, player in pairs(employees) do
        if player.name then
            if player.grade ~= nil and player.grade.level then
                if isPlayerGangBoss(jobName, player.grade.level) then
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow option-enabled' id="player-]] .. player.source  .. [["><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                else
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]] .. player.source  .. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                end
            end
        end
    end

    if BJCore.Shared.Jobs[jobName] and BJCore.Shared.Jobs[jobName].grades then
        for level, grade in pairs(BJCore.Shared.Jobs[jobName].grades) do
            if isPlayerGangBoss(jobName, level) then
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
    if isPlayerGangBoss(PlayerGang.name, PlayerGang.grade.level) then
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
        SendNUIMessage({
            open = true,
            class = 'show-boss',
        })
    else
        SendNUIMessage({
            open = true,
            class = 'hide-boss',
        })
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
RegisterNetEvent('bj-gangmenu:client:refreshPage')
AddEventHandler('bj-gangmenu:client:refreshPage', function(data, list)
    if data == 'employee' then
        local employeesHTML = ''
        for _, player in pairs(list) do
            if player.grade ~= nil and player.grade.level then
                if isPlayerGangBoss(jobName, player.grade.level) then
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
    if BJCore and BJCore.Functions.IsPlayerLoaded() and PlayerGang.name == job then
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
    
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerGang.name, {
        maxweight = 4000000,
        slots = 500,
    })

    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerGang.name)
end)

RegisterNUICallback('outfit', function(data)
    isInMenu = false
    SendNUIMessage({open = false})
    SetNuiFocus(false, false)
   
    TriggerEvent('bj-clothing:client:openOutfitMenu')
    
end)

RegisterNUICallback('giveJob', function(data)
    TriggerServerEvent('bj-gangmenu:server:giveJob', data)
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

        TriggerServerEvent("bj-gangmenu:server:updateNearbys", players)
    end)
end)

RegisterNUICallback('changeGrade', function(data)
    TriggerServerEvent('bj-gangmenu:server:updateGrade', data)
end)

RegisterNUICallback('fireEmployee', function(data)
    TriggerServerEvent('bj-gangmenu:server:fireEmployee', data)
end)

RegisterNUICallback('closeNUI', function()
    isInMenu = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('withdraw', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("moneysafe:server:WithdrawMoney", PlayerGang.name, amount)
end)

RegisterNUICallback('deposit', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("moneysafe:server:DepositMoney", PlayerGang.name, amount)
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


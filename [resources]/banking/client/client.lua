BankData = {}
HackedATMS = {}
Citizen.CreateThread(function()
    while not BJCore do Wait(500); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(500); end
    BJCore.Functions.TriggerServerCallback('banking:GetStartData', function(bankData, atmData)
        BankData = bankData
        HackedATMS = atmData
    end)
    local dist = 1000.0
    while true do 
        Citizen.Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        local nearby = false
        for k,v in ipairs(Config.Banks) do
            local dist = #(coords - v)
            if dist < 20 then nearby = true; end
            if dist < 0.8 then --changed to 3.0    
                if BankData[k] then
                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~s~] Use Bank")
                    if IsControlJustReleased(0, 38) and #(coords - v) < 0.8 then
                        TriggerServerEvent("banking:getBankAmount")
                    end
                else
                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "Bank Closed")
                end
            end
        end
        if not nearby then
            Citizen.Wait(dist)
        end
    end
end)

-- DEV COMMAND
-- RegisterCommand("react:show", function()
--     TriggerServerEvent("banking:getBankAmount")
-- end)

RegisterNetEvent("banking:checkForATM")
AddEventHandler("banking:checkForATM", function()
    local nearATM, atmId = IsNearATM(true)
    if nearATM then
        if HackedATMS[GetEntityCoords(atmId)] then
            BJCore.Functions.Notify('ATM is offline', 'error')
        else
            playAnim('mp_common', 'givetake1_a', 2500)
            Citizen.Wait(2500)
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent("banking:getBankAmount")
        end
    else
        BJCore.Functions.Notify('ATM not found', 'error')
    end
end)

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end

local atms = {
    [1] = -1126237515,
    [2] = 506770882,
    [3] = -870868698,
    [4] = 150237004,
    [5] = -239124254,
    [6] = -1364697528,  
}

function IsNearATM(ignoreTask)
    for i = 1, #atms do
      local objFound = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 0.75, atms[i], 0, 0, 0)
  
      if DoesEntityExist(objFound) then
        if not ignoreTask then
            TaskTurnPedToFaceEntity(PlayerPedId(), objFound, 3.0)
        end
        return true, objFound
      end
    end
  
    return false
end

local cashPtfxAsset = 'scr_xs_celebration'
local cashPtfxName = 'scr_xs_money_rain'

exports('IsNearATM', IsNearATM)

function CanHackATM()
    local nearATM, atmId = IsNearATM(true)
    if nearATM then
        local pData = BJCore.Functions.GetPlayerData()
        if pData and pData.items then
            for k,v in pairs(pData.items) do
                if v.name == 'trojan_usb' and v.amount > 0 then
                    return true
                end
            end
        end
    end
    return false
end

exports('CanHackATM', CanHackATM)

function showLoopParticle(dict, particleName, coords, heading, time)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(0)
    end
    UseParticleFxAssetNextCall(dict)
    local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords, 90.0, heading, 0.0, 1.0, false, false, false)
    --SetParticleFxLoopedColour(particleHandle, 0, 255, 0, 0)
    Citizen.Wait(time)
    StopParticleFxLooped(particleHandle, false)
    return particleHandle
end

RegisterNetEvent('banking:atmParticles')
AddEventHandler('banking:atmParticles', function(coords, heading)
    showLoopParticle(cashPtfxAsset, cashPtfxName, coords, heading, 7000)
end)

RegisterNetEvent('banking:atmHacked')
AddEventHandler('banking:atmHacked', function(coords)
    print('ATM Hacked: '..tostring(coords))
    HackedATMS[coords] = true
end)

AddEventHandler("banking:hackATM", function()
    local nearATM, atmId = IsNearATM(true)
    if nearATM then
        local atmCoords = GetEntityCoords(atmId)
        if HackedATMS[atmCoords] then
            BJCore.Functions.Notify('This ATM has already been hacked.', 'error', 5000)
        else
            local pData = BJCore.Functions.GetPlayerData()
            if pData and pData.metadata then
                local hackValue = pData.metadata["hackerrep"] and pData.metadata["hackerrep"] or 0
                local difficulty = 5 - math.ceil(hackValue / 100 * 5)
                local plyPed = PlayerPedId()
                local coords = GetEntityCoords(plyPed)
                FreezeEntityPosition(plyPed, true)
                TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
                exports['mythic_progbar']:Progress({
                    name = "atm_hack",
                    duration = 4000,
                    label = "Preparing device",
                    canCancel = false,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                        disableInteract = true
                    },
                }, function(status)
                    if not status then
                        TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_STAND_MOBILE", 0, false)
                        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", coords)
                        end                         
                        TriggerServerEvent("crim:server:ChanceRemove", 'trojan_usb', 15)
                        local times = math.random(3,5)
                        local count = 0
                        local busy, failed = false, false
                        for i = 1,times,1 do
                            if failed then break; end
                            busy = true
                            TriggerEvent('bj_minigames:start', 'Hackconnect', { difficulty = difficulty, timer = 20000, background = 1 }, function(data)
                                count = count + 1
                                BJCore.Functions.Notify(count.."/"..times.." tasks complete")
                                if count == times then
                                    ClearPedTasksImmediately(plyPed)
                                    FreezeEntityPosition(plyPed, false)                                  
                                    BJCore.Functions.Notify('ATM hacked', 'primary',10000)
                                    HackedATMS[atmCoords] = true
                                    TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hack Tasks", "green", "**"..pData.name .. "** has hacked atm at "..atmCoords..".")
                                    local coords = GetOffsetFromEntityInWorldCoords(atmId, Config.ParticleModelOffsets[GetEntityModel(atmId)])
                                    local heading = GetEntityHeading(atmId)
                                    for _,v in ipairs(BJCore.Functions.GetPlayersFromCoords(coords, 30.0)) do
                                        TriggerServerEvent('banking:syncAtmParticles', GetPlayerServerId(v), coords, heading)
                                    end
                                    if math.random(100) <= 30 then
                                        TriggerServerEvent('MF_Trackables:Notify','An ATM alarm just tripped', coords, 'police', 'atm')
                                    end 
                                    Wait(6500)
                                    if #(coords - GetEntityCoords(plyPed)) < 3.5 then
                                        TriggerServerEvent('banking:rewardAtmRobbery', atmCoords, true)
                                    else
                                        TriggerServerEvent('banking:rewardAtmRobbery', atmCoords, false)
                                    end
                                end
                                busy = false
                            end, function(data)
                                busy = false
                                failed = true
                                exports.crim:electrocutePlayer()
                                BJCore.Functions.Notify("Failed", "error")
                                TriggerServerEvent('MF_Trackables:Notify','An ATM alarm just tripped.', coords, 'police', 'atm')
                                ClearPedTasksImmediately(plyPed)
                                FreezeEntityPosition(plyPed, false)
                                -- Alert police
                            end)
                            while busy do Citizen.Wait(0); end
                        end           
                    end
                end)
            end
        end
    end
end)

RegisterNetEvent("banking:money")
AddEventHandler("banking:money", function(money, name)
    TriggerEvent('police:client:pauseKeybind', true)
    local _money = money
    local _name = name
    Bank = {
        {
            id = 1,
            name = _name,
            balance = _money,
        }, 
    }

    BJCore.Functions.TriggerServerCallback('banking:get:transactions', function(transactions)
        SendNUIMessage({
            type = "RECIEVE_TRANSACTIONS",
            data = {
                transactions = transactions
            }
        })
    end)

    SendNUIMessage({
        type = "RECIEVE_BANK",
        data = {header = Bank}
    })

    SendNUIMessage(
        {
            type = "APP_SHOW"
        }
    )
    SetNuiFocus(true, true)

end)

-- DEPOSIT

RegisterNUICallback("depositAmount", function(data)
    --print("AMOUNT")
    local depositAmount = data.value
    local depositDate = data.date
    --print(depositAmount, depositDate)
    TriggerServerEvent("banking:deposit", depositAmount, depositDate)
    BJCore.Functions.TriggerServerCallback('banking:get:transactions', function(transactions)
        SendNUIMessage({
            type = "RECIEVE_TRANSACTIONS",
            data = {
                transactions = transactions
            }
        })
    end)
    TriggerServerEvent("banking:getBankAmount")
end)

-- WITHDRAW

RegisterNUICallback("withdrawAmount", function(data)
    local withdrawAmount = data.value
    local withdrawDate = data.date
    --print(withdrawAmount, withdrawDate)
    TriggerServerEvent("banking:withdraw", withdrawAmount, withdrawDate)
    BJCore.Functions.TriggerServerCallback('banking:get:transactions', function(transactions)
        SendNUIMessage({
            type = "RECIEVE_TRANSACTIONS",
            data = {
                transactions = transactions
            }
        })
    end)
    TriggerServerEvent("banking:getBankAmount")
end)

-- TRANSFER

RegisterNUICallback("transferAmount", function(data)
    local transferAmount = data.value 
    local transferName = data.name
    local transferDate = data.date
    --print(transferAmount, transferDate, transferName)
    TriggerServerEvent("banking:transfer", transferAmount, transferDate, transferName)
end)


-- ALERT


RegisterNetEvent("banking:send:alert")
AddEventHandler("banking:send:alert", function(method, messageStr)
    --print(method, messageStr)
    SendNUIMessage({
        type = "SEND_ALERT",
        data = {
            alert = method,
            message = messageStr
        }
    })
end)


RegisterNUICallback("closeBank", function(data)
    TriggerEvent('police:client:pauseKeybind', false)
    SendNUIMessage(
        {
            type = "APP_HIDE"
        }
    )
    SetNuiFocus(false, false)
    playAnim('mp_common', 'givetake1_a', 2500)
    Citizen.Wait(2500)
    ClearPedTasks(PlayerPedId())
end)


--DEV COMMAND
RegisterCommand("react:hide", function()
    TriggerEvent('police:client:pauseKeybind', false)
    SendNUIMessage(
        {
            type = "APP_HIDE"
        }
    )
    SetNuiFocus(false, false)
end)

RegisterNetEvent('banking:client:CheckDistance')
AddEventHandler('banking:client:CheckDistance', function(targetId, amount)
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if targetId == playerId then
          TriggerServerEvent('banking:server:giveCash', playerId, amount)
        end
    else
        BJCore.Functions.Notify('You\'re not nearby this person', 'error')
    end
end)

function GetClosestPlayer()
    local closestPlayers = BJCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
              closestPlayer = closestPlayers[i]
              closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

RegisterNetEvent("banking:syncData")
AddEventHandler("banking:syncData", function(data) BankData = data end)

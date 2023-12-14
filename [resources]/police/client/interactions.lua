local isDoingHandcuff = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if isEscorted then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, Keys['T'], true)
            EnableControlAction(0, Keys['E'], true)
            EnableControlAction(0, Keys['ESC'], true)
            EnableControlAction(0, Keys['N'], true)
        end

        if isHandcuffed then
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1

            DisableControlAction(0, Keys['R'], true) -- Reload
            DisableControlAction(0, Keys['SPACE'], true) -- Jump
            DisableControlAction(0, Keys['Q'], true) -- Cover
            DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
            DisableControlAction(0, Keys['F'], true) -- Also 'enter'?

            DisableControlAction(0, Keys['F1'], true) -- Disable phone
            DisableControlAction(0, Keys['F2'], true) -- Inventory
            DisableControlAction(0, Keys['F3'], true) -- Animations
            DisableControlAction(0, Keys['F6'], true) -- Job

            DisableControlAction(0, Keys['C'], true) -- Disable looking behind
            DisableControlAction(0, Keys['X'], true) -- Disable clearing animation
            DisableControlAction(2, Keys['P'], true) -- Disable pause screen

            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle

            DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth

            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true)  -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle

            if (not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not IsEntityPlayingAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3)) and not BJCore.Functions.GetPlayerData().metadata["isdead"] then
                loadAnimDict("mp_arresting")
                TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, cuffType, 0, 0, 0, 0)
            end
        end
        if not isHandcuffed and not isEscorted then
            Citizen.Wait(2000)
        end
    end
end)

local pause = false
AddEventHandler("police:client:pauseKeybind", function(bool)
    pause = bool
end)

RegisterKeyMapping('-handcuff', 'Handcuff~', 'keyboard', 'UP')
RegisterCommand('-handcuff', function()
    local alt = true
    if IsControlPressed(0,19) then alt = false end
    if not PlayerJob then return; end
    if PlayerJob.name ~= "police" then return; end
    if not onDuty then return; end
    if pause then return; end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return; end
    TriggerEvent("police:client:CuffPlayerSoft", alt)
end, false)

RegisterKeyMapping('-uncuff', 'Un-Cuff~', 'keyboard', 'DOWN')
RegisterCommand('-uncuff', function()
    if pause then return; end
    if not PlayerJob then return; end
    if PlayerJob.name ~= "police" then return; end
    if not onDuty then return; end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return; end
    TriggerEvent("police:client:UnCuffPlayer")
end, false)

RegisterKeyMapping('-escort', 'Escort~', 'keyboard', 'LEFT')
RegisterCommand('-escort', function()
    if pause then return; end
    if not PlayerJob then return; end
    if PlayerJob.name ~= "police" then return; end
    if not onDuty then return; end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return; end
    TriggerEvent("police:client:EscortPlayer")
end, false)

RegisterKeyMapping('-inoutvehicle', 'Put In/Out Vehicle~', 'keyboard', 'RIGHT')
RegisterCommand('-inoutvehicle', function()
    if pause then return; end
    if not PlayerJob then return; end
    if PlayerJob.name ~= "police" then return; end
    if not onDuty then return; end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return; end
    TriggerEvent("police:client:PutPlayerInVehicle")
end, false)

RegisterNetEvent('police:client:SetOutVehicle')
AddEventHandler('police:client:SetOutVehicle', function(pos)
    local plyPed = PlayerPedId()
    if IsPedInAnyVehicle(plyPed, false) then
        local plyPed = PlayerPedId()  
        ClearPedTasksImmediately(plyPed)        
        local veh = GetVehiclePedIsIn(plyPed, false)
        TaskLeaveVehicle(plyPed, veh, 256)
        SetEntityCoords(plyPed, pos)
    end
end)

RegisterNetEvent('police:client:PutInVehicle')
AddEventHandler('police:client:PutInVehicle', function(vehID)
    --if isHandcuffed or isEscorted then
        --local vehicle = BJCore.Functions.GetClosestVehicle()
        local vehicle = NetworkGetEntityFromNetworkId(vehID)
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            for i = GetVehicleMaxNumberOfPassengers(vehicle), 1, -1 do
                if IsVehicleSeatFree(vehicle, i) then
                    isEscorted = false
                    TriggerEvent('hospital:client:isEscorted', isEscorted)
                    ClearPedTasks(PlayerPedId())
                    DetachEntity(PlayerPedId(), true, false)

                    Citizen.Wait(100)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, i)
                    return
                end
                if IsVehicleSeatFree(vehicle,0) then
                    isEscorted = false
                    TriggerEvent('hospital:client:isEscorted', isEscorted)
                    ClearPedTasks(PlayerPedId())
                    DetachEntity(PlayerPedId(), true, false)

                    Citizen.Wait(100)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, 0)          
                end                
            end
        end
    --end
end)

RegisterNetEvent('police:client:GSRTest')
AddEventHandler('police:client:GSRTest', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.0 then
        exports['mythic_progbar']:Progress({
            name = "gsrtest_player",
            duration = math.random(5000, 7000),
            label = "Testing for GSR",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {task = 'WORLD_HUMAN_STAND_MOBILE'}
        }, function(status)
            if not status then
                local plyCoords = GetEntityCoords(GetPlayerPed(player))
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - plyCoords)
                if dist < 2.0 then
                    local playerId = GetPlayerServerId(player)
                    TriggerServerEvent("police:server:RequestStatus", "gunpowder", playerId)
                else
                    BJCore.Functions.Notify("Target moved away", "error")
                end
            else
                BJCore.Functions.Notify("Cancelled", "error")
            end
        end)        
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:FriskPlayer')
AddEventHandler('police:client:FriskPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.0 then
        --print("1player:",player)
        local playerId = GetPlayerServerId(player)
        exports['mythic_progbar']:Progress({
            name = "frisking_player",
            duration = math.random(5000, 7000),
            label = "Frisking",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(status)
            if not status then
                --print("2player:",player)
                local plyCoords = GetEntityCoords(GetPlayerPed(player))
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - plyCoords)
                if dist < 2.0 then
                    local playerId = GetPlayerServerId(player)
                    TriggerServerEvent("police:server:FriskPlayer", playerId)
                else
                    BJCore.Functions.Notify("Target moved away", "error")
                end
            else
                BJCore.Functions.Notify("Cancelled", "error")
            end
        end)         
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:ScannerResult')
AddEventHandler('police:client:ScannerResult', function(found)
    if found then
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'metaldetected', 0.2)
    else
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'metaldetector', 0.05)
    end
end)

RegisterNetEvent('police:client:SearchPlayer')
AddEventHandler('police:client:SearchPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", playerId)
        TriggerServerEvent("police:server:SearchPlayer", playerId)
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:SeizeCash')
AddEventHandler('police:client:SeizeCash', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent("police:server:SeizeCash", playerId)
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:SeizeDriverLicense')
AddEventHandler('police:client:SeizeDriverLicense', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent("police:server:SeizeDriverLicense", playerId)
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:SeizeGunLicense')
AddEventHandler('police:client:SeizeGunLicense', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent("police:server:SeizeGunLicense", playerId)
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

local RequireGunRob = false
RegisterNetEvent('police:client:RobPlayer')
AddEventHandler('police:client:RobPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 1.5 then
        local playerPed = GetPlayerPed(player)
        local playerId = GetPlayerServerId(player)
        if RequireGunRob then
            if not IsPedArmed(PlayerPedId(), 7) then return BJCore.Functions.Notify("You need a gun to rob", "error"); end
        end
        if IsEntityPlayingAnim(playerPed, "missminuteman_1ig_2", "handsup_base", 3) or IsEntityPlayingAnim(playerPed, "mp_arresting", "idle", 3) or IsTargetDead(playerId) then
            exports['mythic_progbar']:Progress({
                name = "robbing_player",
                duration = math.random(5000, 7000),
                label = "Robbing person",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
                animation = {
                    animDict = "random@shop_robbery",
                    anim = "robbery_action_b",
                    flags = 16,
                },
            }, function(status)
                if not status then
                    local plyCoords = GetEntityCoords(playerPed)
                    local pos = GetEntityCoords(PlayerPedId())
                    local dist = #(pos - plyCoords)
                    if dist < 2.5 then
                        StopAnimTask(PlayerPedId(), "random@shop_robbery", "robbery_action_b", 1.0)
                        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", playerId)
                        TriggerEvent("inventory:server:RobPlayer", playerId)
                        TriggerEvent("police:server:RobPlayerLog", playerId)
                    else
                        BJCore.Functions.Notify("Target moved away", "error")
                    end
                else
                    StopAnimTask(PlayerPedId(), "random@shop_robbery", "robbery_action_b", 1.0)
                    BJCore.Functions.Notify("Cancelled", "error")
                end
            end)
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:JailCommand')
AddEventHandler('police:client:JailCommand', function(playerId, time)
    TriggerServerEvent("police:server:JailPlayer", playerId, tonumber(time))
end)

RegisterNetEvent('police:client:BillCommand')
AddEventHandler('police:client:BillCommand', function(playerId, price)
    TriggerServerEvent("police:server:BillPlayer", playerId, tonumber(price))
end)

RegisterNetEvent('police:client:JailPlayer')
AddEventHandler('police:client:JailPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 20)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(7)
        end
        local time = GetOnscreenKeyboardResult()
        if tonumber(time) > 0 then
            TriggerServerEvent("police:server:JailPlayer", playerId, tonumber(time))
        else
            BJCore.Functions.Notify("Time must be higher than 0", "error")
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:DepotVehicle')
AddEventHandler('police:client:DepotVehicle', function(option)
    local plyPed = PlayerPedId()
    local coordA = GetEntityCoords(plyPed)
    local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 100.0, 0.0)
    local v = getVehicleInDirection(coordA, coordB)
    if v == 0 or v == nil then v = BJCore.Functions.GetClosestVehicle(); end
    if v ~= 0 and v ~= nil then
        if option == 'depot' then
            local title = ""
            AddTextEntry('FMMC_KEY_TIP1', 'Set Depot Price:')
            DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "0", "", "", "", 20)
            while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                DisableAllControlActions(0)
                DisableControlAction(0, 20, true)
                Citizen.Wait(1)
            end
            local amount = GetOnscreenKeyboardResult()
            TriggerEvent('police:client:ImpoundVehicle', false, amount or 0)
        elseif option == 'impound' then
            TriggerEvent('police:client:ImpoundVehicle', true, 0)
        end
    else
        BJCore.Functions.Notify("Vehicle not found", "error")
    end
end)

RegisterNetEvent('police:client:BillPlayer')
AddEventHandler('police:client:BillPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 20)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(7)
        end
        local price = GetOnscreenKeyboardResult()
        if tonumber(price) > 0 then
            TriggerServerEvent("police:server:BillPlayer", playerId, tonumber(price))
        else
            BJCore.Functions.Notify("Amount needs to be higher than 0", "error")
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:PutPlayerInVehicle')
AddEventHandler('police:client:PutPlayerInVehicle', function()
    local ped, dist, t = GetClosestPedIgnoreCar()
   if (dist ~= -1 and dist < 2.5) or (dist ~= 1 and GetEntityModel(BJCore.Functions.GetClosestVehicle()) == GetHashKey('medic1') and dist < 5.0) then
        local isInVeh = IsPedInAnyVehicle(ped, true)
        if not isHandcuffed and not isEscorted then
            if not isInVeh then
                local plyPed = PlayerPedId()
                local coordA = GetEntityCoords(plyPed)
                local coordB = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 100.0, 0.0)
                local v = getVehicleInDirection(coordA, coordB)
                if v ~= 0 and v ~= nil then 
                    print(v)           
                    TriggerServerEvent("police:server:PutPlayerInVehicle", GetPlayerServerId(t), VehToNet(v))
                else
                    BJCore.Functions.Notify("Vehicle not found. Try again?", "error")
                end
            else
                TriggerEvent("police:client:SetPlayerOutVehicle")
            end
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:SetPlayerOutVehicle')
AddEventHandler('police:client:SetPlayerOutVehicle', function()
    local ped, dist, t = GetClosestPedIgnoreCar()
    if dist ~= -1 and dist < 2.5 or (dist ~= 1 and GetEntityModel(BJCore.Functions.GetClosestVehicle()) == GetHashKey('medic1') and dist < 5.0) then
        if not isHandcuffed and not isEscorted then
            TriggerServerEvent("police:server:SetPlayerOutVehicle", GetPlayerServerId(t), GetEntityCoords(PlayerPedId()))
            Citizen.Wait(1000)
            TriggerServerEvent("police:server:EscortPlayer", GetPlayerServerId(t))
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:EscortPlayer')
AddEventHandler('police:client:EscortPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not isHandcuffed and not isEscorted then
            TriggerServerEvent("police:server:EscortPlayer", playerId)
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

function IsHandcuffed()
    return isHandcuffed
end

RegisterNetEvent('police:client:KidnapPlayer')
AddEventHandler('police:client:KidnapPlayer', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not IsPedInAnyVehicle(GetPlayerPed(player)) then
            if not isHandcuffed and not isEscorted then
                TriggerServerEvent("police:server:KidnapPlayer", playerId)
            end
        end
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

RegisterNetEvent('police:client:CuffPlayerSoft')
AddEventHandler('police:client:CuffPlayerSoft', function(soft)
    if not IsPedRagdoll(PlayerPedId()) then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            local playerId = GetPlayerServerId(player)
            if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(GetPlayerPed(PlayerPedId())) and not isDoingHandcuff then
                TriggerServerEvent("police:server:CuffPlayer", playerId, soft)
                HandCuffAnimation()
            elseif isDoingHandcuff then
                print('Handcuff spam protection')
            else
                BJCore.Functions.Notify("You cant cuff someone in a vehicle", "error")
            end
        else
            BJCore.Functions.Notify("No one nearby", "error")
        end
    else
        Citizen.Wait(2000)
    end
end)

RegisterNetEvent('police:client:CuffPlayer')
AddEventHandler('police:client:CuffPlayer', function()
    if not IsPedRagdoll(PlayerPedId()) then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            --BJCore.Functions.TriggerServerCallback('BJCore:HasItem', function(result)
                --if result then 
                    local playerId = GetPlayerServerId(player)
                    if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(GetPlayerPed(PlayerPedId())) and not isDoingHandcuff then
                        TriggerServerEvent("police:server:CuffPlayer", playerId, false)
                        HandCuffAnimation()
                    elseif isDoingHandcuff then
                        print('Handcuff spam protection')
                    else
                        BJCore.Functions.Notify("You can\'t cuff someone in/from a vehicle", "error")
                    end
                --else
                    --BJCore.Functions.Notify("You don\'t have handcuffs on you", "error")
                --end
            --end, "handcuffs")
        else
            BJCore.Functions.Notify("No one nearby", "error")
        end
    else
        Citizen.Wait(2000)
    end
end)

RegisterNetEvent('police:client:UnCuffPlayer')
AddEventHandler('police:client:UnCuffPlayer', function()
    if not IsPedRagdoll(PlayerPedId()) then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            local playerId = GetPlayerServerId(player)
            if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(GetPlayerPed(PlayerPedId())) then
                TriggerServerEvent("police:server:UnCuffPlayer", playerId, GetEntityHeading(PlayerPedId()), GetEntityCoords(PlayerPedId()), GetEntityForwardVector(PlayerPedId())) 
            else
                BJCore.Functions.Notify("You can\'t uncuff someone in/from a vehicle", "error")
            end
        else
            BJCore.Functions.Notify("No one nearby", "error")
        end
    else
        Citizen.Wait(2000)
    end
end)

RegisterNetEvent('police:client:GetEscorted')
AddEventHandler('police:client:GetEscorted', function(playerId)
    --BJCore.Functions.GetPlayerData(function(PlayerData)
        --if PlayerData.metadata["isdead"] or isHandcuffed or PlayerData.metadata["inlaststand"] then
            if not isEscorted and IsPedInAnyVehicle(PlayerPedId(), false) then return; end
            if not isEscorted then
                isEscorted = true
                draggerId = playerId
                local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
                local heading = GetEntityHeading(dragger)
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(dragger, 0.0, 0.45, 0.0))
                AttachEntityToEntity(PlayerPedId(), dragger, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                isEscorted = false
                DetachEntity(PlayerPedId(), true, false)
            end
            TriggerEvent('hospital:client:isEscorted', isEscorted)
        --end
    --end)
end)

RegisterNetEvent('police:client:DeEscort')
AddEventHandler('police:client:DeEscort', function()
    isEscorted = false
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    DetachEntity(PlayerPedId(), true, false)
end)

RegisterNetEvent('police:client:GetKidnappedTarget')
AddEventHandler('police:client:GetKidnappedTarget', function(playerId)
    BJCore.Functions.GetPlayerData(function(PlayerData)
        --if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or isHandcuffed then
            if not isEscorted then
                isEscorted = true
                draggerId = playerId
                local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
                local heading = GetEntityHeading(dragger)
                RequestAnimDict("nm")

                while not HasAnimDictLoaded("nm") do
                    Citizen.Wait(10)
                end
                -- AttachEntityToEntity(PlayerPedId(), dragger, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                AttachEntityToEntity(PlayerPedId(), dragger, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
                TaskPlayAnim(PlayerPedId(), "nm", "firemans_carry", 8.0, -8.0, 100000, 33, 0, false, false, false)
            else
                isEscorted = false
                DetachEntity(PlayerPedId(), true, false)
                ClearPedTasksImmediately(PlayerPedId())
            end
            TriggerEvent('hospital:client:isEscorted', isEscorted)
        --end
    end)
end)

local isEscorting = false

RegisterNetEvent('police:client:GetKidnappedDragger')
AddEventHandler('police:client:GetKidnappedDragger', function(playerId)
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not isEscorting then
            draggerId = playerId
            local dragger = PlayerPedId()
            RequestAnimDict("missfinale_c2mcs_1")

            while not HasAnimDictLoaded("missfinale_c2mcs_1") do
                Citizen.Wait(10)
            end
            TaskPlayAnim(dragger, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, 100000, 49, 0, false, false, false)
            isEscorting = true
        else
            local dragger = PlayerPedId()
            ClearPedSecondaryTask(dragger)
            ClearPedTasksImmediately(dragger)
            isEscorting = false
        end
        TriggerEvent('hospital:client:SetEscortingState', isEscorting)
        TriggerEvent('kidnapping:client:SetKidnapping', isEscorting)
    end)
end)

local isRunningHandcuffCheck = false
local nextSkillcheck = 0

RegisterNetEvent('police:client:CuffFailed')
AddEventHandler('police:client:CuffFailed', function()
    BJCore.Functions.Notify('The suspect wriggled free', 'error')
    Citizen.CreateThread(function()
        local endAt = GetGameTimer() + 4000
        isDoingHandcuff = true
        while endAt > GetGameTimer() do
            if not isDoingHandcuff then
                isDoingHandcuff = true
            end
            Wait(10)
        end
        isDoingHandcuff = false
    end)
end)

RegisterNetEvent('police:client:GetCuffed')
AddEventHandler('police:client:GetCuffed', function(playerId, isSoftcuff)
    if not isHandcuffed and not isRunningHandcuffCheck then
        isHandcuffed = true
        SetEnableHandcuffs(PlayerPedId(), true)
        TriggerServerEvent("police:server:SetHandcuffStatus", true)
        ClearPedTasksImmediately(PlayerPedId())
        if Config.UseHandcuffSkillcheck and nextSkillcheck < GetGameTimer()  then
            breakoutSuccess = false
            isRunningHandcuffCheck = true
            --TriggerEvent('bj_minigames:start', 'Lockbox', { difficulty = 1, speed = 2, attempts = 1, stages = 1, stageTimeout = 10000 }, function(data)
            TriggerEvent('bj_minigames:start', 'Lockbox', {
                difficulty = math.random(Config.HandcuffSkillcheck.difficulty.min, Config.HandcuffSkillcheck.difficulty.max),
                speed = math.random(Config.HandcuffSkillcheck.speed.min, Config.HandcuffSkillcheck.speed.max),
                attempts = 1,
                stages = math.random(Config.HandcuffSkillcheck.stages.min, Config.HandcuffSkillcheck.stages.max),
                stageTimeout = Config.HandcuffSkillcheck.stageTimeout
            }, function(data)
                isRunningHandcuffCheck = false
                isHandcuffed = false
                SetEnableHandcuffs(PlayerPedId(), false)
                isEscorted = false
                TriggerEvent('hospital:client:isEscorted', isEscorted)
                DetachEntity(PlayerPedId(), true, false)
                TriggerServerEvent("police:server:SetHandcuffStatus", false)
                ClearPedTasks(PlayerPedId())
                nextSkillcheck = GetGameTimer() + Config.HandcuffSkillcheckCooldown
                BJCore.Functions.Notify("You manage to break free before the cuffs lock", "success")
                TriggerServerEvent("police:server:CuffFailed", playerId)
            end, function(data)
                isRunningHandcuffCheck = false
                nextSkillcheck = GetGameTimer() + Config.HandcuffSkillcheckCooldown
                if not isSoftcuff then
                    BJCore.Functions.Notify("You have been cuffed")
                else
                    BJCore.Functions.Notify("You have been cuffed, but you can walk")
                end
            end)
            Citizen.CreateThread(function()
                if not isSoftcuff then
                    cuffType = 16
                    GetCuffedAnimation(playerId)
                else
                    cuffType = 49
                    GetCuffedAnimation(playerId)
                end
            end)
        else
            if not isSoftcuff then
                cuffType = 16
                GetCuffedAnimation(playerId)
                BJCore.Functions.Notify("You have been cuffed")
            else
                cuffType = 49
                GetCuffedAnimation(playerId)
                BJCore.Functions.Notify("You have been cuffed, but you can walk")
            end
        end
    -- else
    --     isHandcuffed = false
    --     isEscorted = false
    --     TriggerEvent('hospital:client:isEscorted', isEscorted)
    --     DetachEntity(PlayerPedId(), true, false)
    --     TriggerServerEvent("police:server:SetHandcuffStatus", false)
    --     ClearPedTasksImmediately(PlayerPedId())
    --     BJCore.Functions.Notify("You have been uncuffed")
    end
end)

RegisterNetEvent('police:client:DoUnCuffing')
AddEventHandler('police:client:DoUnCuffing', function()
    Citizen.Wait(250)
    BJCore.Functions.LoadAnimDict('mp_arresting')
    TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
    Citizen.Wait(5500)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    isRunningHandcuffCheck = false
end)

RegisterNetEvent('police:client:GetUnCuffed')
AddEventHandler('police:client:GetUnCuffed', function(playerheading, playercoords, playerlocation)
    if isHandcuffed then
        local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
        SetEntityCoords(PlayerPedId(), x, y, z)
        SetEntityHeading(PlayerPedId(), playerheading)
        Citizen.Wait(250)
        BJCore.Functions.LoadAnimDict('mp_arresting')
        TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
        Citizen.Wait(5500)     
        isHandcuffed = false
        isEscorted = false
        TriggerEvent('hospital:client:isEscorted', isEscorted)
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("police:server:SetHandcuffStatus", false)
        ClearPedTasks(PlayerPedId())
        SetEnableHandcuffs(PlayerPedId(), false)
        BJCore.Functions.Notify("You have been uncuffed")
        isRunningHandcuffCheck = false
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         TriggerEvent("tokovoip_script:ToggleRadioTalk", isHandcuffed)
--         Citizen.Wait(2000)
--     end
-- end)

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)  
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = #(coordFrom - GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function GetClosestPedIgnoreCar()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPlayerId = -1
    local ply = PlayerPedId()
    local plyPos = GetEntityCoords(ply)
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value))
            local dist = #(targetCoords - plyPos)
            if(closestDistance == -1 or closestDistance > dist) then
                closestPlayer = target
                closestPlayerId = value
                closestDistance = dist
            end
        end
    end
    
    return closestPlayer, closestDistance, closestPlayerId
end

function IsTargetDead(playerId)
    local retval = false
    BJCore.Functions.TriggerServerCallback('police:server:isPlayerDead', function(result)
        retval = result
    end, playerId)
    Citizen.Wait(100)
    return retval
end

function HandCuffAnimation()
    isDoingHandcuff = true
    loadAnimDict("mp_arrest_paired")
    Citizen.Wait(100)
    TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    Citizen.Wait(3500)
    TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    isDoingHandcuff = false
end

function GetCuffedAnimation(playerId)
    local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
    local heading = GetEntityHeading(cuffer)
    loadAnimDict("mp_arrest_paired")
    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))
    Citizen.Wait(100)
    SetEntityHeading(PlayerPedId(), heading)
    TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0)
    Citizen.Wait(2500)
end

RegisterKeyMapping('-tackle', 'Tackle~', 'keyboard', 'GRAVE')
RegisterCommand('-tackle', function()
    if IsPedCuffed(PlayerPedId()) then return; end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return; end
    if GetEntitySpeed(PlayerPedId()) < 2.5 then return; end
    doTackle()
end, false)

timerEnabled = false
function doTackle()
    if not timerEnabled then
        local t, dist = GetClosestPlayer()
        if t and dist < 2 then
            if t ~= nil and t ~= -1 then TriggerServerEvent('tackleTarget', GetPlayerServerId(t)); end
            tackleAnim()

            timerEnabled = true
            Citizen.Wait(4500)
            timerEnabled = false
        else
            tackleAnim()
            timerEnabled = true
            Citizen.Wait(1000)
            timerEnabled = false
        end
    end
end

RegisterNetEvent('tacklePlayer')
AddEventHandler('tacklePlayer', function()
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.30)
    SetPedToRagdoll(PlayerPedId(), math.random(8500), math.random(8500), 0, 0, 0, 0)
    timerEnabled = true
    Citizen.Wait(1500)
    timerEnabled = false
end)

function tackleAnim()
    local plyPed = PlayerPedId()
    if not IsPedCuffed(plyPed) and not IsPedRagdoll(plyPed) then
        RequestAnimDict("swimming@first_person@diving")
        while not HasAnimDictLoaded("swimming@first_person@diving") do Citizen.Wait(1); end
        
        if IsEntityPlayingAnim(plyPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
            ClearPedSecondaryTask(plyPed)
        else
            TaskPlayAnim(plyPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
            count = 3
            while count > 0 do
                Citizen.Wait(100)
                count = count - 1
            end
            ClearPedSecondaryTask(plyPed)
            SetPedToRagdoll(plyPed, 150, 150, 0, 0, 0, 0) 
        end
        RemoveAnimDict("swimming@first_person@diving")
    end
end

-- local checkedVehicles = {}
-- Citizen.CreateThread(function()
--   while true do
--     Citizen.Wait(1000)
--     for k,v in pairs(checkedVehicles) do
--       if GetGameTimer() - v >= 30000 then
--         checkedVehicles[k] = nil
--       end
--     end
--   end
-- end)

-- local SeatbeltON = false
-- RegisterNetEvent("police:client:toggleSeatScan")
-- AddEventHandler("police:client:toggleSeatScan", function()
--     if validateStart() and not seatbeltCheck then
--         seatbeltCheck = true
--         if seatbeltCheck then
--             seatbeltCheckTick()
--         end
--     elseif seatbeltCheck then
--         seatbeltCheck = false
--         BJCore.Functions.Notify("Seatbelt checking disabled")
--     end
-- end)


-- function validateStart()
--   local ret = false
--   local veh = GetVehiclePedIsIn(PlayerPedId())
--   if DoesEntityExist(veh) and veh > 0 then
--     if GetVehicleClass(veh) == 18 then
--       ret = true
--     end
--   end
--   if not ret then BJCore.Functions.Notify("You must be in a police vehicle to do this", "error"); end
--   return ret
-- end

-- function seatbeltCheckTick()
--     BJCore.Functions.Notify("Seatbelt checking enabled")
--   while seatbeltCheck do
--     Citizen.Wait(3000)
--     local plyPed = PlayerPedId()
--     local vehicles = BJCore.Functions.GetVehicles()
--     for k,v in pairs(vehicles) do
--       if DoesEntityExist(v) then
--         if HasEntityClearLosToEntity(plyPed, v) then
--           if GetVehicleClass(v) ~= 18 then
--             local driver = GetPedInVehicleSeat(v, -1)
--             if driver > 0 and IsPedAPlayer(driver) then
--               local plate = GetVehicleNumberPlateText(vehicle)
--               if checkedVehicles[plate] == nil then
--                 if GetIsVehicleEngineRunning(v) and (GetEntitySpeed(v) * 2.236936) > 10 then
--                   TriggerServerEvent("police:server:requestStatus", GetPlayerServerId(NetworkGetPlayerIndexFromPed(driver)), VehToNet(v))
--                 end
--               end
--             end
--           end
--         end
--       end
--     end
--   end
-- end


-- RegisterNetEvent("police:client:getStatus")
-- AddEventHandler("police:client:getStatus", function(origin, veh)
--   if SeatbeltON then return; end
--   TriggerServerEvent("police:server:returnStatus", origin, veh)
-- end)

-- RegisterNetEvent("police:client:returnStatus")
-- AddEventHandler("police:client:returnStatus", function(veh)
--   local vehicle = NetToVeh(veh)
--   if DoesEntityExist(vehicle) then
--     local plate = GetVehicleNumberPlateText(vehicle)
--     if checkedVehicles[plate] == nil then
--       checkedVehicles[plate] = GetGameTimer()
--       local color1, color2 = GetVehicleColours(vehicle)
--       local vehCol = Config.Colors[color1] or "Unknown"
--       BJCore.Functions.Notify("Person in "..vehCol.." vehicle plate: "..plate.." is not wearing a seatbelt", 7000)
--     end
--   end
-- end)

-- RegisterNetEvent("carhud:seatbelt:client")
-- AddEventHandler("carhud:seatbelt:client",function(bool)
--     SeatbeltON = bool
-- end)
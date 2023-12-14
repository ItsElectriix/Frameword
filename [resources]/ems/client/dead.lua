local deadAnimDict = "dead"
local deadAnim = "dead_a"
local deadCarAnimDict = "veh@low@front_ps@idle_duck"
local deadCarAnim = "sit"
local hold = 5

deathTime = 0

local respawning = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerId()
        if NetworkIsPlayerActive(player) then
            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) and not InLaststand then
                SetLaststand(true)
            elseif IsEntityDead(playerPed) and InLaststand and not isDead then
                SetLaststand(false)
                local killer_2, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
                local killer = GetPedSourceOfDeath(playerPed)

                if killer_2 ~= 0 and killer_2 ~= -1 then
                    killer = killer_2
                end

                local killerId = NetworkGetPlayerIndexFromPed(killer)
                if currentDownInfo and killerId == -1 then
                    TriggerServerEvent("bj-log:server:CreateLog", "death", GetPlayerName(player) .. " ("..GetPlayerServerId(player)..") is dead", "red", "**".. GetPlayerName(player) .. "** has bled out after ".. currentDownInfo.killer .." killed with a **".. currentDownInfo.weaponLabel .. "** (" .. currentDownInfo.weaponName .. ")")
                else
                    local killerName = killerId ~= -1 and GetPlayerName(killerId) .. " " .. "("..GetPlayerServerId(killerId)..")" or "Himself or a NPC"
                    local weaponLabel = BJCore.Shared.Weapons[killerWeapon] ~= nil and BJCore.Shared.Weapons[killerWeapon]["label"] or "Unknown"
                    local weaponName = BJCore.Shared.Weapons[killerWeapon] ~= nil and BJCore.Shared.Weapons[killerWeapon]["name"] or "Unknown_Weapon"
                    TriggerServerEvent("bj-log:server:CreateLog", "death", GetPlayerName(player) .. " ("..GetPlayerServerId(player)..") is dead", "red", "**".. killerName .. "** has killed ".. GetPlayerName(player) .." with a **".. weaponLabel .. "** (" .. weaponName .. ")")
                end
                deathTime = Config.DeathTime
                OnDeath()
                DeathTimer()
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isDead or InLaststand then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, Keys['T'], true)
            EnableControlAction(0, Keys['E'], true)
            EnableControlAction(0, Keys['H'], true)
            EnableControlAction(0, Keys['V'], true)
            EnableControlAction(0, Keys['Z'], true)
            EnableControlAction(0, Keys['ESC'], true)
            --EnableControlAction(0, Keys['F1'], true)
            EnableControlAction(0, Keys['HOME'], true)
            EnableControlAction(0, 249, true)
            local text
            
            if isDead then
                if not isInHospitalBed then 
                    local mins, secs = secondsToClock(deathTime)
                    if not respawning then 
                        if deathTime > 0 then
                            text = "Respawn available in ~b~"..mins..'~s~ minutes ~b~'..secs..'~s~ seconds'
                            --DrawTxt(0.93, 1.44, 1.0,1.0,0.6, "RESPAWN IN: ~r~" .. math.ceil(deathTime) .. "~w~ SECONDS", 255, 255, 255, 255)
                        else
                            text = "Hold [~b~H~w~] for ("..hold..") seconds to respawn"
                           -- DrawTxt(0.865, 1.44, 1.0, 1.0, 0.6, "~w~ HOLD ~r~[E] ("..hold..")~w~ TO RESPAWN ~r~("..BJCore.Config.Currency.Symbol..Config.BillCost..")~w~", 255, 255, 255, 255)
                        end
                    else
                        text = "Respawning... (NLR)"
                    end
                end

                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    loadAnimDict("veh@low@front_ps@idle_duck")
                    if not IsEntityPlayingAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 3) then
                        TaskPlayAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                    end
                else
                    if isInHospitalBed then 
                        if not IsEntityPlayingAnim(PlayerPedId(), inBedDict, inBedAnim, 3) then
                            loadAnimDict(inBedDict)
                            TaskPlayAnim(PlayerPedId(), inBedDict, inBedAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    else
                        if not IsEntityPlayingAnim(PlayerPedId(), deadAnimDict, deadAnim, 3) then
                            loadAnimDict(deadAnimDict)
                            TaskPlayAnim(PlayerPedId(), deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    end
                end

                SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
            elseif InLaststand then
                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(0, Keys['T'], true)
                EnableControlAction(0, Keys['E'], true)
                EnableControlAction(0, Keys['H'], true)            
                EnableControlAction(0, Keys['V'], true)
                EnableControlAction(0, Keys['Z'], true)
                EnableControlAction(0, Keys['ESC'], true)
                --EnableControlAction(0, Keys['F1'], true)
                EnableControlAction(0, Keys['HOME'], true)
                EnableControlAction(0, 249, true)
                local mins, secs = secondsToClock(LaststandTime)
                if LaststandTime > Laststand.MinimumRevive then
                    text = "You will bleed out in ~r~"..mins..'~s~ minutes ~r~'..secs..'~s~ seconds'
                    --DrawTxt(0.94, 1.44, 1.0, 1.0, 0.6, "YOU ARE BLEEDING OUT IN: ~r~" .. math.ceil(LaststandTime) .. "~w~ SECONDS", 255, 255, 255, 255)
                else
                    text = "You will bleed out in ~r~"..mins..'~s~ minutes ~r~'..secs.."~s~ seconds \nYou can now be helped up"
                    --DrawTxt(0.845, 1.44, 1.0, 1.0, 0.6, "YOU ARE BLEEDING OUT IN: ~r~" .. math.ceil(LaststandTime) .. "~w~ SECONDS, YOU CAN BE HELPED", 255, 255, 255, 255)
                end

                if not isEscorted then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        loadAnimDict("veh@low@front_ps@idle_duck")
                        if not IsEntityPlayingAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 3) then
                            TaskPlayAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    else
                        loadAnimDict(lastStandDict)
                        if not IsEntityPlayingAnim(PlayerPedId(), lastStandDict, lastStandAnim, 3) then
                            TaskPlayAnim(PlayerPedId(), lastStandDict, lastStandAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    end
                else
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        loadAnimDict("veh@low@front_ps@idle_duck")
                        if IsEntityPlayingAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 3) then
                            StopAnimTask(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 3)
                        end
                    else
                        loadAnimDict(lastStandDict)
                        if IsEntityPlayingAnim(PlayerPedId(), lastStandDict, lastStandAnim, 3) then
                            StopAnimTask(PlayerPedId(), lastStandDict, lastStandAnim, 3)
                        end
                    end
                end
            end
            DrawGenericTextThisFrame()

            SetTextEntry('STRING')
            AddTextComponentString(text)
            DrawText(0.5, 0.8)
        else
            Citizen.Wait(500)
        end
    end
end)

function OnDeath(spawn)
    if not isDead then
        isDead = true
        StartScreenEffect('DeathFailMPIn', 0, true)
        TriggerServerEvent("hospital:server:SetDeathStatus", true)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
        local player = PlayerPedId()

        while GetEntitySpeed(player) > 0.5 or IsPedRagdoll(player) do
            Citizen.Wait(10)
        end

        if isDead then
            local pos = GetEntityCoords(player)
            local heading = GetEntityHeading(player)

            local inVeh, seat, vehicle = IsPedInAnyVehicle(player), -1, nil
            if inVeh then
                vehicle = GetVehiclePedIsIn(player)
                for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1, 1 do
                    local sPed = GetPedInVehicleSeat(vehicle, i)
                    if sPed == player then
                        seat = i
                        break
                    end
                end
            end

            NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
            SetEntityInvincible(player, true)
            SetEntityHealth(player, GetEntityMaxHealth(player))
            if inVeh then SetPedIntoVehicle(player, vehicle, seat); end
            if IsPedInAnyVehicle(player, false) then
                loadAnimDict("veh@low@front_ps@idle_duck")
                TaskPlayAnim(player, "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            else
                loadAnimDict(deadAnimDict)
                TaskPlayAnim(player, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            end
            TriggerEvent("hospital:client:AiCall")
        end
    end
end

function DeathTimer()
    hold = 5
    TriggerEvent('ems:deathcheck', true)
    TriggerEvent("radio:onRadioDrop")
    TriggerServerEvent("BJCore:SetPlayerStateBag", GetPlayerServerId(PlayerId()), "InLaststand", true)
    --LocalPlayer.state.InLaststand = InLaststand
    while isDead do
        Citizen.Wait(1000)
        deathTime = deathTime - 1
        if deathTime <= 0 then
            if IsControlPressed(0, Keys["H"]) and hold <= 0 and not isInHospitalBed and not respawning then
                respawning = true
                Wait(2000)
                DoScreenFadeOut(4000)
                Wait(4000)
                respawning = false
                TriggerEvent("hospital:client:RespawnAtHospital")
                hold = 5
            end

            if IsControlPressed(0, Keys["H"]) then
                if hold - 1 >= 0 then
                    hold = hold - 1
                else
                    hold = 0
                end
            end

            if IsControlReleased(0, Keys["H"]) then
                hold = 5
            end
        end        
        -- if deathTime == 0 then
        --     TriggerEvent("hospital:client:RespawnAtHospital")
        -- end
    end
    TriggerEvent('ems:deathcheck', false)
end

function secondsToClock(seconds)
    local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

    if seconds <= 0 then
        return 0, 0
    else
        local hours = string.format('%02.f', math.floor(seconds / 3600))
        local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))
        return mins, secs
    end
end

function DrawTxt(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function DrawGenericTextThisFrame()
    SetTextFont(4)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
end
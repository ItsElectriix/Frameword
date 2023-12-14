BJCore = nil

Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

-- Config

Laststand = Laststand or {}
Laststand.ReviveInterval = 300
Laststand.MinimumRevive = 240

-- Code

InLaststand = false
TriggerServerEvent("BJCore:SetPlayerStateBag", GetPlayerServerId(PlayerId()), "InLaststand", InLaststand)
--LocalPlayer.state.InLaststand = InLaststand
CanBePickuped = false
LaststandTime = 0

lastStandDict = "combat@damage@writhe"
lastStandAnim = "writhe_loop"

isEscorted = false
isEscorting = false

currentDownInfo = nil

lastDamageEntity = nil

RegisterNetEvent('hospital:client:SetEscortingState')
AddEventHandler('hospital:client:SetEscortingState', function(bool)
    isEscorting = bool
end)

RegisterNetEvent('hospital:client:isEscorted')
AddEventHandler('hospital:client:isEscorted', function(bool)
    isEscorted = bool
end)

AddEventHandler('gameEventTriggered', function(name, args)
	if name == 'CEventNetworkEntityDamage' then
		if #args >= 5 and args[1] == PlayerPedId() then
			lastDamageEntity = args[5]
		end
	end
end)

function SetLaststand(bool, spawn)
    local ped = PlayerPedId()
    if bool then
        StartScreenEffect('DeathFailNeutralIn', 0, true)
        Wait(1000)
        local pos = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        while GetEntitySpeed(ped) > 0.5 or IsPedRagdoll(ped) do
            Citizen.Wait(10)
        end

        TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)

        LaststandTime = Laststand.ReviveInterval

        local player = PlayerId()
        local killer_2, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
        local killer = GetPedSourceOfDeath(ped)
        if killer_2 ~= 0 and killer_2 ~= -1 then
            killer = killer_2
        elseif lastDamageEntity then
            killerWeapon = lastDamageEntity
        end

        local inVeh, seat, vehicle = IsPedInAnyVehicle(ped), -1, nil
        if inVeh then
            vehicle = GetVehiclePedIsIn(ped)
            for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1, 1 do
                local sPed = GetPedInVehicleSeat(vehicle, i)
                if sPed == ped then
                    seat = i
                    break
                end
            end
        end

        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
        SetEntityHealth(ped, 150)
        if inVeh then SetPedIntoVehicle(ped, vehicle, seat); end
        if IsPedInAnyVehicle(ped, false) then
            LoadAnimation("veh@low@front_ps@idle_duck")
            TaskPlayAnim(ped, "veh@low@front_ps@idle_duck", "sit", 1.0, 8.0, -1, 1, -1, false, false, false)
        else
            LoadAnimation(lastStandDict)
            TaskPlayAnim(ped, lastStandDict, lastStandAnim, 1.0, 8.0, -1, 1, -1, false, false, false)
        end

        InLaststand = true
        TriggerServerEvent("BJCore:SetPlayerStateBag", GetPlayerServerId(PlayerId()), "InLaststand", InLaststand)
        --LocalPlayer.state.InLaststand = InLaststand

        Citizen.CreateThread(function()
            while InLaststand do
                if LaststandTime - 1 > Laststand.MinimumRevive then
                    LaststandTime = LaststandTime - 1
                    --Config.DeathTime = LaststandTime
                elseif LaststandTime - 1 <= Laststand.MinimumRevive and LaststandTime - 1 ~= 0 then
                    LaststandTime = LaststandTime - 1
                    CanBePickuped = true
                    --Config.DeathTime = LaststandTime
                elseif LaststandTime - 1 <= 0 then
                    BJCore.Functions.Notify("You have bled out", "error")
                    SetLaststand(false)
                    deathTime = Config.DeathTime
                    OnDeath()
                    DeathTimer()
                end
                Citizen.Wait(1000)
            end
        end)

        local killerId = NetworkGetPlayerIndexFromPed(killer)
        local weaponLabel = BJCore.Shared.Weapons[killerWeapon] ~= nil and BJCore.Shared.Weapons[killerWeapon]["label"] or "Unknown"
        local weaponName = BJCore.Shared.Weapons[killerWeapon] ~= nil and BJCore.Shared.Weapons[killerWeapon]["name"] or "Unknown_Weapon"

        if IsEntityAVehicle(killer) then
            weaponLabel = "Vehicle"
            weaponName = GetDisplayNameFromVehicleModel(GetEntityModel(killer))
            killer = GetPedInVehicleSeat(killer, -1)
            killerId = NetworkGetPlayerIndexFromPed(killer)
        end

        local killerName = killerId ~= -1 and GetPlayerName(killerId) .. " " .. "("..GetPlayerServerId(killerId)..")" or "Himself or a NPC"

        currentDownInfo = {
            killer = killerName,
            weaponLabel = weaponLabel,
            weaponName = weaponName
        }
        TriggerServerEvent("bj-log:server:CreateLog", "death", GetPlayerName(player) .. " ("..GetPlayerServerId(player)..") is down", "red", "**".. killerName .. "** has killed  ".. GetPlayerName(player) .." with a **".. weaponLabel .. "** (" .. weaponName .. ")")
    else
        StopScreenEffect('DeathFailNeutralIn')
        TaskPlayAnim(ped, lastStandDict, "exit", 1.0, 8.0, -1, 1, -1, false, false, false)
        InLaststand = false
        CanBePickuped = false
        LaststandTime = 0
    end
    TriggerServerEvent("hospital:server:SetLaststandStatus", bool)
end

function LoadAnimation(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(100)
    end
end

RegisterNetEvent('hospital:client:UseFirstAid')
AddEventHandler('hospital:client:UseFirstAid', function()
    if not isEscorting then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            local playerId = GetPlayerServerId(player)
            TriggerServerEvent('hospital:server:UseFirstAid', playerId)
        end
    else
        BJCore.Functions.Notify('Can\'t do this while escorted', 'error')
    end
end)

RegisterNetEvent('hospital:client:CanHelp')
AddEventHandler('hospital:client:CanHelp', function(helperId)
    if InLaststand then
        --if LaststandTime <= 300 then
        if CanBePickuped then
            TriggerServerEvent('hospital:server:CanHelp', helperId, true)
        else
            TriggerServerEvent('hospital:server:CanHelp', helperId, false)
        end
    else
        TriggerServerEvent('hospital:server:CanHelp', helperId, false)
    end
end)

RegisterNetEvent('hospital:client:HelpPerson')
AddEventHandler('hospital:client:HelpPerson', function(targetId)
    local ped = PlayerPedId()
    isHealingPerson = true
    exports['mythic_progbar']:Progress({
        name = "revive_help",
        duration = math.random(45000, 60000),
        label = "Reviving person",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = healAnimDict,
            anim = healAnim,
            flags = 1,
        },        
    }, function(status)
        if not status then
            isHealingPerson = false
            ClearPedTasks(ped)
            BJCore.Functions.Notify("You helped up a person")
            TriggerServerEvent("BJCore:Server:RemoveItem", "firstaid", 1)
            TriggerServerEvent("hospital:server:RevivePlayer", targetId)
        else
            isHealingPerson = false
            ClearPedTasks(ped)
            BJCore.Functions.Notify("Cancelled", "error")     
        end
    end)
end)

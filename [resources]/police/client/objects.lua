local ObjectList = false
local SpawnedObjects = {}

RegisterNetEvent('police:client:spawnCone')
AddEventHandler('police:client:spawnCone', function()
    exports['mythic_progbar']:Progress({
        name = "spawn_object",
        duration = 2500,
        label = "Placing object",
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
            local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
            local forward = GetEntityForwardVector(PlayerPedId())
            TriggerServerEvent("police:server:spawnObject", "cone", coords, heading, forward)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent('police:client:spawnBarrier')
AddEventHandler('police:client:spawnBarrier', function()
    exports['mythic_progbar']:Progress({
        name = "spawn_object",
        duration = 2500,
        label = "Placing object",
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
            local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
            local forward = GetEntityForwardVector(PlayerPedId())
            TriggerServerEvent("police:server:spawnObject", "barier", coords, heading, forward)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent('police:client:spawnSign')
AddEventHandler('police:client:spawnSign', function()
    exports['mythic_progbar']:Progress({
        name = "spawn_object",
        duration = 2500,
        label = "Placing object",
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
            local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
            local forward = GetEntityForwardVector(PlayerPedId())
            TriggerServerEvent("police:server:spawnObject", "schotten", coords, heading, forward)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent('police:client:spawnTent')
AddEventHandler('police:client:spawnTent', function()
    exports['mythic_progbar']:Progress({
        name = "spawn_object",
        duration = 2500,
        label = "Placing object",
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
            local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
            local forward = GetEntityForwardVector(PlayerPedId())
            TriggerServerEvent("police:server:spawnObject", "tent", coords, heading, forward)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent('police:client:spawnLight')
AddEventHandler('police:client:spawnLight', function()
    local coords = GetEntityCoords(PlayerPedId())
    exports['mythic_progbar']:Progress({
        name = "spawn_object",
        duration = 2500,
        label = "Placing object",
        useWhileDead = true,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "anim@narcotics@trash",
            anim = "drop_front",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
            local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
            local forward = GetEntityForwardVector(PlayerPedId())
            TriggerServerEvent("police:server:spawnObject", "light", coords, heading, forward)
        else
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
        end
    end)
end)

RegisterNetEvent('police:client:deleteObject')
AddEventHandler('police:client:deleteObject', function()
    local objectId, dist = GetClosestPoliceObject()
    if objectId == nil or dist == nil then return; end
    if dist < 5.0 then
        exports['mythic_progbar']:Progress({
            name = "remove_object",
            duration = 2500,
            label = "Removing object",
            useWhileDead = true,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                anim = "plant_floor",
                flags = 16,
            },
        }, function(status)
            if not status then
                StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)
                TriggerServerEvent("police:server:deleteObject", objectId)
            else
                StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)
                BJCore.Functions.Notify("Cancelled", "error")
            end
        end)
    end
end)

RegisterNetEvent('police:client:removeObject')
AddEventHandler('police:client:removeObject', function(objectId)
    local rList = {}
    for k,v in pairs(SpawnedObjects) do
        if v and v.id and v.id == objectId then
            if DoesEntityExist(v.obj) then
                DeleteObject(v.obj)
            end
            table.insert(rList,k)
        end
    end
    for k,v in pairs(rList) do SpawnedObjects[v] = nil; ObjectList[v] = nil; end
end)

RegisterNetEvent('police:client:syncObject')
AddEventHandler('police:client:syncObject', function(data)
    ObjectList = data
end)

Citizen.CreateThread(function()
    TriggerServerEvent("police:server:GetObjectData")
    while not ObjectList do Citizen.Wait(500); end
    while true do
        local nearby = false
        local closestObject,closestDist = GetClosestPoliceObject2()

        if closestDist and closestDist < 50 then nearby = true; end
        if not nearby then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
end)

function GetClosestPoliceObject2()
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local closest,closestDist
    for k,v in pairs(ObjectList) do
        local dist = #(plyPos.xyz - v.coords.xyz)
        if (not closestDist or dist < closestDist) then
            closest = v
            closestDist = dist
        end
        if dist <= 75 and not SpawnedObjects[k] then
            local obj = CreateObject(v.model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
            PlaceObjectOnGroundProperly(obj)
            SetEntityHeading(obj, v.coords.w)
            FreezeEntityPosition(obj, Config.Objects[v.type].freeze)
            SpawnedObjects[k] = { obj = obj, id = v.id }
        elseif dist > 75 and SpawnedObjects[k] then
            DeleteObject(SpawnedObjects[k].obj)
            SpawnedObjects[k] = false
        end
    end
    if closestDist then return closest,closestDist
    else return false,999999
    end
end

function GetClosestPoliceObject()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, data in pairs(ObjectList) do
        if current ~= nil then
            if #(pos.xyz - ObjectList[id].coords.xyz) < dist then
                current = id
                dist = #(pos.xyz - ObjectList[id].coords.xyz)
            end
        else
            dist = #(pos.xyz - ObjectList[id].coords.xyz)
            current = id
        end
    end
    return current, dist
end

local SpikeConfig = {
    MaxSpikes = 5
}
local SpawnedSpikes = {}
local spikemodel = "P_ld_stinger_s"
local nearSpikes = false
local spikesSpawned = false
local ClosestSpike = nil

Citizen.CreateThread(function()
    TriggerServerEvent("police:server:RequestSpikes")
    while true do
        if isLoggedIn then
            GetClosestSpike()
        end

        Citizen.Wait(500)
    end
end)

function GetClosestSpike()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil

    for id, data in pairs(SpawnedSpikes) do
        if current ~= nil then
            if(#(pos - vector3(SpawnedSpikes[id].coords.x, SpawnedSpikes[id].coords.y, SpawnedSpikes[id].coords.z)) < dist)then
                current = id
            end
        else
            dist = #(pos - vector3(SpawnedSpikes[id].coords.x, SpawnedSpikes[id].coords.y, SpawnedSpikes[id].coords.z))
            current = id
        end
    end
    ClosestSpike = current
end

RegisterNetEvent('police:client:SpawnSpikeStrip')
AddEventHandler('police:client:SpawnSpikeStrip', function()
    if #SpawnedSpikes + 1 < SpikeConfig.MaxSpikes then
        if PlayerJob.name == "police" and PlayerJob.onduty then
            local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
            local spike = CreateObject(GetHashKey(spikemodel), spawnCoords.x, spawnCoords.y, spawnCoords.z, 1, 1, 1)
            local netid = NetworkGetNetworkIdFromEntity(spike)
            --SetNetworkIdExistsOnAllMachines(netid, true)
            --SetNetworkIdCanMigrate(netid, true)
            SetEntityHeading(spike, GetEntityHeading(PlayerPedId()))
            PlaceObjectOnGroundProperly(spike)
            local newSpike = {
                coords = {
                    x = spawnCoords.x,
                    y = spawnCoords.y,
                    z = spawnCoords.z,
                },
                netid = netid,
                object = spike,
            }
            print("new spike: "..BJCore.Common.Dump(newSpike))
            spikesSpawned = true
            TriggerServerEvent('police:server:AddSpikes', newSpike)
        end
    else
        BJCore.Functions.Notify('Max spike strips spawned', 'error')
    end
end)

RegisterNetEvent('police:client:SyncSpikes')
AddEventHandler('police:client:SyncSpikes', function(data)
    SpawnedSpikes = data
    ClosestSpike = nil
    print("sync spike: "..BJCore.Common.Dump(SpawnedSpikes))
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            if ClosestSpike ~= nil then
                local tires = {
                    {bone = "wheel_lf", index = 0},
                    {bone = "wheel_rf", index = 1},
                    {bone = "wheel_lm", index = 2},
                    {bone = "wheel_rm", index = 3},
                    {bone = "wheel_lr", index = 4},
                    {bone = "wheel_rr", index = 5}
                }

                for a = 1, #tires do
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
                    local spike = GetClosestObjectOfType(tirePos.x, tirePos.y, tirePos.z, 15.0, GetHashKey(spikemodel), 1, 1, 1)
                    local spikePos = GetEntityCoords(spike, false)
                    local distance = Vdist(tirePos.x, tirePos.y, tirePos.z, spikePos.x, spikePos.y, spikePos.z)

                    if distance < 1.8 then
                        if not IsVehicleTyreBurst(vehicle, tires[a].index, true) or IsVehicleTyreBurst(vehicle, tires[a].index, false) then
                            SetVehicleTyreBurst(vehicle, tires[a].index, false, 1000.0)
                        end
                    end
                end
            else
                Citizen.Wait(250)
            end
        end

        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            if PlayerJob.name == "police" and PlayerJob.onduty then
                if ClosestSpike ~= nil then
                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    local dist = #(pos - vector3(SpawnedSpikes[ClosestSpike].coords.x, SpawnedSpikes[ClosestSpike].coords.y, SpawnedSpikes[ClosestSpike].coords.z))

                    if dist < 4 then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            BJCore.Functions.DrawText3D(pos.x, pos.y, pos.z, '[~g~E~w~] Delete Spike')
                            if IsControlJustPressed(0, Keys["E"]) then
                                --NetworkRegisterEntityAsNetworked(SpawnedSpikes[ClosestSpike].object)
                                --NetworkRequestControlOfEntity(SpawnedSpikes[ClosestSpike].object)
                                --SetEntityAsMissionEntity(SpawnedSpikes[ClosestSpike].object)
                                --DeleteEntity(SpawnedSpikes[ClosestSpike].object)
                                TriggerServerEvent("BJCore:RequestEntityDelete", SpawnedSpikes[ClosestSpike].netid)
                                table.remove(SpawnedSpikes, ClosestSpike)
                                ClosestSpike = nil
                                TriggerServerEvent('police:server:RemoveSpikes', ClosestSpike)
                            end
                        end
                    end
                else
                    Citizen.Wait(500)
                end
            else
                Citizen.Wait(500)
            end
        end
        Citizen.Wait(3)
    end
end)

RegisterNetEvent("police:client:DeploySpikeStrips", function()
    BJCore.Functions.LoadAnimDict("p_ld_stinger_s")
    BJCore.Functions.LoadAnimDict("mp_weapons_deal_sting")
    RequestScriptAudioBank("BIG_SCORE_HIJACK_01", false, -1)
    TaskPlayAnim(PlayerPedId(), "mp_weapons_deal_sting", "crackhead_bag_loop", -1.0, 0.925, 0.825, 16, 0, 0, 0, 0 )
    local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
    local spikeObj = CreateObject(GetHashKey(spikemodel), spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
    SetEntityHeading(spikeObj, GetEntityHeading(PlayerPedId()))
    PlaceObjectOnGroundProperly(spikeObj)
    PlayEntityAnim(spikeObj, "P_Stinger_S_Deploy", "p_ld_stinger_s", 1000.0, false, true, 0, 0.0, 0)
    while not IsEntityPlayingAnim(spikeObj, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) do
        PlayEntityAnim(spikeObj, "P_Stinger_S_Deploy", "p_ld_stinger_s", 1000.0, false, true, 0, 0.0, 0)
        Wait(0)
    end
    while IsEntityPlayingAnim(spikeObj, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) and GetEntityAnimCurrentTime(spikeObj, "p_ld_stinger_s", "P_Stinger_S_Deploy") <= 0.99 do
        Wait(0)
    end
    PlayEntityAnim(spikeObj, "p_stinger_s_idle_deployed", "p_ld_stinger_s", 1000.0, false, true, 0, 0.99, 0)
    PlaySoundFromEntity(1, "DROP_STINGER", spikeObj, "BIG_SCORE_3A_SOUNDS", 0, 0)
    DeleteObject(spikeObj)
    print("sent to sync")
    TriggerEvent("police:client:SpawnSpikeStrip")
end)
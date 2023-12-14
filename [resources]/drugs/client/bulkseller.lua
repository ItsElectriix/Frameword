SpawnedBulkSellPed = nil
insideBulkSeller = false

local StartPos = vector4(84.137275, 190.635, 105.26721, 251.26611)
local ReqItem = "deliverylist"
local BoatSpawn = vector4(1188.7357, -2895.045, 0.2846865, 84.40715)
local InsideWeedInteract = vector3(-3.98, -3.847, 2.02)
local IslandPos = vector3(4946.289, -5156.02, 0.1240868)
local DeliverPos = vector3(5003.226, -5149.834, 2.5804238)

local AiSpawnLocations = {
    [1] = {
        pos = vector4(1198.7634, -2903.267, 5.943933, 114.59474)
    },
    [2] = {
        pos = vector4(1195.5983, -2901.791, 5.902111, 148.58976),
    },
    [3] = {
        pos = vector4(1185.8422, -2902.764, 5.90211, 175.36941),
    },
    [4] = {
        pos = vector4(1175.1425, -2915.615, 5.9021105, 32.847553),
    },
    [5] = {
        pos = vector4(1178.9014, -2904.71, 5.90211, 322.94219),
    },
    [6] = {
        pos = vector4(1198.1685, -2902.865, 5.9021081, 283.3757),
    },
    [7] = {
        pos = vector4(1210.9598, -2904.006, 5.8660488, 275.62341),
    },
    [8] = {
        pos = vector4(1218.2794, -2910.702, 5.8812012, 223.90438),
    },
    [9] = {
        pos = vector4(1227.2489, -2908.666, 13.333106, 104.47098),
    },

}

local ShellObjects = {}
Citizen.CreateThread(function()
    while true do
        local nearby = false
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local LastPressed = 0
        if #(plyPos.xyz - StartPos.xyz) < 20 then
            if SpawnedBulkSellPed == nil or not DoesEntityExist(SpawnedBulkSellPed) then
                CreateBulkPed(StartPos)
            end
            if #(plyPos.xyz - StartPos.xyz) < 10 then
                nearby = true
                if #(plyPos.xyz - StartPos.xyz) < 1.6 then
                    local hour = GetClockHours()
                    BJCore.Functions.DrawText3D(StartPos.x,StartPos.y,StartPos.z+1,"[~r~E~s~] Talk")
                    if IsControlJustReleased(0, Keys["E"]) and GetGameTimer() - LastPressed > 1000 then
                        LastPressed = GetGameTimer()
                        if (hour >= 21 or hour < 5) then
                            ClearPedTasks(SpawnedBulkSellPed)
                            Wait(3000)
                            TaskStartScenarioInPlace(SpawnedBulkSellPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
                            Wait(math.random(5000, 8000))
                            BJCore.Functions.TriggerServerCallback("crim:server:getRep", function(rep)
                                if rep and rep >= 100 then
                                    BJCore.Functions.TriggerServerCallback("BJCore:HasItem", function(hasItem)
                                        if hasItem then
                                            BJCore.Functions.Notify("Come through", "primary")
                                            ShellObjects = exports["interior"]:CreateWeed(vector3(StartPos.x,StartPos.y,StartPos.z-50))
                                            TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_open', 0.6)
                                            -- create interior
                                            insideBulkSeller = true
                                            doBulkSellRoom()
                                        else
                                            BJCore.Functions.Notify("It seems like you're missing something. I can't let you in until you have it", "error", 5000)
                                            Wait(500)
                                            ClearPedTasks(SpawnedBulkSellPed)
                                            Wait(2500)
                                            TaskGoStraightToCoord(SpawnedBulkSellPed, StartPos.xyz, 1.0, -1, StartPos.w, 2.0)
                                            Wait(1000)
                                            TaskStartScenarioInPlace(SpawnedBulkSellPed, 'WORLD_HUMAN_LEANING', 0, true)
                                        end
                                    end, ReqItem)
                                else
                                    BJCore.Functions.Notify("I've never heard of you. Come back when you're better known on the streets", "error", 10000)
                                    Wait(500)
                                    ClearPedTasks(SpawnedBulkSellPed)
                                    Wait(2500)
                                    TaskGoStraightToCoord(SpawnedBulkSellPed, StartPos.xyz, 1.0, -1, StartPos.w, 2.0)
                                    Wait(1000)
                                    TaskStartScenarioInPlace(SpawnedBulkSellPed, 'WORLD_HUMAN_LEANING', 0, true)
                                end
                            end, 'dealerrep')
                        else
                            BJCore.Functions.Notify("Come back later. It's too bait rn", "error")
                        end
                    end
                end
            end
        else
            if DoesEntityExist(SpawnedBulkSellPed) then
                DeleteEntity(SpawnedBulkSellPed)
                SpawnedBulkSellPed = nil
            end
        end
        if not nearby then Citizen.Wait(1000); end
        Citizen.Wait(1)
    end
end)

function CreateBulkPed(pos)
    local modelHash = `a_m_y_stlat_01`
    while not HasModelLoaded(modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
    SpawnedBulkSellPed = CreatePed(4, modelHash, pos, false, true)
    TaskStartScenarioInPlace(SpawnedBulkSellPed, 'WORLD_HUMAN_LEANING', 0, true)
    SetEntityAsMissionEntity(SpawnedBulkSellPed, true, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetBlockingOfNonTemporaryEvents(SpawnedBulkSellPed, true)
    SetEntityInvincible(SpawnedBulkSellPed, true)
end

local BulkStage = 0
local interacting = false
function doBulkSellRoom()
    local exit = vector3(StartPos.x + ShellObjects[2].exit.x, StartPos.y + ShellObjects[2].exit.y, StartPos.z-50)
    local laptop = vector3(StartPos.x + InsideWeedInteract.x, StartPos.y + InsideWeedInteract.y, (StartPos.z-50) + InsideWeedInteract.z)
    while insideBulkSeller do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        if not interacting then
            if #(plyPos - exit) < 2.0 then
                BJCore.Functions.DrawText3D(exit.x, exit.y, exit.z+1.0, "[~r~E~s~] Exit")
                if IsControlJustReleased(0, Keys["E"]) then
                    FreezeEntityPosition(PlayerPedId(), true)
                    DoScreenFadeOut(250)
                    Wait(250)
                    exports["interior"]:DespawnInterior(ShellObjects[1], function()
                        TriggerEvent('InteractSound_CL:PlayOnOne', 'houses_door_close', 0.5)
                        SetEntityCoords(PlayerPedId(), -158.5106, -53.95657, 54.396121)
                        SetEntityHeading(PlayerPedId(), 93.29)
                        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0); end
                        FreezeEntityPosition(PlayerPedId(), false)
                        DoScreenFadeIn(250)
                        insideBulkSeller = false
                    end)
                end
            end
            if #(plyPos - laptop) < 20 then
                DrawMarker(2, laptop.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, true, false, false, false, false, false, false)
                if #(plyPos - laptop) < 2 then
                    BJCore.Functions.DrawText3D(laptop.x, laptop.y, laptop.z, "[~r~E~s~] Bulk Sale")
                    if IsControlJustPressed(0, 38) and BulkStage == 0 then
                        exports['mythic_progbar']:Progress({
                            name = "bulksale_order",
                            duration = math.random(5000, 7000),
                            label = "Processing order",
                            useWhileDead = false,
                            canCancel = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "anim@heists@prison_heistig1_p1_guard_checks_bus",
                                anim = "loop",
                                flags = 16,
                            }
                        }, function(status)
                            if not status then
                                BJCore.Functions.TriggerServerCallback("bulksale:server:getitems", function(bulksale)
                                    if bulksale then
                                        TriggerServerEvent("BJCore:Server:RemoveItem", ReqItem, 1)
                                        TriggerEvent("inventory:client:ItemBox", BJCore.Shared.Items[ReqItem], "remove")
                                        BulkStage = 1
                                        BJCore.Functions.Notify("Request sent. Await email confirmation", "success", 4000)
                                        randomDelay = math.random(15000, 25000)
                                        SetTimeout(randomDelay, function()
                                            TriggerServerEvent('phone:server:sendNewMail', {
                                                sender = "Unknown",
                                                subject = "Re: Wholesale delivery",
                                                message = "We've processed your wholesale delivery request. A boat is waiting for you at the docks. You'll find the keys in the ignition (Press tick button to set gps location). <br />We've had reports of deliveries being attacked by gangs in the area. Stay safe.<br /><br />Good luck.",
                                                button = {
                                                    enabled = true,
                                                    buttonEvent = "crim:bulksale:SetBoatMarker",
                                                }
                                            })
                                            CollectBoat()
                                        end)
                                    else
                                        BJCore.Functions.Notify("You have nothing to sell", "error")
                                    end
                                end)
                            else
                                BJCore.Functions.Notify("Cancelled", "error")
                            end
                        end)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end

AddEventHandler("crim:bulksale:SetBoatMarker", function()
    SetNewWaypoint(1188.7357, -2895.045)
    BJCore.Functions.PersistentNotify("start", "collectboat", "Use the boat waiting for you at the docks to get to the delivery location", "primary")
end)

RegisterCommand("collectboat", function()
    BulkStage = 1
    CollectBoat()
end)

function CollectBoat()
    local createdBoat = false
    local taskcombat = false
    local createPeds = false
    while BulkStage == 1 do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local dist = #(plyPos - BoatSpawn.xyz)
        if dist < 100 then
            if not createPeds then
                createPeds = true
                CreateKillSquad()
            end
            -- if not taskcombat and dist < 50 then
            --     taskcombat = true
            --     for k,v in pairs(CreatedAi) do
            --         TaskCombatPed(v, PlayerPedId(), 0, 16)
            --     end
            -- end
            if not createdBoat then
                BJCore.Functions.SpawnVehicle("dinghy", function(cbVeh)
                    createdBoat = cbVeh
                    exports['legacyfuel']:SetFuel(cbVeh,100)
                    SetEntityAsMissionEntity(cbVeh, true, true)
                    SetNetworkIdCanMigrate(VehToNet(cbVeh), true)
                    TriggerEvent('keys:addNew', cbVeh, GetVehicleNumberPlateText(cbVeh))
                end, BoatSpawn, true)
            end
            if IsPedInAnyVehicle(plyPed, false) then
                if GetVehiclePedIsIn(plyPed, false) == createdBoat then
                    BJCore.Functions.PersistentNotify("end", "collectboat")
                    BulkStage = 2
                    DriveToIsland()
                end
            end
        end
        Citizen.Wait(0)
    end
end

function DriveToIsland()
    BJCore.Functions.PersistentNotify("start", "gotoisland", "Go to the location marked on your map", "primary")
    SetNewWaypoint(4946.289, -5156.02)
    local startcount = GetGameTimer()
    local lastpress = 0
    local polnotif = false
    while (BulkStage == 2 or BulkStage == 3) do
        if BulkStage == 2 then
            if GetGameTimer() - startcount >= 15000 then
                if not polnotif then
                    polnotif = true
                    TriggerServerEvent('MF_Trackables:Notify','Coastguard: Possible Smuggling - Cayo Perico', IslandPos.xyz,'police','deliverdrugs')
                end
            end
        end
        if not IsWaypointActive() then
            if BulkStage == 2 then
                SetNewWaypoint(4946.289, -5156.02)
            elseif BulkStage == 3 then
                SetNewWaypoint(5003.226, -5149.834)
            end
        end
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        if BulkStage == 2 then
            local dist = #(plyPos - IslandPos.xyz)
            local notifiedOutBoat = false
            if dist < 5 then
                if not notifiedOutBoat then
                    notifiedOutBoat = true
                    BJCore.Functions.PersistentNotify("start", "island1", "Leave the boat here and head to the warehouse marked on your map", "primary")
                    SetNewWaypoint(5003.226, -5149.834)
                    BulkStage = 3
                end

            else
                if dist > 30 then
                    Citizen.Wait(500)
                end
            end
        else
            BJCore.Functions.PersistentNotify("end", "gotoisland")
            local dist = #(plyPos - DeliverPos.xyz)
            local notifiedDeliver = false
            if dist < 25 then
                DrawMarker(2, DeliverPos.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, true, false, false, false, false, false, false)
                if dist < 2 then
                    BJCore.Functions.DrawText3D(DeliverPos.x, DeliverPos.y, DeliverPos.z, "[~r~E~w~] Deliver")
                    if IsControlJustReleased(0, Keys["E"]) and (lastpress == 0 or (GetGameTimer() - lastpress > 3000)) then
                        BJCore.Functions.PersistentNotify("end", "island1")
                        lastpress = GetGameTimer()
                        TriggerServerEvent("bulksale:server:deliver")
                        BulkStage = 0
                    end
                end
            else
                if dist > 30 then
                    Citizen.Wait(500)
                end
            end
        end
        Citizen.Wait(0)
    end
end

local CombatAttributes = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [5] = true,
    [20] = true,
    [46] = true,
    [52] = true,
    [292] = false,
    [1424] = true,
}

local CombatFloats = {
    [0] = 0.1,
    [1] = 2.0,
    [3] = 1.25,
    [4] = 10.0,
    [5] = 1.0,
    [8] = 0.1,
    [11] = 20.0,
    [12] = 9.0,
    [16] = 10.0,
}

local CreatedAi = {}
function CreateKillSquad()
    Citizen.CreateThread(function()
        for i = 1,#AiSpawnLocations,1 do
            DoRequestModel(GetHashKey("g_m_y_ballasout_01"))
            local createdNPC = CreatePed(27, GetHashKey("g_m_y_ballasout_01"), AiSpawnLocations[i].pos, true)
            SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(createdNPC), true)
            SetEntityMaxHealth(createdNPC, 400)
            SetEntityHealth(createdNPC, 400)
            SetPedAccuracy(createdNPC, 100)
            SetPedCombatAbility(createdNPC, 100)
            SetPedCombatRange(createdNPC, 2)
            local chance = math.random(100)
            if chance <= 33 then
                SetPedCombatMovement(createdNPC, 1)
            elseif chance <= 66 then
                SetPedCombatMovement(createdNPC, 2)
            elseif chance <= 100 then
                SetPedCombatMovement(createdNPC, 3)
            end
            -- for k,v in pairs(CombatAttributes) do
            --     SetPedCombatAttributes(createdNPC, k, v)
            -- end
            -- for k,v in pairs(CombatFloats) do
            --     SetCombatFloat(createdNPC, k, v)
            -- end
            -- SetPedCombatAttributes(createdNPC, 46, true)
            GiveWeaponToPed(createdNPC, GetHashKey('weapon_combatpistol'), 300, false, true)
            SetPedDropsWeaponsWhenDead(createdNPC, false)
            SetModelAsNoLongerNeeded(AiSpawnLocations[i].model)
            SetPedSuffersCriticalHits(createdNPC, false)
            SetPedFiringPattern(createdNPC,GetHashKey("FIRING_PATTERN_FULL_AUTO"))
            local r2, h2 = AddRelationshipGroup("ballas")
            SetPedRelationshipGroupHash(createdNPC, GetHashKey("ballas"))
            TaskCombatPed(createdNPC, PlayerPedId(), 0, 16)
            table.insert(CreatedAi, createdNPC)
        end
        TrackAiDeaths()
    end)
end

function TrackAiDeaths()
    Citizen.CreateThread(function()
        while BulkStage == 1 do
            for k,v in pairs(CreatedAi) do
                if IsEntityDead(v) or IsPedDeadOrDying(v, 1) then
                    TriggerServerEvent("BJCore:RequestEntityDelete", NetworkGetNetworkIdFromEntity(v))
                    CreatedAi[k] = nil
                end
            end
            Citizen.Wait(250)
        end
    end)
end

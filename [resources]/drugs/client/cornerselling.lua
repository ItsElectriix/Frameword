cornerselling = false
hasTarget = false
busySelling = false

startLocation = nil

currentPed = nil

lastPed = {}

stealingPed = nil
stealData = {}

availableDrugs = {}
dealerRep = 0

local policeMessage = {
    "Suspicious situation",
    "Possible drug dealing",
}

local blacklistedModels = {
    GetHashKey('mp_m_shopkeep_01'),
    GetHashKey('a_c_boar'),
    GetHashKey('a_c_cat_01'),
    GetHashKey('a_c_chickenhawk'),
    GetHashKey('a_c_chimp'),
    GetHashKey('a_c_chop'),
    GetHashKey('a_c_cormorant'),
    GetHashKey('a_c_cow'),
    GetHashKey('a_c_coyote'),
    GetHashKey('a_c_crow'),
    GetHashKey('a_c_deer'),
    GetHashKey('a_c_dolphin'),
    GetHashKey('a_c_fish'),
    GetHashKey('a_c_hen'),
    GetHashKey('a_c_humpback'),
    GetHashKey('a_c_husky'),
    GetHashKey('a_c_killerwhale'),
    GetHashKey('a_c_mtlion'),
    GetHashKey('a_c_pig'),
    GetHashKey('a_c_pigeon'),
    GetHashKey('a_c_poodle'),
    GetHashKey('a_c_pug'),
    GetHashKey('a_c_rabbit_01'),
    GetHashKey('a_c_rat'),
    GetHashKey('a_c_retriever'),
    GetHashKey('a_c_rhesus'),
    GetHashKey('a_c_rottweiler'),
    GetHashKey('a_c_seagull'),
    GetHashKey('a_c_sharkhammer'),
    GetHashKey('a_c_sharktiger'),
    GetHashKey('a_c_shepherd'),
    GetHashKey('a_c_stingray'),
    GetHashKey('a_c_westy'),
}

local lastSale = 0
local curCooldown = 0

RegisterNetEvent('drugs:client:cornerselling')
AddEventHandler('drugs:client:cornerselling', function(data)
    if cornerselling then
        if IsEntityPlayingAnim(PlayerPedId(), "pickup_object" ,"pickup_low", 3) then
            ClearPedTasks(PlayerPedId())
        end
        fullReset()
        BJCore.Functions.Notify('Corner selling disabled')
        --ClearPedTasks(PlayerPedId())
    else    
        BJCore.Functions.TriggerServerCallback('drugs:server:cornerselling:getAvailableDrugs', function(result,rep)
            if result ~= nil then
                dealerRep = rep
                availableDrugs = result

                if not cornerselling then
                    cornerselling = true
                    BJCore.Functions.Notify('Started selling')
                    startLocation = GetEntityCoords(PlayerPedId())
                    CornerSellingTick()
                    -- TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_CROSS_ROAD_WAIT", 0, false)
                end
            else
                BJCore.Functions.Notify('You aren\'t carrying any drugs on you', 'error')
            end
        end)
    end
end)

function fullReset()
    cornerselling = false
    hasTarget = false
    busySelling = false
    startLocation = nil
    currentPed = nil
    availableDrugs = {}
end

function toFarAway()
    BJCore.Functions.Notify('You\'ve moved too far away. Corner selling stopped', 'error')
    fullReset()
    Citizen.Wait(5000)
end

function callPolice(coords)
    Citizen.CreateThread(function()
        Citizen.Wait(math.random(3500,7500))
        local title = policeMessage[math.random(1, #policeMessage)]
        local pCoords = GetEntityCoords(PlayerPedId())
        local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pCoords.x, pCoords.y, pCoords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        local streetLabel = street1
        if street2 ~= nil then streetLabel = street1..' '..street2 end
        TriggerServerEvent('MF_Trackables:Notify', title.." has been reported on "..streetLabel, coords, 'police', 'streetdrugs')
        hasTarget = false
        
    end)
    Citizen.Wait(5000)
end

function isBlacklisted(ped)
    local blacklisted = false
    for i = 1, #blacklistedModels, 1 do
        if GetEntityModel(ped) == blacklistedModels[i] then
            blacklisted = true
            break
        end
    end
    return blacklisted
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(4)
        if stealingPed ~= nil and next(stealData) ~= nil then
            if IsEntityDead(stealingPed) then
                local pos = GetEntityCoords(PlayerPedId())
                local pedpos = GetEntityCoords(stealingPed)
                if #(pos - pedpos) < 1.5 then
                    BJCore.Functions.DrawText3D(pedpos.x, pedpos.y, pedpos.z, "[~r~E~s~] Pick up",0.8)
                    if IsControlJustReleased(0, 38) then
                        RequestAnimDict("pickup_object")
                        while not HasAnimDictLoaded("pickup_object") do Citizen.Wait(7); end
                        TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false)
                        Citizen.Wait(2000)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("BJCore:Server:AddItem", stealData.item, stealData.amount)
                        TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[stealData.item], "add")
                        stealingPed = nil
                        stealData = {}
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function CornerSellingTick()
    Citizen.CreateThread(function()
        while cornerselling do
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            if not hasTarget and GetGameTimer() - lastSale >= curCooldown then
                local closestPed = GetRandomPedTosell(coords)
                SellToPed(closestPed)
            end
            if startLocation ~= nil then
                local startDist = #(startLocation - GetEntityCoords(PlayerPedId()))

                if startDist > 10 then
                    toFarAway()
                end
            end
            if IsPedInAnyVehicle(PlayerPedId(), true) then fullReset(); BJCore.Functions.Notify("You cannot corner sell from a vehicle") end 
            Citizen.Wait(3)
        end
    end)
end

RegisterNetEvent('drugs:client:refreshAvailableDrugs')
AddEventHandler('drugs:client:refreshAvailableDrugs', function(items)
    availableDrugs = items and items or 0
    if availableDrugs == 0 then 
        fullReset()
        BJCore.Functions.Notify('You no longer have drugs to sell', 'error')
    end
end)

function SellToPed(ped)
    hasTarget = true
    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    dealerRep = PlayerData.metadata["dealerrep"] or dealerRep
    print("dealerRep: "..dealerRep)

    local succesChance, scamChance, getRobbed, getAttacked

    if dealerRep < 10 then
        succesChance = math.random(1, 20)
        scamChance = math.random(3, 5)
        getRobbed = math.random(1, 8)
        getAttacked = math.random(1, 14)
    elseif dealerRep >= 10 then
        succesChance = math.random(2, 20)
        scamChance = math.random(2, 5)
        getRobbed = math.random(1, 12)
        getAttacked = math.random(2, 16)
    elseif dealerRep >= 20 then
        succesChance = math.random(3, 20)
        scamChance = math.random(1, 5)
        getRobbed = math.random(1, 16)
        getAttacked = math.random(1, 18)
    elseif dealerRep >= 30 then
        succesChance = math.random(4, 20)
        scamChance = math.random(1, 5)
        getRobbed = math.random(1, 20)
        getAttacked = math.random(1, 20)
    elseif dealerRep >= 40 then
        succesChance = math.random(5, 20)
        scamChance = 1
        getRobbed = math.random(1, 20)
        getAttacked = math.random(1, 30)
    end

    print(succesChance, scamChance, getRobbed, getAttacked)

    if succesChance <= 7 then
        hasTarget = false
        return
    elseif succesChance >= 19 then
        callPolice(GetEntityCoords(ped))
        return
    end

    local drugType = math.random(1, #availableDrugs)
    local bagAmount = math.random(1, availableDrugs[drugType].amount)

    if bagAmount > 6 then
        bagAmount = math.random(3, 6)
    end
    currentOfferDrug = availableDrugs[drugType]

    local ddata = Config.DrugsPrice[currentOfferDrug.item]
    local randomPrice = math.random(ddata.min, ddata.max) * bagAmount
    if scamChance == 5 then
       randomPrice = math.random(3, 10) * bagAmount
    end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(PlayerPedId(), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)

    if getRobbed <= 2 or getAttacked <= 2 then
        TaskFollowNavMeshToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
    else
        TaskFollowNavMeshToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
    end
    local timeout = 200
    while (pedDist > 1.5 and timeout ~= 0) do
        coords = GetEntityCoords(PlayerPedId(), true)
        pedCoords = GetEntityCoords(ped)  
        if timeout > 100 then  
            if getRobbed <= 2 or getAttacked <= 2 then
                TaskFollowNavMeshToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
            else
                TaskFollowNavMeshToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
            end
        end
        pedDist = #(coords - pedCoords)
        timeout = timeout - 1

        Citizen.Wait(100)
    end
    if pedDist > 1.5 and timeout <= 0 then
        SetEntityAsNoLongerNeeded(ped)
        ClearPedTasks(e)
        hasTarget = false
        ClearPedTasksImmediately(ped)
        table.insert(lastPed, ped)
        return
    end

    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
    currentPed = ped

    if hasTarget then
        while (pedDist < 1.5 and cornerselling) do
            coords = GetEntityCoords(PlayerPedId(), true)
            pedCoords = GetEntityCoords(ped)
            pedDist = #(coords - pedCoords)

            if getAttacked <= 2 then
                TriggerServerEvent('drugs:server:robCornerDrugs', availableDrugs[drugType].item, bagAmount)
                BJCore.Functions.Notify('You have been robbed and lost '..bagAmount..' bags(\'s) '..availableDrugs[drugType].label, 'error')
                stealingPed = ped
                stealData = {
                    item = availableDrugs[drugType].item,
                    amount = bagAmount,
                }

                hasTarget = false
            
                GiveWeaponToPed(ped, `WEAPON_PISTOL`, 100, false, true)
                SetPedDropsWeaponsWhenDead(ped, false)
                TaskAimGunAtEntity(ped, PlayerPedId(), -1, 1)
                Citizen.Wait(1500, 3000)
                TaskShootAtEntity(ped, PlayerPedId(), -1, `FIRING_PATTERN_FULL_AUTO`)
                SetPedKeepTask(ped, true)
                table.insert(lastPed, ped)
                lastSale = GetGameTimer()
                curCooldown = math.random(8000, 12000)
                break
            elseif getRobbed <= 2 then
                TriggerServerEvent('drugs:server:robCornerDrugs', availableDrugs[drugType].item, bagAmount)
                BJCore.Functions.Notify('You have been robbed and lost '..bagAmount..' bags(\'s) '..availableDrugs[drugType].label, 'error')
                stealingPed = ped
                stealData = {
                    item = availableDrugs[drugType].item,
                    amount = bagAmount,
                }

                hasTarget = false

                local rand = (math.random(6,9) / 100) + 0.3
                local rand2 = (math.random(6,9) / 100) + 0.3
                if math.random(10) > 5 then
                    rand = 0.0 - rand
                end
            
                if math.random(10) > 5 then
                    rand2 = 0.0 - rand2
                end
            
                local moveto = GetEntityCoords(PlayerPedId())
                local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
                ClearPedTasksImmediately(ped)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)

                table.insert(lastPed, ped)
                lastSale = GetGameTimer()
                curCooldown = math.random(8000, 12000)
                break
            else
                if pedDist < 1.5 then
                    BJCore.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, '[~g~E~w~] '..bagAmount..'x '..currentOfferDrug.label..' for '..BJCore.Config.Currency.Symbol..randomPrice..'? | [~r~G~w~] Decline',0.7)
                    if IsControlJustPressed(0, Keys["E"]) then
                        BJCore.Functions.Notify('Offer accepted', 'success')
                        hasTarget = false
                        TaskTurnPedToFaceEntity(PlayerPedId(), ped, 5500)
                        Wait(2000)

                        local animDict = "mp_common";
                        local anim = "givetake2_a";
                        local anim2 = "givetake2_b"; 
                        loadAnimDict(animDict)                       
                        TaskPlayAnim(PlayerPedId(), animDict, anim, 3.0, 1.0, -1, 49, 1, false, false, false)
                        TaskPlayAnim(ped, animDict, anim2, 3.0, 1.0, -1, 49, 1, false, false, false)
                        Wait(5000)
                        StopAnimTask(PlayerPedId(), animDict, anim, 1.0)
                        StopAnimTask(ped, animDict, anim2, 1.0)                                        
                        Citizen.Wait(650)
                        TriggerServerEvent('drugs:server:sellCornerDrugs', availableDrugs[drugType].item, bagAmount, randomPrice)
                        ClearPedTasks(PlayerPedId())

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        lastSale = GetGameTimer()
                        curCooldown = math.random(8000, 12000)
                        break
                    end

                    if IsControlJustPressed(0, Keys["G"]) then
                        BJCore.Functions.Notify('Offer refused', 'error')
                        hasTarget = false

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        table.insert(lastPed, ped)
                        break
                    end
                else
                    hasTarget = false
                    SetPedKeepTask(ped, false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasksImmediately(ped)
                    table.insert(lastPed, ped)
                end
            end
            
            Citizen.Wait(3)
        end
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

function runAnimation(target)
    RequestAnimDict("mp_character_creation@lineup@male_a")
    while not HasAnimDictLoaded("mp_character_creation@lineup@male_a") do
    Citizen.Wait(0)
    end
    if not IsEntityPlayingAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 3) then
        TaskPlayAnim(target, "mp_character_creation@lineup@male_a", "loop_raised", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
end

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    dealerRep = 0
end)

GetRandomPedTosell = function(coords)
    local peds = GetGamePool("CPed")
    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end

    for i=1, #peds, 1 do
        if not IsPedAPlayer(peds[i]) and not isBlacklisted(peds[id]) then
            local pedCoords = GetEntityCoords(peds[i])
            local distance  = #(pedCoords - coords)
            if distance < 15.0 and not IsEntityDead(peds[i]) then
                return peds[i]
            end
        end
    end
end
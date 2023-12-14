PlayerLoaded = false
PlayerData = {}
HackedLights = {}
PoliceCount = 0

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    if amount and amount ~= nil  then
        PoliceCount = amount
    end 
end)

RegisterNetEvent('BJCore:Player:UpdateClientInventoryCache')
AddEventHandler('BJCore:Player:UpdateClientInventoryCache', function(itemCache)
    if PlayerData then
        PlayerData.items = itemCache
    end
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    PlayerLoaded = true
    BJCore.Functions.TriggerServerCallback("crim:server:GetHackedLights", function(data)
        HackedLights = data
    end)
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

local isRobbing = false
local copsConnected = 0

RegisterNetEvent('lls_jobCount')
AddEventHandler('lls_jobCount', function(data)
    if data['police'] ~= nil then
        copsConnected = data['police']
    else
        copsConnected = 0
    end
end)

-- Glove Check
function IsWearingGloves()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoGloves[armIndex] ~= nil and Config.MaleNoGloves[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoGloves[armIndex] ~= nil and Config.FemaleNoGloves[armIndex] then
            retval = false
        end
    end
    return retval
end

exports('IsWearingGloves', IsWearingGloves);

-- Mask Check
function IsWearingMask()
    local maskIndex = GetPedDrawableVariation(PlayerPedId(), 1)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoMask[maskIndex] ~= nil and Config.MaleNoMask[maskIndex] then
            retval = false
        end
    else
        if Config.FemaleNoMask[maskIndex] ~= nil and Config.FemaleNoMask[maskIndex] then
            retval = false
        end
    end
    return retval
end

exports('IsWearingMask', IsWearingMask);

--

local trafficLights = {
    [1] = -655644382,
    [2] = 862871082,
}

function IsNearTrafficLights(ignoreTask)
    for i = 1, #trafficLights do
        local objFound = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 2.75, trafficLights[i], 0, 0, 0)
  
        if DoesEntityExist(objFound) then
            if not ignoreTask then
                TaskTurnPedToFaceEntity(PlayerPedId(), objFound, 3.0)
            end
            return true, objFound
        end
    end
  
    return false, false
end

local colours = {
    [50] = 0,[49] = 2,[48] = 1,[47] = 0,[46] = 2,[45] = 1,[44] = 0,[43] = 2,[42] = 1,[41] = 0,
    [40] = 2,[39] = 1,[38] = 0,[37] = 2,[36] = 1,[35] = 0,[34] = 2,[33] = 1,[32] = 0,[31] = 2,
    [30] = 1,[29] = 0,[28] = 2,[27] = 1,[26] = 0,[25] = 2,[24] = 1,[23] = 0,[22] = 2,[21] = 1,
    [20] = 0,[19] = 2,[18] = 1,[17] = 0,[16] = 2,[15] = 1,[14] = 0,[13] = 2,[12] = 1,[11] = 0,
    [10] = 2,[9] = 1,[8] = 0,[7] = 2,[6] = 1,[5] = 0,[4] = 2,[3] = 1,[2] = 0,[1] = 2,[0] = 1,                             
}

local partId = false
-- RegisterCommand("tlights", function(source, args, raw)
--     local b, obj = IsNearTrafficLights(true)
--     if b then
--         local objPos = GetEntityCoords(obj)
--         partId = math.random(1,99999)
--         objPos = GetOffsetFromEntityInWorldCoords(obj, 0.0, -0.18, 1.3)
--         for _,v in ipairs(BJCore.Functions.GetPlayersFromCoords(objPos, 100.0)) do
--             TriggerServerEvent('crim:server:syncTrafficLights', GetPlayerServerId(v), GetEntityModel(obj), GetEntityCoords(PlayerPedId()))
--             TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), objPos[1], objPos[2], objPos[3], "spark", partId, 80.0, GetEntityHeading(obj), 0.0)
--         end
--         TriggerServerEvent("InteractSound_SV:PlayWithinDistancePos", objPos, 30.0, "spark1", 0.08)
--     end
-- end)

local hacktimer = {
    [1] = 10000,
    [2] = 13000,
    [3] = 16000,
    [4] = 18000,
    [5] = 20000,
}

AddEventHandler("crim:hackTraffic", function()
    local nearLights, lightId = IsNearTrafficLights(true)
    if nearLights then
        local trafficCoords = GetEntityCoords(lightId)
        if HackedLights[trafficCoords] then
            BJCore.Functions.Notify('This Trafic Light has already been hacked', 'error')
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
                    name = "traffic_hack",
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
                        local times = math.random(3,5)
                        local count = 0
                        local busy, failed = false, false
                        if math.random(1, 100) <= 50 and not exports["crim"]:IsWearingGloves() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", coords)
                        end
                        TriggerServerEvent("crim:server:ChanceRemove", 'trojan_usb', 15)                        
                        for i = 1,times,1 do
                            if failed then break; end
                            busy = true                                                
                            TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_STAND_MOBILE", 0, false)
                            TriggerEvent('bj_minigames:start', 'Bruteforce', { difficulty = difficulty, timer = hacktimer[math.ceil(hackValue / 100 * 5)], background = 1 }, function(data)
                                count = count + 1
                                BJCore.Functions.Notify(count.."/"..times.." tasks complete")  
                                if count == times then                              
                                    ClearPedTasksImmediately(plyPed)
                                    FreezeEntityPosition(plyPed, false)
                                    BJCore.Functions.Notify('Traffic Lights hacked', 'primary',7000)
                                    HackedLights[trafficCoords] = true
                                    partId = math.random(1,99999)
                                    local sparkPos = GetOffsetFromEntityInWorldCoords(lightId, 0.0, -0.18, 1.3)
                                    TriggerServerEvent("bj-log:server:CreateLog", "crim", "Hack Tasks", "green", "**"..pData.name.."** ("..pData.citizenid..") has hacked traffic lights at "..trafficCoords..".")
                                    for _,v in ipairs(BJCore.Functions.GetPlayersFromCoords(trafficCoords, 100.0)) do
                                        TriggerServerEvent('crim:server:syncTrafficLights', GetPlayerServerId(v), GetEntityModel(lightId), GetEntityCoords(PlayerPedId()))
                                        TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), sparkPos[1], sparkPos[2], sparkPos[3], "spark", partId, 80.0, GetEntityHeading(lightId), 0.0)
                                    end
                                    TriggerServerEvent("InteractSound_SV:PlayWithinDistancePos", sparkPos, 30.0, "spark1", 0.08)

                                    if math.random(100) <= 40 then
                                        TriggerServerEvent('MF_Trackables:Notify','Traffic Control is reporting a disturbance', trafficCoords, 'police', 'atm')
                                    end
                                    Wait(6500)
                                    TriggerServerEvent("crim:server:rewardTrafficLights", trafficCoords)
                                end
                                busy = false
                            end, function(data)
                                busy = false
                                failed = true
                                BJCore.Functions.Notify("Failed", "error")
                                electrocutePlayer()
                                TriggerServerEvent('MF_Trackables:Notify','Traffic Control is reporting a disturbance', trafficCoords, 'police', 'atm')
                                ClearPedTasksImmediately(plyPed)
                                FreezeEntityPosition(plyPed, false)
                            end)
                            while busy do Citizen.Wait(0); end
                        end
                    end
                end)
            end
        end
    end
end)

function CanHackTrafficLights()
    local nearLights, lightId = IsNearTrafficLights(true)
    if nearLights then
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

exports('CanHackTrafficLights', CanHackTrafficLights)

RegisterNetEvent("crim:client:syncTrafficLights")
AddEventHandler("crim:client:syncTrafficLights", function(model, pos)
    Citizen.CreateThread(function()
        local obj = GetClosestObjectOfType(pos, 2.75, model, 0, 0, 0)
        if obj ~= 0 and obj ~= -1 then
            if DoesEntityExist(obj) then
                for i= 1,6,1 do
                local timer = 50
                    while timer >= 0 do 
                        SetEntityTrafficlightOverride(obj, colours[timer])
                        timer = timer - 1
                        Citizen.Wait(100)
                    end
                end
                if partId then 
                    TriggerServerEvent("particle:StopParticle", partId)
                    partId = false
                end

            end
        end
    end)
end)

RegisterNetEvent('crim:client:trafficHacked')
AddEventHandler('crim:client:trafficHacked', function(coords)
    HackedLights[coords] = true
end)

function electrocutePlayer()
    if math.random(100) <= 50 then
        local ply = PlayerPedId()
        local pos = GetEntityCoords(PlayerPedId())
        local wea = GetHashKey('WEAPON_STUNGUN')
        ShootSingleBulletBetweenCoords(pos.x,pos.y,pos.z + 1.5, pos.x,pos.y,pos.z, 25, false, wea, 0, true, true, 100)
    end
end

exports('electrocutePlayer', electrocutePlayer)
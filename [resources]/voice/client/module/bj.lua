PlayersCoords = {}

local infinityEnabled = GetConvar("onesync", "off") == "on"

RegisterNetEvent("bj_infinity:player:coords")
AddEventHandler("bj_infinity:player:coords", function(coords)
    if type(coords) == "table" then
        PlayersCoords = coords
        if not infinityEnabled then
            for k,v in pairs(PlayersCoords) do
                local player = GetPlayerFromServerId(k)
                if player then
                    local ped = GetPlayerPed(player)
                    if ped then
                        PlayersCoords[k].pos = GetEntityCoords(ped)
                    end
                end
            end
        end
    end
end)

function GetPlayerCoords(serverID)
    local playerID = GetPlayerFromServerId(serverID)

    if playerID ~= -1 then
        return GetEntityCoords(GetPlayerPed(playerID))
    else
        return PlayersCoords[serverID].pos or vector3(0.0, 0.0, 0.0)
    end
end

function GetPlayersInRange(range)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local myid = GetPlayerServerId(PlayerId())

    local players = {}

    for k,v in pairs(PlayersCoords) do
        local coords = GetPlayerCoords(k)

        if #(coords - pedCoords) < range then
            players[k] = true
        end
    end

    return players
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
end

AddEventHandler('pma-voice:setTalkingMode', function(range)
    TriggerEvent('mooseUI:client:UpdateTalkRange', range, #Cfg.voiceModes)
end)

RegisterNetEvent("bj:voice:radio:nameUpdated")
AddEventHandler("bj:voice:radio:nameUpdated", function(serverID, newName)
    if PlayersCoords[serverID] then
        PlayersCoords[serverID].radioName = newName

        if radioData[serverID] ~= nil then
            SendNUIMessage({
                radioNameUpdateId = serverID,
                radioNameUpdateName = newName
            })
        end
    end
end)


AddEventHandler('pma-voice:radioActive', function(val)
    if val then
        TriggerEvent('mooseUI:client:UpdateTalkType', 'RADIO')
    else
        TriggerEvent('mooseUI:client:UpdateTalkType', 'MIC')
    end
end)

exports('getPlayerData', function(serverId, type)
    if type == "voip:mode" then
        return voiceData.mode
    elseif type == "voip:talking" then
        return lastTalkingStatus == true and 1 or 0
    end
end)

TriggerServerEvent("bj_infinity:player:ready")

function almostEqual(pFloat1, pFloat2, pThreshold)
    return math.abs(pFloat1 - pFloat2) <= pThreshold
end  

RegisterCommand('radiovol', function(source, args, raw)
    volume = args[1] and tonumber(args[1]) or 0

    if not volume or volume <= 0 then return end

    local radioVolume = (volume > 120 and 120 or volume) / 100

    if almostEqual(0.0, volume, 0.01) or volume < 0 then radioVolume = 0.0 end

    CustomVolumes['radio'] = radioVolume

    TriggerEvent("BJCore:Notify", ("New radio volume %s"):format(radioVolume))
end)

RegisterCommand('phonevol', function(source, args, raw)
    volume = args[1] and tonumber(args[1]) or 0
    if not volume or volume <= 0 then return end

    local phoneVolume = (volume > 120 and 120 or volume) / 100

    if almostEqual(0.0, volume, 0.01) or volume < 0 then phoneVolume = 0.0 end

    CustomVolumes['phone'] = phoneVolume

    TriggerEvent("BJCore:Notify", ("New phone volume %s"):format(phoneVolume))
end)
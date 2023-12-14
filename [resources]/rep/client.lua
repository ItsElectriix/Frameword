local PlayerData = nil
local CurrentLevels = {}

Citizen.CreateThread(function()
    while not BJCore do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Wait(500); end
    while not BJCore.Functions.IsPlayerLoaded() do Wait(500); end
    PlayerData = BJCore.Functions.GetPlayerData()
    SetCurrentLevels()
end)

RegisterNetEvent('bj_rpgrep:showUI')
AddEventHandler('bj_rpgrep:showUI', function()
    if PlayerData ~= nil then
        local profilePicture = PlayerData.metadata['phone'].profilepicture
        if profilePicture == nil or profilePicture == 'default' then
            profilePicture = './default.png'
        end
        SendNUIMessage({
            type = 'show',
            charInfo = PlayerData.charinfo,
            profilePicture = profilePicture,
            repInfo = CurrentLevels
        })
    end
end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(newPlayerData)
    if PlayerData ~= nil then
        for repType, rep in pairs(RepTypes) do
            local currentRep, newRep = nil, nil

            if newPlayerData.metadata['jobrep'][repType] ~= nil and PlayerData.metadata['jobrep'][repType] ~= nil then
                currentRep = PlayerData.metadata['jobrep'][repType]
                newRep = newPlayerData.metadata['jobrep'][repType]
            elseif newPlayerData.metadata[repType] ~= nil and PlayerData.metadata[repType] ~= nil then
                currentRep = PlayerData.metadata[repType]
                newRep = newPlayerData.metadata[repType]
            end

            if currentRep ~= nil and newRep ~= nil and newRep > currentRep then
                for l,n in pairs(rep.levels) do
                    if newRep >= l and currentRep < l then
                        TriggerEvent('BJCore:Notify', "You have levelled up to '"..n.."' in '"..rep.name.."'", 'primary', 5000)
                    end
                end
            end
        end
    end
    PlayerData = newPlayerData
    SetCurrentLevels()
end)

function SetCurrentLevels()
    if PlayerData ~= nil then
        for repType, rep in pairs(RepTypes) do
            local currentRep = nil

            if PlayerData.metadata['jobrep'][repType] ~= nil then
                currentRep = PlayerData.metadata['jobrep'][repType]
            elseif PlayerData.metadata[repType] ~= nil then
                currentRep = PlayerData.metadata[repType]
            end

            if currentRep ~= nil then
                local current = CurrentLevels[repType]
                if current == nil then
                    current = {
                        level = 0
                    }
                end
                for l,n in pairs(rep.levels) do
                    if currentRep >= l and l > current.level then
                        current = {
                            level = l,
                            name = rep.name,
                            title = n
                        }
                    end
                end
                if current.level > 0 then
                    CurrentLevels[repType] = current
                end
            end
        end
    end
end

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    PlayerData = nil
    CurrentLevels = {}
end)

BJCore = nil

TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

BJCore.Functions.CreateUseableItem("policebadge", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("bj_ids:client:UseIdCard", source, 'policebadge')
end)

RegisterNetEvent('bj_ids:server:FlashToPlayers')
AddEventHandler('bj_ids:server:FlashToPlayers', function(cardType, players, itemData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local data = {}
    if cardType == "personalid" then
        data = {
            source = Player.PlayerData.source,
            firstname  = itemData.info.firstname ~= nil and itemData.info.firstname or Player.PlayerData.charinfo.firstname,
            lastname = itemData.info.lastname ~= nil and itemData.info.lastname or Player.PlayerData.charinfo.lastname,
            dob = itemData.info.birthdate ~= nil and itemData.info.birthdate or Player.PlayerData.charinfo.birthdate,
            citizenid = itemData.info.citizenid ~= nil and itemData.info.citizenid or Player.PlayerData.citizenid,
            gender = itemData.info.gender ~= nil and itemData.info.gender or Player.PlayerData.charinfo.gender,
            nationality = itemData.info.nationality ~= nil and itemData.info.nationality or Player.PlayerData.charinfo.nationality,
            callsign = Player.PlayerData.metadata['callsign']
        }
    else
        data = {
            source = Player.PlayerData.source,
            firstname = Player.PlayerData.charinfo.firstname,
            lastname = Player.PlayerData.charinfo.lastname,
            dob = Player.PlayerData.charinfo.birthdate,
            citizenid = Player.PlayerData.citizenid,
            gender = Player.PlayerData.charinfo.gender,
            nationality = Player.PlayerData.charinfo.nationality,
            callsign = Player.PlayerData.metadata['callsign']
        }
    end

    for _,p in ipairs(players) do
        TriggerClientEvent('bj_ids:client:FlashId', p, data, cardType)
    end
end)

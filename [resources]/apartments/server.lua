local apartmentData = {}
local apartmentKeys = {}
local apartmentReady = false
Citizen.CreateThread(function()
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_apartments`", function(result)
        if result and result[1] ~= nil then
            for k,v in pairs(result) do
                v.keyholders = json.decode(v.keyholders)
                if apartmentData[v.building] == nil then
                    apartmentData[v.building] = {}
                end
                apartmentData[v.building][v.citizenid] = {}
                apartmentData[v.building][v.citizenid] = v
            end
        end
        apartmentReady = true
    end)
end)

RegisterNetEvent("apartments:server:HandleBucket")
AddEventHandler("apartments:server:HandleBucket", function(b, building, id, object)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        if b then
            local bucketId = 0
            if type(id) == "number" then
                bucketId = building..id
            else
                bucketId = building..apartmentData[Config.Buildings[building].name][id].id
            end
            SetPlayerRoutingBucket(tostring(src), tonumber(bucketId))
            if object ~= nil then
                SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(object), tonumber(bucketId))
            end
        else
            SetPlayerRoutingBucket(src, 0)
            if object ~= nil then
                SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(object), 0)
            end
        end
    end
end)

BJCore.Functions.RegisterServerCallback("apartments:server:leaseApartment", function(source, cb, name)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then
        local isOffice = 0
        if Config.Buildings[name].isOffice then isOffice = 1; end
        local text = "apartment"
        if isOffice == 1 then text = "office"; end
        local count = 0
        if apartmentData[Config.Buildings[name].name] ~= nil then
            count = #apartmentData[Config.Buildings[name].name]
        end
        if count >= Config.Buildings[name].maxLeases then
            TriggerClientEvent('BJCore:Notify', source, "There are no available "..text.."s at this location", "error", 5000)
            return
        end
        local hasOffice, hasApp = false, false
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_apartments` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
            if result and result[1] ~= nil then
                for k,v in pairs(result) do
                    if v.isOffice == 1 then
                        hasOffice = true
                    else
                        if not Config.Buildings[getBuildingId(v.building)].isFree then
                            hasApp = true
                        end
                    end
                end
            end
            local proceed = true
            if Config.Buildings[name].isOffice and hasOffice then
                proceed = false
            elseif hasApp and not Config.Buildings[name].isFree then
                proceed = false
            end
            if proceed then
                if Config.Buildings[name].isFree then
                    BJCore.Functions.ExecuteSql(true, "INSERT INTO `player_apartments` (`citizenid`, `building`, `daysLeft`, `isOffice`, `keyholders`) VALUES ('"..Player.PlayerData.citizenid.."', '"..Config.Buildings[name].name.."', 14, '"..isOffice.."', '{}')")
                    addToCache(name, Player.PlayerData.citizenid, text)
                    cb(name)
                elseif Player.Functions.RemoveMoney("bank", Config.Buildings[name].price) then
                    BJCore.Functions.ExecuteSql(true, "INSERT INTO `player_apartments` (`citizenid`, `building`, `daysLeft`, `isOffice`, `keyholders`) VALUES ('"..Player.PlayerData.citizenid.."', '"..Config.Buildings[name].name.."', 14, '"..isOffice.."', '{}')")
                    addToCache(name, Player.PlayerData.citizenid, text)
                    cb(name)
                else
                    TriggerClientEvent('BJCore:Notify', source, 'You don\'t have enough money for this lease', "error", 5000)
                    cb(false)
                end
            else
                TriggerClientEvent('BJCore:Notify', source, 'You can only lease 1 apartment and 1 office', "error", 5000)
                cb(false)
            end
        end)
    end
end)

function addToCache(building, citizenid, text)
    local name = Config.Buildings[building].name
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_apartments` WHERE `citizenid` = '"..citizenid.."' AND `building` = '"..name.."'", function(data)
        data[1].keyholders = json.decode(data[1].keyholders)
        if apartmentData[name] == nil then
            apartmentData[name] = {}
        end
        apartmentData[name][data[1].citizenid] = {}
        apartmentData[name][data[1].citizenid] = data[1]
        if not Config.Buildings[building].isFree then
            local mailData = {
                sender = Config.Buildings[building].label,
                subject = text:gsub("^%l", string.upper).." Lease Confirmation",
                message = BJCore.Config.Currency.Symbol..Config.Buildings[building].price.." has been debited from your bank for a 14 day lease of "..text:gsub("^%l", string.upper).." #"..data[1].id..". You'll be able to renew your lease 7 days before your lease is up.<br/>Kind regards,<br /> Building Management",
                button = {}
            }
            TriggerEvent("phone:server:sendNewMailToOffline", citizenid, mailData)
        end
    end)
end

BJCore.Functions.RegisterServerCallback("apartments:server:GetOwned", function(source, cb, name)
    local Player = BJCore.Functions.GetPlayer(source)
    while not apartmentReady do Citizen.Wait(100); end
    if Player ~= nil then
        local ret = {}
        for _,buildings in pairs(apartmentData) do
            for k,v in pairs(buildings) do
                if v.citizenid == Player.PlayerData.citizenid then
                    table.insert(ret, buildings[k])
                end
            end
        end
        cb(ret)
    end
end)

RegisterNetEvent("apartments:server:renewApartment")
AddEventHandler("apartments:server:renewApartment", function(building)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_apartments` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `building` = '"..Config.Buildings[building].name.."'", function(result)
            if result and result[1] ~= nil then
                if result[1].daysLeft <= 7 then
                    local newDate = result[1].daysLeft + 14
                    BJCore.Functions.ExecuteSql(false, "UPDATE `player_apartments` SET `daysLeft` = '"..newDate.."' WHERE `id` = '"..result[1].id.."'")
                    local text = "apartment"
                    if Config.Buildings[building].isOffice then text = "office"; end
                    local mailData = {
                        sender = Config.Buildings[building].label,
                        subject = "Renewal Confirmation",
                        message = "You have renewed your "..text.." for an additional 14 days <br/>Kind regards,<br /> Building Management",
                        button = {}
                    }
                    TriggerEvent("phone:server:sendNewMailToOffline", Player.PlayerData.citizenid, mailData)
                else
                    TriggerClientEvent('BJCore:Notify', src, "You'll be able to renew your lease in "..(result[1].daysLeft-7).." days", "error", 5000)
                end
            end
        end)
    end
end)

BJCore.Functions.RegisterServerCallback("apartments:server:GetKeys", function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    while not apartmentReady do Citizen.Wait(100); end
    local retTab = {}
    for building,apts in pairs(apartmentData) do
        for id,data in pairs(apts) do
            for k, v in pairs(data.keyholders) do
                if v == Player.PlayerData.citizenid then
                    if retTab[building] == nil then
                        retTab[building] = {}
                    end
                    retTab[building][data.id] = data.citizenid
                end
            end
        end
    end
    cb(retTab)
end)

BJCore.Functions.RegisterServerCallback("apartments:server:getKeyHolders", function(source, cb, building, id)
    local Player = BJCore.Functions.GetPlayer(source)
    while not apartmentReady do Citizen.Wait(100); end
    local retTab, busy = {}, false
    local name = Config.Buildings[building].name
    if apartmentData[name][id].keyholders ~= nil then
        for k,v in pairs(apartmentData[name][id].keyholders) do
            if Player.PlayerData.citizenid ~= v then
                busy = true
                BJCore.Functions.ExecuteSql(false, "SELECT `charinfo` FROM `players` WHERE `citizenid` = '"..v.."'", function(result)
                    if result[1] ~= nil then
                        local charinfo = json.decode(result[1].charinfo)
                        table.insert(retTab, {
                            firstname = charinfo.firstname,
                            lastname = charinfo.lastname,
                            citizenid = v,
                        })
                    end
                    busy = false
                end)
                while busy do Citizen.Wait(0); end
            end
        end
    end
    cb(retTab)
end)

RegisterNetEvent("apartments:server:giveAptKey")
AddEventHandler("apartments:server:giveAptKey", function(target, building, id)
    local src = source
    local tPlayer = BJCore.Functions.GetPlayer(target)
    local name = Config.Buildings[building].name
    if tPlayer ~= nil then
        if apartmentData[name][id].keyholders ~= nil then
            for _, cid in pairs(apartmentData[name][id].keyholders) do
                if cid == tPlayer.PlayerData.citizenid then
                    TriggerClientEvent('BJCore:Notify', src, 'This person already has keys to this apartment', 'error', 3500)
                    return
                end
            end
            table.insert(apartmentData[name][id].keyholders, tPlayer.PlayerData.citizenid)
            BJCore.Functions.ExecuteSql(true, "UPDATE `player_apartments` SET `keyholders` = '"..json.encode(apartmentData[name][id].keyholders).."' WHERE `id` = '"..apartmentData[name][id].id.."'")
            TriggerClientEvent('apartment:client:syncKeys', tPlayer.PlayerData.source, "add", name, apartmentData[name][id].id, apartmentData[name][id].citizenid)
            TriggerClientEvent('BJCore:Notify', tPlayer.PlayerData.source, 'You recieved keys to apartment #'..apartmentData[name][id].id, 'success', 2500)
            TriggerClientEvent('BJCore:Notify', src, "You have given "..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname.." keys", 'success', 3500)
        else
            local sourceTarget = BJCore.Functions.GetPlayer(src)
            apartmentData[name][id].keyholders = {
                [1] = sourceTarget.PlayerData.citizenid
            }
            table.insert(apartmentData[name][id].keyholders, tPlayer.PlayerData.citizenid)
            BJCore.Functions.ExecuteSql(true, "UPDATE `player_houses` SET `keyholders` = '"..json.encode(apartmentData[name][id].keyholders).."' WHERE `house` = '"..house.."'")
            TriggerClientEvent('apartment:client:syncKeys', tPlayer.PlayerData.source, "add", name, apartmentData[name][id].id, apartmentData[name][id].citizenid)
            TriggerClientEvent('BJCore:Notify', tPlayer.PlayerData.source, 'You recieved keys to apartment #'..apartmentData[name][id].id, 'success', 2500)
            TriggerClientEvent('BJCore:Notify', src, "You have given "..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname.." keys", 'success', 3500)
        end
    else
        TriggerClientEvent('BJCore:Notify', src, 'Target player not found', 'error', 2500)
    end
end)

RegisterNetEvent("apartments:server:removeKey")
AddEventHandler("apartments:server:removeKey", function(building, id, target)
    local src = source
    local newHolders = {}
    local name = Config.Buildings[building].name
    if apartmentData[name][id].keyholders ~= nil then
        for k, v in pairs(apartmentData[name][id].keyholders) do
            if v ~= target.citizenid then
                table.insert(newHolders, v)
            end
        end
    end
    apartmentData[name][id].keyholders = newHolders
    local tData = BJCore.Functions.GetPlayerByCitizenId(target.citizenid)
    if tData ~= nil then
        TriggerClientEvent('apartment:client:syncKeys', tData.PlayerData.source, "remove", name, apartmentData[name][id].id, apartmentData[name][id].citizenid)
    end
    TriggerClientEvent('BJCore:Notify', src, target.firstname .. " " .. target.lastname .. "'s keys have been removed", 'primary', 3500)
    BJCore.Functions.ExecuteSql(false, "UPDATE `player_apartments` SET `keyholders` = '"..json.encode(apartmentData[name][id].keyholders).."' WHERE `id` = '"..apartmentData[name][id].id.."'")
end)

BJCore.Functions.RegisterServerCallback("apartments:server:getList", function(source, cb, building)
    local Player = BJCore.Functions.GetPlayer(source)
    cb(apartmentData[Config.Buildings[building].name])
end)

RegisterNetEvent("apartments:server:ringDoor")
AddEventHandler("apartments:server:ringDoor", function(building, id)
    local src = source
    local ringIds, owner = {}, nil
    table.insert(ringIds, apartmentData[building][id].citizenid)
    owner = apartmentData[building][id].citizenid
    if apartmentData[building][id].keyholders ~= nil then
        for k,v in pairs(apartmentData[building][id].keyholders) do
            if v ~= owner then
                table.insert(ringIds, v)
            end
        end
    end
    for k,v in pairs(ringIds) do
        local Player = BJCore.Functions.GetPlayerByCitizenId(v)
        if Player ~= nil then
            TriggerClientEvent("apartments:client:receiveRing", Player.PlayerData.source, src, getBuildingId(building), owner)
        end
    end
end)

RegisterNetEvent("apartments:server:acceptRing")
AddEventHandler("apartments:server:acceptRing", function(target, building, owner)
    TriggerClientEvent("apartments:client:acceptedRing", target, building, owner)
end)

function CronTask(d, h, m)
    if GetConvar("server_type", "DEV") == "LIVE" then
        BJCore.Functions.ExecuteSql(true, "SELECT * FROM player_apartments", function(res)
            for id,v in pairs(res) do
                local text = "apartment"
                local bId = getBuildingId(v.building)
                if not Config.Buildings[bId].isFree then
                    if v.isOffice == 1 then text = "office"; end
                    if v.daysLeft == 7 then
                        local Player = BJCore.Functions.GetPlayerByCitizenId(v.citizenid)
                        local mailData = {
                            sender = Config.Buildings[bId].label,
                            subject = "Lease Renewal Reminder",
                            message = "Your lease for your "..text.."can now be renewed. Please visit the building to renew your lease for another 14 days or we\'ll terminate your lease as scheduled in 7 days.<br/>Kind regards,<br /> Building Management",
                            button = {}
                        }
                        if Player ~= nil then
                            TriggerEvent('phone:server:sendNewMailToOffline', Player.PlayerData.citizenid, mailData)
                        else
                            TriggerEvent("phone:server:sendNewMailToOffline", v.citizenid, mailData)
                        end
                        BJCore.Functions.ExecuteSql(false, "UPDATE `player_apartments` SET `daysLeft` = daysLeft-1 WHERE `id` = '"..v.id.."'")
                    elseif v.daysLeft > 0 then
                        BJCore.Functions.ExecuteSql(false, "UPDATE `player_apartments` SET `daysLeft` = daysLeft-1 WHERE `id` = '"..v.id.."'")
                    else
                        local Player = BJCore.Functions.GetPlayerByCitizenId(v.citizenid)
                        local mailData = {
                            sender = Config.Buildings[bId].label,
                            subject = text:gsub("^%l", string.upper).." Lease Terminated",
                            message = "We\'ve terminated your lease for your "..text.." as you\'ve not renewed your lease.<br/>Kind regards,<br /> Building Management",
                            button = {}
                        }
                        if Player ~= nil then
                            TriggerClientEvent("apartments:client:terminate", Player.PlayerData.source, text)
                            TriggerEvent('phone:server:sendNewMailToOffline', Player.PlayerData.citizenid, mailData)
                        else
                            TriggerEvent("phone:server:sendNewMailToOffline", v.citizenid, mailData)
                        end
                        BJCore.Functions.ExecuteSql(false, "DELETE FROM player_apartments WHERE `id` = '"..v.id.."'")
                    end
                end
            end
        end)
    end
end

TriggerEvent('cron:runAt', 22, 00, CronTask)
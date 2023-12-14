BJCore.Commands.Add("id", "What's my id?", {}, false, function(source, args)
    TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "ID: "..source)
end)

if Config.BlacklistEnabled then
    AddEventHandler('entityCreating', function(e)
        if Config.BlacklistedEntityModels[GetEntityModel(e)] then
            CancelEvent()
        end
    end)
end

--- Trunk functions ---
RegisterNetEvent("bj_gameplay:requestTrunk")
AddEventHandler("bj_gameplay:requestTrunk", function(target, veh, remove)
    if remove then
        TriggerClientEvent('bj_gameplay:handleTrunk', target, false)
    else
        TriggerClientEvent('bj_gameplay:handleTrunk', target, veh)
    end
end)

RegisterNetEvent("gameplay:server:toggleTrunkDoor")
AddEventHandler("gameplay:server:toggleTrunkDoor", function(veh)
    local _source = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
    TriggerClientEvent("gameplay:client:toggleTrunkDoor", owner, veh)
end)
----

--- Carwash ---
BJCore.Functions.RegisterServerCallback('bj_gameplay:purchaseWash', function(source, cb)
    if Config.CarWashPrice > 0 then
        local pData = BJCore.Functions.GetPlayer(source)
        if pData.PlayerData.money.cash < Config.CarWashPrice then
            return cb(false)
        end
        pData.Functions.RemoveMoney("cash",Config.CarWashPrice,"Car wash")
    end
    return cb(true)
end)

RegisterNetEvent("bj_gameplay:requestClean")
AddEventHandler("bj_gameplay:requestClean", function(veh)
    local _source = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))   
    TriggerClientEvent("bj_gameplay:doClean", owner, veh)
end)
---

--- Street Racing ---
local Races = {}
BJCore.Functions.RegisterServerCallback('JAM_RaceMod:SetupRace', function(source, cb, racePos, blipCoord, raceID, wager) 
    Races = Races or {}
    Races.raceID = { 
        start = racePos,
        finish = blipCoord,
        wager = wager,
        players = { source, },
        finished = {},
    }   

    TriggerClientEvent('JAM_RaceMod:ChallengeNearbyPlayers', -1, racePos, raceID, wager)

    local timer = GetGameTimer()
    while (GetGameTimer() - timer) < (Config.SRWaitForPlayersTimer * 1000) do Citizen.Wait(0); end
    if Races.raceID and Races.raceID.players then cbData = #Races.raceID.players else cbData = 0; end
    cb(cbData)
end)

RegisterNetEvent('JAM_RaceMod:JoinRace')
AddEventHandler('JAM_RaceMod:JoinRace', function(raceID) 
    if Races and Races.raceID and Races.raceID.players then
        local plys = Races.raceID.players
        local isAdded = false
        for k,v in pairs(plys) do
            if v == source then isAdded = true; end
        end
        if not isAdded then 
            table.insert(Races.raceID.players, source)
            TriggerEvent('JAM_RaceMod:SetMoney', -Races.raceID.wager) 
        end
    end
end)

RegisterNetEvent('JAM_RaceMod:StartRace')
AddEventHandler('JAM_RaceMod:StartRace', function(raceID) 
    if Races and Races.raceID and Races.raceID.players then
        local race = Races.raceID
        for k,v in pairs(race.players) do
            TriggerClientEvent('JAM_RaceMod:BeginRace', v, raceID, race.finish)
        end
    end
end)

RegisterNetEvent('JAM_RaceMod:SetMoney')
AddEventHandler('JAM_RaceMod:SetMoney', function(amount)
    local pData = BJCore.Functions.GetPlayer(source)
    while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
    local playerMoney = pData.PlayerData.money.cash
    if amount < 0 then 
        pData.Functions.RemoveMoney("cash",amount,"Street race wager")
    else
        pData.Functions.AddMoney("cash",amount,"Street race wager")
    end
end)

RegisterNetEvent('JAM_RaceMod:LeaveRace')
AddEventHandler('JAM_RaceMod:LeaveRace', function(raceID)
    if Races and Races.raceID then
        for k,v in pairs(Races.raceID.players) do
            if v == source then
                table.remove(Races.raceID.players, k)
                return
            end
        end
    end
end)

BJCore.Functions.RegisterServerCallback('JAM_RaceMod:FinishStreetRace', function(source, cb, raceID)    
    print(Races.raceID, Races.raceID.finished)
    table.insert(Races.raceID.finished, source)
    cb(#Races.raceID.finished, Races.raceID.wager, #Races.raceID.players)
end)

RegisterNetEvent('JAM_RaceMod:RaceTimeout')
AddEventHandler('JAM_RaceMod:RaceTimeout', function(raceID)
    for k,v in pairs(Races.raceID.players) do
        local doSend = true
        for key,val in pairs(Races.raceID.finished) do
            if v == val then doSend = false; end
        end
        if doSend then TriggerClientEvent('JAM_RaceMod:Timeout', v); end
    end
    Races.raceID = {}
end)
---

--- Veh sales ---
local forSale = {}

BJCore.Functions.RegisterServerCallback('VehSales:TryBuy',function(source,cb,veh)
    local pData = BJCore.Functions.GetPlayer(source)
    if (pData.PlayerData.citizenid == veh.owner or pData.PlayerData.money.cash >= tonumber(veh.price)) then
        local vehData
        local keyData
        for k,v in pairs(forSale) do
            if v.vehProps.plate == veh.vehProps.plate then
                vehData = v
                keyData = k
            end
        end

        if vehData then
            if not forSale[keyData].brought then
                forSale[keyData].brought = true
                TriggerClientEvent('VehSales:RemoveFromSale',-1,vehData)
                if pData.PlayerData.citizenid ~= veh.owner then
                    cb(true,"You have purchased the vehicle")
                else
                    cb(true,"You have reclaimed the vehicle")
                end
            else
                cb(false,"Somebody else is purchasing this vehicle")
            end
        else
            cb(false,"Can't find this vehicle")
        end
    else
        cb(false,"You can't afford this vehicle")
    end
end)

local AllowDonoSale, AllowFinanceSale = false, false
BJCore.Functions.RegisterServerCallback('VehSales:TrySell', function(source,cb,veh)
    local pData = BJCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute('SELECT * FROM `player_vehicles` WHERE plate=@plate',{['@plate'] = string.gsub(veh.plate, "%s+", "")}, function(data)
        if not data or not data[1] then
            cb(false,"You don't own this vehicle")
        else
            if data[1].financeData and data[1].financeData ~= nil then
                local financeData = json.decode(data[1].financeData)
                if financeData.completedPayments ~= financeData.repayments and not AllowFinanceSale then
                    cb(false,"You need to finish paying this car off before you can sell it")
                end
            end
            if data[1].is_dono and data[1].is_dono > 0 and not AllowDonoSale then
                cb(false,"You cannot sell donation vehicles")
            else
                if data[1].citizenid ~= pData.PlayerData.citizenid then
                    cb(false,"You don't own this vehicle")
                else
                    cb(true)
                end
            end
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('VehSales:GetStartData', function(s,c) local m = MFV; c(forSale); end)

RegisterNetEvent("VehSales:AddSale")
AddEventHandler("VehSales:AddSale", function(veh,loc,price,props)
    local src = source
    local id = GetPlayerIdentifier(source)
    local citizenid = BJCore.Functions.GetPlayer(src).PlayerData.citizenid
    TriggerClientEvent('VehSales:AddToSale',-1,veh,loc,price,props,citizenid)
    forSale[#forSale+1] = {veh = veh, loc = loc, price = price, vehProps = props, owner = citizenid}
end)

RegisterNetEvent("VehSales:BuyVeh")
AddEventHandler("VehSales:BuyVeh", function(veh)
    local src = source
    local vData = false
    for k,v in pairs(forSale) do
        if v.vehProps.plate == veh.vehProps.plate then
            vData = v
            kData = k
        end
    end
    if vData then
        local truePrice = tonumber(vData.price)
        local data = BJCore.Functions.GetPlayer(src)
        local identifier = GetPlayerIdentifier(source)

        if vData.owner ~= data.PlayerData.citizenid then
            local pData = BJCore.Functions.GetPlayerByCitizenId(vData.owner)
            local tick = 0
            while not pData and tick < 1000 do
                tick = tick + 1
                pData = BJCore.Functions.GetPlayerByCitizenId(vData.owner)
                Citizen.Wait(0)
            end

            if pData then 
                pData.Functions.AddMoney("cash",vData.price,"Used vehicle sale")
            else
                BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..vData.owner.."'", function(result)
                    if result[1] ~= nil then
                        local moneyInfo = json.decode(result[1].money)
                        moneyInfo.bank = math.ceil((moneyInfo.bank + vData.price))
                        BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..vData.owner.."'")
                    end
                end)
            end
            local tData = BJCore.Functions.GetPlayer(src)
            tData.Functions.RemoveMoney("cash",vData.price,"Used vehicle purchase")
            print(tData.PlayerData.steam, tData.PlayerData.citizenid, vData.vehProps.plate)
            BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `steam` = @steam, `citizenid` = @citizenid WHERE `plate` = @plate", nil, {
                ['@steam'] = tData.PlayerData.steam,
                ['@citizenid'] = tData.PlayerData.citizenid,
                ['@plate'] = string.gsub(vData.vehProps.plate, "%s+", "")
            })
            TriggerEvent('phone:server:sendNewMailToOffline', vData.owner, {
                sender = 'Vehicle Sale',
                subject = "Automated Confirmation",
                message = ('Hello,<br /><br />This is an automated notification that your vehicle with plate: %s has been sold to %s %s for '..BJCore.Config.Currency.Symbol..'%s<br /><br />'):format(vData.vehProps.plate, pData.PlayerData.charinfo.firstname, pData.PlayerData.charinfo.lastname, vData.price)
            })
            forSale[kData] = nil
        end
    end
end)

BJCore.Commands.Add("sellmycar", "Sell your vehicle", {{name = "price", help = "numerical amount"}}, true, function(source, args)
    TriggerClientEvent("VehSales:AttemptSell", source, args)
end)
---
RegisterNetEvent('3dme:server:shareText')
AddEventHandler('3dme:server:shareText', function(text)
    TriggerClientEvent('3dme:shareDisplay', -1, text, source)
end)

BJCore.Commands.Add("me", "Character interactions", {}, false, function(source, args)
    local text = table.concat(args, ' ')
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent('3dme:shareDisplay', -1, text, source)
    TriggerEvent("bj-log:server:CreateLog", "me", "Me", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..")** " ..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.. " **" ..text, false)
end)

BJCore.Commands.Add("dice", "Roll dice", {{name="dice", help="Amount of dice to roll"}, {name="faces", help="Number of faces on dice"}}, false, function(source, args)
    times = tonumber(args[1]) or 1
    weight = tonumber(args[2]) or 6
    TriggerClientEvent('gameplay:client:rollDice', source, times, weight)
end)

local Pings = {}

BJCore.Commands.Add("ping", "", {{name = "action", help="id | accept | deny"}}, true, function(source, args)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local task = args[1]
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if task == "accept" then
            if Pings[src] ~= nil then
                local sender = BJCore.Functions.GetPlayer(Pings[src].sender)
                local name = 'Unknown'
                if sender then
                    name = sender.PlayerData.charinfo.firstname.." "..sender.PlayerData.charinfo.lastname
                end
                TriggerClientEvent('pings:client:AcceptPing', src, Pings[src], sender.PlayerData.charinfo.firstname.." "..sender.PlayerData.charinfo.lastname)
                TriggerClientEvent('BJCore:Notify', Pings[src].sender, Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.." accepted your ping")
                Pings[src] = nil
            else
                TriggerClientEvent('BJCore:Notify', src, "You don't have a ping pending", "error")
            end
        elseif task == "deny" then
            if Pings[src] ~= nil then
                TriggerClientEvent('BJCore:Notify', Pings[src].sender, "Your ping has been rejected", "error")
                TriggerClientEvent('BJCore:Notify', src, "You have rejected the ping", "success")
                Pings[src] = nil
            else
                TriggerClientEvent('BJCore:Notify', src, "You don't have a ping pending", "error")
            end
        else
            TriggerClientEvent('pings:client:DoPing', src, tonumber(args[1]))
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You don't have a phone", "error")
    end
end)

RegisterServerEvent('pings:server:SendPing')
AddEventHandler('pings:server:SendPing', function(id, coords)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(id)
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if Target ~= nil then
            local OtherItem = Target.Functions.GetItemByName("phone")
            if OtherItem ~= nil then
                TriggerClientEvent('BJCore:Notify', src, "You sent a ping to "..Target.PlayerData.charinfo.firstname.." "..Target.PlayerData.charinfo.lastname)
                Pings[id] = {
                    coords = coords,
                    sender = src,
                }
                TriggerClientEvent('BJCore:Notify', id, "You recived a ping from "..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname..". /ping 'accept | deny'")
            else
                TriggerClientEvent('BJCore:Notify', src, "Could not send the ping, person may not have a phone", "error")
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "This person is not online", "error")
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You don't have a phone", "error")
    end
end)

RegisterServerEvent('pings:server:SendLocation')
AddEventHandler('pings:server:SendLocation', function(PingData, SenderName)
    TriggerClientEvent('pings:client:SendLocation', PingData.sender, PingData, SenderName)
end)

RegisterServerEvent('cmg3_animations:sync')
AddEventHandler('cmg3_animations:sync', function(target, animationLib,animationLib2, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget,attachFlag, emote, actionType)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(targetSrc)
    if actionType == 'start' then
        TriggerEvent("bj-log:server:CreateLog", "crim", "Take Hostage", "green", "**"..Player.PlayerData.name .. "** has taken **"..Target.PlayerData.name.."** hostage using the take hostage function in Z menu.") 
    elseif actionType == 'release' then
        TriggerEvent("bj-log:server:CreateLog", "crim", "Take Hostage", "green", "**"..Player.PlayerData.name .. "** has released **"..Target.PlayerData.name.."** from being hostage.")
    elseif actionType == 'kill' then
        TriggerEvent("bj-log:server:CreateLog", "crim", "Take Hostage", "green", "**"..Player.PlayerData.name .. "** has killed **"..Target.PlayerData.name.."** while being held hostage.")
    end
    TriggerClientEvent('cmg3_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget,attachFlag, emote)
    TriggerClientEvent('cmg3_animations:syncMe', source, animationLib, animation,length,controlFlagSrc,animFlagTarget)
end)

RegisterServerEvent('cmg3_animations:stop')
AddEventHandler('cmg3_animations:stop', function(targetSrc)
    TriggerClientEvent('cmg3_animations:cl_stop', targetSrc)
end)

RegisterNetEvent("particle:StartParticleAtLocation")
AddEventHandler("particle:StartParticleAtLocation", function(target, x, y, z, particleId, allocatedID, rX, rY, rZ)
    TriggerClientEvent("particle:StartClientParticle", target, x, y, z, particleId, allocatedID, rX, rY, rZ)
end)

RegisterNetEvent("particle:StopParticle")
AddEventHandler("particle:StopParticle", function(id)
    TriggerClientEvent("particle:StopParticleClient", -1, id)
end)
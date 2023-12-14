BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

local Plates = {}
cuffedPlayers = {}
PlayerStatus = {}
Casings = {}
BloodDrops = {}
FingerDrops = {}
local Objects = {}

local TempRadioAccess = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000 * 60 * 10)
    while true do
        local curCops = GetCurrentCops()
        TriggerClientEvent("police:SetCopCount", -1, curCops)
        Citizen.Wait(30000)
    end
end)

AddEventHandler('bj:voice:radio:ready', function()
    for k,v in ipairs(Config.RadioChannels) do
        if exports.voice and next(exports.voice) ~= nil then
            exports.voice:RegisterRadioFrequency(v, function(serverID, radioID)
                local Ply = BJCore.Functions.GetPlayer(serverID)
                if not Ply then
                    return false
                end
                if Ply.PlayerData.job.name == "police" or Ply.PlayerData.job.name == "ambulance" then
                    return true
                end
                if TempRadioAccess[Ply.PlayerData.citizenid] then
                    return true
                end
                return false
            end)
        else
            TriggerEvent('radio:registerAuthorizedFrequency', v, function(serverID, radioID)
                local Ply = BJCore.Functions.GetPlayer(serverID)
                if not Ply then
                    return false
                end
                if Ply.PlayerData.job.name == "police" or Ply.PlayerData.job.name == "ambulance" then
                    return true
                end
                if TempRadioAccess[Ply.PlayerData.citizenid] then
                    return true
                end
                return false
            end)
        end
    end
end)

BJCore.Commands.Add("grantencradio", "Grant a person access to encrypted channels (Temporarily)", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance" then
        if args[1] ~= nil then
            local id = tonumber(args[1])
            local Target = BJCore.Functions.GetPlayer(id)

            if Target ~= nil then
                TempRadioAccess[Target.PlayerData.citizenid] = true
                TriggerClientEvent('BJCore:Notify', source, 'Granted access.', 'primary')
                TriggerClientEvent('BJCore:Notify', id, 'You were given access to encrypted emergency channels.', 'primary')
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

RegisterServerEvent('police:server:CheckBills')
AddEventHandler('police:server:CheckBills', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `bills` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `type` = 'police'", function(result)
        if result and result[1] ~= nil then
            local totalAmount = 0
            for k, v in pairs(result) do
                totalAmount = totalAmount + tonumber(v.amount)
            end
            Player.Functions.RemoveMoney("bank", totalAmount, "paid-all-bills")
            BJCore.Functions.ExecuteSql(false, "DELETE FROM `bills` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `type` = 'police'")
            TriggerClientEvent('police:client:sendBillingMail', src, totalAmount)
            TriggerEvent('moneysafe:server:DepositMoneyDirect', "police", totalAmount, "bills")
        end
    end)
end)

RegisterServerEvent('police:server:CuffPlayer')
AddEventHandler('police:server:CuffPlayer', function(playerId, isSoftcuff)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local CuffedPlayer = BJCore.Functions.GetPlayer(playerId)
    if CuffedPlayer ~= nil then
        if Player.Functions.GetItemByName("handcuffs") ~= nil or Player.PlayerData.job.name == "police" then
            TriggerClientEvent("police:client:GetCuffed", CuffedPlayer.PlayerData.source, Player.PlayerData.source, isSoftcuff)           
        end
    end
end)

RegisterServerEvent('police:server:CuffFailed')
AddEventHandler('police:server:CuffFailed', function(playerId)
    local Player = BJCore.Functions.GetPlayer(playerId)
    if Player ~= nil then
        TriggerClientEvent('police:client:CuffFailed', playerId)
    end
end)

RegisterServerEvent('police:server:UnCuffPlayer')
AddEventHandler('police:server:UnCuffPlayer', function(playerId, heading, coords, position)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local CuffedPlayer = BJCore.Functions.GetPlayer(playerId)
    if CuffedPlayer ~= nil then
        if Player.Functions.GetItemByName("handcuffs") ~= nil or Player.PlayerData.job.name == "police" then
            TriggerClientEvent("police:client:GetUnCuffed", CuffedPlayer.PlayerData.source, heading, coords, position)
            TriggerClientEvent("police:client:DoUnCuffing", Player.PlayerData.source)
        end
    end
end)

RegisterServerEvent('police:server:EscortPlayer')
AddEventHandler('police:server:EscortPlayer', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local EscortPlayer = BJCore.Functions.GetPlayer(playerId)
    if EscortPlayer ~= nil then
        if (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") or (EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or EscortPlayer.PlayerData.metadata["inlaststand"]) then
            TriggerClientEvent("police:client:GetEscorted", EscortPlayer.PlayerData.source, Player.PlayerData.source)
        else
            TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Person is not dead or cuffed")
        end
    end
end)

RegisterServerEvent('police:server:KidnapPlayer')
AddEventHandler('police:server:KidnapPlayer', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local EscortPlayer = BJCore.Functions.GetPlayer(playerId)
    if EscortPlayer ~= nil then
        --if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or EscortPlayer.PlayerData.metadata["inlaststand"] then
            TriggerClientEvent("police:client:GetKidnappedTarget", EscortPlayer.PlayerData.source, Player.PlayerData.source)
            TriggerClientEvent("police:client:GetKidnappedDragger", Player.PlayerData.source, EscortPlayer.PlayerData.source)
       -- else
            --TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Person is not dead or cuffed")
        --end
    end
end)

RegisterServerEvent('police:server:SetPlayerOutVehicle')
AddEventHandler('police:server:SetPlayerOutVehicle', function(playerId, pos)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local EscortPlayer = BJCore.Functions.GetPlayer(playerId)
    if EscortPlayer ~= nil then
        --if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("police:client:SetOutVehicle", EscortPlayer.PlayerData.source, pos)
        --else
            --TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Person is not dead or cuffed")
        --end
    end
end)

RegisterServerEvent('police:server:PutPlayerInVehicle')
AddEventHandler('police:server:PutPlayerInVehicle', function(playerId, veh)
    local src = source
    local Player = BJCore.Functions.GetPlayer(source)
    local EscortPlayer = BJCore.Functions.GetPlayer(playerId)
    if EscortPlayer ~= nil then
        --if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("police:client:PutInVehicle", EscortPlayer.PlayerData.source, veh)
        --else
            --TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Person is not dead or cuffed")
        --end
    end
end)

RegisterServerEvent('police:server:BillPlayer')
AddEventHandler('police:server:BillPlayer', function(playerId, price)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "police" then
        if OtherPlayer ~= nil then
            if OtherPlayer.Functions.RemoveMoney("bank", price, "paid-bills") then
                TriggerEvent('moneysafe:server:DepositMoneyDirect', "police", price, "bills")
            end
            TriggerClientEvent('BJCore:Notify', OtherPlayer.PlayerData.source, "You received a fine of "..BJCore.Config.Currency.Symbol..price)
            TriggerEvent("bj-log:server:CreateLog", "police", "Police Fine", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has fined **"..OtherPlayer.PlayerData.name.."** ("..OtherPlayer.PlayerData.citizenid..") for "..BJCore.Config.Currency.Symbol..price)
        end
    end
end)

RegisterServerEvent('police:server:JailPlayer')
AddEventHandler('police:server:JailPlayer', function(playerId, time)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
    local currentDate = os.date("*t")
    if currentDate.day == 31 then currentDate.day = 30 end

    if Player.PlayerData.job.name == "police" then
        if OtherPlayer ~= nil then
            OtherPlayer.Functions.SetMetaData("injail", time)
            OtherPlayer.Functions.SetMetaData("criminalrecord", {
                ["hasRecord"] = true,
                ["date"] = currentDate
            })
            TriggerClientEvent("police:client:SendToJail", OtherPlayer.PlayerData.source, time)
            TriggerClientEvent('BJCore:Notify', src, "You sent the person to prison for "..time.." months")
            TriggerEvent("bj-log:server:CreateLog", "police", "Police Jail", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has jailed **"..OtherPlayer.PlayerData.name.."** ("..OtherPlayer.PlayerData.citizenid..") for "..time.." (months).")
        end
    end
end)

RegisterServerEvent('police:server:SetHandcuffStatus')
AddEventHandler('police:server:SetHandcuffStatus', function(isHandcuffed)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        Player.Functions.SetMetaData("ishandcuffed", isHandcuffed)
    end
end)

RegisterServerEvent('heli:spotlight')
AddEventHandler('heli:spotlight', function(state)
    local serverID = source
    TriggerClientEvent('heli:spotlight', -1, serverID, state)
end)

RegisterServerEvent('police:server:FlaggedPlateTriggered')
AddEventHandler('police:server:FlaggedPlateTriggered', function(camId, plate, street1, street2, blipSettings)
    local src = source
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if street2 ~= nil then
                    TriggerClientEvent("112:client:SendPoliceAlert", v, "flagged", {
                        camId = camId,
                        plate = plate,
                        streetLabel = street1.. " "..street2,
                    }, blipSettings)
                else
                    TriggerClientEvent("112:client:SendPoliceAlert", v, "flagged", {
                        camId = camId,
                        plate = plate,
                        streetLabel = street1
                    }, blipSettings)
                end
            end
        end
    end
end)

RegisterServerEvent('police:server:PoliceAlertMessage')
AddEventHandler('police:server:PoliceAlertMessage', function(title, streetLabel, coords)
    local src = source

    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("police:client:PoliceAlertMessage", v, title, streetLabel, coords)
            elseif Player.Functions.GetItemByName("radioscanner") ~= nil and math.random(1, 100) <= 50 then
                TriggerClientEvent("police:client:PoliceAlertMessage", v, title, streetLabel, coords)
            end
        end
    end
end)

RegisterServerEvent('police:server:GunshotAlert')
AddEventHandler('police:server:GunshotAlert', function(streetLabel, isAutomatic, fromVehicle, coords, vehicleInfo)
    local src = source

    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("police:client:GunShotAlert", Player.PlayerData.source, streetLabel, isAutomatic, fromVehicle, coords, vehicleInfo)
            elseif Player.Functions.GetItemByName("radioscanner") ~= nil and math.random(1, 100) <= 50 then
                TriggerClientEvent("police:client:GunShotAlert", Player.PlayerData.source, streetLabel, isAutomatic, fromVehicle, coords, vehicleInfo)
            end
        end
    end
end)

RegisterServerEvent('police:server:VehicleCall')
AddEventHandler('police:server:VehicleCall', function(pos, msg, alertTitle, streetLabel, modelPlate, modelName)
    local src = source
    local alertData = {
        title = "Vehicle theft",
        coords = {x = pos.x, y = pos.y, z = pos.z},
        description = msg,
    }
    print(streetLabel)
    TriggerClientEvent("police:client:VehicleCall", -1, pos, alertTitle, streetLabel, modelPlate, modelName)
    TriggerClientEvent("phone:client:addPoliceAlert", -1, alertData)
end)

RegisterServerEvent('police:server:HouseRobberyCall')
AddEventHandler('police:server:HouseRobberyCall', function(coords, message, gender, streetLabel)
    local src = source
    local alertData = {
        title = "Burglary",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = message,
    }
    TriggerClientEvent("police:client:HouseRobberyCall", -1, coords, message, gender, streetLabel)
    TriggerClientEvent("phone:client:addPoliceAlert", -1, alertData)
end)

RegisterServerEvent('police:server:SendEmergencyMessage')
AddEventHandler('police:server:SendEmergencyMessage', function(coords, message)
    local src = source
    local MainPlayer = BJCore.Functions.GetPlayer(src)
    local nameInfo = MainPlayer.PlayerData.charinfo.firstname .. " " .. MainPlayer.PlayerData.charinfo.lastname .. " ("..src..")"
    local alertData = {
        title = "911 alert - "..nameInfo,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = message,
    }
    TriggerClientEvent("phone:client:addPoliceAlert", -1, alertData)
    TriggerClientEvent('police:server:SendEmergencyMessageCheck', -1, nameInfo, message, coords)
end)

RegisterServerEvent('police:server:Send311Message')
AddEventHandler('police:server:Send311Message', function(coords, message)
    local src = source
    local MainPlayer = BJCore.Functions.GetPlayer(src)
    local nameInfo = MainPlayer.PlayerData.charinfo.firstname .. " " .. MainPlayer.PlayerData.charinfo.lastname .. " ("..src..")"
    local alertData = {
        title = "311 message - "..nameInfo,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = message,
    }
    TriggerClientEvent("phone:client:addPoliceAlert", -1, alertData)
    TriggerClientEvent('police:server:Send311Check', -1, nameInfo, message, coords)
end)

RegisterServerEvent('police:server:FriskPlayer')
AddEventHandler('police:server:FriskPlayer', function(playerId)
    local src = source
    local targetPly = BJCore.Functions.GetPlayer(playerId)
    local found = false
    if targetPly ~= nil then
        TriggerClientEvent('BJCore:Notify', targetPly.PlayerData.source, "You are being frisked")
        if targetPly.PlayerData.items then
            for k,v in pairs(targetPly.PlayerData.items) do
                if v and v.type == "weapon" then 
                    found = true
                    break
                end
            end
        end
        if found then
            TriggerClientEvent('BJCore:Notify', src, "You feel something that might resemble a weapon")
        else
            TriggerClientEvent('BJCore:Notify', src, "You feel nothing out of the ordinary")
        end
    end
end)

RegisterServerEvent('police:server:CheckForWeapons')
AddEventHandler('police:server:CheckForWeapons', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local found = false
    if Player ~= nil then
        if Player.PlayerData.items then
            for k,v in pairs(Player.PlayerData.items) do
                if v and v.type == "weapon" then 
                    found = true
                    break
                end
            end
        end
        TriggerClientEvent('police:client:ScannerResult', src, found)
    end
end)

RegisterNetEvent('police:server:RequestStatus')
AddEventHandler('police:server:RequestStatus', function(statusType, target)
    local src = source
    local targetPly = BJCore.Functions.GetPlayer(target)
    if targetPly ~= nil then
        if statusType == "gunpowder" then
            TriggerClientEvent('BJCore:Notify', targetPly.PlayerData.source, "You are being tested for GSR")
        end
        TriggerClientEvent('evidence:client:GetStatus', target, statusType, src)
    end
end)

RegisterNetEvent('police:server:ReturnStatus')
AddEventHandler('police:server:ReturnStatus', function(data, rTarget)
    local src = source
    local rTarget = tonumber(rTarget)
    local targetPly = BJCore.Functions.GetPlayer(rTarget)
    if targetPly ~= nil then
        if data and data.time and data.time > 0 then
            TriggerClientEvent('BJCore:Notify', targetPly.PlayerData.source, "GSR Test has returned POSITIVE", "primary", 10000)
        elseif not data or data.time == 0 then
            TriggerClientEvent('BJCore:Notify', targetPly.PlayerData.source, "GSR Test has returned NEGATIVE", "primary", 10000)
        end
    end
end)

RegisterServerEvent('police:server:SearchPlayer')
AddEventHandler('police:server:SearchPlayer', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(playerId)
    if SearchedPlayer ~= nil then 
        TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Person has "..BJCore.Config.Currency.Symbol..SearchedPlayer.PlayerData.money["cash"].." on them")
        TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "You are being searched")
        TriggerEvent("bj-log:server:CreateLog", "police", "Police Search", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used search function on **"..SearchedPlayer.PlayerData.name.."** ("..SearchedPlayer.PlayerData.citizenid..").") 
    end
end)

RegisterServerEvent('police:server:SeizeCash')
AddEventHandler('police:server:SeizeCash', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(playerId)
    if SearchedPlayer ~= nil then 
        local moneyAmount = SearchedPlayer.PlayerData.money["cash"]
        local info = {
            label = "Siezed Cash",
            type = "cash",
            cash = moneyAmount,
        }
        SearchedPlayer.Functions.RemoveMoney("cash", moneyAmount, "police-cash-seized")
        Player.Functions.AddItem("filled_evidence_bag", 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["filled_evidence_bag"], "add")
        TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "Your cash has been seized")
        TriggerEvent("bj-log:server:CreateLog", "police", "Police Cash Seize", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has seized "..BJCore.Config.Currency.Symbol..moneyAmount.." from **"..SearchedPlayer.PlayerData.name.."** ("..SearchedPlayer.PlayerData.citizenid..").") 
    end
end)

RegisterServerEvent('police:server:SeizeDriverLicense')
AddEventHandler('police:server:SeizeDriverLicense', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(playerId)
    if SearchedPlayer ~= nil then
        local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
        if driverLicense then
            local licenses = {
                ["driver"] = false,
                ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
            }
            SearchedPlayer.Functions.SetMetaData("licences", licenses)
            TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "Your driving license has been seized")
            TriggerClientEvent('BJCore:Notify', src, "Driving license has been seized")
        else
            TriggerClientEvent('BJCore:Notify', src, "This person has no driver's license", "error")
        end
    end
end)

RegisterServerEvent('police:server:SeizeGunLicense')
AddEventHandler('police:server:SeizeGunLicense', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(playerId)
    if SearchedPlayer ~= nil then
        local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
        if driverLicense then
            local licenses = {
                ["gun"] = false,
                ["driver"] = SearchedPlayer.PlayerData.metadata["licences"]["driver"],
                ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
            }
            SearchedPlayer.Functions.SetMetaData("licences", licenses)
            TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "Your gun license has been seized")
            TriggerClientEvent('BJCore:Notify', src, "Gun license has been seized")
        else
            TriggerClientEvent('BJCore:Notify', src, "This person has no gun license", "error")
        end
    end
end)

RegisterServerEvent('police:server:RobPlayer')
AddEventHandler('police:server:RobPlayer', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(playerId)
    if SearchedPlayer ~= nil then 
        local money = SearchedPlayer.PlayerData.money["cash"]
        Player.Functions.AddMoney("cash", money, "police-player-robbed")
        SearchedPlayer.Functions.RemoveMoney("cash", money, "police-player-robbed")
        TriggerClientEvent('BJCore:Notify', SearchedPlayer.PlayerData.source, "You have been robbed of "..BJCore.Config.Currency.Symbol..money.."..")
        TriggerEvent("bj-log:server:CreateLog", "default", "Player Robbed", "red", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has robbed **"..SearchedPlayer.PlayerData.name.."**'s ("..SearchedPlayer.PlayerData.citizenid..") "..BJCore.Config.Currency.Symbol..money.." cash using the rob function.")
    end
end)

RegisterNetEvent('police:server:RobPlayerLog')
AddEventHandler('police:server:RobPlayerLog', function(target)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local SearchedPlayer = BJCore.Functions.GetPlayer(target)
    TriggerEvent("bj-log:server:CreateLog", "default", "Player Robbed", "orange", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has used rob function on **"..SearchedPlayer.PlayerData.name.."** ("..SearchedPlayer.PlayerData.citizenid..").")    
end)

RegisterServerEvent('police:server:UpdateBlips')
AddEventHandler('police:server:UpdateBlips', function()
    local src = source
    local dutyPlayers = {}
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if ((Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") and Player.PlayerData.job.onduty) and Player.Functions.GetItemByName(Config.GPSItem) ~= nil then
                table.insert(dutyPlayers, {
                    source = Player.PlayerData.source,
                    label = Player.PlayerData.metadata["callsign"],
                    job = Player.PlayerData.job.name,
                })
            end
        end
    end
    TriggerClientEvent("police:client:UpdateBlips", -1, dutyPlayers)
end)

RegisterServerEvent('police:server:spawnObject')
AddEventHandler('police:server:spawnObject', function(type, pos, h, forward)
    local src = source
    local objectId = CreateObjectId()
    Objects[objectId] = type
    local x, y, z = table.unpack(pos + forward * 0.5)
    Objects[objectId] = {
        id = objectId,
        type = type,
        model = Config.Objects[type].model,
        coords = vector4(x, y, z - 0.3, h),
    }
    TriggerClientEvent("police:client:syncObject", -1, Objects)
end)

RegisterNetEvent('police:server:GetObjectData')
AddEventHandler('police:server:GetObjectData', function() local src = source TriggerClientEvent('police:client:syncObject', src, Objects) end)

RegisterServerEvent('police:server:deleteObject')
AddEventHandler('police:server:deleteObject', function(objectId)
    local src = source
    Objects[objectId] = nil
    TriggerClientEvent('police:client:removeObject', -1, objectId)
end)

RegisterServerEvent('police:server:Impound')
AddEventHandler('police:server:Impound', function(plate, fullImpound, price)
    local src = source
    local price = price ~= nil and price or 0
    if IsVehicleOwned(plate) then
        if not fullImpound then
            exports['ghmattimysql']:execute('UPDATE player_vehicles SET state = @state, depotprice = @depotprice WHERE plate = @plate', {['@state'] = 0, ['@depotprice'] = price, ['@plate'] = plate})
            TriggerClientEvent('BJCore:Notify', src, "Vehicle taken into depot for "..BJCore.Config.Currency.Symbol..price.."")
        else
            exports['ghmattimysql']:execute('UPDATE player_vehicles SET state = @state WHERE plate = @plate', {['@state'] = 2, ['@plate'] = plate})
            TriggerClientEvent('BJCore:Notify', src, "Vehicle completely seized")
        end
    end
end)

RegisterServerEvent('evidence:server:UpdateStatus')
AddEventHandler('evidence:server:UpdateStatus', function(data)
    local src = source
    PlayerStatus[src] = data
end)

RegisterServerEvent('evidence:server:CreateBloodDrop')
AddEventHandler('evidence:server:CreateBloodDrop', function(citizenid, bloodtype, coords)
    local src = source
    local bloodId = CreateBloodId()
    BloodDrops[bloodId] = {dna = citizenid, bloodtype = bloodtype}
    TriggerClientEvent("evidence:client:AddBlooddrop", -1, bloodId, citizenid, bloodtype, coords)
end)

RegisterServerEvent('evidence:server:CreateFingerDrop')
AddEventHandler('evidence:server:CreateFingerDrop', function(coords)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local fingerId = CreateFingerId()
    FingerDrops[fingerId] = Player.PlayerData.metadata["fingerprint"]
    TriggerClientEvent("evidence:client:AddFingerPrint", -1, fingerId, Player.PlayerData.metadata["fingerprint"], coords)
end)

RegisterServerEvent('evidence:server:ClearBlooddrops')
AddEventHandler('evidence:server:ClearBlooddrops', function(blooddropList)
    if blooddropList ~= nil and next(blooddropList) ~= nil then 
        for k, v in pairs(blooddropList) do
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, v)
            BloodDrops[v] = nil
        end
    end
end)

BJCore.Functions.RegisterServerCallback('police:server:hasEmptyEvidenceBag', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    local item = Player.Functions.GetItemByName("empty_evidence_bag")
    if item and item.amount > 0 then
        cb(true)
    else
        TriggerClientEvent('BJCore:Notify', source, "You need an empty evidence bag", "error")
        cb(false)
    end
end)

RegisterServerEvent('evidence:server:AddBlooddropToInventory')
AddEventHandler('evidence:server:AddBlooddropToInventory', function(bloodId, bloodInfo)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, bloodInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, BJCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, bloodId)
            BloodDrops[bloodId] = nil
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You need an empty evidence bag", "error")
    end
end)

RegisterServerEvent('evidence:server:AddFingerprintToInventory')
AddEventHandler('evidence:server:AddFingerprintToInventory', function(fingerId, fingerInfo)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, fingerInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, BJCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveFingerprint", -1, fingerId)
            FingerDrops[fingerId] = nil
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You need an empty evidence bag", "error")
    end
end)

RegisterServerEvent('evidence:server:CreateCasing')
AddEventHandler('evidence:server:CreateCasing', function(weapon, coords)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local casingId = CreateCasingId()
    local weaponInfo = BJCore.Shared.Weapons[weapon]
    local serialNumber = nil
    if weaponInfo ~= nil then
        local weaponItem = Player.Functions.GetItemByName(weaponInfo["name"])

        if weaponItem ~= nil then
            if weaponItem.info ~= nil and  weaponItem.info ~= "" then 
                serialNumber = weaponItem.info.serial
            end
        end
    end
    TriggerClientEvent("evidence:client:AddCasing", -1, casingId, weapon, coords, serialNumber)
end)


RegisterServerEvent('police:server:UpdateCurrentCops')
AddEventHandler('police:server:UpdateCurrentCops', function()
    local amount = 0
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    TriggerClientEvent("police:SetCopCount", -1, amount)
end)

RegisterServerEvent('evidence:server:ClearCasings')
AddEventHandler('evidence:server:ClearCasings', function(casingList)
    if casingList ~= nil and next(casingList) ~= nil then 
        for k, v in pairs(casingList) do
            TriggerClientEvent("evidence:client:RemoveCasing", -1, v)
            Casings[v] = nil
        end
    end
end)

RegisterServerEvent('evidence:server:AddCasingToInventory')
AddEventHandler('evidence:server:AddCasingToInventory', function(casingId, casingInfo)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, casingInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, BJCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveCasing", -1, casingId)
            Casings[casingId] = nil
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You need an empty evidence bag", "error")
    end
end)

RegisterServerEvent('police:server:showFingerprint')
AddEventHandler('police:server:showFingerprint', function(playerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(playerId)

    TriggerClientEvent('police:client:showFingerprint', playerId, src)
    TriggerClientEvent('police:client:showFingerprint', src, playerId)
end)

RegisterServerEvent('police:server:showFingerprintId')
AddEventHandler('police:server:showFingerprintId', function(sessionId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local fid = Player.PlayerData.metadata["fingerprint"]

    TriggerClientEvent('police:client:showFingerprintId', sessionId, fid)
    TriggerClientEvent('police:client:showFingerprintId', src, fid)
end)

RegisterServerEvent('police:server:SetTracker')
AddEventHandler('police:server:SetTracker', function(targetId)
    local Target = BJCore.Functions.GetPlayer(targetId)
    local TrackerMeta = Target.PlayerData.metadata["tracker"]

    if TrackerMeta then
        Target.Functions.SetMetaData("tracker", false)
        TriggerClientEvent('BJCore:Notify', targetId, 'Your anklet is taken off.', 'error', 5000)
        TriggerClientEvent('BJCore:Notify', source, 'You took off an ankle bracelet from '..Target.PlayerData.charinfo.firstname.." "..Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('police:client:SetTracker', targetId, false)
    else
        Target.Functions.SetMetaData("tracker", true)
        TriggerClientEvent('BJCore:Notify', targetId, 'You put on an ankle strap.', 'error', 5000)
        TriggerClientEvent('BJCore:Notify', source, 'You put on an ankle strap to '..Target.PlayerData.charinfo.firstname.." "..Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('police:client:SetTracker', targetId, true)
    end
end)

RegisterServerEvent('police:server:SendTrackerLocation')
AddEventHandler('police:server:SendTrackerLocation', function(coords, requestId)
    local Target = BJCore.Functions.GetPlayer(source)
    local TrackerMeta = Target.PlayerData.metadata["tracker"]

    local msg = "The location of "..Target.PlayerData.charinfo.firstname.." "..Target.PlayerData.charinfo.lastname.." is marked on your map."

    local alertData = {
        title = "Anklet location",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = msg
    }

    TriggerClientEvent("police:client:TrackerMessage", requestId, msg, coords)
    TriggerClientEvent("phone:client:addPoliceAlert", requestId, alertData)
end)

RegisterServerEvent('police:server:SendPoliceEmergencyAlert')
AddEventHandler('police:server:SendPoliceEmergencyAlert', function(streetLabel, coords, callsign)
    -- local alertData = {
    --     title = "Assistance colleague",
    --     coords = {x = coords.x, y = coords.y, z = coords.z},
    --     description = "Emergency button pressed by ".. callsign .. " at "..streetLabel,
    -- }
    if callsign then
        TriggerClientEvent("police:client:PoliceEmergencyAlert", -1, callsign, streetLabel, coords)
    end
    --TriggerClientEvent("phone:client:addPoliceAlert", -1, alertData)
end)

BJCore.Functions.RegisterServerCallback('police:server:isPlayerDead', function(source, cb, playerId)
    local Player = BJCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.metadata["isdead"])
end)

BJCore.Functions.RegisterServerCallback('police:GetPlayerStatus', function(source, cb, playerId)
    local Player = BJCore.Functions.GetPlayer(playerId)
    local statList = {}
    if Player ~= nil then
        if PlayerStatus[Player.PlayerData.source] ~= nil and next(PlayerStatus[Player.PlayerData.source]) ~= nil then
            for k, v in pairs(PlayerStatus[Player.PlayerData.source]) do
                table.insert(statList, PlayerStatus[Player.PlayerData.source][k].text)
            end
        end
    end
    cb(statList)
end)

BJCore.Functions.RegisterServerCallback('police:IsSilencedWeapon', function(source, cb, weapon)
    local Player = BJCore.Functions.GetPlayer(source)
    local itemInfo = Player.Functions.GetItemByName(BJCore.Shared.Weapons[weapon]["name"])
    local retval = false
    if itemInfo ~= nil then 
        if itemInfo.info ~= nil and itemInfo.info.attachments ~= nil then 
            for k, v in pairs(itemInfo.info.attachments) do
                if itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP_02" or itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP" or itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP_02" or itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP" then
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)

BJCore.Functions.RegisterServerCallback('police:GetDutyPlayers', function(source, cb)
    local dutyPlayers = {}
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if ((Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance") and Player.PlayerData.job.onduty) then
                table.insert(dutyPlayers, {
                    source = Player.PlayerData.source,
                    label = Player.PlayerData.metadata["callsign"],
                    job = Player.PlayerData.job.name,
                })
            end
        end
    end
    cb(dutyPlayers)
end)

function CreateBloodId()
    if BloodDrops ~= nil then
        local bloodId = math.random(10000, 99999)
        while BloodDrops[caseId] ~= nil do
            bloodId = math.random(10000, 99999)
        end
        return bloodId
    else
        local bloodId = math.random(10000, 99999)
        return bloodId
    end
end

function CreateFingerId()
    if FingerDrops ~= nil then
        local fingerId = math.random(10000, 99999)
        while FingerDrops[caseId] ~= nil do
            fingerId = math.random(10000, 99999)
        end
        return fingerId
    else
        local fingerId = math.random(10000, 99999)
        return fingerId
    end
end

function CreateCasingId()
    if Casings ~= nil then
        local caseId = math.random(10000, 99999)
        while Casings[caseId] ~= nil do
            caseId = math.random(10000, 99999)
        end
        return caseId
    else
        local caseId = math.random(10000, 99999)
        return caseId
    end
end

function CreateObjectId()
    if Objects ~= nil then
        local objectId = math.random(10000, 99999)
        while Objects[caseId] ~= nil do
            objectId = math.random(10000, 99999)
        end
        return objectId
    else
        local objectId = math.random(10000, 99999)
        return objectId
    end
end

function IsVehicleOwned(plate)
    local val = false
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if (result and result[1] ~= nil) then
            val = true
        else
            val = false
        end
    end)
    return val
end

BJCore.Functions.RegisterServerCallback('police:GetImpoundedVehicles', function(source, cb)
    local vehicles = {}
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE state = @state', {['@state'] = 2}, function(result)
        if result and result[1] ~= nil then
            vehicles = result
        end
        cb(vehicles)
    end)
end)

BJCore.Functions.RegisterServerCallback('police:IsPlateFlagged', function(source, cb, plate)
    local retval = false
    if Plates ~= nil and Plates[plate] ~= nil then
        if Plates[plate].isflagged then
            retval = true
        end
    end
    cb(retval)
end)

BJCore.Functions.RegisterServerCallback('police:GetCops', function(source, cb)
    local amount = 0
    
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    cb(amount)
end)

BJCore.Commands.Add("setpolice", "Give the police job to someone", {{name="id", help="Player ID"}, {name="grade", help="Job grade number"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.job.name == "police" and Myself.PlayerData.job.onduty) and IsHighCommand(Myself.PlayerData.citizenid) then
            Player.Functions.SetJob("police", tonumber(args[2]))
        end
    end
end)

BJCore.Commands.Add("spikestrip", "Place spike strips", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
            TriggerClientEvent('police:client:SpawnSpikeStrip', source)
        end
    end
end)

BJCore.Commands.Add("firepolice", "Fire a police officer", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.job.name == "police" and Myself.PlayerData.job.onduty) and IsHighCommand(Myself.PlayerData.citizenid) then
            Player.Functions.SetJob("unemployed", 1)
        end
    end
end)

function IsHighCommand(citizenid)
    local retval = false
    for k, v in pairs(Config.ArmoryWhitelist) do
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

function IsUCCommand(citizenid)
    local retval = false
    for k, v in pairs(Config.UCWhitelist) do
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

BJCore.Commands.Add("pobject", "Place/Delete an object", {{name="type", help="Type object you want or 'delete' to delete"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local type = args[1]:lower()
    if Player.PlayerData.job.name == "police" then
        if type == "cone" then
            TriggerClientEvent("police:client:spawnCone", source)
        elseif type == "barrier" then
            TriggerClientEvent("police:client:spawnBarrier", source)
        elseif type == "sign" then
            TriggerClientEvent("police:client:spawnSign", source)
        elseif type == "tent" then
            TriggerClientEvent("police:client:spawnTent", source)
        elseif type == "light" then
            TriggerClientEvent("police:client:spawnLight", source)
        elseif type == "delete" then
            TriggerClientEvent("police:client:deleteObject", source)
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("cuff", "Cuff a player", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:CuffPlayer", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("palert", "Make a police alert", {{name="alert", help="The Police alert"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    
    if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
        if args[1] ~= nil then
            local msg = table.concat(args, " ")
            TriggerClientEvent("chatMessage", -1, "POLICE ALERT", "error", msg)
            TriggerEvent("bj-log:server:CreateLog", "police", "Police alert", "blue", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Alert:** " ..msg, false)
            TriggerClientEvent('police:PlaySound', -1)
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You need to include a message")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("escort", "Escort a person", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("police:client:EscortPlayer", source)
end)

BJCore.Commands.Add("mdt", "Toggle police mdt", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:toggleDatabank", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("callsign", "Put the name of your callsign (call number)", {{name="name", help="Name of your callsign"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    Player.Functions.SetMetaData("callsign", table.concat(args, " "))
end)

BJCore.Commands.Add("clearcasings", "Clear bullet casings in the area (make sure you have picked up some)", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("evidence:client:ClearCasingsInArea", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("jail", "Jail a person", {{name="id", help="Player ID"},{name="time", help="Time they have to be in jail"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        local playerId = tonumber(args[1])
        local time = tonumber(args[2])
        if time > 0 then
            TriggerClientEvent("police:client:JailCommand", source, playerId, time)
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Time must be higher then 0")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("comserv", "Send person to community serivce", {{name="id", help="Player ID"},{name="tasks", help="Number of tasks to complete"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        local playerId = tonumber(args[1])
        local Target = BJCore.Functions.GetPlayer(playerId)
        local tasks = tonumber(args[2])
        if Target then
            if tasks > 0 then
                TriggerClientEvent('BJCore:Notify', source, "Player has been sent to community service to complete "..tasks.." tasks", "primary")
                Target.Functions.SetMetaData("comserv", tasks)
                TriggerClientEvent("police:client:setInService", playerId, tasks)
            else
                TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Tasks must be higher then 0")
            end
        else
            TriggerClientEvent('BJCore:Notify', source, "Target player not found", "error")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("unjail", "Unjail a person", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        local playerId = tonumber(args[1])
        TriggerClientEvent("prison:client:UnjailPerson", playerId)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("clearblood", "Clear nearby blood (make sure you've picked some up)", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("evidence:client:ClearBlooddropsInArea", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("seizecash", "Take cash from the nearest person", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
        TriggerClientEvent("police:client:SeizeCash", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("sc", "Handcuff someone but allowed to walk", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:CuffPlayerSoft", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("cam", "View security camera", {{name="camid", help="Camera ID"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:ActiveCamera", source, tonumber(args[1]))
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

RegisterNetEvent("police:server:AddToFlagPlates")
AddEventHandler("police:server:AddToFlagPlates", function(reasonMessage, plate)
    if not Plates[plate:upper()] or Plates[plate:upper()] == nil then
        Plates[plate:upper()] = {
            isflagged = true,
            reason = reasonMessage
        }
    end
end)

BJCore.Commands.Add("flagplate", "Flag a vehicle", {{name="plate", help="Vehicle Plate"}, {name="reason", help="Reason of flagging the vehicle"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    
    if Player.PlayerData.job.name == "police" then
        local reason = {}
        for i = 2, #args, 1 do
            table.insert(reason, args[i])
        end
        Plates[args[1]:upper()] = {
            isflagged = true,
            reason = table.concat(reason, " ")
        }
        TriggerClientEvent('BJCore:Notify', source, "Vehicle ("..args[1]:upper()..") is flagged for: "..table.concat(reason, " "))
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("unflagplate", "Unflag a vehicle", {{name="plate", help="Vehicle Plate"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        if Plates ~= nil and Plates[args[1]:upper()] ~= nil then
            if Plates[args[1]:upper()].isflagged then
                Plates[args[1]:upper()].isflagged = false
                TriggerClientEvent('BJCore:Notify', source, "Vehicle ("..args[1]:upper()..") is unflagged")
            else
                TriggerClientEvent('chatMessage', source, "REPORTING ROOM", "error", "Vehicle is not flagged")
            end
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Vehicle is not flagged")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("plateinfo", "Check plate for flags", {{name="plate", help="Vehicle Plate"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        if Plates ~= nil and Plates[args[1]:upper()] ~= nil then
            if Plates[args[1]:upper()].isflagged then
                TriggerClientEvent('chatMessage', source, "REPORTING ROOM", "normal", "Vehicle ("..args[1]:upper()..") has been flagged for: "..Plates[args[1]:upper()].reason)
            else
                TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Vehicle is not flagged")
            end
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Vehicle is not flagged")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("depot", "Send a vehicle to the depot", {{name="price", help="Price for how much the person has to pay (or 0)"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:ImpoundVehicle", source, false, tonumber(args[1]))
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("impound", "Impound a vehicle", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:ImpoundVehicle", source, true)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("paytow", "Pay a tow worker", {{name="id", help="ID of the player"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance" then
        local playerId = tonumber(args[1])
        local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
        if OtherPlayer ~= nil then
            if OtherPlayer.PlayerData.job.name == "tow" then
                OtherPlayer.Functions.AddMoney("bank", 500, "police-tow-paid")
                TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "SYSTEM", "warning", "You received "..BJCore.Config.Currency.Symbol.." 500 for your service")
                TriggerClientEvent('BJCore:Notify', source, 'You paid a bergnet worker')
            else
                TriggerClientEvent('BJCore:Notify', source, 'Person is not a bergnet worker', "error")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("paylaw", "Pay a lawyer", {{name="id", help="ID of the player"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "judge" then
        local playerId = tonumber(args[1])
        local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
        if OtherPlayer ~= nil then
            if OtherPlayer.PlayerData.job.name == "lawyer" then
                OtherPlayer.Functions.AddMoney("bank", 500, "police-lawyer-paid")
                TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "SYSTEM", "warning", "You received "..BJCore.Config.Currency.Symbol.." 500 for your pro bono case")
                TriggerClientEvent('BJCore:Notify', source, 'You paid a lawyer')
            else
                TriggerClientEvent('BJCore:Notify', source, 'Person is not a lawyer', "error")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("radar", "Toggle speedradar", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("wk:toggleRadar", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Functions.CreateUseableItem("spikestrip", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        Player.Functions.RemoveItem(item.name, 1, item.slot)
        TriggerClientEvent("police:client:DeploySpikeStrips", source)
    end
end)

BJCore.Functions.CreateUseableItem("handcuffs", function(source, item)
    print(BJCore.Common.Dump(item))
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("police:client:CuffPlayerSoft", source)
    end
end)

BJCore.Commands.Add("911", "Send a report to emergency services", {{name="message", help="Message you want to send"}}, true, function(source, args)
    local message = table.concat(args, " ")
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.Functions.GetItemByName("phone") ~= nil then
        TriggerClientEvent('chatMessage', Player.PlayerData.source, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. " > 911", "warning", message)
        TriggerClientEvent("police:client:SendEmergencyMessage", source, message)
        TriggerEvent("bj-log:server:CreateLog", "911", "911 alert", "blue", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Alert:** " ..message, false)
    else
        TriggerClientEvent('BJCore:Notify', source, 'You dont have a phone', 'error')
    end
end)

BJCore.Commands.Add("911a", "Send an anonymous report to emergency services (gives no location)", {{name="message", help="Message you want to send"}}, true, function(source, args)
    local message = table.concat(args, " ")
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.Functions.GetItemByName("phone") ~= nil then
        TriggerClientEvent('chatMessage', Player.PlayerData.source, "Anonymous > 911", "warning", message)
        TriggerClientEvent("police:client:CallAnim", source)
        TriggerClientEvent('police:client:Send112AMessage', -1, message)
    else
        TriggerClientEvent('BJCore:Notify', source, 'You dont have a phone', 'error')
    end
end)

BJCore.Commands.Add("911r", "Send a message back to an alert", {{name="id", help="ID of the alert"}, {name="message", help="Message you want to send"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local OtherPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
    table.remove(args, 1)
    local message = table.concat(args, " ")
    local Prefix = "POLICE"
    if (Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") then
        Prefix = "AMBULANCE"
    end
    if OtherPlayer ~= nil then 
        TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "("..Prefix..") " ..Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, "error", message)
        TriggerClientEvent("police:client:EmergencySound", OtherPlayer.PlayerData.source)
        TriggerClientEvent("police:client:CallAnim", source)
        TriggerClientEvent('police:client:Send911Reply', -1, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname.." > "..OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .."("..OtherPlayer.PlayerData.source..")", message, "error")  
        --TriggerEvent("bj-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)     
    end
end)

BJCore.Commands.Add("311", "Send a message to emergency services", {{name="message", help="Message you want to send"}}, true, function(source, args)
    local message = table.concat(args, " ")
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.Functions.GetItemByName("phone") ~= nil then
        TriggerClientEvent('chatMessage', Player.PlayerData.source, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. " > 311", "warning", message)
        TriggerClientEvent("police:client:Send311Message", source, message)
        TriggerEvent("bj-log:server:CreateLog", "311", "311 message", "orange", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
    else
        TriggerClientEvent('BJCore:Notify', source, 'You dont have a phone', 'error')
    end
end)

BJCore.Commands.Add("311a", "Send an anonymous message to emergency services (gives no location)", {{name="message", help="Message you want to send"}}, true, function(source, args)
    local message = table.concat(args, " ")
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.Functions.GetItemByName("phone") ~= nil then
        TriggerClientEvent('chatMessage', Player.PlayerData.source, "Anonymous > 311", "warning", message)
        TriggerClientEvent("police:client:CallAnim", source)
        TriggerClientEvent('police:client:Send311AMessage', -1, message)
    else
        TriggerClientEvent('BJCore:Notify', source, 'You dont have a phone', 'error')
    end
end)

BJCore.Commands.Add("311r", "Send a message back to a 311 message", {{name="id", help="ID of the alert"}, {name="message", help="Message you want to send"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local OtherPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
    table.remove(args, 1)
    local message = table.concat(args, " ")
    local Prefix = "POLICE"
    if (Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") then
        Prefix = "AMBULANCE"
    end
    if OtherPlayer ~= nil then 
        TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "("..Prefix..") " ..Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, "error", message)
        TriggerClientEvent("police:client:CallAnim", source)
        TriggerClientEvent('police:client:Send311Reply', -1, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname.." > "..OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .."("..OtherPlayer.PlayerData.source..")", message, "error")  
        --TriggerEvent("bj-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)     
    end
end)

BJCore.Commands.Add("anklet", "Put an anklet on the nearest person.", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("police:client:CheckDistance", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("ankletlocation", "remove an anklet off the nearest person", {{"bsn", "BSN of person"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    
    if Player.PlayerData.job.name == "police" then
        if args[1] ~= nil then
            local citizenid = args[1]
            local Target = BJCore.Functions.GetPlayerByCitizenId(citizenid)

            if Target ~= nil then
                if Target.PlayerData.metadata["tracker"] then
                    TriggerClientEvent("police:client:SendTrackerLocation", Target.PlayerData.source, source)
                else
                    TriggerClientEvent('BJCore:Notify', source, 'This person does not have an anklet.', 'error')
                end
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
    end
end)

BJCore.Commands.Add("ebutton", "Send a message back to a notification", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if ((Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") and Player.PlayerData.job.onduty) then
        TriggerClientEvent("police:client:SendPoliceEmergencyAlert", source)
    end
end)

BJCore.Commands.Add("takedrivinglicense", "Take the driving license from someone", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if ((Player.PlayerData.job.name == "police") and Player.PlayerData.job.onduty) then
        TriggerClientEvent("police:client:SeizeDriverLicense", source)
    end
end)

BJCore.Commands.Add("takedna", "Take a DNA sample from a person (empty evidence bag needed)", {{name="id", help="ID of the person"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local OtherPlayer = BJCore.Functions.GetPlayer(tonumber(args[1]))
    if ((Player.PlayerData.job.name == "police") and Player.PlayerData.job.onduty) and OtherPlayer ~= nil then
        if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
            local info = {
                label = "DNA Sample",
                type = "dna",
                dnalabel = DnaHash(OtherPlayer.PlayerData.citizenid),
            }
            if Player.Functions.AddItem("filled_evidence_bag", 1, false, info) then
                TriggerClientEvent("inventory:client:ItemBox", source, BJCore.Shared.Items["filled_evidence_bag"], "add")
            end
        else
            TriggerClientEvent('BJCore:Notify', source, "You need an empty evidence bag", "error")
        end
    end
end)

BJCore.Functions.CreateUseableItem("filled_evidence_bag", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        if item.info ~= nil and item.info ~= "" and item.info.cash then
            if Player.PlayerData.job.name ~= "police" then
                if Player.Functions.RemoveItem("filled_evidence_bag", 1, item.slot) then
                    Player.Functions.AddMoney("cash", tonumber(item.info.cash), "Evidence Bag of Money used")
                end
            end
        end
    end
end)

function GetCurrentCops()
    local amount = 0
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    return amount
end

BJCore.Functions.RegisterServerCallback('police:server:IsPoliceForcePresent', function(source, cb)
    local retval = false
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            for _, citizenid in pairs(Config.ArmoryWhitelist) do
                if citizenid == Player.PlayerData.citizenid then
                    retval = true
                    break
                end
            end
        end
    end
    cb(retval)
end)

function DnaHash(s)
    local h = string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return h
end

local SpikeStrips = {}

RegisterNetEvent("police:server:RequestSpikes", function()
    TriggerClientEvent("police:client:SyncSpikes", source, SpikeStrips)
end)

RegisterNetEvent("police:server:AddSpikes", function(data)
    table.insert(SpikeStrips, data)
    TriggerClientEvent('police:client:SyncSpikes', -1, SpikeStrips)
end)

RegisterNetEvent("police:server:RemoveSpikes", function(id)
    table.remove(SpikeStrips, id)
    TriggerClientEvent('police:client:SyncSpikes', -1, SpikeStrips)
end)

RegisterServerEvent('police:server:SyncSpikes')
AddEventHandler('police:server:SyncSpikes', function(table)
    TriggerClientEvent('police:client:SyncSpikes', -1, table)
end)

-- Prison
local AlarmActivated = false

RegisterServerEvent('prison:server:SetJailStatus')
AddEventHandler('prison:server:SetJailStatus', function(jailTime)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("injail", jailTime)
    if jailTime > 0 then
        if Player.PlayerData.job.name ~= "unemployed" then
            Player.Functions.SetJob("unemployed", 1)
            TriggerClientEvent('BJCore:Notify', src, "You are unemployed")
        end
    end
end)

RegisterServerEvent('prison:server:SaveJailItems')
AddEventHandler('prison:server:SaveJailItems', function(jailTime)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local amount = 10
    if Player.PlayerData.metadata["jailitems"] == nil or next(Player.PlayerData.metadata["jailitems"]) == nil then 
        TriggerEvent("bj-log:server:CreateLog", "police", "Police Jail", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has been jailed. Items stored until released: "..BJCore.Common.Dump(Player.PlayerData.items))
        Player.Functions.SetMetaData("jailitems", Player.PlayerData.items)
        Player.Functions.AddMoney('cash', 80)
        Citizen.Wait(2000)
        Player.Functions.ClearInventory()
    end
end)

RegisterServerEvent('prison:server:GiveJailItems')
AddEventHandler('prison:server:GiveJailItems', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.Functions.ClearInventory()
    Citizen.Wait(1000)
    TriggerEvent("bj-log:server:CreateLog", "police", "Police Jail", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has been released from jail. Items returned to player: "..BJCore.Common.Dump(Player.PlayerData.metadata["jailitems"]))
    for k, v in pairs(Player.PlayerData.metadata["jailitems"]) do
        Player.Functions.AddItem(v.name, v.amount, v.slot, v.info)
    end
    Citizen.Wait(1000)
    Player.Functions.SetMetaData("jailitems", {})
end)

RegisterServerEvent('prison:server:SecurityLockdown')
AddEventHandler('prison:server:SecurityLockdown', function()
    local src = source
    TriggerClientEvent("prison:client:SetLockDown", -1, true)
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("prison:client:PrisonBreakAlert", v)
            end
        end
    end
end)

RegisterServerEvent('prison:server:SetGateHit')
AddEventHandler('prison:server:SetGateHit', function(key)
    local src = source
    TriggerClientEvent("prison:client:SetGateHit", -1, key, true)
    if math.random(1, 100) <= 50 then
        for k, v in pairs(BJCore.Functions.GetPlayers()) do
            local Player = BJCore.Functions.GetPlayer(v)
            if Player ~= nil then 
                if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                    TriggerClientEvent("prison:client:PrisonBreakAlert", v)
                end
            end
        end
    end
end)

RegisterServerEvent('prison:server:CheckRecordStatus')
AddEventHandler('prison:server:CheckRecordStatus', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local CriminalRecord = Player.PlayerData.metadata["criminalrecord"]
    local currentDate = os.date("*t")

    if (CriminalRecord["date"].month + 1) == 13 then
        CriminalRecord["date"].month = 0
    end

    if CriminalRecord["hasRecord"] then
        if currentDate.month == (CriminalRecord["date"].month + 1) or currentDate.day == (CriminalRecord["date"].day - 1) then
            CriminalRecord["hasRecord"] = false
            CriminalRecord["date"] = nil
        end
    end
end)

RegisterServerEvent('prison:server:JailAlarm')
AddEventHandler('prison:server:JailAlarm', function()
    if not AlarmActivated then
        TriggerClientEvent('prison:client:JailAlarm', -1, true)
        SetTimeout(5 * (60 * 1000), function()
            TriggerClientEvent('prison:client:JailAlarm', -1, false)
        end)
    end
end)

RegisterServerEvent('police:server:createIdentityCard')
AddEventHandler('police:server:createIdentityCard', function(metadata)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    Player.Functions.AddItem("id_card", 1, false, metadata)
    TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["id_card"], "add")
end)

BJCore.Functions.CreateUseableItem("electronickit", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("electronickit:UseElectronickit", source)
    end
end)

BJCore.Functions.RegisterServerCallback('prison:server:IsAlarmActive', function(source, cb)
    cb(AlarmActivated)
end)

RegisterNetEvent('tackleTarget')
AddEventHandler('tackleTarget', function(target)
    TriggerClientEvent('tacklePlayer', target)
end)

BJCore.Commands.Add("rungunserial", "Check gun serial number for details", {{name="serial", help="Weapon Serial"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" and IsUCCommand(Player.PlayerData.citizenid) then
        BJCore.Functions.ExecuteSql(true, "SELECT * FROM `weapon_records`", function(result)
            local found = false
            if result and result[1] ~= nil then
                for k,v in pairs(result) do
                    local data = json.decode(v.data)
                    
                    if data.serial == args[1] then
                        found = true
                        BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.citizenid.."'", function(Tresult)
                            if Tresult and Tresult[1] ~= nil then
                                local charInfo = json.decode(Tresult[1].charinfo)
                                TriggerClientEvent('chatMessage', source, "INFO", "warning", "Serial: "..data.serial.." | Weapon: "..data.weapon.." | Registered Purchaser: "..charInfo.firstname.." "..charInfo.lastname)
                            end
                        end)
                        return
                    end
                end
                if not found then
                    TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, "Matching data not found. Unregistered weapon", "error")
                end                
            end
        end)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services CID unit")
    end
end)

BJCore.Functions.CreateUseableItem("police_stormram", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
        TriggerClientEvent("police:client:stormram", source)
    end
end)

-- BJCore.Commands.Add("scanseatbelts", "Be alerted if you have LOS on a player with no seatbelt", {}, false, function(source, args)
--     local Myself = BJCore.Functions.GetPlayer(source)
--     if Myself ~= nil then 
--         if Myself.PlayerData.job.name == "police" then
--             if Myself.PlayerData.job.onduty then
--                 TriggerClientEvent("police:client:toggleSeatScan", source)
--             else
--                 TriggerClientEvent('BJCore:Notify', source, "You need to be on duty to use this", "error")
--             end
--         end
--     end
-- end)

-- RegisterNetEvent("police:server:requestStatus")
-- AddEventHandler("police:server:requestStatus", function(target, veh)
--     local src = source
--     TriggerClientEvent("police:client:getStatus", target, src, veh)
-- end)

-- RegisterNetEvent("police:server:returnStatus")
-- AddEventHandler("police:server:returnStatus", function(origin, veh)
--     TriggerClientEvent("police:client:returnStatus", origin, veh)
-- end)
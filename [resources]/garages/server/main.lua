local OutsideVehicles = {}

Citizen.CreateThread(function()
    exports['ghmattimysql']:execute('UPDATE player_vehicles SET state = 1 WHERE `type` != "vehicle" AND `state` != 2', {})
end)

RegisterServerEvent('garages:server:RemoveVehicle')
AddEventHandler('garages:server:RemoveVehicle', function(CitizenId, Plate)
    if OutsideVehicles[CitizenId] ~= nil then
        OutsideVehicles[CitizenId][Plate] = nil
    end
end)

RegisterServerEvent('garages:server:UpdateOutsideVehicles')
AddEventHandler('garages:server:UpdateOutsideVehicles', function(Vehicles)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)
    local CitizenId = Ply.PlayerData.citizenid

    OutsideVehicles[CitizenId] = Vehicles
end)

BJCore.Functions.RegisterServerCallback("garages:server:GetOutsideVehicles", function(source, cb)
    local Ply = BJCore.Functions.GetPlayer(source)
    local CitizenId = Ply.PlayerData.citizenid

    if OutsideVehicles[CitizenId] ~= nil and next(OutsideVehicles[CitizenId]) ~= nil then
        cb(OutsideVehicles[CitizenId])
    else
        cb(nil)
    end
end)

BJCore.Functions.RegisterServerCallback("garages:server:GetUserVehicles", function(source, cb, garage)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND garage = @garage', {['@citizenid'] = pData.PlayerData.citizenid, ['@garage'] = garage}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                if v.status ~= nil then
                    v.status = json.decode(v.status)
                end
            end
            cb(result)
        else
            cb(nil)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:GetVehicleProperties", function(source, cb, plate)
    local src = source
    local properties = {}
    BJCore.Functions.ExecuteSql(false, "SELECT `mods` FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            properties = json.decode(result[1].mods)
        end
        cb(properties)
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:GetDepotVehicles", function(source, cb)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND state = @state', {['@citizenid'] = pData.PlayerData.citizenid, ['@state'] = 0}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                if v.status ~= nil then
                    v.status = json.decode(v.status)
                end
            end
            cb(result)
        else
            cb(nil)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:checkVehicleOwner", function(source, cb, plate, type)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate AND citizenid = @citizenid AND `type` = @type', {['@plate'] = plate, ['@citizenid'] = pData.PlayerData.citizenid, ['@type'] = type}, function(result)
        if result and result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:GetHouseVehicles", function(source, cb, house)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE garage = @garage', {['@garage'] = house}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                if v.status ~= nil then
                    v.status = json.decode(v.status)
                end
            end
            cb(result)
        else
            cb(nil)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:checkVehicleHouseOwner", function(source, cb, plate, house)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            local hasHouseKey = exports['houses']:hasKey(result[1].steam, result[1].citizenid, house)
            if hasHouseKey then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('garages:server:PayDepotPrice')
AddEventHandler('garages:server:PayDepotPrice', function(vehicle, garage)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate', {['@plate'] = vehicle.plate}, function(result)
        if result[1] ~= nil then
            if Player.Functions.RemoveMoney("cash", result[1].depotprice, "paid-depot") then
                TriggerClientEvent("garages:client:takeOutDepot", src, vehicle, garage)
            elseif bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney("bank", result[1].depotprice, "paid-depot")
                TriggerClientEvent("garages:client:takeOutDepot", src, vehicle, garage)
            end
        end
    end)
end)

RegisterServerEvent('garages:server:updateVehicleState')
AddEventHandler('garages:server:updateVehicleState', function(state, plate, garage)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('UPDATE player_vehicles SET state = @state, garage = @garage, depotprice = @depotprice WHERE plate = @plate AND state != 3', {['@state'] = state, ['@plate'] = plate, ['@depotprice'] = 0, ['@citizenid'] = pData.PlayerData.citizenid, ['@garage'] = garage})
end)

RegisterServerEvent('garages:server:updateVehicleStatus')
AddEventHandler('garages:server:updateVehicleStatus', function(fuel, engine, body, plate, garage, properties)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    if engine > 1000 then
        engine = engine / 1000
    end

    if body > 1000 then
        body = body / 1000
    end
    
    exports['ghmattimysql']:execute('UPDATE player_vehicles SET mods = @mods, fuel = @fuel, engine = @engine, body = @body WHERE plate = @plate', {
        ['@mods'] = json.encode(properties),
        ['@fuel'] = fuel, 
        ['@engine'] = engine, 
        ['@body'] = body,
        ['@plate'] = plate,
    })
end)

BJCore.Functions.RegisterServerCallback("garages:server:checkJobVehicle", function(source, cb, plate, job)
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE plate = @plate AND job = @job', {['@plate'] = plate, ['@job'] = job}, function(result)
        if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback("garages:server:getJobVehicle", function(source, cb, job)
    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE `job` = @job', {['@job'] = job}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                if v.status ~= nil then
                    v.status = json.decode(v.status)
                end
            end
            cb(result)
        else
            cb(nil)
        end
    end)
end)

BJCore.Commands.Add("addjobvehicle", "Add vehicle to job garage", {{name="job", help="Job name (not label)"}}, true, function(source, args)
    local src = source
    if BJCore.Shared.Jobs[args[1]] ~= nil then
        TriggerClientEvent("garages:client:getCurVehicle", src, args[1])
    else
        TriggerClientEvent("BJCore:Notify", src, "Invalid job", "error", 2500)
    end
end, "god")

RegisterNetEvent("garages:server:returnVehicleData")
AddEventHandler("garages:server:returnVehicleData", function(model, job)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)
    local plate = exports["vehicleshop"]:GeneratePlate()
    TriggerClientEvent('bj-admin:client:setVehicle', src, plate)
    BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`vehicle`, `hash`, `mods`, `plate`, `state`, `job`) VALUES ('"..model.."', '"..GetHashKey(model).."', '{}', '"..plate.."', 0, '"..job.."')")
    TriggerClientEvent("BJCore:Notify", src, "Vehicle: "..model.." with plate: "..plate.." has been saved to "..job.."'s garage", "success", 5000)
    TriggerEvent("bj-log:server:CreateLog", "bans", "Vehicle to Job Garage", "**"..pData.PlayerData.name.."** "..pData.PlayerData.citizenid.." has given vehicle: "..model.." with plate: "..plate.." to "..job.."'s garage") 
end)
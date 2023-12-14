RegisterServerEvent('customs:server:UpdateBusyState')
AddEventHandler('customs:server:UpdateBusyState', function(k, bool)
    Customs.Locations[k]["busy"] = bool
    TriggerClientEvent('customs:client:UpdateBusyState', -1, k, bool)
end)

RegisterServerEvent('customs:print')
AddEventHandler('customs:print', function(data)
    print(data)
end)

BJCore.Functions.RegisterServerCallback('customs:server:CanPurchase', function(source, cb, price)
    local Player = BJCore.Functions.GetPlayer(source)
    local CanBuy = false

    if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        CanBuy = true
    else
        CanBuy = false
    end

    cb(CanBuy)
end)

RegisterServerEvent("customs:server:SaveVehicleProps")
AddEventHandler("customs:server:SaveVehicleProps", function(vehicleProps)
	local src = source
    if IsVehicleOwned(vehicleProps.plate) then
        BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `mods` = '"..json.encode(vehicleProps).."' WHERE `plate` = '"..vehicleProps.plate.."'")
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end

-- Vehicle tuning
local VehicleStatus = {}
local VehicleDrivingDistance = {}

local ThrottleNext = GetGameTimer()
local PendingThrottledPlates = {}
local ThrottleDiff = 10000

function ThrottleStatus(plate)
	PendingThrottledPlates[plate] = VehicleStatus[plate]
	if ThrottleNext < GetGameTimer() then
		TriggerClientEvent("vehiclemod:client:setVehicleStatusList", -1, PendingThrottledPlates)
		ThrottleNext = GetGameTimer() + ThrottleDiff
		PendingThrottledPlates = {}
	end
end

BJCore.Functions.RegisterServerCallback('vehicletuning:server:GetDrivingDistances', function(source, cb)
    cb(VehicleDrivingDistance)
end)

RegisterServerEvent("vehiclemod:server:setupVehicleStatus")
AddEventHandler("vehiclemod:server:setupVehicleStatus", function(plate, engineHealth, bodyHealth)
    local src = source
    local engineHealth = engineHealth ~= nil and engineHealth or 1000.0
    local bodyHealth = bodyHealth ~= nil and bodyHealth or 1000.0
    if VehicleStatus[plate] == nil then 
        if IsVehicleOwned(plate) then
            local statusInfo = GetVehicleStatus(plate)
            if statusInfo == nil then 
                statusInfo =  {
                    ["engine"] = engineHealth,
                    ["body"] = bodyHealth,
                    ["radiator"] = Config.MaxStatusValues["radiator"],
                    ["axle"] = Config.MaxStatusValues["axle"],
                    ["brakes"] = Config.MaxStatusValues["brakes"],
                    ["clutch"] = Config.MaxStatusValues["clutch"],
                    ["fuel"] = Config.MaxStatusValues["fuel"],
                }
            end
            VehicleStatus[plate] = statusInfo
            --TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, statusInfo)
			ThrottleStatus(plate)
        else
            local statusInfo = {
                ["engine"] = engineHealth,
                ["body"] = bodyHealth,
                ["radiator"] = Config.MaxStatusValues["radiator"],
                ["axle"] = Config.MaxStatusValues["axle"],
                ["brakes"] = Config.MaxStatusValues["brakes"],
                ["clutch"] = Config.MaxStatusValues["clutch"],
                ["fuel"] = Config.MaxStatusValues["fuel"],
            }
            VehicleStatus[plate] = statusInfo
            --TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, statusInfo)
			ThrottleStatus(plate)
        end
    else
        --TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
		ThrottleStatus(plate)
    end
end)

RegisterServerEvent('vehicletuning:server:UpdateDrivingDistance')
AddEventHandler('vehicletuning:server:UpdateDrivingDistance', function(amount, plate)
    VehicleDrivingDistance[plate] = amount

    TriggerClientEvent('vehicletuning:client:UpdateDrivingDistance', -1, VehicleDrivingDistance[plate], plate)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `drivingdistance` = '"..amount.."' WHERE `plate` = '"..plate.."'")
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('vehicletuning:server:IsVehicleOwned', function(source, cb, plate)
    local retval = false
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
        cb(retval)
    end)
end)

RegisterServerEvent('vehicletuning:server:LoadStatus')
AddEventHandler('vehicletuning:server:LoadStatus', function(veh, plate)
    VehicleStatus[plate] = veh
    TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, veh)
end)

RegisterServerEvent("vehiclemod:server:updatePart")
AddEventHandler("vehiclemod:server:updatePart", function(plate, part, level)
    if VehicleStatus[plate] ~= nil then
        if part == "engine" or part == "body" then
            VehicleStatus[plate][part] = level
            if VehicleStatus[plate][part] < 0 then
                VehicleStatus[plate][part] = 0
            elseif VehicleStatus[plate][part] > 1000 then
                VehicleStatus[plate][part] = 1000.0
            end
        else
            VehicleStatus[plate][part] = level
            if VehicleStatus[plate][part] < 0 then
                VehicleStatus[plate][part] = 0
            elseif VehicleStatus[plate][part] > 100 then
                VehicleStatus[plate][part] = 100
            end
        end
        --TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
		ThrottleStatus(plate)
    end
end)

RegisterServerEvent('vehicletuning:server:SetPartLevel')
AddEventHandler('vehicletuning:server:SetPartLevel', function(plate, part, level)
    if VehicleStatus[plate] ~= nil then
        VehicleStatus[plate][part] = level
        --TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
		ThrottleStatus(plate)
    end
end)

RegisterServerEvent("vehiclemod:server:fixEverything")
AddEventHandler("vehiclemod:server:fixEverything", function(plate)
    if VehicleStatus[plate] ~= nil then 
        for k, v in pairs(Config.MaxStatusValues) do
            VehicleStatus[plate][k] = v
        end
        TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, VehicleStatus[plate])
    end
end)

RegisterServerEvent("vehiclemod:server:saveStatus")
AddEventHandler("vehiclemod:server:saveStatus", function(plate)
    if VehicleStatus[plate] ~= nil then
        exports['ghmattimysql']:execute('UPDATE player_vehicles SET status = @status WHERE plate = @plate', {['@status'] = json.encode(VehicleStatus[plate]), ['@plate'] = plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end

function GetVehicleStatus(plate)
    local retval = nil
    BJCore.Functions.ExecuteSql(true, "SELECT `status` FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = result[1].status ~= nil and json.decode(result[1].status) or nil
        end
    end)
    return retval
end

BJCore.Commands.Add("setvehiclestatus", "Set vehicle status", {{name="part", help="Type of status you want to edit"}, {name="amount", help="Level of the status"}}, true, function(source, args)
    local part = args[1]:lower()
    local level = tonumber(args[2])
    TriggerClientEvent("vehiclemod:client:setPartLevel", source, part, level)
end, "god")

BJCore.Functions.RegisterServerCallback('vehicletuning:server:GetAttachedVehicle', function(source, cb)
    cb(Config.Plates)
end)

BJCore.Functions.RegisterServerCallback('vehicletuning:server:IsMechanicAvailable', function(source, cb)
    local amount = 0
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "mechanic" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    cb(amount)
end)

RegisterServerEvent('vehicletuning:server:SetAttachedVehicle')
AddEventHandler('vehicletuning:server:SetAttachedVehicle', function(veh, k)
    if veh ~= false then
        Config.Plates[k].AttachedVehicle = veh
        TriggerClientEvent('vehicletuning:client:SetAttachedVehicle', -1, veh, k)
    else
        Config.Plates[k].AttachedVehicle = nil
        TriggerClientEvent('vehicletuning:client:SetAttachedVehicle', -1, false, k)
    end
end)

RegisterServerEvent('vehicletuning:server:CheckForItems')
AddEventHandler('vehicletuning:server:CheckForItems', function(part)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local RepairPart = Player.Functions.GetItemByName(Config.RepairCostAmount[part].item)

    if RepairPart ~= nil then
        if RepairPart.amount >= Config.RepairCostAmount[part].costs then
            TriggerClientEvent('vehicletuning:client:RepaireeePart', src, part)
            Player.Functions.RemoveItem(Config.RepairCostAmount[part].item, Config.RepairCostAmount[part].costs)

            for i = 1, Config.RepairCostAmount[part].costs, 1 do
                TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[Config.RepairCostAmount[part].item], "remove")
                Citizen.Wait(500)
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "You don't have enough "..BJCore.Shared.Items[Config.RepairCostAmount[part].item]["label"].." (min. "..Config.RepairCostAmount[part].costs.."x)", "error")
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "You don't have "..BJCore.Shared.Items[Config.RepairCostAmount[part].item]["label"].." with you", "error")
    end
end)

function IsAuthorized(CitizenId)
    local retval = false
    for _, cid in pairs(Config.GroveStCustomAuthorized) do
        if cid == CitizenId then
            retval = true
            break
        end
    end
    return retval
end

BJCore.Commands.Add("setgrovest", "Give player Grove Street Customs job", {{name="id", help="ID of the player"}, {name="grade", help="Job grade number"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = BJCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                if TargetData.Functions.SetJob("grovestcustom", tonumber(args[2])) then
                    TriggerClientEvent('BJCore:Notify', TargetData.PlayerData.source, "You have been hired by Grove Street Customs")
                    TriggerClientEvent('BJCore:Notify', source, "You have hired ("..TargetData.PlayerData.charinfo.firstname..") as a Grove Street Customs employee")
                end
            end
        else
            TriggerClientEvent('BJCore:Notify', source, "You must provide a player ID")
        end
    else
        TriggerClientEvent('BJCore:Notify', source, "You cannot use this", "error") 
    end
end)

BJCore.Commands.Add("takegrovestreet", "Remove Grove Street Customs job from player", {{name="id", help="ID of the player"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = BJCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                if TargetData.PlayerData.job.name == "mechanic" then
                    if TargetData.Functions.SetJob("unemployed", 1) then
                        TriggerClientEvent('BJCore:Notify', TargetData.PlayerData.source, "You have been fired from Grove Street Customs")
                        TriggerClientEvent('BJCore:Notify', source, "You have fired ("..TargetData.PlayerData.charinfo.firstname..") from Grove Street Customs")
                    end
                else
                    TriggerClientEvent('BJCore:Notify', source, "This is not a Grove Street Customs employee", "error")
                end
            end
        else
            TriggerClientEvent('BJCore:Notify', source, "You must provide a player ID", "error")
        end
    else
        TriggerClientEvent('BJCore:Notify', source, "You cannot use this", "error")
    end
end)

BJCore.Functions.RegisterServerCallback('vehicletuning:server:GetStatus', function(source, cb, plate)
    if VehicleStatus[plate] ~= nil and next(VehicleStatus[plate]) ~= nil then
        cb(VehicleStatus[plate])
    else
        cb(nil)
    end
end)

-- Mech

RegisterServerEvent('mech:server:removeItem')
AddEventHandler('mech:server:removeItem', function(item, amount)
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    pData.Functions.RemoveItem(item, amount)
end)

RegisterServerEvent('mech:server:requestRepair')
AddEventHandler('mech:server:requestRepair', function(veh, isAdvanced)
    local _source = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
    TriggerClientEvent("mech:client:doRepair", owner, veh, isAdvanced)
end)

RegisterServerEvent('mech:server:requestClean')
AddEventHandler('mech:server:requestClean', function(veh)
    local _source = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
    TriggerClientEvent("mech:client:doClean", owner, veh)
end)

BJCore.Functions.CreateUseableItem("platekit", function(source, item)
    local rndPlate = exports["vehicleshop"]:GeneratePlate()
    TriggerClientEvent("mech:client:attemptFakePlate", source, rndPlate)
end)

RegisterNetEvent("mech:server:applyFakePlate", function(veh, plate)
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
    TriggerClientEvent("mech:client:applyFakePlate", owner, veh, plate)
end)

RegisterNetEvent("mech:server:removeFakePlate", function(veh, plate)
    local vehEnt = NetworkGetEntityFromNetworkId(veh)
    if Entity(vehEnt).state.fakeplate then
        local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
        TriggerClientEvent("mech:client:removeFakePlate", owner, veh)
    end
end)
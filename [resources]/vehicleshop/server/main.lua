local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

local dealersOnline = {}
Citizen.CreateThread(function()
    while true do
        GetDealersOnline()
        Citizen.Wait(60000)
    end
end)

function GetDealersOnline()
    dealersOnline = {}
    for job,_ in pairs(Config.VehicleShops) do
        dealersOnline[job] = 0
        for k, v in pairs(BJCore.Functions.GetPlayers()) do
            local Player = BJCore.Functions.GetPlayer(v)
            if Player ~= nil then 
                if Player.PlayerData.job.name == job and Player.PlayerData.job.onduty then
                    dealersOnline[job] = dealersOnline[job] + 1
                end
            end
        end
    end
    TriggerClientEvent("vehicleshop:client:dealersOnline", -1, dealersOnline)
end

RegisterNetEvent("vehicleshop:server:dealersOnline")
AddEventHandler("vehicleshop:server:dealersOnline", function() TriggerClientEvent("vehicleshop:client:dealersOnline", source, dealersOnline) end)

RegisterNetEvent("vehicleshop:server:updateDealersOnline")
AddEventHandler("vehicleshop:server:updateDealersOnline", function() GetDealersOnline() end)

RegisterNetEvent("vehicleshop:server:sellVehicle")
AddEventHandler("vehicleshop:server:sellVehicle", function(targetPly, curShop, vData, vType)
    local src = source
    vData.vehicletype = vType
    if vData.data.finance then
        vData.data.price = vData.data.price+(vData.data.price*(vData.data.interest/100))
    end
    TriggerClientEvent("vehiceleshop:client:requestSale", tonumber(targetPly), curShop, vData, src)
end)

RegisterNetEvent('vehicleshop:server:buyVehicle')
AddEventHandler('vehicleshop:server:buyVehicle', function(saleData)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)
    local balance = pData.PlayerData.money["bank"]
    local plate = GeneratePlate()
    local sale = false
    if saleData.vData.data.finance then
        local downPayment = math.ceil(saleData.vData.data.price*(saleData.vData.data.down/100))
        if (balance - downPayment) >= 0 then
            if pData.Functions.RemoveMoney("bank", downPayment) then
                local financedAmount = math.ceil(saleData.vData.data.price-downPayment)
                local financeData = {
                    dealership = saleData.shopData.val.label,
                    totalPrice = math.floor(saleData.vData.data.price),
                    downPayment = saleData.vData.data.down,
                    repayments = saleData.vData.data.repayments,
                    repaymentAmount = math.ceil(financedAmount/saleData.vData.data.repayments),
                    completedPayments = 0,
                    interest = saleData.vData.data.interest,
                    daysLeft = 7,
                    balance = financedAmount,
                    overdue = 0,
                }
                BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `type`, `hash`, `mods`, `plate`, `garage`, `financeData`) VALUES (@steam, @citizenid, @vehicle, @type, @hash, @mods, @plate, @garage, @financeData)", nil, {
                    ['@steam'] = pData.PlayerData.steam,
                    ['@citizenid'] = pData.PlayerData.citizenid,
                    ['@vehicle'] = saleData.vData.data.vehicle,
                    ['@type'] = saleData.vData.vehicletype,
                    ['@hash'] = GetHashKey(saleData.vData.data.vehicle),
                    ['@mods'] = '{}',
                    ['@plate'] = plate,
                    ['@garage'] = Config.DefaultGarage[saleData.vData.vehicletype],
                    ['@financeData'] = json.encode(financeData)
                })
                TriggerClientEvent("BJCore:Notify", src, "Vehicle purchased. Plate: "..plate, "success", 5000)
                sale = true
                local displayName = BJCore.Shared.Vehicles[saleData.vData.data.vehicle]["name"]
                local brand = BJCore.Shared.Vehicles[saleData.vData.data.vehicle]["brand"]
                local mailData = {
                    sender = saleData.shopData.val.label,
                    subject = "Vehicle Purchase: "..plate,
                    message = "<u>Finance Details: </u><br><b>Vehicle:</b> "..brand.." "..displayName.."<br><b>Total Price:</b> "..BJCore.Config.Currency.Symbol..format_thousand(saleData.vData.data.price).."<br><b>Interest:</b> "..saleData.vData.data.interest.."%<br><b>Down Payment:</b> "..BJCore.Config.Currency.Symbol..downPayment.." ("..saleData.vData.data.down.."%)<br><b>"..saleData.vData.data.repayments.."</b> weekly repayments of "..BJCore.Config.Currency.Symbol.."<b>"..format_thousand(math.ceil(financedAmount/saleData.vData.data.repayments)).."</b><br><br>Repayments are automatically debited from your bank account. <br>If we're unable to process payment then you will fall into arrears. <u>The vehicle will be repossessed if you have more than 1 missed repayment.</u><br><br>Kind regards,<br><b>"..saleData.shopData.val.label,
                    button = {}
                }
                TriggerEvent("bj-log:server:CreateLog", "vehicleshop", GetPlayerName(src).." ("..pData.PlayerData.citizenid..") has purchased a vehicle "..saleData.vData.data.vehicle.." on finance. Data: "..BJCore.Common.Dump(financeData))               
                TriggerEvent('phone:server:sendNewMailToOffline', pData.PlayerData.citizenid, mailData)
            else
                TriggerClientEvent("BJCore:Notify", src, "Insufficient bank balance, you need an additional "..BJCore.Config.Currency.Symbol..format_thousand(downPayment - balance), "error", 5000)
            end
        end
    else
        local totalPrice = math.floor(saleData.vData.data.price)
        if (balance - totalPrice) >= 0 then
            if pData.Functions.RemoveMoney("bank", totalPrice) then
                BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `type`, `hash`, `mods`, `plate`, `garage`) VALUES (@steam, @citizenid, @vehicle, @type, @hash, @mods, @plate, @garage)", nil, {
                    ['@steam'] = pData.PlayerData.steam,
                    ['@citizenid'] = pData.PlayerData.citizenid,
                    ['@vehicle'] = saleData.vData.data.vehicle,
                    ['@type'] = saleData.vData.vehicletype,
                    ['@hash'] = GetHashKey(saleData.vData.data.vehicle),
                    ['@mods'] = '{}',
                    ['@plate'] = plate,
                    ['@garage'] = Config.DefaultGarage[saleData.vData.vehicletype]
                })
                TriggerClientEvent("BJCore:Notify", src, "Vehicle purchased successful", "success", 5000)
                TriggerEvent("bj-log:server:CreateLog", "vehicleshop", GetPlayerName(src).." ("..pData.PlayerData.citizenid..") has purchased a vehicle "..saleData.vData.data.vehicle..". Data: "..BJCore.Common.Dump(saleData))
                sale = true
            end
        else
            TriggerClientEvent("BJCore:Notify", src, "Insufficient bank balance, you need an additional "..BJCore.Config.Currency.Symbol..format_thousand(totalPrice - balance), "error", 5000)
        end
    end
    local comDealerPercent, comDealershipPercent = Config.GlobalDealerCommission,  Config.GlobalDealershipCommission
    if sale then
        TriggerClientEvent("vehicleshop:client:completePurchase", src, saleData.vData.data.vehicle, plate)
        if saleData.origin and Config.PayDealerCommission then
            local oData = BJCore.Functions.GetPlayer(tonumber(saleData.origin))
            if oData ~= nil and (src ~= saleData.origin or Config.AllowDealerEarnOwnCom) then
                if Config.DealerCommissionType == 2 then
                    if BJCore.Shared.Vehicles[saleData.vData.data.vehicle].dealer ~= nil then
                        comDealerPercent = BJCore.Shared.Vehicles[saleData.vData.data.vehicle].dealer
                    else
                        print("[VEHICLESHOP] - Vehicle model: "..saleData.vData.data.vehicle.." missing commission value in shared.lua. Using Config.GlobalDealerCommission instead")
                    end
                end
                local commission = saleData.vData.data.price*(comDealerPercent/100)
                oData.Functions.AddMoney("bank", math.ceil(commission))
                TriggerClientEvent("BJCore:Notify", oData.PlayerData.source, "You have received commission of "..BJCore.Config.Currency.Symbol..format_thousand(commission), "primary", 5000)
            end
        end
        if Config.PayDealershipCommission then
            if exports["utils"]:DoesMoneysafeExist(saleData.shopData.key) then
                if Config.DearlershipCommissionType == 2 then
                    if BJCore.Shared.Vehicles[saleData.vData.data.vehicle].dealership ~= nil then
                        comDealershipPercent = BJCore.Shared.Vehicles[saleData.vData.data.vehicle].dealership
                    else
                        print("[VEHICLESHOP] - Vehicle model: "..saleData.vData.data.vehicle.." missing commission value in shared.lua. Using Config.GlobalDealershipCommission instead")
                    end
                end
                if comDealerPercent + comDealershipPercent > 100 then
                    comDealershipPercent = 100-comDealerPercent
                end
                local commission = saleData.vData.data.price*(comDealershipPercent/100)
                TriggerEvent("moneysafe:server:DepositMoneyDirect", saleData.shopData.key, math.ceil(commission))
            else
                print("[VEHICLESHOP] - Money safe missing for job: "..saleData.shopData.key..". Attempted dealership commission payment failed")
            end
        end
    end
end)

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
            .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end

function GeneratePlate()
    local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = @plate", function(result)
        while (result[1] ~= nil) do
            plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
        end
        return plate
    end, { ['@plate'] = plate })
    return plate:upper()
end

exports('GeneratePlate', GeneratePlate);

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

RegisterNetEvent('vehicleshop:server:setShowroomCarInUse')
AddEventHandler('vehicleshop:server:setShowroomCarInUse', function(showroom, showroomVehicle, bool)
    Config.ShowroomVehicles[showroom][showroomVehicle].inUse = bool
    TriggerClientEvent('vehicleshop:client:setShowroomCarInUse', -1, showroom, showroomVehicle, bool)
end)

RegisterNetEvent('vehicleshop:server:setSalePointInUse')
AddEventHandler('vehicleshop:server:setSalePointInUse', function(showroom, salePoint, bool)
    Config.SalePoints[showroom][salePoint].inUse = bool
    TriggerClientEvent('vehicleshop:client:setSalePointInUse', -1, showroom, salePoint, bool)
end)

RegisterNetEvent('vehicleshop:server:setShowroomVehicle')
AddEventHandler('vehicleshop:server:setShowroomVehicle', function(vData, showroom, k)
    Config.ShowroomVehicles[showroom][k].chosenVehicle = vData
    TriggerClientEvent('vehicleshop:client:setShowroomVehicle', -1, vData, showroom, k)
end)

BJCore.Functions.RegisterServerCallback('vehicleshop:server:SellVehicle', function(source, cb, vehicle, plate)
    local VehicleData = BJCore.Shared.VehicleModels[vehicle]
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `citizenid` = @citizenid AND `plate` = @plate", function(result)
        if result[1] ~= nil then
            if result[1].is_dono == 1 then
                TriggerClientEvent('BJCore:Notify', src, "You can't sell this vehicle (donation vehicle)", "error")
                cb(false)
            else
                Player.Functions.AddMoney('bank', math.ceil(VehicleData["price"] / 100 * 60))
                BJCore.Functions.ExecuteSql(false, "DELETE FROM `player_vehicles` WHERE `citizenid` = @citizenid AND `plate` = @plate", nil, {
                    ['@citizenid'] = Player.PlayerData.citizenid,
                    ['@plate'] = plate,
                })
                cb(true)
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "You don't own this vehicle", "error")
            cb(false)
        end
    end, { ['@citizenid'] = Player.PlayerData.citizenid, ['@plate'] = plate })
end)

RegisterNetEvent("vehicleshop:server:getSaleData")
AddEventHandler("vehicleshop:server:getSaleData", function() TriggerClientEvent("vehicleshop:client:returnSaledata", source, Config.SalePoints) end)

RegisterNetEvent("vehicleshop:server:UpdateSalePointData")
AddEventHandler("vehicleshop:server:UpdateSalePointData", function(shop, salePoint, index, data)
    if string.find(index, "%.") then
        Config.SalePoints[shop][salePoint][splitIndex(index, ".")[1]][splitIndex(index, ".")[2]] = data
    else
        Config.SalePoints[shop][salePoint][index] = data
    end
    TriggerClientEvent("vehicleshop:client:returnSaledata", -1, Config.SalePoints) 
end)

RegisterNetEvent("vehicleshop:server:SetDefaultSale")
AddEventHandler("vehicleshop:server:SetDefaultSale", function(model, shop, salePoint)
    local data = {
        vehicle = model,
        finance = false,
        price = BJCore.Shared.Vehicles[model]["price"],
        interest = Config.MinInterestRate,
        down = Config.MinDownpayment,
        repayments = Config.MinAmountOfRepayments,
    }
    Config.SalePoints[shop][salePoint].data = data
    TriggerClientEvent("vehicleshop:client:returnSaledata", -1, Config.SalePoints)
end)

local releaseOnPay = false
BJCore.Commands.Add("managefinance", "Manage finance vehicles", {{name="plate", help="Vehicle plate"}, {name="action", help="check | pay | release"}}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = @plate AND `financeData` IS NOT NULL", function(result)
            if result and result[1] ~= nil then
                if (result[1].citizenid == Player.PlayerData.citizenid or BJCore.Functions.HasPermission(source, "god") or Player.PlayerData.job.name == "judge") then
                    local financeData = json.decode(result[1].financeData)
                    if args[2] == "check" then
                        local displayName = BJCore.Shared.Vehicles[result[1].vehicle]["name"]
                        local brand = BJCore.Shared.Vehicles[result[1].vehicle]["brand"]
                        local mailData = {
                            sender = financeData.dealership,
                            subject = "Vehicle Finance: "..result[1].plate,
                            message = "<u>Details: </u><br><b>Vehicle:</b> "..brand.." "..displayName.."<br><b>Owner:</b> "..result[1].citizenid.."<br><b>Total Price:</b> "..BJCore.Config.Currency.Symbol..format_thousand(financeData.totalPrice).."<br><b>Interest:</b> "..financeData.interest.."%<br><b>Down Payment:</b> "..BJCore.Config.Currency.Symbol..format_thousand(math.ceil(financeData.totalPrice*(financeData.downPayment/100))).." ("..financeData.downPayment.."%)<br><br><b>Repayments:</b> "..financeData.completedPayments.."/"..financeData.repayments.."<br><b>Balance:</b> "..BJCore.Config.Currency.Symbol..financeData.balance.."<br><b>Payment Due:</b> "..BJCore.Config.Currency.Symbol..format_thousand(math.ceil(financeData.overdue*financeData.repaymentAmount)).."<br><b>Next Due:</b> "..financeData.daysLeft.." day(s)<br><br>Kind regards,<br><b>"..financeData.dealership,
                            button = {}
                        }
                        TriggerEvent('phone:server:sendNewMailToOffline', Player.PlayerData.citizenid, mailData)
                    elseif args[2] == "pay" then
                        if tonumber(financeData.overdue) > 0 then
                            local balance = financeData.repaymentAmount*financeData.overdue
                            if Player.PlayerData.money["bank"] >= balance then
                                if Player.Functions.RemoveMoney("bank", balance) then
                                    financeData.completedPayments = financeData.completedPayments + financeData.overdue
                                    financeData.overdue = 0
                                    financeData.balance = financeData.balance - balance
                                    local newData = json.encode(financeData)
                                    BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `financeData` = @financeData WHERE `plate` = @plate", nil, {
                                        ['@financeData'] = newData,
                                        ['@plate'] = result[1].plate,
                                    })
                                    TriggerClientEvent('BJCore:Notify', source, "You have cleared your overdue balance of "..BJCore.Config.Currency.Symbol..balance.." for vehicle with plate: "..result[1].plate, "success", 7000)
                                    if releaseOnPay then
                                        BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '1' WHERE `plate` = @plate", nil, {
                                            ['@plate'] = result[1].plate,
                                        })
                                    end
                                end
                            else
                                TriggerClientEvent('BJCore:Notify', source, "You don't have enough money in your bank to pay "..BJCore.Config.Currency.Symbol..format_thousand(balance), "error", 4000)                                
                            end
                        else
                            TriggerClientEvent('BJCore:Notify', source, "No overdue balance", "error")
                        end
                    elseif args[2] == "release" then
                        if (BJCore.Functions.HasPermission(source, "god") or Player.PlayerData.job.name == "judge") then
                            BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '1' WHERE `plate` = @plate", nil, {
                                ['@plate'] = result[1].plate,
                            })
                            TriggerClientEvent('BJCore:Notify', source, "Vehicle with plate: "..result[1].plate.." has been released", "success", 4000)
                        end
                    end
                else
                    TriggerClientEvent('BJCore:Notify', source, "Finance vehicle not found", "error")
                end
            else
                TriggerClientEvent('BJCore:Notify', source, "Finance vehicle not found", "error")
            end
        end, { ['@plate'] = args[1] })
    end
end)

function CronTask(d, h, m)
    if GetConvar("server_type", "DEV") == "LIVE" then
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE JSON_UNQUOTE(JSON_EXTRACT(financeData, '$.balance')) > 0", function(result)
            for k,v in pairs(result) do
                local financeData = json.decode(v.financeData)
                financeData.daysLeft = tonumber(financeData.daysLeft)
                if financeData.daysLeft > 1 then
                    financeData.daysLeft = financeData.daysLeft - 1
                    if financeData.daysLeft == 3 then
                        local mailData = {
                            sender = financeData.dealership,
                            subject = "Repayment Reminder",
                            message = "<u>Vehicle Plate: "..result[1].plate.."</u><br><br>We will be debiting your bank account of "..BJCore.Config.Currency.Symbol.."<b>"..financeData.repaymentAmount.."</b> in <b>3</b> days. Please make sure you have enough money in your account for this payment.<br><br>Kind regards,<br><b>"..financeData.dealership,
                            button = {}
                        }
                        TriggerEvent('phone:server:sendNewMailToOffline', v.citizenid, mailData)
                    end
                    BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `financeData` = @financeData WHERE `plate` = @plate", nil, {
                        ['@financeData'] = json.encode(financeData),
                        ['@plate'] = v.plate,
                    })
                else
                    local Player = BJCore.Functions.GetPlayerByCitizenId(v.citizenid)
                    local paid = false
                    if Player ~= nil then
                        if Player.PlayerData.money["bank"] >= financeData.repaymentAmount then
                            if Player.Functions.RemoveMoney("bank", financeData.repaymentAmount) then
                                paid = true
                                TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, "Repayment for Vehicle Finance (Plate: "..v.plate..") successfully paid", "success")
                            end
                        else
                            TriggerClientEvent('BJCore:Notify', Player.PlayerData.source, "You don't have enough money in your bank to pay finance payment of "..BJCore.Config.Currency.Symbol..format_thousand(financeData.repaymentAmount), "error", 5000) 
                        end
                    else
                        local busy = true
                        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = @citizenid", function(PlayerData)
                            if PlayerData[1] ~= nil then
                                local moneyInfo = json.decode(PlayerData[1].money)
                                if tonumber(moneyInfo.bank) >= financeData.repaymentAmount then
                                    moneyInfo.bank = math.ceil((moneyInfo.bank - financeData.repaymentAmount))
                                    BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = @money WHERE `citizenid` = @citizenid", nil, {
                                        ['@money'] = json.encode(moneyInfo),
                                        ['@citizenid'] = v.citizenid,
                                    })
                                    paid = true
                                end
                            end
                            busy = false
                        end, { ['@citizenid'] = v.citizenid })
                        while busy do Citizen.Wait(100); end
                    end
                    if not paid then
                        financeData.overdue = financeData.overdue + 1
                        if financeData.overdue > 1 and tonumber(v.state) ~= 3 then -- repossess vehicle
                            BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '3' WHERE `plate` = @plate", nil, {
                                ['@plate'] = v.plate,
                            })
                        end
                    else
                        financeData.completedPayments = financeData.completedPayments + 1
                        financeData.balance = financeData.balance - financeData.repaymentAmount
                    end
                    if financeData.completedPayments ~= financeData.repayments then financeData.daysLeft = 7; end
                    BJCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `financeData` = @financeData WHERE `plate` = @plate", nil, {
                        ['@financeData'] = json.encode(financeData),
                        ['@plate'] = v.plate
                    })
                end
            end
        end)
    end
end

local testDrives, syncing = {}, false
RegisterNetEvent("vehicleshop:server:syncTestDrives")
AddEventHandler("vehicleshop:server:syncTestDrives", function(shop, vehicle, b)
    syncing = true
    if testDrives[shop] == nil then
        testDrives[shop] = {}
    end
    if b then
        testDrives[shop][vehicle] = b
    else
        if testDrives[shop][vehicle] ~= nil then
            testDrives[shop][vehicle] = nil
        end
    end
    TriggerClientEvent("vehicleshop:client:syncTestDrives", -1, testDrives)
    syncing = false
end)

Citizen.CreateThread(function()
    while true do
        local updates = false
        Citizen.Wait(5000)
        if not syncing then
            for k,v in pairs(testDrives) do
                if testDrives[k] ~= nil then
                    for veh,_ in pairs (testDrives[k]) do
                        if testDrives[k][veh] ~= nil then
                            if DoesEntityExist(NetworkGetEntityFromNetworkId(veh)) then
                                updates = true
                                testDrives[k][veh] = GetEntityCoords(NetworkGetEntityFromNetworkId(veh))
                            end
                        end
                    end
                end
            end
        end
        if updates then
            TriggerClientEvent("vehicleshop:client:syncTestDrives", -1, testDrives)
        end
    end
end)

-- RegisterNetEvent('finance:testywesty')
-- AddEventHandler('finance:testywesty', function()
--     CronTask()
-- end)

TriggerEvent('cron:runAt', 01, 00, CronTask)
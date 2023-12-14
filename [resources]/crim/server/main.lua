storeData = {
    [1] = { ['pos'] = vector4(372.29217529297, 326.39370727539, 103.56636047363, 246.00857543945), ['store'] = "247 Clinton", ['robbed'] = false, ['safeRobbed'] = false },
    [2] = { ['pos'] = vector4(24.215274810791, -1347.2624511719, 29.497016906738, 248.67747497559), ['store'] = "247 Strawberry", ['robbed'] = false, ['safeRobbed'] = false },
    [3] = { ['pos'] = vector4(2557.1748046875, 380.64489746094, 108.62294006348, 340.8776550293), ['store'] = "247 Palomino", ['robbed'] = false, ['safeRobbed'] = false },
    [4] = { ['pos'] = vector4(-3038.2673339844, 584.47491455078, 7.908935546875, 23.610481262207), ['store'] = "247 Ineseno", ['robbed'] = false, ['safeRobbed'] = false },
    [5] = { ['pos'] = vector4(-3242.2670898438, 999.76306152344, 12.830704689026, 345.36389160156), ['store'] = "247 Barbareno", ['robbed'] = false, ['safeRobbed'] = false },
    [6] = { ['pos'] = vector4(549.44256591797, 2671.2185058594, 42.156513214111, 75.037734985352), ['store'] = "247 Route 68", ['robbed'] = false, ['safeRobbed'] = false },
    [7] = { ['pos'] = vector4(1959.9187011719, 3740.0014648438, 32.343738555908, 293.646484375), ['store'] = "247 Alhambra", ['robbed'] = false, ['safeRobbed'] = false },
    [8] = { ['pos'] = vector4(1727.7840576172, 6415.3408203125, 35.037250518799, 226.98921203613), ['store'] = "247 Senora", ['robbed'] = false, ['safeRobbed'] = false },
    [9] = { ['pos'] = vector4(2677.9306640625, 3279.3017578125, 55.241123199463, 317.35440063477), ['store'] = "247 Route 13", ['robbed'] = false, ['safeRobbed'] = false },
    [10] = { ['pos'] = vector4(-2966.3012695313, 391.58193969727, 15.043300628662, 86.15234375), ['store'] = "RobsLiquor Great Ocean", ['robbed'] = false, ['safeRobbed'] = false },
    [11] = { ['pos'] = vector4(-1487.2850341797, -376.92288208008, 40.163436889648, 153.55458068848), ['store'] = "RobsLiquor Prosperity", ['robbed'] = false, ['safeRobbed'] = false },
    [12] = { ['pos'] = vector4(-1221.3229980469, -908.12780761719, 12.326356887817, 37.299858093262), ['store'] = "RobsLiquor San Andreas", ['robbed'] = false, ['safeRobbed'] = false },
    [13] = { ['pos'] = vector4(1134.0545654297, -983.3251953125, 46.415802001953, 282.5920715332), ['store'] = "RobsLiquor El Rancho", ['robbed'] = false, ['safeRobbed'] = false },
    [14] = { ['pos'] = vector4(1165.2305908203, 2710.9692382813, 38.157665252686, 188.72573852539), ['store'] = "RobsLiquor Route 68", ['robbed'] = false, ['safeRobbed'] = false },
    [15] = { ['pos'] = vector4(-705.91625976563, -913.41326904297, 19.215585708618, 89.320465087891), ['store'] = "LTD Vespucci", ['robbed'] = false, ['safeRobbed'] = false},
    [16] = { ['pos'] = vector4(-46.958980560303, -1758.9643554688, 29.420999526978, 48.277374267578), ['store'] = "LTD Davis", ['robbed'] = false, ['safeRobbed'] = false },
    [17] = { ['pos'] = vector4(1165.1630859375, -323.87414550781, 69.205047607422, 101.4720993042), ['store'] = "LTD Mirror Park", ['robbed'] = false, ['safeRobbed'] = false },
    [18] = { ['pos'] = vector4(-1819.5125732422, 793.64141845703, 138.08486938477, 132.9716796875), ['store'] = "LTD Banham Canyon", ['robbed'] = false, ['safeRobbed'] = false },
    [19] = { ['pos'] = vector4(1697.1395263672, 4923.4130859375, 42.063632965088, 325.30218505859), ['store'] = "LTD Grapeseed", ['robbed'] = false, ['safeRobbed'] = false }
}

hasRobbed = {}
function resetTimer() 
    while true do Wait(1000); doReset() end 
end 

function doReset()  
    local delTab = {}   
    local time = GetGameTimer()   
    for key,val in pairs(hasRobbed) do     
        if (time - val) > (Config.StoreRobResetTimer * 60 * 1000) then             
            storeData[key]['robbed'] = false
            storeData[key]['safeRobbed'] = false                 
            delTab[key] = true
            print('reseting store id: '..key)
            TriggerClientEvent("storerobbery:syncData", -1, storeData)
        end   
     end   
    for k,v in pairs(delTab) do hasRobbed[k] = nil; end 
end

RegisterServerEvent("storerobbery:setRobbed")
AddEventHandler("storerobbery:setRobbed", function(id)
    storeData[id]['robbed'] = true
    hasRobbed[id] = GetGameTimer()
    print('set id robbed: '..id)
    TriggerEvent("bj-log:server:CreateLog", "crim", "Store Robbery", "black", storeData[id]['store'].." Shop ("..id.."): has been marked as robbed. On cooldown")
    TriggerClientEvent("storerobbery:syncData", -1, storeData)
end)

RegisterServerEvent("storerobbery:requestDelete")
AddEventHandler("storerobbery:requestDelete", function(ped)
    local _source = source
    local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(ped))
    TriggerClientEvent("storerobbery:deletePed", owner, ped)
end)

function GetLockpickCount(source)
  local amount = 0
  local pData = BJCore.Functions.GetPlayer(source)
  while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(source); end
  local item = pData.Functions.GetItemByName('lockpick')
  if item and item.amount then amount = item.amount; end
  return amount
end

RegisterServerEvent("storerobbery:globalEvent")
AddEventHandler("storerobbery:globalEvent", function(options)
    TriggerClientEvent("storerobbery:eventHandler", -1, options["event"] or "none", options["data"] or nil)
end)

RegisterServerEvent("storerobbery:receiveBagCash")
AddEventHandler("storerobbery:receiveBagCash", function(cashAmount)
    local src = source
    local pData = BJCore.Functions.GetPlayer(src)

    if pData then
        pData.Functions.AddItem("cashroll", cashAmount)
        for i = 1, cashAmount, 1 do
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cashroll"], "add")
        end
        TriggerClientEvent('BJCore:Notify',src,"You grabbed "..cashAmount.." cash rolls",'primary')
        TriggerEvent("bj-log:server:CreateLog", "crim", "Store Robbery", "green", "**"..pData.PlayerData.name .. "** has looted items: "..BJCore.Shared.Items["cashroll"]['label'].." | amount: "..cashAmount)
    end
end)

RegisterNetEvent('storerobbery:NotifyPolice')
AddEventHandler('storerobbery:NotifyPolice', function(data)
    for k,v in pairs(BJCore.Functions.GetPlayers()) do
        local pData = BJCore.Functions.GetPlayer(v)
        while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(v); end
        if pData.PlayerData.job.name == 'police' then
            TriggerClientEvent('storerobbery:NotifyPolice', v, data)
        end
    end
end)

Citizen.CreateThread(function(...) resetTimer(...); end)
BJCore.Functions.RegisterServerCallback('storerobbery:getStartData', function(source,cb) cb(storeData); end)
BJCore.Functions.RegisterServerCallback('storerobbery:GetLockpickCount', function(source,cb) cb(GetLockpickCount(source) or 0); end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        GenerateVehicleList()
        Citizen.Wait((1000 * 60) * 60)
    end
end)

RegisterServerEvent('scrapyard:server:LoadVehicleList')
AddEventHandler('scrapyard:server:LoadVehicleList', function()
    local src = source
    TriggerClientEvent("scrapyard:client:setNewVehicles", src, Config.CSCurrentVehicles)
end)


RegisterServerEvent('scrapyard:server:ScrapVehicle')
AddEventHandler('scrapyard:server:ScrapVehicle', function(listKey)
    local src = source 
    local Player = BJCore.Functions.GetPlayer(src)
    if Config.CSCurrentVehicles[listKey] ~= nil then 
        for i = 1, math.random(3,5), 1 do
            local item = Config.CSItems[math.random(1, #Config.CSItems)]
            Player.Functions.AddItem(item, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item], 'add')
            TriggerEvent("bj-log:server:CreateLog", "crim", "Chopshop", "green", "**"..Player.PlayerData.name .. "** has received items: "..BJCore.Shared.Items[item]['label'].." | amount: 1 from chopping a vehicle")
            Citizen.Wait(500)
        end
        local Luck = math.random(1, 8)
        local Odd = math.random(1, 8)
        if Luck == Odd then
            local random = math.random(2, 4)
            Player.Functions.AddItem("rubber", random)
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["rubber"], 'add')
            TriggerEvent("bj-log:server:CreateLog", "crim", "Chopshop", "green", "**"..Player.PlayerData.name .. "** has received items: "..BJCore.Shared.Items["rubber"]['label'].." | amount: "..random.." from chopping a vehicle")
        end
        Config.CSCurrentVehicles[listKey] = nil
        TriggerClientEvent("scrapyard:client:setNewVehicles", -1, Config.CSCurrentVehicles)
    end
end)

moneyWashConvert = {
    ["cashband"] = {
        value = 130,
        ranged = 20,
    },
    ["cashroll"] = {
        value = 40,
        ranged = 10,
    }
}

RegisterServerEvent('moneywash:deliverySuccess')
AddEventHandler('moneywash:deliverySuccess', function()
    local src = source 
    local Player = BJCore.Functions.GetPlayer(src)
    local item, value, ranged = nil, 0, 0
    for k,v in pairs(moneyWashConvert) do
        if item ~= nil then break; end
        item = Player.Functions.GetItemByName(k)
        value, ranged = moneyWashConvert[k].value, moneyWashConvert[k].ranged
    end
    
    if item == nil then
        TriggerClientEvent('BJCore:Notify', src, "You don't have anything to give me? Get the hell out of here!", 'primary')
        TriggerClientEvent('moneywash:client:cancelrun', src)
    else
        local amount = item.amount
        if amount > 3 then
            amount = 3
        end
        local rangedprice = math.random(value-ranged, value+ranged)
        local price = amount * rangedprice
    
        Player.Functions.RemoveItem(item.name, amount)
        Player.Functions.AddMoney("cash", price, "Moneywash delivery")
        local chance = math.random(100)
        if chance <= 35 then
            Player.Functions.SetMetaData("washrep", Player.PlayerData.metadata["washrep"] + 1)
            if Player.PlayerData.metadata["washrep"] + 1 == 100 then
                TriggerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.citizenid..") has reached 100 money wash rep.")
                TriggerClientEvent('moneywash:client:repNotif', src)
            end
        end
    
        TriggerClientEvent('BJCore:Notify', src, "You receive "..BJCore.Config.Currency.Symbol..tostring(price).." as bills", 'primary')
        TriggerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..Player.PlayerData.name .. "** has received "..BJCore.Config.Currency.Symbol..price.." from washing x"..amount.." "..BJCore.Shared.Items[item.name]['label']..".")
        Citizen.Wait(2000)
        TriggerClientEvent('BJCore:Notify', src, "Drop off successful. You'll be updated with the next drop off", 'primary')
    end
end)

function GenerateVehicleList()
    Config.CSCurrentVehicles = {}
    for i = 1, 20, 1 do
        local randVehicle = Config.CSVehicles[math.random(1, #Config.CSVehicles)]
        if not IsInList(randVehicle) then
            Config.CSCurrentVehicles[i] = randVehicle
        end
    end
    TriggerClientEvent("scrapyard:client:setNewVehicles", -1, Config.CSCurrentVehicles)
end

function IsInList(name)
    local retval = false
    if Config.CSCurrentVehicles ~= nil and next(Config.CSCurrentVehicles) ~= nil then 
        for k, v in pairs(Config.CSCurrentVehicles) do
            if Config.CSCurrentVehicles[k] == name then 
                retval = true
            end
        end
    end
    return retval
end

local HintLoc = {}
function WashLocations(...)
    HintLoc = Config.MWStartLocations[math.random(1,#Config.MWStartLocations)]
    while true do
        Citizen.Wait(math.random(45,75) * 60 * 1000)
        HintLoc = Config.MWStartLocations[math.random(1,#Config.MWStartLocations)]
        TriggerClientEvent('moneywash:client:SetHint', -1, HintLoc)
    end
end

RegisterNetEvent('moneywash:server:ReportStolen')
AddEventHandler('moneywash:server:ReportStolen', function(vehicle, plate)
    local selectMsg = math.random(1,3)
    if selectMsg == 1 then
        TriggerClientEvent('police:client:Send112AMessage', -1, "Hello. I would like to report my "..vehicle.." stolen. The plate reads "..plate..". Please impound it if you see it!")
    elseif selectMsg == 2 then
        TriggerClientEvent('police:client:Send112AMessage', -1, "Help! My "..vehicle.." has been stolen. The reg plate is "..plate..". Please find my car!")
    elseif selectMsg == 3 then
        TriggerClientEvent('police:client:Send112AMessage', -1, "My vehicle has been stolen! It's a "..vehicle.." with plates "..plate..". Please catch those filthy criminals!")
    end
    TriggerEvent('police:server:AddToFlagPlates', 'Vehicle reported stolen | Vehicle: '..vehicle, plate)
end)

RegisterNetEvent('moneywash:server:GetHint')
AddEventHandler('moneywash:server:GetHint', function() TriggerClientEvent('moneywash:client:SetHint', source, HintLoc); end)
Citizen.CreateThread(function(...) WashLocations(...); end)

BJCore.Functions.RegisterServerCallback("crim:server:getRep", function(source, cb, repType)
    local Player = BJCore.Functions.GetPlayer(source)
    cb(Player.PlayerData.metadata[repType] or 0)
end)

local orders, ready = {}, false

function WashAwake(update)
    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `wash_orders`", function(data)
        if data[1] then
            for k,v in pairs(data) do
                orders[v.id] = {id = v.id, cid = v.citizenid, item = v.item, amount = v.amount, time = v.ordered_on, ready = v.ready}
            end
            ready = true
        end
        if update then WashUpdate(); end        
    end)
end

function WashUpdate(...)
    while not ready do Citizen.Wait(0); end
    WashCheckOrders()
    while true do Wait(60 * 60 * 1000); WashCheckOrders() end 
end

function WashCheckOrders(...)
    local curTime = os.time()
    for k,v in pairs(orders) do
        local diff = curTime - v.time
        if diff >= (24*60*60) and v.ready == 0 then -- If it's been 24 hours then order is ready for collection
            BJCore.Functions.ExecuteSql(false, "UPDATE `wash_orders` SET `ready` ='1' WHERE `id` = '"..k.."'")
            orders[k].ready = 1
            local maildata = {
                sender = "While-U-Wait Laundry",
                subject = "Ready for collection!",
                message = "Your most recent load you dropped off is now ready for collection. <br />Please make sure you have enough space to collect your items<br /><br />Take care",

            }
            TriggerEvent("phone:server:sendNewMailToOffline", v.cid, maildata)
        end
    end
end

local ExchangeTo = {  -- for every 1x money bags player receives this amount
    min = 4,
    max = 6
}

RegisterServerEvent('moneywash:server:PlaceOrder')
AddEventHandler('moneywash:server:PlaceOrder', function(item, amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local hasAll = true
    if Player.Functions.GetItemByName(item) == nil then
        hasAll = false
    else
        local count = Player.Functions.GetItemByName(item).amount
        if count == nil or count < amount then
            hasAll = false
        end
    end

    if not hasAll then 
        TriggerClientEvent('BJCore:Notify', src, "Amount of "..BJCore.Shared.Items[item].label.." on you doesn't match amount on the order", "error")
    else
        Player.Functions.RemoveItem(item, amount)
        local curTime = os.time()
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `wash_orders` (`citizenid`, `item`, `amount`, `ordered_on`) VALUES ('"..Player.PlayerData.citizenid.."', '"..item.."', '"..amount.."', '"..curTime.."')")
        TriggerClientEvent('BJCore:Notify', src, "Order successfully placed", "success")
        TriggerClientEvent('BJCore:Notify', src, "You'll be emailed when the order is ready to collect", "primary")
        TriggerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..Player.PlayerData.name .. "** has placed an order for x"..amount.." "..BJCore.Shared.Items[item].label.." to be washed.")
        Wait(10)
        WashAwake(false)
    end
end)

RegisterNetEvent("moneywash:server:getPlayerOrders")
AddEventHandler("moneywash:server:getPlayerOrders", function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local clientOrders = {}
    local curTime = os.time()
    for k,v in pairs(orders) do
        if v.cid == Player.PlayerData.citizenid then
            clientOrders[k] = {ready = v.ready, id = v.id, item = v.item, amount = v.amount}
        end
    end
    if next(clientOrders) == nil then TriggerClientEvent('BJCore:Notify', src, "You have no current orders", "primary")
    else 
        for k,v in pairs(clientOrders) do
            local rdyText = "Ready for collection"
            if v.ready == 0 then rdyText = "Not ready"; end
            TriggerClientEvent('BJCore:Notify', src, "Order #: "..v.id.." | "..BJCore.Shared.Items[v.item].label.."(s): "..v.amount.." | "..rdyText, "primary", 6000)
        end 
        TriggerClientEvent('BJCore:Notify', src, "Use /washcollect to collect orders", "primary")
    end
end)

BJCore.Commands.Add("washcollect", "What's this then?", {{name="Order ID", help="ID"}}, true, function(source, args)
    local src = source
    if args[1] ~= nil then
        local orderId = tonumber(args[1])
        TriggerClientEvent("moneywash:client:collectOrder", src, orderId)
    else
        TriggerClientEvent('BJCore:Notify', src, "Missing order number", "error")
    end
end)

RegisterNetEvent("moneywash:server:giveOrder")
AddEventHandler("moneywash:server:giveOrder", function(orderKey)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if orders[orderKey] then
        if orders[orderKey].cid == Player.PlayerData.citizenid then
            if orders[orderKey].ready == 1 then
                local amount = 0
                if orders[orderKey].item == "moneybag" then
                    for i=1,orders[orderKey].amount, 1 do
                        local toAdd = math.random(ExchangeTo.min, ExchangeTo.max)
                        amount = amount + toAdd
                    end
                else
                    amount = orders[orderKey].amount
                end
                local itemReward = "cashband"
                if orders[orderKey].item ~= "moneybag" then
                    itemReward = 0
                    for i=1,amount,1 do
                        local toAdd = math.random(moneyWashConvert[orders[orderKey].item].value-moneyWashConvert[orders[orderKey].item].ranged, moneyWashConvert[orders[orderKey].item].value+moneyWashConvert[orders[orderKey].item].ranged)
                        itemReward = itemReward + toAdd
                    end
                end
                local reward = false
                if orders[orderKey].item == "moneybag" then
                    if Player.Functions.AddItem("cashband", amount) then
                        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cashband"], "add")
                        reward = true
                    else
                        TriggerClientEvent('BJCore:Notify', src, "You don't have enough space to collect these items", "error")
                    end
                else
                    Player.Functions.AddMoney("cash", itemReward)
                    reward = true
                end
                if reward then
                    TriggerClientEvent('BJCore:Notify', src, "Order #: "..orderKey.." has been collected", "primary")
                    BJCore.Functions.ExecuteSql(false, "DELETE FROM `wash_orders` WHERE `id` = '"..orderKey.."'")
                    if orders[orderKey].item == "moneybag" then
                        TriggerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..Player.PlayerData.name .. "** has collected order #"..orderKey..". Exchanged x"..orders[orderKey].amount.." Money Bag(s) for x"..amount.." Cash Band(s).")
                    else
                        TriggerEvent("bj-log:server:CreateLog", "crim", "Money Wash", "green", "**"..Player.PlayerData.name .. "** has collected order #"..orderKey..". Exchanged x"..orders[orderKey].amount.." "..BJCore.Shared.Items[orders[orderKey].item].label.." for $"..itemReward)
                    end
                    orders[orderKey] = nil
                end
            else
                TriggerClientEvent('BJCore:Notify', src, "This order isn't ready for collection", "error")
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "This order isn't yours", "error")
        end
    else
        TriggerClientEvent('BJCore:Notify', src, "Order not found", "error")
    end
end)

Citizen.CreateThread(function(...) WashAwake(true); end)

RegisterNetEvent("crim:server:AddRep")
AddEventHandler("crim:server:AddRep", function(rep, amount)
    -- body
end)

RegisterNetEvent("crim:server:syncTrafficLights")
AddEventHandler("crim:server:syncTrafficLights", function(target, model, pos)
    TriggerClientEvent("crim:client:syncTrafficLights", target, model, pos)
end)

HackedLights = {}
RegisterServerEvent("crim:server:rewardTrafficLights")
AddEventHandler("crim:server:rewardTrafficLights", function(coords)
    local _source = source
    HackedLights[coords] = true
    if math.random(100) <= 80 then
        local pData = BJCore.Functions.GetPlayer(_source)
        local hackValue = pData.PlayerData.metadata["hackerrep"] and pData.PlayerData.metadata["hackerrep"] or 0
        pData.Functions.SetMetaData('hackerrep', hackValue + 1)
    end
    TriggerClientEvent('crim:client:trafficHacked', -1, coords)
end) 

BJCore.Functions.RegisterServerCallback("crim:server:GetHackedLights", function(source, cb) cb(HackedLights); end)

RegisterNetEvent("crim:server:ChanceRemove")
AddEventHandler("crim:server:ChanceRemove", function(item, chance)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local roll = math.random(100)
    print("chance remove roll: "..roll.." | chance <= "..chance)
    if roll <= chance then
        Player.Functions.RemoveItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["item"], "remove")
    end
end)

BJCore.Functions.RegisterServerCallback("crim:server:GetCrypto", function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    cb(Player.PlayerData.money.crypto or 0)
end)

local IntelConfig = {
    ["store"] = {
        ["intel"] = " hasn't made a recent deposit of the store cash. Their store safe is probably the best place to find it. Be safe!",
        ["expires"] = nil,
        ["type"] = "store",
        ["id"] = nil,
    }
}

RegisterNetEvent("crim:server:rewardIntel")
AddEventHandler("crim:server:rewardIntel", function(intelType)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local metaData = false
    if Player ~= nil then
        if intelType == 'store' then
            local rndIndex = math.random(#storeData)
            local rndStore = storeData[rndIndex]['store']
            metaData = {
                ["intel"] = rndStore.." "..IntelConfig[intelType]["intel"],
                ["expires"] = os.time() + (6*60*60),
                ["type"] = IntelConfig[intelType]["type"],
                ["id"] = rndIndex
            }
        end
        if metaData then
            if intelType == 'store' then
                TriggerClientEvent("chatMessage", src, "SYSTEM", "warning", "To use store 'intel' you need to have the item on the person who starts and runs through the store robbery")
            end
            Player.Functions.AddItem("intel", 1, nil, metaData)
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["intel"], "add")
            TriggerEvent("bj-log:server:CreateLog", "crim", "Hacker: Intel", "green", "**"..Player.PlayerData.name .. "** received "..intelType.." intel")
        end
    end
end)

BJCore.Functions.RegisterServerCallback("crim:server:checkForIntel", function(source, cb, intelType, index)
    local Player = BJCore.Functions.GetPlayer(source)
    local hasCorrectIntel = false
    if Player ~= nil then
        local intel = Player.Functions.GetItemByName("intel")
        if intel and intel ~= nil then
            if intel.info and intel.info.type == intelType then
                if intel.info.id == index then
                    if intel.info.expires and intel.info.expires > os.time() then
                        Player.Functions.RemoveItem("intel", 1, intel.slot)
                        TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items["intel"], "remove")
                        hasCorrectIntel = true
                    else
                        TriggerClientEvent('BJCore:Notify', source, "This intel has expired", "error")
                    end
                else
                    print("wrong id: "..intel.info.id.." | compared to: "..index)
                end
            else
                print("wrong type: "..intelType.." | compared to: "..intel.type)
            end
        else
            print("not intel item")
        end
        cb(hasCorrectIntel)
    end
end)

BJCore.Functions.RegisterServerCallback("crim:server:checkStoreSafe", function(source, cb, store)
    if not storeData[store]["safeRobbed"] then
        storeData[store]["safeRobbed"] = true
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("crim:server:ResetStoreSafe")
AddEventHandler("crim:server:ResetStoreSafe", function(store) storeData[store]["safeRobbed"] = false TriggerClientEvent("storerobbery:syncData", -1, storeData) end)

RegisterNetEvent("crim:server:RewardStoreSafe")
AddEventHandler("crim:server:RewardStoreSafe", function(store)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local rndAmount = math.random(5,8)
        Player.Functions.AddItem("cashband", rndAmount)
        TriggerEvent("bj-log:server:CreateLog", "crim", "Store Robbery", "green", "**"..Player.PlayerData.name.."** has looted "..rndAmount.." cash bands from a store robbery safe")
        for i = 1, rndAmount, 1 do
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cashband"], "add")
        end
        if math.random(100) <= 60 then
            TriggerEvent("bj-log:server:CreateLog", "crim", "Store Robbery", "green", "**"..Player.PlayerData.name.."** has looted a green usb from a store robbery safe")
            Player.Functions.AddItem("greenusb", 1, nil, {
                ["expires"] = os.time() + (24*60*60),
                ["encrypted"] = true,
            })
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["greenusb"], "add")
        end
    end
end)

local EncryptedItems = {
    'greenusb',
    'blackusb'
}

BJCore.Functions.RegisterServerCallback("crim:server:hasEncryptedItem", function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    local foundItem, hasExpired = false, false
    for k,v in pairs(EncryptedItems) do
        local item = Player.Functions.GetItemByName(v)
        if item and item ~= nil then
            if item.info and item.info.encrypted then
                if item.info.expires > os.time() then
                    foundItem = item
                    break
                else
                    hasExpired = true
                end
            end
        end
    end
    if hasExpired then TriggerClientEvent('BJCore:Notify', source, "You have expired encrypted item(s) that can no longer be used", "inform", 10000); end
    cb(foundItem)
end)

RegisterNetEvent("crim:server:doDecrypt")
AddEventHandler("crim:server:doDecrypt", function(item)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemBySlot(item.slot)
    if item and item ~= nil then
        local infoSave = Player.PlayerData.items[item.slot].info
        infoSave.encrypted = false
        Player.Functions.UpdateItemInfo(item.slot, infoSave)
        TriggerClientEvent('BJCore:Notify', src, BJCore.Shared.Items[item.name].label.." successfully decrypted", "success")
        TriggerClientEvent("chatMessage", src, "SYSTEM", "warning", "Once decrypted usbs are used, anything on it will be activated immediately")
        TriggerEvent("bj-log:server:CreateLog", "crim", "Bank Truck", "green", "**"..Player.PlayerData.name.."** has decrypted "..BJCore.Shared.Items[item.name].label)
    else
        print("selected item not found")
    end
end)

-- RegisterCommand('givetestintel', function(source, args, raw)
--     local metaData = {
--         ["intel"] = "247 Senora",
--         ["expires"] = os.time() + (4*60*60),
--         ["type"] = "store",
--         ["id"] = 8
--     }
--     local Player = BJCore.Functions.GetPlayer(source)
--     Player.Functions.AddItem("intel", 1, nil, metaData)
-- end, true)

-- RegisterCommand('givetestgreen', function(source, args, raw)
--     local metaData = {
--         ["expires"] = os.time() + (24*60*60),
--         ["encrypted"] = true,
--     }
--     local Player = BJCore.Functions.GetPlayer(source)
--     Player.Functions.AddItem("greenusb", 1, nil, metaData)
-- end, true)

BJCore.Functions.RegisterServerCallback("crim:server:GetExpiry", function(source, cb, expiry)
    if expiry > os.time() then
        cb(true)
    else
        cb(false)
    end
end)
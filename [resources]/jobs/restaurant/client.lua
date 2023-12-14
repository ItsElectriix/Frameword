local RestaurantsPolyZones = {}
local KitchenPolyZones = {}

local CurRestaurant = false
local CurCounter = false
local CurKitchen = false

local CustomerThreadRunning = false
local StaffThreadRunning = false

Citizen.CreateThread(function()
    PlayerData = BJCore.Functions.GetPlayerData()
    for k,v in pairs(Config.Restaurants) do
        Config.Restaurants[k].locationPolyZone.Options.data = {}
        Config.Restaurants[k].locationPolyZone.Options.data.key = k
        RestaurantsPolyZones[k] = PolyZone:Create(v.locationPolyZone.Points, v.locationPolyZone.Options)

        Config.Restaurants[k].kitchenPolyZone.Options.data = {}
        Config.Restaurants[k].kitchenPolyZone.Options.data.key = k
        KitchenPolyZones[k] = PolyZone:Create(v.kitchenPolyZone.Points, v.kitchenPolyZone.Options)
    end
    ManageRestaurantZones()
    ManageKitchenZones()
end)

function ManageRestaurantZones()
    for k,v in pairs(RestaurantsPolyZones) do
        RestaurantsPolyZones[k]:onPlayerInOut(function(isPointInside, point)
            if isPointInside then
                CurRestaurant = k
                StaffThread()
                CustomerThread()
            else
                if CurRestaurant == k then
                    CurRestaurant = false
                end
            end
        end)
    end
end

function ManageKitchenZones()
    for k,v in pairs(KitchenPolyZones) do
        KitchenPolyZones[k]:onPlayerInOut(function(isPointInside, point)
            if isPointInside then
                CurKitchen = k
                print("Entered kitchen")
                ActiveOrders()
            else
                if CurKitchen == k then
                    CurKitchen = false
                    ClearActiveOrders()
                    print("Left kitchen")
                end
            end
        end)
    end
end

local CurOrder = {}
local previousSelection = 1

local ShowingOrderNotif = false
local atStaffCounter, atCustomerCounter = false, false

function CustomerThread()
    if CustomerThreadRunning then return; end
    CustomerThreadRunning = true
    Citizen.CreateThread(function()
        local plyPed = PlayerPedId()
        while CurRestaurant do
            local nearby = false
            local plyPos = GetEntityCoords(plyPed)
            atCustomerCounter = false
            for k,v in pairs(Config.Restaurants[CurRestaurant].counterLocations.customer) do
                local dist = #(plyPos - GetObjectOffsetFromCoords(v.pos.xyz, v.pos.w, v.offset))
                if dist <= 0.8 then
                    nearby = true
                    atCustomerCounter = true
                    CurCounter = k
                    if not ShowingOrderNotif then
                        FormatOrderNotif()
                    end
                    local counterData = GetCounterData(CurCounter)
                    if counterData.process and not counterData.paid then
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.05, "[~g~E~w~] Pay "..BJCore.Config.Currency.Symbol..counterData.process)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent("restaurant:server:payAtCounter", CurRestaurant, CurCounter)
                        end
                    end
                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~g~H~w~] Counter")
                    if IsControlJustPressed(0, 74) then
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", "restaurant_"..CurRestaurant.."_counter_"..k, {slots = 5}, "Restaurant Counter "..k)
                        TriggerEvent("inventory:client:SetCurrentStash", "restaurant_"..CurRestaurant.."_counter_"..k)
                    end
                end
            end
            if (not StaffThreadRunning and not atCustomerCounter) then BJCore.Functions.PersistentNotify("end", "counterOrder") ShowingOrderNotif = false; end
            if not nearby then Citizen.Wait(1000); end
            Citizen.Wait(0)
        end
        CustomerThreadRunning = false
    end)
end

local dummy = {
    [1] = "test",
    [2] = "test",
    [3] = "test",
    [4] = "test",
}

local CookingData = {}
AddStateBagChangeHandler('RestaurantCooks', 'global', function(bagName, key, value, reserved, replicated)
    CookingData = value
end)

local textData = {}
local isAtCooker = false
function CookingText()
    for i = 1, #CookingData[CurRestaurant][isAtCooker], 1 do
        if CookingData[CurRestaurant][isAtCooker][i].item then
            local prefixColour = "~w~"
            if CookingData[CurRestaurant][isAtCooker][i].status == 2 or CookingData[CurRestaurant][isAtCooker][i].clean then
                prefixColour = "~g~"
            elseif CookingData[CurRestaurant][isAtCooker][i].status == 3 then
                prefixColour = "~o~"
            elseif CookingData[CurRestaurant][isAtCooker][i].status == 4 then
                prefixColour = "~r~"
            end
            local timer = "Ruined"
            if CookingData[CurRestaurant][isAtCooker][i].clean then
                timer = "Cleaning"
            elseif CookingData[CurRestaurant][isAtCooker][i].status ~= 4 then
                timer = s2m((GetNetworkTime()-CookingData[CurRestaurant][isAtCooker][i].start)/1000)
            end
            textData[i] =  BJCore.Shared.Items[CookingData[CurRestaurant][isAtCooker][i].item].label.." x"..CookingData[CurRestaurant][isAtCooker][i].amount.." | "..prefixColour..timer.."~w~"
        else
            textData[i] = " - "
        end
    end
end

function s2m(s)
    if s <= 0 then
        return "00:00"
    else
        local m = string.format("%02.f", math.floor(s/60))
        return m..":"..string.format("%02.f", math.floor(s - m * 60))
    end
end

RegisterNetEvent("restaurant:client:burnDownStation", function(restaurant, station)

end)

local ManagerMode = false
function StaffThread()
    if PlayerData.job.name ~= CurRestaurant then return; end
    if StaffThreadRunning then return; end
    StaffThreadRunning = true
    LastPress = 0
    Citizen.CreateThread(function()
        local plyPed = PlayerPedId()
        CookingData = GlobalState.RestaurantCooks
        OrderData = GlobalState.RestaurantOrders
        while CurRestaurant do
            local nearby = false
            local plyPos = GetEntityCoords(plyPed)
            local nearbyCooker = false
            for k,v in pairs(Config.Restaurants[CurRestaurant].cookingLocations) do
                local dist = #(plyPos - v.xyz)
                if dist <= 0.8 then
                    nearby = true
                    nearbyCooker = true
                    if not isAtCooker then
                        isAtCooker = k
                        TriggerEvent("isAtCooker", isAtCooker)
                    end
                    if next(CookingData) ~= nil then
                        CookingText()
                        DrawText3DMulti(v.x, v.y, v.z, textData, 4)
                    end
                end
            end
            if not nearbyCooker then
                if isAtCooker then
                    isAtCooker = false
                    TriggerEvent("isAtCooker", isAtCooker)
                end
            end
            for k,v in pairs(Config.Restaurants[CurRestaurant].counterLocations.staff) do
                local dist = #(plyPos - GetObjectOffsetFromCoords(v.pos.xyz, v.pos.w, v.offset))
                if dist <= 0.8 then
                    nearby = true
                    atStaffCounter = true
                    CurCounter = k
                    if not ShowingOrderNotif then
                        FormatOrderNotif()
                    end

                    if not ManagerMode then
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.05, "[~g~E~w~] Take Order")
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~g~H~w~] Counter")
                    else
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.05, "[~g~E~w~] Process Receipts")
                        local deliveries = "~r~Off"
                        if GlobalState.RestaurantAIStatus[CurRestaurant] then
                            deliveries = "~g~On"
                        end
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~g~H~w~] Deliveries: "..deliveries)
                    end
                    if PlayerData.job.grade.level >= Config.RestaurantManagerGrade[CurRestaurant] then
                        local modeText = "Manager Mode"
                        if ManagerMode then
                            modeText = "Till"
                        end
                        BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z-0.05, "[~g~K~w~] Switch to "..modeText)
                        if IsControlJustPressed(0, 311) then
                            ManagerMode = not ManagerMode
                        end
                    end
                    if IsControlJustPressed(0, 74) then
                        if not ManagerMode then
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", "restaurant_"..CurRestaurant.."_counter_"..k, {slots = 5}, "Restaurant Counter "..k)
                            TriggerEvent("inventory:client:SetCurrentStash", "restaurant_"..CurRestaurant.."_counter_"..k)
                        else
                            TriggerServerEvent("restaurant:server:toggleAIDeliveries", CurRestaurant)
                        end
                    end
                    if IsControlJustPressed(0, 38) then
                        if not ManagerMode then
                            Menu.hidden = not Menu.hidden
                            CreateOrderMenu()
                        elseif GetGameTimer() - LastPress > 2000 then
                            LastPress = GetGameTimer()
                            TriggerServerEvent("restaurant:server:processReceipts", CurRestaurant)
                        end
                    end
                end
            end
            for k,v in pairs(Config.Restaurants[CurRestaurant].storageLocations) do
                local dist = #(plyPos - v.pos)
                if dist <= 1.5 then
                    nearby = true
                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, "[~g~E~w~] "..v.label.." Storage")
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", "restaurant_"..CurRestaurant.."_"..v.label, nil, v.label.." Storage")
                        TriggerEvent("inventory:client:SetCurrentStash", "restaurant_"..CurRestaurant.."_"..v.label)
                    end
                end
            end
            if not Menu.hidden then
                Menu.renderGUI()
                if IsControlJustPressed(1, 177) and not Menu.hidden then
                    if MenuTitle == "Modify" then
                        CreateOrderMenu({previousSelection = previousSelection-1})
                    else
                        closeMenuFull()
                    end
                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                end
            end
            if Config.Restaurants[CurRestaurant].managementStash and PlayerData.job.grade.level >= Config.Restaurants[CurRestaurant].managementStash.minimumGrade then
                local stash = Config.Restaurants[CurRestaurant].managementStash
                local dist = #(plyPos - stash.pos)
                if dist <= 1.0 then
                    nearby = true
                    BJCore.Functions.DrawText3D(stash.pos.x, stash.pos.y, stash.pos.z, "[~g~E~w~] Management Storage")
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", "restaurant_"..CurRestaurant.."_management", nil, "Management Storage")
                        TriggerEvent("inventory:client:SetCurrentStash", "restaurant_"..CurRestaurant.."_management")
                    end
                end
            end
            if (not atStaffCounter and not atCustomerCounter) then BJCore.Functions.PersistentNotify("end", "counterOrder") ShowingOrderNotif = false; end
            if not atStaffCounter then Menu.hidden = true; end
            atStaffCounter, atCustomerCounter = false, false
            if not nearby then Citizen.Wait(1000); end
            Citizen.Wait(0)
        end
        StaffThreadRunning = false
    end)
end

function FormatOrderNotif(forceData)
    if CurCounter then
        ShowingOrderNotif = true
        local orderString = ""
        local orderData = GetCounterData(CurCounter).order
        if forceData ~= nil then
            orderData = forceData[CurRestaurant].counters[CurCounter].order
        end

        for k,v in pairs(orderData) do
            orderString = orderString..v.." "..BJCore.Shared.Items[k].label.."<br>"
        end
        local backgroundColor = "#ff8800"
        local paidString = ""
        if atStaffCounter then
            local paidData = GetCounterData(CurCounter)
            if paidData.paid then
                backgroundColor = "#33c208"
                paidString = "<br>Paid: "..paidData.paid
            end

        end
        BJCore.Functions.PersistentNotify("start", "counterOrder", "<u><b>Counter "..CurCounter.."</b></u><br> "..orderString.." Total: "..BJCore.Config.Currency.Symbol..CalculateOrderPrice(CurRestaurant, orderData)..paidString, "success", { ['background-color'] = backgroundColor, ['color'] = '#ffffff' })
    end
end

function CreateOrderMenu(data, forceClear)
    MenuTitle = "Options"
    TriggerEvent("police:client:pauseKeybind", true)
    ClearMenu()
    Menu.selection = 1
    if data and tonumber(data.previousSelection) then
        Menu.selection = data.previousSelection
    end
    Menu.addButton("Restaurant Menu", "yeet", "Menu", nil, "Title")
    Menu.addButton("Process", "UpdateOrder", {action = "process"}, nil, "Title")
    Menu.addButton("Clear", "UpdateOrder", {action = "clear"}, nil, "Remove")
    for k,v in pairs(Config.RestaurantMenu[CurRestaurant]) do
        Menu.addButton(BJCore.Shared.Items[k].label, "ModifyItemOrder", {item = k}, BJCore.Config.Currency.Symbol..v)
    end
    Menu.addButton("Close Menu", "closeMenuFull", {})
end

function GetCounterData(counter)
    local counterData = CopyTable(GlobalState.Restaurants)
    counterData = counterData[CurRestaurant].counters
    return counterData[counter]
end

function ModifyItemOrder(data)
    previousSelection = data.previousSelection
    MenuTitle = "Modify"
    ClearMenu()
    Menu.selection = 1
    Menu.addButton(BJCore.Shared.Items[data.item].label, "yeet", "Menu", BJCore.Config.Currency.Symbol..Config.RestaurantMenu[CurRestaurant][data.item], "Title")
    Menu.addButton("Add", "UpdateOrder", {item = data.item, action = "add"}, nil, "Title")
    Menu.addButton("Remove", "UpdateOrder", {item = data.item, action = "remove"}, nil, "Remove")
end

function UpdateOrder(data, buttonInfo)
    if data.action == "add" then
        if CurOrder[data.item] == nil then
            CurOrder[data.item] = 0
        end
        CurOrder[data.item] = CurOrder[data.item] + 1
        TriggerServerEvent("restaurant:server:counterAction", "update", CurRestaurant, CurCounter, CurOrder)
        --Menu.updateButton(buttonInfo.page, buttonInfo.button-1, BJCore.Shared.Items[data.item].label, "yeet", "Menu", tostring(CurOrder[data.item]), "Title")
    elseif data.action == "remove" then
        if CurOrder[data.item] ~= nil then
            if CurOrder[data.item] - 1 >= 0 then
                CurOrder[data.item] = CurOrder[data.item] - 1
                TriggerServerEvent("restaurant:server:counterAction", "update", CurRestaurant, CurCounter, CurOrder)
                --Menu.updateButton(buttonInfo.page, buttonInfo.button-2, BJCore.Shared.Items[data.item].label, "yeet", "Menu", tostring(CurOrder[data.item]), "Title")
            end
        end
    elseif data.action == "clear" then
        TriggerServerEvent("restaurant:server:counterAction", "clear", CurRestaurant, CurCounter)
        CreateOrderMenu({previousSelection = previousSelection-1}, true)
        CurOrder = {}
    elseif data.action == "process" then
        TriggerServerEvent("restaurant:server:counterAction", "process", CurRestaurant, CurCounter)
    end
end

function DestroyRestaurantZones()
    for k,v in pairs(RestaurantsPolyZones) do
        if v ~= false then
            RestaurantsPolyZones[k]:destroy()
        end
    end
    for k,v in pairs(KitchenPolyZones) do
        if v ~= false then
            KitchenPolyZones[k]:destroy()
        end
    end
end

AddStateBagChangeHandler('Restaurants', 'global', function(bagName, key, value, reserved, replicated)
    if next(value) == nil then return; end
    FormatOrderNotif(value)
end)

AddEventHandler("restaurant:client:cookInteract", function(data)
    local cookData = GetCookData(isAtCooker, data[1])
    print("cookData: "..BJCore.Common.Dump(cookData))
    if not cookData.status then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "restaurant_"..CurRestaurant.."_cookstation_"..isAtCooker.."_"..data[1], {temp = true, slots = 1}, "Cooking Station "..isAtCooker.." | Slot: "..data[1])
        TriggerEvent("inventory:client:SetCurrentStash", "restaurant_"..CurRestaurant.."_cookstation_"..isAtCooker.."_"..data[1])
    elseif cookData.status == 1 then
        BJCore.Functions.Notify("This meal isn't ready to take out", "error")
    elseif cookData.status == 2 then
        TriggerServerEvent("restaurant:server:completeCook", CurRestaurant, isAtCooker, data[1])
    elseif cookData.status > 2 then
        if cookData.status == 3 or cookData.status == 4 then
            TriggerServerEvent("restaurant:server:stopToClean", CurRestaurant, isAtCooker, data[1])
            local curStatus = cookData.status
            local notifyText, time = "You have overcooked this item", Config.OvercookedCleanTime
            if cookData.status == 4 then
                notifyText = "All items have been ruined"
                time = Config.RuinedCleanTime
            end
            BJCore.Functions.Notify(notifyText, "error")
            exports['mythic_progbar']:Progress({
                name = "progress_bar",
                duration = time*1000,
                label = "Cleaning",
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                    disableInteract = false
                },
                animation = {
                    animDict = "anim@amb@business@coc@coc_unpack_cut_left@",
                    anim = "coke_cut_v5_coccutter",
                },
            }, function(status)
                if not status then
                    TriggerServerEvent("restaurant:server:clearCookingSlot", CurRestaurant, isAtCooker, data[1], curStatus)
                end
            end)
        end
    end
end)

function GetCookData(station, id)
    print(station, id)
    local data = CopyTable(GlobalState.RestaurantCooks[CurRestaurant])
    for k,v in pairs(data[station]) do
        if k == id then
            return v
        end
    end
    return nil
end

AddTextEntry("cookingsummary", " [~g~ 1 ~w~] ~a~ \n [~g~ 2 ~w~] ~a~ \n [~g~ 3 ~w~] ~a~ \n [~g~ 4 ~w~] ~a~")

DrawText3DMulti = function(x, y, z, text, linecount)
    if not linecount or linecount == nil or linecount == 0 then
        linecount = 0.7
    end
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("cookingsummary")
    SetTextCentre(true)
    local longestText = 6
    for i=1, linecount do
        if text[i] ~= nil then
            AddTextComponentString(text[i])
            if longestText < string.len(text[i]) then
                longestText = string.len(text[i])
            end
        else
            AddTextComponentString(" - ")
        end
    end
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = longestText / 275
    DrawRect(0.0, 0.0+0.0405, 0.002 - factor, 0.02 * linecount, 0, 0, 0, 68)
    ClearDrawOrigin()
end

local activeOrdersIds = {}
function ActiveOrders(forceData)
    if PlayerData.job.name ~= CurRestaurant then return; end
    if not CurKitchen then return; end
    local orderData = CopyTable(GlobalState.RestaurantOrders)
    if forceData ~= nil then
        orderData = forceData
    end
    orderData = orderData[CurRestaurant]
    if not orderData then return; end
    for k,v in pairs(orderData) do
        if v and not v.hidden then
            activeOrdersIds[k] = true
            local orderString = ""
            for item,amount in pairs(v.order) do
                orderString = orderString..amount.." "..BJCore.Shared.Items[item].label.."<br>"
            end
            local counterString = "Counter: "..tostring(v.counter)
            if not v.counter then counterString = "Delivery"; end
            BJCore.Functions.PersistentNotify("start", "activeOrders_"..k, "<u><b>Order: "..k.."</b></u><br> "..orderString.."<br>"..counterString, "success", { ['background-color'] = "#ff8800", ['color'] = '#ffffff' })
        end
    end
end

function ClearActiveOrders()
    for k,v in pairs(activeOrdersIds) do
        BJCore.Functions.PersistentNotify("end", "activeOrders_"..k)
    end
end

RegisterNetEvent("restaurant:client:removeActiveOrder", function(id)
    if not CurRestaurant then return; end
    if not CurKitchen then return; end
    BJCore.Functions.PersistentNotify("end", "activeOrders_"..id)
end)

AddStateBagChangeHandler('RestaurantOrders', 'global', function(bagName, key, value, reserved, replicated)
    if next(value) == nil then return; end
    ActiveOrders(value)
end)

RegisterCommand("clearOrder", function(s,a,r)
    if a[1] == nil then return; end
    if not CurRestaurant then return; end
    if not CurKitchen then return; end
    if tonumber(a[1]) then
        TriggerServerEvent("restaurant:server:removeActiveOrder", CurRestaurant, tonumber(a[1]))
    else
        BJCore.Functions.Notify("You must include a numerical id", "erorr")
    end
end)

local delivering = false
RegisterNetEvent("restaurant:client:markForDelivery", function(data)
    SetNewWaypoint(Config.AIDeliveryLocations[data.delivery])
    BJCore.Functions.Notify("Order: "..data.id.." location marked on your GPS", "primary", 5000)
    delivering = {pos = data.delivery, restaurant = data.restaurant, id = data.id}
    DeliveryInteraction()
end)

RegisterNetEvent("restaurant:client:completeDelivery", function()
    delivering = false
end)

local deliverPed = false
local curDelivery = false
local activeDeliveries = {}
function DeliveryInteraction()
    if curDelivery and curDelivery == delivering.id then print("stopping dupe delivery") return; end
    Citizen.CreateThread(function()
        local LastPress = 0
        local CurDelivery = delivering.id
        curDelivery = CurDelivery
        -- activeDeliveries[curDelivery] = GetGameTimer()
        while delivering and delivering.id == CurDelivery do
            local sleep = 1000
            local plyPos = GetEntityCoords(PlayerPedId())
            local dist = #(plyPos - Config.AIDeliveryLocations[delivering.pos].xyz)
            if dist <= 50 then
                if not deliverPed then
                    CreateDropOffPed()
                end
                if dist < 2 then
                    sleep = 1
                    BJCore.Functions.DrawText3D(Config.AIDeliveryLocations[delivering.pos].x, Config.AIDeliveryLocations[delivering.pos].y, Config.AIDeliveryLocations[delivering.pos].z, "[~g~E~w~] Deliver")
                    if IsControlJustPressed(0, 38) and GetGameTimer() - LastPress > 2000 then
                        LastPress = GetGameTimer()
                        TriggerServerEvent("restaurant:client:deliverOrder", delivering)
                    end
                end
            end
            -- if GetGameTimer() - activeDeliveries[curDelivery] > (10*60*1000) then
            --     break
            -- end
            Citizen.Wait(sleep)
        end
        print("CurDelivery stopped: "..CurDelivery)
        if deliverPed then
            Citizen.Wait(5000)
            DeleteEntity(deliverPed)
            deliverPed = false
        end
    end)
end

function CreateDropOffPed()
    local hashKey = `a_m_m_business_01`
    RequestModel(hashKey)
    while not HasModelLoaded(hashKey) do
        RequestModel(hashKey)
        Citizen.Wait(100)
    end

    deliverPed = CreatePed(5, hashKey, Config.AIDeliveryLocations[delivering.pos].x, Config.AIDeliveryLocations[delivering.pos].y, Config.AIDeliveryLocations[delivering.pos].z, Config.AIDeliveryLocations[delivering.pos].w, 0, 0)

    ClearPedTasks(deliverPed)
    ClearPedSecondaryTask(deliverPed)
    TaskSetBlockingOfNonTemporaryEvents(deliverPed, true)
    SetPedFleeAttributes(deliverPed, 0, 0)
    SetPedCombatAttributes(deliverPed, 17, 1)

    SetPedSeeingRange(deliverPed, 0.0)
    SetPedHearingRange(deliverPed, 0.0)
    SetPedAlertness(deliverPed, 0)
    SetPedKeepTask(deliverPed, true)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return; end
    DestroyRestaurantZones()
    BJCore.Functions.PersistentNotify("end", "counterOrder")
    for k,v in pairs(activeOrdersIds) do
        BJCore.Functions.PersistentNotify("end", "activeOrders_"..k)
    end
end)

local CashCarryLocations = {
    vector3(337.07324, -1119.37, 29.405632),
}

local shopItems = {
    [1] = {
        name = "water_bottle",
        price = 1,
        amount = 10,
        info = {},
        type = "item",
        slot = 1,
    },
}

Citizen.CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        local nearby = false
        local lastPress = 0
        for k,v in pairs(CashCarryLocations) do
            local dist = #(plyPos - v)
            if dist < 5 then
                nearby = true
                if dist < 1 then
                    BJCore.Functions.DrawText3D(v.x, v.y, v.z, "[~g~E~w~] Cash & Carry")
                    if IsControlJustPressed(0, 38) and GetGameTimer() - lastPress >= 3000 then
                        lastPress = GetGameTimer()
                        BJCore.Functions.TriggerServerCallback("restaurant:server:getCashCarryItem", function(job)
                            if job then
                                local ShopItems = {}
                                ShopItems.label = "Cash & Carry"
                                ShopItems.items = shopItems
                                ShopItems.slots = #shopItems
                                TriggerServerEvent("inventory:server:OpenInventory", "shop", "Jobshop_"..job, ShopItems)
                            else
                                BJCore.Functions.Notify("You need a cash and carry card to use this shop", "error")
                            end
                        end)
                    end
                end
            end
        end
        if not nearby then Citizen.Wait(1000); end
        Citizen.Wait(0)
    end
end)
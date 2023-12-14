BJCore = nil

inInventory = false
hotbarOpen = false

local inventoryTest = {}
local currentWeapon = nil
local CurrentWeaponData = {}
local currentOtherInventory = nil

local Drops = {}
local CurrentDrop = 0
local DropsNear = {}

local OpenedDrop = nil
local CurrentVehicle = nil
local CurrentGlovebox = nil
local CurrentStash = nil
local CurrentSafe = nil
local CurrentBin = nil
local CurrentSmelter = nil
local CurrentCraft = nil
local isCrafting = false
local craftTabType = false

local showTrunkPos = false

Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

RegisterNetEvent('radialmenu:hidden')
AddEventHandler('radialmenu:hidden', function()
	ToggleHotbar(false)
end)

RegisterNetEvent('inventory:client:CheckOpenState')
AddEventHandler('inventory:client:CheckOpenState', function(type, id, label)
    local name = BJCore.Shared.SplitStr(label, "-")[2]
    if type == "stash" then
        if name ~= CurrentStash or CurrentStash == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "trunk" then
        if name ~= CurrentVehicle or CurrentVehicle == nil then
            print("setsafe")
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "glovebox" then
        if name ~= CurrentGlovebox or CurrentGlovebox == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "safe" then
        if name ~= CurrentSafe or CurrentSafe == nil then
            print("setsafe")
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "bin" then
        if name ~= CurrentBin or CurrentBin == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "smelter" then
        if name ~= CurrentSmelter or CurrentSmelter == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    
    elseif type == "crafting" then
        if name ~= CurrentCraft or CurrentCraft == nil then
            print('Check if craft open: '..id)
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
            TriggerEvent('Crafting:TableClosed')
        end
    elseif type == "drop" then
        if OpenedDrop == nil or tostring(name) ~= tostring(OpenedDrop) then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    end
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon')
AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
end)

RegisterNetEvent("inventory:checkForVending")
AddEventHandler("inventory:checkForVending", function()
    if IsNearVending() then
        Citizen.Wait(1000)
        ClearPedTasks(PlayerPedId())
        local ShopItems = {}
        ShopItems.label = "Vending Machine"
        ShopItems.items = Config.VendingItem
        ShopItems.slots = #Config.VendingItem
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_"..math.random(1, 99), ShopItems)
    else
        BJCore.Functions.Notify('Vending Machine not found', 'error')
    end
end)

function IsNearVending()
    for i = 1, #Config.VendingObjects do
        local model = Config.VendingObjects[i]
        if type(Config.VendingObjects[i]) ~= "number" then model = GetHashKey(Config.VendingObjects[i]); end
        local objFound = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 0.75, model, 0, 0, 0)
  
        if DoesEntityExist(objFound) then
            TaskTurnPedToFaceEntity(PlayerPedId(), objFound, 3.0)
        return true
        end
    end
  
    return false
end
exports('IsNearVending', IsNearVending)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2)
        DisableControlAction(0, Keys["1"], true)
        DisableControlAction(0, Keys["2"], true)
        DisableControlAction(0, Keys["3"], true)
        DisableControlAction(0, Keys["4"], true)
        DisableControlAction(0, Keys["5"], true)
        if IsControlJustPressed(0, Keys["Z"]) then
            ToggleHotbar(true)
        end
        if IsControlJustReleased(0, Keys["Z"]) then
            ToggleHotbar(false)
        end
    end
end)

RegisterKeyMapping('-inventory', 'Inventory~', 'keyboard', 'F2')
RegisterCommand('-inventory', function()
    if not BJCore.Functions.IsOnscreenKeyboard() then
        if not isCrafting and GetLastInputMethod(0) then
            BJCore.Functions.GetPlayerData(function(PlayerData)
                if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
                    local curVeh = nil
                    if IsPedInAnyVehicle(PlayerPedId()) then
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        CurrentGlovebox = GetVehicleNumberPlateText(vehicle)
                        curVeh = vehicle
                        CurrentVehicle = nil
                    else
                        local vehicle = BJCore.Functions.GetClosestVehicle()
                        if vehicle ~= 0 and vehicle ~= nil then
                            local pos = GetEntityCoords(PlayerPedId())
                            local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                            if (IsBackEngine(GetEntityModel(vehicle))) then
                                trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                            end
                            if #(pos - trunkpos) < 2.0 and not IsPedInAnyVehicle(PlayerPedId()) then
                                if GetVehicleDoorLockStatus(vehicle) < 2 then
                                    CurrentVehicle = GetVehicleNumberPlateText(vehicle)
                                    curVeh = vehicle
                                    CurrentGlovebox = nil
                                else
                                    BJCore.Functions.Notify("Vehicle is locked", "error")
                                    return
                                end
                            else
                                CurrentVehicle = nil
                            end
                        else
                            CurrentVehicle = nil
                        end
                    end

                    if CurrentVehicle ~= nil then
                        local maxweight = 0
                        local slots = 0
                        if GetVehicleClass(curVeh) == 0 then
                            maxweight = 38000
                            slots = 30
                        elseif GetVehicleClass(curVeh) == 1 then
                            maxweight = 50000
                            slots = 40
                        elseif GetVehicleClass(curVeh) == 2 then
                            maxweight = 75000
                            slots = 50
                        elseif GetVehicleClass(curVeh) == 3 then
                            maxweight = 42000
                            slots = 35
                        elseif GetVehicleClass(curVeh) == 4 then
                            maxweight = 38000
                            slots = 30
                        elseif GetVehicleClass(curVeh) == 5 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 6 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 7 then
                            maxweight = 30000
                            slots = 25
                        elseif GetVehicleClass(curVeh) == 8 then
                            maxweight = 15000
                            slots = 15
                        elseif GetVehicleClass(curVeh) == 9 then
                            maxweight = 60000
                            slots = 35
                        elseif GetVehicleClass(curVeh) == 12 then
                            maxweight = 120000
                            slots = 35
                        else
                            maxweight = 60000
                            slots = 35
                        end
                        local other = {
                            maxweight = maxweight,
                            slots = slots,
                        }
                        TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                        OpenTrunk()
                    elseif CurrentGlovebox ~= nil then
                        TriggerServerEvent("inventory:server:OpenInventory", "glovebox", CurrentGlovebox)
                    elseif CurrentDrop ~= 0 then
                        TriggerServerEvent("inventory:server:OpenInventory", "drop", CurrentDrop)
                    else
                        TriggerServerEvent("inventory:server:OpenInventory")
                    end
                end
            end)
        end
    end
end)

RegisterKeyMapping('-hotbar1', 'Hotbar Slot 1~', 'keyboard', '1')
RegisterCommand('-hotbar1', function()
    if BJCore.Functions.IsOnscreenKeyboard() then return; end
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 1)
        end
    end)
end, false)

RegisterKeyMapping('-hotbar2', 'Hotbar Slot 2~', 'keyboard', '2')
RegisterCommand('-hotbar2', function()
    if BJCore.Functions.IsOnscreenKeyboard() then return; end
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 2)
        end
    end)
end, false)

RegisterKeyMapping('-hotbar3', 'Hotbar Slot 3~', 'keyboard', '3')
RegisterCommand('-hotbar3', function()
    if BJCore.Functions.IsOnscreenKeyboard() then return; end
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 3)
        end
    end)
end, false)

RegisterKeyMapping('-hotbar4', 'Hotbar Slot 4~', 'keyboard', '4')
RegisterCommand('-hotbar4', function()
    if BJCore.Functions.IsOnscreenKeyboard() then return; end
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 4)
        end
    end)
end, false)

RegisterKeyMapping('-hotbar5', 'Hotbar Slot 5~', 'keyboard', '5')
RegisterCommand('-hotbar5', function()
    if BJCore.Functions.IsOnscreenKeyboard() then return; end
    BJCore.Functions.GetPlayerData(function(PlayerData)
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] then
            TriggerServerEvent("inventory:server:UseItemSlot", 5)
        end
    end)
end, false)

RegisterNetEvent('inventory:client:ItemBox')
AddEventHandler('inventory:client:ItemBox', function(itemData, type)
    SendNUIMessage({
        action = "itemBox",
        item = itemData,
        type = type
    })
end)

RegisterNetEvent('inventory:client:requiredItems')
AddEventHandler('inventory:client:requiredItems', function(items, bool)
    local itemTable = {}
    if bool then
        for k, v in pairs(items) do
            table.insert(itemTable, {
                item = items[k].name,
                label = BJCore.Shared.Items[items[k].name]["label"],
                image = items[k].image,
            })
        end
    end
    
    SendNUIMessage({
        action = "requiredItem",
        items = itemTable,
        toggle = bool
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if DropsNear ~= nil then
            for k, v in pairs(DropsNear) do
                if DropsNear[k] ~= nil and next(DropsNear[k]) ~= nil then
                    DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 30, 144, 255, 155, false, false, false, false, false, false, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if Drops ~= nil and next(Drops) ~= nil then
            local pos = GetEntityCoords(PlayerPedId(), true)
            for k,v in pairs(DropsNear) do
                if not Drops[k] then
                    DropsNear[k] = nil
                end
            end
            for k, v in pairs(Drops) do
                if Drops[k] ~= nil then 
                    if #(pos - v.coords) < 7.5 then
                        DropsNear[k] = v
                        if #(pos - v.coords) < 2 then
                            CurrentDrop = k
                        else
                            CurrentDrop = 0
                        end
                    else
                        DropsNear[k] = nil
                    end
                end
            end
        else
            DropsNear = {}
        end
        Citizen.Wait(500)
    end
end)

RegisterNetEvent("BJCore:Client:OnPlayerLoaded")
AddEventHandler("BJCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("inventory:server:LoadDrops")
end)

RegisterNetEvent('inventory:client:SetDrops')
AddEventHandler('inventory:client:SetDrops', function(drops)
    Drops = drops
end)

RegisterNetEvent('inventory:server:RobPlayer')
AddEventHandler('inventory:server:RobPlayer', function(TargetId)
    SendNUIMessage({
        action = "RobMoney",
        TargetId = TargetId,
    })
end)

RegisterNUICallback('RobMoney', function(data, cb)
    TriggerServerEvent("police:server:RobPlayer", data.TargetId)
end)

RegisterNUICallback('Notify', function(data, cb)
    BJCore.Functions.Notify(data.message, data.type)
end)

-- function startInInventoryLoop()
--     Citizen.CreateThread(function()
--         local playerId = PlayerId()
--     	while inInventory do
--             DisablePlayerFiring(playerId, true)
--             DisableAllControlActions(0)
--             DisableAllControlActions(1)
--             DisableAllControlActions(2)
--             DisableControlAction(0, 24, true)
--             EnableControlAction(1, 249, true)
-- 
--     		Wait(0)
--     	end
--     end)
-- end

RegisterNetEvent('openInvAnim')
AddEventHandler('openInvAnim', function()
    LoadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent("inventory:client:OpenInventory")
AddEventHandler("inventory:client:OpenInventory", function(PlayerAmmo, inventory, other)
    if not IsEntityDead(PlayerPedId()) then
        ToggleHotbar(false)
        SetTimecycleModifier('hud_def_blur')
        SetNuiFocus(true, true)
        if other ~= nil then
            currentOtherInventory = other.name
            if BJCore.Shared.SplitStr(currentOtherInventory, "-")[1] == 'crafting' then
                local _recipes = exports.crafting:GetRecipes()
                craftTabType = other.tabType
                print('Updating recipes from crafting')
                SendNUIMessage({
                    action = "setRecipes",
                    recipes = _recipes
                })
            end
        else
            TriggerEvent('openInvAnim')
        end
        SendNUIMessage({
            action = "open",
            inventory = inventory,
            slots = MaxInventorySlots,
            other = other,
            maxweight = BJCore.Config.Player.MaxWeight,
            Ammo = PlayerAmmo,
            maxammo = Config.MaximumAmmoValues,
            allowGive = Config.AllowGive,
            allowDestroy = Config.AllowDestroy
        })
        inInventory = true
        SetControlNormal(0, 24, 0)
        -- startInInventoryLoop()
    end
end)

RegisterNetEvent("inventory:client:ShowTrunkPos")
AddEventHandler("inventory:client:ShowTrunkPos", function()
    showTrunkPos = true
end)

RegisterNetEvent("inventory:client:UpdatePlayerInventory")
AddEventHandler("inventory:client:UpdatePlayerInventory", function(isError)
    SendNUIMessage({
        action = "update",
        inventory = BJCore.Functions.GetPlayerData().items,
        maxweight = BJCore.Config.Player.MaxWeight,
        slots = MaxInventorySlots,
        error = isError,
    })
end)

RegisterNetEvent("inventory:client:CraftItems")
AddEventHandler("inventory:client:CraftItems", function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true

    exports['mythic_progbar']:Progress({
        name = "crafting_inv",
        duration = (math.random(2000, 5000) * amount),
        label = "Crafting",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
            TriggerServerEvent("inventory:server:CraftItems", itemName, itemCosts, amount, toSlot, points)
            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[itemName], 'add')
            isCrafting = false
        else
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
            isCrafting = false                   
        end
    end)
end)

RegisterNetEvent('inventory:client:CraftAttachment')
AddEventHandler('inventory:client:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    exports['mythic_progbar']:Progress({
        name = "crafting_inv",
        duration = (math.random(2000, 5000) * amount),
        label = "Crafting",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
            TriggerServerEvent("inventory:server:CraftAttachment", itemName, itemCosts, amount, toSlot, points)
            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[itemName], 'add')
            isCrafting = false
        else
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
            BJCore.Functions.Notify("Cancelled", "error")
            isCrafting = false                   
        end
    end)
end)

RegisterNetEvent("inventory:client:PickupSnowballs")
AddEventHandler("inventory:client:PickupSnowballs", function()
    LoadAnimDict('anim@mp_snowball')
    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 3.0, 3.0, -1, 0, 1, 0, 0, 0)
    exports['mythic_progbar']:Progress({
        name = "pickupsnowball",
        duration = 2000,
        label = "Picking up Snowballs",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('BJCore:Server:AddItem', "snowball", 1)
            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items["snowball"], "add")
        else
            ClearPedTasks(PlayerPedId())
            BJCore.Functions.Notify("Cancelled", "error")                 
        end
    end)
end)

RegisterNetEvent("inventory:client:UseSnowball")
AddEventHandler("inventory:client:UseSnowball", function(amount)
    GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_snowball"), amount, false, false)
    SetPedAmmo(PlayerPedId(), GetHashKey("weapon_snowball"), amount)
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_snowball"), true)
end)

RegisterNetEvent("inventory:client:UseWeapon")
AddEventHandler("inventory:client:UseWeapon", function(weaponData, shootbool)
    local weaponName = tostring(weaponData.name)
    if currentWeapon == weaponName then
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        RemoveAllPedWeapons(PlayerPedId(), true)
        TriggerEvent('weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif exports["weapons"]:IsThrowable(weaponName) then
        GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponName), ammo, false, false)
        SetPedAmmo(PlayerPedId(), GetHashKey(weaponName), 1)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey(weaponName), true)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    elseif weaponName == "weapon_snowball" then
        GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponName), ammo, false, false)
        SetPedAmmo(PlayerPedId(), GetHashKey(weaponName), 10)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey(weaponName), true)
        TriggerServerEvent('BJCore:Server:RemoveItem', weaponName, 1)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    else
        BJCore.Functions.TriggerServerCallback("weapon:server:GetWeaponAmmo", function(result)
            local ammo = tonumber(result)
            if weaponName == "weapon_fireextinguisher" then 
                ammo = 4000 
            end
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponName), ammo, false, false)
            if weaponData.info.attachments ~= nil then
                for _, attachment in pairs(weaponData.info.attachments) do
                    GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(weaponName), GetHashKey(attachment.component))
                end
            end
            SetPedAmmo(PlayerPedId(), GetHashKey(weaponName), ammo)
            SetCurrentPedWeapon(PlayerPedId(), GetHashKey(weaponName), true)
            currentWeapon = weaponName
            TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        end, weaponData)
    end
end)

function FormatWeaponAttachments(itemdata)
    local attachments = {}
    itemdata.name = itemdata.name:upper()
    if itemdata.info.attachments ~= nil and next(itemdata.info.attachments) ~= nil then
        for k, v in pairs(itemdata.info.attachments) do
            local attachment = exports['weapons']:GetAttachment(itemdata.name)
            if attachment ~= nil then
                for key, value in pairs(attachment) do
                    if value.component == v.component then
                        table.insert(attachments, {
                            attachment = key,
                            label = value.label,
                            item = value.item
                        })
                    end
                end
            end
        end
    end
    return attachments
end

RegisterNUICallback('GetWeaponData', function(data, cb)
    local data = {
        WeaponData = BJCore.Shared.Items[data.weapon],
        AttachmentData = FormatWeaponAttachments(data.ItemData)
    }
    cb(data)
end)

RegisterNUICallback('RemoveAttachment', function(data, cb)
    local WeaponData = BJCore.Shared.Items[data.WeaponData.name]
    local WeaponAttachmentData = exports['weapons']:GetAttachment(WeaponData.name:upper())
    local Attachment = WeaponAttachmentData[data.AttachmentData.attachment]
    
    BJCore.Functions.TriggerServerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
        if NewAttachments ~= false then
            local Attachies = {}
            RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            for k, v in pairs(NewAttachments) do
                for wep, pew in pairs(WeaponAttachmentData) do
                    if v.component == pew.component then
                        table.insert(Attachies, {
                            attachment = pew.item,
                            label = pew.label,
                        })
                    end
                end
            end
            local DJATA = {
                Attachments = Attachies,
                WeaponData = WeaponData,
            }
            cb(DJATA)
        else
            RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            cb({})
        end
    end, data.AttachmentData, data.WeaponData)
end)

RegisterNetEvent("inventory:client:ResetWeapon")
AddEventHandler("inventory:client:ResetWeapon", function()
    TriggerEvent('weapons:ResetHolster')
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    RemoveAllPedWeapons(PlayerPedId(), true)
    currentWeapon = nil
end)

RegisterNetEvent("inventory:client:CheckWeapon")
AddEventHandler("inventory:client:CheckWeapon", function(weaponName, force)
    if currentWeapon == weaponName or force then 
        TriggerEvent('weapons:ResetHolster')
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        RemoveAllPedWeapons(PlayerPedId(), true)
        currentWeapon = nil
    end
end)

RegisterNetEvent("inventory:client:AddDropItem")
AddEventHandler("inventory:client:AddDropItem", function(dropId, coords)
    Drops[dropId] = {
        id = dropId,
        coords = coords,
    }
end)

RegisterNetEvent("inventory:client:RemoveDropItem")
AddEventHandler("inventory:client:RemoveDropItem", function(dropId)
    Drops[dropId] = nil
end)

RegisterNetEvent("inventory:client:DropItemAnim")
AddEventHandler("inventory:client:DropItemAnim", function()
    SendNUIMessage({
        action = "close",
    })
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Citizen.Wait(2000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent("inventory:client:ShowId")
AddEventHandler("inventory:client:ShowId", function(sourcePos, citizenid, character)
    local pos = GetEntityCoords(PlayerPedId(), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 2.0) then
        local gender = "Male"
        if character.gender == "1" then
            gender = "Female"
        end
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>CSN:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>Birth Date:</strong> {4} <br><strong>Sex:</strong> {5} <br><strong>Nationality:</strong> {6}</div></div>',
            args = {'ID-Card', character.citizenid, character.firstname, character.lastname, character.birthdate, gender, character.nationality}
        })
    end
end)

RegisterNetEvent("inventory:client:ShowDriverLicense")
AddEventHandler("inventory:client:ShowDriverLicense", function(sourcePos, citizenid, character)
    local pos = GetEntityCoords(PlayerPedId(), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 2.0) then
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
            args = {'Drivers License', character.firstname, character.lastname, character.birthdate, character.type}
        })
    end
end)

RegisterNetEvent("inventory:client:SetCurrentStash")
AddEventHandler("inventory:client:SetCurrentStash", function(stash)
    CurrentStash = stash
end)

RegisterNetEvent("inventory:client:SetCurrentSafe")
AddEventHandler("inventory:client:SetCurrentSafe", function(safe)
    CurrentSafe = safe
end)

RegisterNetEvent("inventory:client:SetCurrentBin")
AddEventHandler("inventory:client:SetCurrentBin", function(bin)
    CurrentBin = bin
end)

RegisterNetEvent("inventory:client:SetCurrentSmelter")
AddEventHandler("inventory:client:SetCurrentSmelter", function(smelter)
    CurrentSmelter = smelter
end)

RegisterNetEvent("inventory:client:SetCurrentCraft")
AddEventHandler("inventory:client:SetCurrentCraft", function(craft)
    print('Set current craft: '..craft)
    CurrentCraft = craft
end)

RegisterNetEvent("inventory:client:SetCurrentDrop")
AddEventHandler("inventory:client:SetCurrentDrop", function(drop)
    OpenedDrop = drop
end)

RegisterNUICallback('getCombineItem', function(data, cb)
    cb(BJCore.Shared.Items[data.item])
end)

RegisterNUICallback("CloseInventory", function(data, cb)
    TriggerEvent('openInvAnim') 
    if currentOtherInventory == "none-inv" then
        CurrentDrop = 0
        OpenedDrop = nil
        CurrentVehicle = nil
        CurrentGlovebox = nil
        CurrentStash = nil
        CurrentSafe = nil
        CurrentBin = nil
        CurrentSmelter = nil
        CurrentCraft = nil
        SetTimecycleModifier('default')
        SetNuiFocus(false, false)

        inInventory = false
        ClearPedTasks(PlayerPedId())
        return
    end
    ForceSaveInventories()
    SetTimecycleModifier('default')
    SetNuiFocus(false, false)
    inInventory = false
end)

function ForceSaveInventories()
    if CurrentVehicle ~= nil then
        CloseTrunk()
        TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
        CurrentVehicle = nil
    elseif CurrentGlovebox ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
        CurrentGlovebox = nil
    elseif CurrentStash ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
        CurrentStash = nil
    elseif CurrentSafe ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "safe", CurrentSafe)
        CurrentSafe = nil
    elseif CurrentBin ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "bin", CurrentBin)
        CurrentBin = nil
    elseif CurrentSmelter ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "smelter", CurrentSmelter)
        CurrentSmelter = nil
    elseif CurrentCraft ~= nil then
        TriggerServerEvent("inventory:server:SetIsOpenState", false, "crafting", BJCore.Shared.SplitStr(CurrentCraft, "-")[2])
        TriggerEvent('Crafting:TableClosed')
        CurrentCraft = nil
        -- Do nothing, wait for DoCraft callback
    elseif OpenedDrop ~= nil then
        print('Closing drop: '..tostring(OpenedDrop))
        TriggerServerEvent("inventory:server:SaveInventory", "drop", OpenedDrop)
        CurrentDrop = 0
        OpenedDrop = nil
    end
end

RegisterNUICallback('DoCraft', function(data, cb)
    if data then
        SetTimecycleModifier('default')
        SetNuiFocus(false, false)
        inInventory = false
        local _recipes = exports.crafting:GetRecipes()
        local craftTime = (_recipes[data.recipe] and _recipes[data.recipe].craftTime or 3.0)
        exports['mythic_progbar']:Progress({
            name = "progress_bar",
            duration = craftTime * 1000,
            label = "Crafting",
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
                disableInteract = true
            },
            animation = {
                animDict = "anim@amb@business@coc@coc_unpack_cut_left@",
                anim = "coke_cut_v5_coccutter",
            },
        }, function(status)
            if not status then
                TriggerServerEvent("inventory:server:SaveInventory", "crafting", BJCore.Shared.SplitStr(CurrentCraft, "-")[2], data)
                CurrentCraft = nil
                TriggerEvent('Crafting:TableClosed')
            end
        end)
    end
end)

RegisterNUICallback('CanCraft', function(data, cb)
    if data then
        BJCore.Functions.TriggerServerCallback('Crafting:CanCraft', function(success, error)
            if not error and success then
                cb('OK')
            elseif not error then
                cb('Unable to craft this item')
            else
                cb(error)
            end
        end, data.recipe, craftTabType)
    end
end)

RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("inventory:server:UseItem", data.inventory, data.item)
end)

RegisterNUICallback("GiveItem", function(data, cb)
    local closest = BJCore.Functions.GetClosestPlayerRadius(2.0)
    if closest ~= nil then
        TriggerServerEvent("inventory:server:giveItem", GetPlayerServerId(closest), data.item, data.amount)
    else
        BJCore.Functions.Notify("Player not found", "error")
    end
end)

RegisterNUICallback("DestroyItem", function(data, cb)
    TriggerServerEvent("inventory:server:destroyItem", data.item, data.amount)
end)

RegisterNUICallback("combineItem", function(data)
    Citizen.Wait(150)
    TriggerServerEvent('inventory:server:combineItem', data.reward, data.fromItem, data.toItem)
    TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[data.reward], 'add')
end)

RegisterNUICallback('combineWithAnim', function(data)
    local combineData = data.combineData
    local aDict = combineData.anim.dict
    local aLib = combineData.anim.lib
    local animText = combineData.anim.text
    local animTimeout = combineData.anim.timeOut

    exports['mythic_progbar']:Progress({
        name = "combine_anim",
        duration = animTimeout,
        label = animText,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = aDict,
            anim = aLib,
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
            TriggerServerEvent('inventory:server:combineItem', combineData.reward, data.requiredItem, data.usedItem)
            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[combineData.reward], 'add')
        else
            StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
            BJCore.Functions.Notify("Cancelled", "error")                     
        end
    end)
end)

RegisterNUICallback("SetInventoryData", function(data, cb)
    local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
    local forward = GetEntityForwardVector(GetPlayerPed(GetPlayerFromServerId(player)))
    local x, y, z = table.unpack(coords + forward * 0.5)
    local dropCoords = vector3(x, y, z - 0.3)
    local binData = {}

    for i = 1, #Config.BinObjects do
        local objFound = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 0.75, Config.BinObjects[i], 0, 0, 0)
        if DoesEntityExist(objFound) then
            binData = {
                binid = DecorGetInt(objFound, 'BinId') or 0,
                pos = GetEntityCoords(objFound),
                heading = GetEntityHeading(objFound),
                model = GetEntityModel(objFound),
            }
        end
    end
    TriggerServerEvent("inventory:server:SetInventoryData", dropCoords, data.fromInventory, data.toInventory, data.fromSlot, data.toSlot, data.fromAmount, data.toAmount, binData)
end)

RegisterNUICallback("combineLaptop", function(data)
    local combineData = data.combineData
    local aDict = combineData.anim.dict
    local aLib = combineData.anim.lib
    local animText = combineData.anim.text
    local animTimeout = combineData.anim.timeOut
    exports['mythic_progbar']:Progress({
        name = "combine_anim",
        duration = animTimeout,
        label = animText,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = aDict,
            anim = aLib,
            flags = 16,
        },
    }, function(status)
        if not status then
            StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
            local usbItem = BJCore.Functions.GetPlayerData().items[data.usedItemSlot]
            if usbItem.info then
                if not usbItem.info.encrypted then
                    BJCore.Functions.TriggerServerCallback("crim:server:GetExpiry", function(canUse)
                        if canUse then
                            TriggerServerEvent("BJCore:Server:RemoveItem", data.requiredItem, 1, data.usedItemSlot)
                            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[data.requiredItem], "remove")
                            if data.requiredItem == 'greenusb' then
                                exports["fleeca"]:getRandomTruckSpawn()
                            end
                        else
                            BJCore.Functions.Notify("This USB has expired and the data on it is not longer useable")
                        end
                    end, usbItem.info.expires)
                else
                    BJCore.Functions.Notify("This usb is encrypted. It needs to be decrypted before you can access its data", "error", 10000)
                end
            end
        else
            StopAnimTask(PlayerPedId(), aDict, aLib, 1.0)
            BJCore.Functions.Notify("Cancelled", "error")                     
        end
    end)    
end)

RegisterNUICallback("PlayDropSound", function(data, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback("PlayDropFail", function(data, cb)
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
end)

function OpenTrunk()
    if BJCore.Functions.GetPlayerData().metadata["intrunk"] then return; end
    local vehicle = BJCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

function CloseTrunk()
    if BJCore.Functions.GetPlayerData().metadata["intrunk"] then return; end
    local vehicle = BJCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorShut(vehicle, 5, false)
    end
end

function IsBackEngine(vehModel)
    for _, model in pairs(BackEngineVehicles) do
        if GetHashKey(model) == vehModel then
            return true
        end
    end
    return false
end

function ToggleHotbar(toggle)
    local HotbarItems = {
        [1] = BJCore.Functions.GetPlayerData().items[1],
        [2] = BJCore.Functions.GetPlayerData().items[2],
        [3] = BJCore.Functions.GetPlayerData().items[3],
        [4] = BJCore.Functions.GetPlayerData().items[4],
        [5] = BJCore.Functions.GetPlayerData().items[5],
        --[41] = BJCore.Functions.GetPlayerData().items[41],
    } 

    if toggle then
        SendNUIMessage({
            action = "toggleHotbar",
            open = true,
            items = HotbarItems
        })
    else
        SendNUIMessage({
            action = "toggleHotbar",
            open = false,
        })
    end
end

function LoadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

-- SetNuiCloseCallback(function()
--     SendNUIMessage({
--         action = "close",
--     })
-- end)

RegisterNetEvent("core:resetUi")
AddEventHandler("core:resetUi", function()
    SendNUIMessage({
        action = "close",
    })
end)

local carryPackage, isHolding = nil, false
RegisterNetEvent("BJCore:Player:UpdateClientInventoryCache")
AddEventHandler("BJCore:Player:UpdateClientInventoryCache", function(data)
    local found = false
    for k,v in pairs(data) do
        if v.type == "carriable" then
            found = true
            break
        end
    end
    if found and not isHolding then
        PickupPackage()
    elseif not found and isHolding then
        DropPackage()
    end
end)

function PickupPackage()
    local plyPed = PlayerPedId()
    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do Citizen.Wait(0); end
    TaskPlayAnim(plyPed, "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey("prop_cs_cardbox_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0); end
    local object = CreateObject(model, GetEntityCoords(plyPed), true, true, true)
    AttachEntityToEntity(object, plyPed, GetPedBoneIndex(plyPed, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
    isHolding = true
    holdingTick(plyPed)
end

function holdingTick(plyPed)
    local stumble = false
    Citizen.CreateThread(function()
        while isHolding do
            if IsPedRunning(plyPed) then
                stumble = true
                SetPedToRagdoll(plyPed,2000,2000, 3, 0, 0, 0)
                Wait(2100)
                stumble = false
                TaskPlayAnim(plyPed,"anim@heists@box_carry@","idle",2.0, -8, 180000000, 49, 0, 0, 0, 0)
            end
            if not stumble and not IsEntityPlayingAnim(plyPed, "anim@heists@box_carry@","idle", 49) then
                TaskPlayAnim(plyPed, "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 49, 0, false, false, false)
            end
            Citizen.Wait(0)
        end
    end)
end

function DropPackage()
    SetEntityAsMissionEntity(carryPackage, true, true)
    --DetachEntity(carryPackage, true, true)
    DeleteEntity(carryPackage)
    Wait(10)
    ClearPedTasks(PlayerPedId())
    carryPackage = nil
    isHolding = false
end

function GetCarryingObject()
    return carryPackage
end

exports('GetCarryingObject', GetCarryingObject)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return; end
    if DoesEntityExist(carryPackage) then
        SetEntityAsMissionEntity(carryPackage, true, true)
        DeleteEntity(carryPackage)
        ClearPedTasks(PlayerPedId())
        carryPackage, isHolding = nil, false
    end
end)

BJCore = nil

local isLoggedIn = true
local CurrentWeaponData = {}
local PlayerData = {}
local CanShoot = true

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

-- Citizen.CreateThread(function() 
--     while true do
--         if isLoggedIn then
--             TriggerServerEvent("weapons:server:SaveWeaponAmmo")
--         end
--         Citizen.Wait(60000)
--     end
-- end)

Citizen.CreateThread(function()
    Wait(1000)
    if BJCore.Functions.GetPlayerData() ~= nil then
        TriggerServerEvent("weapons:server:LoadWeaponAmmo")
        isLoggedIn = true
        PlayerData = BJCore.Functions.GetPlayerData()

        BJCore.Functions.TriggerServerCallback("weapons:server:GetConfig", function(RepairPoints)
            for k, data in pairs(RepairPoints) do
                Config.WeaponRepairPoints[k].IsRepairing = data.IsRepairing
                Config.WeaponRepairPoints[k].RepairingData = data.RepairingData
            end
        end)
    end
end)

local MultiplierAmount = 0

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
                if IsPedShooting(PlayerPedId()) or IsControlJustPressed(0, 24) then
                    if CanShoot then
                        local weapon = GetSelectedPedWeapon(PlayerPedId())
                        local ammo = GetAmmoInPedWeapon(PlayerPedId(), weapon)
                        local name = BJCore.Shared.Weapons[weapon]["name"]
                        if name == "weapon_snowball" then
                            TriggerServerEvent('BJCore:Server:RemoveItem', "snowball", 1)
                        elseif IsThrowable(name) and IsPedShooting(PlayerPedId()) then
                            TriggerServerEvent('BJCore:Server:RemoveItem', name, 1)
                        else
                            if ammo > 0 then
                                MultiplierAmount = MultiplierAmount + 1
                            end
                        end
                    else
                        TriggerEvent('inventory:client:CheckWeapon', CurrentWeaponData.name)
                        BJCore.Functions.Notify("This weapon is broken and can no longer be used", "error")
                        MultiplierAmount = 0
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local player = PlayerId()
        local weapon = GetSelectedPedWeapon(ped)
        local ammo = GetAmmoInPedWeapon(ped, weapon)
        local name = BJCore.Shared.Weapons[weapon]["name"]

        if ammo == 1 and not IsThrowable(name) then
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            if IsPedInAnyVehicle(ped, true) then
                SetPlayerCanDoDriveBy(player, false)
            end
        else
            EnableControlAction(0, 24, true) -- Attack
			EnableControlAction(0, 257, true) -- Attack 2
            if IsPedInAnyVehicle(ped, true) and IsThrowable(name) then
                SetPlayerCanDoDriveBy(player, true)
            end
        end

        if IsPedShooting(ped) then
            if ammo - 1 < 1 and not IsThrowable(name) then
                SetAmmoInClip(PlayerPedId(), GetHashKey(name), 1)
            end
        end
        
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while BJCore == nil do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    while true do
        if CurrentWeaponData and (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
            local weapon = GetSelectedPedWeapon(PlayerPedId())
            if GetHashKey(CurrentWeaponData.name) == weapon then
                local ammo = GetAmmoInPedWeapon(PlayerPedId(), weapon)
                if ammo > 0 then
                    TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, tonumber(ammo))
                elseif not IsPedArmed(PlayerPedId(), 1) and CurrentWeaponData.name:lower() ~= 'weapon_stungun' then
                    TriggerEvent('inventory:client:CheckWeapon', CurrentWeaponData.name)
                    TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, 0)
                end

                if MultiplierAmount > 0 then
                    TriggerServerEvent("weapons:server:UpdateWeaponQuality", CurrentWeaponData, MultiplierAmount)
                    MultiplierAmount = 0
                end
            end
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('weapon:client:AddAmmo')
AddEventHandler('weapon:client:AddAmmo', function(type, amount, itemData)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if CurrentWeaponData ~= nil then
        if BJCore.Shared.Weapons[weapon]["name"] ~= "weapon_unarmed" and BJCore.Shared.Weapons[weapon]["ammotype"] == type:upper() then
            local total = (GetAmmoInPedWeapon(PlayerPedId(), weapon))
            --local Skillbar = exports['skillbar']:GetSkillbarObject()
            local retval = GetMaxAmmoInClip(ped, weapon, 1)
            retval = tonumber(retval)
            local newAmmo = total + retval
            if newAmmo > 150 then newAmmo = 150; end

            --if (total + retval) <= (retval + 1) then
                exports['mythic_progbar']:Progress({
                    name = "loading_bullets",
                    duration = math.random(3000, 6000),
                    label = "Reloading",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true,
                    }
                }, function(status)
                    if not status then
                        if BJCore.Shared.Weapons[weapon] ~= nil then
                            SetAmmoInClip(ped, weapon, 0)
                            SetPedAmmo(ped, weapon, newAmmo)
                            TriggerServerEvent("weapons:server:AddWeaponAmmo", CurrentWeaponData, newAmmo)
                            TriggerServerEvent('BJCore:Server:RemoveItem', itemData.name, 1, itemData.slot)
                            TriggerEvent('inventory:client:ItemBox', BJCore.Shared.Items[itemData.name], "remove")
                            TriggerEvent('BJCore:Notify', retval.." bullets added weapon", "success")
                        end
                    else
                        BJCore.Functions.Notify("Canceled", "error")
                    end
                end)
            -- else
            --     BJCore.Functions.Notify("Your weapon is already loaded", "error")
            -- end
        else
            if BJCore.Shared.Weapons[weapon]["name"] == "weapon_unarmed" then
                BJCore.Functions.Notify("You're not holding a weapon", "error")
            else
                BJCore.Functions.Notify("You can't use this ammo type on this weapon", "error")
            end
        end
    else
        BJCore.Functions.Notify("You're not holding a weapon", "error")
    end
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("weapons:server:LoadWeaponAmmo")
    isLoggedIn = true
    PlayerData = BJCore.Functions.GetPlayerData()

    BJCore.Functions.TriggerServerCallback("weapons:server:GetConfig", function(RepairPoints)
        for k, data in pairs(RepairPoints) do
            Config.WeaponRepairPoints[k].IsRepairing = data.IsRepairing
            Config.WeaponRepairPoints[k].RepairingData = data.RepairingData
        end
    end)
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon')
AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
    CanShoot = bool
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false

    for k, v in pairs(Config.WeaponRepairPoints) do
        Config.WeaponRepairPoints[k].IsRepairing = false
        Config.WeaponRepairPoints[k].RepairingData = {}
    end
end)

RegisterNetEvent('weapons:client:SetWeaponQuality')
AddEventHandler('weapons:client:SetWeaponQuality', function(amount)
    if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
        TriggerServerEvent("weapons:server:SetWeaponQuality", CurrentWeaponData, amount)
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         if isLoggedIn then
--             local inRange = false
--             local ped = PlayerPedId()
--             local pos = GetEntityCoords(ped)

--             for k, data in pairs(Config.WeaponRepairPoints) do
--                 local distance = GetDistanceBetweenCoords(pos, data.coords.x, data.coords.y, data.coords.z, true)

--                 if distance < 10 then
--                     inRange = true

--                     if distance < 1 then
--                         if data.IsRepairing then
--                             if data.RepairingData.CitizenId ~= PlayerData.citizenid then
--                                 DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop is this moment  ~r~NOT~w~ useble..')
--                             else
--                                 if not data.RepairingData.Ready then
--                                     DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'Ur weapon wil be repaired')
--                                 else
--                                     DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] to take weapon back')
--                                 end
--                             end
--                         else
--                             if CurrentWeaponData ~= nil and next(CurrentWeaponData) ~= nil then
--                                 if not data.RepairingData.Ready then
--                                     local WeaponData = BJCore.Shared.Weapons[GetHashKey(CurrentWeaponData.name)]
--                                     local WeaponClass = (BJCore.Shared.SplitStr(WeaponData.ammotype, "_")[2]):lower()
--                                     DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] Wapen repareren, ~g~€'..Config.WeaponRepairCotsts[WeaponClass]..'~w~')
--                                     if IsControlJustPressed(0, Keys["E"]) then
--                                         BJCore.Functions.TriggerServerCallback('weapons:server:RepairWeapon', function(HasMoney)
--                                             if HasMoney then
--                                                 CurrentWeaponData = {}
--                                             end
--                                         end, k, CurrentWeaponData)
--                                     end
--                                 else
--                                     if data.RepairingData.CitizenId ~= PlayerData.citizenid then
--                                         DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'The repairshop is this moment ~r~NOT~w~ useble..')
--                                     else
--                                         DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] to take weapon back')
--                                         if IsControlJustPressed(0, Keys["E"]) then
--                                             TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
--                                         end
--                                     end
--                                 end
--                             else
--                                 if data.RepairingData.CitizenId == nil then
--                                     DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, 'You dont have a weapon in ur hands..')
--                                 elseif data.RepairingData.CitizenId == PlayerData.citizenid then
--                                     DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] to take weapon back')
--                                     if IsControlJustPressed(0, Keys["E"]) then
--                                         TriggerServerEvent('weapons:server:TakeBackWeapon', k, data)
--                                     end
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end

--             if not inRange then
--                 Citizen.Wait(1000)
--             end
--         end
--         Citizen.Wait(3)
--     end
-- end)

RegisterNetEvent("weapons:client:SyncRepairShops")
AddEventHandler("weapons:client:SyncRepairShops", function(NewData, key)
    Config.WeaponRepairPoints[key].IsRepairing = NewData.IsRepairing
    Config.WeaponRepairPoints[key].RepairingData = NewData.RepairingData
end)

RegisterNetEvent("weapons:client:EquipAttachment")
AddEventHandler("weapons:client:EquipAttachment", function(ItemData, attachment)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    local WeaponData = BJCore.Shared.Weapons[weapon]
    
    if weapon ~= GetHashKey("WEAPON_UNARMED") then
        WeaponData.name = WeaponData.name:upper()
        if Config.WeaponAttachments[WeaponData.name] ~= nil then
            if Config.WeaponAttachments[WeaponData.name][attachment] ~= nil then
                TriggerServerEvent("weapons:server:EquipAttachment", ItemData, CurrentWeaponData, Config.WeaponAttachments[WeaponData.name][attachment])
            else
                BJCore.Functions.Notify("This weapon does not support this attachment", "error")
            end
        end
    else
        BJCore.Functions.Notify("You dont have a weapon in ur hand..", "error")
    end
end)

RegisterNetEvent("addAttachment")
AddEventHandler("addAttachment", function(component)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    local WeaponData = BJCore.Shared.Weapons[weapon]
    GiveWeaponComponentToPed(ped, GetHashKey(WeaponData.name), GetHashKey(component))
end)

exports('GetAttachment', function(hashName)
	return Config.WeaponAttachments[hashName] and Config.WeaponAttachments[hashName] or {}
end)

function IsThrowable(name)
    return Config.Throwables[name] and Config.Throwables[name] or false
end
exports('IsThrowable', IsThrowable)
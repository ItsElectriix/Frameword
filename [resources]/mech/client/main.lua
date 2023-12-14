local CurrentShop = nil
local CurrentVehicleData = {}
local ShoppingCart = {
    id = "shoppingcart",
    label = "Shopping cart",
    buttons = {},
}
local CartedItem = false
PlayerData = {}

function OpenCustoms(shop, showUpgrades, job)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local repaircosts = nil
    SetVehicleModKit(veh, 0)

    CurrentVehicleData = BJCore.Functions.GetVehicleProperties(veh)
    SetEntityCoords(veh, shop["coords"], 0.0, 0.0, 0.0, false)
    SetEntityHeading(veh, shop["coords"].w)
    FreezeEntityPosition(veh, true)
    TriggerServerEvent('customs:server:UpdateBusyState', CurrentShop, true)
    if showUpgrades then
        BJCore.Functions.TriggerServerCallback('vehicletuning:server:IsMechanicAvailable', function(Mechanic)
            if Mechanic < 1 or Customs.IgnoreMechanicsForRepair then
                if IsVehicleDamaged(veh) or GetVehicleBodyHealth(veh) < 995 or GetVehicleEngineHealth(veh) < 995 then
                    local vehdamage = GetVehicleBodyHealth(veh)
                    repaircosts = math.ceil(1000 - vehdamage)
                    -- local pricemultiplier = vehdamage / 1050
                    -- repaircosts = round(80 + (100 * pricemultiplier), -2)
                end
            end

            SetNuiFocus(true, false)
            SendNUIMessage({
                action = "open",
                mods = GetAvailableMods(true),
                costs = repaircosts,
                currencySymbol = BJCore.Config.Currency.Symbol,
                type = "bennys"
            })
        end)
    else
        BJCore.Functions.TriggerServerCallback('vehicletuning:server:IsMechanicAvailable', function(Mechanic)
            if Mechanic < 1 or Customs.IgnoreMechanicsForRepair then
                if IsVehicleDamaged(veh) or GetVehicleBodyHealth(veh) < 995 or GetVehicleEngineHealth(veh) < 995 then
                    local vehdamage = GetVehicleBodyHealth(veh)
                    repaircosts = math.ceil(1000 - vehdamage)
                    -- local pricemultiplier = vehdamage / 1050
                    -- repaircosts = round(400 + (500 * pricemultiplier), -2)
                end
            end            
            SetNuiFocus(true, false)
            SendNUIMessage({
                action = "open",
                mods = GetAvailableMods(false),
                costs = repaircosts,
                currencySymbol = BJCore.Config.Currency.Symbol,
                type = "lscustom",
            })
        end)
    end
end

RegisterNUICallback('GetFocus', function()
    SetNuiFocus(true, true)
end)

RegisterNUICallback('ReleaseFocus', function()
    SetNuiFocus(true, false)
end)

RegisterNUICallback('CanRepairVehicle', function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local purchased, busy = false, true
    if not Customs.Locations[CurrentShop].job then
        BJCore.Functions.TriggerServerCallback("customs:server:CanPurchase", function(CanBuy)
            purchased = CanBuy
            busy = false
        end, data.price)
    else
        BJCore.Functions.TriggerServerCallback('moneysafe:server:CanPay', function(CanBuy)
            purchased = CanBuy
            busy = false
        end, data.price, 'Mechanic Upgrades')
    end
    while busy do Citizen.Wait(100); end
    if purchased then
        local currFuel = GetVehicleFuelLevel(veh)
        Wait(0)
        SetVehicleFixed(veh)
        Wait(0)
        SetVehicleFuelLevel(veh, currFuel)
        DamageRandomComponent(veh)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
        cb(true)
    else
        BJCore.Functions.Notify('You dont have enough money', 'error')
        cb(false)
    end
end)

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function IsVehicleBlacklisted(veh)
    local retval = false
    for _, vehicle in pairs(Customs.BlacklistedVehicles) do
        if veh == GetHashKey(vehicle) then
            retval = true
            break
        end
    end
    return retval
end

function IsJobAllowed(jobs)
    local ret = false
    for k,v in pairs(jobs) do
        if PlayerData.job.name == v then
            ret = true
            break
        end
    end
    return ret
end

function GetAvailableMods(upgrades)
    local veh = GetVehiclePedIsIn(PlayerPedId())

    if BJCore.Shared.VehicleModels[GetEntityModel(veh)] ~= nil then
        model = BJCore.Shared.VehicleModels[GetEntityModel(veh)].model
        VehicleData = BJCore.Shared.Vehicles[model]
        if VehicleData == nil then 
            VehiclePrice = 5000
        else
            VehiclePrice = VehicleData.price
        end
    else
        VehiclePrice = 50000
    end

    -- SetVehicleModKit(veh, 0)
    local VehicleIsABike = false
    if IsThisModelABike(GetEntityModel(veh)) then
        VehicleIsABike = true
    end
    local mods = {}
    if upgrades then
        for k, v in pairs(Customs.Upgrades) do
            if not v.job or IsJobAllowed(v.job) then
                if v.multiplier ~= nil then
                    for key, btn in pairs(v.buttons) do
                        if key ~= 1 then
                            btn.price = VehiclePrice * v.multiplier
                            btn.increaseby = btn.price / (GetNumVehicleMods(veh, v.id) / 2)
                        else
                            btn.price = 0
                        end
                        btn.price = round(btn.price, -2)
                        btn.increaseby = round(btn.increaseby, -2)
                    end
                end
                table.insert(mods, {
                    label = v.label,
                    id = v.id,
                    buttons = v.buttons,
                })
            end         
        end
    end
    for k, v in pairs(Customs.Mods) do
        if not v.job or IsJobAllowed(v.job) then
            if v.buttons ~= nil and next(v.buttons) ~= nil then
                if v.id ~= 48 then
                    if v.multiplier ~= nil then
                        for key, btn in pairs(v.buttons) do
                            if key ~= 1 then
                                btn.price = VehiclePrice * v.multiplier
                                btn.increaseby = btn.price / (GetNumVehicleMods(veh, v.id) / 2)
                            else
                                btn.price = 0
                            end
                            btn.price = round(btn.price, -2)
                            btn.increaseby = round(btn.increaseby, -2)
                        end
                    end
                    table.insert(mods, {
                        label = v.label,
                        id = v.id,
                        buttons = v.buttons,
                    })
                end
            else
                if v.id == 48 then
                    if GetVehicleLiveryCount(veh) > 0 then
                        local buttons = {}
                        table.insert(buttons, {
                            price = 0,
                            increaseby = 0,
                            name = "Standard",
                            modid = -1,
                            liverytype = "livery",
                            modtype = "liveries",
                        })
                        for i = 0, (GetVehicleLiveryCount(veh) - 1), 1 do
                            table.insert(buttons, {
                                price = v.price,
                                increaseby = v.increaseby,
                                name = "Livery #"..i + 1,
                                modid = i,
                                liverytype = "livery",
                                modtype = "liveries",
                            })
                        end
                        table.insert(mods, {
                            label = v.label,
                            id = v.id,
                            buttons = buttons,
                            modtype = "liveries",
                        })
                    elseif GetNumVehicleMods(veh, 48) > 0 then
                        local buttons = {}
                        table.insert(buttons, {
                            price = 0,
                            increaseby = 0,
                            name = "Standard",
                            modid = -1,
                            liverytype = "mod",
                            modtype = "liveries",
                        })
                        for i = 0, (GetNumVehicleMods(veh, 48) - 1), 1 do
                            table.insert(buttons, {
                                price = v.price,
                                increaseby = v.increaseby,
                                name = "Livery #"..i + 1,
                                modid = i,
                                liverytype = "mod",
                                modtype = "liveries",
                            })
                        end
                        table.insert(mods, {
                            label = v.label,
                            id = v.id,
                            buttons = buttons,
                            modtype = "liveries",
                        })
                    end
                else
                    if not VehicleIsABike then
                        if v.id ~= 23 and v.id ~= 24 then
                            if v.id == "wheels" then
                                local wheeltypes = {}
                                table.insert(wheeltypes, {
                                    price = 0,
                                    increaseby = 0,
                                    name = "Standard Wheel",
                                    modid = -1,
                                    wheeltype = -1
                                })
                                for i = 1, #v.categorys, 1 do
                                    local buttons = {}
                                    if v.categorys[i].label ~= "JDM Rims" then
                                        for w = 1, v.categorys[i].amount, 1 do
                                            table.insert(buttons, {
                                                price = 1200,
                                                increaseby = 0,
                                                name = v.categorys[i].label.." #"..w,
                                                modid = w,
                                                wheeltype = v.categorys[i].wheeltype,
                                                modtype = "wheels",
                                            })
                                        end
                                    else
                                        for c = 50, 108, 1 do
                                            label = (c - 49)
                                            table.insert(buttons, {
                                                price = 1500,
                                                increaseby = 0,
                                                name = v.categorys[i].label.." #"..label,
                                                modid = c,
                                                wheeltype = v.categorys[i].wheeltype,
                                                modtype = "wheels",
                                            })
                                        end
                                    end
                                    table.insert(wheeltypes, {
                                        name = v.categorys[i].label,
                                        buttons = buttons,
                                    })
                                end
                                table.insert(mods, {
                                    label = v.label,
                                    id = v.id,
                                    buttons = {
                                        {
                                            id = "wheels",
                                            name = "Wheel Types",
                                            buttons = wheeltypes,
                                        },
                                        {
                                            id = "wheelcolors",
                                            name = "Wheel Colors",
                                            buttons = Customs.WheelColors,
                                        },
                                        {
                                            id = "wheelaccessories",
                                            name = "Wheel Accessoires",
                                            buttons = Customs.WheelAccessories,
                                        },
                                    },
                                })
                            else
                                --print("mods for id: "..v.id.." #"..tostring(GetNumVehicleMods(veh, v.id)))
                                if v.id == 47 then
                                    local buttons = {}
                                    table.insert(buttons, {
                                        price = 0,
                                        increaseby = 0,
                                        name = "Standard ",
                                        modid = 0,
                                        modtype = v.id,
                                    })
                                    for i = 1, (GetNumVehicleWindowTints()), 1 do
                                        v.price = VehiclePrice * v.multiplier
                                        v.increaseby = 0
                                        v.price = round(v.price, -2)
                                        table.insert(buttons, {
                                            price = v.price,
                                            increaseby = v.increaseby,
                                            name = GetWindowName(i),
                                            modid = i,
                                            modtype = v.id,
                                        })                                                                      
                                    end
                                    table.insert(mods, {
                                        label = v.label,
                                        id = v.id,
                                        buttons = buttons,
                                    })                                                        
                                elseif v.id == 22 then
                                    local buttons = {}
                                    table.insert(buttons, {
                                        price = 0,
                                        increaseby = 0,
                                        name = "Standard ",
                                        modid = 0,
                                        modtype = v.id,
                                    })
                                    table.insert(buttons, {
                                        price = round(VehiclePrice * v.multiplier, -2),
                                        increaseby = 0,
                                        name = v.label,
                                        modid = 1,
                                        modtype = v.id,
                                    })
                                    table.insert(mods, {
                                        label = v.label,
                                        id = v.id,
                                        buttons = buttons,
                                    })
                                elseif v.id == "underglow" then
                                    local buttons = {}
                                    table.insert(buttons, {
                                        price = v.price,
                                        increaseby = 0,
                                        name = "Custom",
                                        customRgbPicker = true,
                                        modOptions = {spraytype = "custom", modtype = "underglow", name = "Custom Color", modid = nil, price = v.price},
                                        modid = nil,
                                        modtype = v.id,
                                        buttons = {}
                                    })
                                    table.insert(mods, {
                                        label = v.label,
                                        id = v.id,
                                        buttons = buttons,
                                    })
                                elseif v.id == "headlightcolor" and IsToggleModOn(veh, 22) then
                                    local buttons = {}
                                    table.insert(buttons, {
                                        price = 0,
                                        increaseby = 0,
                                        name = "Deafult ",
                                        modid = -1,
                                        modtype = v.id,
                                    })
                                    for i = 0, 12, 1 do
                                        table.insert(buttons, {
                                            price = v.price,
                                            increaseby = v.increaseby,
                                            name = GetHeadLightColour(i),
                                            modid = i,
                                            modtype = v.id,
                                        })
                                    end
                                    table.insert(mods, {
                                        label = v.label,
                                        id = v.id,
                                        buttons = buttons,
                                    })
                                elseif GetNumVehicleMods(veh, v.id) > 0 then
                                    local buttons = {}
                                    table.insert(buttons, {
                                        price = 0,
                                        increaseby = 0,
                                        name = "Standard "..v.label,
                                        modid = -1,
                                        modtype = v.id,
                                    })
                                    for i = 0, (GetNumVehicleMods(veh, v.id) - 1), 1 do
                                        if v.multiplier ~= nil then
                                            v.price = VehiclePrice * v.multiplier
                                            v.increaseby = v.price / GetNumVehicleMods(veh, v.id)
                                            v.price = round(v.price, -2)
                                            v.increaseby = round(v.increaseby, -2)
                                        else
                                            v.price = v.price ~= nil and v.price or 500
                                            v.increaseby = v.increaseby ~= nil and v.increaseby or 500
                                        end
                                        table.insert(buttons, {
                                            price = v.price,
                                            increaseby = v.increaseby,
                                            name = v.label.." #"..i + 1,
                                            modid = i,
                                            modtype = v.id,
                                        })
                                    end
                                    table.insert(mods, {
                                        label = v.label,
                                        id = v.id,
                                        buttons = buttons,
                                    })
                                end
                            end
                        end
                    else
                        if v.id ~= "wheels" then
                            if GetNumVehicleMods(veh, v.id) > 0 then
                                local buttons = {}
                                table.insert(buttons, {
                                    price = 0,
                                    increaseby = 0,
                                    name = "Standard "..v.label,
                                    modid = -1,
                                    modtype = v.modtype,
                                })
                                for i = 1, GetNumVehicleMods(veh, v.id), 1 do
                                    v.price = v.price ~= nil and v.price or 800
                                    v.increaseby = v.increaseby ~= nil and v.increaseby or 0
                                    table.insert(buttons, {
                                        price = v.price,
                                        increaseby = v.increaseby,
                                        name = v.label.." #"..i,
                                        modid = i-1,
                                        modtype = v.modtype,
                                    })
                                end
                                table.insert(mods, {
                                    label = v.label,
                                    id = v.id,
                                    buttons = buttons,
                                    modtype = v.modtype,
                                })
                            end
                        elseif v.id == "wheels" then
                            table.insert(mods, {
                                label = "Wheel",
                                id = "wheels",
                                buttons = {
                                    {
                                        id = "wheelcolors",
                                        name = "Wheel Colors",
                                        buttons = Customs.WheelColors,
                                    },
                                    {
                                        id = "wheelaccessories",
                                        name = "Wheel Accessoires",
                                        buttons = Customs.WheelAccessories,
                                    },
                                },
                            })
                        end
                    end
                end
            end
        end
    end
    
    table.sort(mods, function(a, b)
		return a.label < b.label
	end)

    return mods
end

function GetWindowName(index)
    if (index == 1) then
        return "Pure Black"
    elseif (index == 2) then
        return "Darksmoke"
    elseif (index == 3) then
        return "Lightsmoke"
    elseif (index == 4) then
        return "Limo"
    elseif (index == 5) then
        return "Green"
    else
        return "Unknown"
    end
end

function GetHeadLightColour(index)
    if (index == -1) then
        return "Default"
    elseif (index == 0) then
        return "White"
    elseif (index == 1) then
        return "Blue"
    elseif (index == 2) then
        return "Electric Blue"
    elseif (index == 3) then
        return "Mint Green"
    elseif (index == 4) then
        return "Lime Green"
    elseif (index == 5) then
        return "Yellow"
    elseif (index == 6) then
        return "Golden Shower"
    elseif (index == 7) then
        return "Orange"
    elseif (index == 8) then
        return "Red"
    elseif (index == 9) then
        return "Pony Pink"
    elseif (index == 10) then
        return "Hot Pink"
    elseif (index == 11) then
        return "Purple"
    elseif (index == 12) then
        return "Blacklight"
    else
        return "Unknown"
    end
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false

        for k, loc in pairs(Customs.Locations) do
            local dist = #(pos - loc["coords"].xyz)
            if dist < 20 then
                inRange = true
                if dist < 10 then
                    if not loc["busy"] then
                        if IsPedInAnyVehicle(ped) then
                            local veh = GetVehiclePedIsIn(ped)
                            local seat = GetPedInVehicleSeat(veh, -1)
                            if seat == ped then
                                if not IsVehicleBlacklisted(GetEntityModel(GetVehiclePedIsIn(ped))) then
                                    local allow = false
                                    if loc.job then
                                        if (PlayerJob.name == loc.job and onDuty) then; allow = true; end
                                    else allow = true; end
                                    if allow then
                                        DrawMarker(22, loc["coords"].x, loc["coords"].y, loc["coords"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 1.0, 45, 91, 227, 100, true, true, 2, false, false, false, false)
                                        if dist < 3 then
                                            local name = "LS Customs"
                                            if loc.upgrades then name = "Benny's"; end
                                            BJCore.Functions.DrawText3D(loc["coords"].x, loc["coords"].y, loc["coords"].z, '[~g~E~w~] '..name, 0.7)
                                            
                                            if IsControlJustPressed(0, 38) then -- ENTER
                                                CurrentShop = k
                                                OpenCustoms(loc, loc.upgrades, loc.job)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

function OnIndexChange(id, data)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if data.modid ~= nil and id ~= nil then
        if id == "respray" then
            if data.modid ~= nil then
                if data.colortype == "primary" then
                    local CartedSecondary = GetCartedColor("secondary")
                    if data.spraytype == 'custom' then
                        SetVehicleCustomPrimaryColour(veh, data.modid.r, data.modid.g, data.modid.b)
                    else
                        ClearVehicleCustomPrimaryColour(veh)
                        local secondaryColour = CurrentVehicleData.color2
                        if CartedSecondary ~= nil then
                            secondaryColour = CartedSecondary
                        end
                        if type(secondaryColour) == 'table' then
                            SetVehicleColours(veh, data.modid, 1)
                        else
                            SetVehicleColours(veh, data.modid, secondaryColour)
                        end
                    end
                elseif data.colortype == "secondary" then
                    local CartedPrimary = GetCartedColor("primary")
                    if data.spraytype == 'custom' then
                        SetVehicleCustomSecondaryColour(veh, data.modid.r, data.modid.g, data.modid.b)
                    else
                        ClearVehicleCustomSecondaryColour(veh)
                        local primaryColour = CurrentVehicleData.color1
                        if CartedPrimary ~= nil then
                            primaryColour = CartedPrimary
                        end
                        if type(primaryColour) == 'table' then
                            SetVehicleColours(veh, 1, data.modid)
                        else
                            SetVehicleColours(veh, primaryColour, data.modid)
                        end
                    end
                else
                    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                    SetVehicleExtraColours(veh, data.modid, wheelColor)
                end
            end
        elseif id == "wheelcolors" then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
            SetVehicleExtraColours(veh, pearlescentColor, data.modid)
        elseif id == "wheelaccessories" then
            if data.smokecolor ~= nil then
                ToggleVehicleMod(veh, 20, true)
                SetVehicleTyreSmokeColor(veh, data.smokecolor[1], data.smokecolor[2], data.smokecolor[3])
            end
        elseif id == 47 then
            SetVehicleWindowTint(veh, tonumber(data.modid))
        elseif id == 48 then
            if data.modid ~= -1 then
                data.modid = tonumber(data.modid)
                if data.liverytype == "mod" then
                    SetVehicleMod(veh, 48, data.modid, false)
                elseif data.liverytype == "livery" then
                    SetVehicleLivery(veh, data.modid)
                end
            end
        elseif id == 18 or id == 20 or id == 22 then
            if data.modid == 0 then
                ToggleVehicleMod(veh, id, false)
            else
                ToggleVehicleMod(veh, id, true)
            end
        elseif id == "wheels" then
            if data.wheeltype ~= nil then
                SetVehicleWheelType(veh, data.wheeltype)
                SetVehicleMod(veh, 23, data.modid)
            end
        elseif id == "underglow" then
            if data.modid ~= nil then
                for i=1,4,1 do
                    if not IsVehicleNeonLightEnabled(veh, i-1) then
                        SetVehicleNeonLightEnabled(veh, i-1, true)
                    end
                end
                SetVehicleNeonLightsColour(veh, data.modid.r, data.modid.g, data.modid.b)
            end
        elseif id == "headlightcolor" then
            if data.modid ~= nil then
                SetVehicleXenonLightsColor(veh, data.modid)
            end
        else
            if data.modid ~= nil and id ~= nil then
                SetVehicleMod(veh, id, data.modid, false)
            end
        end
    end
end

-- NUI Callback's

RegisterNUICallback('CloseMenu', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    FreezeEntityPosition(veh, false)

    SetNuiFocus(false, false)
    TriggerServerEvent('customs:server:UpdateBusyState', CurrentShop, false)
    ShoppingCart.buttons = {}
    BJCore.Functions.SetVehicleProperties(veh, CurrentVehicleData)
    CurrentShop = nil
end)

RegisterNUICallback('print', function(data, cb)
    -- TriggerServerEvent('customs:print', data.print)
end)

RegisterNUICallback('OnIndexChange', function(data, cb)
    if data.cart == nil then
        if data.id ~= nil then
            OnIndexChange(data.id, data.data)
        end
    end

    if not data.data.spraytype or data.data.spraytype ~= 'custom' then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end)

RegisterNUICallback('SelectSound', function()
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)
RegisterNUICallback('BackSound', function()
    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)
RegisterNUICallback('QuitSound', function()
    PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

-- Events

RegisterNetEvent('customs:client:UpdateBusyState')
AddEventHandler('customs:client:UpdateBusyState', function(k, bool)
    Customs.Locations[k]["busy"] = bool
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('GetCurrentMod', function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local currentmod = -1

    if data.data ~= nil and next(data.data) ~= nil then
        if data.data.id ~= nil then
            if data.data.id ~= "respray" and data.data.id ~= "wheels" and data.data.id ~= "wheelcolors" and data.data.id ~= "wheelaccessories" and data.data.id ~= "underglow" and data.data.id ~= "headlightcolor" then
                if data.data.id >= 0 and data.data.id <= 47 then
                    if data.data.id == 18 or data.data.id == 20 or data.data.id == 22 then
                        if not CurrentVehicleData[Customs.indexToName[data.data.id]] then
                            currentmod = -1
                        else
                            currentmod = 0
                        end
                    elseif data.data.id == 47 then
                        if CurrentVehicleData[Customs.indexToName[data.data.id]] == -1 then
                            currentmod = -1
                        else
                            currentmod = CurrentVehicleData[Customs.indexToName[data.data.id]] - 1
                        end
                    else
                        currentmod = CurrentVehicleData[Customs.indexToName[data.data.id]]
                    end
                end
            elseif data.data.id == "respray" then
                if data.data.customRgbPicker then
                    if data.data.modOptions.colortype == "primary" and type(CurrentVehicleData.color1) == 'table' then
                        currentmod = CurrentVehicleData.color1
                    end
                    if data.data.modOptions.colortype == "secondary" and type(CurrentVehicleData.color2) == 'table' then
                        currentmod = CurrentVehicleData.color2
                    end
                end
                if data.data.buttons ~= nil then
                    for k, v in pairs(data.data.buttons) do
                        if v.colortype == "primary" then
                            if v.modid == CurrentVehicleData.color1 then
                                currentmod = (k - 2)
                                break
                            end
                        elseif v.colortype == "secondary" then
                            if v.modid == CurrentVehicleData.color2 then
                                currentmod = (k - 2)
                                break
                            end
                        elseif v.colortype == "pearlescent" then
                            if v.modid == CurrentVehicleData.pearlescentColor then
                                currentmod = (k - 2)
                                break
                            end
                        end
                    end
                end
            elseif data.data.id == "wheels" then
                if data.data.buttons ~= nil and next(data.data.buttons) ~= nil then
                    for k, v in pairs(data.data.buttons) do
                        if v.wheeltype == CurrentVehicleData.wheels and v.modid == CurrentVehicleData.modFrontWheels then
                            currentmod = (k - 2)
                            break
                        end
                    end
                end
            elseif data.data.id == "wheelcolors" then
                local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                for k, v in pairs(Customs.WheelColors) do
                    if v.modid == wheelColor then
                        currentmod = (k - 2)
                        break
                    end
                end
            elseif data.data.id == "wheelaccessories" then
                local current = GetTyreSmokeKey()
                currentmod = (current - 2)
            elseif data.data.id == "underglow" then
                currentmod = CurrentVehicleData.neonColor
            elseif data.data.id == "headlightcolor" then
                currentmod = CurrentVehicleData.xenonColor
            end
        end
    end
    cb(currentmod)
end)

RegisterNUICallback('AddItemToCart', function(data, cb)
    if ShoppingCart.buttons ~= nil and next(ShoppingCart.buttons) ~= nil then
        for k, v in pairs(ShoppingCart.buttons) do
            if v.modtype ~= "respray" then
                if v.modtype == data.ItemData.modtype then
                    table.remove(ShoppingCart.buttons, k)
                end
            else
                if v.colortype == data.ItemData.colortype then
                    table.remove(ShoppingCart.buttons, k)
                end
            end
        end
    end
    if data.ItemData.originalprice ~= nil then
        data.ItemData.price = data.ItemData.originalprice
    end
    table.insert(ShoppingCart.buttons, data.ItemData)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
    CartedItem = true
end)

RegisterNUICallback('ToggleCartedItem', function(data, cb)
    CartedItem = data.toggle
end)

function GetCartedColor(type)
    local retval = nil
    for k, v in pairs(ShoppingCart.buttons) do
        if v.colortype == type then
            retval = v
        end
    end
    return retval
end

RegisterNUICallback('CheckIfCartedItem', function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    BJCore.Functions.SetVehicleProperties(veh, CurrentVehicleData)
    if ShoppingCart.buttons ~= nil and next(ShoppingCart.buttons) ~= nil then
        for k, v in pairs(ShoppingCart.buttons) do
            if v.modtype ~= nil then
                if v.modtype ~= "respray" and v.modtype ~= "wheels" and v.modtype ~= "wheelcolor" and v.modtype ~= "wheelaccessories" and v.modtype ~= "frontwheels" and v.modtype ~= "backwheels" and v.modtype ~= "liveries" and v.modtype ~= "underglow" and v.modtype ~= "headlightcolor" then
                    if v.modid == 18 or v.modid == 22 then
                        if data.modid == 0 then
                            ToggleVehicleMod(veh, v.modid, false)
                        else
                            ToggleVehicleMod(veh, v.modid, true)
                        end
                    elseif v.modtype == 47 then
                        SetVehicleWindowTint(veh, v.modid)
                    else
                        SetVehicleMod(veh, v.modtype, v.modid, false)
                    end
                elseif v.modtype == "respray" then
                    if v.colortype == "primary" then
                        local CartedSecondary = GetCartedColor("secondary")
                        if type(v.modid) == 'table' then
                            SetVehicleCustomPrimaryColour(veh, v.modid.r, v.modid.g, v.modid.b)
                        else
                            ClearVehicleCustomPrimaryColour(veh)
                            local secondaryColour = CurrentVehicleData.color2
                            if CartedSecondary ~= nil then
                                secondaryColour = CartedSecondary
                            end
                            if type(secondaryColour) == 'table' then
                                SetVehicleColours(veh, v.modid, 1)
                            else
                                SetVehicleColours(veh, v.modid, secondaryColour)
                            end
                        end
                    elseif v.colortype == "secondary" then
                        local CartedSecondary = GetCartedColor("primary")
                        if type(v.modid) == 'table' then
                            SetVehicleCustomSecondaryColour(veh, v.modid.r, v.modid.g, v.modid.b)
                        else
                            ClearVehicleCustomSecondaryColour(veh)
                            local primaryColour = CurrentVehicleData.color1
                            if CartedPrimary ~= nil then
                                primaryColour = CartedPrimary
                            end
                            if type(primaryColour) == 'table' then
                                SetVehicleColours(veh, 1, v.modid)
                            else
                                SetVehicleColours(veh, primaryColour, v.modid)
                            end
                        end
                    else
                        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                        SetVehicleExtraColours(veh, v.modid, wheelColor)
                    end
                elseif v.modtype == "wheels" then
                    if v.wheeltype ~= nil then
                        SetVehicleWheelType(veh, v.wheeltype)
                        SetVehicleMod(veh, 23, v.modid)
                    end
                elseif v.modtype == "liveries" then
                    if v.modid ~= -1 then
                        if v.liverytype == "mod" then
                            SetVehicleMod(veh, 48, v.modid, false)
                        elseif v.liverytype == "livery" then
                            SetVehicleLivery(veh, v.modid)
                        end
                    end
                elseif v.modtype == "frontwheels" then
                    SetVehicleWheelType(veh, 6)
                    SetVehicleMod(veh, 23, v.modid)
                elseif v.modtype == "backwheels" then
                    SetVehicleWheelType(veh, 6)
                    SetVehicleMod(veh, 24, v.modid)
                elseif v.modtype == "wheelcolor" then
                    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                    SetVehicleExtraColours(veh, pearlescentColor, v.modid)
                elseif v.modtype == "wheelaccessories" then
                    if v.tireid ~= 0 then
                        ToggleVehicleMod(veh, v.modid, true)
                        SetVehicleTyreSmokeColor(veh, v.smokecolor[1], v.smokecolor[2], v.smokecolor[3])
                    else
                        ToggleVehicleMod(veh, v.modid, false)
                    end
                elseif v.modtype == "underglow" then
                    if v.modid ~= nil then
                        for i=1,4,1 do
                            if not IsVehicleNeonLightEnabled(veh, i-1) then
                                SetVehicleNeonLightEnabled(veh, i-1, true)
                            end
                        end
                        SetVehicleNeonLightsColour(veh, v.modid.r, v.modid.g, v.modid.b)
                    else
                        SetVehicleNeonLightsColour(veh, 255, 255, 255)
                    end
                elseif v.modtype == "headlightcolor" then
                    if v.modid ~= nil then
                        SetVehicleXenonLightsColor(veh, v.modid)
                    else
                        SetVehicleXenonLightsColor(veh, -1)
                    end
                end
            elseif v.id ~= nil then
                SetVehicleMod(veh, v.id, v.modid, false)
            end
        end
    end
end)

RegisterNUICallback('RemoveCartItem', function(data, cb)
    for k, v in pairs(ShoppingCart.buttons) do
        if v.modtype ~= "wheels" and v.modtype ~= "respray" then
            if v.modtype == data.ItemData.modtype and v.modid == data.ItemData.modid then
                table.remove(ShoppingCart.buttons, k)
            end
        elseif v.modtype == "respray" then
            if v.colortype == data.ItemData.colortype and v.modid == data.ItemData.modid then
                table.remove(ShoppingCart.buttons, k)
            end
        elseif v.modtype == "wheels" then
            table.remove(ShoppingCart.buttons, k)
        end
    end

    CartedItem = false
end)

RegisterNUICallback('GetShoppingCart', function(data, cb)
    cb(ShoppingCart)
end)

function CalculatePrice()
    local totalprice = 0
    for k, v in pairs(ShoppingCart.buttons) do
        totalprice = totalprice + v.price
    end
    return totalprice
end

RegisterNUICallback('PurchaseUpgrades', function(data, cb)

    local TotalPrice = CalculatePrice()
    local String = ""
    local purchased, busy = false, true
    if not Customs.Locations[CurrentShop].job then
        BJCore.Functions.TriggerServerCallback("customs:server:CanPurchase", function(CanBuy)
            purchased = CanBuy
            busy = false
        end, TotalPrice)
    else
        BJCore.Functions.TriggerServerCallback('moneysafe:server:CanPay', function(CanBuy)
            purchased = CanBuy
            busy = false
        end, TotalPrice, 'Mechanic Upgrades')
    end
    while busy do Citizen.Wait(100); end
    if purchased then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped)

        FreezeEntityPosition(veh, false)

        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)

        TriggerServerEvent('customs:server:UpdateBusyState', CurrentShop, false)
        BJCore.Functions.SetVehicleProperties(veh, CurrentVehicleData)
        if ShoppingCart.buttons ~= nil and next(ShoppingCart.buttons) ~= nil then
            for k, v in pairs(ShoppingCart.buttons) do
                String = String .. "\n #" .. k .. " Upgrade: **" .. v.name .. "** Price: **"..BJCore.Config.Currency.Symbol .. v.originalprice .. "**" 
                if v.modtype ~= nil then
                    if v.modtype ~= "respray" and v.modtype ~= "wheels" and v.modtype ~= "wheelcolor" and v.modtype ~= "wheelaccessories" and v.modtype ~= "frontwheels" and v.modtype ~= "backwheels" and v.modtype ~= "liveries" and v.modtype ~= "underglow" and v.modtype ~= "headlightcolor" then
                        if v.modtype == 18 or v.modtype == 22 then
                            if v.modid == 0 then
                                ToggleVehicleMod(veh, v.modtype, false)
                            else
                                ToggleVehicleMod(veh, v.modtype, true)
                            end
                        elseif v.modtype == 47 then
                            SetVehicleWindowTint(veh, v.modid)                                
                        else
                            SetVehicleMod(veh, v.modtype, v.modid, false)
                        end
                    elseif v.modtype == "respray" then
                        if v.colortype == "primary" then
                            local CartedSecondary = GetCartedColor("secondary")
                            if type(v.modid) == 'table' then
                                SetVehicleCustomPrimaryColour(veh, v.modid.r, v.modid.g, v.modid.b)
                            else
                                ClearVehicleCustomPrimaryColour(veh)
                                local secondaryColour = CurrentVehicleData.color2
                                if CartedSecondary ~= nil then
                                    secondaryColour = CartedSecondary
                                end
                                if type(secondaryColour) == 'table' then
                                    SetVehicleColours(veh, v.modid, 1)
                                else
                                    SetVehicleColours(veh, v.modid, secondaryColour)
                                end
                            end
                        elseif v.colortype == "secondary" then
                            local CartedSecondary = GetCartedColor("primary")
                            if type(v.modid) == 'table' then
                                SetVehicleCustomSecondaryColour(veh, v.modid.r, v.modid.g, v.modid.b)
                            else
                                ClearVehicleCustomSecondaryColour(veh)
                                local primaryColour = CurrentVehicleData.color1
                                if CartedPrimary ~= nil then
                                    primaryColour = CartedPrimary
                                end
                                if type(primaryColour) == 'table' then
                                    SetVehicleColours(veh, 1, v.modid)
                                else
                                    SetVehicleColours(veh, primaryColour, v.modid)
                                end
                            end
                        else
                            local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                            SetVehicleExtraColours(veh, v.modid, wheelColor)
                        end
                    elseif v.modtype == "wheels" then
                        if v.wheeltype ~= nil then
                            SetVehicleWheelType(veh, v.wheeltype)
                            SetVehicleMod(veh, 23, v.modid)
                        end
                    elseif v.modtype == "liveries" then
                        if v.modid ~= -1 then
                            if v.liverytype == "mod" then
                                SetVehicleMod(veh, 48, v.modid, false)
                            elseif v.liverytype == "livery" then
                                SetVehicleLivery(veh, v.modid)
                            end
                        end
                    elseif v.modtype == "frontwheels" then
                        SetVehicleWheelType(veh, 6)
                        SetVehicleMod(veh, 23, v.modid)
                    elseif v.modtype == "backwheels" then
                        SetVehicleWheelType(veh, 6)
                        SetVehicleMod(veh, 24, v.modid)
                    elseif v.modtype == "wheelcolor" then
                        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
                        SetVehicleExtraColours(veh, pearlescentColor, v.modid)
                    elseif v.modtype == "wheelaccessories" then
                        if v.tireid ~= 0 then
                            ToggleVehicleMod(veh, v.modid, true)
                            SetVehicleTyreSmokeColor(veh, v.smokecolor[1], v.smokecolor[2], v.smokecolor[3])
                        else
                            ToggleVehicleMod(veh, v.modid, false)
                        end
                    elseif v.modtype == "underglow" then
                        if v.modid ~= nil then
                            for i=1,4,1 do
                                if not IsVehicleNeonLightEnabled(veh, i-1) then
                                    SetVehicleNeonLightEnabled(veh, i-1, true)
                                end
                            end
                            SetVehicleNeonLightsColour(veh, v.modid.r, v.modid.g, v.modid.b)
                        else
                            SetVehicleNeonLightsColour(veh, 255, 255, 255)
                        end
                    elseif v.modtype == "headlightcolor" then
                        if v.modid ~= nil then
                            SetVehicleXenonLightsColor(veh, v.modid)
                        else
                            SetVehicleXenonLightsColor(veh, -1)
                        end
                    end
                elseif v.id ~= nil then
                    SetVehicleMod(veh, v.id, v.modid, false)
                end
            end
            PlayerData = BJCore.Functions.GetPlayerData()
            TriggerServerEvent("bj-log:server:sendLog", PlayerData.citizenid, "buy", {upgrades = String, citizenid = PlayerData.citizenid})
            TriggerServerEvent("bj-log:server:CreateLog", "mechanic", "Purchase", "green", "**" .. PlayerData.name .. "** (citizenid: *" .. PlayerData.citizenid .. "* | id: *(" .. PlayerData.source .. ")* has paid **"..BJCore.Config.Currency.Symbol .. TotalPrice .. "** for the following upgrade\'s: \n" .. String.. " | Plate: "..GetVehicleNumberPlateText(veh))
        end

        CurrentShop = nil
        ShoppingCart.buttons = {}

        CurrentVehicleData = BJCore.Functions.GetVehicleProperties(veh)
        TriggerServerEvent('customs:server:SaveVehicleProps', CurrentVehicleData)
    else
        BJCore.Functions.Notify('You dont have enough money', 'error')
    end
end)

function GetTyreSmokeKey()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local cur = table.pack(GetVehicleTyreSmokeColor(veh))
    local retval = -1

    for k, v in pairs(Customs.WheelAccessories) do
        if v.smokecolor[1] == cur[1] and v.smokecolor[2] == cur[2] and v.smokecolor[3] == cur[3] then
            retval = k
            break
        end
    end
    return retval
end

RegisterNUICallback('GetCartItem', function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local retval = -1

    if data.data ~= nil then
        if ShoppingCart.buttons ~= nil and next(ShoppingCart.buttons) ~= nil then
            for k, v in pairs(ShoppingCart.buttons) do
                if v.modtype ~= "respray" and v.modtype ~= "wheels" and v.modtype ~= "wheelaccessories" and v.modtype ~= "wheelcolor" and v.modtype ~= "underglow" then
                    for _, mod in pairs(data.data) do
                        if v.modtype ~= 18 then
                            if v.modtype == mod.modtype and v.modid == mod.modid then
                                retval = v.modid
                                break
                            end
                        else
                            if v.modid == mod.modid then
                                retval = 0
                                break
                            end
                        end
                    end
                elseif v.modtype == "respray" then
                    for k, mod in pairs(data.data) do
                        if v.modid == mod.modid and v.colortype == mod.colortype and v.spraytype == mod.spraytype then
                            retval = (k - 2)
                            break
                        end
                    end
                elseif v.modtype == "wheels" then
                    for k, mod in pairs(data.data) do
                        if v.modid == mod.modid and v.wheeltype == mod.wheeltype then
                            retval = (k - 2)
                            break
                        end
                    end
                elseif v.modtype == "wheelcolor" then
                    for k, mod in pairs(data.data) do
                        for _, color in pairs(Customs.WheelColors) do
                            if mod.modid == color.modid then
                                retval = (k - 2)
                                break
                            end
                        end
                    end
                elseif v.modtype == "wheelaccessories" then
                    for _, mod in pairs(data.data) do
                        if mod.smokecolor ~= nil then
                            if mod.smokecolor[1] == v.smokecolor[1] and mod.smokecolor[2] == v.smokecolor[2] and mod.smokecolor[2] == v.smokecolor[2] then
                                retval = (mod.tireid - 2)
                                break
                            end
                        end
                    end
                elseif v.modtype == "underglow" then
                    for k, mod in pairs(data.data) do
                        if v.modid == mod.modid and v.spraytype == mod.spraytype then
                            retval = (k - 2)
                            break
                        end
                    end
                end
            end
        end
    end
    cb(retval)
end)

RegisterNetEvent("BJCore:Player:SetPlayerData")
AddEventHandler("BJCore:Player:SetPlayerData", function(data)
    PlayerData = data
end)

RegisterNetEvent('BJCore:Player:UpdateClientInventoryCache')
AddEventHandler('BJCore:Player:UpdateClientInventoryCache', function(itemCache)
    if PlayerData then
        PlayerData.items = itemCache
    end
end)
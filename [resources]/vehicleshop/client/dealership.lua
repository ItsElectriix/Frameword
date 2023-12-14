local ClosestVehicle = -1
local modelLoaded = true
CurVehShop = false

local fakecar = {model = '', car = nil}

vehshop = {
	opened = false,
	title = "Vehicle Shop",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 0,
	marker = { r = 0, g = 155, b = 255, a = 250, type = 1 },
	menu = {
		x = 0.14,
		y = 0.15,
		width = 0.12,
		height = 0.03,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.29,
		font = 0,
	}
}

function menuTemplate(menu)
    local tab = {}
    if menu == "main" then
        tab = {
            title = "CATEGORIES",
            name = "main",
            buttons = {
                {name = "Vehicle", description = ""},
            }
        }
    elseif menu == "cats" then
        tab = {
            title = "VEHICLES",
            name = "vehicles",
            buttons = {}
        }  
    end
    return tab
end

function setUpCats()
    Citizen.CreateThread(function()
        for shop,data in pairs(vehShopCats) do
            vehshop.menu[shop] = menuTemplate("main")
            vehshop.menu[shop].buttons[1].name = Config.VehicleShops[shop].label
            vehshop.menu[shop.."-cats"] = menuTemplate("cats")
            for k,v in pairs(data) do
                if next(v.vehicles) ~= nil then
                    table.insert(vehshop.menu[shop.."-cats"].buttons, {
                        menu = shop.."-"..k,
                        name = v.label,
                        description = {}
                    })

                    vehshop.menu[shop.."-"..k] = {
                        title = k,
                        name = v.label,
                        buttons = v.vehicles
                    }
                end
            end
        end
    end)
end

function isValidMenu(menu)
    local retval = false
    for shop,_ in pairs(vehShopCats) do
        for k, v in pairs(vehshop.menu[shop.."-cats"].buttons) do
            if menu == v.menu then
                retval = true
            end
        end
    end
    return retval
end

function drawMenuButton(button,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)
	if selected then
		DrawRect(x,y,menu.width,menu.height,255,255,255,255)
	else
		DrawRect(x,y,menu.width,menu.height,0, 0, 0,220)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function drawMenuInfo(text)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawRect(0.675, 0.95,0.65,0.050,0,0,0,250)
	DrawText(0.255, 0.254)
end

function drawMenuRight(txt,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.2, 0.2)
	--SetTextRightJustify(1)
	if selected then
		SetTextColour(0,0,0, 255)
	else
		SetTextColour(255, 255, 255, 255)
		
	end
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu.width/2 + 0.025, y - menu.height/3 + 0.0002)

	if selected then
		DrawRect(x + menu.width/2 + 0.025, y,menu.width / 3,menu.height,255, 255, 255,250)
	else
		DrawRect(x + menu.width/2 + 0.025, y,menu.width / 3,menu.height,0, 0, 0,250)
	end
end

function drawMenuTitle(txt,x,y)
	local menu = vehshop.menu
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)

	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawRect(x,y,menu.width,menu.height,0,0,0,250)
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1; end
    return count
end

function ButtonSelected(button)
    local this = vehshop.currentmenu
    local btn = button.name

    if this == "main" then
        if btn == "Vehicle" then
            OpenMenu('vehicles')
        end
    elseif IsDelearship(this) then
            OpenMenu(CurVehShop.key.."-cats")
    elseif this == CurVehShop.key.."-cats" then
        if CatButton(btn) then
            OpenMenu(CurVehShop.key..'-'..CatButton(btn))
        end
    end
end

function CatButton(btn)
    local ret = false
    for k,v in pairs(vehCatTemplate()) do
        if v.label == btn then
            ret = k
            break
        end
    end
    return ret
end

function IsDelearship(index)
    local ret = false
    for k,v in pairs(Config.VehicleShops) do
        if index == k then
            ret = true
            break
        end
    end
    return ret
end
exports("IsDelearship", IsDelearship)

function OpenMenu(openMenu)
    vehshop.lastmenu = vehshop.currentmenu
    fakecar = {model = '', car = nil}
	if openMenu == CurVehShop.key.."-cats" then
		vehshop.lastmenu = CurVehShop.key
	end
	vehshop.menu.from = 1
	vehshop.menu.to = 10
	vehshop.selectedbutton = 1
	vehshop.currentmenu = openMenu
end

function Back()
	if IsDelearship(vehshop.currentmenu) then
		CloseCreator()
	elseif isValidMenu(vehshop.currentmenu) then
		if DoesEntityExist(fakecar.car) then
			BJCore.Functions.DeleteVehicle(fakecar.car)
		end
		fakecar = {model = '', car = nil}
		OpenMenu(vehshop.lastmenu)
	else
		OpenMenu(vehshop.lastmenu)
	end
end

function CloseCreator()
    TriggerEvent('police:client:pauseKeybind', false)
	Citizen.CreateThread(function()
		vehshop.opened = false
		vehshop.menu.from = 1
        vehshop.menu.to = 10
        if ClosestVehicle ~= nil then
            Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse = false
            TriggerServerEvent('vehicleshop:server:setShowroomCarInUse', CurVehShop.key, ClosestVehicle, false)
        else
            TriggerServerEvent('vehicleshop:server:setSalePointInUse', CurVehShop.key, curSalePoint, false)
        end
	end)
end

local spawnedShowroom = {}
function showroomVehicleCreation()
    Citizen.CreateThread(function()
        while CurVehShop do
            local dist = #(GetEntityCoords(PlayerPedId())-CurVehShop.val.pos)
            if dist <= 50 then
                for i = 1, #Config.ShowroomVehicles[CurVehShop.key], 1 do
                    if not spawnedShowroom[i] then
                        local oldVehicle = GetClosestVeh(Config.ShowroomVehicles[CurVehShop.key][i].coords.xyz, 0.5)
                        if oldVehicle ~= 0 then
                            BJCore.Functions.DeleteVehicle(oldVehicle)
                        end

                        local model = GetHashKey(Config.ShowroomVehicles[CurVehShop.key][i].chosenVehicle)
                        RequestModel(model)
                        while not HasModelLoaded(model) do Citizen.Wait(0); end

                        local veh = CreateVehicle(model, Config.ShowroomVehicles[CurVehShop.key][i].coords.x, Config.ShowroomVehicles[CurVehShop.key][i].coords.y, Config.ShowroomVehicles[CurVehShop.key][i].coords.z, false, false)
                        SetModelAsNoLongerNeeded(model)
                        SetVehicleOnGroundProperly(veh)
                        SetEntityInvincible(veh,true)
                        SetEntityHeading(veh, Config.ShowroomVehicles[CurVehShop.key][i].coords.w)
                        SetVehicleDoorsLocked(veh, 3)

                        FreezeEntityPosition(veh,true)
                        SetVehicleNumberPlateText(veh, i .. "CARSALE")
                        table.insert(spawnedShowroom, veh)
                    end
                end
            else
                for k,v in pairs(spawnedShowroom) do DeleteVehicle(v); end
                spawnedShowroom = {}
                Citizen.Wait(500)
            end
            Citizen.Wait(1000)
        end
    end)
end

function OpenCreator(menu)
    TriggerEvent('police:client:pauseKeybind', true)
	vehshop.currentmenu = menu
	vehshop.opened = true
    vehshop.selectedbutton = 1
    if ClosestVehicle ~= nil then
        TriggerServerEvent('vehicleshop:server:setShowroomCarInUse', CurVehShop.key, ClosestVehicle, true)
    else
        TriggerServerEvent('vehicleshop:server:setSalePointInUse', CurVehShop.key, curSalePoint, true)
    end
    menuTick()
end

function setClosestShowroomVehicle()
    local plyPos = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = nil

    for id, veh in pairs(Config.ShowroomVehicles[CurVehShop.key]) do
        if current ~= nil then
            if #(plyPos - Config.ShowroomVehicles[CurVehShop.key][id].coords.xyz) < dist then
                current = id
                dist = #(plyPos - Config.ShowroomVehicles[CurVehShop.key][id].coords.xyz)
            end
        else
            dist = #(plyPos - Config.ShowroomVehicles[CurVehShop.key][id].coords.xyz)
            current = id
        end
    end
    if current ~= ClosestVehicle then
        ClosestVehicle = current
    end
end

Citizen.CreateThread(function()
    while true do
        local plyPos = GetEntityCoords(PlayerPedId())
        if isLoggedIn then
            local closestKey,closestVal,closestDist
            for k,v in pairs(Config.VehicleShops) do
                local dist = #(plyPos - v.pos)
                if not closestDist or dist < closestDist then
                    closestKey = k
                    closestVal = v
                    closestDist = dist
                end
            end
            if not CurVehShop then
                CurVehShop = { key = closestKey, val = closestVal }
                showroomTick()
                showroomVehicleCreation()
                salePointTick()
            else
                CurVehShop = { key = closestKey, val = closestVal }
            end
            if closestDist <= 50 then
                setClosestShowroomVehicle()
            end
        end
        Citizen.Wait(1000)
    end
end)

function showroomTick()
    Citizen.CreateThread(function()
        while CurVehShop do
            local lastPress = 0
            local plyPed = PlayerPedId()
            local plyPos = GetEntityCoords(plyPed)
            if Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle] ~= nil then
                local dist = #(plyPos - Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.xyz)
                if dist <= 3 then
                    if ClosestVehicle ~= nil then
                        local vehicleHash = GetHashKey(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle)
                        local vDist = 2.0
                        if IsThisModelABike(vehicleHash) then vDist = 1.75; end
                        if dist < vDist then
                            if not Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse then
                                local displayName = BJCore.Shared.Vehicles[Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle]["name"]
                                local vehPrice = BJCore.Shared.Vehicles[Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle]["price"]
                                local brand = BJCore.Shared.Vehicles[Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle]["brand"]

                                if not Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse then
                                    if not vehshop.opened then
                                        BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.70, '[~g~'..ClosestVehicle..'~s~]'..' '..brand..' '..displayName)
                                        if EnableAutomation(CurVehShop.key) then
                                            BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.65, "Price: ~g~$~s~"..math.ceil(vehPrice+(vehPrice*(Config.OfflinePriceMultiplier/100))).." | Buy [~g~E~w~]")
                                            BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.60, "[~g~H~s~] Change Vehicle")
                                            if IsControlJustPressed(1, 38) and GetGameTimer() - lastPress > 2000 then
                                                lastPress = GetGameTimer()
                                                local data = {
                                                    data = {
                                                        vehicle = Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle,
                                                        finance = false,
                                                        price = math.ceil(vehPrice+(vehPrice*(Config.OfflinePriceMultiplier/100))),
                                                        interest = false,
                                                        down = false,
                                                        repayments = false,
                                                        offline = true
                                                    }
                                                }
                                                TriggerServerEvent("vehicleshop:server:sellVehicle", GetPlayerServerId(PlayerId()), CurVehShop, data, GetVehicleType(data.data.vehicle))
                                            end
                                            if IsControlJustPressed(1, 74) then
                                                if not vehshop.opened then
                                                    OpenCreator(CurVehShop.key)
                                                end
                                            end
                                        end
                                    elseif vehshop.opened then
                                        if modelLoaded then
                                            BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.65, 'Choosing vehicle')
                                        else
                                            BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.65, 'Loading vehicle..')
                                        end
                                    end
                                else
                                    BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 1.65, 'Vehicle is being used by another customer')
                                end

                                if GetVehiclePedIsTryingToEnter(plyPed) ~= nil and GetVehiclePedIsTryingToEnter(plyPed) ~= 0 then
                                    ClearPedTasksImmediately(plyPed)
                                end
                            elseif Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse then
                                BJCore.Functions.DrawText3D(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.x, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.y, Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.z + 0.5, 'Vehicle is being used')
                            end
                        elseif dist > 1.5 then
                            if vehshop.opened then
                                CloseCreator()
                            end
                        end
                    end
                else
                    Citizen.Wait(1000)
                end
            end
            Citizen.Wait(0)
        end
    end)
end

function EnableAutomation(shop)
    local ret = false
    if dealersOnline[shop] ~= nil then
        if dealersOnline[shop] <= Config.MinEnableAuto[shop] then
            ret = true
        end
    end
    return ret
end

local hologram, holoVeh = false, false
local curSalePoint, curSalePointData = 0, {}
local showCtrls, selection = false, nil

local selections = {
    [1] = "price",
    [2] = "repayments",
    [3] = "down",
    [4] = "interest"
}

function salePointTick()
    Citizen.CreateThread(function()
        while CurVehShop do
            local nearby = false
            for k,v in pairs(Config.SalePoints[CurVehShop.key]) do
                local dist = #(GetEntityCoords(PlayerPedId()) - v.pos)
                if dist <= 5 then
                    nearby = true
                    -- local dist2 = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(holoVeh))
                    -- if dist < 2 or dist2 < 2 then
                    if dist < 2 then
                        curSalePoint = k
                        curSalePointData = v
                        if Config.SalePoints[CurVehShop.key][k]["enabled"] or (CurVehShop.key == PlayerJob.name and PlayerJob.onduty) then
                            if v.data.vehicle then
                                BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.5, BJCore.Shared.Vehicles[v.data.vehicle]["brand"].." "..BJCore.Shared.Vehicles[v.data.vehicle]["name"])
                                if v.data.finance then
                                    local total = v.data.price+(v.data.price*(v.data.interest/100))
                                    local down = total*(v.data.down/100)
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.4, "Price: ~g~$~s~"..CommaValue(math.floor(v.data.price)).." | NRP: "..v.data.repayments)
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.35, "Interest: "..v.data.interest.."~g~%~s~ | Total Price: ~g~$~s~"..CommaValue(math.ceil(total)))
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.3, v.data.down.."~g~%~s~ Down Payment | Amount: ~g~$~s~"..CommaValue(math.ceil(down)))
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.25, "Repayments of: ~g~$~s~"..CommaValue(math.ceil((total-down)/v.data.repayments)))
                                else
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.4, "Price: ~g~$~s~"..CommaValue(math.floor(v.data.price)))
                                end
                                -- if CurVehShop.key == "handlebar" then
                                --     salePointHologram(v.vehPos, v.data.vehicle)
                                -- end
                            else
                                if CurVehShop.key ~= PlayerJob.name then
                                    BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.3, "Awaiting Selection")
                                    -- resetHolo()
                                end
                            end
                        end
                        if (CurVehShop.key == PlayerJob.name and PlayerJob.onduty) then
                            if not Config.SalePoints[CurVehShop.key][k]["enabled"] then
                                BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.6, "[~g~"..k.."~s~] Sale Point ~r~Hidden")
                            else
                                BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.6, "[~g~"..k.."~s~] Sale Point ~g~Visible")
                            end
                            if v.data.inUse then
                                BJCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.2, "Currently in use")
                            end
                            if not showCtrls then
                                selection = 1
                                showCtrls = true
                                BJCore.Functions.PersistentNotify("start", "SALECTRL1", "[G] Toggle Finance | [H] Change Vehicle | [LEFT][RIGHT] Change Selection | [UP][DOWN] Change Selected Value ", "primary")
                                BJCore.Functions.PersistentNotify("start", "SALECTRL2", "Selection: "..selections[selection]:gsub("^%l", string.upper), "primary")
                            end
                            if BJCore.Functions.GetKeyPressed("G") and v.data.vehicle then
                                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.finance", not Config.SalePoints[CurVehShop.key][curSalePoint].data.finance)
                            end
                            if BJCore.Functions.GetKeyPressed("H") then
                                if not vehshop.opened then
                                    OpenCreator(CurVehShop.key)
                                end
                            end
                            if showCtrls and not v.data.finance and selection ~= 1 then
                                selection = 1
                                BJCore.Functions.PersistentNotify("start", "SALECTRL2", "Selection: "..selections[selection]:gsub("^%l", string.upper), "primary")
                            end
                        end
                    else
                        if showCtrls and k == curSalePoint then
                            BJCore.Functions.PersistentNotify("end", "SALECTRL1")
                            BJCore.Functions.PersistentNotify("end", "SALECTRL2")
                            showCtrls = false
                        end
                        if vehshop.opened and curSalePoint ~= 0 then
                            CloseCreator()
                        end
                        curSalePoint = 0
                        -- resetHolo()
                    end
                end
            end
            if not nearby then Citizen.Wait(1000); end
            Citizen.Wait(0)
        end
    end)
end

AddEventHandler("vehicleshop:client:ToggleSalePoint", function() 
    if curSalePoint and curSalePoint ~= 0 then
        TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "enabled", not Config.SalePoints[CurVehShop.key][curSalePoint]["enabled"])
    else
        BJCore.Functions.Notify("Sale point not found")
    end
end)

function resetHolo()
    if DoesEntityExist(holoVeh) then DeleteVehicle(holoVeh) holoVeh = false; end
    hologram = false
end

-- RegisterCommand("hologram", function()
--     Config.SalePoints[CurVehShop.key][1].data.vehicle = 'akuma'
--     Config.SalePoints[CurVehShop.key][1]["enabled"] = true
-- end)

function salePointHologram(pos, vehicle)
    if hologram then 
        if GetEntityModel(holoVeh) ~= GetHashKey(vehicle) then
            resetHolo()
        else
            return
        end
    end
    local model = GetHashKey(vehicle)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(250); end
    holoVeh = CreateVehicle(model, pos, pos.w, false, false)
    SetEntityCollision(holoVeh, false, false)
    FreezeEntityPosition(holoVeh, true)
    SetEntityRotation(holoVeh, GetEntityRotation(holoVeh) + vector3(30.0,0.0,0.0))
    SetEntityCoordsNoOffset(holoVeh, GetEntityCoords(holoVeh) + vector3(0.0,0.0,0.5))
    SetEntityInvincible(holoVeh, true)
    SetVehicleDoorsLocked(holoVeh, 2)    
    SetEntityAlpha(holoVeh, 200, false)
    SetModelAsNoLongerNeeded(model)
    hologram = true
    Citizen.CreateThread(function()
        while hologram do
            SetEntityRotation(holoVeh, GetEntityRotation(holoVeh) + vector3(0.0,0.0,0.2))
            Citizen.Wait(0)
        end
    end)
end

function menuTick()
    Citizen.CreateThread(function()
        while vehshop.opened do
            local menu = vehshop.menu[vehshop.currentmenu]
            local y = vehshop.menu.y + 0.12
            buttoncount = tablelength(menu.buttons)
            local selected = false
            for i,button in pairs(menu.buttons) do
                if i >= vehshop.menu.from and i <= vehshop.menu.to then
                    if i == vehshop.selectedbutton then
                        selected = true
                    else
                        selected = false
                    end
                    drawMenuButton(button,vehshop.menu.x,y,selected)
                    if button.price ~= nil then
                        drawMenuRight("$"..button.price,vehshop.menu.x,y,selected)
                    end
                    y = y + 0.04
                    if isValidMenu(vehshop.currentmenu) then
                        if selected then
                            if IsControlJustPressed(1, 18) then
                                if modelLoaded then
                                    if curSalePoint > 0 then
                                        TriggerServerEvent('vehicleshop:server:SetDefaultSale', button.model, CurVehShop.key, curSalePoint)
                                    elseif ClosestVehicle ~= nil then
                                        TriggerServerEvent('vehicleshop:server:setShowroomVehicle', button.model, CurVehShop.key, ClosestVehicle)
                                    end
                                end
                            end
                        end
                    end
                    if selected and (IsControlJustPressed(1, 38) or IsControlJustPressed(1, 18)) then
                        ButtonSelected(button)
                    end
                end
            end

            if IsControlJustPressed(1, 202) then
                Back()
            end
            if IsControlJustPressed(1, 188) then
                if modelLoaded then
                    if vehshop.selectedbutton > 1 then
                        vehshop.selectedbutton = vehshop.selectedbutton -1
                        if buttoncount > 10 and vehshop.selectedbutton < vehshop.menu.from then
                            vehshop.menu.from = vehshop.menu.from -1
                            vehshop.menu.to = vehshop.menu.to - 1
                        end
                    end
                end
            end
            if IsControlJustPressed(1, 187)then
                if modelLoaded then
                    if vehshop.selectedbutton < buttoncount then
                        vehshop.selectedbutton = vehshop.selectedbutton +1
                        if buttoncount > 10 and vehshop.selectedbutton > vehshop.menu.to then
                            vehshop.menu.to = vehshop.menu.to + 1
                            vehshop.menu.from = vehshop.menu.from + 1
                        end
                    end
                end
            end
            Citizen.Wait(0)
        end
    end)
end

AddEventHandler("vehicleshop:client:ChangeDisplayCurrent", function()
    if not CurVehShop then return BJCore.Functions.Notify("You're not at vehicleshop", "error"); end
    if CurVehShop and CurVehShop.key ~= PlayerJob.name then return BJCore.Functions.Notify("Access Denied", "error"); end
    if CurVehShop then
        if ClosestVehicle ~= nil then
            local dist = #(GetEntityCoords(PlayerPedId()) - Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.xyz)
            if dist < 1.75 then
                if not Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse then
                    if not vehshop.opened then
                        if vehshop.opened then
                            CloseCreator()
                        else
                            OpenCreator(CurVehShop.key)
                        end
                    end
                else
                    BJCore.Functions.Notify("Showroom Display currently in use")
                end
            else
                BJCore.Functions.Notify("Display vehicle not found", "error")
            end
        end    
    end
end)

AddEventHandler("vehicleshop:client:TestDriveCurrent", function()
    if not CurVehShop then return BJCore.Functions.Notify("You're not at vehicleshop", "error"); end
    if CurVehShop and CurVehShop.key ~= PlayerJob.name then return BJCore.Functions.Notify("Access Denied", "error"); end
    if CurVehShop then
        if ClosestVehicle ~= nil then
            local dist = #(GetEntityCoords(PlayerPedId()) - Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].coords.xyz)
            if dist < 1.75 then
                if not Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].inUse then
                    if not vehshop.opened then
                        TestDrive()
                    end
                else
                    BJCore.Functions.Notify("Showroom Display currently in use")
                end
            else
                BJCore.Functions.Notify("Display vehicle not found", "error")
            end
        end    
    end
end)


RegisterNetEvent('vehicleshop:client:setShowroomCarInUse')
AddEventHandler('vehicleshop:client:setShowroomCarInUse', function(showroom, showroomVehicle, inUse)
    Config.ShowroomVehicles[showroom][showroomVehicle].inUse = inUse
end)

RegisterNetEvent('vehicleshop:client:setSalePointInUse')
AddEventHandler('vehicleshop:client:setSalePointInUse', function(showroom, salePoint, inUse)
    Config.SalePoints[showroom][salePoint].inUse = inUse
end)

RegisterNetEvent('vehicleshop:client:setShowroomVehicle')
AddEventHandler('vehicleshop:client:setShowroomVehicle', function(showroomVehicle, showroom, k)
    if Config.ShowroomVehicles[showroom][k].chosenVehicle ~= showroomVehicle then
        BJCore.Functions.DeleteVehicle(GetClosestVeh(Config.ShowroomVehicles[showroom][k].coords.xyz, 2.0))
        modelLoaded = false
        Wait(250)
        local model = GetHashKey(showroomVehicle)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(250); end
        local veh = CreateVehicle(model, Config.ShowroomVehicles[showroom][k].coords.x, Config.ShowroomVehicles[showroom][k].coords.y, Config.ShowroomVehicles[showroom][k].coords.z, false, false)
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh,true)
        SetEntityHeading(veh, Config.ShowroomVehicles[showroom][k].coords.w)
        SetVehicleDoorsLocked(veh, 3)
        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, k .. "CARSALE")
        modelLoaded = true
        Config.ShowroomVehicles[showroom][k].chosenVehicle = showroomVehicle
    end
end)

RegisterNetEvent('vehicleshop:client:completePurchase')
AddEventHandler('vehicleshop:client:completePurchase', function(vehicle, plate)
    BJCore.Functions.SpawnVehicle(vehicle, function(veh)
        exports['legacyfuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.PurchaseVehicleSpawn[CurVehShop.key].w)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        TriggerServerEvent("vehicletuning:server:SaveVehicleProps", BJCore.Functions.GetVehicleProperties(veh))
        SetEntityAsMissionEntity(veh, true, true)
        SetNewWaypoint(Config.PurchaseVehicleSpawn[CurVehShop.key].x, Config.PurchaseVehicleSpawn[CurVehShop.key].y)
        BJCore.Functions.Notify("Your vehicle is ready for collection. Location mark on your map", "primary")
        Wait(1000)
        TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(veh), "plate", plate)
        exports["vehiclelock"]:hornandLights(veh, 3, 300, 30)
    end, Config.PurchaseVehicleSpawn[CurVehShop.key], true)
end)

local testDrives = {}
function TestDrive()
    BJCore.Functions.SpawnVehicle(Config.ShowroomVehicles[CurVehShop.key][ClosestVehicle].chosenVehicle, function(veh)
        exports['legacyfuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, CurVehShop.key..ClosestVehicle)
        SetEntityAsMissionEntity(veh, true, true)
        SetEntityHeading(veh, Config.TestDriveSpawn[CurVehShop.key].w)
        TriggerEvent('keys:addNew', veh, GetVehicleNumberPlateText(veh))
        BJCore.Functions.Notify("Test Drive Vehicle ready", "success")
        TriggerServerEvent("vehicleshop:server:syncTestDrives", CurVehShop.key, VehToNet(veh), true)
    end, Config.TestDriveSpawn[CurVehShop.key], true)    
end

RegisterNetEvent("vehicleshop:client:syncTestDrives")
AddEventHandler("vehicleshop:client:syncTestDrives", function(data) testDrives = data; end)

local testDrivesBlips = {}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if testDrives[PlayerJob.name] ~= nil and next(testDrives[PlayerJob.name]) then
            for veh,pos in pairs(testDrives[PlayerJob.name]) do
                if DoesEntityExist(NetToVeh(veh)) then
                    if not DoesBlipExist(testDrivesBlips[veh]) then
                        local blip = AddBlipForEntity(NetToVeh(veh))
                        SetBlipSprite(blip, 225)
                        SetBlipScale(blip, 1.0)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentString("Test Drive")
                        EndTextCommandSetBlipName(blip)
                        testDrivesBlips[veh] = blip
                    end
                else
                    if type(testDrives[PlayerJob.name][veh]) == "vector3" then
                        if testDrivesBlips[veh] ~= nil then
                            BeginTextCommandSetBlipName('STRING')
                            AddTextComponentString("Test Drive")
                            EndTextCommandSetBlipName(testDrivesBlips[veh])
                            SetBlipCoords(testDrivesBlips[veh], testDrives[PlayerJob.name][veh].x, testDrives[PlayerJob.name][veh].y, testDrives[PlayerJob.name][veh].z)
                        else
                            local blip = AddBlipForCoord(testDrives[PlayerJob.name][veh].x, testDrives[PlayerJob.name][veh].y, testDrives[PlayerJob.name][veh].z)
                            SetBlipSprite(blip, 225)
                            SetBlipScale(blip, 1.0)
                            SetBlipAsShortRange(blip, true)
                            BeginTextCommandSetBlipName('STRING')
                            AddTextComponentString("Test Drive")
                            EndTextCommandSetBlipName(blip)
                            testDrivesBlips[veh] = blip
                        end
                    end
                end
            end
        end
    end
end)

function IsInTestDrive()
    local ret = false
    local plyPed = PlayerPedId()
    if IsPedInAnyVehicle(plyPed) then
        local veh = GetVehiclePedIsIn(plyPed)
        if veh ~= 0 and testDrives[PlayerJob.name] ~= nil and next(testDrives[PlayerJob.name]) ~= nil then
            for k,v in pairs(testDrives[PlayerJob.name]) do
                if veh == NetToVeh(k) then
                    ret = true
                    break
                end
            end
        end
    end
    return ret
end
exports("IsInTestDrive", IsInTestDrive)

AddEventHandler("vehicleshop:client:returnTestDrive", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    TriggerServerEvent("vehicleshop:server:syncTestDrives", PlayerJob.name, VehToNet(vehicle), false)
    BJCore.Functions.DeleteVehicle(vehicle)
end)

RegisterKeyMapping('+valueup', 'Value Up~', 'keyboard', 'UP')
RegisterCommand('+valueup', function()
    if curSalePoint == 0 then return; end
    if vehshop.opened then return; end
    if CurVehShop.key ~= PlayerJob.name then return; end
    if curSalePointData.data.vehicle == nil then return; end
    if selections[selection] == "price" then
        local sharedVeh = BJCore.Shared.Vehicles[curSalePointData.data.vehicle]
        local maxUp = Config.MaxPriceMarkUp/100
        if Config.PriceMarkType == 2 then
            if sharedVeh.markup ~= nil then
                maxUp = sharedVeh.markup/100
            else
                print("Vehicle model: "..curSalePointData.data.vehicle.." missing markup value in shared.lua. Using Config.MaxPriceMarkUp instead")
            end
        end
        if curSalePointData.data.price + (sharedVeh.price*0.01) > sharedVeh.price + (sharedVeh.price*maxUp) then
            if curSalePointData.data.price ~= sharedVeh.price then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.price", sharedVeh.price + (sharedVeh.price*maxUp))
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.price", curSalePointData.data.price + (sharedVeh.price*0.01))
        end
    elseif selections[selection] == "repayments" then
        if curSalePointData.data.repayments + 1 > Config.MaxAmountOfRepayments then
            if curSalePointData.data.repayments ~= Config.MaxAmountOfRepayments then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.repayments", Config.MaxAmountOfRepayments)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.repayments", curSalePointData.data.repayments + 1)
        end
    elseif selections[selection] == "down" then
        if curSalePointData.data.down + 1 > Config.MaxDownpayment then
            if curSalePointData.data.down ~= Config.MaxDownpayment then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.down", Config.MaxDownpayment)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.down", curSalePointData.data.down + 1)
        end
    elseif selections[selection] == "interest" then
        if curSalePointData.data.interest + 1 > Config.MaxInterestRate then
            if curSalePointData.data.interest ~= Config.MaxInterestRate then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.interest", Config.MaxInterestRate)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.interest", curSalePointData.data.interest + 1)
        end
    end
end, false)

RegisterKeyMapping('+valuedown', 'Value Down~', 'keyboard', 'DOWN')
RegisterCommand('+valuedown', function()
    if curSalePoint == 0 then return; end
    if vehshop.opened then return; end
    if CurVehShop.key ~= PlayerJob.name then return; end
    if curSalePointData.data.vehicle == nil then return; end
    if selections[selection] == "price" then
        local sharedVeh = BJCore.Shared.Vehicles[curSalePointData.data.vehicle]
        local maxDown = Config.MaxPriceMarkDown/100
        if Config.PriceMarkType == 2 then
            if sharedVeh.markdown ~= nil then
                maxDown = sharedVeh.markdown/100
            else
                print("Vehicle model: "..curSalePointData.data.vehicle.." missing markdown value in shared.lua. Using Config.MaxPriceMarkDown instead")
            end
        end
        if curSalePointData.data.price - (sharedVeh.price*0.01) < sharedVeh.price - (sharedVeh.price*maxDown) then
            if curSalePointData.data.price ~= sharedVeh.price - (sharedVeh.price*maxDown) then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.price", sharedVeh.price - (sharedVeh.price*maxDown))
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.price", curSalePointData.data.price - (sharedVeh.price*0.01))
        end
    elseif selections[selection] == "repayments" then
        if curSalePointData.data.repayments - 1 < Config.MinAmountOfRepayments then
            if curSalePointData.data.repayments ~= Config.MinAmountOfRepayments then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.repayments", Config.MinAmountOfRepayments)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.repayments", curSalePointData.data.repayments - 1)
        end
    elseif selections[selection] == "down" then
        if curSalePointData.data.down - 1 < Config.MinDownpayment then
            if curSalePointData.data.down ~= Config.MinDownpayment then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.down", Config.MinDownpayment)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.down", curSalePointData.data.down - 1)
        end
    elseif selections[selection] == "interest" then
        if curSalePointData.data.interest - 1 < Config.MinInterestRate then
            if curSalePointData.data.interest ~= Config.MinInterestRate then
                TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.interest", Config.MinInterestRate)
            end
        else
            TriggerServerEvent("vehicleshop:server:UpdateSalePointData", CurVehShop.key, curSalePoint, "data.interest", curSalePointData.data.interest - 1)
        end
    end
end, false)

RegisterKeyMapping('+valueleft', 'Value Left~', 'keyboard', 'LEFT')
RegisterCommand('+valueleft', function()
    if curSalePoint == 0 then return; end
    if vehshop.opened then return; end
    if CurVehShop.key ~= PlayerJob.name then return; end
    if curSalePointData.data.vehicle == nil then return; end
    if selection >= 1 and curSalePointData.data.finance then
        if selection - 1 <= 0 then
            selection = 1
        else
            selection = selection - 1
        end
        BJCore.Functions.PersistentNotify("start", "SALECTRL2", "Selection: "..selections[selection]:gsub("^%l", string.upper), "primary")
    end
end, false)

RegisterKeyMapping('+valueright', 'Value Right~', 'keyboard', 'RIGHT')
RegisterCommand('+valueright', function()
    if curSalePoint == 0 then return; end
    if vehshop.opened then return; end
    if CurVehShop.key ~= PlayerJob.name then return; end
    if curSalePointData.data.vehicle == nil then return; end
    if selection >= 1 and curSalePointData.data.finance then
        if selection + 1 > #selections then
            selection = #selections
        else
            selection = selection + 1
        end
        BJCore.Functions.PersistentNotify("start", "SALECTRL2", "Selection: "..selections[selection]:gsub("^%l", string.upper), "primary")
    end
end, false)

RegisterCommand("sellvehicle", function(s,a,r)
    if curSalePoint == 0 then return; end
    if vehshop.opened then return; end
    if CurVehShop.key ~= PlayerJob.name then return; end
    if curSalePointData == nil and next(curSalePointData) == nil then return; end
    if a[1] == nil then return; end
    if not tonumber(a[1]) then return; end
    if tonumber(a[1]) == GetPlayerServerId(PlayerId()) and not Config.AllowDealerSellOwn then return; end
    TriggerServerEvent("vehicleshop:server:sellVehicle", a[1], CurVehShop, curSalePointData, GetVehicleType(curSalePointData.data.vehicle))
end)

local pendingSale = {}
RegisterNetEvent("vehiceleshop:client:requestSale")
AddEventHandler("vehiceleshop:client:requestSale", function(shopData, vData, origin)
    pendingSale.shopData = shopData
    pendingSale.vData = vData
    pendingSale.origin = origin
    if shopData.offline == true then pendingSale.origin = false; end
    local displayName = BJCore.Shared.Vehicles[vData.data.vehicle]["name"]
    local brand = BJCore.Shared.Vehicles[vData.data.vehicle]["brand"]
    if vData.data.finance then
        local downPayment = math.ceil(vData.data.price*(vData.data.down/100))
        BJCore.Functions.PersistentNotify("start", "vehsale", "<u><b>"..shopData.val.label.."</b></u><br> Pending Sale <br><br> <b>Vehicle:</b> "..brand.." "..displayName.."<br><b>Total Price:</b> $"..CommaValue(math.floor(vData.data.price)).."<br>Interest: "..vData.data.interest.."%<br>Down Payment: $"..CommaValue(downPayment).." ("..vData.data.down.."%)<br>Repayments: $"..CommaValue(math.ceil((vData.data.price-downPayment)/vData.data.repayments)).." (x"..vData.data.repayments..")<br><br> /vehiclesale [accept/decline]", "success", { ['background-color'] = '#ff8800', ['color'] = '#ffffff' })
    else
        BJCore.Functions.PersistentNotify("start", "vehsale", "<u><b>"..shopData.val.label.."</b></u><br> Pending Sale <br><br> <b>Vehicle:</b> "..brand.." "..displayName.."<br><b>Price:</b> $"..CommaValue(vData.data.price).."<br><br> /vehiclesale [accept/decline]", "success", { ['background-color'] = '#ff8800', ['color'] = '#ffffff' })
    end
    Wait(5*60*1000)
    BJCore.Functions.PersistentNotify("end", "vehsale")
    pendingSale = {}
end)

RegisterCommand("vehiclesale", function(s,a,r)
    if pendingSale == nil or next(pendingSale) == nil then return; end
    if a[1] == "accept" then
        BJCore.Functions.PersistentNotify("end", "vehsale")
        TriggerServerEvent("vehicleshop:server:buyVehicle", pendingSale)
    elseif a[1] == "decline" then
        BJCore.Functions.PersistentNotify("end", "vehsale")
        BJCore.Functions.Notify("Vehicle Sale declined", "error")
        pendingSale = {}
    end
end)

function GetVehicleType(model)
    if type(model) ~= "number" then model = GetHashKey(model); end
    local vType = "vehicle"
    if IsThisModelAPlane(model) or IsThisModelAHeli(model) then
        vType = "aircraft"
    elseif IsThisModelABoat(model) then
        vType = "boat"
    end
    return vType
end
exports("GetVehicleType", GetVehicleType)

function CommaValue(value)
    local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return; end
    BJCore.Functions.PersistentNotify("end", "vehsale")
    BJCore.Functions.PersistentNotify("end", "SALECTRL1")
    BJCore.Functions.PersistentNotify("end", "SALECTRL2")
end)

RegisterNetEvent("vehicleshop:client:returnSaledata")
AddEventHandler("vehicleshop:client:returnSaledata", function(data) Config.SalePoints = data end)

function GetClosestVeh(coords, range)
    local vehicles        = BJCore.Functions.GetVehicles()
    local closestDistance = -1
    local closestVehicle  = 0
    local coords          = coords

    if coords == nil then
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end
    for i=1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance      = #(vehicleCoords - coords)

        if distance < range then
            closestVehicle  = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle
end
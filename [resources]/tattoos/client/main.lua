local currentTattoos = {}
local cam = nil
local back = 1
local opacity = 1
local scaleType = nil
local scaleString = ""
local closestShop = false
local menuOpen = false
local catMenuOpen = false
local lastTattoo = nil
local runningInfinity = false

Config.interiorIds = {}
for k, v in ipairs(Config.Shops) do
    Config.interiorIds[#Config.interiorIds + 1] = GetInteriorAtCoords(v)
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	if not runningInfinity then
		runningInfinity = true
		InfinityIsfun()
	end
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    runningInfinity = false
end)

function InfinityIsfun()
	Citizen.CreateThread(function()
		while runningInfinity do
			Citizen.Wait(300000)
			if Menu.hidden then
                refreshTattoos(false)
			end
		end
	end)
end

function refreshTattoos(naked)
	BJCore.Functions.TriggerServerCallback('tattoos:server:GetPlayerTattoos', function(tattooList)
		if tattooList then
			ClearPedDecorations(PlayerPedId())
			for k, v in pairs(tattooList) do
				if v.Count ~= nil then
					for i = 1, v.Count do
						SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
					end
				else
					SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
				end
			end
			currentTattoos = tattooList
		end
		if naked then GetNaked(); end
	end)
end

function GetTattooData()
	return currentTattoos
end
exports('GetTattooData', GetTattooData)

function DrawTattoo(collection, name)
	ClearPedDecorations(PlayerPedId())
	for k, v in pairs(currentTattoos) do
		if v.Count ~= nil then
			for i = 1, v.Count do
				SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
			end
		else
			SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
		end
	end
	if HasTattoo(name) then return; end
	for i = 1, opacity do
		SetPedDecoration(PlayerPedId(), collection, name)
	end
end

function GetNaked()
	if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
		local nakedMale = {
			outfitData = {
				["pants"]       = { item = 14, texture = 0},  -- Broek
				["arms"]        = { item = 15, texture = 0},  -- Armen
				["t-shirt"]     = { item = 15, texture = 0},  -- T Shirt
				["vest"]        = { item = 0, texture = 0},  -- Body Vest
				["torso2"]      = { item = 91, texture = 0},  -- Jas / Vesten
				["shoes"]       = { item = 5, texture = 0},  -- Schoenen
				["decals"]      = { item = 10, texture = 0},  -- Decals
				["accessory"]   = { item = 0, texture = 0},  -- Nek / Das
				["hat"]         = { item = -1, texture = -1},  -- Pet
				["glass"]       = { item = 0, texture = 0},  -- Bril
				["mask"]         = { item = 0, texture = 0},  -- Masker
			},
		}
		TriggerEvent('bj-clothing:client:loadOutfit', nakedMale)
	else
		local nakedFemale = {
			outfitData = {
				["pants"]       = { item = 16, texture = 0},  -- Broek
				["arms"]        = { item = 15, texture = 0},  -- Armen
				["t-shirt"]     = { item = -1, texture = 0},  -- T Shirt
				["vest"]        = { item = 0, texture = 0},  -- Body Vest
				["torso2"]      = { item = 101, texture = 1},  -- Jas / Vesten
				["shoes"]       = { item = 5, texture = 0},  -- Schoenen
				["decals"]      = { item = 0, texture = 0},  -- Decals
				["accessory"]   = { item = 0, texture = 0},  -- Nek / Das
				["hat"]         = { item = -1, texture = -1},  -- Pet
				["glass"]       = { item = 0, texture = 0},  -- Bril
				["mask"]         = { item = 0, texture = 0},  -- Masker
			},
		}
		TriggerEvent('bj-clothing:client:loadOutfit', nakedFemale)
	end
end

function ResetSkin()
	TriggerEvent("clothing:client:settingtattoos")
	Citizen.Wait(10)
	TriggerServerEvent("bj-clothing:loadPlayerSkin")
end

function ReqTexts(text, slot)
	RequestAdditionalText(text, slot)
	while not HasAdditionalTextLoaded(slot) do
		Citizen.Wait(0)
	end
end

function OpenTattooShop()
	ClearPedTasks(PlayerPedId())
	menuOpen = true
	TriggerEvent("hud:toggle", false)
	refreshTattoos(true)
	FreezeEntityPosition(PlayerPedId(), true)
	ReqTexts("TAT_MNU", 9)
	OpenMainMenu()
end

function CloseTattooShop()
	menuOpen = false
	closestShop = false
	ClearAdditionalText(9, 1)
	FreezeEntityPosition(PlayerPedId(), false)
	EnableAllControlActions(0)
	back = 1
	opacity = 1
	ResetSkin()
	TriggerEvent("hud:toggle", true)
	return true
end

function ButtonPress()
	PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

function BuyTattoo(collection, name, label, price)
	local ret, busy = false, true
	BJCore.Functions.TriggerServerCallback('tattoos:server:PurchaseTattoo', function(success)
		if success then
			table.insert(currentTattoos, {collection = collection, nameHash = name, Count = opacity})
			LocalDecorationRefresh()
			ret = true
		end
		busy = false
	end, currentTattoos, price, {collection = collection, nameHash = name, Count = opacity}, GetLabelText(label))
	while busy do Citizen.Wait(0); end
	return ret
end

function RemoveTattoo(name, label)
	for k, v in pairs(currentTattoos) do
		if v.nameHash == name then
			table.remove(currentTattoos, k)
			LocalDecorationRefresh()
		end
	end
	TriggerServerEvent("tattoos:server:RemoveTattoo", currentTattoos)
	BJCore.Functions.Notify("You have removed the " .. GetLabelText(label) .. " tattoo", 'success')
end

function CreateScale(sType)
	if scaleString ~= sType and sType == "Control" then
		scaleType = setupScaleform("instructional_buttons", "Change Camera View", 21, "Change Opacity", {32, 33}, "Buy/Remove Tattoo", 191, "Rotate Player", {34,35})
		scaleString = sType
	end
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        local plyPed = PlayerPedId()
		local CanSleep = true
		for _,interiorId in ipairs(Config.interiorIds) do
			if GetInteriorFromEntity(plyPed) == interiorId then
				CanSleep = false
				if not IsPedInAnyVehicle(plyPed, false) then
					if not menuOpen and not closestShop then
						closestShop = _
						BJCore.Functions.PersistentNotify("start", "tatshop", "[E] Open Tattoo Shop", "primary")
					end
					if IsControlJustPressed(0, 38) then
						BJCore.Functions.PersistentNotify("end", "tatshop")
						Menu.hidden = not Menu.hidden
						OpenTattooShop()
					end
					if IsDisabledControlJustPressed(1, 177) and not Menu.hidden then
						if catMenuOpen then
							OpenMainMenu()
						else
		                    closeMenuFull()
		                end
	                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	                end
				end
			else
				if closestShop and closestShop == _ then
					if not Menu.hidden then
						Menu.hidden = true
					end
					closestShop = false
					BJCore.Functions.PersistentNotify("end", "tatshop")
				end
			end
		end

		if menuOpen then
			Menu.renderGUI()
			DisableAllControlActions(0)
			CanSleep = false
		end
	end
end)

function OpenMainMenu()
	catMenuOpen = false
	LocalDecorationRefresh()
	if DoesCamExist(cam) then
		DetachCam(cam)
		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, 1, 0)
		DestroyCam(cam, false)
	end
    MenuTitle = "Main Menu"
    TriggerEvent("police:client:pauseKeybind", true)
    ClearMenu()
    Menu.selection = 0
    Menu.addButton("Tattoo Categories", "yeet", "Categories", nil, "Title")
    for k,v in pairs(Config.TattooCats) do
    	Menu.addButton(v[2], "OpenCatMenu", v) 
    end
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

AddEventHandler("tattoos:client:setTattoos", function()
	local busy = false
	if currentTattoos == nil or next(currentTattoos) == nil then
		busy = true
		BJCore.Functions.TriggerCallback('tattoos:server:GetPlayerTattoos', function(tattooList)
			if tattooList then
				currentTattoos = tattooList
			end
			busy = false
		end)
	end
	while busy do Citizen.Wait(0); end
	LocalDecorationRefresh()
end)

function LocalDecorationRefresh()
	ClearPedDecorations(PlayerPedId())
	for k,v in pairs(currentTattoos) do
		if v.Count ~= nil then
			for i = 1, v.Count do
				SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
			end
		else
			SetPedDecoration(PlayerPedId(), v.collection, v.nameHash)
		end
	end
end

function OpenCatMenu(cat)
	local sex = "female"
	if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then sex = "male"; end
	catMenuOpen = cat
	UpdateCatCam()
	InCatMenuTick()
    MenuTitle = "Cat Menu"
    ClearMenu()
    Menu.selection = 0
    Menu.addButton(cat[2].." Tattoos", "yeet", cat[2], nil, "Title")
    for k,v in pairs(Config.AllTattooList) do
    	if v["Zone"] == cat[1] then
    		local hash = false
			if sex == "male" then
				if v.HashNameMale ~= '' then
					hash = v.HashNameMale
				end
			elseif sex == "female" then
				if v.HashNameFemale ~= '' then
					hash = v.HashNameFemale
				end
			end
			if HasTattoo(hash) then
		    	Menu.addButton(GetLabelText(v["Name"]), "BuyRemove", v, "Remove", "Remove")
			else
		    	Menu.addButton(GetLabelText(v["Name"]), "BuyRemove", v, BJCore.Config.Currency.Symbol..""..v["Price"])
		    end
	    end
    end
    Menu.addButton("Back", "OpenMainMenu", nil)
end

function InCatMenuTick()
	Citizen.CreateThread(function()
		while catMenuOpen do
			local plyPed = PlayerPedId()
			CreateScale("Control")
			DrawScaleformMovieFullscreen(scaleType, 255, 255, 255, 255, 0)
			if IsDisabledControlJustPressed(0, 21) then
				ButtonPress()
				if back == #catMenuOpen[3] then
					back = 1
				else
					back = back + 1
				end
				if GetCamCoord(cam) ~= GetOffsetFromEntityInWorldCoords(plyPed, catMenuOpen[3][back]) then
					SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(plyPed, catMenuOpen[3][back]))
					PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(plyPed, catMenuOpen[4]))
				end
			end
			if IsDisabledControlJustPressed(0, 32) then
				ButtonPress()
				if opacity == 10 then
					opacity = 10
				else
					opacity = opacity + 1
				end
				if lastTattoo ~= nil then
					Hovered(lastTattoo)
				end
			end
			if IsDisabledControlJustPressed(0, 33) then
				ButtonPress()
				if opacity == 1 then
					opacity = 1
				else
					opacity = opacity - 1
				end
				if lastTattoo ~= nil then
					Hovered(lastTattoo)
				end
			end
			if IsDisabledControlPressed(0, 34) then
				SetEntityHeading(plyPed, GetEntityHeading(plyPed) - 1)
			end
			if IsDisabledControlPressed(0, 35) then
				SetEntityHeading(plyPed, GetEntityHeading(plyPed) + 1)
			end
			Citizen.Wait(0)
		end
	end)
end

function UpdateCatCam()
	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 0, true, true)
		StopCamShaking(cam, true)
	end
	if GetCamCoord(cam) ~= GetOffsetFromEntityInWorldCoords(PlayerPedId(), catMenuOpen[3][back]) then
		SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), catMenuOpen[3][back]))
		PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), catMenuOpen[4]))
	end
end

function Hovered(tattoo)
	lastTattoo = tattoo
	if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
		if tattoo.HashNameMale ~= '' then
			DrawTattoo(tattoo.Collection, tattoo.HashNameMale)
		end
	else
		if tattoo.HashNameFemale ~= '' then
			DrawTattoo(tattoo.Collection, tattoo.HashNameFemale)
		end
	end
end

function HasTattoo(hash)
	local found = false
	for k, v in pairs(currentTattoos) do
		if v.nameHash == hash then
			found = true
			break
		end
	end
	return found
end

function BuyRemove(tattoo, option)
	if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
		if tattoo.HashNameMale ~= '' then
			if HasTattoo(tattoo.HashNameMale) then
				RemoveTattoo(tattoo.HashNameMale, tattoo.Name)
				Menu.updateButton(option.page, option.button, GetLabelText(tattoo["Name"]), "BuyRemove", tattoo, BJCore.Config.Currency.Symbol..""..tattoo["Price"])
			else
				Citizen.CreateThread(function()
					if BuyTattoo(tattoo.Collection, tattoo.HashNameMale, tattoo.Name, tattoo.Price) then
						Menu.updateButton(option.page, option.button, GetLabelText(tattoo["Name"]), "BuyRemove", tattoo, "Remove", "Remove")
					end
				end)
			end
		end
	else
		if tattoo.HashNameFemale ~= '' then
			if HasTattoo(tattoo.HashNameFemale) then
				RemoveTattoo(tattoo.HashNameFemale, tattoo.Name)
				Menu.updateButton(option.page, option.button, GetLabelText(tattoo["Name"]), "BuyRemove", tattoo, BJCore.Config.Currency.Symbol..""..tattoo["Price"])
			else
				Citizen.CreateThread(function()
					if BuyTattoo(tattoo.Collection, tattoo.HashNameFemale, tattoo.Name, tattoo.Price) then
						Menu.updateButton(option.page, option.button, GetLabelText(tattoo["Name"]), "BuyRemove", tattoo, "Remove", "Remove")
					end
				end)
			end
		end
	end
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    PushScaleformMovieMethodParameterButtonName(ControlButton)
end

function setupScaleform(scaleform, message, button, message2, buttons, message3, button2, message4, buttons2)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 175, true))
    Button(GetControlInstructionalButton(2, 174, true))
    ButtonMessage("Nav Pages")
    PopScaleformMovieFunctionVoid()
	
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, buttons[2], true))
    Button(GetControlInstructionalButton(2, buttons[1], true))
    ButtonMessage(message2)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, button, true))
    ButtonMessage(message)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, buttons2[2], true))
    Button(GetControlInstructionalButton(2, buttons2[1], true))
    ButtonMessage(message4)
    PopScaleformMovieFunctionVoid()
	
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, button2, true))
    ButtonMessage(message3)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end
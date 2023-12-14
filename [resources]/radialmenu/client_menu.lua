-- Menu state
local showMenu = false

-- Keybind Lookup table
local keybindControls = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local MAX_MENU_ITEMS = 7
local enabled = true
AddEventHandler('disableRadialMenuUse', function() enabled = false end)
AddEventHandler('enableRadialMenuUse', function() enabled = true end)
-- Main thread
Citizen.CreateThread(function()
    local keyBind = "Z"
    local resName = GetCurrentResourceName()
    while true do
        Citizen.Wait(0)
        if enabled then
            if not IsControlPressed(1, keybindControls[keyBind]) and GetLastInputMethod(2) and showMenu then
                showMenu = false
				TriggerEvent('radialmenu:hidden')
                --SetNuiFocus(false, false)
            end
            if IsControlPressed(1, keybindControls[keyBind]) and GetLastInputMethod(2) then
                showMenu = true
                local enabledMenus = {}
                for _, menuConfig in ipairs(rootMenuConfig) do
                    if menuConfig:enableMenu() then
                        local dataElements = {}
                        local hasSubMenus = false
                        if menuConfig.id == "weed-dealer" then
                            menuConfig.subMenus = getSeedItems()
                        end
                        if menuConfig.subMenus ~= nil and #menuConfig.subMenus > 0 then
                            hasSubMenus = true
                            local previousMenu = dataElements
                            local currentElement = {}
                            for i = 1, #menuConfig.subMenus do
                                -- if newSubMenus[menuConfig.subMenus[i]] ~= nil and newSubMenus[menuConfig.subMenus[i]].enableMenu ~= nil and not newSubMenus[menuConfig.subMenus[i]]:enableMenu() then
                                --     goto continue
                                -- end
                                currentElement[#currentElement+1] = newSubMenus[menuConfig.subMenus[i]]
                                currentElement[#currentElement].id = menuConfig.subMenus[i]
                                currentElement[#currentElement].enableMenu = nil

                                if i % MAX_MENU_ITEMS == 0 and i < (#menuConfig.subMenus - 1) then
                                    previousMenu[MAX_MENU_ITEMS + 1] = {
                                        id = "_more",
                                        title = "More",
                                        icon = "#more",
                                        items = currentElement
                                    }
                                    previousMenu = currentElement
                                    currentElement = {}
                                end
                                --::continue::
                            end
                            if #currentElement > 0 then
                                previousMenu[MAX_MENU_ITEMS + 1] = {
                                    id = "_more",
                                    title = "More",
                                    icon = "#more",
                                    items = currentElement
                                }
                            end
                            dataElements = dataElements[MAX_MENU_ITEMS + 1].items

                        end
                        enabledMenus[#enabledMenus+1] = {
                            id = menuConfig.id,
                            title = menuConfig.displayName,
                            functionName = menuConfig.functionName,
                            functionParameters = menuConfig.functionParameters or nil,
                            icon = menuConfig.icon,
                        }
                        if hasSubMenus then
                            enabledMenus[#enabledMenus].items = dataElements
                        end
                    end
                end
                SendNUIMessage({
                    state = "show",
                    resourceName = resName,
                    data = enabledMenus,
                    menuKeyBind = "z"
                })
                SetCursorLocation(0.5, 0.5)

                -- Play sound
                PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)


                while IsControlPressed(1, keybindControls[keyBind]) do
                    Wait(0)
					DisableControlAction(1, 1, true)
					DisableControlAction(1, 2, true)
					DisableControlAction(1, 3, true)
					DisableControlAction(1, 4, true)
					DisableControlAction(1, 5, true)
					DisableControlAction(1, 6, true)
					DisableControlAction(0, 69, true)
					DisableControlAction(0, 92, true)
					DisableControlAction(0, 142, true)
					DisableControlAction(0, 237, true)
					DisableControlAction(0, 257, true)
					local posX, posY = GetNuiCursorPosition()
					SendNUIMessage({
						state = "mouse",
						position = {
							x = posX,
							y = posY
						},
						resourceName = resName,
						click = IsDisabledControlJustReleased(0, 24)
					})
                end
                Citizen.Wait(100)
                if showMenu then
                    showMenu = false
					TriggerEvent('radialmenu:hidden')
                    SendNUIMessage({
                        state = 'destroy'
                    })
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    local lastShown = false
	while true do
        if showMenu then
            lastShown = true
            Wait(0)
            
            DisableControlAction(0, 24, true)
            DisablePlayerFiring(PlayerId(), true)
            --print(GetNuiCursorPosition())
        elseif lastShown and not showMenu then
            local toWait = 100
			while toWait > 0 do
				DisableControlAction(0, 24, true)
				DisablePlayerFiring(PlayerId(), true)
				toWait = toWait - 1
				Wait(0)
            end
            lastShown = false
		else
			Wait(100)
		end
	end
end)
-- Callback function for closing menu
RegisterNUICallback('closemenu', function(data, cb)
    -- Clear focus and destroy UI
    
    --SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
    SetControlNormal(0, 24, 0)

    -- Play sound    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Send ACK to callback function
    cb('ok')

    Wait(500)
    showMenu = false
	TriggerEvent('radialmenu:hidden')
end)

-- Callback function for when a slice is clicked, execute command
RegisterNUICallback('triggerAction', function(data, cb)
    print("data: "..BJCore.Common.Dump(data))
    -- Clear focus and destroy UI
    showMenu = false
	TriggerEvent('radialmenu:hidden')
    --SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Run command
    --ExecuteCommand(data.action)
    TriggerEvent(data.action, data.parameters)

    -- Send ACK to callback function
    cb('ok')
end)

RegisterNetEvent("menu:menuexit")
AddEventHandler("menu:menuexit", function()
    showMenu = false
	TriggerEvent('radialmenu:hidden')
    --SetNuiFocus(false, false)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        showMenu = false
		TriggerEvent('radialmenu:hidden')
        --SetNuiFocus(false, false)
        SendNUIMessage({
            state = 'destroy'
        })
    end
end)
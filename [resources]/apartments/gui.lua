-- Credit : Ideo

--------------------------------------------------------------------------------------------------------------------
-- fonctions graphiques
--------------------------------------------------------------------------------------------------------------------

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Menu = {}
Menu.GUI = {}
Menu.buttonCount = 0
Menu.selection = 0
Menu.hidden = true
MenuTitle = "Menu"
Menu.MaxOptions = 20
Menu.CurButtonCount = 0
Menu.CurMenuPage = 1
Menu.MenuPages = 1

function Menu.addButton(name, func,args,args2,args3,extra,damages,bodydamages,fuel)
	local yoffset = 0.25
	local xoffset = 0.3
	local xmin = 0.0
	local xmax = 0.15
	local ymin = 0.03
	local ymax = 0.03
	if Menu.CurButtonCount == 20 then
        Menu.MenuPages = Menu.MenuPages + 1
        Menu.CurButtonCount = 0
        --Menu.buttonCount = 0
    end
    Menu.CurButtonCount = Menu.CurButtonCount + 1
    if Menu.GUI[Menu.MenuPages] == nil then 
    	Menu.GUI[Menu.MenuPages] = {}
    end
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount] = {}
	if extra ~= nil then
		Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["extra"] = extra
	end
	if damages ~= nil then
		Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["damages"] = damages
		Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["bodydamages"] = bodydamages
		Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["fuel"] = fuel
	end
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["name"] = name
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["func"] = func
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["args"] = args
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["args2"] = args2
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["args3"] = args3		
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["active"] = false
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["xmin"] = xmin
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["ymin"] = ymin * (Menu.CurButtonCount + 0.01) +yoffset
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["xmax"] = xmax 
	Menu.GUI[Menu.MenuPages][Menu.CurButtonCount]["ymax"] = ymax 
	Menu.buttonCount = Menu.buttonCount+1
end

function Menu.updateSelection() 
	if IsControlJustPressed(1, Keys["DOWN"]) then 
		if(Menu.selection < #Menu.GUI[Menu.CurMenuPage] -1 ) then
			if Menu.selection +1 == 3 and MenuTitle == "Options" then
				Menu.selection = 4
			else
				Menu.selection = Menu.selection +1
			end
		else
			Menu.selection = 1
		end		
		PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	elseif IsControlJustPressed(1, Keys["TOP"]) then
		if(Menu.selection > 1)then
			if Menu.selection -1 == 3 and MenuTitle == "Options" then
				Menu.selection = 2
			else
				Menu.selection = Menu.selection -1
			end
		else
			Menu.selection = #Menu.GUI[Menu.CurMenuPage]-1
		end	
		PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	elseif IsControlJustPressed(1, Keys["LEFT"]) then
		if Menu.CurMenuPage ~= 1 then
			Menu.CurMenuPage = Menu.CurMenuPage - 1
			if Menu.GUI[Menu.CurMenuPage][Menu.selection] == nil then
				Menu.selection = 0
			end
		end
		PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	elseif IsControlJustPressed(1, Keys["RIGHT"]) then
		if Menu.CurMenuPage ~= Menu.MenuPages then
			Menu.CurMenuPage = Menu.CurMenuPage + 1
			if Menu.GUI[Menu.CurMenuPage][Menu.selection] == nil then
				Menu.selection = 0
			end
		end
		PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	elseif IsControlJustPressed(1, 215) then
		MenuCallFunction(Menu.GUI[Menu.CurMenuPage][Menu.selection +1]["func"], Menu.GUI[Menu.CurMenuPage][Menu.selection +1]["args"], Menu.GUI[Menu.CurMenuPage][Menu.selection +1]["args2"] or nil, Menu.GUI[Menu.CurMenuPage][Menu.selection +1]["args3"] or nil)
		PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	end
	local iterator = 0
	if Menu.GUI[Menu.CurMenuPage] ~= nil then
		for id, settings in ipairs(Menu.GUI[Menu.CurMenuPage]) do
			Menu.GUI[Menu.CurMenuPage][id]["active"] = false
			if(iterator == Menu.selection ) then
				Menu.GUI[Menu.CurMenuPage][iterator +1]["active"] = true
			end
			iterator = iterator +1
		end
	end
end

function Menu.renderGUI()
	if not Menu.hidden then
		Menu.renderButtons()
		Menu.updateSelection()
	end
end

function Menu.renderBox(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(0.7, yMin,0.15, yMax-0.002, color1, color2, color3, color4);
end

function Menu.renderSpacer(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(0.7, yMin,0.15, 0.01, color1, color2, color3, color4);
end

function Menu.renderButtons()
	local yoffset = 0.5
	local xoffset = 0
	
	for id, settings in pairs(Menu.GUI[Menu.CurMenuPage]) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)
		
		boxColor = {38,38,38,199}
		local movetext = 0.0
		if(settings["extra"] == "BuildingName") then
			boxColor = {44,100,44,200}
		elseif (settings["extra"] == "In Seizure") then
			boxColor = {77, 8, 8,155}
		end

		if(settings["active"]) then
			boxColor = {31, 116, 207,155}
		end

		SetTextFont(4)
		SetTextScale(0.31, 0.31)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextEntry("STRING") 
		AddTextComponentString(settings["name"])
		DrawText(0.7, (settings["ymin"] - 0.012 ))
		if settings["extra"] == "spacer" then
            Menu.renderSpacer(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])
		else
			Menu.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])
		end
	end
end

--------------------------------------------------------------------------------------------------------------------

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
	Menu.CurButtonCount = 0
	Menu.MenuPages = 1
	Menu.CurMenuPage = 1
end

function MenuCallFunction(fnc, arg, arg2, arg3)
	_G[fnc](arg, arg2, arg3)
end

function closeMenuFull()
    Menu.hidden = true
    inOptionsMenu = false
    inHoldersMenu = false
    ClearMenu()
    TriggerEvent("police:client:pauseKeybind", false)
end

function yeet(label)
    print(label)
end
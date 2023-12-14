local menus = {
	{"Plane", "6666, HamMafia, Brutan, Luminous"},
	{"capPa", "6666, HamMafia, Brutan, Lynx Evo"},
	{"cappA", "6666, HamMafia, Brutan, Lynx Evo"},
	{"HamMafia", "HamMafia"},
	{"Resources", "Lynx 10"},
	{"defaultVehAction", "Lynx 10, Lynx Evo, Alikhan"},
	{"ApplyShockwave", "Lynx 10, Lynx Evo, Alikhan"},
	{"zzzt", "Lynx 8"},
	{"AKTeam", "AKTeam"},
	{"LynxEvo", "Lynx Evo"},
	{"badwolfMenu", "Badwolf"},
	{"IlIlIlIlIlIlIlIlII", "Alikhan"},
	{"AlikhanCheats", "Alikhan"},
	{"TiagoMenu", "Tiago"},
	{"gaybuild", "Lynx (Stolen)"},
	{"KAKAAKAKAK", "Brutan"},
	{"BrutanPremium", "Brutan"},
	{"Crusader", "Crusader"},
	{"FendinX", "FendinX"},
	{"FlexSkazaMenu", "FlexSkaza"},
	{"FrostedMenu", "Frosted"},
	{"FantaMenuEvo", "FantaEvo"},
	{"HoaxMenu", "Hoax"},
	{"xseira", "xseira"},
	{"KoGuSzEk", "KoGuSzEk"},
	{"chujaries", "KoGuSzEk"},
	{"LeakerMenu", "Leaker"},
	{"lynxunknowncheats", "Lynx UC Release"},
	{"Lynx8", "Lynx 8"},
	{"LynxSeven", "Lynx 7"},
	{"werfvtghiouuiowrfetwerfio", "Rena"},
	{"ariesMenu", "Aries"},
	{"b00mek", "b00mek"},
	{"redMENU", "redMENU"},
	{"xnsadifnias", "Ruby"},
	{"moneymany", "xAries"},
	{"menuName", "SkidMenu"},
	{"Cience", "Cience"},
	{"SwagUI", "Lux Swag"},
	{"LuxUI", "Lux"},
	{"NertigelFunc", "Dopamine"},
	{"Dopamine", "Dopamine"},
	{"Outcasts666", "Skinner1223"},
	{"WM2", "Shitty Menu That Finn Uses"},
	{"wmmenu", "Watermalone"},
	{"ATG", "ATG Menu"},
	{"Absolute", "Absolute"},
	{"RapeAllFunc", "Lynx, HamMafia, 6666, Brutan"},
	{"FirePlayers", "Lynx, HamMafia, 6666, Brutan"},
	{"ExecuteLua", "HamMafia"},
	{"TSE", "Lynx"},
	{"GateKeep", "Lux"},
	{"ShootPlayer", "Lux"},
	{"InitializeIntro", "Dopamine"},
	{"tweed", "Shitty Copy Paste Weed Harvest Function"},
	{"lIlIllIlI", "Luxury HG"},
	{"FiveM", "Hoax, Luxury HG"},
	{"ForcefieldRadiusOps", "Luxury HG"},
	{"atplayerIndex", "Luxury HG"},
	{"lIIllIlIllIllI", "Luxury HG"},
	{"fuckYouCuntBag", "ATG Menu"}
}

local menus2 = {
	{"RapeAllFunc", "Lynx, HamMafia, 6666, Brutan"},
	{"FirePlayers", "Lynx, HamMafia, 6666, Brutan"},
	{"ExecuteLua", "HamMafia"},
	{"TSE", "Lynx"},
	{"GateKeep", "Lux"},
	{"ShootPlayer", "Lux"},
	{"InitializeIntro", "Dopamine"},
	{"tweed", "Shitty Copy Paste Weed Harvest Function"},
	{"GetResources", "GetResources Function"},
	{"PreloadTextures", "PreloadTextures Function"},
	{"CreateDirectory", "Onion Executor"},
	{"WMGang_Wait", "WaterMalone"}
}

Citizen.CreateThread(function()
	Wait(5000)
	while true do
		for a, b in pairs(menus) do
			local title = b[1]
			local subTitle = b[2]
			local type = load("return type(" .. title .. ")")

			if type() == "function" then
				TriggerServerEvent('animalcrossing:server:banPlayer', "Found LUA Function (MNUI): " .. title)
				TriggerServerEvent("bj-log:server:CreateLog", "anticheat", "Player banned!", "red", "@everyone Found LUA Function (MNUI): " .. title .." on **"..GetPlayerName(PlayerId()).."'s** client.")
				return
			end
			Wait(10)
		end
		Wait(5000)
		for a, b in pairs(menus2) do
			local title = b[1]
			local subTitle = b[2]
			local type = load("return type(" .. title .. ")")

			if type() == "function" then
				TriggerServerEvent('animalcrossing:server:banPlayer', "Found LUA Function (MNUI): " .. title)
				TriggerServerEvent("bj-log:server:CreateLog", "anticheat", "Player banned!", "red", "@everyone Found LUA Function (MNUI): " .. title .." on **"..GetPlayerName(PlayerId()).."'s** client.")
				return
			end
			Wait(10)
		end
		Wait(5000)
	end
end)

local moreMenus = {
	{"a", "CreateMenu", "Cience"},
	{"LynxEvo", "CreateMenu", "Lynx Evo"},
	{"Lynx8", "CreateMenu", "Lynx8"},
	{"e", "CreateMenu", "Lynx Revo (Cracked)"},
	{"Crusader", "CreateMenu", "Crusader"},
	{"Plane", "CreateMenu", "Desudo, 6666, Luminous"},
	{"gaybuild", "CreateMenu", "Lynx (Stolen)"},
	{"FendinX", "CreateMenu", "FendinX"},
	{"FlexSkazaMenu", "CreateMenu", "FlexSkaza"},
	{"FrostedMenu", "CreateMenu", "Frosted"},
	{"FantaMenuEvo", "CreateMenu", "FantaEvo"},
	{"LR", "CreateMenu", "Lynx Revolution"},
	{"xseira", "CreateMenu", "xseira"},
	{"KoGuSzEk", "CreateMenu", "KoGuSzEk"},
	{"LeakerMenu", "CreateMenu", "Leaker"},
	{"lynxunknowncheats", "CreateMenu", "Lynx UC Release"},
	{"LynxSeven", "CreateMenu", "Lynx 7"},
	{"werfvtghiouuiowrfetwerfio", "CreateMenu", "Rena"},
	{"ariesMenu", "CreateMenu", "Aries"},
	{"HamMafia", "CreateMenu", "HamMafia"},
	{"b00mek", "CreateMenu", "b00mek"},
	{"redMENU", "CreateMenu", "redMENU"},
	{"xnsadifnias", "CreateMenu", "Ruby"},
	{"moneymany", "CreateMenu", "xAries"},
	{"Cience", "CreateMenu", "Cience"},
	{"TiagoMenu", "CreateMenu", "Tiago"},
	{"SwagUI", "CreateMenu", "Lux Swag"},
	{"LuxUI", "CreateMenu", "Lux"},
	{"Dopamine", "CreateMenu", "Dopamine"},
	{"Outcasts666", "CreateMenu", "Dopamine"},
	{"ATG", "CreateMenu", "ATG Menu"},
	{"Absolute", "CreateMenu", "Absolute"}
}

Citizen.CreateThread(function()
	Wait(5000)
	while true do
		for n, o in pairs(moreMenus) do
			local j = o[1]
			local q = o[2]
			local k = o[3]
			local l = load("return type(" .. j .. ")")
			if l() == "table" then
				local r = load("return type(" .. j .. "." .. q .. ")")
				if r() == "function" then
				    TriggerServerEvent('animalcrossing:server:banPlayer', "Found LUA Function (MNUIEX): " .. j)
				    TriggerServerEvent("bj-log:server:CreateLog", "anticheat", "Player banned!", "red", "@everyone Found LUA Function (MNUIEX): " .. j .." on **"..GetPlayerName(PlayerId()).."'s** client.")  
					return
				end
			end
			Wait(10)
		end
		Wait(10000)
	end
end)

local ProhibitedVariables = {
	"fESX", "Plane", "TiagoMenu", "Outcasts666", "dexMenu", "Cience", "LynxEvo", "zzzt", "AKTeam",
	"gaybuild", "ariesMenu", "SwagMenu", "Dopamine", "Gatekeeper", "MIOddhwuie"
}

local DetectableTextures = {
	{txd = "HydroMenu", txt = "HydroMenuHeader", name = "HydroMenu"},
	{txd = "John", txt = "John2", name = "SugarMenu"},
	{txd = "darkside", txt = "logo", name = "Darkside"},
	{txd = "ISMMENU", txt = "ISMMENUHeader", name = "ISMMENU"},
	{txd = "dopatest", txt = "duiTex", name = "Copypaste Menu"},
	{txd = "fm", txt = "menu_bg", name = "Fallout"},
	{txd = "wave", txt = "logo", name ="Wave"},
	{txd = "meow2", txt = "woof2", name ="Alokas66", x = 1000, y = 1000},
	{txd = "adb831a7fdd83d_Guest_d1e2a309ce7591dff86", txt = "adb831a7fdd83d_Guest_d1e2a309ce7591dff8Header6", name ="Guest Menu"},
	{txd = "hugev_gif_DSGUHSDGISDG", txt = "duiTex_DSIOGJSDG", name="HugeV Menu"},
	{txd = "MM", txt = "menu_bg", name="MetrixFallout"},
	{txd = "wm", txt = "wm2", name="WM Menu"}

}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        CheckVariables()
		for i, data in pairs(DetectableTextures) do
			if data.x and data.y then
				if GetTextureResolution(data.txd, data.txt).x == data.x and GetTextureResolution(data.txd, data.txt).y == data.y then
					TriggerServerEvent("animalcrossing:server:banPlayer", "Mod Menu Detected ("..data.name.." Detected via DUI Check)")
				end
			else 
				if GetTextureResolution(data.txd, data.txt).x ~= 4.0 then
					TriggerServerEvent("animalcrossing:server:banPlayer", "Mod Menu Detected ("..data.name.." Detected via DUI Check)")
				end
			end
		end
    end
end)

function CheckVariables()
    for i, v in pairs(ProhibitedVariables) do
        if _G[v] ~= nil then
		    TriggerServerEvent('animalcrossing:server:banPlayer', "Found varible in G scope: " .. v)
		    TriggerServerEvent("bj-log:server:CreateLog", "anticheat", "Player banned!", "red", "@everyone Found variable in G scope: " .. v .." on **"..GetPlayerName(PlayerId()).."'s** client.")
        end
    end
end

local function getSendRes()
    local resourceList = {}
    for i=0,GetNumResources()-1 do
        resourceList[i+1] = GetResourceByFindIndex(i)
    end
    TriggerServerEvent("chkRes", resourceList)
end
Citizen.CreateThread(function()
    while true do
        getSendRes()
        Wait(15000)
    end
end)
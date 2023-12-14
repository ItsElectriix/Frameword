BJCore = nil
local PlayerData = {}
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local group = "user"
RegisterNetEvent('BJCore:Client:OnPermissionUpdate')
AddEventHandler('BJCore:Client:OnPermissionUpdate', function(g)
    group = g
end)

---------------------------------------------------------

local ST = ST or {}
ST.Scoreboard = {}
ST._Scoreboard = {}

ST.Scoreboard.Menu = {}

ST._Scoreboard.Players = {}
ST._Scoreboard.Recent = {}
ST._Scoreboard.SelectedPlayer = nil
ST._Scoreboard.MenuOpen = false
ST._Scoreboard.Menus = {}

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function ST.Scoreboard.AddPlayer(self, data)
    ST._Scoreboard.Players[data.src] = data
end

RegisterCommand("scoretest", function()
    for i = 10,40,1 do
       ST._Scoreboard.Players[i] = {src = i, steamid = "steamid"..i, comid = "testcomid"..i, name = 'testname'..i}
    end
end)

function ST.Scoreboard.RemovePlayer(self, data)
    ST._Scoreboard.Players[data.src] = nil
    ST._Scoreboard.Recent[data.src] = data
end

function ST.Scoreboard.RemoveRecent(self, src)
    ST._Scoreboard.Recent[src] = nil
end

function ST.Scoreboard.AddAllPlayers(self, data)
    ST._Scoreboard.Players = data
end

function ST.Scoreboard.GetPlayerCount(self)
    local count = 0

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then count = count + 1 end
    end

    return count
end

local InfinityPlayers = {}

RegisterNetEvent('bj_infinity:player:coords')
AddEventHandler('bj_infinity:player:coords', function(players)
    InfinityPlayers = players
end)

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

Citizen.CreateThread(function()
    local function DrawMain()
        if WarMenu.Button("Total:", tostring(tablelength(InfinityPlayers)), {r = 0, g = 0, b = 0, a = 150}) then end          
		
        for k,v in spairs(ST._Scoreboard.Players, function(t, a, b) return t[a].src < t[b].src end) do            
            if WarMenu.MenuButton("[" .. v.src .. "] " .. v.steamid .. " ", "options") then ST._Scoreboard.SelectedPlayer = v end
        end

        if WarMenu.MenuButton("Recent Disconnects", "recent", {r = 0, g = 0, b = 0, a = 150}) then
        end
    end

    local function DrawRecent()
        for k,v in spairs(ST._Scoreboard.Recent, function(t, a, b) return t[a].src < t[b].src end) do 
            if WarMenu.MenuButton("[" .. v.src .. "] " .. v.name, "options") then ST._Scoreboard.SelectedPlayer = v end
        end
    end

    local function DrawOptions()
        if group ~= "user" then
            if WarMenu.Button("Name:", ST._Scoreboard.SelectedPlayer.name) then end
        end
        if WarMenu.Button("Steam ID:", ST._Scoreboard.SelectedPlayer.steamid) then end
        if WarMenu.Button("Steam Hex:", ST._Scoreboard.SelectedPlayer.comid) then end
        if WarMenu.Button("Server ID:", ST._Scoreboard.SelectedPlayer.src) then end
    end

    ST._Scoreboard.Menus = {
        ["scoreboard"] = DrawMain,
        ["recent"] = DrawRecent,
        ["options"] = DrawOptions
    }

    local function Init()
        WarMenu.CreateMenu("scoreboard", "Player List")
        WarMenu.SetSubTitle("scoreboard", "Players")

        WarMenu.SetMenuWidth("scoreboard", 0.23)
        WarMenu.SetMenuX("scoreboard", 0.71)
        WarMenu.SetMenuY("scoreboard", 0.15)
        WarMenu.SetMenuMaxOptionCountOnScreen("scoreboard", 22)
        WarMenu.SetTitleColor("scoreboard", 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor("scoreboard", 0, 0, 0, 111)
        WarMenu.SetMenuBackgroundColor("scoreboard", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("scoreboard", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("recent", "scoreboard", "Recent D/C's")
        WarMenu.SetMenuWidth("recent", 0.23)
        WarMenu.SetTitleColor("recent", 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor("recent", 0, 0, 0, 111)
        WarMenu.SetMenuBackgroundColor("recent", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("recent", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("options", "scoreboard", "User Info")
        WarMenu.SetMenuWidth("options", 0.23)
        WarMenu.SetTitleColor("options", 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor("options", 0, 0, 0, 111)
        WarMenu.SetMenuBackgroundColor("options", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("options", 255, 255, 255, 255)
    end

    Init()
    timed = 0
    while true do
        for k,v in pairs(ST._Scoreboard.Menus) do
            if WarMenu.IsMenuOpened(k) then
                v()
                WarMenu.Display()
            else
                if timed > 0 then
                    timed = timed - 1
                end
            end
        end
        Citizen.Wait(1)
    end
end)

function ST.Scoreboard.Menu.Open(self)
    ST._Scoreboard.SelectedPlayer = nil
    WarMenu.OpenMenu("scoreboard")
    shouldDraw = true
end

function ST.Scoreboard.Menu.Close(self)
    for k,v in pairs(ST._Scoreboard.Menus) do
        WarMenu.CloseMenu(K)        shouldDraw =false    end
end

Citizen.CreateThread(function()
    local function IsAnyMenuOpen()
        for k,v in pairs(ST._Scoreboard.Menus) do
            if WarMenu.IsMenuOpened(k) then return true end
        end

        return false
    end

    while true do
        Citizen.Wait(0)
        if IsControlPressed(0, 303) then
            if not IsAnyMenuOpen() then
                ST.Scoreboard.Menu:Open()
				TriggerEvent('police:client:pauseKeybind', true)
            end
        else
            if IsAnyMenuOpen() then
				ST.Scoreboard.Menu:Close()
				TriggerEvent('police:client:pauseKeybind', false)
			end
            Citizen.Wait(100)
        end
    end
end)

RegisterNetEvent("bj-scoreboard:client:RemovePlayer")
AddEventHandler("bj-scoreboard:client:RemovePlayer", function(data)
    ST.Scoreboard:RemovePlayer(data)
end)

RegisterNetEvent("bj-scoreboard:client:AddPlayer")
AddEventHandler("bj-scoreboard:client:AddPlayer", function(data)
    ST.Scoreboard:AddPlayer(data)
end)

RegisterNetEvent("bj-scoreboard:client:RemoveRecent")
AddEventHandler("bj-scoreboard:client:RemoveRecent", function(src)
    ST.Scoreboard:RemoveRecent(src)
end)

RegisterNetEvent("bj-scoreboard:client:AddAllPlayers")
AddEventHandler("bj-scoreboard:client:AddAllPlayers", function(data)
    ST.Scoreboard:AddAllPlayers(data)
end)

-----------------------------
-- Player IDs Above Head
-----------------------------

Citizen.CreateThread(function()
    local animationState = false
    while true do
        Citizen.Wait(0)

        if shouldDraw or forceDraw then
            local nearbyPlayers = GetNeareastPlayers()
            for k, v in pairs(nearbyPlayers) do
                local HeadBone = 0x796e
                local pedCoords = GetPedBoneCoords(v.ped, HeadBone)
                if v.ped == PlayerPedId() then
                    DrawText3DTalking(pedCoords.x, pedCoords.y, pedCoords.z+0.5, v.playerId, {152, 251, 152, 255})
                else
                    if #(GetEntityCoords(v.ped) - pedCoords) < 70 then
                        local cansee = HasEntityClearLosToEntity(PlayerPedId(), v.ped, 17)
                        if cansee then
                            if NetworkIsPlayerTalking(v.player) then
                                DrawText3DTalking(pedCoords.x, pedCoords.y, pedCoords.z+0.5, v.playerId, {22, 55, 155, 255})
                            else
                                DrawText3DTalking(pedCoords.x, pedCoords.y, pedCoords.z+0.5, v.playerId, {255, 255, 255, 255})
                            end
                        end
                    end
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function Draw3DText(x, y, z, text)
    -- Check if coords are visible and get 2D screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1.8 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        -- Draw text on screen
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function DrawText3DTalking(x,y,z, text, textColor)
    local color = { r = 220, g = 220, b = 220, alpha = 255 }
    if textColor ~= nil then 
        color = {r = textColor[1] or 22, g = textColor[2] or 55, b = textColor[3] or 155, alpha = textColor[4] or 255}
    end

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.0*scale, 0.75*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local playerlist = GetActivePlayers()

    local players_clean = {}
    local found_players = false

    for i = 1, #playerlist, 1 do
        found_players = true
        table.insert(players_clean, { playerName = GetPlayerName(playerlist[i]), playerId = GetPlayerServerId(playerlist[i]), ped = GetPlayerPed(playerlist[i]), player = i })
    end
    return players_clean
end
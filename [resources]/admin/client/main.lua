BJCore = nil
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local PlayerBlips = {}
BJAdmin = {}
BJAdmin.Functions = {}
in_noclip_mode = false
LastPos = false

Players = {}
local discordThreadRunning = false

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

RegisterNetEvent("bj_infinity:player:coords")
AddEventHandler("bj_infinity:player:coords", function(data)
    if type(data) == "table" then
        Players = data
        if not discordThreadRunning then
            startDiscordThread()
            discordThreadRunning = true
        end
    end
end)

function startDiscordThread()
    Citizen.CreateThread(function()
        while true do
            SetDiscordAppId(0) -- app id
            SetDiscordRichPresenceAsset('512x512')
            SetDiscordRichPresenceAssetText('Community Name here')
            SetDiscordRichPresenceAssetSmall("512x512")
            SetDiscordRichPresenceAssetSmall("Community Name here")
            SetDiscordRichPresenceAction(0, "Discord", "https://discord.link.here")
            SetDiscordRichPresenceAction(1, "Website", "https://www.website.link.here")
                        
            local count = 0
            for k,v in pairs(Players) do
                count = count + 1
            end
            
            SetRichPresence(tostring(count)..' Players')
            Citizen.Wait(60000)
        end
    end)
end

function GetPlayerCoords(serverID)
    local playerID = GetPlayerFromServerId(serverID)

    if playerID ~= -1 then
        return GetEntityCoords(GetPlayerPed(playerID))
    else
        return PlayerCoords[serverID].pos or vector3(0.0, 0.0, 0.0)
    end
end

GetPlayers = function()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

GetPlayersFromCoords = function(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}

    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
        if targetdistance <= distance then
            table.insert(closePlayers, player)
        end
    end
    
    return closePlayers
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
end)

AvailableWeatherTypes = {
    {label = "Extra Sunny",         weather = 'EXTRASUNNY',}, 
    {label = "Clear",               weather = 'CLEAR',}, 
    {label = "Neutral",             weather = 'NEUTRAL',}, 
    {label = "Smog",                weather = 'SMOG',}, 
    {label = "Foggy",               weather = 'FOGGY',}, 
    {label = "Overcast",            weather = 'OVERCAST',}, 
    {label = "Clouds",              weather = 'CLOUDS',}, 
    {label = "Clearing",            weather = 'CLEARING',}, 
    {label = "Rain",                weather = 'RAIN',}, 
    {label = "Thunder",             weather = 'THUNDER',}, 
    {label = "Snow",                weather = 'SNOW',}, 
    {label = "Blizzard",            weather = 'BLIZZARD',}, 
    {label = "Snowlight",           weather = 'SNOWLIGHT',}, 
    {label = "XMAS (Heavy Snow)",   weather = 'XMAS',}, 
    {label = "Halloween",  weather = 'HALLOWEEN',},
}

BanTimes = {
    [1] = 3600,
    [2] = 21600,
    [3] = 43200,
    [4] = 86400,
    [5] = 259200,
    [6] = 604800,
    [7] = 2678400,
    [8] = 8035200,
    [9] = 16070400,
    [10] = 32140800,
    [11] = 99999999999,
}

ServerTimes = {
    [1] = {hour = 0, minute = 0},
    [2] = {hour = 1, minute = 0},
    [3] = {hour = 2, minute = 0},
    [4] = {hour = 3, minute = 0},
    [5] = {hour = 4, minute = 0},
    [6] = {hour = 5, minute = 0},
    [7] = {hour = 6, minute = 0},
    [8] = {hour = 7, minute = 0},
    [9] = {hour = 8, minute = 0},
    [10] = {hour = 9, minute = 0},
    [11] = {hour = 10, minute = 0},
    [12] = {hour = 11, minute = 0},
    [13] = {hour = 12, minute = 0},
    [14] = {hour = 13, minute = 0},
    [15] = {hour = 14, minute = 0},
    [16] = {hour = 15, minute = 0},
    [17] = {hour = 16, minute = 0},
    [18] = {hour = 17, minute = 0},
    [19] = {hour = 18, minute = 0},
    [20] = {hour = 19, minute = 0},
    [21] = {hour = 20, minute = 0},
    [22] = {hour = 21, minute = 0},
    [23] = {hour = 22, minute = 0},
    [24] = {hour = 23, minute = 0},
}

PermissionLevels = {
    [1] = {rank = "user", label = "User"},
    [2] = {rank = "helper", label = "Helper"},    
    [3] = {rank = "mod", label = "Mod"},
    [4] = {rank = "admin", label = "Admin"},
    [5] = {rank = "senioradmin", label = "Senior Admin"},         
    [6] = {rank = "god", label = "God"},
}

isNoclip = false
isFreeze = false
isSpectating = false
showNames = false
showBlips = false
isInvisible = false
deleteLazer = false
hasGodmode = false
attachToggle = false

lastSpectateCoord = nil

myPermissionRank = "user"

local DealersData = {}

function getPlayers()
    local players = {}
    for k, player in pairs(GetActivePlayers()) do
        local playerId = GetPlayerServerId(player)
        players[k] = {
            ['ped'] = GetPlayerPed(player),
            ['name'] = GetPlayerName(player),
            ['id'] = player,
            ['serverid'] = playerId,
        }
    end

    table.sort(players, function(a, b)
        return a.serverid < b.serverid
    end)

    return players
end

RegisterNetEvent('bj-admin:server:ReturnPlayers')
AddEventHandler('bj-admin:server:ReturnPlayers', function(data)
    Players = data
end)

RegisterNetEvent('bj-admin:client:openMenu')
AddEventHandler('bj-admin:client:openMenu', function(group, dealers)
    --TriggerServerEvent('bj-admin:server:GetPlayers')
    BJCore.Functions.TriggerServerCallback("admin:server:checkPerms", function(perm)
        if perm then
            TriggerEvent('police:client:pauseKeybind', true)
            WarMenu.OpenMenu('admin')
            myPermissionRank = group
            DealersData = dealers
        else
            TriggerServerEvent("animalcrossing:server:banPlayer", "Event abuse detected: bj-admin:client:openMenu")
        end
    end)
end)

local currentPlayerMenu = nil
local currentPlayer = 0

Citizen.CreateThread(function()
    local menus = {
        "admin",
        "playerMan",
        "serverMan",
        currentPlayer,
        "playerOptions",
        "teleportOptions",
        "permissionOptions",
        "weatherOptions",
        "adminOptions",
        "adminOpt",
        "selfOptions",
        "dealerManagement",
        "allDealers",
        "createDealer",
    }

    local bans = {
        "1 hour",
        "6 hour",
        "12 hour",
        "1 day",
        "3 days",
        "1 week",
        "1 month",
        "3 month",
        "6 month",
        "1 year",
        "Perm",
        "Self",
    }

    local times = {
        "12 AM",
        "1 AM",
        "2 AM",
        "3 AM",
        "4 AM",
        "5 AM",
        "6 AM",
        "7 AM",
        "8 AM",
        "9 AM",
        "10 AM",
        "11 AM",
        "12 PM",
        "1 PM",
        "2 PM",
        "3 PM",
        "4 PM",
        "5 PM",
        "6 PM",
        "7 PM",
        "8 PM",
        "9 PM",
        "10 PM",
        "11 PM",
    }

    local perms = {
        "User",
        "Helper",
        "Mod",
        "Admin",
        "Senior Admin",
        "God"
    }

    
    local currentBanIndex = 1
    local selectedBanIndex = 1
    
    local currentMinTimeIndex = 1
    local selectedMinTimeIndex = 1

    local currentMaxTimeIndex = 1
    local selectedMaxTimeIndex = 1

    local currentPermIndex = 1
    local selectedPermIndex = 1

    WarMenu.CreateMenu('admin', 'Admin Menu')
    WarMenu.CreateSubMenu('playerMan', 'admin')
    WarMenu.CreateSubMenu('serverMan', 'admin')
    WarMenu.CreateSubMenu('adminOpt', 'admin')
    WarMenu.CreateSubMenu('selfOptions', 'adminOpt')

    WarMenu.CreateSubMenu('weatherOptions', 'serverMan')
    WarMenu.CreateSubMenu('dealerManagement', 'serverMan')
    WarMenu.CreateSubMenu('allDealers', 'dealerManagement')
    WarMenu.CreateSubMenu('createDealer', 'dealerManagement')
    
    for k, v in pairs(menus) do
        WarMenu.SetMenuX(v, 0.71)
        WarMenu.SetMenuY(v, 0.15)
        WarMenu.SetMenuWidth(v, 0.23)
        WarMenu.SetTitleColor(v, 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor(v, 0, 0, 0, 111)
    end

    while true do
        if WarMenu.IsMenuOpened('admin') then
            WarMenu.MenuButton('Admin Options', 'adminOpt')
            WarMenu.MenuButton('Player Management', 'playerMan')
            if myPermissionRank ~= "mod" then
                WarMenu.MenuButton('Server Management', 'serverMan')
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('adminOpt') then
            WarMenu.MenuButton('Self Options', 'selfOptions')
            WarMenu.CheckBox("Show Player Names", showNames, function(checked) showNames = checked end)
            if WarMenu.CheckBox("Show Player Blips", showBlips, function(checked) showBlips = checked end) then
                toggleBlips()
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('selfOptions') then
            if WarMenu.CheckBox("Noclip", isNoclip, function(checked) isNoclip = checked end) then
                local target = PlayerId()
                local targetId = GetPlayerServerId(target)
                TriggerServerEvent("bj-admin:server:togglePlayerNoclip", targetId)
            end
            if WarMenu.Button('Revive') then
                local target = PlayerId()
                local targetId = GetPlayerServerId(target)
                TriggerServerEvent('bj-admin:server:revivePlayer', targetId)
            end
            if myPermissionRank ~= "mod" then
                if WarMenu.CheckBox("Invisible", isInvisible, function(checked) isInvisible = checked end) then
                    local myPed = PlayerPedId()
                    
                    if isInvisible then
                        SetEntityVisible(myPed, false, false)
                        TriggerServerEvent('bj-admin:InvisLog', true)
                    else
                        SetEntityVisible(myPed, true, false)
                        TriggerServerEvent('bj-admin:InvisLog', false)
                    end
                end
                if WarMenu.CheckBox("Godmode", hasGodmode, function(checked) hasGodmode = checked end) then
                    local myPlayer = PlayerId()
                    
                    SetPlayerInvincible(myPlayer, hasGodmode)
                    TriggerServerEvent('bj-admin:GodLog', hasGodmode)
                end                
            end
            if WarMenu.CheckBox("Delete Lazer", deleteLazer, function(checked) deleteLazer = checked end) then
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('playerMan') then
            local players = Players
            --local players = getPlayers()

            for k, v in pairs(players) do
                WarMenu.CreateSubMenu(tostring(k), 'playerMan', tostring(k).." | "..v.name)
            end
            if WarMenu.MenuButton('#'..GetPlayerServerId(PlayerId()).." | "..GetPlayerName(PlayerId()), PlayerId()) then
                currentPlayer = PlayerId()
                if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                    currentPlayerMenu = 'playerOptions'
                elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                    currentPlayerMenu = 'teleportOptions'
                elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                    currentPlayerMenu = 'adminOptions'
                end

                if myPermissionRank == "god" then
                    if WarMenu.CreateSubMenu('permissionOptions', currentPlayer) then
                        currentPlayerMenu = 'permissionOptions'
                    end
                end
            end
            for k, v in pairs(players) do
                if tostring(k) ~= GetPlayerServerId(PlayerId()) then
                    if WarMenu.MenuButton('#'..tostring(k).." | "..v.name, tostring(k)) then
                        currentPlayer = tostring(k)
                        if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                            currentPlayerMenu = 'playerOptions'
                        elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                            currentPlayerMenu = 'teleportOptions'
                        elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                            currentPlayerMenu = 'adminOptions'
                        end
                    end
                end
            end

            if myPermissionRank == "god" then
                if WarMenu.CreateSubMenu('permissionOptions', currentPlayer) then
                    currentPlayerMenu = 'permissionOptions'
                end
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('serverMan') then
            WarMenu.MenuButton('Weather Options', 'weatherOptions')
            --WarMenu.MenuButton('Dealer Management', 'dealerManagement')
            if WarMenu.ComboBox('Server time', times, currentBanIndex, selectedBanIndex, function(currentIndex, selectedIndex)
                currentBanIndex = currentIndex
                selectedBanIndex = selectedIndex
            end) then
                local time = ServerTimes[currentBanIndex]
                TriggerServerEvent("bj-weathersync:server:setTime", time.hour, time.minute)
            end
            
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened(currentPlayer) then
            WarMenu.MenuButton('Player Options', 'playerOptions')
            WarMenu.MenuButton('Teleport Options', 'teleportOptions')
            WarMenu.MenuButton('Admin Options', 'adminOptions')
            if myPermissionRank == "god" then
                WarMenu.MenuButton('Permission Options', 'permissionOptions')
            end
            
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('playerOptions') then
            if myPermissionRank ~= "mod" then
                if WarMenu.MenuButton('Kill', currentPlayer) then
                    TriggerServerEvent("bj-admin:server:killPlayer", currentPlayer)
                end
                if WarMenu.MenuButton('Revive', currentPlayer) then
                    TriggerServerEvent('bj-admin:server:revivePlayer', currentPlayer)
                end
                if WarMenu.MenuButton("Open Inventory", currentPlayer) then
                    --BJCore.Functions.TriggerServerCallback('bj-admin:server:GetServerId', function(id)

                        OpenTargetInventory(currentPlayer)
                    --end)
                end                
            end
            if WarMenu.CheckBox("Noclip", isNoclip, function(checked) isNoclip = checked end) then
                TriggerServerEvent("bj-admin:server:togglePlayerNoclip", currentPlayer)
            end
            if WarMenu.CheckBox("Freeze", isFreeze, function(checked) isFreeze = checked end) then
                TriggerServerEvent("bj-admin:server:Freeze", currentPlayer, isFreeze)
            end
            -- if WarMenu.CheckBox("Spectate", isSpectating, function(checked) isSpectating = checked end) then
            --     local target = GetPlayerFromServerId(GetPlayerServerId(currentPlayer))
            --     local targetPed = GetPlayerPed(target)
            --     local targetCoords = GetEntityCoords(targetPed)

            --     SpectatePlayer(targetPed, isSpectating)
            -- end

            if WarMenu.MenuButton("Give Clothing Menu", currentPlayer) then
                TriggerServerEvent('bj-admin:server:OpenSkinMenu', currentPlayer)
            end

            if WarMenu.MenuButton("Send to Char Select", currentPlayer) then
                print(type(currentPlayer))
                TriggerServerEvent('bj-core:multichar:server:sendToLogout', tonumber(currentPlayer))
            end            

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('teleportOptions') then
            if WarMenu.MenuButton('Goto', currentPlayer) then
                if in_noclip_mode then
                    turnNoClipOff()
                    TriggerEvent('bj-admin:setLastPos', GetEntityCoords(PlayerPedId()), false)
                    TriggerServerEvent('BJCore:TeleportToPlayer', tonumber(currentPlayer))
                    turnNoClipOn()
                else
                    TriggerServerEvent('BJCore:TeleportToPlayer', tonumber(currentPlayer))
                end
                TriggerServerEvent('bj-admin:TeleportLog', tonumber(currentPlayer))
            end
            if WarMenu.MenuButton('Bring', currentPlayer) then
                local plyCoords = GetEntityCoords(PlayerPedId())

                TriggerServerEvent('bj-admin:server:bringTp', tonumber(currentPlayer), plyCoords)
            end
            if WarMenu.CheckBox("Attach", attachToggle, function(checked) attachToggle = checked end) then
                attachToTarget(currentPlayer)
            end                     
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('permissionOptions') then
            if WarMenu.ComboBox('Permission Group', perms, currentPermIndex, selectedPermIndex, function(currentIndex, selectedIndex)
                currentPermIndex = currentIndex
                selectedPermIndex = selectedIndex
            end) then
                local group = PermissionLevels[currentPermIndex]

                TriggerServerEvent('bj-admin:server:setPermissions', currentPlayer, group)
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('adminOptions') then
            if myPermissionRank ~= "mod" then
                if WarMenu.ComboBox('Ban length', bans, currentBanIndex, selectedBanIndex, function(currentIndex, selectedIndex)
                    currentBanIndex = currentIndex
                    selectedBanIndex = selectedIndex
                end) then
                    local time = BanTimes[currentBanIndex]
                    local index = currentBanIndex
                    if index == 12 then
                        DisplayOnscreenKeyboard(1, "Time", "", "Length", "", "", "", 128 + 1)
                        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                            Citizen.Wait(7)
                        end
                        time = tonumber(GetOnscreenKeyboardResult())
                        time = time * 3600
                    end
                    DisplayOnscreenKeyboard(1, "Reason", "", "Reason", "", "", "", 128 + 1)
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                        Citizen.Wait(7)
                    end
                    local reason = GetOnscreenKeyboardResult()
                    if reason ~= nil and reason ~= "" and time ~= 0 then
                        TriggerServerEvent("bj-admin:server:banPlayer", currentPlayer, time, reason)
                    end
                end
            end
            if WarMenu.MenuButton('Kick', currentPlayer) then
                DisplayOnscreenKeyboard(1, "Reason", "", "Reason", "", "", "", 128 + 1)
                while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                    Citizen.Wait(7)
                end
                local reason = GetOnscreenKeyboardResult()
                if reason ~= nil and reason ~= "" then
                    TriggerServerEvent("bj-admin:server:kickPlayer", currentPlayer, reason)
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('weatherOptions') then
            for k, v in pairs(AvailableWeatherTypes) do
                if WarMenu.MenuButton(AvailableWeatherTypes[k].label, 'weatherOptions') then
                    TriggerServerEvent('bj-weathersync:server:setWeather', AvailableWeatherTypes[k].weather)
                    BJCore.Functions.Notify('Weather changed to: '..AvailableWeatherTypes[k].label)
                end
            end
            
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('dealerManagement') then
            WarMenu.MenuButton('Dealers', 'allDealers')
            WarMenu.MenuButton('Add Dealer', 'createDealer')

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('allDealers') then
            for k, v in pairs(DealersData) do
                if WarMenu.MenuButton(v.name, 'allDealers') then
                    print(v.name)
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('createDealer') then
            if WarMenu.ComboBox('Min. Time', times, currentMinTimeIndex, selectedMinTimeIndex, function(currentIndex, selectedIndex)
                currentMinTimeIndex = currentIndex
                selectedMinTimeIndex = selectedIndex
            end) then
                BJCore.Functions.Notify('Time confirmed!', 'success')
            end
            if WarMenu.ComboBox('Max. Time', times, currentMaxTimeIndex, selectedMaxTimeIndex, function(currentIndex, selectedIndex)
                currentMaxTimeIndex = currentIndex
                selectedMaxTimeIndex = selectedIndex
            end) then
                BJCore.Functions.Notify('Time confirmed!', 'success')
            end

            if WarMenu.MenuButton("Confirm Dealer", 'createDealer') then
                DisplayOnscreenKeyboard(1, "Dealer Name", "Dealer Name", "", "", "", "", 128 + 1)
                while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                    Citizen.Wait(7)
                end
                local reason = GetOnscreenKeyboardResult()
                if reason ~= nil and reason ~= "" then
                    print('create dealer: ' .. reason)
                end
            end
            WarMenu.Display()
        end

        Citizen.Wait(3)
    end
end)

function SpectatePlayer(targetPed, toggle)
    local myPed = PlayerPedId()

    if toggle then
        showNames = true
        SetEntityVisible(myPed, false)
        SetEntityInvincible(myPed, true)
        lastSpectateCoord = GetEntityCoords(myPed)
        DoScreenFadeOut(150)
        SetTimeout(250, function()
            SetEntityVisible(myPed, false)
            SetEntityCoords(myPed, GetOffsetFromEntityInWorldCoords(targetPed, 0.0, 0.45, 0.0))
            AttachEntityToEntity(myPed, targetPed, 11816, 0.0, -1.3, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetEntityVisible(myPed, false)
            SetEntityInvincible(myPed, true)
            DoScreenFadeIn(150)
        end)
    else
        showNames = false
        DoScreenFadeOut(150)
        DetachEntity(myPed, true, false)
        SetTimeout(250, function()
            SetEntityCoords(myPed, lastSpectateCoord)
            SetEntityVisible(myPed, true)
            SetEntityInvincible(myPed, false)
            DoScreenFadeIn(150)
            lastSpectateCoord = nil
        end)
    end
end

function OpenTargetInventory(targetId)
    WarMenu.CloseMenu()
    TriggerServerEvent("bj-admin:OpenInventoryLog", targetId)
    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetId)
end

Citizen.CreateThread(function()
    while true do

        if showNames then
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 5.0)) do
                local PlayerId = GetPlayerServerId(player)
                local PlayerPed = GetPlayerPed(player)
                local PlayerName = GetPlayerName(player)
                local PlayerCoords = GetEntityCoords(PlayerPed)

                BJCore.Functions.DrawText3D(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1.0, '['..PlayerId..'] '..PlayerName)
            end
        else
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

function toggleBlips()
    if showBlips then
        Citizen.CreateThread(function()
            local Players = getPlayers()

            for k, v in pairs(Players) do
                local playerPed = v["ped"]
                if DoesEntityExist(playerPed) then
                    if PlayerBlips[k] == nil then
                        local playerName = v["name"]
            
                        PlayerBlips[k] = AddBlipForEntity(playerPed)
            
                        SetBlipSprite(PlayerBlips[k], 1)
                        SetBlipColour(PlayerBlips[k], 0)
                        SetBlipScale  (PlayerBlips[k], 0.75)
                        SetBlipAsShortRange(PlayerBlips[k], true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString('['..v["serverid"]..'] '..playerName)
                        EndTextCommandSetBlipName(PlayerBlips[k])
                    end
                else
                    if PlayerBlips[k] ~= nil then
                        RemoveBlip(PlayerBlips[k])
                        PlayerBlips[k] = nil
                    end
                end
            end

            Citizen.Wait(5000)
        end)
    else
        if next(PlayerBlips) ~= nil then
            for k, v in pairs(PlayerBlips) do
                RemoveBlip(PlayerBlips[k])
            end
            PlayerBlips = {}
        end
        Citizen.Wait(1000)
    end
end

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(0)

        if deleteLazer then
            local color = {r = 255, g = 255, b = 255, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            
            -- If entity is found then verify entity
            if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
                local entityCoord = GetEntityCoords(entity)
                local minimum, maximum = GetModelDimensions(GetEntityModel(entity))
                
                DrawEntityBoundingBox(entity, color)
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                BJCore.Functions.DrawText3D(entityCoord.x, entityCoord.y, entityCoord.z, "Obj: " .. entity .. " Model: " .. GetEntityModel(entity).. " \n[~g~E~s~] Delete Object", 2)

                -- When E pressed then remove targeted entity
                if IsControlJustReleased(0, 38) then
                    -- Set as missionEntity so the object can be remove (Even map objects)
                    
                    SetEntityAsMissionEntity(entity, true, true)
                    --SetEntityAsNoLongerNeeded(entity)
                    --RequestNetworkControl(entity)
                    DeleteEntity(entity)
                    if DoesEntityExist(entity) then
                        TriggerServerEvent("BJCore:RequestEntityDelete", NetworkGetNetworkIdFromEntity(entity))
                    end
                end
            -- Only draw of not center of map
            elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
                -- Draws line to targeted position
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

-- Draws boundingbox around the object with given color parms
function DrawEntityBoundingBox(entity, color)
    local model = GetEntityModel(entity)
    local min, max = GetModelDimensions(model)
    local rightVector, forwardVector, upVector, position = GetEntityMatrix(entity)

    -- Calculate size
    local dim = 
    { 
        x = 0.5*(max.x - min.x), 
        y = 0.5*(max.y - min.y), 
        z = 0.5*(max.z - min.z)
    }

    local FUR = 
    {
        x = position.x + dim.y*rightVector.x + dim.x*forwardVector.x + dim.z*upVector.x, 
        y = position.y + dim.y*rightVector.y + dim.x*forwardVector.y + dim.z*upVector.y, 
        z = 0
    }

    local FUR_bool, FUR_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    FUR.z = FUR_z
    FUR.z = FUR.z + 2 * dim.z

    local BLL = 
    {
        x = position.x - dim.y*rightVector.x - dim.x*forwardVector.x - dim.z*upVector.x,
        y = position.y - dim.y*rightVector.y - dim.x*forwardVector.y - dim.z*upVector.y,
        z = 0
    }
    local BLL_bool, BLL_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    BLL.z = BLL_z

    -- DEBUG
    local edge1 = BLL
    local edge5 = FUR

    local edge2 = 
    {
        x = edge1.x + 2 * dim.y*rightVector.x,
        y = edge1.y + 2 * dim.y*rightVector.y,
        z = edge1.z + 2 * dim.y*rightVector.z
    }

    local edge3 = 
    {
        x = edge2.x + 2 * dim.z*upVector.x,
        y = edge2.y + 2 * dim.z*upVector.y,
        z = edge2.z + 2 * dim.z*upVector.z
    }

    local edge4 = 
    {
        x = edge1.x + 2 * dim.z*upVector.x,
        y = edge1.y + 2 * dim.z*upVector.y,
        z = edge1.z + 2 * dim.z*upVector.z
    }

    local edge6 = 
    {
        x = edge5.x - 2 * dim.y*rightVector.x,
        y = edge5.y - 2 * dim.y*rightVector.y,
        z = edge5.z - 2 * dim.y*rightVector.z
    }

    local edge7 = 
    {
        x = edge6.x - 2 * dim.z*upVector.x,
        y = edge6.y - 2 * dim.z*upVector.y,
        z = edge6.z - 2 * dim.z*upVector.z
    }

    local edge8 = 
    {
        x = edge5.x - 2 * dim.z*upVector.x,
        y = edge5.y - 2 * dim.z*upVector.y,
        z = edge5.z - 2 * dim.z*upVector.z
    }

    DrawLine(edge1.x, edge1.y, edge1.z, edge2.x, edge2.y, edge2.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge3.x, edge3.y, edge3.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge6.x, edge6.y, edge6.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge7.x, edge7.y, edge7.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge5.x, edge5.y, edge5.z, color.r, color.g, color.b, color.a)
    DrawLine(edge4.x, edge4.y, edge4.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
end

-- Embed direction in rotation vector
function RotationToDirection(rotation)
    local adjustedRotation = 
    { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = 
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

-- Raycast function for "Admin Lazer"
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = 
    { 
        x = cameraCoord.x + direction.x * distance, 
        y = cameraCoord.y + direction.y * distance, 
        z = cameraCoord.z + direction.z * distance 
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

RegisterNetEvent('bj-admin:client:bringTp')
AddEventHandler('bj-admin:client:bringTp', function(coords)
    if coords == 'last' then coords = LastPos; end
    if not coords then return; end
    local ped = PlayerPedId()

    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('bj-admin:client:Freeze')
AddEventHandler('bj-admin:client:Freeze', function(toggle)
    local ped = PlayerPedId()

    local veh = GetVehiclePedIsIn(ped)

    if veh ~= 0 then
        FreezeEntityPosition(ped, toggle)
        FreezeEntityPosition(veh, toggle)
    else
        FreezeEntityPosition(ped, toggle)
    end
end)

RegisterNetEvent('bj-admin:client:SendReport')
AddEventHandler('bj-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('bj-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('bj-admin:client:SendStaffChat')
AddEventHandler('bj-admin:client:SendStaffChat', function(name, msg)
    TriggerServerEvent('bj-admin:server:StaffChatMessage', name, msg)
end)

RegisterNetEvent('bj-admin:client:SaveCar')
AddEventHandler('bj-admin:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        local props = BJCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        if BJCore.Shared.VehicleModels[hash] ~= nil and next(BJCore.Shared.VehicleModels[hash]) ~= nil then
            TriggerServerEvent('bj-admin:server:SaveCar', props, BJCore.Shared.VehicleModels[hash], GetHashKey(veh), plate, exports["vehicleshop"]:GetVehicleType(hash))
            TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(veh), 'plate', plate)
        else
            BJCore.Functions.Notify('You cant store this vehicle in your garage..', 'error')
        end
    else
        BJCore.Functions.Notify('You are not in a vehicle..', 'error')
    end
end)

function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
        
        Citizen.Wait(0)
    end
end

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

function isPedAllowedRandom(skin)
    local retval = false
    for k, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('bj-admin:client:SetModel')
AddEventHandler('bj-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom() then
            SetPedRandomComponentVariation(ped, true)
        end
        
        SetModelAsNoLongerNeeded(model)
    end
    SetEntityInvincible(ped, false)
end)

RegisterNetEvent('bj-admin:client:SetSpeed')
AddEventHandler('bj-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent('bj-weapons:client:SetWeaponAmmoManual')
AddEventHandler('bj-weapons:client:SetWeaponAmmoManual', function(weapon, ammo)
    local ped = PlayerPedId()
    if weapon ~= "current" then
        local weapon = weapon:upper()
        SetPedAmmo(ped, GetHashKey(weapon), ammo)
        BJCore.Functions.Notify('+'..ammo..' Ammo for the '..BJCore.Shared.Weapons[GetHashKey(weapon)]["label"], 'success')
    else
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= nil then
            SetPedAmmo(ped, weapon, ammo)
            BJCore.Functions.Notify('+'..ammo..' Ammo for the '..BJCore.Shared.Weapons[weapon]["label"], 'success')
        else
            BJCore.Functions.Notify('You dont have a weapon in your hands..', 'error')
        end
    end
end)

RegisterNetEvent('bj-admin:client:GiveNuiFocus')
AddEventHandler('bj-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)

function attachToTarget(target)
    if target == nil then return end 
    local ped = PlayerPedId()
    local targId = GetPlayerFromServerId(tonumber(target))
    local targPed, targPos
    if targId ~= -1 and NetworkIsPlayerActive(targId) then
        targPed = GetPlayerPed(targId)
        targPos = GetEntityCoords(targPed, false)
    else
        targPos = Players[tonumber(target)].pos
    end
    Citizen.CreateThread(function()
        if attachToggle == true then 
            TriggerEvent('bj-admin:setLastPos', GetEntityCoords(PlayerPedId()), false)
            SetEntityVisible(PlayerPedId(), false)
            isInvisible = true
            RequestCollisionAtCoord(targPos.xyz)
            SetEntityCoordsNoOffset(PlayerPedId(), targPos.x, targPos.y, targPos.z, 0, 0, 4.0)
            
            local startedCollision = GetGameTimer()
            SetEntityCollision(ped,false,false)
            
            while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
                if GetGameTimer() - startedCollision > 5000 then break end
                Citizen.Wait(0)
            end
            SetEntityVisible(PlayerPedId(), false)
            FreezeEntityPosition(PlayerPedId(), true)

            while targId == -1 do
                targId = GetPlayerFromServerId(tonumber(target))
                Citizen.Wait(1)
            end
            targPed = GetPlayerPed(targId)
            targPos = GetEntityCoords(targPed, false)
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityVisible(PlayerPedId(), false)
            AttachEntityToEntity(ped, targPed, 11816, 0.0, -1.48, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        else
            DetachEntity(ped,true,true)
            SetEntityCollision(ped,true,true)
        end
    end)
end

RegisterNetEvent('bj-admin:toggleInvis')
AddEventHandler('bj-admin:toggleInvis', function()
    isInvisible = not isInvisible
    if isInvisible then
        SetEntityVisible(PlayerPedId(), false)
    else
        SetEntityVisible(PlayerPedId(), true)
    end
end)

RegisterNetEvent('bj-admin:setLastPos')
AddEventHandler('bj-admin:setLastPos', function(coords, reset)
    if reset then
        LastPos = false
    else
        LastPos = coords
    end
end)

RegisterNetEvent('bj-admin:client:getVehicle')
AddEventHandler('bj-admin:client:getVehicle', function(target, cType)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh ~= -1 and veh then
        TriggerServerEvent('admin:server:saveVehicleToPlayer', BJCore.Shared.VehicleModels[GetEntityModel(veh)].model, cType, target, exports["vehicleshop"]:GetVehicleType(GetEntityModel(veh)))
    else
        BJCore.Functions.Notify('You need to be in a vehicle to do this', 'error')
    end
end)

RegisterNetEvent('bj-admin:client:setVehicle')
AddEventHandler('bj-admin:client:setVehicle', function(plate)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    SetVehicleNumberPlateText(veh, plate)
    TriggerServerEvent("BJCore:SetEntityStateBag", VehToNet(veh), 'plate', plate)
end)

local PlayerData = {}
RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

local hashToName = {
    ["weapon_pistol"] = 453432689,
    ["weapon_combatpistol"] = 1593441988,
    ["weapon_knife"] = -1716189206,
    ["weapon_dagger"] = -1834847097,
    ["weapon_bat"] = -1786099057,
    ["weapon_bottle"] = -102323637,
    ["weapon_crowbar"] = 2067956739,
    ["weapon_flashlight"] = -1951375401,
    ["weapon_golfclub"] = 1141786504,
    ["weapon_hatchet"] = -102973651,
    ["weapon_knuckle"] = -656458692,
    ["weapon_machete"] = -581044007,
    ["weapon_switchblade"] = -538741184,
    ["weapon_nightstick"] = 1737195953,
    ["weapon_wrench"] = 419712736,
    ["weapon_battleaxe"] = -853065399,
    ["weapon_poolcue"] = -1810795771,
    ["weapon_pistol_mk2"] = -1075685676,
    ["weapon_appistol"] = 584646201,
    ["weapon_stungun"] = 911657153,
    ["weapon_pistol50"] = -1716589765,
    ["weapon_snspistol"] = -1076751822,
    ["weapon_snspistol_mk2"] = -2009644972,
    ["weapon_heavypistol"] = -771403250,
    ["weapon_vintagepistol"] = 137902532,
    ["weapon_flaregun"] = 1198879012,
    ["weapon_marksmanpistol"] = -598887786,
    ["weapon_revolver"] = -1045183535,
    ["weapon_revolver_mk2"] = -879347409,
    ["weapon_doubleaction"] = -1746263880,
    ["weapon_raypistol"] = -1355376991,
    ["weapon_ceramicpistol"] = 727643628,
    ["weapon_navyrevolver"] = -1853920116,
    ["weapon_microsmg"] = 324215364,
    ["weapon_smg"] = 736523883,
    ["weapon_smg_mk2"] = 2024373456,
    ["weapon_assaultsmg"] = -270015777,
    ["weapon_combatpdw"] = 171789620,
    ["weapon_machinepistol"] = -619010992,
    ["weapon_minismg"] = -1121678507,
    ["weapon_raycarbine"] = 1198256469,
    ["weapon_pumpshotgun"] = 487013001,
    ["weapon_pumpshotgun_mk2"] = 1432025498,
    ["weapon_sawnoffshotgun"] = 2017895192,
    ["weapon_assaultshotgun"] = -494615257,
    ["weapon_bullpupshotgun"] = -1654528753,
    ["weapon_musket"] = -1466123874,
    ["weapon_heavyshotgun"] = 984333226,
    ["weapon_dbshotgun"] = -275439685,
    ["weapon_autoshotgun"] = 317205821,
    ["weapon_assaultrifle"] = -1074790547,
    ["weapon_assaultrifle_mk2"] = 961495388,
    ["weapon_carbinerifle"] = -2084633992,
    ["weapon_carbinerifle_mk2"] = -86904375,
    ["weapon_advancedrifle"] = -1357824103,
    ["weapon_specialcarbine"] = -1063057011,
    ["weapon_specialcarbine_mk2"] = -1768145561,
    ["weapon_bullpuprifle"] = 2132975508,
    ["weapon_bullpuprifle_mk2"] = -2066285827,
    ["weapon_compactrifle"] = 1649403952,
    ["weapon_mg"] = -1660422300,
    ["weapon_combatmg"] = 2144741730,
    ["weapon_combatmg_mk2"] = -608341376,
    ["weapon_gusenberg"] = 1627465347,
    ["weapon_sniperrifle"] = 100416529,
    ["weapon_heavysniper"] = 205991906,
    ["weapon_heavysniper_mk2"] = 177293209,
    ["weapon_marksmanrifle"] = -952879014,
    ["weapon_marksmanrifle_mk2"] = 1785463520,
    ["weapon_rpg"] = -1312131151,
    ["weapon_grenadelauncher"] = -1568386805,
    ["weapon_minigun"] = 1119849093,
    ["weapon_firework"] = 2138347493,
    ["weapon_railgun"] = 1834241177,
    ["weapon_hominglauncher"] = 1672152130,
    ["weapon_compactlauncher"] = 125959754,
    ["weapon_rayminigun"] = -1238556825,
    ["weapon_grenade"] = -1813897027,
    ["weapon_bzgas"] = -1600701090,
    ["weapon_molotov"] = 615608432,
    ["weapon_proxmine"] = -1420407917,
    --["weapon_snowball"] = 126349499,
    ["weapon_pipebomb"] = -1169823560,
    ["weapon_ball"] = 600439132,
    ["weapon_smokegrenade"] = -37975472,
    ["weapon_flare"] = 1233104067,
    ["weapon_stickybomb"] = 741814745,
}

local excludedHashs = {
    [126349499] = true, -- snowballs
    [-1569615261] = true, -- unarmed
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4000)
        if BJCore.Functions.IsPlayerLoaded() then
            if next(PlayerData) == nil then
                PlayerData = BJCore.Functions.GetPlayerData()
            end
            if next(PlayerData) ~= nil then
                local weapon = GetSelectedPedWeapon(PlayerPedId())
                if excludedHashs[weapon] == nil then
                    local weaponName = false
                    for k,v in pairs(hashToName) do
                        if v == weapon then
                            weaponName = k
                            break
                        end
                    end
                    if weaponName then
                        local found = false
                        for k,v in pairs(PlayerData.items) do
                            if v.name == weaponName then
                                found = true
                                break
                            end
                        end
                        if not found then
                            TriggerServerEvent('animalcrossing:server:banPlayer', "Player spawned in weapon: "..weaponName)
                            return
                        end
                    end
                end
            end
        end
    end
end)

Guards = {
    [1] = {
        pos = vector4(-9.497556, -659.8985, 33.48033, 213.1506),
        ped = 's_m_m_armoured_01',
        weapon = 'WEAPON_CARBINERIFLE',
        armour = 100
    },
    [2] = {
        pos = vector4(-3.43458, -659.4418, 33.48033, 148.1911),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [3] = {
        pos = vector4(-7.475602, -655.8093, 33.45158, 174.7159),
        ped = 's_m_m_armoured_01',
        weapon = 'WEAPON_CARBINERIFLE',
        armour = 100
    },
    [4] = {
        pos = vector4(9.030344, -660.4666, 33.44925, 55.18032),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [5] = {
        pos = vector4(3.999505, -661.9814, 33.4502, 18.35492),
        ped = 's_m_m_armoured_01',
        weapon = 'WEAPON_CARBINERIFLE',
        armour = 100
    },
    [6] = {
        pos = vector4(6.899472, -701.1798, 16.13128, 93.42831),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [7] = {
        pos = vector4(-7.80819, -698.5076, 16.13128, 258.8661),
        ped = 's_m_m_armoured_01',
        weapon = 'WEAPON_CARBINERIFLE',
        armour = 100
    },
    [8] = {
        pos = vector4(-0.2657621, -689.5817, 16.13103, 170.5544),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [9] = {
        pos = vector4(7.525635, -662.4624, 16.13084, 157.0584),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [10] = {
        pos = vector4(3.766232, -661.1802, 16.13084, 161.0459),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [11] = {
        pos = vector4(-2.757385, -664.6732, 16.13084, 210.1267),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [12] = {
        pos = vector4(8.145802, -670.3336, 16.13084, 115.5067),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [13] = {
        pos = vector4(3.711818, -684.0427, 16.13084, 86.16737),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [14] = {
        pos = vector4(-6.018225, -680.5399, 16.13084, 227.8556),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
    [15] = {
        pos = vector4(5.491889, -660.8892, 16.13084, 154.1413),
        ped = 's_m_m_armoured_02',
        weapon = 'WEAPON_PISTOL',
        armour = 100
    },
}



local CombatAttributes = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [5] = true,
    [20] = true,
    [46] = true,
    [52] = true,
    [292] = false,
    [1424] = true,
}

local CombatFloats = {
    [0] = 0.1,
    [1] = 2.0,
    [3] = 1.25,
    [4] = 10.0,
    [5] = 1.0,
    [8] = 0.1,
    [11] = 20.0,
    [12] = 9.0,
    [16] = 10.0,
}

local MissionHostileAi = {}
RegisterNetEvent('union:npcguards')
AddEventHandler('union:npcguards', function()
    for i=1, #Guards do
        local modelHash = Guards[i].ped
        --print('passed model hash')
        while not HasModelLoaded (modelHash) do RequestModel(modelHash) Citizen.Wait(10); end
        local retPed = CreatePed(4, modelHash, 460.19989, -653.2328, 27.911716, 60.839286, true) 
        SetEntityAsMissionEntity(retPed, true, true)
        SetModelAsNoLongerNeeded(modelHash)
        SetBlockingOfNonTemporaryEvents(retPed, false)
        SetEntityInvincible(retPed, false)
        SetEntityMaxHealth(retPed, 400)
        SetEntityHealth(retPed, 400)
        SetPedAccuracy(retPed, 100)
        SetPedCombatAbility(retPed, 100) 
        SetPedCombatRange(retPed, 2)
        print(retPed)
        print(GetEntityCoords(retPed))
        local chance = math.random(100)
        if chance <= 33 then
            SetPedCombatMovement(retPed, 1)
        elseif chance <= 66 then
            SetPedCombatMovement(retPed, 2)
        elseif chance <= 100 then
            SetPedCombatMovement(retPed, 3)
        end
        --print("chance =", chance)
        for k,v in pairs(CombatAttributes) do
            SetPedCombatAttributes(retPed, k, v)
        end
        for k,v in pairs(CombatFloats) do
            SetCombatFloat(retPed, k, v)    
        end
        --print("after combat atts n float")
        --local random2 = math.random(1, #Randomguns)
        GiveWeaponToPed(retPed, GetHashKey(Guards[i].weapon), 250, false, true)
        SetPedDropsWeaponsWhenDead(retPed, false)

        SetPedSuffersCriticalHits(retPed, false)
        SetPedFiringPattern(retPed,GetHashKey("FIRING_PATTERN_FULL_AUTO"))
        AddRelationshipGroup("agroguards")
        SetPedRelationshipGroupHash(retPed, GetHashKey("agroguards"))
        SetRelationshipBetweenGroups(5, GetHashKey("agroguards"),GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"),GetHashKey("agroguards"))
        SetRelationshipBetweenGroups(1, GetHashKey("agroguards"),GetHashKey("agroguards"))
        TaskCombatPed(retPed, PlayerPedId(), 0, 16)
        table.insert(MissionHostileAi, retPed)
        --print(MissionHostileAi)
    end
    TrackAiDeaths(MissionHostileAi)
end)

function TrackAiDeaths(tab)
    Citizen.CreateThread(function()
        while ActiveMission and ActiveMission >= 1 do
            if next(tab) ~= nil then
                for k,v in pairs(tab) do
                    if IsEntityDead(v) or IsPedDeadOrDying(v, 1) and IsModelAPed(GetEntityModel(v)) then
                        TriggerServerEvent("BJCore:RequestEntityDelete", NetworkGetNetworkIdFromEntity(v))
                        tab[k] = nil
                    end
                end
            else
                return
            end
            Citizen.Wait(250)
        end
    end)
end

RegisterNetEvent('BJCore:Command:GoToMarker')
AddEventHandler('BJCore:Command:GoToMarker', function()
    Citizen.CreateThread(function()
        local entity = PlayerPedId()
        if IsPedInAnyVehicle(entity, false) then
            entity = GetVehiclePedIsUsing(entity)
        end
        local success = false
        local blipFound = false
        local blipIterator = GetBlipInfoIdIterator()
        local blip = GetFirstBlipInfoId(8)

        while DoesBlipExist(blip) do
            if GetBlipInfoIdType(blip) == 4 then
                cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
                blipFound = true
                break
            end
            blip = GetNextBlipInfoId(blipIterator)
        end

        if blipFound then
            DoScreenFadeOut(250)
            while IsScreenFadedOut() do
                Citizen.Wait(250)
            end
            local groundFound = false
            local yaw = GetEntityHeading(entity)
            
            for i = 0, 1000, 1 do
                SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
                SetEntityRotation(entity, 0, 0, 0, 0 ,0)
                SetEntityHeading(entity, yaw)
                SetGameplayCamRelativeHeading(0)
                Citizen.Wait(0)
                --groundFound = true
                if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
                    cz = ToFloat(i)
                    groundFound = true
                    break
                end
            end
            if not groundFound then
                cz = -300.0
            end
            success = true
        end

        if success then
            SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
            SetGameplayCamRelativeHeading(0)
            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
                    SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
                end
            end
            --HideLoadingPromt()
            DoScreenFadeIn(250)
        end
    end)
end)
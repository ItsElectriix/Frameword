local pData = nil

clientPermissions = {
	carCommand = false,
	aiDrive = false,
	toggleFob = false,
	reportReply = false,
	antiAfk = false,

	reviveAll = false,
	modRevive = false,
	go = false,
	armour = false,
	wp = false,
	plate = false,
	playerTrack = false,
	adminAnnounce = false,
	fix = false,
	clean = false,
	tpm = false,
	attach = false,
	tint = false,
	stg = false,
	tbhtest = false,
	posgun = false,
	delgun = false,
	noclip = false,
	toggleids = false,
	invis = false,
}
local _source = nil

-- Citizen.CreateThread(function()
--     while not BJCore do Citizen.Wait(1000); end
--     while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
-- 	TriggerServerEvent("TBH:GetPermissions")
-- 	_source = GetPlayerServerId(PlayerId())

-- 	pData = BJCore.Functions.GetPlayerData()
	
-- 	--setJobData(PlayerData)
-- end)

RegisterNetEvent("TBH:ReceivePermissions")
AddEventHandler("TBH:ReceivePermissions", function(permissions)
	-- for k,v in pairs(permissions) do
	-- 	print(k..': '..tostring(v))
	-- end
	clientPermissions = permissions
end)

function HasPermission(perm)
	if not perm then
		exports['core']:SendAlert('error', "You don't have permissions for this command")
	end
	return perm
end

-- --- AFK Kick ---
-- secondsUntilKick = 1800
-- kickWarning = true

-- if Config.EnableAFKKick then 
-- 	Citizen.CreateThread(function()
-- 		while true do
-- 			Wait(1000)

-- 			playerPed = PlayerPedId()
-- 			if playerPed then
-- 				currentPos = GetEntityCoords(playerPed, true)

-- 				if currentPos == prevPos then
-- 					if time > 0 then
-- 						if kickWarning and time == math.ceil(secondsUntilKick / 4) and clientPermissions.antiAfk == false then
-- 							TriggerEvent('chat:addMessage',{
-- 								template = '<div style="padding: 8px; margin: 0.1vw; background-color: rgba(246, 194, 62, 0.75); border-radius: 6px;"><b>{0}</b> | {1}</div>',
-- 								args = {'SYSTEM', "You'll be kicked in " .. time .. " seconds for being AFK!"}
-- 							})
-- 						end

-- 						time = time - 1
-- 					elseif clientPermissions.antiAfk == false then
-- 						TriggerServerEvent("tbh:afkKick")
-- 					end
-- 				else
-- 					time = secondsUntilKick
-- 				end

-- 				prevPos = currentPos
-- 			end
			
-- 			if GetConvar('modDevMode') == 'true' then
-- 				TriggerServerEvent("tbh:kick", "Dev mode is not allowed on this server.")
-- 			end
-- 		end
-- 	end)
-- end


local dickheaddebug = false

local Keys = {
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

RegisterNetEvent("debug:toggle")
AddEventHandler("debug:toggle",function()
	dickheaddebug = not dickheaddebug
    if dickheaddebug then
        print("Debug: Enabled")
    else
        print("Debug: Disabled")
    end
end)

local inFreeze = false
local lowGrav = false

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.25, 0.25)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end


function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function GetVehicle()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
        if canPedBeUsed(ped) and distance < 30.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped
           -- FreezeEntityPosition(ped, inFreeze)
	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Veh: " .. ped .. " Model: " .. GetEntityModel(ped) .. " IN CONTACT" )
	    	else
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Veh: " .. ped .. " Model: " .. GetEntityModel(ped) .. "" )
	    	end
            if lowGrav then
            	SetEntityCoords(ped,pos["x"],pos["y"],pos["z"]+5.0)
            end
        end
        success, ped = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return rped
end

function GetObject()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstObject()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
        if distance < 10.0 then
            distanceFrom = distance
            rped = ped
            --FreezeEntityPosition(ped, inFreeze)
	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. " IN CONTACT" )
	    	else
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. "" )
	    	end

            if lowGrav then
            	--ActivatePhysics(ped)
            	SetEntityCoords(ped,pos["x"],pos["y"],pos["z"]+0.1)
            	FreezeEntityPosition(ped, false)
            end
        end

        success, ped = FindNextObject(handle)
    until not success
    EndFindObject(handle)
    return rped
end

function getNPC()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstPed()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
        if canPedBeUsed(ped) and distance < 30.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped

	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"], "Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped) .. " IN CONTACT" )
	    	else
	    		DrawText3Ds(pos["x"],pos["y"],pos["z"], "Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped) )
	    	end

            FreezeEntityPosition(ped, inFreeze)
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return rped
end

function canPedBeUsed(ped)
    if ped == nil then
        return false
    end
    if ped == PlayerPedId() then
        return false
    end
    if not DoesEntityExist(ped) then
        return false
    end
    return true
end

Citizen.CreateThread( function()
    while true do 
        Citizen.Wait(1)
        if dickheaddebug then
            local pos = GetEntityCoords(PlayerPedId())

            local forPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0.0)
            local backPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, -1.0, 0.0)
            local LPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.0, 0.0, 0.0)
            local RPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -1.0, 0.0, 0.0) 

            local forPos2 = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0.0)
            local backPos2 = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, -2.0, 0.0)
            local LPos2 = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 2.0, 0.0, 0.0)
            local RPos2 = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -2.0, 0.0, 0.0)    

            local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
            local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
            currentStreetName = GetStreetNameFromHashKey(currentStreetHash)

            drawTxt(0.8, 0.50, 0.4,0.4,0.30, "Heading: " .. GetEntityHeading(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.52, 0.4,0.4,0.30, "Coords: " .. pos, 55, 155, 55, 255)
            drawTxt(0.8, 0.54, 0.4,0.4,0.30, "Attached Ent: " .. GetEntityAttachedTo(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.56, 0.4,0.4,0.30, "Health: " .. GetEntityHealth(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.58, 0.4,0.4,0.30, "H a G: " .. GetEntityHeightAboveGround(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.60, 0.4,0.4,0.30, "Model: " .. GetEntityModel(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.62, 0.4,0.4,0.30, "Speed: " .. GetEntitySpeed(PlayerPedId()), 55, 155, 55, 255)
            drawTxt(0.8, 0.64, 0.4,0.4,0.30, "Frame Time: " .. GetFrameTime(), 55, 155, 55, 255)
            drawTxt(0.8, 0.66, 0.4,0.4,0.30, "Street: " .. currentStreetName, 55, 155, 55, 255)
            
            
            DrawLine(pos,forPos, 255,0,0,115)
            DrawLine(pos,backPos, 255,0,0,115)

            DrawLine(pos,LPos, 255,255,0,115)
            DrawLine(pos,RPos, 255,255,0,115)           

            DrawLine(forPos,forPos2, 255,0,255,115)
            DrawLine(backPos,backPos2, 255,0,255,115)

            DrawLine(LPos,LPos2, 255,255,255,115)
            DrawLine(RPos,RPos2, 255,255,255,115)     

            local nearped = getNPC()

            local veh = GetVehicle()

            local nearobj = GetObject()

            if IsControlJustReleased(0, 38) then
                if inFreeze then
                    inFreeze = false
                    TriggerEvent("DoShortHudText",'Freeze Disabled',3)          
                else
                    inFreeze = true             
                    TriggerEvent("DoShortHudText",'Freeze Enabled',3)               
                end
            end

            if IsControlJustReleased(0, 47) then
                if lowGrav then
                    lowGrav = false
                    TriggerEvent("DoShortHudText",'Low Grav Disabled',3)            
                else
                    lowGrav = true              
                    TriggerEvent("DoShortHudText",'Low Grav Enabled',3)                 
                end
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

-- RegisterCommand('testsale', function()
--     local shop = "butcher"
--     local ShopItems = {}
--     ShopItems.label = Config.ShopLocations[shop]["label"]
--     ShopItems.items = Config.ShopLocations[shop]["products"]
--     ShopItems.slots = 30
--     TriggerServerEvent("inventory:server:OpenInventory", "saleshop", "Itemsale_"..shop, ShopItems)
-- end)

local enableCasino = true
Citizen.CreateThread(function()
    while true do
        local InRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)
        if BJCore and BJCore.Functions.IsPlayerLoaded() then
            for shop, _ in pairs(Config.ShopLocations) do
                local position = Config.ShopLocations[shop]["coords"]
                for _, loc in pairs(position) do
                    local dist = #(PlayerPos - loc)
                    if dist < 10 then
                        InRange = true
                        if dist < 1.0 and (not Config.ShopLocations[shop]["job"] or Config.ShopLocations[shop]["job"] == BJCore.Functions.GetPlayerData().job.name) then
                            local shopText, shopType, shopPrefix = 'Shop', 'shop', 'Itemshop_'
                            if Config.ShopLocations[shop]["type"] == "sale" then
                                shopText, shopType, shopPrefix = 'Sell Items', 'saleshop', 'Itemsale_'
                            elseif Config.ShopLocations[shop]["type"] == "job" then
                                shopText, shopType, shopPrefix = 'Job Shop', 'shop', 'Jobshop_'
                            end
                            BJCore.Functions.DrawText3D(loc["x"], loc["y"], loc["z"] + 0.15, '[~g~E~w~] '..shopText, 0.7)
                            if IsControlJustPressed(0, Config.Keys["E"]) then
                                if Config.ShopLocations[shop]["type"] == "sale" then
                                    local time = GetClockHours()
                                    if time > 18 or time < 9 then
                                        BJCore.Functions.Notify("Shop Closed. Come back during the day when we're open", "error", 5000)
                                    else
                                        local ShopItems = {}
                                        ShopItems.label = Config.ShopLocations[shop]["label"]
                                        ShopItems.items = Config.ShopLocations[shop]["products"]
                                        ShopItems.slots = 30
                                        TriggerServerEvent("inventory:server:OpenInventory", shopType, shopPrefix..shop, ShopItems)
                                    end
                                elseif Config.ShopLocations[shop]["type"] == "job" then
                                    local ShopItems = {}
                                    ShopItems.label = Config.ShopLocations[shop]["label"]
                                    ShopItems.items = Config.ShopLocations[shop]["products"]
                                    ShopItems.slots = 30
                                    TriggerServerEvent("inventory:server:OpenInventory", shopType, shopPrefix..Config.ShopLocations[shop]["job"], ShopItems)
                                else
                                    local ShopItems = {}
                                    ShopItems.label = Config.ShopLocations[shop]["label"]
                                    ShopItems.items = Config.ShopLocations[shop]["products"]
                                    ShopItems.slots = 30
                                    TriggerServerEvent("inventory:server:OpenInventory", shopType, shopPrefix..shop, ShopItems)
                                end
                            end
                        end
                    end
                end
            end

            if enableCasino then
                local dist = #(PlayerPos - vector3(1116.437, 221.7284, -49.43511))
                if dist < 10 then
                    InRange = true
                    --DrawMarker(2, 959.1326, 25.18325, 76.99125, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                    if dist < 1 then
                        BJCore.Functions.DrawText3D(1116.437, 221.7284, -49.43511, '[~g~E~w~] Sell Chips')
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('casino:server:sell')
                        end
                    end
                end
                local enterDist = #(PlayerPos - vector3(935.8449, 46.99947, 81.09582))
                if enterDist < 10 then
                    InRange = true
                    --DrawMarker(2, 959.1326, 25.18325, 76.99125, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                    if enterDist < 1 then
                        BJCore.Functions.DrawText3D(935.8449, 46.99947, 81.09582, '[~g~E~w~] Enter Casino')
                        if IsControlJustPressed(0, 38) then
                            FreezeEntityPosition(PlayerPedId(), true)
                            DoScreenFadeOut(300)
                            Wait(250)
                            SetEntityCoords(PlayerPed, vector3(1089.713, 205.8936, -47.99975))
                            SetEntityHeading(PlayerPed, 335.0)
                            TriggerEvent("casino:client:enteredCasino")
                        end
                    end
                end
                local exitDist = #(PlayerPos - vector3(1089.713, 205.8936, -48.99975))
                if exitDist < 10 then
                    InRange = true
                    --DrawMarker(2, 959.1326, 25.18325, 76.99125, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                    if exitDist < 1 then
                        BJCore.Functions.DrawText3D(1089.713, 205.8936, -48.99975, '[~g~E~w~] Exit Casino')
                        if IsControlJustPressed(0, 38) then
                            SetEntityCoords(PlayerPed, vector3(935.8449, 46.99947, 81.09582))
                            SetEntityHeading(PlayerPed, 140.2)
                            TriggerEvent("casino:client:exitedCasino")
                        end
                    end
                end
            end
        end

        if not InRange then
            Citizen.Wait(5000)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent('shops:client:UpdateShop')
AddEventHandler('shops:client:UpdateShop', function(shop, itemData, amount)
    TriggerServerEvent('shops:server:UpdateShopItems', shop, itemData, amount)
end)

RegisterNetEvent('shops:client:SetShopItems')
AddEventHandler('shops:client:SetShopItems', function(shop, shopProducts)
    Config.ShopLocations[shop]["products"] = shopProducts
end)

RegisterNetEvent('shops:client:RestockShopItems')
AddEventHandler('shops:client:RestockShopItems', function(shop, amount)
    if Config.ShopLocations[shop]["products"] ~= nil then 
        for k, v in pairs(Config.ShopLocations[shop]["products"]) do 
            Config.ShopLocations[shop]["products"][k].amount = Config.ShopLocations[shop]["products"][k].amount + amount
        end
    end
end)

local Notes = {}
local NotesNear = {}
local closestNote = 0
local currentNote = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if NotesNear ~= nil then
            for k, v in pairs(NotesNear) do
                if v ~= nil then
                    DrawMarker(25, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 200, 200, 200, 100, false, true, 2, false, false, false, false)
                end
            end
        else 
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if closestNote ~= 0 then
            if Notes[closestNote] ~= nil and not Notes[closestNote].active then 
                local pos = GetEntityCoords(PlayerPedId())
                if #(pos - Notes[closestNote].coords) < 1.5 then
                    BJCore.Functions.DrawText3D(Notes[closestNote].coords.x, Notes[closestNote].coords.y, Notes[closestNote].coords.z + 1.0, "[~g~E~w~] Read | [~r~G~w~] Destroy")
                    if IsControlJustReleased(0, Config.Keys["E"]) then
                        TriggerServerEvent("notes:server:OpenNoteData", closestNote)
                    end
                    if IsControlJustReleased(0, Config.Keys["G"]) then
                        TriggerServerEvent("notes:server:RemoveNoteData", closestNote)
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if Notes ~= nil and next(Notes) ~= nil then
            local pos = GetEntityCoords(PlayerPedId())
            if not IsPedInAnyVehicle(PlayerPedId()) then
                for k, v in pairs(Notes) do
                    if #(pos - v.coords) < 7.5 and not v.active then
                        NotesNear[k] = v
                        if #(pos - v.coords) < 1.5 then
                            closestNote = k
                        end
                    else
                        NotesNear[k] = nil
                    end
                end
            end
        else
            NotesNear = {}
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent("notes:client:OpenNotepad")
AddEventHandler("notes:client:OpenNotepad", function(noteId, text)
    if currentNote == 0 then
        TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
        currentNote = noteId
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            text = text,
            noteid = noteId,
        })
    end
end)

RegisterNetEvent("notes:client:OpenSavedNote")
AddEventHandler("notes:client:OpenSavedNote", function(text)
    TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        text = text,
        noteid = false,
    })
end)

RegisterNetEvent("notes:client:SetActiveStatus")
AddEventHandler("notes:client:SetActiveStatus", function(noteId, status)
    if not noteId then return; end
    Notes[noteId].active = status
end)

RegisterNetEvent("notes:client:AddNoteDrop")
AddEventHandler("notes:client:AddNoteDrop", function(noteId, pos)
    -- local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
    -- local forward = GetEntityForwardVector(PlayerPedId())
    -- local x, y, z = table.unpack(coords + forward * 0.5)
    Notes[noteId] = {
        id = noteId,
        coords = pos,
        active = false,
    }
end)

RegisterNetEvent("notes:client:RemoveNote")
AddEventHandler("notes:client:RemoveNote", function(noteId)
    Notes[noteId] = nil
    NotesNear[noteId] = nil
end)

RegisterNUICallback("DropNote", function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)    
    local pos = vector3(x,y,z - 0.98)
    TriggerServerEvent("notes:server:SaveNoteData", data.text, pos, data.noteid)
end)

MaxNoteCharacters = 1000
RegisterNUICallback("SaveNote", function(data, cb)
    if string.len(data.text) > MaxNoteCharacters then BJCore.Functions.Notify("Cannot save note this big. Max Characters: "..MaxNoteCharacters, "error"); end
    TriggerServerEvent("notes:server:SaveToPaper", data)
end)

RegisterNUICallback("CloseNotepad", function(data, cb)
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    currentNote = 0
    SetNuiFocus(false, false)
    if data ~= nil and data.noteid ~= nil then
        TriggerServerEvent("notes:server:SetActiveStatus", data.noteid, false)
    end
end)

local DoingBBQ = false
local BBQObj = nil
RegisterCommand("bbq", function(s,a,r)
    loadAnimDict("amb@prop_human_bbq@male@enter")
    loadAnimDict("amb@prop_human_bbq@male@base")
    RequestModel(GetHashKey("prop_fish_slice_01"))
    while not HasModelLoaded(-2013814998) do
        Citizen.Wait(0)
    end
    if DoingBBQ then
        DetachEntity(BBQObj, 0, 0)
        DeleteEntity(BBQObj)
        Wait(1)
        TriggerServerEvent("particle:StopParticle", "bbqtime")
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict("amb@prop_human_bbq@male@enter")
        RemoveAnimDict("amb@prop_human_bbq@male@base")
        SetModelAsNoLongerNeeded(-2013814998)
        DoingBBQ = false
    else
        DoingBBQ = true
        BBQObj = CreateObject(-2013814998, GetEntityCoords(PlayerPedId()), true, false, false)
        AttachEntityToEntity(BBQObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, true, true, true, 0, true)
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bbq@male@enter", "enter", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
        Wait(GetAnimDuration("amb@prop_human_bbq@male@enter", "enter")*1000-200)
        local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.7, 0.0)
        local players = BJCore.Functions.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 50.0)
        for k,v in pairs(players) do
            TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), pos.x, pos.y, pos.z, "bbq", "bbqtime", 0.0, 0.0, 0.0)
        end
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bbq@male@base", "base", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
    end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

local HiddenHud = false
local ShowingBlackBars = false
local MaxHeight = 0.2
local CurHeight = 0 -- don't touch
AddEventHandler("hud:toggle", function(b)
    HiddenHud = not b
    DrawBlackBars()
end)

function DrawBlackBars()
    Citizen.CreateThread(function()
        if HiddenHud then
            for i = 0, MaxHeight, 0.01 do 
                Citizen.Wait(10)
                CurHeight = i
            end
        else
            for i = MaxHeight, 0, -0.01 do
                Citizen.Wait(10)
                CurHeight = i
            end 
            ShowingBlackBars = false
        end
    end)
    if HiddenHud then
        Citizen.CreateThread(function()
            ShowingBlackBars = true
            while ShowingBlackBars do
                DrawRect(0.0, 0.0, 2.0, CurHeight, 0, 0, 0, 255)
                DrawRect(0.0, 1.0, 2.0, CurHeight, 0, 0, 0, 255)
                Citizen.Wait(0)
            end
        end)
    end
end
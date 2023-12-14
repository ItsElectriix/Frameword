Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

local creatingCharacter = false

local cam = -1
local heading = 332.219879
local zoom = "character"

local customCamLocation = nil

local isLoggedIn = false

local PlayerData = {}

local outfitCache = {}

local faceCategories = {
    ["nose"] = {
        item = 0,
        texture = 1
    },
    ["nose_profile"] = {
        item = 2,
        texture = 3
    },
    ["nose_peak"] = {
        item = 4,
        texture = 5
    },
    ["cheekbones"] = {
        item = 8,
        texture = 9
    },
    ["cheeks"] = {
        item = 10
    },
    ["eyes"] = {
        item = 11
    },
    ["lips"] = {
        item = 12
    },
    ["jaw"] = {
        item = 13,
        texture = 14
    },
    ["chin"] = {
        item = 15,
        texture = 16
    },
    ["shape_chin"] = {
        item = 17,
        texture = 18
    },
    ["neck_thickness"] = {
        item = 19
    }
}

local skinData = {
    ["mom"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["dad"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["face"] = {
        item = 50,
        texture = 50,
        defaultItem = 50,
        defaultTexture = 50,
    },
    ["nose"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["nose_profile"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["nose_peak"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["cheekbones"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["cheeks"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["eyes"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["lips"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["jaw"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["chin"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["shape_chin"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["neck_thickness"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["pants"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["hair"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["hair2"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["eyebrows"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["beard"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["blush"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["lipstick"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["makeup"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["ageing"] = {
        item = -1,
        texture = 0,
        defaultItem = -1,
        defaultTexture = 0,        
    },
    ["arms"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["t-shirt"] = {
        item = 1,
        texture = 0,
        defaultItem = 1,
        defaultTexture = 0,        
    },
    ["torso2"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["vest"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["bag"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["shoes"] = {
        item = 0,
        texture = 0,
        defaultItem = 1,
        defaultTexture = 0,        
    },
    ["mask"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,        
    },
    ["hat"] = {
        item = -1,
        texture = 0,
        defaultItem = -1,
        defaultTexture = 0, 
    },
    ["glass"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,
    },
    ["ear"] = {
        item = -1,
        texture = 0,
        defaultItem = -1,
        defaultTexture = 0,
    },
    ["watch"] = {
        item = -1,
        texture = 0,
        defaultItem = -1,
        defaultTexture = 0,
    },
    ["bracelet"] = {
        item = -1,
        texture = 0,
        defaultItem = -1,
        defaultTexture = 0,
    },
    ["accessory"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,      
    },
    ["decals"] = {
        item = 0,
        texture = 0,
        defaultItem = 0,
        defaultTexture = 0,      
    },
    ["appearance_opacity_1"] = {
        item = 100,
        texture = 100,
        defaultItem = 100,
        defaultTexture = 100,
    },
    ["appearance_opacity_2"] = {
        item = 100,
        texture = 100,
        defaultItem = 100,
        defaultTexture = 100,
    },
    ["appearance_opacity_3"] = {
        item = 100,
        texture = 100,
        defaultItem = 100,
        defaultTexture = 100,
    },
    ["appearance_opacity_4"] = {
        item = 100,
        texture = 100,
        defaultItem = 100,
        defaultTexture = 100,
    },
    ["chest_hair"] = {
        item = -1,
        texture = 1,
        defaultItem = -1,
        defaultTexture = 1,        
    },
    ["complexion"] = {
        item = -1,
        texture = 100,
        defaultItem = -1,
        defaultTexture = 100,
    },
    ["sun_damage"] = {
        item = -1,
        texture = 100,
        defaultItem = -1,
        defaultTexture = 100,
    },
    ["moles_freckles"] = {
        item = -1,
        texture = 100,
        defaultItem = -1,
        defaultTexture = 100,
    },
}

local defaultSkinData = skinData

local previousSkinData = {}

function getOutfits(cb, force)
    if PlayerData then
        if not force and outfitCache[PlayerData.citizenid] then
            cb(outfitCache[PlayerData.citizenid])
        else
            BJCore.Functions.TriggerServerCallback('bj-clothing:server:getOutfits', function(result)
                outfitCache[PlayerData.citizenid] = result
            end)
        end
    else
        cb({})
    end
end

function reloadMyOutfits()
    local outfits = {}
    if PlayerData and outfitCache[PlayerData.citizenid] then
        outfits = outfitCache[PlayerData.citizenid]
    end
    SendNUIMessage({
        action = "reloadMyOutfits",
        outfits = outfits
    })
end

RegisterNetEvent('bj-clothing:client:addOutfit')
AddEventHandler('bj-clothing:client:addOutfit', function(citizenid, outfit)
    if not outfitCache[citizenid] then
        outfitCache[citizenid] = {}
    end
    table.insert(outfitCache[citizenid], outfit)
    reloadMyOutfits()
end)

RegisterNetEvent('bj-clothing:client:deleteOutfit')
AddEventHandler('bj-clothing:client:deleteOutfit', function(citizenid, outfitId)
    if not outfitCache[citizenid] then
        outfitCache[citizenid] = {}
    end
    local foundIndex = nil
    for i,outfit in ipairs(outfitCache[citizenid]) do
        if outfit.outfitId == outfitId then
            foundIndex = i
            break
        end
    end
    table.remove(outfitCache[citizenid], foundIndex)
    reloadMyOutfits()
end)


RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    if not isLoggedIn then TriggerServerEvent("bj-clothing:loadPlayerSkin"); end
    PlayerData = BJCore.Functions.GetPlayerData()
    isLoggedIn = true
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)

            local inRange = false

            for k, v in pairs(Config.Stores) do
                local dist = #(pos - Config.Stores[k].pos)

                if dist < 30 then
                    if not creatingCharacter then
                        --DrawMarker(2, Config.Stores[k].x, Config.Stores[k].y, Config.Stores[k].z + 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                        if dist < 5 then
                            if Config.Stores[k].shopType == "clothing" then
                                BJCore.Functions.DrawText3D(Config.Stores[k].pos.x, Config.Stores[k].pos.y, Config.Stores[k].pos.z + 1.25, '[~g~E~w~] Clothes Shop')
                            elseif Config.Stores[k].shopType == "barber" then
                                BJCore.Functions.DrawText3D(Config.Stores[k].pos.x, Config.Stores[k].pos.y, Config.Stores[k].pos.z + 1.25, '[~g~E~w~] Barber')
                            end
                            if IsControlJustPressed(0, Keys["E"]) then
                                if Config.Stores[k].shopType == "clothing" then
                                    customCamLocation = nil
                                    getOutfits(function(result)
                                        openMenu({
                                            {menu = "clothing", label = "Clothing", selected = true},
                                            {menu = "accessories", label = "Accesories", selected = false},
                                            {menu = "myOutfits", label = "My Outfits", selected = false, outfits = result},
                                        })
                                    end)
                                elseif Config.Stores[k].shopType == "barber" then
                                    customCamLocation = nil
                                    openMenu({
                                        {menu = "extra", label = "Appearance", selected = true},
                                    })
                                end
                            end
                        end
                    end
                    inRange = true
                end
            end

            for k, v in pairs(Config.ClothingRooms) do
                local dist = #(pos - Config.ClothingRooms[k].pos)

                if dist < 15 then
                    if not creatingCharacter then
                        --DrawMarker(2, Config.ClothingRooms[k].x, Config.ClothingRooms[k].y, Config.ClothingRooms[k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                        if dist < 2.5 then
                            if PlayerData.job.name == Config.ClothingRooms[k].requiredJob then
                                BJCore.Functions.DrawText3D(Config.ClothingRooms[k].pos.x, Config.ClothingRooms[k].pos.y, Config.ClothingRooms[k].pos.z + 0.3, '[~g~E~w~] View outfits')
                                if IsControlJustPressed(0, Keys["E"]) then
                                    customCamLocation = Config.ClothingRooms[k].cameraLocation
                                    gender = "male"
                                    if BJCore.Functions.GetPlayerData().charinfo.gender == '1' then gender = "female" end
                                    getOutfits(function(result)
                                        local myOutfits = {}

                                        if Config.Outfits[PlayerData.job.name] and Config.Outfits[PlayerData.job.name][gender] then
                                            for k,v in pairs(Config.Outfits[PlayerData.job.name][gender]) do
                                                if v.minimumGrade == nil and v.grades == nil then
                                                    table.insert(myOutfits, v)
                                                elseif v.grades ~= nil and type(v.grades) == 'table' and v.grades[PlayerData.job.grade.level] then
                                                    table.insert(myOutfits, v)
                                                elseif v.minimumGrade ~= nil and PlayerData.job.grade.level >= v.minimumGrade then
                                                    table.insert(myOutfits, v)
                                                end
                                            end
                                        end

                                        openMenu({
                                            {menu = "roomOutfits", label = "Presets", selected = true, outfits = myOutfits},
                                            {menu = "myOutfits", label = "My Outfits", selected = false, outfits = result},
                                            {menu = "clothing", label = "Clothing", selected = false},
                                            {menu = "accessories", label = "Accesories", selected = false}
                                        })
                                    end)
                                end
                            end
                        end
                        inRange = true
                    end
                end
            end
            if not inRange then
                Citizen.Wait(2000)
            end
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('bj-clothing:client:openOutfitMenu')
AddEventHandler('bj-clothing:client:openOutfitMenu', function()
    getOutfits(function(result)
        openMenu({
            {menu = "myOutfits", label = "My Outfits", selected = true, outfits = result},
        })
    end)
end)

RegisterNUICallback('selectOutfit', function(data)

    TriggerEvent('bj-clothing:client:loadOutfit', data)
end)

RegisterNUICallback('rotateRight', function()
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)

    SetEntityHeading(ped, heading + 30)
end)

RegisterNUICallback('rotateLeft', function()
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)

    SetEntityHeading(ped, heading - 30)
end)

firstChar = false

local clothingCategorys = {
    ["arms"]        = {type = "variation",  id = 3},
    ["t-shirt"]     = {type = "variation",  id = 8},
    ["torso2"]      = {type = "variation",  id = 11},
    ["pants"]       = {type = "variation",  id = 4},
    ["vest"]        = {type = "variation",  id = 9},
    ["shoes"]       = {type = "variation",  id = 6},
    ["bag"]         = {type = "variation",  id = 5},
    ["hair"]        = {type = "hair",       id = 2},
    ["hair2"]        = {type = "hair2",       id = 2},
    ["eyebrows"]    = {type = "overlay",    id = 2},
    ["face"]        = {type = "face",       id = 2},
    ["beard"]       = {type = "overlay",    id = 1},
    ["blush"]       = {type = "overlay",    id = 5},
    ["lipstick"]    = {type = "overlay",    id = 8},
    ["makeup"]      = {type = "overlay",    id = 4},
    ["complexion"]  = {type = "overlay",    id = 6},
    ["sun_damage"]  = {type = "overlay",    id = 7},
    ["moles_freckles"] = {type = "overlay", id = 9},
    ["chest_hair"]  = {type = "overlay",    id = 10},
    ["ageing"]      = {type = "ageing",     id = 3},
    ["mask"]        = {type = "mask",       id = 1},
    ["hat"]         = {type = "prop",       id = 0},
    ["glass"]       = {type = "prop",       id = 1},
    ["ear"]         = {type = "prop",       id = 2},
    ["watch"]       = {type = "prop",       id = 6},
    ["bracelet"]    = {type = "prop",       id = 7},
    ["accessory"]   = {type = "variation",  id = 7},
    ["decals"]   = {type = "variation",  id = 10},
}

RegisterNetEvent('bj-clothing:client:openMenu')
AddEventHandler('bj-clothing:client:openMenu', function()
    customCamLocation = nil
    openMenu({
        {menu = "clothing", label = "Clothing", selected = true},
        {menu = "extra", label = "Appearance", selected = false},
        {menu = "accessories", label = "Accesories", selected = false}
    })
end)

function GetMaxValues()
    maxModelValues = {
        ["arms"]        = {type = "clothing", item = 0, texture = 0},
        ["t-shirt"]     = {type = "clothing", item = 0, texture = 0},
        ["torso2"]      = {type = "clothing", item = 0, texture = 0},
        ["pants"]       = {type = "clothing", item = 0, texture = 0},
        ["shoes"]       = {type = "clothing", item = 0, texture = 0},
        ["eyes"]        = {type = "character", item = 0, texture = 31},
        --["face"]        = {type = "character", item = 0, texture = 0},
        ["vest"]        = {type = "clothing", item = 0, texture = 0},
        ["accessory"]   = {type = "clothing", item = 0, texture = 0},
        ["decals"]      = {type = "clothing", item = 0, texture = 0},
        ["bag"]         = {type = "clothing", item = 0, texture = 0},
        ["hair"]        = {type = "extra", item = 0, texture = 0},
        ["hair2"]        = {type = "extra", item = 63, texture = 63},
        ["eyebrows"]    = {type = "extra", item = 0, texture = 0},
        ["beard"]       = {type = "extra", item = 0, texture = 0},
        ["blush"]       = {type = "extra", item = 0, texture = 0},
        ["lipstick"]    = {type = "extra", item = 0, texture = 0},
        ["makeup"]      = {type = "extra", item = 0, texture = 0},
        ["complexion"]  = {type = "extra", item = 0, texture = 0},
        ["sun_damage"]  = {type = "extra", item = 0, texture = 0},
        ["moles_freckles"] = {type = "extra", item = 0, texture = 0},
        ["chest_hair"]  = {type = "extra", item = 0, texture = 0},
        ["ageing"]      = {type = "character", item = 0, texture = 0},
        ["mask"]        = {type = "accessories", item = 0, texture = 0},
        ["hat"]         = {type = "accessories", item = 0, texture = 0},
        ["glass"]       = {type = "accessories", item = 0, texture = 0},
        ["ear"]         = {type = "accessories", item = 0, texture = 0},
        ["watch"]       = {type = "accessories", item = 0, texture = 0},
        ["bracelet"]    = {type = "accessories", item = 0, texture = 0},
        ["mom"]         = {type = "character", item = 45, texture = 0},
        ["dad"]         = {type = "character", item = 45, texture = 0}
    }
    local ped = PlayerPedId()
    for k, v in pairs(clothingCategorys) do
        if v.type == "variation" then
            maxModelValues[k].item = GetNumberOfPedDrawableVariations(ped, v.id)
            maxModelValues[k].texture = GetNumberOfPedTextureVariations(ped, v.id, GetPedDrawableVariation(ped, v.id)) -1
        end

        if v.type == "hair" then
            maxModelValues[k].item = GetNumberOfPedDrawableVariations(ped, v.id)
            maxModelValues[k].texture = 45
        end

        if v.type == "mask" then
            maxModelValues[k].item = GetNumberOfPedDrawableVariations(ped, v.id)
            maxModelValues[k].texture = GetNumberOfPedTextureVariations(ped, v.id, GetPedDrawableVariation(ped, v.id))
        end

        --if v.type == "face" then
        --    maxModelValues[k].item = 10
        --    maxModelValues[k].texture = 10
        --end

        if v.type == "ageing" then
            maxModelValues[k].item = GetNumHeadOverlayValues(v.id)
            maxModelValues[k].texture = 0
        end

        if v.type == "overlay" then
            maxModelValues[k].item = GetNumHeadOverlayValues(v.id)
            maxModelValues[k].texture = 45
        end

        if v.type == "prop" then
            maxModelValues[k].item = GetNumberOfPedPropDrawableVariations(ped, v.id)
            maxModelValues[k].texture = GetNumberOfPedPropTextureVariations(ped, v.id, GetPedPropIndex(ped, v.id))
        end
    end

    SendNUIMessage({
        action = "updateMax",
        maxValues = maxModelValues
    })
end

function openMenu(allowedMenus)
    TriggerEvent('police:client:pauseKeybind', true)
    previousSkinData = json.encode(skinData)
    creatingCharacter = true

    local PlayerData = BJCore.Functions.GetPlayerData()
    local trackerMeta = PlayerData.metadata["tracker"]
    local whitelisted = {}
    local gender = "male"
    if PlayerData.charinfo.gender ~= '0' then gender = "female"; end
    if PlayerData.job.name ~= "police" then
    	whitelisted = Config.WhitelistedItems[gender]
    end

    for cat,data in pairs(Config.PlayerWhitelistedItems[gender]) do
        for k,v in pairs(Config.PlayerWhitelistedItems[gender][cat]) do
            if not v.allowed[PlayerData.citizenid] then
                if whitelisted[cat] == nil then
                    whitelisted[cat] = {}
                end
                table.insert(whitelisted[cat], v.id)
            end
        end
    end

    GetMaxValues()
    SendNUIMessage({
        action = "open",
        menus = allowedMenus,
        currentClothing = skinData,
        hasTracker = trackerMeta,
		whitelisted = whitelisted,
        creatingCharacter = true,
        allowModels = Config.AllowModels
    })
    SetNuiFocus(true, true)
    SetCursorLocation(0.9, 0.25)

    FreezeEntityPosition(PlayerPedId(), true)

    enableCam()
end

function IsAllowed()
    -- body
end

Merge = function(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            Merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

RegisterNUICallback('TrackerError', function()
    TriggerEvent('chatMessage', "SYSTEM", "error", "You cannot remove your anklet")
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)

    TriggerServerEvent('bj-clothing:saveOutfit', data.outfitName, model, skinData)
end)

-- RegisterNetEvent('bj-clothing:client:reloadOutfits')
-- AddEventHandler('bj-clothing:client:reloadOutfits', function(myOutfits)
--     SendNUIMessage({
--         action = "reloadMyOutfits",
--         outfits = myOutfits
--     })
-- end)

function enableCam()
    -- Camera
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if(not DoesCamExist(cam)) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(PlayerPedId()) + 180)
    end
    if customCamLocation ~= nil then
        SetCamCoord(cam, customCamLocation.x, customCamLocation.y, customCamLocation.z)
    end
end

RegisterNUICallback('rotateCam', function(data)
    local rotType = data.type
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0, 2.0, 0)

    if rotType == "left" then
        SetEntityHeading(ped, GetEntityHeading(ped) - 10)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180)
    else
        SetEntityHeading(ped, GetEntityHeading(ped) + 10)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180)
    end
end)

RegisterNUICallback('setupCam', function(data)
    local value = data.value

    if value == 1 then
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.75, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.65)
    elseif value == 2 then
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.2)
    elseif value == 3 then
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + -0.6)
    else
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
    end
end)

function disableCam()
    -- print(cam)
    -- print('Render')
    RenderScriptCams(false, true, 250, true, true)
    -- print('Active')
    SetCamActive(cam, false)
    -- print('Destroy')
    DestroyCam(cam, true)

    FreezeEntityPosition(PlayerPedId(), false)
end

function closeMenu()
    SendNUIMessage({
        action = "close",
    })
    SaveSkin()
    disableCam()
end

RegisterNUICallback('resetOutfit', function()
    resetClothing(json.decode(previousSkinData))
    skinData = json.decode(previousSkinData)
    previousSkinData = {}
end)

function resetClothing(data)
    local ped = PlayerPedId()

    -- Face
    -- SetPedHeadBlendData(ped, data["face"].item, data["face"].item, data["face"].item, data["face"].texture, data["face"].texture, data["face"].texture, 1.0, 1.0, 1.0, true)

    SetHeadData(ped, data)

    -- Pants
    SetPedComponentVariation(ped, 4, data["pants"].item, 0, 0)
    SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0)

    -- Hair
    SetPedComponentVariation(ped, 2, data["hair"].item, 0, 0)
    if data["hair2"] ~= nil and data["hair2"].item > -1 then
        SetPedHairColor(ped, data["hair"].texture, data["hair2"].item)
    else
        SetPedHairColor(ped, data["hair"].texture, data["hair"].texture)
    end

    if data["eyes"] ~= nil and data["eyes"].texture > 0 then
        SetPedEyeColor(ped, data["eyes"].texture)
    else
        SetPedEyeColor(ped, 0)
    end

    -- Eyebrows
    SetPedHeadOverlay(ped, 2, data["eyebrows"].item, data["appearance_opacity_1"].item / 100)
    SetPedHeadOverlayColor(ped, 2, 1, data["eyebrows"].texture, 0)

    -- Beard
    SetPedHeadOverlay(ped, 1, data["beard"].item, data["appearance_opacity_1"].texture / 100)
    SetPedHeadOverlayColor(ped, 1, 1, data["beard"].texture, 0)

    -- Blush
    SetPedHeadOverlay(ped, 5, data["blush"].item, data["appearance_opacity_2"].item / 100)
    SetPedHeadOverlayColor(ped, 5, 1, data["blush"].texture, 0)

    -- Lipstick
    SetPedHeadOverlay(ped, 8, data["lipstick"].item, data["appearance_opacity_2"].texture / 100)
    SetPedHeadOverlayColor(ped, 8, 1, data["lipstick"].texture, 0)

    -- Makeup
    SetPedHeadOverlay(ped, 4, data["makeup"].item, data["appearance_opacity_3"].item / 100)
    SetPedHeadOverlayColor(ped, 4, 1, data["makeup"].texture, 0)

    -- Ageing
    SetPedHeadOverlay(ped, 3, data["ageing"].item, data["appearance_opacity_3"].texture / 100)
    SetPedHeadOverlayColor(ped, 3, 1, data["ageing"].texture, 0)

    -- Chest Hair
    SetPedHeadOverlay(ped, 10, data["chest_hair"].item, data["appearance_opacity_4"].item / 100)
    SetPedHeadOverlayColor(ped, 10, 1, data["chest_hair"].texture, 0)

    -- Complexion
    SetPedHeadOverlay(ped, 6, data["complexion"].item, data["complexion"].texture / 100)

    -- Sun Damage
    SetPedHeadOverlay(ped, 7, data["sun_damage"].item, data["sun_damage"].texture / 100)

    -- Moles/Freckles
    SetPedHeadOverlay(ped, 9, data["moles_freckles"].item, data["moles_freckles"].texture / 100)

    -- Arms
    SetPedComponentVariation(ped, 3, data["arms"].item, 0, 2)
    SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0)

    -- T-Shirt
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, 0, 2)
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0)

    -- Vest
    SetPedComponentVariation(ped, 9, data["vest"].item, 0, 2)
    SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0)

    -- Torso 2
    SetPedComponentVariation(ped, 11, data["torso2"].item, 0, 2)
    SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0)

    -- Shoes
    SetPedComponentVariation(ped, 6, data["shoes"].item, 0, 2)
    SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0)

    -- Mask
    SetPedComponentVariation(ped, 1, data["mask"].item, 0, 2)
    SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0)

    -- Badge
    SetPedComponentVariation(ped, 10, data["decals"].item, 0, 2)
    SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0)

    -- Accessory
    SetPedComponentVariation(ped, 7, data["accessory"].item, 0, 2)
    SetPedComponentVariation(ped, 7, data["accessory"].item, data["accessory"].texture, 0)

    -- Bag
    SetPedComponentVariation(ped, 5, data["bag"].item, 0, 2)
    SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)

    -- Hat
    if data["hat"].item ~= -1 and data["hat"].item ~= 0 then
        SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true)
    else
        ClearPedProp(ped, 0)
    end

    -- Glass
    if data["glass"].item ~= -1 and data["glass"].item ~= 0 then
        SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true)
    else
        ClearPedProp(ped, 1)
    end

    -- Ear
    if data["ear"].item ~= -1 and data["ear"].item ~= 0 then
        SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true)
    else
        ClearPedProp(ped, 2)
    end

    -- Watch
    if data["watch"].item ~= -1 and data["watch"].item ~= 0 then
        SetPedPropIndex(ped, 6, data["watch"].item, data["watch"].texture, true)
    else
        ClearPedProp(ped, 6)
    end

    -- Bracelet
    if data["bracelet"].item ~= -1 and data["bracelet"].item ~= 0 then
        SetPedPropIndex(ped, 7, data["bracelet"].item, data["bracelet"].texture, true)
    else
        ClearPedProp(ped, 7)
    end
end

RegisterNUICallback('close', function()
    TriggerEvent('police:client:pauseKeybind', false)
    SetNuiFocus(false, false)
    creatingCharacter = false
    disableCam()
    
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNUICallback('getCatergoryItems', function(data, cb)
    cb(Config.Menus[data.category])
end)

RegisterNUICallback('updateSkin', function(data)
    ChangeVariation(data)
end)

RegisterNUICallback('updateSkinOnInput', function(data)
    ChangeVariation(data)
end)

RegisterNUICallback('removeOutfit', function(data, cb)
    TriggerServerEvent('bj-clothing:server:removeOutfit', data.outfitName, data.outfitId)
    TriggerEvent('chatMessage', "SYSTEM", "warning", "You removed "..data.outfitName.." from your outfits")
end)

function SetHeadData(ped, data)
    SetPedHeadBlendData(ped, data["mom"].item, data["dad"].item, nil, data["mom"].item, data["dad"].item, nil, data["face"].item / 100, data["face"].texture / 100, nil, true)

    for k,v in pairs(faceCategories) do
        if data[k] then
            if v.item ~= nil then
                SetPedFaceFeature(ped, v.item, data[k].item / 100)
            end

            if v.texture ~= nil then
                SetPedFaceFeature(ped, v.texture, data[k].texture / 100)
            end
        end
    end
end

function ChangeVariation(data)
    local ped = PlayerPedId()
    local clothingCategory = data.clothingType
    local type = data.type
    local item = data.articleNumber

    if clothingCategory == "mom" then
        if type == "item" then
            skinData["mom"].item = item
            SetHeadData(ped, skinData)
        end
    elseif clothingCategory == "dad" then
        if type == "item" then
            skinData["dad"].item = item
            SetHeadData(ped, skinData)
        end
    elseif faceCategories[clothingCategory] then
        if clothingCategory == "eyes" and type == "texture" then
            skinData[clothingCategory].texture = item
            SetPedEyeColor(ped, skinData[clothingCategory].texture)
        elseif type == "item" then
            skinData[clothingCategory].item = item
        elseif type == "texture" then
            skinData[clothingCategory].texture = item
        end
        SetHeadData(ped, skinData)
    elseif clothingCategory == "pants" then
        if type == "item" then
            SetPedComponentVariation(ped, 4, item, 0, 0)
            skinData["pants"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 4)
            SetPedComponentVariation(ped, 4, curItem, item, 0)
            skinData["pants"].texture = item
        end
    elseif clothingCategory == "face" then
        if type == "item" then
            --SetPedHeadBlendData(ped, tonumber(item), tonumber(item), tonumber(item), skinData["face"].texture, skinData["face"].texture, skinData["face"].texture, 1.0, 1.0, 1.0, true)
            skinData["face"].item = item
        elseif type == "texture" then
            --SetPedHeadBlendData(ped, skinData["face"].item, skinData["face"].item, skinData["face"].item, item, item, item, 1.0, 1.0, 1.0, true)
            skinData["face"].texture = item
        end
        SetHeadData(ped, skinData)
    elseif clothingCategory == "hair" then
        --SetPedHeadBlendData(ped, skinData["face"].item, skinData["face"].item, skinData["face"].item, skinData["face"].texture, skinData["face"].texture, skinData["face"].texture, 1.0, 1.0, 1.0, true)
        SetHeadData(ped, skinData)
        if type == "item" then
            SetPedComponentVariation(ped, 2, item, 0, 0)
            skinData["hair"].item = item
        elseif type == "texture" then
            SetPedHairColor(ped, item, item)
            skinData["hair"].texture = item
        end
    elseif clothingCategory == "hair2" then
        --SetPedHeadBlendData(ped, skinData["face"].item, skinData["face"].item, skinData["face"].item, skinData["face"].texture, skinData["face"].texture, skinData["face"].texture, 1.0, 1.0, 1.0, true)
        SetHeadData(ped, skinData)
        if type == "item" then
            if skinData["hair2"] ~= nil then
                SetPedHairColor(ped, skinData["hair"].texture, item)
                skinData["hair2"].item = item
            end
        end
    elseif clothingCategory == "eyebrows" then
        if type == "item" then
            SetPedHeadOverlay(ped, 2, item, skinData["appearance_opacity_1"].item / 100)
            skinData["eyebrows"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 2, 1, item, 0)
            skinData["eyebrows"].texture = item
        end
    elseif clothingCategory == "beard" then
        if type == "item" then
            SetPedHeadOverlay(ped, 1, item, skinData["appearance_opacity_1"].texture / 100)
            skinData["beard"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 1, 1, item, 0)
            skinData["beard"].texture = item
        end
    elseif clothingCategory == "chest_hair" then
        if type == "item" then
            SetPedHeadOverlay(ped, 10, item, skinData["appearance_opacity_4"].item / 100)
            skinData["chest_hair"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 10, 1, item, 0)
            skinData["chest_hair"].texture = item
        end
    elseif clothingCategory == "complexion" then
        if type == "item" then
            SetPedHeadOverlay(ped, 6, item, skinData["complexion"].texture / 100)
            skinData["complexion"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 6, skinData["complexion"].item, item / 100)
            skinData["complexion"].texture = item
        end
    elseif clothingCategory == "sun_damage" then
        if type == "item" then
            SetPedHeadOverlay(ped, 7, item, skinData["sun_damage"].texture / 100)
            skinData["sun_damage"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 7, skinData["sun_damage"].item, item / 100)
            skinData["sun_damage"].texture = item
        end
    elseif clothingCategory == "moles_freckles" then
        if type == "item" then
            SetPedHeadOverlay(ped, 9, item, skinData["moles_freckles"].texture / 100)
            skinData["moles_freckles"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 9, skinData["moles_freckles"].item, item / 100)
            skinData["moles_freckles"].texture = item
        end
    elseif clothingCategory == "blush" then
        if type == "item" then
            SetPedHeadOverlay(ped, 5, item, skinData["appearance_opacity_2"].item / 100)
            skinData["blush"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 5, 1, item, 0)
            skinData["blush"].texture = item
        end
    elseif clothingCategory == "lipstick" then
        if type == "item" then
            SetPedHeadOverlay(ped, 8, item, skinData["appearance_opacity_2"].texture / 100)
            skinData["lipstick"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 8, 1, item, 0)
            skinData["lipstick"].texture = item
        end
    elseif clothingCategory == "makeup" then
        if type == "item" then
            SetPedHeadOverlay(ped, 4, item, skinData["appearance_opacity_3"].item / 100)
            skinData["makeup"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 4, 1, item, 0)
            skinData["makeup"].texture = item
        end
    elseif clothingCategory == "ageing" then
        if type == "item" then
            SetPedHeadOverlay(ped, 3, item, skinData["appearance_opacity_3"].texture / 100)
            skinData["ageing"].item = item
        elseif type == "texture" then
            SetPedHeadOverlayColor(ped, 3, 1, item, 0)
            skinData["ageing"].texture = item
        end
    elseif clothingCategory == "arms" then
        if type == "item" then
            SetPedComponentVariation(ped, 3, item, 0, 2)
            skinData["arms"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 3)
            SetPedComponentVariation(ped, 3, curItem, item, 0)
            skinData["arms"].texture = item
        end
    elseif clothingCategory == "t-shirt" then
        if type == "item" then
            SetPedComponentVariation(ped, 8, item, 0, 2)
            skinData["t-shirt"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 8)
            SetPedComponentVariation(ped, 8, curItem, item, 0)
            skinData["t-shirt"].texture = item
        end
    elseif clothingCategory == "vest" then
        if type == "item" then
            SetPedComponentVariation(ped, 9, item, 0, 2)
            skinData["vest"].item = item
        elseif type == "texture" then
            SetPedComponentVariation(ped, 9, skinData["vest"].item, item, 0)
            skinData["vest"].texture = item
        end
    elseif clothingCategory == "bag" then
        if type == "item" then
            SetPedComponentVariation(ped, 5, item, 0, 2)
            skinData["bag"].item = item
        elseif type == "texture" then
            SetPedComponentVariation(ped, 5, skinData["bag"].item, item, 0)
            skinData["bag"].texture = item
        end
    elseif clothingCategory == "decals" then
        if type == "item" then
            SetPedComponentVariation(ped, 10, item, 0, 2)
            skinData["decals"].item = item
        elseif type == "texture" then
            SetPedComponentVariation(ped, 10, skinData["decals"].item, item, 0)
            skinData["decals"].texture = item
        end
    elseif clothingCategory == "accessory" then
        if type == "item" then
            SetPedComponentVariation(ped, 7, item, 0, 2)
            skinData["accessory"].item = item
        elseif type == "texture" then
            SetPedComponentVariation(ped, 7, skinData["accessory"].item, item, 0)
            skinData["accessory"].texture = item
        end
    elseif clothingCategory == "torso2" then
        if type == "item" then
            SetPedComponentVariation(ped, 11, item, 0, 2)
            skinData["torso2"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 11)
            SetPedComponentVariation(ped, 11, curItem, item, 0)
            skinData["torso2"].texture = item
        end
    elseif clothingCategory == "shoes" then
        if type == "item" then
            SetPedComponentVariation(ped, 6, item, 0, 2)
            skinData["shoes"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 6)
            SetPedComponentVariation(ped, 6, curItem, item, 0)
            skinData["shoes"].texture = item
        end
    elseif clothingCategory == "mask" then
        if type == "item" then
            SetPedComponentVariation(ped, 1, item, 0, 2)
            skinData["mask"].item = item
        elseif type == "texture" then
            local curItem = GetPedDrawableVariation(ped, 1)
            SetPedComponentVariation(ped, 1, curItem, item, 0)
            skinData["mask"].texture = item
        end
    elseif clothingCategory == "hat" then
        if type == "item" then
            if item ~= -1 then
                SetPedPropIndex(ped, 0, item, skinData["hat"].texture, true)
            else
                ClearPedProp(ped, 0)
            end
            skinData["hat"].item = item
        elseif type == "texture" then
            SetPedPropIndex(ped, 0, skinData["hat"].item, item, true)
            skinData["hat"].texture = item
        end
    elseif clothingCategory == "glass" then
        if type == "item" then
            if item ~= -1 then
                SetPedPropIndex(ped, 1, item, skinData["glass"].texture, true)
                skinData["glass"].item = item
            else
                ClearPedProp(ped, 1)
            end
        elseif type == "texture" then
            SetPedPropIndex(ped, 1, skinData["glass"].item, item, true)
            skinData["glass"].texture = item
        end
    elseif clothingCategory == "ear" then
        if type == "item" then
            if item ~= -1 then
                SetPedPropIndex(ped, 2, item, skinData["ear"].texture, true)
            else
                ClearPedProp(ped, 2)
            end
            skinData["ear"].item = item
        elseif type == "texture" then
            SetPedPropIndex(ped, 2, skinData["ear"].item, item, true)
            skinData["ear"].texture = item
        end
    elseif clothingCategory == "watch" then
        if type == "item" then
            if item ~= -1 then
                SetPedPropIndex(ped, 6, item, skinData["watch"].texture, true)
            else
                ClearPedProp(ped, 6)
            end
            skinData["watch"].item = item
        elseif type == "texture" then
            SetPedPropIndex(ped, 6, skinData["watch"].item, item, true)
            skinData["watch"].texture = item
        end
    elseif clothingCategory == "bracelet" then
        if type == "item" then
            if item ~= -1 then
                SetPedPropIndex(ped, 7, item, skinData["bracelet"].texture, true)
            else
                ClearPedProp(ped, 7)
            end
            skinData["bracelet"].item = item
        elseif type == "texture" then
            SetPedPropIndex(ped, 7, skinData["bracelet"].item, item, true)
            skinData["bracelet"].texture = item
        end
    elseif clothingCategory == "appearance_opacity_1" then
        if type == "item" then
            SetPedHeadOverlay(ped, 2, skinData["eyebrows"].item, item / 100)
            skinData["appearance_opacity_1"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 1, skinData["beard"].item, item / 100)
            skinData["appearance_opacity_1"].texture = item
        end
    elseif clothingCategory == "appearance_opacity_2" then
        if type == "item" then
            SetPedHeadOverlay(ped, 5, skinData["blush"].item, item / 100)
            skinData["appearance_opacity_2"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 8, skinData["lipstick"].item, item / 100)
            skinData["appearance_opacity_2"].texture = item
        end
    elseif clothingCategory == "appearance_opacity_3" then
        if type == "item" then
            SetPedHeadOverlay(ped, 4, skinData["makeup"].item, item / 100)
            skinData["appearance_opacity_3"].item = item
        elseif type == "texture" then
            SetPedHeadOverlay(ped, 3, skinData["ageing"].item, item / 100)
            skinData["appearance_opacity_3"].texture = item
        end
    elseif clothingCategory == "appearance_opacity_4" then
        if type == "item" then
            SetPedHeadOverlay(ped, 10, skinData["chest_hair"].item, item / 100)
            skinData["appearance_opacity_4"].item = item
        end
    end

    GetMaxValues()
end

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

function ChangeToSkinNoUpdate(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    Citizen.CreateThread(function()
        RequestModel(model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)

        for k, v in pairs(skinData) do
            if skin == "mp_m_freemode_01" or skin == "mp_f_freemode_01" then
                ChangeVariation({
                    clothingType = k,
                    articleNumber = v.defaultItem,
                    type = "item",
                })
            else
                if k ~= "face" and k ~= "hair" and k ~= "hair2" then
                    ChangeVariation({
                        clothingType = k,
                        articleNumber = v.defaultItem,
                        type = "item",
                    })
                end
            end
            
            if skin == "mp_m_freemode_01" or skin == "mp_f_freemode_01" then
                ChangeVariation({
                    clothingType = k,
                    articleNumber = v.defaultTexture,
                    type = "texture",
                })
            else
                if k ~= "face" and k ~= "hair" and k ~= "hair2" then
                    ChangeVariation({
                        clothingType = k,
                        articleNumber = v.defaultTexture,
                        type = "texture",
                    })
                end
            end
        end
    end)

    -- SetEntityInvincible(ped, true)
    -- if IsModelInCdimage(model) and IsModelValid(model) then
    --     LoadPlayerModel(model)
    --     SetPlayerModel(PlayerId(), model)

    --     for k, v in pairs(skinData) do
    --         skinData[k].item = skinData[k].defaultItem
    --         skinData[k].texture = skinData[k].defaultTexture
    --     end

    --     if isPedAllowedRandom() then
    --         SetPedRandomComponentVariation(ped, true)
    --     end
        
    --     SendNUIMessage({action = "toggleChange", allow = true})
	-- 	SetModelAsNoLongerNeeded(model)
	-- end
	-- SetEntityInvincible(ped, false)
    -- GetMaxValues()
end

RegisterNUICallback('setCurrentPed', function(data, cb)
    local playerData = BJCore.Functions.GetPlayerData()

    if playerData.charinfo.gender == '0' then
        cb(Config.ManPlayerModels[data.ped])
        ChangeToSkinNoUpdate(Config.ManPlayerModels[data.ped])
    else
        cb(Config.WomanPlayerModels[data.ped])
        ChangeToSkinNoUpdate(Config.WomanPlayerModels[data.ped])
    end
end)

RegisterNUICallback('saveClothing', function(data)
    SaveSkin()
end)

AddEventHandler("clothing:save", function()
    SaveSkin()
end)

local createNewChar = false
function SaveSkin()
	local model = GetEntityModel(PlayerPedId())
    clothing = json.encode(skinData)
	TriggerServerEvent("bj-clothing:saveSkin", model, clothing, createNewChar)
    Wait(100)
    if createNewChar then
        createNewChar = not createNewChar
        TriggerServerEvent("bj-clothing:server:HandleBucket")
    end
end

RegisterNetEvent('bj-clothing:client:CreateFirstCharacter')
AddEventHandler('bj-clothing:client:CreateFirstCharacter', function()
    BJCore.Functions.GetPlayerData(function(PlayerData)
        TriggerServerEvent("bj-clothing:server:HandleBucket")
        createNewChar = true
        Wait(10)
        local skin = "mp_m_freemode_01"
        openMenu({
            {menu = "character", label = "Character", selected = true},
            {menu = "clothing", label = "Clothing", selected = false},
            {menu = "extra", label = "Appearance", selected = false},
            {menu = "accessories", label = "Accesories", selected = false}
        })
        -- print(PlayerData.charinfo.gender)
        if PlayerData.charinfo.gender == '1' then 
            skin = "mp_f_freemode_01" 
        end

        ChangeToSkinNoUpdate(skin)
        SendNUIMessage({
            action = "ResetValues",
        })
    end)
end)

RegisterNetEvent("bj-clothing:loadSkin")
AddEventHandler("bj-clothing:loadSkin", function(new, model, data)
    print('[CLOTHING] Load Model Called: '..tostring(model))
    print("1 clothing fade: "..tostring(IsScreenFadedOut()))
    model = model ~= nil and tonumber(model) or false
    while not DoesEntityExist(PlayerPedId()) do
        print("[CLOTHING] waiting for player ped (loadSkin)")
        Citizen.Wait(0)
    end
    if not model then
        print("[CLOTHING] model data not found on saved char. sending to char creation")
        --DoScreenFadeIn(500)
        TriggerEvent("bj-clothing:client:CreateFirstCharacter")
    else
        Citizen.CreateThread(function()
            RequestModel(model)
            while not HasModelLoaded(model) do
                print("[CLOTHING] loading model (loadSkin): "..tostring(model))
                RequestModel(model)
                Citizen.Wait(0)
            end
            print("[CLOTHING] pre: "..tostring(model))
            SetPlayerModel(PlayerId(), model)
            print("[CLOTHING] actual: "..GetEntityModel(PlayerPedId()))
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
            data = json.decode(data)
            print("2 clothing fade: "..tostring(IsScreenFadedOut()))
            TriggerEvent('bj-clothing:client:loadPlayerClothing', data, PlayerPedId(), new)
        end)
    end
end)

RegisterNetEvent('bj-clothing:client:loadPlayerClothing')
AddEventHandler('bj-clothing:client:loadPlayerClothing', function(data, ped, new)
    faceProps = {
        [1] = { ["Prop"] = -1, ["Texture"] = -1 },
        [2] = { ["Prop"] = -1, ["Texture"] = -1 },
        [3] = { ["Prop"] = -1, ["Texture"] = -1 },
        [4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
        [5] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
        [6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
    }

    print("3 clothing fade: "..tostring(IsScreenFadedOut()))
    print("[CLOTHING] before applying clothing: "..GetEntityModel(PlayerPedId()))
    if ped == nil then ped = PlayerPedId() end

    for i = 0, 11 do
        SetPedComponentVariation(ped, i, 0, 0, 0)
    end

    for i = 0, 7 do
        ClearPedProp(ped, i)
    end

    for k,sd in pairs(defaultSkinData) do
        if not data[k] then
            data[k] = sd
        end
        data[k].defaultItem = sd.defaultItem
        data[k].defaultTexture = sd.defaultTexture
    end

    if data["eyeColor"] ~= nil and data["eyeColor"].item ~= nil and (data["eyes"].texture > 40 or data["eyes"].texture <= 0) then
        data["eyes"].texture = data["eyeColor"].item
    end

    -- Face
    --SetPedHeadBlendData(ped, data["face"].item, data["face"].item, data["face"].item, data["face"].texture, data["face"].texture, data["face"].texture, 1.0, 1.0, 1.0, true)
    SetHeadData(ped, data)

    -- Pants
    SetPedComponentVariation(ped, 4, data["pants"].item, 0, 0)
    SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0)

    -- Hair
    SetPedComponentVariation(ped, 2, data["hair"].item, 0, 0)

    if data["hair2"] ~= nil and data["hair2"].item > 0 then
        SetPedHairColor(ped, data["hair"].texture, data["hair2"].item)
    else
        SetPedHairColor(ped, data["hair"].texture, data["hair"].texture)
    end

    if data["eyes"] ~= nil and data["eyes"].texture > -1 then
        SetPedEyeColor(ped, data["eyes"].texture)
    else
        SetPedEyeColor(ped, 0)
    end

    -- Eyebrows
    SetPedHeadOverlay(ped, 2, data["eyebrows"].item, data["appearance_opacity_1"].item / 100)
    SetPedHeadOverlayColor(ped, 2, 1, data["eyebrows"].texture, 0)

    -- Beard
    SetPedHeadOverlay(ped, 1, data["beard"].item, data["appearance_opacity_1"].texture / 100)
    SetPedHeadOverlayColor(ped, 1, 1, data["beard"].texture, 0)

    -- Blush
    SetPedHeadOverlay(ped, 5, data["blush"].item, data["appearance_opacity_2"].item / 100)
    SetPedHeadOverlayColor(ped, 5, 1, data["blush"].texture, 0)

    -- Lipstick
    SetPedHeadOverlay(ped, 8, data["lipstick"].item, data["appearance_opacity_2"].texture / 100)
    SetPedHeadOverlayColor(ped, 8, 1, data["lipstick"].texture, 0)

    -- Makeup
    SetPedHeadOverlay(ped, 4, data["makeup"].item, data["appearance_opacity_3"].item / 100)
    SetPedHeadOverlayColor(ped, 4, 1, data["makeup"].texture, 0)

    -- Ageing
    SetPedHeadOverlay(ped, 3, data["ageing"].item, data["appearance_opacity_3"].texture / 100)
    SetPedHeadOverlayColor(ped, 3, 1, data["ageing"].texture, 0)

    -- Chest Hair
    SetPedHeadOverlay(ped, 10, data["chest_hair"].item, data["appearance_opacity_4"].item / 100)
    SetPedHeadOverlayColor(ped, 10, 1, data["chest_hair"].texture, 0)

    -- Complexion
    SetPedHeadOverlay(ped, 6, data["complexion"].item, data["complexion"].texture / 100)

    -- Sun Damage
    SetPedHeadOverlay(ped, 7, data["sun_damage"].item, data["sun_damage"].texture / 100)

    -- Moles/Freckles
    SetPedHeadOverlay(ped, 9, data["moles_freckles"].item, data["moles_freckles"].texture / 100)

    -- Arms
    SetPedComponentVariation(ped, 3, data["arms"].item, 0, 2)
    SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0)

    -- T-Shirt
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, 0, 2)
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0)

    -- Vest
    SetPedComponentVariation(ped, 9, data["vest"].item, 0, 2)
    SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0)

    -- Torso 2
    SetPedComponentVariation(ped, 11, data["torso2"].item, 0, 2)
    SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0)

    -- Shoes
    SetPedComponentVariation(ped, 6, data["shoes"].item, 0, 2)
    SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0)

    -- Mask
    SetPedComponentVariation(ped, 1, data["mask"].item, 0, 2)
    SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0)

    -- Badge
    SetPedComponentVariation(ped, 10, data["decals"].item, 0, 2)
    SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0)

    -- Accessory
    SetPedComponentVariation(ped, 7, data["accessory"].item, 0, 2)
    SetPedComponentVariation(ped, 7, data["accessory"].item, data["accessory"].texture, 0)

    -- Bag
    SetPedComponentVariation(ped, 5, data["bag"].item, 0, 2)
    SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)

    -- Hat
    if data["hat"].item ~= -1 and data["hat"].item ~= 0 then
        SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true)
    else
        ClearPedProp(ped, 0)
    end

    -- Glass
    if data["glass"].item ~= -1 and data["glass"].item ~= 0 then
        SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true)
    else
        ClearPedProp(ped, 1)
    end

    -- Ear
    if data["ear"].item ~= -1 and data["ear"].item ~= 0 then
        SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true)
    else
        ClearPedProp(ped, 2)
    end

    -- Watch
    if data["watch"].item ~= -1 and data["watch"].item ~= 0 then
        SetPedPropIndex(ped, 6, data["watch"].item, data["watch"].texture, true)
    else
        ClearPedProp(ped, 6)
    end

    -- Bracelet
    if data["bracelet"].item ~= -1 and data["bracelet"].item ~= 0 then
        SetPedPropIndex(ped, 7, data["bracelet"].item, data["bracelet"].texture, true)
    else
        ClearPedProp(ped, 7)
    end

    skinData = data
    print("[CLOTHING] after applying clothing: "..GetEntityModel(PlayerPedId()))
    print("4 clothing fade: "..tostring(IsScreenFadedOut()))
    TriggerEvent("tattoos:client:setTattoos")
    if not new and not SettingTattoos then
        TriggerEvent('bj-spawnlocation:client:openUI', true)
    else
        SettingTattoos = false
    end
end)

function typeof(var)
    local _type = type(var);
    if(_type ~= "table" and _type ~= "userdata") then
        return _type;
    end
    local _meta = getmetatable(var);
    if(_meta ~= nil and _meta._NAME ~= nil) then
        return _meta._NAME;
    else
        return _type;
    end
end

local outfitIgnore = {
    ['model'] = true,
    ['mom'] = true,
    ['dad'] = true,
    ['face'] = true,
    ['ageing'] = true,
    ['nose'] = true,
    ['nose_profile'] = true,
    ['nose_peak'] = true,
    ['cheekbones'] = true,
    ['cheeks'] = true,
    ['eyes'] = true,
    ['lips'] = true,
    ['jaw'] = true,
    ['chin'] = true,
    ['shape_chin'] = true,
    ['hair'] = true,
    ['hair2'] = true,
    ['eyebrows'] = true,
    ['beard'] = true,
    ['chest_hair'] = true,
    ['complexion'] = true,
    ['sun_damage'] = true,
    ['makeup'] = true,
    ['moles_freckles'] = true,
    ['lipstick'] = true,
    ['blush'] = true,
    ['appearance_opacity_1'] = true,
    ['appearance_opacity_2'] = true,
    ['appearance_opacity_3'] = true,
    ['appearance_opacity_4'] = true
}

local lastOutfit = {}

AddEventHandler("clothing:client:restoreOutfit", function()
    if next(lastOutfit) ~= nil then
        TriggerEvent("bj-clothing:client:loadOutfit", lastOutfit)
    end
end)

RegisterNetEvent('bj-clothing:client:loadOutfit')
AddEventHandler('bj-clothing:client:loadOutfit', function(oData)
    local ped = PlayerPedId()

    data = oData.outfitData
    lastOutfit.outfitData = {}

    if typeof(data) ~= "table" then data = json.decode(data) end

    for k, v in pairs(data) do
        if outfitIgnore[k] then
            data[k] = nil
        else
            if lastOutfit.outfitData[k] == nil then
                lastOutfit.outfitData[k] = {}
            end
            lastOutfit.outfitData[k].item = skinData[k].item
            lastOutfit.outfitData[k].texture = skinData[k].texture
            skinData[k].item = data[k].item
            skinData[k].texture = data[k].texture
        end
    end

    print(BJCore.Common.Dump(lastOutfit))

    -- Pants
    if data["pants"] ~= nil then
        SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0)
    end

    -- Arms
    if data["arms"] ~= nil then
        SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0)
    end

    -- T-Shirt
    if data["t-shirt"] ~= nil then
        SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0)
    end

    -- Vest
    if data["vest"] ~= nil then
        SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0)
    end

    -- Torso 2
    if data["torso2"] ~= nil then
        SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0)
    end

    -- Shoes
    if data["shoes"] ~= nil then
        SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0)
    end

    -- Bag
    if data["bag"] ~= nil then
        SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)
    end

    -- Badge
    if data["badge"] ~= nil then
        SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0)
    end

    -- Accessory
    if data["accessory"] ~= nil then
        if BJCore.Functions.GetPlayerData().metadata["tracker"] then
            SetPedComponentVariation(ped, 7, 13, 0, 0)
        else
            SetPedComponentVariation(ped, 7, data["accessory"].item, data["accessory"].texture, 0)
        end
    else
        if BJCore.Functions.GetPlayerData().metadata["tracker"] then
            SetPedComponentVariation(ped, 7, 13, 0, 0)
        else
            SetPedComponentVariation(ped, 7, -1, 0, 2)
        end
    end

    -- Mask
    if data["mask"] ~= nil then
        SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0)
    end

    -- Bag
    if data["bag"] ~= nil then
        SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)
    end

    -- Hat
    if data["hat"] ~= nil then
        if data["hat"].item ~= -1 and data["hat"].item ~= 0 then
            SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true)
        else
            ClearPedProp(ped, 0)
        end
    end

    -- Glass
    if data["glass"] ~= nil then
        if data["glass"].item ~= -1 and data["glass"].item ~= 0 then
            SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true)
        else
            ClearPedProp(ped, 1)
        end
    end

    -- Ear
    if data["ear"] ~= nil then
        if data["ear"].item ~= -1 and data["ear"].item ~= 0 then
            SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true)
        else
            ClearPedProp(ped, 2)
        end
    end

    if oData.outfitName ~= nil then
        TriggerEvent('chatMessage', "SYSTEM", "warning", "Outfit: "..oData.outfitName.." loaded. Press Confirm to continue")
    end
end)

RegisterNUICallback('toggleFacewear', function(data)
    if data.type then
        TriggerEvent('bj-clothing:client:adjustfacewear', data.type)
    end
end)

local faceProps = {
	[1] = { ["Prop"] = -1, ["Texture"] = -1 },
	[2] = { ["Prop"] = -1, ["Texture"] = -1 },
	[3] = { ["Prop"] = -1, ["Texture"] = -1 },
	[4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
	[5] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
	[6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
}

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

RegisterNetEvent("bj-clothing:client:adjustfacewear")
AddEventHandler("bj-clothing:client:adjustfacewear",function(type, forceData, item)
    if BJCore.Functions.GetPlayerData().metadata["ishandcuffed"] then return end
	removeWear = false
	local AnimSet = "none"
	local AnimationOn = "none"
	local AnimationOff = "none"
	local PropIndex = 0

	local AnimSet = "mp_masks@on_foot"
	local AnimationOn = "put_on_mask"
	local AnimationOff = "put_on_mask"

	faceProps[6]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 0)
	faceProps[6]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 0)
	faceProps[6]["Texture"] = GetPedTextureVariation(PlayerPedId(), 0)

    if type == 6 and GetPedDrawableVariation(PlayerPedId(), 0) ~= -1 then
        removeWear = true
    end

	for i = 0, 3 do
		if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
			faceProps[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)

            if type == (i+1) then
                removeWear = true
            end
		end
		if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
			faceProps[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)

            if type == (i+1) then
                removeWear = true
            end
		end
	end

	if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
		faceProps[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
		faceProps[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
		faceProps[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)

        if type == 4 then
            removeWear = true
        end
	end

	-- if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
	-- 	faceProps[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
	-- 	faceProps[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
	-- 	faceProps[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
	-- end

    if GetPedDrawableVariation(PlayerPedId(), 5) ~= -1 then
        faceProps[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 5)
        faceProps[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 5)
        faceProps[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 5)

        if type == 5 then
            removeWear = true
        end
    end

    if not removeWear and forceData == nil and item == false then return; end
	if type == 1 then
		PropIndex = 0
	elseif type == 2 then
		PropIndex = 1

		AnimSet = "clothingspecs"
		AnimationOn = "take_off"
		AnimationOff = "take_off"

	elseif type == 3 then
		PropIndex = 2
	elseif type == 4 then
		PropIndex = 1
		if removeWear then
			AnimSet = "missfbi4"
			AnimationOn = "takeoff_mask"
			AnimationOff = "takeoff_mask"
		end
	elseif type == 5 then
		PropIndex = 5
		AnimSet = "oddjobs@basejump@ig_15"
		AnimationOn = "puton_parachute"
		AnimationOff = "puton_parachute"
		--mp_safehouseshower@male@ male_shower_idle_d_towel
		--mp_character_creation@customise@male_a drop_clothes_a
		--oddjobs@basejump@ig_15 puton_parachute_bag
	end

	loadAnimDict( AnimSet )
	-- if type == 5 then
	-- 	if removeWear then
	-- 		SetPedComponentVariation(PlayerPedId(), 3, 2, faceProps[6]["Texture"], faceProps[6]["Palette"])
	-- 	end
	-- end
	if removeWear then
		TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
		Citizen.Wait(500)
		if type ~= 5 then
			if type == 4 then
                TriggerServerEvent("clothing:server:createFacewear", type, faceProps[type])
				SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
			else
				if type ~= 2 then
                    TriggerServerEvent("clothing:server:createFacewear", type, faceProps[PropIndex+1])
					ClearPedProp(PlayerPedId(), tonumber(PropIndex))
				end
			end
		end
	else
		TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
		Citizen.Wait(500)
		if type ~= 5 and type ~= 2 then
			if type == 4 then
                if forceData then
				    SetPedComponentVariation(PlayerPedId(), PropIndex, forceData["Prop"], forceData["Texture"], forceData["Palette"])
                else
                    SetPedComponentVariation(PlayerPedId(), PropIndex, tonumber(item.info["Prop"]), tonumber(item.info["Texture"]), tonumber(item.info["Palette"]))
                    TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
                end
			else
                if forceData then
                    SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(forceData["Prop"]), tonumber(forceData["Texture"]), false)
                else
				    SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(item.info["Prop"]), tonumber(item.info["Texture"]), false)
                    TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
                end
			end
		end
	end
	if type == 5 then
		if not removeWear then
            if forceData then
                SetPedComponentVariation(PlayerPedId(), PropIndex, forceData["Prop"], forceData["Texture"], forceData["Palette"])
            else
                SetPedComponentVariation(PlayerPedId(), PropIndex, tonumber(item.info["Prop"]), tonumber(item.info["Texture"]), tonumber(item.info["Palette"]))
                TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
            end
			-- SetPedComponentVariation(PlayerPedId(), 3, 1, faceProps[6]["Texture"], faceProps[6]["Palette"])
			-- SetPedComponentVariation(PlayerPedId(), PropIndex, faceProps[type]["Prop"], faceProps[type]["Texture"], faceProps[type]["Palette"])
		else
			SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
            TriggerServerEvent("clothing:server:createFacewear", type, faceProps[type])
		end
		Citizen.Wait(1800)
	end
	if type == 2 then
		Citizen.Wait(600)
		if removeWear then
            TriggerServerEvent("clothing:server:createFacewear", type, faceProps[PropIndex+1])
			ClearPedProp(PlayerPedId(), tonumber(PropIndex))
		end

		if not removeWear then
			Citizen.Wait(140)
            if forceData then
                SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(forceData["Prop"]), tonumber(forceData["Texture"]), false)
            else
                SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(item.info["Prop"]), tonumber(item.info["Texture"]), false)
                TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
            end
		end
	end
	if type == 4 and removeWear then
		Citizen.Wait(1200)
	end
	ClearPedTasks(PlayerPedId())
    if removeWear and forceData ~= nil then
        TriggerEvent("bj-clothing:client:adjustfacewear", type, forceData, item)
    end
end)

local clothingProps = {
    -- Torso
    [3] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 },
    [8] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 },
    [11] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 },

    -- Pants
    [4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 },

    -- Shoes
    [6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 },

    -- Vest
    [9] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1, ["Armour"] = 0 },
}

local defaults = {
    ['0'] = {
        [1] = -1,
        [2] = -1,
        [3] = 15,
        [4] = 21,
        [5] = -1,
        [6] = 34,
        [7] = -1,
        [8] = 15,
        [9] = 0,
        [10] = -1,
        [11] = 91,
        [12] = -1,
        [13] = -1,
        [14] = -1,
        [15] = -1,
    },
    ['1'] = {
        [1] = -1,
        [2] = -1,
        [3] = 15,
        [4] = 15,
        [5] = -1,
        [6] = 35,
        [7] = 8,
        [8] = -1,
        [9] = 0,
        [10] = -1,
        [11] = 82,
        [12] = -1,
        [13] = -1,
        [14] = -1,
        [15] = -1,
    }
}

local animations = {
    [6] = {
        AnimSet = 'clothingshoes',
        AnimationOn = 'check_out_a',
        AnimationOff = 'check_out_a',
        Delay = 1300
    }
}

local ClothingProgressBar = 2 -- seconds or false to disable
local DisableMovmentWhileChanging = true -- or false
local ClothingChangeInCar = true -- set to false to disable toggling clothing in a vehicle
RegisterNetEvent("bj-clothing:client:adjustClothing")
AddEventHandler("bj-clothing:client:adjustClothing",function(type, forceData, item)
    if BJCore.Functions.GetPlayerData().metadata["ishandcuffed"] then return end
    if IsPedInAnyVehicle(PlayerPedId()) and not ClothingChangeInCar then BJCore.Functions.Notify("You can't do this while in a vehicle") return; end
	removeWear = false
	local PropIndex = 0

	local AnimSet = "missmic4"
	local AnimationOn = "michael_tux_fidget"
	local AnimationOff = "michael_tux_fidget"
    local Delay = 3500
    local isTorso = type == 3 or type == 8 or type == 11
    local genderDefaults = defaults[BJCore.Functions.GetPlayerData().charinfo.gender]

    if animations[type] then
        AnimSet = animations[type].AnimSet
	    AnimationOn = animations[type].AnimationOn
	    AnimationOff = animations[type].AnimationOff
        Delay = animations[type].Delay
    end

	for k,v in pairs(clothingProps) do
        local draw, text, palette = GetPedDrawableVariation(PlayerPedId(), k), GetPedTextureVariation(PlayerPedId(), k), GetPedPaletteVariation(PlayerPedId(), k)

        if draw ~= -1 and draw ~= genderDefaults[k] then
            clothingProps[k]["Prop"] = draw

            if text ~= -1 then
                clothingProps[k]["Texture"] = text
            end
            if palette ~= -1 then
                clothingProps[k]["Palette"] = palette
            end
        end

        if type == k and draw ~= -1 and draw ~= genderDefaults[k] then
            removeWear = true
        end
    end

	if type == 3 or type == 8 or type == 11 then
        type = 3
	end

    if not removeWear and forceData == nil and item == false then return; end

    local busy = true
    if ClothingProgressBar then
        exports['mythic_progbar']:Progress({
            name = "gsrtest_player",
            duration = ClothingProgressBar*1000,
            label = "Adjusting clothes",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = DisableMovmentWhileChanging,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = false,
            },
        }, function(status)
            busy = false
        end)
        while busy do Citizen.Wait(10); end
    end

	loadAnimDict( AnimSet )
    if type == 3 then
        if removeWear then
            TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
            Citizen.Wait(Delay)
            SetPedComponentVariation(PlayerPedId(), 3, genderDefaults[3], 0, clothingProps[3]["Palette"])
            SetPedComponentVariation(PlayerPedId(), 8, genderDefaults[8], 0, clothingProps[8]["Palette"])
            SetPedComponentVariation(PlayerPedId(), 11, genderDefaults[11], 0, clothingProps[11]["Palette"])
            local dataToStore = {
                torso = {
                    Prop = clothingProps[3]["Prop"],
                    Texture = clothingProps[3]["Texture"],
                    Pallet = clothingProps[3]["Palette"]
                },
                accessories = {
                    Prop = clothingProps[8]["Prop"],
                    Texture = clothingProps[8]["Texture"],
                    Pallet = clothingProps[8]["Palette"]
                },
                shirt = {
                    Prop = clothingProps[11]["Prop"],
                    Texture = clothingProps[11]["Texture"],
                    Pallet = clothingProps[11]["Palette"]
                },
            }
            TriggerServerEvent("clothing:server:createClothing", 3, dataToStore)
        else
            TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
            Citizen.Wait(Delay)
            -- SetPedComponentVariation(PlayerPedId(), 3, clothingProps[3]["Prop"], clothingProps[3]["Texture"], clothingProps[3]["Palette"])
            -- SetPedComponentVariation(PlayerPedId(), 8, clothingProps[8]["Prop"], clothingProps[8]["Texture"], clothingProps[8]["Palette"])
            -- SetPedComponentVariation(PlayerPedId(), 11, clothingProps[11]["Prop"], clothingProps[11]["Texture"], clothingProps[11]["Palette"])
            if forceData then
                SetPedComponentVariation(PlayerPedId(), 3, forceData.torso["Prop"], forceData.torso["Texture"], forceData.torso["Palette"])
                SetPedComponentVariation(PlayerPedId(), 8, forceData.accessories["Prop"], forceData.accessories["Texture"], forceData.accessories["Palette"])
                SetPedComponentVariation(PlayerPedId(), 11, forceData.shirt["Prop"], forceData.shirt["Texture"], forceData.shirt["Palette"])
            else
                SetPedComponentVariation(PlayerPedId(), 3, item.info.torso["Prop"], item.info.torso["Texture"], item.info.torso["Palette"])
                SetPedComponentVariation(PlayerPedId(), 8, item.info.accessories["Prop"], item.info.accessories["Texture"], item.info.accessories["Palette"])
                SetPedComponentVariation(PlayerPedId(), 11, item.info.shirt["Prop"], item.info.shirt["Texture"], item.info.shirt["Palette"])
                TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
            end
        end
    else
        if removeWear then
            TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
            Citizen.Wait(Delay)
            SetPedComponentVariation(PlayerPedId(), type, genderDefaults[type], 0, clothingProps[type]["Palette"])
            TriggerServerEvent("clothing:server:createClothing", type, clothingProps[type])
        else
            TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
            Citizen.Wait(Delay)
            if forceData then
                SetPedComponentVariation(PlayerPedId(), type, forceData["Prop"], forceData["Texture"], forceData["Palette"])
            else
                SetPedComponentVariation(PlayerPedId(), type, item.info["Prop"], item.info["Texture"], item.info["Palette"])
                TriggerServerEvent("BJCore:Server:RemoveItem", item.name, item.amount, item.slot)
            end
        end
    end

    if type == 9 and removeWear then
        clothingProps[type]["Armour"] = GetPedArmour(PlayerPedId())
        SetPedArmour(PlayerPedId(), 0)
    elseif type == 9 and clothingProps[type]["Prop"] ~= -1 and clothingProps[type]["Prop"] ~= genderDefaults[type] then
        SetPedArmour(PlayerPedId(), clothingProps[type]["Armour"])
    end

	ClearPedTasks(PlayerPedId())

    if removeWear and forceData ~= nil then
        TriggerEvent("bj-clothing:client:adjustClothing", type, forceData, item)
    end
end)

RegisterCommand('firstchar', function()
    TriggerEvent('bj-clothing:client:CreateFirstCharacter')
end)

AddEventHandler("clothing:client:settingtattoos", function()
    SettingTattoos = true
end)
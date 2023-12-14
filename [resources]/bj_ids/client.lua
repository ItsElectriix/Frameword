local cardDisplayRunning = false
local forceCancelDisplay = false


local cardImageConfig = {
    ['policebadge'] = {
        offset = {
            x = 10,
            y = -75
        },
        scale = {
            x = 130,
            y = 170
        },
        textColour = { r = 255, g = 255, b = 255 },
        fields = {
            {
                type = 'firstname',
                offset = {
                    x = 145,
                    y = -50
                },
                justify = 1,
                textScale = 0.32
            },
            {
                type = 'lastname',
                offset = {
                    x = 270,
                    y = -50
                },
                justify = 1,
                textScale = 0.32
            },
            {
                type = 'dob',
                offset = {
                    x = 145,
                    y = 10
                },
                justify = 1,
                textScale = 0.32
            },
            {
                type = 'gender',
                offset = {
                    x = 270,
                    y = 10
                },
                justify = 1,
                textScale = 0.32
            },
            {
                type = 'citizenid',
                offset = {
                    x = 230,
                    y = 43
                },
                justify = 1,
                textScale = 0.32
            }
        },
        useFibBadge = true
    }
}

function CreateHeadshot(ped)
    if DoesEntityExist(ped) then
		local mugshot = RegisterPedheadshotTransparent(ped)

		while not IsPedheadshotReady(mugshot) or not IsPedheadshotValid(mugshot) do
			Citizen.Wait(50)
		end

		return mugshot, GetPedheadshotTxdString(mugshot)
	else
		return
	end
end

function getInfoForField(fieldType, PlayerData)
    if fieldType == 'fullname' then
        return PlayerData.firstname..' '..PlayerData.lastname
    elseif fieldType == 'gender' then
        return tostring(PlayerData.gender) == '0' and 'Male' or 'Female'
    elseif PlayerData[fieldType] then
        return PlayerData[fieldType]
    end

    return ''
end

function doFibAnim(ped)
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()
		if not IsPedInAnyVehicle(playerPed, false) then
            local coords = GetEntityCoords(playerPed)
            local prop = CreateObject(`prop_fib_badge`, coords.x, coords.y, coords.z, true, true, true)
		    local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.065, 0.029, -0.035, 80.0, -1.90, 75.0, true, true, false, true, 1, true)
			RequestAnimDict('paper_1_rcm_alt1-9')
            while not HasAnimDictLoaded('paper_1_rcm_alt1-9') do
                Wait(50)
            end
			TaskPlayAnim(playerPed, 'paper_1_rcm_alt1-9', 'player_one_dual-9', 8.0, -8, 10.0, 49, 0, 0, 0, 0)
			Wait(3000)
			ClearPedSecondaryTask(playerPed)
			DeleteObject(prop)
		end
	end)
end

function doCardAnim(ped)
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            local coords = GetEntityCoords(playerPed)
            local prop = CreateObject(`prop_ld_contact_card`, coords.x, coords.y, coords.z, true, true, true)
		    local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.035, 0.039, 0.005, 177.0, 91.90, 180.0, true, true, false, true, 1, true)
			RequestAnimDict('mp_common')
            while not HasAnimDictLoaded('mp_common') do
                Wait(50)
            end
			TaskPlayAnim(playerPed, 'mp_common', 'givetake2_a', 1.0, -1.0, 2500, 49, 1, false, false, false)
			Wait(1800)
			ClearPedSecondaryTask(playerPed)
			DeleteObject(prop)
		end
    end)
end

RegisterNetEvent('bj_ids:client:UseIdCard')
AddEventHandler('bj_ids:client:UseIdCard', function(cardType, data)
    if cardImageConfig[cardType] then
        local players = {}
        local myCoords = GetEntityCoords(PlayerPedId())
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) and #(GetEntityCoords(ped) - myCoords) <= 5.0 then
                table.insert(players, GetPlayerServerId(player))
            end
        end
    
        TriggerServerEvent('bj_ids:server:FlashToPlayers', cardType, players, data)

        if cardImageConfig[cardType].useFibBadge then
            doFibAnim()
        else
            doCardAnim()
        end
    end
end)

RegisterNetEvent('bj_ids:client:FlashId')
AddEventHandler('bj_ids:client:FlashId', function(playerData, cardType)
    if not cardImageConfig[cardType] then
        return
    end

    local cardCfg = cardImageConfig[cardType]

    local playerServerid = GetPlayerFromServerId(playerData.source)

    if cardDisplayRunning then
        forceCancelDisplay = true
        while cardDisplayRunning do
            Wait(1)
        end
    end

    local ped = GetPlayerPed(playerServerid)

    local mugshot, txdString = CreateHeadshot(ped)

    RequestStreamedTextureDict('bj_ids')

    while not HasStreamedTextureDictLoaded('bj_ids', 1) do
        Wait(100)
    end

    local cX, cY = 460, 272
    local x, y = GetActiveScreenResolution()

    local targetX, targetY = (cardCfg.scale.x / x), (cardCfg.scale.y / y)
    local cardX, cardY = (cX / x), (cY / y)

    Citizen.CreateThread(function()
        local endAt = GetGameTimer() + (8 * 1000)
        local startPedPosition = 0.01 + (targetX / 2)
        local startCardPosition = 0.01 + (cardX / 2)
        local modifierX = cardCfg.offset.x / x
        local modifierY = cardCfg.offset.y / x
        local fieldValues = {}
        if cardCfg.fields then
            for _,v in ipairs(cardCfg.fields) do
                table.insert(fieldValues, getInfoForField(v.type, playerData))
            end
        end
        cardDisplayRunning = true
        forceCancelDisplay = false
        while endAt > GetGameTimer() and not forceCancelDisplay do
            if cardCfg.cardOverlayed then
                DrawSprite(txdString, txdString, startPedPosition + modifierX, 0.5 + modifierY, targetX, targetY, 0.0, 255, 255, 255, 1000)
            end
            DrawSprite('bj_ids', cardType, startCardPosition, 0.5, cardX, cardY, 0.0, 255, 255, 255, 1000)
            if not cardCfg.cardOverlayed then
                DrawSprite(txdString, txdString, startPedPosition + modifierX, 0.5 + modifierY, targetX, targetY, 0.0, 255, 255, 255, 1000)
            end
            if cardCfg.fields then
                for i,v in ipairs(cardCfg.fields) do
                    if fieldValues[i] then
                        SetTextFont(0)
                        SetTextProportional(1)
                        SetTextScale(0.0, v.textScale and v.textScale or 0.3)
                        if cardCfg.textColour then
                            SetTextColour(cardCfg.textColour.r, cardCfg.textColour.g, cardCfg.textColour.b, 255)
                        else
                            SetTextColour(0, 0, 0, 255)
                        end
                        SetTextJustification(v.justify and v.justify or 0)
                        SetTextEntry("STRING")
                        AddTextComponentString(fieldValues[i])
                        SetTextWrap(0.01, 0.01 + cardX + (v.justify == 2 and (v.offset.x / x) or 0))
                        DrawText(0.01 + (v.offset.x / x), 0.5 + (v.offset.y / y))
                    end
                end
            end
            Wait(2)
        end
        UnregisterPedheadshot(mugshot)
        forceCancelDisplay = false
        SetTimeout(150, function()
            cardDisplayRunning = false
        end)
    end)
end)

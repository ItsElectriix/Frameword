-- CASINO_DIA_PL    - Falling Diamonds
-- CASINO_HLW_PL    - Falling Skulls
-- CASINO_SNWFLK_PL - Falling Snowflakes

VideoType = 'CASINO_DIA_PL'

inCasino = false
local videoWallRenderTarget = nil
local showBigWin = false

local wheelObject = nil
local baseWheelObject = nil
local isWheelSpinning = false
local curAngle = false

local spinningObject = nil
local spinningCar = nil
local vehicleModel = nil

RegisterNetEvent("luckywheel:client:updateVehicleModel", function(model) vehicleModel = model end)

local casinoLoad = {
    ["npcs"] = true,
    ["vehicle"] = true,
    ["screens"] = false,
    ["audio"]  = false,
    ["wheel"] = false,
}

function IsCasinoLoaded()
    local ret = true
    for k,v in pairs(casinoLoad) do
        if not v then
            ret = false
            break
        end
    end
    return ret
end

function StartCasinoThreads()
    local interior = GetInteriorAtCoords(GetEntityCoords(PlayerPedId()))
    while not IsInteriorReady(interior) do Citizen.Wait(10) end
    RequestStreamedTextureDict('Prop_Screen_Vinewood')
    while not HasStreamedTextureDictLoaded('Prop_Screen_Vinewood') do Citizen.Wait(100); end
    RegisterNamedRendertarget('casinoscreen_01')
    LinkNamedRendertarget(`vw_vwint01_video_overlay`)
    videoWallRenderTarget = GetNamedRendertargetRenderId('casinoscreen_01')
    casinoLoad["screens"] = true
    Citizen.CreateThread(function()
        local lastUpdatedTvChannel = 0
        while inCasino do
            Citizen.Wait(0)

            if videoWallRenderTarget then
                local currentTime = GetGameTimer()
                if showBigWin then
                    setVideoWallTvChannelWin()
                    lastUpdatedTvChannel = GetGameTimer() - 33666
                    showBigWin = false
                else
                    if (currentTime - lastUpdatedTvChannel) >= 42666 then
                        setVideoWallTvChannel()
                        lastUpdatedTvChannel = currentTime
                    end
                end
                SetTextRenderId(videoWallRenderTarget)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                DrawInteractiveSprite('Prop_Screen_Vinewood', 'BG_Wall_Colour_4x4', 0.25, 0.5, 0.5, 1.0, 0.0, 255, 255, 255, 255)
                DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            end
        end
        ReleaseNamedRendertarget('casinoscreen_01')
        videoWallRenderTarget = nil
        showBigWin = false
    end)
end

function setVideoWallTvChannel()
    SetTvChannelPlaylist(0, VideoType, true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(0)
end

function setVideoWallTvChannelWin()
    SetTvChannelPlaylist(0, 'CASINO_WIN_PL', true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(-1)
    SetTvChannel(0)
end

AddEventHandler("casino:client:enteredCasino", function()
    TriggerServerEvent("luckywheel:server:getVehicleModel")
    inCasino = true
    -- SpawnNpcs()
    -- VehicleSpin()
    StartCasinoThreads()
    AmbientAudio()
    CreateLuckyWheel()
    while not IsCasinoLoaded() do Citizen.Wait(500); end
    FreezeEntityPosition(PlayerPedId(), false)
    DoScreenFadeIn(300)
    Wait(2000)
    GetAverageFPS()
end)

local AvFPS = 0

function GetAverageFPS()
    local fpsTab = {}
    local count = 100
    while count > 0 do
        table.insert(fpsTab, math.floor(1.0/GetFrameTime()))
        count = count -1
        Citizen.Wait(0)
    end
    AvFPS = math.average(fpsTab)
    print("Average FPS: "..AvFPS)
end

function math.average(t)
    local sum = 0
    for _,v in pairs(t) do
        sum = sum + v
    end
    return sum / #t
end

AddEventHandler("casino:client:exitedCasino", function()
    CleanUp()
    inCasino = false
end)

AddEventHandler("casino:client:bigWin", function()
    if not inCasino then return; end
    if not IsCasinoLoaded() then return; end
    showBigWin = true
end)

local CasinoAudioBanks = {
    "DLC_VINEWOOD/CASINO_GENERAL",
    "DLC_VINEWOOD/CASINO_SLOT_MACHINES_01",
    "DLC_VINEWOOD/CASINO_SLOT_MACHINES_02",
    "DLC_VINEWOOD/CASINO_SLOT_MACHINES_03",
}

function AmbientAudio()
    Citizen.CreateThread(function()
        local function audioBanks()
            for k,v in pairs(CasinoAudioBanks) do
                while not RequestScriptAudioBank(v, false, -1) do Citizen.Wait(0); end
            end
        end
        audioBanks()
        casinoLoad["audio"] = true
        while inCasino do
            if not IsStreamPlaying() and LoadStream("casino_walla", "DLC_VW_Casino_Interior_Sounds") then
                PlayStreamFromPosition(1111.0, 230.0, -47.0)
            end
            if IsStreamPlaying() and not IsAudioSceneActive("DLC_VW_Casino_General") then
                StartAudioScene("DLC_VW_Casino_General")
            end
            Citizen.Wait(1000)
        end
        if IsStreamPlaying() then StopStream(); end
        if IsAudioSceneActive("DLC_VW_Casino_General") then StopAudioScene("DLC_VW_Casino_General"); end
    end)
end

local spawnedPeds = {}
local bouncers = {
    vector4(1092.8, 207.9, -50.0, 114.31),
    vector4(1088.51, 212.03, -50.0, 183.23),
    vector4(1100.8, 226.52, -49.99, 167.17),
    vector4(1126.7, 241.07, -51.44, 98.35),
    vector4(1136.27, 260.55, -52.44, 210.89),
    vector4(1117.535, 216.65734, -49.43518, 133.48913),
    vector4(1107.4661, 198.33183, -49.4401, 43.199562),
    vector4(1102.126, 235.09516, -49.8408, 230.665),
    vector4(1100.488, 254.21139, -51.24425, 43.59465),
    vector4(1111.5841, 252.24961, -50.44083, 81.221755),
    vector4(1118.0487, 258.49884, -50.44071, 222.51861),
    vector4(1138.0437, 270.8511, -51.44081, 181.6208),
}

local punters = {
    {hash=920595805, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1096.72, 215.88, -50.99, 317.26)},
    {hash=920595805, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1108.11, 207.55, -50.44, 329.61)},
    {hash=920595805, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1107.95, 209.18, -50.44, 190.33)},
    {hash=3293887675, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1113.93, 211.38, -50.44, 103.73)},
    {hash=3045437975, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1148.18, 267.02, -52.84, 353.16)},
    {hash=GetHashKey("ig_djblamryans"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1104.9895, 220.38337, -49.99494, 90.793647)},
    {hash=GetHashKey("ig_kerrymcintosh"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1103.6624, 216.46592, -49.99494, 219.50782)},
    {hash=GetHashKey("ig_tanisha"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1114.9803, 222.78077, -50.43516, 70.782653)},
    {hash=GetHashKey("ig_molly"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1118.754, 227.64901, -50.84075, 124.26529)},
    {hash=GetHashKey("ig_lazlow"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1119.6827, 213.09443, -50.44007, 102.22131)},
    {hash=920595805, scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1117.2431, 211.41589, -50.44007, 16.844791)},
    {hash=920595805, scenario = "WORLD_HUMAN_DRINKING_CASINO_TERRACE", pos = vector4(1097.8565, 213.64723, -49.99494, 295.44165)},
    {hash=GetHashKey("ig_mp_agent14"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1097.8565, 213.64723, -49.99494, 295.44165)},
    {hash=GetHashKey("a_m_y_gencaspat_01"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1110.9592, 211.68292, -49.44014, 358.60452)},
    {hash=GetHashKey("a_m_y_gencaspat_01"), scenario = "WORLD_HUMAN_PARTYING", pos = vector4(1105.0622, 228.372, -49.84074, 243.40371)},
}

local CasinoModels = {
    --GetHashKey("ig_gustavo"),
    GetHashKey("S_F_Y_ClubBar_01"),
    GetHashKey("U_F_M_CasinoCash_01"),
    GetHashKey("U_F_M_Debbie_01"),
    GetHashKey("U_F_M_CasinoShop_01"),
    GetHashKey("s_m_m_bouncer_01"),
    GetHashKey("a_f_y_bevhills_04"),
    GetHashKey("u_m_m_griff_01"),
    GetHashKey("s_f_y_bartender_01"),
    GetHashKey("s_m_y_casino_01"),
    GetHashKey("ig_lazlow"),
    GetHashKey("ig_molly"),
    GetHashKey("ig_tanisha"),
    GetHashKey("ig_kerrymcintosh"),
    GetHashKey("ig_djblamryans"),
    GetHashKey("ig_mp_agent14"),
    GetHashKey("a_m_y_gencaspat_01"),
}

local CasinoAnimDicts = {
    "mini@strip_club@idles@bouncer@base",
}

function SpawnNpcs()
    Citizen.CreateThread(function()
        for k,v in pairs(CasinoModels) do
            RequestModel(v)
            while not HasModelLoaded(v) do Citizen.Wait(0); end
        end

        for k,v in pairs(CasinoAnimDicts) do
            RequestAnimDict(v)
            while not HasAnimDictLoaded(v) do Citizen.Wait(0); end
        end

        bartender = CreatePed(5, `S_F_Y_ClubBar_01`, 1110.33, 208.9, -50.44, 63.96, false, true)
        NPCSetters(bartender)
        SetPedRelationshipGroupHash(bartender, GetHashKey("CIVFEMALE"))

        bartender2 = CreatePed(5, GetHashKey("s_f_y_bartender_01"), 1111.9145, 206.32235, -50.44009, 192.02508, false, true)
        NPCSetters(bartender2)
        SetPedRelationshipGroupHash(bartender2, GetHashKey("CIVFEMALE"))

        cashier = CreatePed(5, `U_F_M_CasinoCash_01`, 1117.83, 220.11, -50.44, 84.8, false, true)
        NPCSetters(cashier)
        SetPedRelationshipGroupHash(cashier, GetHashKey("CIVFEMALE"))

        reception = CreatePed(5, `U_F_M_Debbie_01`, 1087.94, 221.16, -50.2, 182.16, false, true)
        NPCSetters(reception)
        SetPedRelationshipGroupHash(reception, GetHashKey("CIVFEMALE"))

        shop = CreatePed(5, 338154536, 1100.53, 195.59, -50.44, 313.67, false, true)
        NPCSetters(shop)
        SetPedRelationshipGroupHash(shop, GetHashKey("CIVFEMALE"))

        luckywheel = CreatePed(5, GetHashKey("s_m_y_casino_01"), 1112.3366, 228.40847, -50.63584, 136.324, false, true)
        NPCSetters(luckywheel)
        SetPedDefaultComponentVariation(luckywheel)
        SetPedRelationshipGroupHash(luckywheel, GetHashKey("CIVMALE"))

        for k,v in pairs(bouncers) do
            local ped = CreatePed(4, 2681481517, v, false, true)
            SetEntityInvincible(ped, false)
            SetPedArmour(ped, 100)
            SetPedMaxHealth(ped, 100)
            SetPedRelationshipGroupHash(ped, GetHashKey("SECURITY_GUARD"))
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND_PATROL", 0, true)
            SetPedCanRagdoll(ped, false)
            SetPedDiesWhenInjured(ped, false)
            TaskPlayAnim(ped,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
            SetEntityAsMissionEntity(ped)
            table.insert(spawnedPeds, ped)
        end
        
        for k,v in pairs(punters) do
            local ped = CreatePed(4, v.hash, v.pos, false, true)
            SetEntityInvincible(ped, true)
            TaskStartScenarioInPlace(ped, v.scenario, 0, true)
            table.insert(spawnedPeds, ped)
        end
        casinoLoad["npcs"] = true
    end)
end

function NPCSetters(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    table.insert(spawnedPeds, ped)
end

function CleanUp()
    for k,v in pairs(spawnedPeds) do
        DeleteEntity(v)
    end
    for k,v in pairs(CasinoModels) do
        SetModelAsNoLongerNeeded(v)
    end
    DeleteEntity(spinningCar)
    spinningObject = nil
    spinningCar = nil
    spawnedPeds = {}
    DeleteEntity(baseWheelObject)
    DeleteEntity(wheelObject)
    baseWheelObject = nil
    wheelObject = nil
    curAngle = false
    vehicleModel = nil
    for k,v in pairs(casinoLoad) do
        casinoLoad[k] = false
    end
end

function VehicleSpin()
    while vehicleModel == nil do Citizen.Wait(0); end
    Citizen.CreateThread(function()
        while inCasino do
            if spinningObject == nil or spinningObject == 0 or not DoesEntityExist(spinningObject) then
                spinningObject = GetClosestObjectOfType(1100.0, 220.0, -51.0, 10.0, -1561087446, 0, 0, 0)
                CreatePrizeVehicle()
            end
            if spinningObject ~= nil and spinningObject ~= 0 then
                local curHeading = GetEntityHeading(spinningObject)
                local curHeadingCar = GetEntityHeading(spinningCar)
                if curHeading >= 360 then
                    curHeading = 0.0
                    curHeadingCar = 0.0
                elseif curHeading ~= curHeadingCar then
                    curHeadingCar = curHeading
                end
                SetEntityHeading(spinningObject, curHeading + 0.075)
                SetEntityHeading(spinningCar, curHeadingCar + 0.075)
            end
            Citizen.Wait(0)
        end
        spinningObject = nil
    end)
end

function CreatePrizeVehicle()
    if DoesEntityExist(spinningCar) then
        DeleteEntity(spinningCar)
    end
    local busy = true
    BJCore.Functions.SpawnLocalVehicle(vehicleModel, vector3(1100.0, 220.0, -51.0 + 0.05), 0.0, function(veh)
        spinningCar = veh
        SetVehicleDirtLevel(spinningCar, 0.0)
        SetVehicleOnGroundProperly(spinningCar)
        Citizen.Wait(100)
        FreezeEntityPosition(spinningCar, 1)
        casinoLoad["vehicle"] = true
        busy = false
    end)
    while busy do Citizen.Wait(0); end
end

local curSpinning = false
function CreateLuckyWheel()
    local model = GetHashKey('vw_prop_vw_luckywheel_02a')
    local baseWheelModel = GetHashKey('vw_prop_vw_luckywheel_01a')
    Citizen.CreateThread(function()
        RequestModel(baseWheelModel)
        while not HasModelLoaded(baseWheelModel) do Citizen.Wait(0); end

        baseWheelObject = CreateObject(baseWheelModel, 1111.05, 229.81, -53.38, false, false, true)
        SetEntityHeading(baseWheelObject, 0.0)
        SetModelAsNoLongerNeeded(baseWheelModel)
        FreezeEntityPosition(baseWheelObject, true)

        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0); end
        wheelObject = CreateObject(model, 1111.05, 229.81, -50.38, false, false, true)
        SetEntityHeading(wheelObject, 0.0)
        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(wheelObject, true)
        CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_luckylight_on"), false)
        RemoveModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_jackpot_on"), false)
        TriggerServerEvent("luckywheel:server:getCurAngle")
        casinoLoad["wheel"] = true
        while not curAngle do Citizen.Wait(0); end
        SpinWheelInteract()
    end)
end

RegisterNetEvent("luckywheel:client:getCurAngle", function(angle)
    curAngle = angle
    if inCasino then
        while not IsCasinoLoaded() do Citizen.Wait(0); end
        while curSpinning do Citizen.Wait(0); end
        SetEntityRotation(wheelObject, 0.0, curAngle, 0.0, 1, true)
    end
end)

RegisterNetEvent("luckywheel:client:doSpin")
AddEventHandler("luckywheel:client:doSpin", function(prize, totalSpin)
    curSpinning = true
    Citizen.CreateThread(function()
        local rollspeed = 1.0
        local intCnt = 0
        PlaySoundFromCoord(1, 'Spin_Start', 1111.052, 229.8579, -49.133, 'dlc_vw_casino_lucky_wheel_sounds', false, 0, false)
        local degradeRate = 0.001
        local degradeAt = 500
        if AvFPS <= 35 then
            rollspeed = 2.9
            degradeRate = 0.00643
            degradeAt = 600
        elseif AvFPS <= 45 then
            rollspeed = 1.9
            degradeRate = 0.0028
            degradeAt = 500
        elseif AvFPS <= 55 then
            rollspeed = 1.6
            degradeRate = 0.0016
            degradeAt = 650
        elseif AvFPS <= 65 then
            rollspeed = 1.35
            degradeRate = 0.0016
            degradeAt = 500
        elseif AvFPS <= 75 then
            rollspeed = 1.21
            degradeRate = 0.00135
            degradeAt = 500
        elseif AvFPS <= 85 then
            rollspeed = 1.11
            degradeRate = 0.001202
            degradeAt = 500
        elseif AvFPS <= 95 then
            rollspeed = 1.05
            degradeRate = 0.0011
            degradeAt = 500
        elseif AvFPS <= 105 then
            rollspeed = 1.0
            degradeRate = 0.001
            degradeAt = 500
        elseif AvFPS <= 115 then
            rollspeed = 0.995
            degradeRate = 0.001
            degradeAt = 500
        elseif AvFPS <= 125 then
            rollspeed = 0.97
            degradeRate = 0.001
            degradeAt = 485
        elseif AvFPS <= 135 then
            rollspeed = 0.969
            degradeRate = 0.001
            degradeAt = 485
        elseif AvFPS <= 145 then
            rollspeed = 0.94
            degradeRate = 0.001
            degradeAt = 465
        elseif AvFPS <= 155 then
            rollspeed = 0.935
            degradeRate = 0.001
            degradeAt = 465
        elseif AvFPS <= 165 then
            rollspeed = 0.918
            degradeRate = 0.001
            degradeAt = 455
        elseif AvFPS > 165 then
            rollspeed = 0.9
            degradeRate = 0.001
            degradeAt = 440
        end
        local timeStarted = GetCloudTimeAsInt()
        while intCnt < totalSpin do
            local retval = GetEntityRotation(wheelObject, 1)
            --print("diff: "..totalSpin - intCnt)
            if totalSpin - intCnt <= degradeAt then
                rollspeed = rollspeed - degradeRate
                if rollspeed <= 0.05 then
                    rollspeed = 0.05
                end
            end
            intCnt = intCnt + rollspeed
            local _y = retval.y - rollspeed
            SetEntityRotation(wheelObject, 0.0, _y, 0.0, 1, true)
            Citizen.Wait(0)
        end
        print("seconds: "..GetCloudTimeAsInt()-timeStarted)
        if isWheelSpinning == GetPlayerServerId(PlayerId()) then
            TriggerServerEvent("luckywheel:server:completeWheel", GetEntityRotation(wheelObject, 1).y+0.0)
        end
        curSpinning = false
    end)
end)

RegisterNetEvent("luckywheel:client:handleWheelWin", function(winType)
    if not inCasino then return; end
    if not IsCasinoLoaded() then return; end
    GetAverageFPS()
    if not winType then return; end
    if winType == "car" then
        PlaySoundFromCoord(1, 'Win_Car', 1111.052, 229.8579, -49.133, "dlc_vw_casino_lucky_wheel_sounds", false, 0, false)
        TriggerEvent("casino:client:bigWin")
        local players = BJCore.Functions.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 50.0)
        for k,v in pairs(players) do
            TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), 1111.052, 229.8579, -50.133, "confetti", "casinoBigWin1", 0.0, 0.0, 0.0)
            TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), 1109.9965, 230.05085, -50.54921, "confetti", "casinoBigWin2", 0.0, 0.0, 0.0)
            TriggerServerEvent("particle:StartParticleAtLocation", GetPlayerServerId(v), 1111.9033, 230.09379, -50.63533, "confetti", "casinoBigWin3", 0.0, 0.0, 0.0)
        end
    elseif winType == "cash" then
        PlaySoundFromCoord(1, 'Win_Cash', 1111.052, 229.8579, -49.133, "dlc_vw_casino_lucky_wheel_sounds", false, 0, false)
    elseif winType == "chips" then
        PlaySoundFromCoord(1, 'Win_Chips', 1111.052, 229.8579, -49.133, "dlc_vw_casino_lucky_wheel_sounds", false, 0, false)
    elseif winType == "mystery" then
        PlaySoundFromCoord(1, 'Win_Mystery', 1111.052, 229.8579, -49.133, "dlc_vw_casino_lucky_wheel_sounds", false, 0, false)
    end
    WinFlashingLights()
end)

function WinFlashingLights()
    Citizen.CreateThread(function()
        CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_jackpot_on"), false)
        CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_luckylight_on"), false)
        local enabled = false
        local count = 10
        while count ~= 0 do
            Citizen.Wait(500)
            enabled = not enabled
            if enabled then
                RemoveModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_jackpot_on"), false)
                RemoveModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_luckylight_on"), false)
            else 
                CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_jackpot_on"), false)
                CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_luckylight_on"), false)
            end
            count = count - 1
        end
        CreateModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_luckylight_on"), false)
        RemoveModelHide(1111.052, 229.849, -50.641, 5.0, GetHashKey("vw_prop_vw_jackpot_on"), false)
    end)
end

RegisterNetEvent("luckywheel:client:spinWheel")
AddEventHandler("luckywheel:client:spinWheel", function(spinner, prize, totalSpin)
    isWheelSpinning = spinner
    if not IsCasinoLoaded() then return; end
    if spinner and inCasino then
        TriggerEvent("luckywheel:client:doSpin", prize, totalSpin)
    end
end)

RegisterNetEvent("luckywheel:client:startSpin", function()
    if not isWheelSpinning then
        local plyPed = PlayerPedId()
        local animDict, anim = "ANIM_CASINO_A@AMB@CASINO@GAMES@LUCKY7WHEEL@FEMALE", "enter_right_to_baseidle"
        if IsPedMale(plyPed) then animDict = "ANIM_CASINO_A@AMB@CASINO@GAMES@LUCKY7WHEEL@MALE"; end
        while (not HasAnimDictLoaded(animDict)) do RequestAnimDict(animDict) Citizen.Wait(5); end
        local targetPos = vector3(1109.55, 228.88, -49.64)
        TaskGoStraightToCoord(plyPed,  targetPos.x,  targetPos.y,  targetPos.z,  1.0,  -1,  312.2,  0.0)
        local inPosition = false
        while not inPosition do
            local coords = GetEntityCoords(plyPed)
            if coords.x >= (targetPos.x - 0.02) and coords.x <= (targetPos.x + 0.01) and coords.y >= (targetPos.y - 0.01) and coords.y <= (targetPos.y + 0.01) then
                inPosition = true
            end
            Citizen.Wait(0)
        end
        TaskPlayAnim(plyPed, animDict, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
        while IsEntityPlayingAnim(plyPed, animDict, anim, 3) do
            Citizen.Wait(0)
            DisableAllControlActions(0)
        end
        TaskPlayAnim(plyPed, animDict, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
        while IsEntityPlayingAnim(plyPed, animDict, 'enter_to_armraisedidle', 3) do
            Citizen.Wait(0)
            DisableAllControlActions(0)
        end
        TriggerServerEvent("luckywheel:server:spinWheel")
        TaskPlayAnim(plyPed, animDict, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
    end
end)

function SpinWheelInteract()
    Citizen.CreateThread(function()
        local lastPress = 0
        while inCasino do
            if not isWheelSpinning then
                local plyPos = GetEntityCoords(PlayerPedId())
                local dist = #(plyPos - vector3(1109.76, 227.89, -49.64))
                if dist < 1.5 then
                    BJCore.Functions.DrawText3D(1109.76, 227.89, -49.64, "[~g~E~w~] Spin Wheel ($"..Config.LucklyWheelCost..")")
                    if IsControlJustReleased(0, 38) then
                        if GetGameTimer() - lastPress > 1000 then
                            TriggerServerEvent("luckywheel:server:attemptWheelSpin")
                        end
                        lastPress = GetGameTimer()
                    end
                end
            else
                Citizen.Wait(500)
            end
            Citizen.Wait(0)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return; end
    CleanUp()
    DeleteEntity(baseWheelObject)
    DeleteEntity(wheelObject)
end)
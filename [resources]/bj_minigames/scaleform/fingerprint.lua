ScaleformMinigames['Fingerprint'] = function(mgData)
    Callback = {}
    Minutes = 3
    Seconds = 0
    Seconds2 = 0
    Ms = 0
    Ms2 = 0
    Lifes = 6

    Ar = GetAspectRatio(0)
    Ard = (1.778 / Ar)

    G_0 = 1
    G_1 = false
    G_2 = false
    G_3 = ""
    G_4 = 1
    G_5 = 0
    G_6 = 0
    G_7 = {
        [1] = {
            [1] = 1,
            [2] = 4,
            [3] = 6,
            [4] = 7,
            [5] = 0
        },
        [2] = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
            [4] = 4,
            [5] = 1
        },
        [3] = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
            [4] = 4,
            [5] = 2
        },
        [4] = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
            [4] = 4,
            [5] = 3
        }
    }
    G_8 = {
        [1] = {
            [1] = 0.536,
            [2] = true
        },
        [2] = {
            [1] = 0.662,
            [2] = true
        },
        [3] = {
            [1] = 0.782,
            [2] = true
        },
        [4] = {
            [1] = 0.905,
            [2] = true
        }
    }
    G_9 = 31
    G_10 = {
        [1] = -0.0035,
        [2] = 0.008,
        [3] = 0.0195,
        [4] = 0.031,
        [5] = 0.0425,
        [6] = 0.054,
        [7] = 0.0655,
        [8] = 0.077,
        [9] = 0.0885,
        [10] = 0.1,
        [11] = 0.1115,
        [12] = 0.123,
        [13] = 0.1345,
        [14] = 0.146,
        [15] = 0.1575,
        [16] = 0.169,
        [17] = 0.1805,
        [18] = 0.192,
        [19] = 0.2035,
        [20] = 0.215,
        [21] = 0.2265,
        [22] = 0.238,
        [23] = 0.2495,
        [24] = 0.261,
        [25] = 0.2725,
        [26] = 0.284,
        [27] = 0.2955,
        [28] = 0.307,
        [29] = 0.3185,
        [30] = 0.33,
        [31] = 0.3415
    }
    G_11 = {
        [1] = {
            [1] = 0.983,
            [2] = 0.255
        },
        [2] = {
            [1] = 0.983,
            [2] = 0.308
        },
        [3] = {
            [1] = 0.983,
            [2] = 0.361
        },
        [4] = {
            [1] = 0.983,
            [2] = 0.414
        },
        [5] = {
            [1] = 0.983,
            [2] = 0.467
        },
        [6] = {
            [1] = 0.983,
            [2] = 0.52
        }
    }
    G_12 = {
        [1] = 0,
        [2] = 1,
        [3] = 2
    }
    G_13 = nil
    G_14 = {
        [1] = 0.33,
        [2] = 0.34,
        [3] = 0.35,
        [4] = 0.36,
        [5] = 0.37,
        [6] = 0.38,
        [7] = 0.39,
        [8] = 0.4,
        [9] = 0.41,
        [10] = 0.42,
        [11] = 0.43,
        [12] = 0.44,
        [13] = 0.45,
        [14] = 0.46,
        [15] = 0.47,
        [16] = 0.48,
        [17] = 0.49,
        [18] = 0.5,
        [19] = 0.51,
        [20] = 0.52,
        [21] = 0.53,
        [22] = 0.54,
        [23] = 0.55,
        [24] = 0.56,
        [25] = 0.57,
        [26] = 0.58,
        [27] = 0.59,
        [28] = 0.6,
        [29] = 0.61,
        [30] = 0.62,
        [31] = 0.63,
        [32] = 0.64,
        [33] = 0.65,
        [34] = 0.66,
        [35] = 0.67,
    }
    G_20 = false

    function Generate()
        Citizen.CreateThread(function()
            for level = 1, 4, 1 do
                for instance = 1, 86, 1 do
                    local array = {1, 2, 3, 4, 5, 6, 7, 8}

                    for dat = 1, 8, 1 do
                        local i = math.random(#array)

                        G_Table[level][instance][dat][4] = array[i]
                        table.remove(array, i)
                    end
                end
            end
            StartHack()
        end)
    end

    function StartHack()
        G_0 = 1
        G_6 = 0
        Seconds = 0
        Seconds2 = 0
        Ms = 0
        Ms2 = 0
        G_15 = true
        G_1 = false
        G_16 = false
        RequestStreamedTextureDict("mphackinggamebg", false)
        RequestStreamedTextureDict("mpfclone_decor", false)
        RequestStreamedTextureDict("mphackinggame", false)
        RequestStreamedTextureDict("mphackinggamewin", false)
        RequestStreamedTextureDict("mphackinggamewin2", false)
        RequestStreamedTextureDict("mphackinggamewin3", false)
        RequestStreamedTextureDict("mpfclone_common", false)
        RequestStreamedTextureDict("mphackinggameoverlay", false)
        RequestStreamedTextureDict("mphackinggameoverlay1", false)
        RequestStreamedTextureDict("mpfclone_print0", false)
        RequestStreamedTextureDict("mpfclone_print1", false)
        RequestStreamedTextureDict("mpfclone_print2", false)
        RequestStreamedTextureDict("mpfclone_print3", false)
        while not HasStreamedTextureDictLoaded("mphackinggame")
        or not HasStreamedTextureDictLoaded("mpfclone_common")
        or not HasStreamedTextureDictLoaded("mpfclone_decor")
        or not HasStreamedTextureDictLoaded("mphackinggamewin")
        or not HasStreamedTextureDictLoaded("mphackinggamebg")
        or not HasStreamedTextureDictLoaded("mpfclone_print0")
        or not HasStreamedTextureDictLoaded("mpfclone_print1")
        or not HasStreamedTextureDictLoaded("mpfclone_print2")
        or not HasStreamedTextureDictLoaded("mpfclone_print3")
        do
            Citizen.Wait(10)
        end
        G_17 = GetSoundId()
        F_0()
        local G_23 = F_13("instructional_buttons")
        G_18 = function()
            G_19 = true
            Citizen.CreateThread(function()
                G_19 = false
                G_9 = 31
                while true do
                    if G_1 == true or G_19 == true then
                        return
                    end
                    Citizen.Wait(1920)
                    while G_16 == true do
                        Citizen.Wait(10)
                    end
                    if G_9 == 0 then
                        G_6 = 0
                        F_0()
                        return G_18()
                    else
                        PlaySoundFrontend(-1, "Scramble_Countdown_Med", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                        G_9 = G_9 - 1
                    end
                end
            end)
        end
        Citizen.CreateThread(function()
            while G_15 do
                F_1()
                Citizen.Wait(1)
            end
        end)
        Citizen.CreateThread(function()
            while true do
                if IsControlJustReleased(2, 201) then
                    if G_13[G_4][3] == true then
                        G_13[G_4][3] = false
                        G_6 = G_6 - 1
                        PlaySoundFrontend(-1, "Deselect_Print_Tile", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                    elseif G_13[G_4][3] == false and G_6 < 4 then
                        G_13[G_4][3] = true
                        G_6 = G_6 + 1
                        PlaySoundFrontend(-1, "Select_Print_Tile", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                    end
                elseif IsControlJustReleased(2, 204) then
                    if G_6 == 4 then
                        F_2()
                        F_3()
                    end
                elseif IsControlJustReleased(2, 187) then
                    F_2()
                    if G_4 < 7 then
                        G_4 = G_4 + 2
                    elseif G_4 == 7 then
                        G_4 = 1
                    elseif G_4 == 8 then
                        G_4 = 2
                    end
                elseif IsControlJustReleased(2, 188) then
                    F_2()
                    if G_4 > 2 then
                        G_4 = G_4 - 2
                    elseif G_4 == 1 then
                        G_4 = 7
                    elseif G_4 == 2 then
                        G_4 = 8
                    end
                elseif IsControlJustReleased(2, 189) then
                    F_2()
                    if G_4 ~= 1 then
                        G_4 = G_4 - 1
                    else
                        G_4 = 8
                    end
                elseif IsControlJustReleased(2, 190) then
                    F_2()
                    if G_4 ~= 8 then
                        G_4 = G_4 + 1
                    else
                        G_4 = 1
                    end
                elseif IsControlJustReleased(2, 194) then
                    F_8("Hack aborted")
                    G_1 = true
                    return
                end
                if G_1 then
                    return
                end
                Citizen.Wait(1)
            end
        end)
        PlaySoundFrontend(G_17, "Background_Hum", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
        Citizen.CreateThread(function()
            while true do
                if G_1 then
                    return
                end
                F_4("mphackinggamebg", "bg", 0.5, 0.5, 1920.0, 1920.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggamewin", "tech_3_0", 0.090, 0.489, 980.0, 1000.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggamewin", "tech_3_0", 0.090, 0.489, 980.0, 1000.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggamewin2", "tech_2_0", 0.950, 0.642, 840.0, 800.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggamewin3", "tech_4_1", 0.065, 0.670, 950.0, 1000.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mpfclone_common", "background_layout", 0.5, 0.5, 1264.0, 1600.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "Scrambler_BG", 0.169, 0.840, 400.0, 64.0, 0.0, 255, 255, 255, 125, 0)
                for i = 1, G_9, 1 do
                    F_4("mphackinggame", "Scrambler_Fill_Segment", G_10[i], 0.840, 12.0, 80.0, 0.0, 255, 255, 255, 250, 0)
                end
                F_4("mphackinggame", "numbers_0", 0.06, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "numbers_"..Minutes, 0.091, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "Numbers_Colon", 0.122, 0.154, 40.0, 60., 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "numbers_"..Seconds, 0.153, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "numbers_"..Seconds2, 0.184, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "Numbers_Colon", 0.215, 0.154, 40.0, 60., 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "numbers_"..Ms, 0.246, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                F_4("mphackinggame", "numbers_"..Ms2, 0.277, 0.154, 40.0, 60.0, 0.0, 255, 255, 255, 250, 0)
                for i = 1, Lifes, 1 do
                    F_4("mphackinggame", "Life", G_11[i][1], G_11[i][2], 64.0, 100.0, 0.0, 255, 255, 255, 250, 0)
                end
                F_5()
                F_4("mpfclone_common", "disc_A"..G_12[1], 0.983, 0.660, 90.0, 126.5822784810127, 0.0, 255, 255, 255, 255, 0)
                F_4("mpfclone_common", "disc_B"..G_12[2], 0.983, 0.660, 90.0, 126.5822784810127, 0.0, 255, 255, 255, 255, 0)
                F_4("mpfclone_common", "disc_C"..G_12[3], 0.983, 0.660, 90.0, 126.5822784810127, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggameoverlay", "grid_rgb_pixels", 0.5, 0.5, 1920.0, 1920.0, 0.0, 255, 255, 255, 255, 0)
                F_4("mphackinggameoverlay1", "ScreenGrid", 0.5, 0.5, 1920.0, 1920.0, 0.0, 255, 255, 255, 255, 0)
                for i = 1, 4, 1 do
                    if G_8[i][2] == true then
                        F_4("mpfclone_common", "decypher_"..i, G_8[i][1], 0.818, 120.0, 200.0, 0.0, 255, 255, 255, 255, 0)
                    elseif G_8[i][2] == false then
                        F_4("mpfclone_common", "disabled_signal", G_8[i][1], 0.818, 101.0, 181.0, 0.0, 255, 255, 255, 255, 0)
                    end
                end
                F_4("mpfclone_common", "Decyphered_Selector", G_8[G_0][1], 0.818, 160.0, 260.0, 0.0, 255, 255, 255, 255, 0);
                for i = 1, 8, 1 do
                    if G_13[i][3] == true then
                        F_4("mpfclone_print"..G_7[G_0][5], "fp"..G_0.."_comp_"..G_13[i][4], G_13[i][1], G_13[i][2], 128.0, 220.0, 0.0, 255, 255, 255, 250, 0)
                    else
                        F_4("mpfclone_print"..G_7[G_0][5], "fp"..G_0.."_comp_"..G_13[i][4], G_13[i][1], G_13[i][2], 128.0, 220.0, 0.0, 255, 255, 255, 120, 0)
                    end
                end
                F_4("MPFClone_Common", "selectorFrame", G_13[G_4][1], G_13[G_4][2], 180.0, 285.0, 0.0, 255, 255, 255, 250, 0);
                if G_21 == true then
                    PlaySoundFrontend(-1, "Window_Draw", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                    for i = 1, 8, 1 do
                        F_4("mpfclone_print"..G_7[G_0][5], "fp"..G_0.."_"..i, 0.674, 0.379, 400.0, 800.0, 0.0, 255, 255, 255, GetRandomIntInRange(127, 255), 0)
                    end
                    if G_20 == true then
                        F_4("mphackinggame", "Loading_Window", 0.5, 0.5, 450.0, 250.0, 0.0, 255, 255, 255, 255, 0)
                        for j = 2, G_5, 1 do
                            F_4("mphackinggame", "Loading_Bar_Segment", G_14[j], 0.520, 15.0, 90.0, 0.0, 255, 255, 255, 255, 0)
                        end
                    end
                elseif not G_21 then
                    for i = 1, 8, 1 do
                        F_4("mpfclone_print"..G_7[G_0][5], "fp"..G_0.."_"..i, 0.674, 0.379, 400.0, 800.0, 0.0, 255, 255, 255, 120, 0)
                    end
                end
                if G_22 == true then
                    F_4("mphackinggame", G_3, 0.5, 0.5, 600.0, 250.0, 0.0, 255, 255, 255, 255, 0)
                end
                DrawScaleformMovieFullscreen(G_23, 255, 255, 255, 255, 0)
                Citizen.Wait(1)
            end
        end)
        G_18()
        Citizen.CreateThread(function()
            while true do
                if G_1 then
                    return
                end
                for i = 1, 3, 1 do
                    if G_12[i] < 2 then
                        G_12[i] = G_12[i] + 1
                    else
                        G_12[i] = 0
                    end
                end
                Citizen.Wait(1000)
            end
        end)
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1)
                if G_1 then
                    return
                end
                if Ms2 == 0 then
                    Ms2 = 9
                    if Ms == 0 then
                        Ms = 9
                        if Seconds2 == 0 then
                            Seconds2 = 9
                            if Seconds == 0 then
                                Seconds = 5
                                Minutes = Minutes - 1
                            else
                                Seconds = Seconds - 1
                            end
                        else
                            Seconds2 = Seconds2 - 1
                        end
                    else
                        Ms = Ms - 1
                    end
                else
                    Ms2 = Ms2 - 1
                end
            end
        end)
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1)
                if G_1 == true then
                    return
                end
                if Seconds == 0 and Seconds2 == 0 and Minutes == 0 then
                    G_1 = true
                    F_8("Time is up!")
                    return
                end
            end
        end)
    end

    function F_3()
        local a
        local c = 0

        G_2 = false
        G_5 = 0
        G_16 = true
        G_21 = true
        G_20 = true
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(50)
                G_5 = G_5 + 1
                if G_5 == 35 then
                    G_20 = false
                    G_21 = false
                    G_22 = true
                    return
                end
            end
        end)
        if G_6 == 4 then
            for i = 1 , 8, 1 do
                if G_13[i][3] == true then
                    for j = 1, 4, 1 do
                        if G_13[i][4] == G_7[G_0][j] then
                            c = c + 1
                        end
                    end
                end
            end
            if c == 4 then
                a = true
            else
                a = false
            end
            Citizen.Wait(1000)
            Citizen.CreateThread(function()
                while true do
                    if a == true then
                        PlaySoundFrontend(-1, "Target_Match", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                        G_3 = "Correct_0"
                        Citizen.Wait(500)
                        G_3 = "Correct_1"
                        Citizen.Wait(500)
                    elseif a == false then
                        PlaySoundFrontend(-1, "No_Match", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
                        G_3 = "Incorrect_0"
                        Citizen.Wait(500)
                        G_3 = "Incorrect_1"
                        Citizen.Wait(500)
                    end
                    if G_1 == true or G_2 == true then
                        return
                    end
                    Citizen.Wait(1)
                end
            end)
            Citizen.Wait(3500)
            G_2 = true
            if a == true then
                if G_0 < LevelCount then
                    F_0()
                    G_0 = G_0 + 1
                else
                    G_1 = true
                    F_7()
                end
            else
                if Lifes > 1 then
                    F_0()
                    G_18()
                    Lifes = Lifes - 1
                else
                    G_1 = true
                    F_8("Out of life")
                end
            end
            F_6()
            G_6 = 0
            G_9 = 31
            G_22 = false
            G_16 = false
            G_21 = false
            G_20 = false
        end
    end

    function F_7()
        G_1 = true
        StopSound(G_17)
        ReleaseSoundId(G_17)
        TriggerEvent('bj:minigameResult', 'Fingerprint', true, {})
        StopSound(G_17)
        ReleaseSoundId(G_17)
        G_15 = false
    end

    function F_8(reason)
        G_1 = true
        TriggerEvent('bj:minigameResult', 'Fingerprint', false, { reason = reason})
        StopSound(G_17)
        ReleaseSoundId(G_17)
        G_15 = false
    end

    function F_2()
        PlaySoundFrontend(-1, "Cursor_Move", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
    end

    function F_6()
        for i = 1, 8, 1 do
            G_13[i][3] = false
        end
    end

    function F_0()
        local ok = false
        local random

        repeat
            random = math.random(86)
            if random ~= SelectedLevelData then
                ok = true
            else
                ok = false
            end
        until ok == true
        SelectedLevelData = random
        G_13 = G_Table[G_0][random]
    end

    function F_4(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
        DrawSprite(arg1, arg2, F_9(arg3), arg4, (F_10(arg5) * Ard), F_10(arg6), arg7, arg8, arg9, arg10, arg11, arg12)
    end

    function F_5()
        if (Seconds2 % 2 == 0) then
            F_4("MPFClone_Decor", "techaration_0", 0.5, 0.5, 1264.0, 1600.0, 0.0, 255, 255, 255, 255, 0)
        else
            F_4("MPFClone_Decor", "techaration_1", 0.5, 0.5, 1264.0, 1600.0, 0.0, 255, 255, 255, 255, 0)
        end
    end

    function F_1() DisableControlAction(0, 73, false) DisableControlAction(0, 24, true) DisableControlAction(0, 257, true) DisableControlAction(0, 25, true) DisableControlAction(0, 263, true) DisableControlAction(0, 32, true) DisableControlAction(0, 34, true) DisableControlAction(0, 31, true) DisableControlAction(0, 30, true) DisableControlAction(0, 45, true) DisableControlAction(0, 22, true) DisableControlAction(0, 44, true) DisableControlAction(0, 37, true) DisableControlAction(0, 23, true) DisableControlAction(0, 288, true) DisableControlAction(0, 289, true) DisableControlAction(0, 170, true) DisableControlAction(0, 167, true) DisableControlAction(0, 73, true) DisableControlAction(2, 199, true) DisableControlAction(0, 47, true) DisableControlAction(0, 264, true) DisableControlAction(0, 257, true) DisableControlAction(0, 140, true) DisableControlAction(0, 141, true) DisableControlAction(0, 142, true) DisableControlAction(0, 143, true) end

    function F_9(arg1)
        return (0.5 - ((0.5 - arg1) / Ar))
    end

    function F_10(arg1)
        return arg1 / 1920.0
    end

    function F_11(ControlButton)
        N_0xe83a3e3557a56640(ControlButton)
    end

    function F_12(text)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentScaleform(text)
        EndTextCommandScaleformString()
    end

    function F_13(scaleform)
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
        F_11(GetControlInstructionalButton(2, 194, true))
        F_12("Abort Hack")
        PopScaleformMovieFunctionVoid()

        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(1)
        F_11(GetControlInstructionalButton(2, 191, true))
        F_12("Select")
        PopScaleformMovieFunctionVoid()

        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(2)
        F_11(GetControlInstructionalButton(2, 190, true))
        F_12("")
        PopScaleformMovieFunctionVoid()

        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(3)
        F_11(GetControlInstructionalButton(2, 189, true))
        F_12("")
        PopScaleformMovieFunctionVoid()

        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(4)
        F_11(GetControlInstructionalButton(2, 187, true))
        F_12("")
        PopScaleformMovieFunctionVoid()

        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(5)
        F_11(GetControlInstructionalButton(2, 188, true))
        F_12("Move Selector")
        PopScaleformMovieFunctionVoid()

    	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(6)
        F_11(GetControlInstructionalButton(2, 192, true))
        F_12("Check Selections")
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

    if mgData.levels ~= nil then
        if mgData.levels <= 0 then
            LevelCount = 1
        elseif mgData.levels > 3 then
            LevelCount = 4
        else
            LevelCount = mgData.levels
        end
    else
        LevelCount = 4
    end
    if mgData.attempts ~= nil then
        if mgData.attempts <= 0 then
            Lifes = 1
        elseif mgData.attempts > 6 then
            Lifes = 6
        else
            Lifes = mgData.attempts
        end
    else
        Lifes = 5
    end
    if mgData.timer ~= nil then
        if mgData.timer < 1 then
            CountdownTime = 60000
            Minutes = 1
        elseif mgData.timer > 9 then
            CountdownTime = 540000
            Minutes = 9
        else
            CountdownTime = mgData.timer * 60000
            Minutes = mgData.timer
        end
    else
        CountdownTime = 180000
        Minutes = 3
    end
    for k, v in ipairs(G_8) do
        if k > LevelCount then
            v[2] = false
        else
            v[2] = true
        end
    end
    Generate()
end
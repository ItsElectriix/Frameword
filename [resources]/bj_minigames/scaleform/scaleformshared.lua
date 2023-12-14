local countdownRunning = false

function StopCountdown()
    countdownRunning = false
end

function DoCountdown(scaleform, length, cb)
    Citizen.CreateThread(function()
        countdownRunning = true
        local targetTime = GetGameTimer() + length
        G_17 = GetSoundId()
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
        PlaySoundFrontend(G_17, "Background_Hum", "DLC_H3_Cas_Finger_Minigame_Sounds", true)
        G_18()
        while countdownRunning do
            local currTime = GetGameTimer()
            local timeRemaining = targetTime - currTime
            if timeRemaining < 0 then
                cb()
                countdownRunning = false
            end
            local min, sec, ms = 0, 0, 0
            if timeRemaining > 60000 then
                min = math.floor(timeRemaining / 60000)
                timeRemaining = timeRemaining % (min * 60000)
            end
            if timeRemaining > 1000 then
                sec = math.floor(timeRemaining / 1000)
                timeRemaining = timeRemaining % (sec * 1000)
            end
            ms = timeRemaining
            if ms < 0 then ms = 0 end
            PushScaleformMovieFunction(scaleform, "SET_COUNTDOWN")
            PushScaleformMovieFunctionParameterInt(min)
            PushScaleformMovieFunctionParameterInt(sec)
            PushScaleformMovieFunctionParameterInt(ms)
            PopScaleformMovieFunctionVoid()
            Wait(2)
        end
        G_1 = true
        StopSound(G_17)
        ReleaseSoundId(G_17)
    end)
end
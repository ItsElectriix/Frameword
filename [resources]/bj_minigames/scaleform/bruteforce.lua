local passwords = {
    "HONGKONG",
    "ORIGINAL",
    "PASSWORD",
    "AARDVARK",
    "CONGRESS",
    "EXAMPLAR",
    "FEATHERS",
    "FISHCAKE",
    "JOKINGLY",
    "PARSNIPS",
    "SCRAMBLE",
    "SCAMMERS",
    "THROTTLE"
}

ScaleformMinigames['Bruteforce'] = function(mgData)
    local scaleform = nil
    local ClickReturn
    local gamePassword = passwords[math.random(1, #passwords)]
    local isRunning = true

    local data = {
        difficulty = mgData.difficulty and mgData.difficulty or 5,
        attempts = mgData.attempts and mgData.attempts or 5,
        timer = mgData.timeout and mgData.timeout or false,
        background = mgData.background and mgData.background or 0
    }

    local maxAttempts = data.attempts

    if data.difficulty > 5 then data.difficulty = 5 end
    if data.difficulty < 1 then data.difficulty = 1 end

    local maxSpeed = (255 / 5 * data.difficulty)

    Citizen.CreateThread(function()
        function Initialize(scaleform)
            local scaleform = RequestScaleformMovieInteractive(scaleform)
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end
    
            PushScaleformMovieFunction(scaleform, "SET_LABELS") --this allows us to label every item inside My Computer
            PushScaleformMovieFunctionParameterString("Local Disk (C:)")
            PushScaleformMovieFunctionParameterString("Network")
            PushScaleformMovieFunctionParameterString("External Device (J:)")
            PushScaleformMovieFunctionParameterString("HackConnect.exe")
            PushScaleformMovieFunctionParameterString("BruteForce.exe")
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_BACKGROUND") --We can set the background of the scaleform, so far 0-6 works.
            PushScaleformMovieFunctionParameterInt(data.background)
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "ADD_PROGRAM") --We add My Computer application to the scaleform
            PushScaleformMovieFunctionParameterFloat(1.0) -- Position in the scaleform most left corner
            PushScaleformMovieFunctionParameterFloat(4.0)
            PushScaleformMovieFunctionParameterString("My Computer")
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "ADD_PROGRAM") --Power Off app.
            PushScaleformMovieFunctionParameterFloat(6.0) -- Position in the scaleform most right corner
            PushScaleformMovieFunctionParameterFloat(6.0)
            PushScaleformMovieFunctionParameterString("Power Off")
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED") --Column speed used in the minigame, (0-255). 
            PushScaleformMovieFunctionParameterInt(0)
            PushScaleformMovieFunctionParameterInt(math.random((170 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(1)
            PushScaleformMovieFunctionParameterInt(math.random((180 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(2)
            PushScaleformMovieFunctionParameterInt(math.random((190 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(3)
            PushScaleformMovieFunctionParameterInt(math.random((200 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(4)
            PushScaleformMovieFunctionParameterInt(math.random((210 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(5)
            PushScaleformMovieFunctionParameterInt(math.random((220 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(6)
            PushScaleformMovieFunctionParameterInt(math.random((230 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            PushScaleformMovieFunction(scaleform, "SET_COLUMN_SPEED")
            PushScaleformMovieFunctionParameterInt(7)
            PushScaleformMovieFunctionParameterInt(math.random((240 / 5 * data.difficulty),maxSpeed))
            PopScaleformMovieFunctionVoid()
    
            return scaleform
        end
    
        scaleform = Initialize("HACKING_PC") -- THE SCALEFORM WE ARE USING: https://scaleform.devtesting.pizza/#HACKING_PC
    
        while isRunning do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            PushScaleformMovieFunction(scaleform, "SET_CURSOR") --We use this scaleform function to define what input is going to move the cursor
            PushScaleformMovieFunctionParameterFloat(GetControlNormal(0, 239)) 
            PushScaleformMovieFunctionParameterFloat(GetControlNormal(0, 240))
            PopScaleformMovieFunctionVoid()
            if IsDisabledControlJustPressed(0,24) then -- IF LEFT CLICK IS PRESSED WE SELECT SOMETHING IN THE SCALEFORM
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT_SELECT")
                ClickReturn = PopScaleformMovieFunction()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            elseif IsDisabledControlJustPressed(0, 25) then -- IF RIGHT CLICK IS PRESSED WE GO BACK.
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT_BACK")
                PopScaleformMovieFunctionVoid()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            end
        end
    end)
    
    Citizen.CreateThread(function()
        while isRunning do
            if HasScaleformMovieLoaded(scaleform) then
                FreezeEntityPosition(PlayerPedId(), true) --If the user is in scaleform we should freeze him to prevent movement.
                DisableControlAction(0, 24, true) --LEFT CLICK disabled while in scaleform
                DisableControlAction(0, 25, true) --RIGHT CLICK disabled while in scaleform
                if IsScaleformMovieMethodReturnValueReady(ClickReturn) then -- old native?
                    ProgramID = GetScaleformMovieFunctionReturnInt(ClickReturn)
                    print("ProgramID: "..ProgramID) -- Prints the ID of the Apps we click on inside the scaleform, very useful.
    
                    if ProgramID == 82 then --HACKCONNECT.EXE
                        PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
    
                    elseif ProgramID == 83 then  --BRUTEFORCE.EXE
                        PushScaleformMovieFunction(scaleform, "RUN_PROGRAM")
                        PushScaleformMovieFunctionParameterFloat(83.0)
                        PopScaleformMovieFunctionVoid()
    
                        PushScaleformMovieFunction(scaleform, "SET_ROULETTE_WORD")
                        PushScaleformMovieFunctionParameterString(gamePassword)
                        PopScaleformMovieFunctionVoid()

                        PushScaleformMovieFunction(scaleform, "SET_LIVES")
                        PushScaleformMovieFunctionParameterInt(data.attempts) --We set how many lives our user has before he fails the bruteforce.
                        PushScaleformMovieFunctionParameterInt(maxAttempts)
                        PopScaleformMovieFunctionVoid()

                        if mgData.timer then
                            DoCountdown(scaleform, mgData.timer, function()
                                PlaySoundFrontend(-1, "HACKING_FAILURE", "", true)
                                PushScaleformMovieFunction(scaleform, "SET_ROULETTE_OUTCOME")
                                PushScaleformMovieFunctionParameterBool(false)
                                PushScaleformMovieFunctionParameterString("BRUTEFORCE FAILED!")
                                PopScaleformMovieFunctionVoid()

                                Wait(3500) --WE WAIT 3.5 seconds here aswell to let the bruteforce message sink in before exiting.
                                PushScaleformMovieFunction(scaleform, "CLOSE_APP")
                                PopScaleformMovieFunctionVoid()

                                PushScaleformMovieFunction(scaleform, "OPEN_ERROR_POPUP")
                                PushScaleformMovieFunctionParameterBool(true)
                                PushScaleformMovieFunctionParameterString("MEMORY LEAK DETECTED, DEVICE SHUTTING DOWN")
                                PopScaleformMovieFunctionVoid()

                                Wait(2500)
                                isRunning = false
                                SetScaleformMovieAsNoLongerNeeded(scaleform)
                                PopScaleformMovieFunctionVoid()
                                FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                                DisableControlAction(0, 24, false) --LEFT CLICK enabled again
                                DisableControlAction(0, 25, false) --RIGHT CLICK enabled again
                                TriggerEvent('bj:minigameResult', 'Bruteforce', false, {})
                            end)
                        end
    
                    elseif ProgramID == 87 then --IF YOU CLICK THE WRONG LETTER IN BRUTEFORCE APP
                        data.attempts = data.attempts - 1
    
                        PushScaleformMovieFunction(scaleform, "SET_ROULETTE_WORD")
                        PushScaleformMovieFunctionParameterString(gamePassword)
                        PopScaleformMovieFunctionVoid()
    
                        PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
                        PushScaleformMovieFunction(scaleform, "SET_LIVES")
                        PushScaleformMovieFunctionParameterInt(data.attempts) --We set how many lives our user has before he fails the bruteforce.
                        PushScaleformMovieFunctionParameterInt(maxAttempts)
                        PopScaleformMovieFunctionVoid()
    
                    elseif ProgramID == 92 then --IF YOU CLICK THE RIGHT LETTER IN BRUTEFORCE APP, you could add more lives here.
                        PlaySoundFrontend(-1, "HACKING_CLICK_GOOD", "", false)
    
                    elseif ProgramID == 86 then --IF YOU SUCCESSFULY GET ALL LETTERS RIGHT IN BRUTEFORCE APP
                        PlaySoundFrontend(-1, "HACKING_SUCCESS", "", true)
                        
                        StopCountdown()
                        
                        PushScaleformMovieFunction(scaleform, "SET_ROULETTE_OUTCOME")
                        PushScaleformMovieFunctionParameterBool(true)
                        PushScaleformMovieFunctionParameterString("BRUTEFORCE SUCCESSFUL!")
                        PopScaleformMovieFunctionVoid()
                        
                        Wait(2800) --We wait 2.8 to let the bruteforce message sink in before we continue
                        PushScaleformMovieFunction(scaleform, "CLOSE_APP")
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "OPEN_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterBool(true)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterInt(35)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_TIME")
                        PushScaleformMovieFunctionParameterInt(35)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_MESSAGE")
                        PushScaleformMovieFunctionParameterString("Writing data to buffer..")
                        PushScaleformMovieFunctionParameterFloat(2.0)
                        PopScaleformMovieFunctionVoid()
                        Wait(1500)
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_MESSAGE")
                        PushScaleformMovieFunctionParameterString("Executing malicious code..")
                        PushScaleformMovieFunctionParameterFloat(2.0)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_TIME")
                        PushScaleformMovieFunctionParameterInt(15)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterInt(75)
                        PopScaleformMovieFunctionVoid()
                        
                        Wait(1500)
                        PushScaleformMovieFunction(scaleform, "OPEN_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterBool(false)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "OPEN_ERROR_POPUP")
                        PushScaleformMovieFunctionParameterBool(true)
                        PushScaleformMovieFunctionParameterString("MEMORY LEAK DETECTED, DEVICE SHUTTING DOWN")
                        PopScaleformMovieFunctionVoid()
                        
                        Wait(3500)
                        SetScaleformMovieAsNoLongerNeeded(scaleform) --EXIT SCALEFORM
                        PopScaleformMovieFunctionVoid()
                        FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                        isRunning = false
                        TriggerEvent('bj:minigameResult', 'Bruteforce', true, {})
                    elseif ProgramID == 6 then
                        Wait(500) -- WE WAIT 0.5 SECONDS TO EXIT SCALEFORM, JUST TO SIMULATE A SHUTDOWN, OTHERWISE IT CLOSES INSTANTLY
                        SetScaleformMovieAsNoLongerNeeded(scaleform) --EXIT SCALEFORM
                        FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                        DisableControlAction(0, 24, false) --LEFT CLICK enabled again
                        DisableControlAction(0, 25, false) --RIGHT CLICK enabled again
                        isRunning = false
                        StopCountdown()
                        TriggerEvent('bj:minigameResult', 'Bruteforce', false, {})
                    end
    
                    if data.attempts == 0 then
                        PlaySoundFrontend(-1, "HACKING_FAILURE", "", true)
                        PushScaleformMovieFunction(scaleform, "SET_ROULETTE_OUTCOME")
                        PushScaleformMovieFunctionParameterBool(false)
                        PushScaleformMovieFunctionParameterString("BRUTEFORCE FAILED!")
                        PopScaleformMovieFunctionVoid()
                        
                        Wait(3500) --WE WAIT 3.5 seconds here aswell to let the bruteforce message sink in before exiting.
                        PushScaleformMovieFunction(scaleform, "CLOSE_APP")
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "OPEN_ERROR_POPUP")
                        PushScaleformMovieFunctionParameterBool(true)
                        PushScaleformMovieFunctionParameterString("MEMORY LEAK DETECTED, DEVICE SHUTTING DOWN")
                        PopScaleformMovieFunctionVoid()
                        
                        Wait(2500)
                        SetScaleformMovieAsNoLongerNeeded(scaleform)
                        PopScaleformMovieFunctionVoid()
                        FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                        DisableControlAction(0, 24, false) --LEFT CLICK enabled again
                        DisableControlAction(0, 25, false) --RIGHT CLICK enabled again
                        isRunning = false
                        StopCountdown()
                        TriggerEvent('bj:minigameResult', 'Bruteforce', false, {})
                    end
                end
            end
            Citizen.Wait(0)
        end
    end)
end
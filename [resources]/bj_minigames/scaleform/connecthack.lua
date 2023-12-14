ScaleformMinigames['Hackconnect'] = function(mgData)
    local scaleform = nil
    local ClickReturn
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

            PushScaleformMovieFunction(scaleform, "SET_SPEED")
            PushScaleformMovieFunctionParameterInt(data.difficulty * 15)
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
            elseif IsDisabledControlJustPressed(0, 172) then -- IF ARROW UP
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT")
                PushScaleformMovieFunctionParameterInt(8)
                PopScaleformMovieFunctionVoid()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            elseif IsDisabledControlJustPressed(0, 173) then -- IF ARROW DOWN
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT")
                PushScaleformMovieFunctionParameterInt(9)
                PopScaleformMovieFunctionVoid()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            elseif IsDisabledControlJustPressed(0, 174) then -- IF ARROW LEFT
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT")
                PushScaleformMovieFunctionParameterInt(10)
                PopScaleformMovieFunctionVoid()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            elseif IsDisabledControlJustPressed(0, 175) then -- IF ARROW RIGHT
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT")
                PushScaleformMovieFunctionParameterInt(11)
                PopScaleformMovieFunctionVoid()
                PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
            elseif IsDisabledControlJustPressed(0, 179) then -- IF SPACEBAR
                PushScaleformMovieFunction(scaleform, "SET_INPUT_EVENT_SELECT")
                ClickReturn = PopScaleformMovieFunction()
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
                DisableControlAction(0, 172, true) --ARROW UP disabled while in scaleform
                DisableControlAction(0, 173, true) --ARROW DOWN disabled while in scaleform
                DisableControlAction(0, 174, true) --ARROW LEFT disabled while in scaleform
                DisableControlAction(0, 175, true) --ARROW RIGHT disabled while in scaleform
                if IsScaleformMovieMethodReturnValueReady(ClickReturn) then -- old native?
                    ProgramID = GetScaleformMovieFunctionReturnInt(ClickReturn)
                    print("ProgramID: "..ProgramID) -- Prints the ID of the Apps we click on inside the scaleform, very useful.
    
                    if ProgramID == 82 then --HACKCONNECT.EXE
                        PushScaleformMovieFunction(scaleform, "RUN_PROGRAM")
                        PushScaleformMovieFunctionParameterFloat(82.0)
                        PopScaleformMovieFunctionVoid()
    
                        PushScaleformMovieFunction(scaleform, "SET_LIVES")
                        PushScaleformMovieFunctionParameterInt(data.attempts) --We set how many lives our user has before he fails the bruteforce.
                        PushScaleformMovieFunctionParameterInt(maxAttempts)
                        PopScaleformMovieFunctionVoid()
                        
                        if mgData.timer then
                            DoCountdown(scaleform, mgData.timer, function()
                                PlaySoundFrontend(-1, "HACKING_FAILURE", "", true)
                                StopCountdown()
                                PushScaleformMovieFunction(scaleform, "SET_IP_OUTCOME")
                                PushScaleformMovieFunctionParameterBool(false)
                                PushScaleformMovieFunctionParameterString("HACKCONNECT FAILED!")
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
                                DisableControlAction(0, 172, false) --ARROW UP enabled again
                                DisableControlAction(0, 173, false) --ARROW DOWN enabled again
                                DisableControlAction(0, 174, false) --ARROW LEFT enabled again
                                DisableControlAction(0, 175, false) --ARROW RIGHT enabled again
                                TriggerEvent('bj:minigameResult', 'Hackconnect', false, {})
                            end)
                        end
    
                    elseif ProgramID == 83 then  --BRUTEFORCE.EXE
                        PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
                    
                    elseif ProgramID == 85 then --IF YOU CLICK THE WRONG LETTER IN BRUTEFORCE APP
                        data.attempts = data.attempts - 1
    
                        PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
                        PushScaleformMovieFunction(scaleform, "SET_LIVES")
                        PushScaleformMovieFunctionParameterInt(data.attempts) --We set how many lives our user has before he fails the bruteforce.
                        PushScaleformMovieFunctionParameterInt(maxAttempts)
                        PopScaleformMovieFunctionVoid()

                    elseif ProgramID == 84 then --IF YOU SUCCESSFULY GET ALL LETTERS RIGHT IN BRUTEFORCE APP
                        PlaySoundFrontend(-1, "HACKING_SUCCESS", "", true)

                        StopCountdown()
                        
                        PushScaleformMovieFunction(scaleform, "SET_IP_OUTCOME")
                        PushScaleformMovieFunctionParameterBool(true)
                        PushScaleformMovieFunctionParameterString("HACKCONNECT SUCCESSFUL!")
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
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_MESSAGE")
                        PushScaleformMovieFunctionParameterString("Execution successful. Shutting down.")
                        PushScaleformMovieFunctionParameterFloat(2.0)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_TIME")
                        PushScaleformMovieFunctionParameterInt(0)
                        PopScaleformMovieFunctionVoid()
                        
                        PushScaleformMovieFunction(scaleform, "SET_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterInt(100)
                        PopScaleformMovieFunctionVoid()

                        Wait(3500)
                        
                        PushScaleformMovieFunction(scaleform, "OPEN_LOADING_PROGRESS")
                        PushScaleformMovieFunctionParameterBool(false)
                        PopScaleformMovieFunctionVoid()
                        
                        -- PushScaleformMovieFunction(scaleform, "OPEN_ERROR_POPUP")
                        -- PushScaleformMovieFunctionParameterBool(true)
                        -- PushScaleformMovieFunctionParameterString("MEMORY LEAK DETECTED, DEVICE SHUTTING DOWN")
                        -- PopScaleformMovieFunctionVoid()
                        -- 
                        -- Wait(3500)
                        SetScaleformMovieAsNoLongerNeeded(scaleform) --EXIT SCALEFORM
                        PopScaleformMovieFunctionVoid()
                        FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                        isRunning = false
                        StopCountdown()
                        TriggerEvent('bj:minigameResult', 'Hackconnect', true, {})

                    elseif ProgramID == 6 then
                        StopCountdown()
                        Wait(500) -- WE WAIT 0.5 SECONDS TO EXIT SCALEFORM, JUST TO SIMULATE A SHUTDOWN, OTHERWISE IT CLOSES INSTANTLY
                        SetScaleformMovieAsNoLongerNeeded(scaleform) --EXIT SCALEFORM
                        FreezeEntityPosition(PlayerPedId(), false) --unfreeze our character
                        DisableControlAction(0, 24, false) --LEFT CLICK enabled again
                        DisableControlAction(0, 25, false) --RIGHT CLICK enabled again
                        DisableControlAction(0, 172, false) --ARROW UP enabled again
                        DisableControlAction(0, 173, false) --ARROW DOWN enabled again
                        DisableControlAction(0, 174, false) --ARROW LEFT enabled again
                        DisableControlAction(0, 175, false) --ARROW RIGHT enabled again
                        isRunning = false
                        StopCountdown()
                        TriggerEvent('bj:minigameResult', 'Hackconnect', false, {})
                    end
    
                    if data.attempts == 0 then
                        PlaySoundFrontend(-1, "HACKING_FAILURE", "", true)
                        StopCountdown()
                        PushScaleformMovieFunction(scaleform, "SET_IP_OUTCOME")
                        PushScaleformMovieFunctionParameterBool(false)
                        PushScaleformMovieFunctionParameterString("HACKCONNECT FAILED!")
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
                        DisableControlAction(0, 172, false) --ARROW UP enabled again
                        DisableControlAction(0, 173, false) --ARROW DOWN enabled again
                        DisableControlAction(0, 174, false) --ARROW LEFT enabled again
                        DisableControlAction(0, 175, false) --ARROW RIGHT enabled again
                        isRunning = false
                        StopCountdown()
                        TriggerEvent('bj:minigameResult', 'Hackconnect', false, {})
                    end
                end
            end
            Citizen.Wait(0)
        end
    end)
end
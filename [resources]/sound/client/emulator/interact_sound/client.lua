if config.interact_sound_enable then

    RegisterNetEvent('InteractSound_CL:PlayOnOne')
    AddEventHandler('InteractSound_CL:PlayOnOne', function(soundFile, soundVolume)
        PlayUrl("./sounds/" .. soundFile, "./sounds/" .. soundFile .. "." .. config.interact_sound_file, soundVolume)
    end)

    RegisterNetEvent('InteractSound_CL:PlayOnAll')
    AddEventHandler('InteractSound_CL:PlayOnAll', function(soundFile, soundVolume)
        PlayUrl("./sounds/" .. soundFile, "./sounds/" .. soundFile .. "." .. config.interact_sound_file, soundVolume)
    end)

    RegisterNetEvent('InteractSound_CL:PlayWithinDistance')
    AddEventHandler('InteractSound_CL:PlayWithinDistance', function(sourcePos, maxDistance, soundFile, soundVolume)
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(sourcePos - plyPos)
        PlayUrlPos("./sounds/" .. soundFile, "./sounds/" .. soundFile .. "." .. config.interact_sound_file, soundVolume, sourcePos)
        Distance("./sounds/" .. soundFile, maxDistance)
    end)

end
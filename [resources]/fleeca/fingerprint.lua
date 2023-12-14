AddEventHandler("utk_fingerprint:Start", function(levels, lifes, time, func)
    Callback = func
    SendNUIMessage({
		type = 'intro'
    })
    TriggerEvent("utk_hack:playSound", 'intro')
    Citizen.Wait(3350)
	TriggerEvent('bj_minigames:start', 'Fingerprint', { difficulty = levels, attempts = lives, timer = time }, function(data)
        SendNUIMessage({
    		type = "success"
        })
        TriggerEvent("utk_hack:playSound", 'success')
        func(true)
    end, function(data)
        SendNUIMessage({
    		type = "fail"
        })
        TriggerEvent("utk_hack:playSound", 'fail')
        func(false, data.reason)
    end)
end)

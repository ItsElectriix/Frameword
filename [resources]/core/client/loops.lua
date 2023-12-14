
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		if NetworkIsSessionStarted() then
			Citizen.Wait(10)
			TriggerServerEvent('BJCore:PlayerJoined')
			return
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		if isLoggedIn then
			Citizen.Wait((1000 * 60) * 10)
			TriggerEvent("BJCore:Player:UpdatePlayerData")
		else
			Citizen.Wait(5000)
		end
	end
end)

pausePosUpdate = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		if isLoggedIn and not pausePosUpdate then
			Citizen.Wait(30000)
			TriggerEvent("BJCore:Player:UpdatePlayerPosition")
		else
			Citizen.Wait(5000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(math.random(3000, 5000))
		if isLoggedIn then
			if BJCore.Functions.GetPlayerData().metadata["hunger"] <= 0 or BJCore.Functions.GetPlayerData().metadata["thirst"] <= 0 then
				local ped = PlayerPedId()
				local currentHealth = GetEntityHealth(ped)

				SetEntityHealth(ped, currentHealth - math.random(5, 10))
			end
		end
	end
end)
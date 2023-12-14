local ResetStress = false

RegisterServerEvent("bj-hud:Server:UpdateStress")
AddEventHandler('bj-hud:Server:UpdateStress', function(StressGain)
	local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + StressGain
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
		TriggerClientEvent("hud:client:UpdateStress", src, newStress)
		TriggerClientEvent('mooseUI:client:UpdateStatus',src, {stress=100-newStress})
	end
end)

RegisterServerEvent('bj-hud:Server:GainStress')
AddEventHandler('bj-hud:Server:GainStress', function(amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("hud:client:UpdateStress", src, newStress)
        --TriggerClientEvent('BJCore:Notify', src, 'Gained stress', 'primary', 1500)
		TriggerClientEvent('mooseUI:client:UpdateStatus',src, {stress=100-newStress})
	end
end)

RegisterServerEvent('bj-hud:Server:RelieveStress')
AddEventHandler('bj-hud:Server:RelieveStress', function(amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("hud:client:UpdateStress", src, newStress)
        TriggerClientEvent('BJCore:Notify', src, 'Stress lightened')
		TriggerClientEvent('mooseUI:client:UpdateStatus',src, {stress=100-newStress})
	end
end)
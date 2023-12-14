BJCore.Functions.RegisterServerCallback('tattoos:server:GetPlayerTattoos', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil then
		 exports['ghmattimysql']:execute('SELECT tattoos FROM playerskins WHERE citizenid = @citizenid', {
			['@citizenid'] = Player.PlayerData.citizenid
		}, function(result)
			if result[1] ~= nil and result[1].tattoos ~= nil then
				cb(json.decode(result[1].tattoos))
			else
				cb({})
			end
		end)
	else
		cb()
	end
end)

BJCore.Functions.RegisterServerCallback('tattoos:server:PurchaseTattoo', function(source, cb, tattooList, price, tattoo, tattooName)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player ~= nil and Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
		table.insert(tattooList, tattoo)
		exports['ghmattimysql']:execute('UPDATE playerskins SET tattoos = @tattoos WHERE citizenid = @citizenid', {
			['@tattoos'] = json.encode(tattooList),
			['@citizenid'] = Player.PlayerData.citizenid
		})
		TriggerClientEvent('BJCore:Notify', source, "You have bought the " .. tattooName .. " tattoo for "..BJCore.Config.Currency.Symbol..""..price, 'success')
		cb(true)
	else
		TriggerClientEvent('BJCore:Notify', source, "You do not have enough money for this tattoo", 'error')

		cb(false)
	end
end)

RegisterNetEvent('tattoos:server:RemoveTattoo')
AddEventHandler('tattoos:server:RemoveTattoo', function(tattooList)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	exports['ghmattimysql']:execute('UPDATE playerskins SET tattoos = @tattoos WHERE citizenid = @citizenid', {
		['@tattoos'] = json.encode(tattooList),
		['@citizenid'] = Player.PlayerData.citizenid
	})
end)

RegisterServerEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
	local pData = BJCore.Functions.GetPlayer(source)
	local amount = BJCore.Common.MathRound(price)

	if price > 0 then
		pData.Functions.RemoveMoney("cash",amount,"Pay fuel")
		TriggerEvent("bj-log:server:CreateLog", "default", "Fuel Station", "green", "**"..pData.PlayerData.name .. "** has paid "..BJCore.Config.Currency.Symbol..amount.." for fuel")
		TriggerClientEvent('BJCore:Notfy', source, 'You\'ve paid '..BJCore.Config.Currency.Symbol..amount..' at the gas station', 'primary')
	end
end)

RegisterServerEvent("fuel:SetFuel")
AddEventHandler("fuel:SetFuel", function(veh,fuel)
	local _source = source
	local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(veh))
    TriggerClientEvent("fuel:SetFuel",owner,veh,fuel)
end)
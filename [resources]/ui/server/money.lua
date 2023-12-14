BJCore = nil

TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

BJCore.Commands.Add("cash", "Show your cash", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "cash")
end)

BJCore.Commands.Add("bank", "Show your bank", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "bank")
end)
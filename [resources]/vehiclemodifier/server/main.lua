RegisterNetEvent("carhud:ejection:server")
AddEventHandler("carhud:ejection:server",function(target, value, plate)
	local src = source
	if target == -1 or value == nil or plate == nil then
		TriggerEvent("animalcrossing:server:banPlayer", "Ejection exploit", src)
		return
	end
    TriggerClientEvent("carhud:ejection:client", target, value, plate)
end)

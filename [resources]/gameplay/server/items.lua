BJCore.Functions.CreateUseableItem("joint", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseJoint", source)
    end
end)

BJCore.Functions.CreateUseableItem("armor", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseArmor", source)
end)

BJCore.Functions.CreateUseableItem("heavyarmor", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseHeavyArmor", source)
end)

BJCore.Functions.CreateUseableItem("smoketrailred", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseRedSmoke", source)
    end
end)

BJCore.Functions.CreateUseableItem("parachute", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseParachute", source)
    end
end)

BJCore.Commands.Add("parachuteoff", "Take off your parachute", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
        TriggerClientEvent("consumables:client:ResetParachute", source)
end)

RegisterServerEvent("qb-smallpenis:server:AddParachute")
AddEventHandler("qb-smallpenis:server:AddParachute", function()
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)

    Ply.Functions.AddItem("parachute", 1)
end)

BJCore.Functions.CreateUseableItem("water_bottle", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("vodka", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

BJCore.Functions.CreateUseableItem("beer", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

BJCore.Functions.CreateUseableItem("whiskey", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

BJCore.Functions.CreateUseableItem("coffee", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("cola", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("sandwich", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("twix_bar", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("snickers_bar", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("toastie", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

BJCore.Functions.CreateUseableItem("binoculars", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("binoculars:Toggle", source)
end)

BJCore.Functions.CreateUseableItem("cokebaggy", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Cokebaggy", source)
end)

BJCore.Functions.CreateUseableItem("crack_baggy", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Crackbaggy", source)
end)

BJCore.Functions.CreateUseableItem("xtcbaggy", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:EcstasyBaggy", source)
end)

BJCore.Functions.CreateUseableItem("firework1", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework")
end)

BJCore.Functions.CreateUseableItem("firework2", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework_v2")
end)

BJCore.Functions.CreateUseableItem("firework3", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_xmas_firework")
end)

BJCore.Functions.CreateUseableItem("firework4", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "scr_indep_fireworks")
end)

BJCore.Commands.Add("removearmour", "Remove your vest", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("consumables:client:ResetArmor", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services!")
    end
end)

BJCore.Functions.CreateUseableItem("repairkit", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("mech:client:UseRepairItem", source, false, false, false)
end)

BJCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("mech:client:UseRepairItem", source, true, false, false)
end)

BJCore.Functions.CreateUseableItem("bikerepairkit", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("mech:client:UseRepairItem", source, true, false, true)
end)

BJCore.Functions.CreateUseableItem("lockpick", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("vehiclelock:client:UseLockPickItem", source, false)
end)

BJCore.Functions.CreateUseableItem("advancedlockpick", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("vehiclelock:client:UseLockPickItem", source, true)
end)

BJCore.Functions.CreateUseableItem("cleaningkit", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("mech:client:menuOnClean", source, false)
end)

BJCore.Functions.CreateUseableItem("blindfold", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    TriggerClientEvent("gameplay:client:UseBlindfold", source)
end)
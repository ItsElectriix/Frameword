function MethRewardPlayers(plyA,plyB)
	local enoughmeth,enoughtray = false,false
	local doReward = false
	local pData = BJCore.Functions.GetPlayer(plyA)
	local tData = BJCore.Functions.GetPlayer(plyB)
	while not tData do tData = BJCore.Functions.GetPlayer(plyB) Citizen.Wait(0); end
	local methcount = 0  
	if pData.Functions.GetItemByName(Config.MethRequiredItem) ~= nil then
		methcount = pData.Functions.GetItemByName(Config.MethRequiredItem).amount
	end
	if methcount < Config.MethRequiredMeth then
		TriggerClientEvent('BJCore:Notify',pData.PlayerData.source,'You no longer have enough meth to complete the cook. Nice try','error',5500)
	else
		enoughmeth = true
		if methcount > 100 then
			methcount = 100
		end
		pData.Functions.RemoveItem(Config.MethRequiredItem, methcount)
		TriggerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..pData.PlayerData.name.."** is exchanging x"..methcount.." meth crystals for a meth cook run with **"..tData.PlayerData.name..".")		
	end
	local traycount = 0
	if pData.Functions.GetItemByName(Config.TrayRequiredItem) ~= nil then 
		traycount = pData.Functions.GetItemByName(Config.TrayRequiredItem).amount
	end
	if traycount < Config.MethRequiredTray then
		TriggerClientEvent('BJCore:Notify',pData.PlayerData.source,'You no longer have enough bakings trays to complete the cook. Nice try', "error", 5500)
	else
		enoughtray = true
		if traycount > 10 then
			traycount = 10
		end    
		pData.Functions.RemoveItem(Config.TrayRequiredItem, traycount)
		TriggerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..pData.PlayerData.name.."** is exchanging x"..traycount.." trays for a meth cook run with **"..tData.PlayerData.name..".")
	end 

	if enoughmeth and enoughtray then doReward = true; end
	if doReward then 
		local amount = (math.random(Config.MethMinMethReward, Config.MethMaxMethReward) * methcount) / Config.MethRequiredMeth
		tData.Functions.AddItem(Config.MethItemRewardName, amount)
		TriggerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..tData.PlayerData.name.."** has been rewarded x"..amount.." meth bags for a meth cook run with **"..pData.PlayerData.name..".")
	end
end

BJCore.Functions.RegisterServerCallback('MobileMeth:GetMeth', function(source,cb) 
	local pData = BJCore.Functions.GetPlayer(source)
	local meth, tray = false, false

    if pData.Functions.GetItemByName(Config.MethRequiredItem) ~= nil then
    	if pData.Functions.GetItemByName(Config.MethRequiredItem).amount >= Config.MethRequiredMeth then
    		meth = true
    	end
    end

    if pData.Functions.GetItemByName(Config.TrayRequiredItem) ~= nil then
    	if pData.Functions.GetItemByName(Config.TrayRequiredItem).amount >= Config.MethRequiredTray then
    		tray = true
    	end
    end
    if not meth or not tray then
    	TriggerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..pData.PlayerData.name.."** has been requested a meth cooking run but didn't have required items.")
    	TriggerClientEvent('BJCore:Notify', pData.PlayerData.source, "You seem to be missing some items to cook with", 'error')
    else
    	TriggerEvent("bj-log:server:CreateLog", "crim", "Meth cooking", "black", "**"..pData.PlayerData.name.."** has successfully started/requested meth cooking run.")
    end
		 
	cb({hasMeth = meth, hasTray = tray})
end)

RegisterNetEvent('MobileMeth:BeginCooking')
AddEventHandler('MobileMeth:BeginCooking', function(target) TriggerClientEvent('MobileMeth:BeginCooking', target, source); end)
RegisterNetEvent('MobileMeth:FinishCook')
AddEventHandler('MobileMeth:FinishCook', function(target,result,msg) TriggerClientEvent('MobileMeth:FinishCook', target, result, msg); end)
RegisterNetEvent('MobileMeth:SyncSmoke')
AddEventHandler('MobileMeth:SyncSmoke', function(netId) TriggerClientEvent('MobileMeth:SyncSmoke', -1, netId); end)
RegisterNetEvent('MobileMeth:RemoveTruck')
AddEventHandler('MobileMeth:RemoveTruck', function(netId) TriggerClientEvent('MobileMeth:RemoveSmoke', -1, netId); end)
RegisterNetEvent('MobileMeth:RewardPlayers')
AddEventHandler('MobileMeth:RewardPlayers', function(driver) MethRewardPlayers(source,driver); end)
BJCore.Functions.RegisterServerCallback("bj-spawnlocation:server:getProperties", function(source, cb)
	local retTab = {}
	local cid = BJCore.Functions.GetPlayer(source).PlayerData.citizenid
	local busy = true
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_houses` WHERE `citizenid` = '"..cid.."' ", function(result)
        if result[1] ~= nil then
        	retTab["houses"] = result
        end
	    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_apartments` WHERE `citizenid` = '"..cid.."' ", function(result)
	        if result[1] ~= nil then
	        	retTab["apartments"] = result
	        end
	        busy = false
	    end)
    end)
    while busy do Citizen.Wait(100); end
    cb(retTab)
end)
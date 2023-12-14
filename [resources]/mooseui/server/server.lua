-- ESX.RegisterServerCallback('mooseUI:GetCharacterId', function(source, cb)
-- 	local _source = source
	
-- 	local steamId = GetPlayerIdentifiers(_source)[1]
-- 	local result = MySQL.Sync.fetchAll('SELECT id FROM users WHERE identifier = @identifier', {
-- 		['@identifier'] = steamId
-- 	})
    
-- 	cb(result[1].id)
-- end)
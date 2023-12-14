BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
local loggingApi = ""

RegisterServerEvent('bj-log:server:CreateLog')
AddEventHandler('bj-log:server:CreateLog', function(name, title, color, message, tagEveryone)
	if GetConvar("server_type", "DEV") == "LIVE" then
	    local tag = tagEveryone ~= nil and tagEveryone or false
	    local webHook = Config.Webhooks[name] ~= nil and Config.Webhooks[name] or Config.Webhooks["default"]
		local messageData = {
			["username"] = "BJ Logger",
			["embeds"] = {
				{
					["title"] = title,
					["color"] = Config.Colors[color] ~= nil and Config.Colors[color] or Config.Colors["default"],
					["footer"] = {
						["text"] = os.date("%c"),
					},
					["description"] = message,
				}
			}
		}
		if tag then
			messageData["content"] = "@everyone"
	    end
		PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode(messageData), { ['Content-Type'] = 'application/json' })
	end
end)
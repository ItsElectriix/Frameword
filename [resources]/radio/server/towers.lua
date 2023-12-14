function LoadJson(name)
	local File = LoadResourceFile(GetCurrentResourceName(), name..".json")
	return json.decode(File)
end

CreateThread(function()
    if Config.UsingSaltyChat then
	    print("^3Setting up radio towers!^7")
	    local Towers = LoadJson("worldRadioTowers")
	    local Formatted = {}
	    for k,v in pairs(Towers) do
	    	local t = {v.Position.X, v.Position.Y, v.Position.Z}
        
	    	table.insert(Formatted, t)
	    end
	    print("^3Found "..#Towers.." radio towers/masts, formatted and sending to SaltyChat now.^7")
	    exports.saltychat:SetRadioTowers(Formatted)
    end
end)
BJCore.DiscordAPI = {}

local FormattedToken = "Bot " .. BJCore.Config.Server.DiscordAPI.Bot_Token
DiscordRequest = function(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do Citizen.Wait(0); end
	
    return data
end

BJCore.DiscordAPI.GetRoleIdFromRoleName = function (name)
	if (Caches.RoleList ~= nil) then 
		return tonumber(Caches.RoleList[name]);
	else 
		local roles = GetGuildRoleList();
		return tonumber(roles[name]);
	end
end

BJCore.DiscordAPI.CheckEqual = function(role1, role2)
	local checkStr1 = false
	local checkStr2 = false
	local roleID1 = role1
	local roleID2 = role2
	if type(role1) == "string" then checkStr1 = true end
	if type(role2) == "string" then checkStr2 = true end
	if checkStr1 then 
		local roles = GetGuildRoleList();
		for roleName, roleID in pairs(roles) do 
			if roleName == role1 then 
				roleID1 = roleID;
			end
		end
		local roles2 = BJCore.Config.Server.DiscordAPI.RoleList;
		for roleRef, roleID in pairs(roles2) do 
			if roleRef == role1 then 
				roleID1 = roleID;
			end
		end
	end
	if checkStr2 then 
		local roles = GetGuildRoleList();
		for roleName, roleID in pairs(roles) do 
			if roleName == role2 then 
				roleID2 = roleID;
			end
		end
		local roles2 = BJCore.Config.Server.DiscordAPI.RoleList;
		for roleRef, roleID in pairs(roles2) do 
			if roleRef == role2 then 
				roleID2 = roleID;
			end
		end
	end
	if tonumber(roleID1) == tonumber(roleID2) then 
		return true
	end
	return false
end

BJCore.DiscordAPI.IsDiscordEmailVerified = function(user) 
    local discordId = nil
    local isVerified = false;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
                -- It is valid data
                isVerified = data.verified;
            end
        else 
        	print("[DiscordAPI] ERROR: Code 200 was not reached. Error provided: " .. member.data)
        end
    end
    return isVerified;
end

BJCore.DiscordAPI.GetDiscordEmail = function(user) 
    local discordId = nil
    local emailData = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
                -- It is valid data
                emailData = data.email
            end
        else 
        	print("[DiscordAPI] ERROR: Code 200 was not reached. Error provided: " .. member.data)
        end
    end
    return emailData;
end

BJCore.DiscordAPI.GetDiscordName = function(user) 
    local discordId = nil
    local nameData = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
                -- It is valid data 
                nameData = data.username .. "#" .. data.discriminator
            end
        else 
        	print("[DiscordAPI] ERROR: Code 200 was not reached. Error provided: " .. member.data)
        end
    end
    return nameData;
end

BJCore.DiscordAPI.GetGuildIcon = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		if (data.icon:sub(1, 1) and data.icon:sub(2, 2) == "_") then 
			-- It's a gif 
			return 'https://cdn.discordapp.com/icons/' .. BJCore.Config.Server.DiscordAPI.Guild_ID .. "/" .. data.icon .. ".gif"
		else 
			-- Image 
			return 'https://cdn.discordapp.com/icons/' .. BJCore.Config.Server.DiscordAPI.Guild_ID .. "/" .. data.icon .. ".png"
		end 
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end

BJCore.DiscordAPI.GetGuildSplash = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		-- Image 
		return 'https://cdn.discordapp.com/splashes/' .. BJCore.Config.Server.DiscordAPI.Guild_ID .. "/" .. data.icon .. ".png";
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end 

BJCore.DiscordAPI.GetGuildName = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		-- Image 
		return data.name;
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end

BJCore.DiscordAPI.GetGuildDescription = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		-- Image 
		return data.description;
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end

BJCore.DiscordAPI.GetGuildMemberCount = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID.."?with_counts=true", {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		-- Image 
		return data.approximate_member_count;
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end

BJCore.DiscordAPI.GetGuildOnlineMemberCount = function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID.."?with_counts=true", {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		return data.approximate_presence_count;
	else
		print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
	return nil;
end

BJCore.DiscordAPI.GetDiscordAvatar = function(user) 
    local discordId = nil
    local imgURL = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
	end
	if discordId then 
		if Caches.Avatars[discordId] == nil then 
			local endpoint = ("users/%s"):format(discordId)
			local member = DiscordRequest("GET", endpoint, {})
			if member.code == 200 then
				local data = json.decode(member.data)
				if data ~= nil and data.avatar ~= nil then 
					-- It is valid data 
					if (data.avatar:sub(1, 1) and data.avatar:sub(2, 2) == "_") then 
						imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".gif";
					else 
						imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
					end
				end
			else 
				print("[DiscordAPI] ERROR: Code 200 was not reached. Error provided: " .. member.data)
			end
			Caches.Avatars[discordId] = imgURL;
		else 
			imgURL = Caches.Avatars[discordId];
		end 
	else 
		print("[DiscordAPI] ERROR: Discord ID was not found...")
	end
    return imgURL;
end

Caches = {
	Avatars = {}
}
BJCore.DiscordAPI.ResetCaches = function()
	Caches = {}
end

BJCore.DiscordAPI.GetGuildRoleList = function()
	if (Caches.RoleList == nil) then 
		local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
		if guild.code == 200 then
			local data = json.decode(guild.data)
			-- Image 
			local roles = data.roles
			local roleList = {}
			for i = 1, #roles do 
				roleList[roles[i].name] = roles[i].id
			end
			Caches.RoleList = roleList
		else
			print("[DiscordAPI] An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
			Caches.RoleList = nil
		end
	end
	return Caches.RoleList
end

BJCore.DiscordAPI.GetDiscordRoles = function(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			break;
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(BJCore.Config.Server.DiscordAPI.Guild_ID, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			return roles
		else
			print("[DiscordAPI] ERROR: Code 200 was not reached... Returning false. [Member Data NOT FOUND]")
			return false
		end
	else
		print("[DiscordAPI] ERROR: Discord was not connected to user's Fivem account...")
		return false
	end
	return false
end

BJCore.DiscordAPI.GetDiscordNickname = function(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(BJCore.Config.Server.DiscordAPI.Guild_ID, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local nickname = data.nick
			return nickname;
		else
			print("[DiscordAPI] ERROR: Code 200 was not reached. Error provided: "..member.data)
			return nil;
		end
	else
		print("[DiscordAPI] ERROR: Discord was not connected to user's Fivem account...")
		return nil;
	end
	return nil;
end

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..BJCore.Config.Server.DiscordAPI.Guild_ID, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		print("[DiscordAPI] Permission system guild set to: "..data.name.." ("..data.id..")")
	else
		print("[DiscordAPI] An error occured, check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
end)
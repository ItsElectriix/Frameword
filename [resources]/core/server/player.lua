BJCore.Players = {}
BJCore.Player = {}

BJCore.Player.Login = function(source, citizenid, newData)
    if source ~= nil then
	    if citizenid then
		    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..citizenid.."'", function(result)
			    local PlayerData = result[1]
				if PlayerData ~= nil then
					PlayerData.money = json.decode(PlayerData.money)
					PlayerData.job = json.decode(PlayerData.job)
					PlayerData.position = json.decode(PlayerData.position)
					PlayerData.metadata = json.decode(PlayerData.metadata)
					PlayerData.charinfo = json.decode(PlayerData.charinfo)
					if PlayerData.gang ~= nil then
						PlayerData.gang = json.decode(PlayerData.gang)
					else
						PlayerData.gang = {}
					end
				end
				BJCore.Player.CheckPlayerData(source, PlayerData)
			end)
	    else
	        BJCore.Player.CheckPlayerData(source, newData)
		end
		return true
	else
	    BJCore.ShowError(GetCurrentResourceName(), "ERROR BJCore.PLAYER.LOGIN - NO SOURCE GIVEN")
		return false
	end
end

BJCore.Player.GenerateNumber = function()
	local num = false
	while not num do
		local tNum = BJConfig.Player.PhoneNumberPrefix..math.random(11111111, 99999999)
		local result = exports['ghmattimysql']:executeSync("SELECT * FROM `players` WHERE `charinfo` LIKE '%"..tNum.."%'", {})
		if #result == 0 then
			num = tNum
		end
		Wait(0)
	end
	return num
end

BJCore.Player.CheckPlayerData = function(source, PlayerData)
    PlayerData = PlayerData ~= nil and PlayerData or {}

	PlayerData.source = source
	PlayerData.citizenid = PlayerData.citizenid ~= nil and PlayerData.citizenid or BJCore.Player.CreateCitizenId()
	PlayerData.steam = PlayerData.steam ~= nil and PlayerData.steam or BJCore.Functions.GetIdentifier(source, "steam")
	PlayerData.license = PlayerData.license ~= nil and PlayerData.license or BJCore.Functions.GetIdentifier(source, "license")
	PlayerData.name = GetPlayerName(source)
	PlayerData.cid = PlayerData.cid ~= nil and PlayerData.cid or 1

    PlayerData.money = PlayerData.money ~= nil and PlayerData.money or {}
	for moneytype, startamount in pairs(BJCore.Config.Money.MoneyTypes) do
		PlayerData.money[moneytype] = PlayerData.money[moneytype] ~= nil and PlayerData.money[moneytype] or startamount
	end

	PlayerData.charinfo = PlayerData.charinfo ~= nil and PlayerData.charinfo or {}
	PlayerData.charinfo.firstname = PlayerData.charinfo.firstname ~= nil and PlayerData.charinfo.firstname or "Firstname"
	PlayerData.charinfo.lastname = PlayerData.charinfo.lastname ~= nil and PlayerData.charinfo.lastname or "Lastname"
	PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate ~= nil and PlayerData.charinfo.birthdate or "00-00-0000"
	PlayerData.charinfo.gender = PlayerData.charinfo.gender ~= nil and PlayerData.charinfo.gender or 0
	PlayerData.charinfo.backstory = PlayerData.charinfo.backstory ~= nil and PlayerData.charinfo.backstory or "placeholder backstory"
	PlayerData.charinfo.nationality = PlayerData.charinfo.nationality ~= nil and PlayerData.charinfo.nationality or "American"
	PlayerData.charinfo.phone = PlayerData.charinfo.phone ~= nil and PlayerData.charinfo.phone or BJCore.Player.GenerateNumber()
	PlayerData.charinfo.account = PlayerData.charinfo.account ~= nil and PlayerData.charinfo.account or "BNK0"..math.random(1,9).."BJ"..math.random(1111,9999)..math.random(1111,9999)..math.random(11,99)

	PlayerData.metadata = PlayerData.metadata ~= nil and PlayerData.metadata or {}
	PlayerData.metadata["hunger"] = PlayerData.metadata["hunger"] ~= nil and PlayerData.metadata["hunger"] or 100
	PlayerData.metadata["thirst"] = PlayerData.metadata["thirst"] ~= nil and PlayerData.metadata["thirst"] or 100
	PlayerData.metadata["stress"] = PlayerData.metadata["stress"] ~= nil and PlayerData.metadata["stress"] or 0
	PlayerData.metadata["isdead"] = PlayerData.metadata["isdead"] ~= nil and PlayerData.metadata["isdead"] or false
	PlayerData.metadata["intrunk"] = PlayerData.metadata["intrunk"] ~= nil and PlayerData.metadata["intrunk"] or false
	PlayerData.metadata["inlaststand"] = PlayerData.metadata["inlaststand"] ~= nil and PlayerData.metadata["inlaststand"] or false
	PlayerData.metadata["armor"]  = PlayerData.metadata["armor"]  ~= nil and PlayerData.metadata["armor"] or 0
	PlayerData.metadata["ishandcuffed"] = PlayerData.metadata["ishandcuffed"] ~= nil and PlayerData.metadata["ishandcuffed"] or false
	PlayerData.metadata["tracker"] = PlayerData.metadata["tracker"] ~= nil and PlayerData.metadata["tracker"] or false
	PlayerData.metadata["injail"] = PlayerData.metadata["injail"] ~= nil and PlayerData.metadata["injail"] or 0
	PlayerData.metadata["comserv"] = PlayerData.metadata["comserv"] ~= nil and PlayerData.metadata["comserv"] or 0
	PlayerData.metadata["jailitems"] = PlayerData.metadata["jailitems"] ~= nil and PlayerData.metadata["jailitems"] or {}
	PlayerData.metadata["status"] = PlayerData.metadata["status"] ~= nil and PlayerData.metadata["status"] or {}
	PlayerData.metadata["phone"] = PlayerData.metadata["phone"] ~= nil and PlayerData.metadata["phone"] or {}
	PlayerData.metadata["fitbit"] = PlayerData.metadata["fitbit"] ~= nil and PlayerData.metadata["fitbit"] or {}
	PlayerData.metadata["commandbinds"] = PlayerData.metadata["commandbinds"] ~= nil and PlayerData.metadata["commandbinds"] or {}
	PlayerData.metadata["bloodtype"] = PlayerData.metadata["bloodtype"] ~= nil and PlayerData.metadata["bloodtype"] or BJCore.Config.Player.Bloodtypes[math.random(1, #BJCore.Config.Player.Bloodtypes)]
	PlayerData.metadata["washrep"] = PlayerData.metadata["washrep"] ~= nil and PlayerData.metadata["washrep"] or 0
	PlayerData.metadata["dealerrep"] = PlayerData.metadata["dealerrep"] ~= nil and PlayerData.metadata["dealerrep"] or 0
	PlayerData.metadata["hackerrep"] = PlayerData.metadata["hackerrep"] ~= nil and PlayerData.metadata["hackerrep"] or 0
	PlayerData.metadata["weedrep"] = PlayerData.metadata["weedrep"] ~= nil and PlayerData.metadata["weedrep"] or 0
	PlayerData.metadata["cokefield"] = PlayerData.metadata["cokefield"] ~= nil and PlayerData.metadata["cokefield"] or 0
	PlayerData.metadata["cokelab"] = PlayerData.metadata["cokelab"] ~= nil and PlayerData.metadata["cokelab"] or 0
	PlayerData.metadata["craftingrep"] = PlayerData.metadata["craftingrep"] ~= nil and PlayerData.metadata["craftingrep"] or 0
	PlayerData.metadata["attachmentcraftingrep"] = PlayerData.metadata["attachmentcraftingrep"] ~= nil and PlayerData.metadata["attachmentcraftingrep"] or 0
	PlayerData.metadata["currentapartment"] = PlayerData.metadata["currentapartment"] ~= nil and PlayerData.metadata["currentapartment"] or nil
	PlayerData.metadata["jobrep"] = PlayerData.metadata["jobrep"] ~= nil and PlayerData.metadata["jobrep"] or {
		["tow"] = 0,
		["trucker"] = 0,
		["taxi"] = 0,
		["hotdog"] = 0,
		["hunting"] = 0,
		["fishing"] = 0,
		["delivery"] = 0,
		["garbage"] = 0
	}
	PlayerData.metadata["callsign"] = PlayerData.metadata["callsign"] ~= nil and PlayerData.metadata["callsign"] or "NO CALLSIGN"
	PlayerData.metadata["fingerprint"] = PlayerData.metadata["fingerprint"] ~= nil and PlayerData.metadata["fingerprint"] or BJCore.Player.CreateFingerId()
	PlayerData.metadata["walletid"] = PlayerData.metadata["walletid"] ~= nil and PlayerData.metadata["walletid"] or BJCore.Player.CreateWalletId()
	PlayerData.metadata["criminalrecord"] = PlayerData.metadata["criminalrecord"] ~= nil and PlayerData.metadata["criminalrecord"] or {
		["hasRecord"] = false,
		["date"] = nil
	}
	PlayerData.metadata["licences"] = PlayerData.metadata["licences"] ~= nil and PlayerData.metadata["licences"] or {
		["driver"] = false,
		["business"] = false,
		["gun"] = false,
	}
	PlayerData.metadata["inside"] = PlayerData.metadata["inside"] ~= nil and PlayerData.metadata["inside"] or {
		house = nil,
		apartment = {
			apartmentType = nil,
			apartmentId = nil,
		}
	}
	PlayerData.metadata["phonedata"] = PlayerData.metadata["phonedata"] ~= nil and PlayerData.metadata["phonedata"] or {
        SerialNumber = BJCore.Player.CreateSerialNumber(),
        InstalledApps = {},
    }
	PlayerData.metadata["lastlogout"] = PlayerData.metadata["lastlogout"] ~= nil and PlayerData.metadata["lastlogout"] or 0

    PlayerData.job = PlayerData.job ~= nil and PlayerData.job or {}
	PlayerData.job.name = PlayerData.job.name ~= nil and PlayerData.job.name or "unemployed"
	PlayerData.job.label = PlayerData.job.label ~= nil and PlayerData.job.label or "Unemployed"
	PlayerData.job.isPolice = PlayerData.job.isPolice ~= nil and PlayerData.job.isPolice or false
	PlayerData.job.payment = PlayerData.job.payment ~= nil and PlayerData.job.payment or 10
	PlayerData.job.onduty = PlayerData.job.onduty ~= nil and PlayerData.job.onduty or true
	PlayerData.job.grade = PlayerData.job.grade ~= nil and PlayerData.job.grade or {}

	if PlayerData.job.grade.level == nil then
		PlayerData.job.grade.level = 1
	end
	if PlayerData.job.grade.name == nil then
		if BJCore.Shared.Jobs[PlayerData.job.name].grades and BJCore.Shared.Jobs[PlayerData.job.name].grades[PlayerData.job.grade.level] then
			PlayerData.job.grade.name = BJCore.Shared.Jobs[PlayerData.job.name].grades[PlayerData.job.grade.level].name
		elseif BJCore.Shared.Jobs[PlayerData.job.name].grades and BJCore.Shared.Jobs[PlayerData.job.name].grades[1] then
			PlayerData.job.grade.name = BJCore.Shared.Jobs[PlayerData.job.name].grades[1].name
			PlayerData.job.grade.level = 1
		else
			PlayerData.job.grade.name = PlayerData.job.name
		end
	end

    PlayerData.gang = PlayerData.gang ~= nil and PlayerData.gang or {}
	PlayerData.gang.name = PlayerData.gang.name ~= nil and PlayerData.gang.name or "none"
	PlayerData.gang.label = PlayerData.gang.label ~= nil and PlayerData.gang.label or "No Gang"

	PlayerData.gang.grade = PlayerData.gang.grade ~= nil and PlayerData.gang.grade or {}

	if PlayerData.gang.grade.level == nil then
		PlayerData.gang.grade.level = 1
	end
	if PlayerData.gang.grade.name == nil then
		if BJCore.Shared.Gangs[PlayerData.gang.name].grades and BJCore.Shared.Gangs[PlayerData.gang.name].grades[PlayerData.gang.grade.level] then
			PlayerData.gang.grade.name = BJCore.Shared.Gangs[PlayerData.gang.name].grades[PlayerData.gang.grade.level].name
		elseif BJCore.Shared.Gangs[PlayerData.gang.name].grades and BJCore.Shared.Gangs[PlayerData.gang.name].grades[1] then
			PlayerData.gang.grade.name = BJCore.Shared.Gangs[PlayerData.gang.name].grades[1].name
			PlayerData.gang.grade.level = 1
		else
			PlayerData.gang.grade.name = PlayerData.gang.name
		end
	end

    PlayerData.position = PlayerData.position ~= nil and PlayerData.position or BJConfig.DefaultSpawn
	PlayerData.LoggedIn = true

    PlayerData = BJCore.Player.LoadInventory(PlayerData)

	BJCore.Player.CreatePlayer(PlayerData)
end

function copyTable(datatable)
    local tblRes={}
    if type(datatable)=="table" then
        for k,v in pairs(datatable) do
            tblRes[k] = copyTable(v)
        end
    else
        tblRes = datatable
    end
    return tblRes
end

BJCore.Player.CreatePlayer = function(PlayerData)
	local self = {}
	self.Functions = {}
	self.PlayerData = PlayerData

    self.Functions.GetClientPlayerData = function()
        local playerData = copyTable(self.PlayerData)
        local newInv = {}

        for i,item in pairs(self.PlayerData.items) do
            newInv[i] = {
                slot = item.slot,
                name = item.name,
                amount = item.amount,
                info = item.info
            }
        end

        playerData.items = newInv

        return playerData
    end


	self.Functions.UpdatePlayerData = function()
		TriggerClientEvent("BJCore:Player:SetPlayerData", self.PlayerData.source, self.Functions.GetClientPlayerData())
		BJCore.Commands.Refresh(self.PlayerData.source)
	end

	self.Functions.SetJob = function(job, grade)
		local job = job:lower()
		if grade == nil then grade = 1; end
		if BJCore.Shared.Jobs[job] ~= nil and BJCore.Shared.Jobs[job].grades[grade] then
			self.PlayerData.job.name = job
			self.PlayerData.job.label = BJCore.Shared.Jobs[job].label
			self.PlayerData.job.onduty = BJCore.Shared.Jobs[job].defaultDuty
			self.PlayerData.job.isPolice = BJCore.Shared.Jobs[job].isPolice

			local jobgrade = BJCore.Shared.Jobs[job].grades[grade]
			self.PlayerData.job.grade = {}
			self.PlayerData.job.grade.name = jobgrade.name
			self.PlayerData.job.grade.level = grade
			self.PlayerData.job.payment = jobgrade.payment ~= nil and jobgrade.payment or 30
			self.Functions.UpdatePlayerData()
			TriggerClientEvent("BJCore:Client:OnJobUpdate", self.PlayerData.source, self.PlayerData.job)
			return true
		else
			return false
		end
	end

	self.Functions.SetGang = function(gang, grade)
		local gang = gang:lower()
		if grade == nil then grade = 1; end
		if BJCore.Shared.Gangs[gang] ~= nil and BJCore.Shared.Gangs[gang].grades[grade] then
			self.PlayerData.gang.name = gang
			self.PlayerData.gang.label = BJCore.Shared.Gangs[gang].label

			local ganggrade = BJCore.Shared.Gangs[gang].grades[grade]
			self.PlayerData.gang.grade = {}
			self.PlayerData.gang.grade.name = ganggrade.name
			self.PlayerData.gang.grade.level = grade
			self.Functions.UpdatePlayerData()
			TriggerClientEvent("BJCore:Client:OnGangUpdate", self.PlayerData.source, self.PlayerData.gang)
			return true
		else
			return false
		end
	end

	self.Functions.SetJobDuty = function(onDuty)
		self.PlayerData.job.onduty = onDuty
		self.Functions.UpdatePlayerData()
		TriggerClientEvent("BJCore:Client:OnJobUpdate", self.PlayerData.source, self.PlayerData.job)
	end

	self.Functions.ChangeIban = function(iban)
	    self.PlayerData.charinfo.account = iban
	    self.Functions.UpdatePlayerData()
	end

	self.Functions.SetMetaData = function(meta, val)
		local meta = meta:lower()
		if val ~= nil then
			self.PlayerData.metadata[meta] = val
			self.Functions.UpdatePlayerData()
			if string.match(meta, 'rep') then
				TriggerClientEvent("InteractSound_CL:PlayOnOne", self.PlayerData.source, "rep2", 0.2)
			end
		end
	end

	self.Functions.AddJobReputation = function(job, amount)
		local amount = tonumber(amount)
		if not self.PlayerData.metadata["jobrep"][job] then
			self.PlayerData.metadata["jobrep"][job] = 0
		end
		self.PlayerData.metadata["jobrep"][job] = self.PlayerData.metadata["jobrep"][job] + amount
		self.Functions.UpdatePlayerData()
		TriggerClientEvent("InteractSound_CL:PlayOnOne", self.PlayerData.source, "rep2", 0.2)
	end

	self.Functions.AddMoney = function(moneytype, amount, reason)
		reason = reason ~= nil and reason or "unkown"
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if amount < 0 then return end
		if self.PlayerData.money[moneytype] ~= nil then
			self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype]+amount
			self.Functions.UpdatePlayerData()
			TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "moneyadded", {amount=amount, moneytype=moneytype, newbalance=self.PlayerData.money[moneytype], reason=reason})
			if amount > 100000 then
				TriggerEvent("bj-log:server:CreateLog", "playermoney", "AddMoney", "lightgreen", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** "..BJCore.Config.Currency.Symbol..amount .. " ("..moneytype..") added, new "..moneytype.." balance: "..self.PlayerData.money[moneytype], true)
			else
				TriggerEvent("bj-log:server:CreateLog", "playermoney", "AddMoney", "lightgreen", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** "..BJCore.Config.Currency.Symbol..amount .. " ("..moneytype..") added, new "..moneytype.." balance: "..self.PlayerData.money[moneytype])
			end
			TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, false)
			return true
		end
		return false
	end

	self.Functions.RemoveMoney = function(moneytype, amount, reason)
		reason = reason ~= nil and reason or "unknown"
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if amount < 0 then return end
		if self.PlayerData.money[moneytype] ~= nil then
			for _, mtype in pairs(BJCore.Config.Money.DontAllowMinus) do
				if mtype == moneytype then
					if self.PlayerData.money[moneytype] - amount < 0 then return false end
				end
			end
			self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
			self.Functions.UpdatePlayerData()
			TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "moneyremoved", {amount=amount, moneytype=moneytype, newbalance=self.PlayerData.money[moneytype], reason=reason})
			if amount > 100000 then
				TriggerEvent("bj-log:server:CreateLog", "playermoney", "RemoveMoney", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** "..BJCore.Config.Currency.Symbol..amount .. " ("..moneytype..") removed, new "..moneytype.." balance: "..self.PlayerData.money[moneytype], true)
			else
				TriggerEvent("bj-log:server:CreateLog", "playermoney", "RemoveMoney", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** "..BJCore.Config.Currency.Symbol..amount .. " ("..moneytype..") removed, new "..moneytype.." balance: "..self.PlayerData.money[moneytype])
			end
			TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, true)
			if moneytype == "bank" then TriggerClientEvent('phone:client:RemoveBankMoney', self.PlayerData.source, amount); end
			return true
		end
		return false
	end

	self.Functions.SetMoney = function(moneytype, amount, reason)
		reason = reason ~= nil and reason or "unkown"
		local moneytype = moneytype:lower()
		local amount = tonumber(amount)
		if amount < 0 then return end
		if self.PlayerData.money[moneytype] ~= nil then
			self.PlayerData.money[moneytype] = amount
			self.Functions.UpdatePlayerData()
			TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "moneyset", {amount=amount, moneytype=moneytype, newbalance=self.PlayerData.money[moneytype], reason=reason})
			TriggerEvent("bj-log:server:CreateLog", "playermoney", "SetMoney", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** "..BJCore.Config.Currency.Symbol..amount .. " ("..moneytype..") gezet, nieuw "..moneytype.." balans: "..self.PlayerData.money[moneytype])
			return true
		end
		return false
	end

	self.Functions.AddItem = function(item, amount, slot, info)
		local totalWeight = BJCore.Player.GetTotalWeight(self.PlayerData.items)
		local itemInfo = BJCore.Shared.Items[item:lower()]
		if itemInfo == nil then TriggerClientEvent('chatMessage', self.PlayerData.source, "SYSTEM",  "warning", "Item not found") return end
		local amount = tonumber(amount)
		local loop = 1
		local success = false
		if (totalWeight + (itemInfo["weight"] * amount)) > BJCore.Config.Player.MaxWeight then return false; end
		if itemInfo["unique"] and amount > 1 then loop = amount amount = 1; end
		if loop > self.Functions.GetTotalAvailableSlots() then return false; end
		local slot = tonumber(slot) ~= nil and tonumber(slot) or BJCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
		for i = 1, loop, 1 do
			if itemInfo["unique"] and (loop > 1 and i > 1) then info = {} slot = nil end
			if itemInfo["type"] == "weapon" and (info == nil or next(info) == nil) then
				info = {
					serial = tostring(BJCore.Shared.RandomInt(2) .. BJCore.Shared.RandomStr(3) .. BJCore.Shared.RandomInt(1) .. BJCore.Shared.RandomStr(2) .. BJCore.Shared.RandomInt(3) .. BJCore.Shared.RandomStr(4)),
				}
			elseif itemInfo["type"] == "cashstorage" and (info == nil or next(info) == nil) then
				info = {
					cash = 0
				}
			elseif itemInfo["type"] == "itemstorage" and (info == nil or next(info) == nil) then
				info = {
					stashId = exports["storage"]:CreateStorageItemId()
				}
			end
			if (slot ~= nil and self.PlayerData.items[slot] ~= nil) and (self.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo["type"] == "item" and not itemInfo["unique"]) then
				self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount + amount
				self.Functions.UpdatePlayerData()
				TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemadded", {name=self.PlayerData.items[slot].name, amount=amount, slot=slot, newamount=self.PlayerData.items[slot].amount, reason="unkown"})
				TriggerEvent("bj-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " added", "success")
				success = true
			elseif (not itemInfo["unique"] and slot or slot ~= nil and self.PlayerData.items[slot] == nil) then
				self.PlayerData.items[slot] = {name = itemInfo["name"], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = slot, combinable = itemInfo["combinable"]}
				self.Functions.UpdatePlayerData()
				TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemadded", {name=self.PlayerData.items[slot].name, amount=amount, slot=slot, newamount=self.PlayerData.items[slot].amount, reason="unkown"})
				TriggerEvent("bj-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " added", "success")
				success = true
			elseif (itemInfo["unique"]) or (not slot or slot == nil) or (itemInfo["type"] == "weapon") then
				local i = self.Functions.GetNextAvailableSlot()
				self.PlayerData.items[i] = {name = itemInfo["name"], amount = amount, info = info ~= nil and info or "", label = itemInfo["label"], description = itemInfo["description"] ~= nil and itemInfo["description"] or "", weight = itemInfo["weight"], type = itemInfo["type"], unique = itemInfo["unique"], useable = itemInfo["useable"], image = itemInfo["image"], shouldClose = itemInfo["shouldClose"], slot = i, combinable = itemInfo["combinable"]}
				self.Functions.UpdatePlayerData()
				TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemadded", {name=self.PlayerData.items[i].name, amount=amount, slot=i, newamount=self.PlayerData.items[i].amount, reason="unkown"})
				TriggerEvent("bj-log:server:CreateLog", "playerinventory", "AddItem", "green", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** got item: [slot:" ..i.."], itemname: " .. self.PlayerData.items[i].name .. ", added amount: " .. amount ..", new total amount: ".. self.PlayerData.items[i].amount)
                success = true
			end
			Wait(10)
        end
		return success
	end

	self.Functions.GetTotalAvailableSlots = function()
	    local count = 0
		for i = 1, BJConfig.Player.MaxInvSlots, 1 do
			if self.PlayerData.items[i] == nil then
				count = count + 1
			end
		end
		return count
	end

	self.Functions.GetNextAvailableSlot = function()
		for i = 1, BJConfig.Player.MaxInvSlots, 1 do
			if self.PlayerData.items[i] == nil then
				return i
			end
		end
	end

	self.Functions.RemoveItem = function(item, amount, slot)
		local itemInfo = BJCore.Shared.Items[item:lower()]
		local amount = tonumber(amount)
		local slot = tonumber(slot)
		if slot ~= nil then
			if self.PlayerData.items[slot].amount > amount then
				self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amount
				TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, item)
				Wait(100)
				self.Functions.UpdatePlayerData()
				TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemremoved", {name=self.PlayerData.items[slot].name, amount=amount, slot=slot, newamount=self.PlayerData.items[slot].amount, reason="unkown"})
				TriggerEvent("bj-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
				--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " removed", "error")
				return true
			else
				self.PlayerData.items[slot] = nil
				TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, item)
				Wait(100)
				self.Functions.UpdatePlayerData()
				TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemremoved", {name=item, amount=amount, slot=slot, newamount=0, reason="unkown"})
				TriggerEvent("bj-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
				--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " removed", "error")
				return true
			end
		else
			local slots = BJCore.Player.GetSlotsByItem(self.PlayerData.items, item)
			local amountToRemove = amount
			if slots ~= nil then
				if self.Functions.GetItemAmountByName(item) >= amountToRemove then
					for _, slot in pairs(slots) do
						if self.PlayerData.items[slot].amount > amountToRemove then
							self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amountToRemove
							TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, item)
							Wait(100)
							self.Functions.UpdatePlayerData()
							TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemremoved", {name=self.PlayerData.items[slot].name, amount=amount, slot=slot, newamount=self.PlayerData.items[slot].amount, reason="unkown"})
							TriggerEvent("bj-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. self.PlayerData.items[slot].name .. ", removed amount: " .. amount ..", new total amount: ".. self.PlayerData.items[slot].amount)
							--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " removed", "error")
							return true
						elseif self.PlayerData.items[slot].amount == amountToRemove then
							self.PlayerData.items[slot] = nil
							TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, item)
							Wait(100)
							self.Functions.UpdatePlayerData()
							TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemremoved", {name=item, amount=amount, slot=slot, newamount=0, reason="unkown"})
							TriggerEvent("bj-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
							--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " removed", "error")
							return true
						elseif self.PlayerData.items[slot].amount < amountToRemove then
							if amountToRemove - self.PlayerData.items[slot].amount < 0 then
								amountToRemove = 0
								self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amountToRemove
							else
								amountToRemove = amountToRemove - self.PlayerData.items[slot].amount
								self.PlayerData.items[slot] = nil
							end
							TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, item)
							Wait(100)
							self.Functions.UpdatePlayerData()
							TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "itemremoved", {name=item, amount=amount, slot=slot, newamount=0, reason="unkown"})
							TriggerEvent("bj-log:server:CreateLog", "playerinventory", "RemoveItem", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** lost item: [slot:" ..slot.."], itemname: " .. item .. ", removed amount: " .. amount ..", item removed")
							--TriggerClientEvent('BJCore:Notify', self.PlayerData.source, itemInfo["label"].. " removed", "error")
							if amountToRemove <= 0 then
								return true
							end
						end
					end
				end
			end
		end
		return false
	end

	self.Functions.UpdateItemInfo = function(slot, data)
		local slot = tonumber(slot)
		if self.PlayerData.items[slot] ~= nil then
            self.PlayerData.items[slot].info = data
			self.Functions.UpdatePlayerData()
		end
	end

	self.Functions.SetInventory = function(items)
		self.PlayerData.items = items
		self.Functions.UpdatePlayerData()
		--TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "setinventory", {items=json.encode(items)})
		--TriggerEvent("bj-log:server:CreateLog", "playerinventory", "SetInventory", "blue", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** items set: " .. json.encode(items))
	end

	self.Functions.ClearInventory = function()
		--TriggerClientEvent("inventory:client:CheckWeapon", self.PlayerData.source, nil, true)
		self.PlayerData.items = {}
		self.Functions.UpdatePlayerData()
		TriggerEvent("bj-log:server:sendLog", self.PlayerData.citizenid, "clearinventory", {})
		TriggerEvent("bj-log:server:CreateLog", "playerinventory", "ClearInventory", "red", "**"..GetPlayerName(self.PlayerData.source) .. " (citizenid: "..self.PlayerData.citizenid.." | id: "..self.PlayerData.source..")** inventory cleared")
	end

	self.Functions.GetItemByName = function(item)
		local item = tostring(item):lower()
		local slot = BJCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
		if slot ~= nil then
			return self.PlayerData.items[slot]
		end
		return nil
	end

	self.Functions.GetItemAmountByName = function(item)
		local amount = 0
		local item = tostring(item):lower()
		for k,v in pairs(self.PlayerData.items) do
			if v.name == item then
				amount = amount + v.amount
			end
		end
		return amount
	end

	self.Functions.GetItemBySlot = function(slot)
		local slot = tonumber(slot)
		if self.PlayerData.items[slot] ~= nil then
			return self.PlayerData.items[slot]
		end
		return nil
	end

	self.Functions.Save = function()
		BJCore.Player.Save(self.PlayerData.source)
	end

	BJCore.Players[self.PlayerData.source] = self
	BJCore.Player.Save(self.PlayerData.source)
	self.Functions.UpdatePlayerData()
	TriggerClientEvent("BJCore:Client:OnPermissionUpdate", self.PlayerData.source, BJCore.Functions.GetPermission(self.PlayerData.source))
end

BJCore.Player.Save = function(source)
	local PlayerData = BJCore.Players[source].PlayerData
	-- if exports.voice then
	-- 	local players = exports.voice:GetInfinityPlayers()
	-- 	if players and players[source] and players[source].pos then
	-- 		PlayerData.position.x = players[source].pos.x
	-- 		PlayerData.position.y = players[source].pos.y
	-- 		PlayerData.position.z = players[source].pos.z
	-- 	end
	-- end
	if PlayerData ~= nil then
		BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..PlayerData.citizenid.."'", function(result)
			if result[1] == nil then
				BJCore.Functions.ExecuteSql(true, "INSERT INTO `players` (`citizenid`, `cid`, `steam`, `license`, `name`, `money`, `charinfo`, `job`, `gang`, `position`, `metadata`) VALUES ('"..PlayerData.citizenid.."', '"..tonumber(PlayerData.cid).."', '"..PlayerData.steam.."', '"..PlayerData.license.."', '"..PlayerData.name.."', '"..json.encode(PlayerData.money).."', '"..BJCore.EscapeSqli(json.encode(PlayerData.charinfo)).."', '"..BJCore.EscapeSqli(json.encode(PlayerData.job)).."', '"..json.encode(PlayerData.gang).."', '"..json.encode(PlayerData.position).."', '"..BJCore.EscapeSqli(json.encode(PlayerData.metadata)).."')")
			else
				BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET steam='"..PlayerData.steam.."',license='"..PlayerData.license.."',name='"..PlayerData.name.."',money='"..json.encode(PlayerData.money).."',charinfo='"..BJCore.EscapeSqli(json.encode(PlayerData.charinfo)).."',job='"..BJCore.EscapeSqli(json.encode(PlayerData.job)).."',gang='"..json.encode(PlayerData.gang).."', position='"..json.encode(PlayerData.position).."',metadata='"..BJCore.EscapeSqli(json.encode(PlayerData.metadata)).."' WHERE `citizenid` = '"..PlayerData.citizenid.."'")
			end
			BJCore.Player.SaveInventory(source)
		end)
		BJCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .." PLAYER SAVED")
	else
		BJCore.ShowError(GetCurrentResourceName(), "ERROR BJCore.PLAYER.SAVE - PLAYERDATA IS EMPTY")
	end
end

BJCore.Player.Logout = function(source)
	TriggerClientEvent('BJCore:Client:OnPlayerUnload', source)
	TriggerClientEvent("BJCore:Player:UpdatePlayerData", source, true)
	Citizen.Wait(200)
	-- BJCore.Players[source].Functions.Save()
	-- TriggerEvent('BJCore:Server:OnPlayerUnload')
	BJCore.Players[source].Functions.SetMetaData("lastlogout", os.time())
	TriggerEvent("bj-log:server:CreateLog", BJCore.Players[source].PlayerData.job.name.."_duty", "Duty Alert", "green", "**"..BJCore.Players[source].PlayerData.charinfo.firstname.." "..BJCore.Players[source].PlayerData.charinfo.lastname.."** ("..BJCore.Players[source].PlayerData.citizenid..") has gone **Off Duty** (Logged Out/Switched Chars)")
	BJCore.Players[source] = nil
	TriggerClientEvent('bj-core:multichar:client:sendToCharSelect', source)
end

BJCore.Player.DeleteCharacter = function(source, citizenid)
	BJCore.Functions.ExecuteSql(true, "DELETE FROM `players` WHERE `citizenid` = '"..citizenid.."'")
	TriggerEvent("bj-log:server:sendLog", citizenid, "characterdeleted", {})
	TriggerEvent("bj-log:server:CreateLog", "joinleave", "Character Deleted", "red", "**".. GetPlayerName(source) .. "** ("..GetPlayerIdentifiers(source)[1]..") deleted **"..citizenid.."**..")
end

BJCore.Player.LoadInventory = function(PlayerData)
	PlayerData.items = {}
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..PlayerData.citizenid.."'", function(result)
		if result[1] ~= nil then
			if result[1].inventory ~= nil then
				plyInventory = json.decode(result[1].inventory)
				if next(plyInventory) ~= nil then
					local itemsToFill = {}
					for _, item in pairs(plyInventory) do
						if item ~= nil then
							local itemInfo = BJCore.Shared.Items[item.name:lower()]
							if itemInfo ~= nil then
								local addItem = {
									name = itemInfo["name"],
									amount = item.amount,
									info = item.info ~= nil and item.info or "",
									label = itemInfo["label"],
									description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
									weight = itemInfo["weight"],
									type = itemInfo["type"],
									unique = itemInfo["unique"],
									useable = itemInfo["useable"],
									image = itemInfo["image"],
									shouldClose = itemInfo["shouldClose"],
									combinable = itemInfo["combinable"]
								}
								if item.slot == nil then
									table.insert(itemsToFill, addItem)
								else
									addItem.slot = item.slot
									PlayerData.items[item.slot] = addItem
								end
							end
						end
					end

					for _, item in pairs(itemsToFill) do
						for i = 1, BJConfig.Player.MaxInvSlots, 1 do
							if PlayerData.items[i] == nil then
								item.slot = i
								PlayerData.items[i] = item
								break
							end
						end
					end
				end
			end
		end
	end)
	return PlayerData
end

BJCore.Player.SaveInventory = function(source)
	if BJCore.Players[source] ~= nil then
		local PlayerData = BJCore.Players[source].PlayerData
		local items = PlayerData.items
		local ItemsJson = {}
		if items ~= nil and next(items) ~= nil then
			for slot, item in pairs(items) do
				if items[slot] ~= nil then
					table.insert(ItemsJson, {
						name = item.name,
						amount = item.amount,
						info = item.info,
						type = item.type,
						slot = slot,
					})
				end
			end
		end
		BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET `inventory` = '"..BJCore.EscapeSqli(json.encode(ItemsJson)).."' WHERE `citizenid` = '"..PlayerData.citizenid.."'")
	end
end

BJCore.Player.GetTotalWeight = function(items)
	local weight = 0
	if items ~= nil then
		for slot, item in pairs(items) do
			weight = weight + (item.weight * item.amount)
		end
	end
	return tonumber(weight)
end

BJCore.Player.GetSlotsByItem = function(items, itemName)
	local slotsFound = {}
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				table.insert(slotsFound, slot)
			end
		end
	end
	return slotsFound
end

BJCore.Player.GetFirstSlotByItem = function(items, itemName)
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				return tonumber(slot)
			end
		end
	end
	return nil
end

BJCore.Player.CreateCitizenId = function()
	local UniqueFound = false
	local CitizenId = nil

	while not UniqueFound do
		CitizenId = tostring(BJCore.Shared.RandomStr(3) .. BJCore.Shared.RandomInt(5)):upper()
		BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM `players` WHERE `citizenid` = '"..CitizenId.."'", function(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return CitizenId
end

BJCore.Player.CreateFingerId = function()
	local UniqueFound = false
	local FingerId = nil
	while not UniqueFound do
		FingerId = tostring(BJCore.Shared.RandomStr(2) .. BJCore.Shared.RandomInt(3) .. BJCore.Shared.RandomStr(1) .. BJCore.Shared.RandomInt(2) .. BJCore.Shared.RandomStr(3) .. BJCore.Shared.RandomInt(4))
		BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE '%"..FingerId.."%'", function(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return FingerId
end

BJCore.Player.CreateWalletId = function()
	local UniqueFound = false
	local WalletId = nil
	while not UniqueFound do
		WalletId = "BJ-"..math.random(11111111, 99999999)
		BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE '%"..WalletId.."%'", function(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return WalletId
end

BJCore.Player.CreateSerialNumber = function()
    local UniqueFound = false
    local SerialNumber = nil

    while not UniqueFound do
        SerialNumber = math.random(11111111, 99999999)
        BJCore.Functions.ExecuteSql(true, "SELECT COUNT(*) as count FROM players WHERE metadata LIKE '%"..SerialNumber.."%'", function(result)
            if result[1].count == 0 then
                UniqueFound = true
            end
        end)
    end
    return SerialNumber
end

BJCore.EscapeSqli = function(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end
BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

local PlayerInjuries = {}
local PlayerWeaponWounds = {}

local whitelistItem = {
	['phone'] = true,
	['id_card'] = true,
	['driver_license'] = true,
}

RegisterServerEvent('hospital:server:RespawnAtHospital')
AddEventHandler('hospital:server:RespawnAtHospital', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local preCash = Player.PlayerData.money["cash"]
	local yoinked = {}
	for k,v in pairs(Player.PlayerData.items) do
        if not whitelistItem[v.name] then
        	Player.Functions.RemoveItem(v.name, v.amount)
        	table.insert(yoinked,{item = v.name, amount = v.amount})
        end
	end
	Player.Functions.SetMoney('cash', 0, 'respawn')
	TriggerClientEvent('hospital:client:SendToHospital', src)
	TriggerEvent("bj-log:server:CreateLog", "ems", "Player Respawned", "green", "**"..Player.PlayerData.name .. "** has respawned and has lost "..BJCore.Config.Currency.Symbol..preCash.." cash and items: "..BJCore.Common.Dump(yoinked))
	-- Player.Functions.ClearInventory()
	-- BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET `inventory` = '"..BJCore.EscapeSqli(json.encode({})).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
	-- Player.Functions.RemoveMoney("bank", Config.BillCost, "respawned-at-hospital")
	TriggerClientEvent('BJCore:Notify', src, 'All your possessions have been taken', 'primary', 10000)
	--TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
	return
end)

RegisterServerEvent('hospital:server:SyncInjuries')
AddEventHandler('hospital:server:SyncInjuries', function(data)
    local src = source
    PlayerInjuries[src] = data
end)

RegisterServerEvent('hospital:server:SetWeaponDamage')
AddEventHandler('hospital:server:SetWeaponDamage', function(data)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then 
		PlayerWeaponWounds[Player.PlayerData.source] = data
	end
end)

RegisterServerEvent('hospital:server:RestoreWeaponDamage')
AddEventHandler('hospital:server:RestoreWeaponDamage', function()
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	PlayerWeaponWounds[Player.PlayerData.source] = nil
end)

RegisterServerEvent('hospital:server:SetDeathStatus')
AddEventHandler('hospital:server:SetDeathStatus', function(isDead)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.Functions.SetMetaData("isdead", isDead)
	end
end)

RegisterServerEvent('hospital:server:SetLaststandStatus')
AddEventHandler('hospital:server:SetLaststandStatus', function(bool)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.Functions.SetMetaData("inlaststand", bool)
	end
end)

RegisterServerEvent('hospital:server:SetArmor')
AddEventHandler('hospital:server:SetArmor', function(amount)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.Functions.SetMetaData("armor", amount)
	end
end)

RegisterServerEvent('hospital:server:TreatWounds')
AddEventHandler('hospital:server:TreatWounds', function(playerId)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local Patient = BJCore.Functions.GetPlayer(playerId)
	if Patient ~= nil then
		if Player.PlayerData.job.name == "doctor" then
			TriggerClientEvent("hospital:client:HealInjuries", Patient.PlayerData.source, "full")
		elseif Player.PlayerData.job.name == "ambulance" then
			TriggerClientEvent("hospital:client:HealInjuries", Patient.PlayerData.source, "partial")
		end
		TriggerEvent("bj-log:server:CreateLog", "ems", "Player Treated", "green", "**"..Player.PlayerData.name .. "** has treated (treat wounds) **"..Patient.PlayerData.name.."**.")
	end
end)

RegisterServerEvent('hospital:server:SetDoctor')
AddEventHandler('hospital:server:SetDoctor', function()
	local amount = 0
	for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "doctor" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	TriggerClientEvent("hospital:client:SetDoctorCount", -1, amount)
end)

RegisterServerEvent('hospital:server:RevivePlayer')
AddEventHandler('hospital:server:RevivePlayer', function(playerId, isOldMan)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local Patient = BJCore.Functions.GetPlayer(playerId)
	local oldMan = isOldMan ~= nil and isOldMan or false
	if Patient ~= nil then
		if oldMan then
			if Player.Functions.RemoveMoney("cash", 5000, "revived-player") then
				TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
			else
				TriggerClientEvent('BJCore:Notify', src, "You don\'t have enough money on you", "error")
			end
		else
			TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
			TriggerEvent("bj-log:server:CreateLog", "ems", "Player Revived", "green", "**"..Player.PlayerData.name .. "** has revived **"..Patient.PlayerData.name.."**.")
		end
	end
end)

RegisterServerEvent('hospital:server:SendDoctorAlert')
AddEventHandler('hospital:server:SendDoctorAlert', function()
	local src = source
	for k, v in pairs(BJCore.Functions.GetPlayers()) do
		local Player = BJCore.Functions.GetPlayer(v)
		if Player ~= nil then 
			if (Player.PlayerData.job.name == "doctor" and Player.PlayerData.job.onduty) then
				TriggerClientEvent("hospital:client:SendAlert", v, "A doctor is needed at Pillbox Hospital")
			end
		end
	end
end)

RegisterServerEvent('hospital:server:MakeDeadCall')
AddEventHandler('hospital:server:MakeDeadCall', function(blipSettings, gender, street1, street2)
	local src = source
	local genderstr = "Man"

	if gender == 1 then genderstr = "Woman" end

	if street2 ~= nil then
		TriggerClientEvent("112:client:SendAlert", -1, "A ".. genderstr .." is injured at " ..street1 .. " "..street2, blipSettings)
		TriggerClientEvent('bj-policealerts:client:AddPoliceAlert', -1, {
            timeOut = 5000,
            alertTitle = "Injured person",
            details = {
                [1] = {
                    icon = '<i class="fas fa-venus-mars"></i>',
                    detail = genderstr,
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = street1.. ' '..street2,
                },
            },
            callSign = nil,
        }, true)
	else
		TriggerClientEvent("112:client:SendAlert", -1, "A ".. genderstr .." is injured at "..street1, blipSettings)
		TriggerClientEvent('bj-policealerts:client:AddPoliceAlert', -1, {
            timeOut = 5000,
            alertTitle = "Injured person",
            details = {
                [1] = {
                    icon = '<i class="fas fa-venus-mars"></i>',
                    detail = genderstr,
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = street1,
                },
            },
            callSign = nil,
        }, true)
	end
end)

BJCore.Functions.RegisterServerCallback('hospital:GetDoctors', function(source, cb)
	local amount = 0
	for k, v in pairs(BJCore.Functions.GetPlayers()) do
		local Player = BJCore.Functions.GetPlayer(v)
		if Player ~= nil then 
			if (Player.PlayerData.job.name == "doctor" and Player.PlayerData.job.onduty) then
				amount = amount + 1
			end
		end
	end
	cb(amount)
end)


function GetCharsInjuries(source)
    return PlayerInjuries[source]
end

function GetActiveInjuries(source)
	local injuries = {}
	if (PlayerInjuries[source].isBleeding > 0) then
		injuries["BLEED"] = PlayerInjuries[source].isBleeding
	end
	for k, v in pairs(PlayerInjuries[source].limbs) do
		if PlayerInjuries[source].limbs[k].isDamaged then
			injuries[k] = PlayerInjuries[source].limbs[k]
		end
	end
    return injuries
end

BJCore.Functions.RegisterServerCallback('hospital:GetPlayerStatus', function(source, cb, playerId)
	local Player = BJCore.Functions.GetPlayer(playerId)
	local injuries = {}
	injuries["WEAPONWOUNDS"] = {}
	if Player ~= nil then
		if PlayerInjuries[Player.PlayerData.source] ~= nil then
			if (PlayerInjuries[Player.PlayerData.source].isBleeding > 0) then
				injuries["BLEED"] = PlayerInjuries[Player.PlayerData.source].isBleeding
			end
			for k, v in pairs(PlayerInjuries[Player.PlayerData.source].limbs) do
				if PlayerInjuries[Player.PlayerData.source].limbs[k].isDamaged then
					injuries[k] = PlayerInjuries[Player.PlayerData.source].limbs[k]
				end
			end
		end
		if PlayerWeaponWounds[Player.PlayerData.source] ~= nil then 
			for k, v in pairs(PlayerWeaponWounds[Player.PlayerData.source]) do
				injuries["WEAPONWOUNDS"][k] = v
			end
		end
	end
    cb(injuries)
end)

BJCore.Functions.RegisterServerCallback('hospital:GetPlayerBleeding', function(source, cb)
	local src = source
	if PlayerInjuries[src] ~= nil and PlayerInjuries[src].isBleeding ~= nil then
		cb(PlayerInjuries[src].isBleeding)
	else
		cb(nil)
	end
end)

BJCore.Commands.Add("status", "Check a person his health", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.PlayerData.job.name == "doctor" or Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:CheckStatus", source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
	end
end)

BJCore.Commands.Add("heal", "Help a person his injuries", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.PlayerData.job.name == "doctor" or Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:TreatWounds", source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
	end
end)

BJCore.Commands.Add("revivep", "Revive a person", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.PlayerData.job.name == "doctor" then
		TriggerClientEvent("hospital:client:RevivePlayer", source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
	end
end)

BJCore.Commands.Add("revive", "Revive a player or yourself", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if args[1] ~= nil then
		local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
		if Target ~= nil then
			TriggerClientEvent('hospital:client:Revive', Target.PlayerData.source)
			TriggerEvent("bj-log:server:CreateLog", "bans", "Revive Player", "green", "**"..Player.PlayerData.name .. "** has revived **"..Target.PlayerData.name.."** using /revive command")
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not online")
		end
	else
		TriggerClientEvent('hospital:client:Revive', source)
	end
end, "helper")

BJCore.Commands.Add("setpain", "Set pain to a player or yourself", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	if args[1] ~= nil then
		local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
		if Player ~= nil then
			TriggerClientEvent('hospital:client:SetPain', Player.PlayerData.source)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not online")
		end
	else
		TriggerClientEvent('hospital:client:SetPain', source)
	end
end, "god")

BJCore.Commands.Add("kill", "Kill a player or yourself", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if args[1] ~= nil then
		local Target = BJCore.Functions.GetPlayer(tonumber(args[1]))
		if Target ~= nil then
			TriggerClientEvent('hospital:client:KillPlayer', Target.PlayerData.source)
			TriggerEvent("bj-log:server:CreateLog", "bans", "Kill Player", "green", "**"..Player.PlayerData.name .. "** has killed **"..Target.PlayerData.name.."** using /kill command")
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player not online")
		end
	else
		TriggerClientEvent('hospital:client:KillPlayer', source)
		TriggerEvent("bj-log:server:CreateLog", "bans", "Kill Player", "green", "**"..Player.PlayerData.name .. "** has killed themselves using /kill command")
	end
end, "senioradmin")

BJCore.Commands.Add("setambulance", "Give the ambulance job to someone ", {{name="id", help="Player ID"}, {name="grade", help="Job grade number"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if ((Myself.PlayerData.job.name == "ambulance" or Myself.PlayerData.job.name == "doctor") and Myself.PlayerData.job.onduty) and IsHighCommand(Myself.PlayerData.citizenid) then
            Player.Functions.SetJob("ambulance", tonumber(args[2]))
        end
    end
end)

BJCore.Commands.Add("setdoctor", "Give the doctor job to someone ", {{name="id", help="Player ID"}, {name="grade", help="Job grade number"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = BJCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if ((Myself.PlayerData.job.name == "ambulance" or Myself.PlayerData.job.name == "doctor") and Myself.PlayerData.job.onduty) and IsHighCommand(Myself.PlayerData.citizenid) then
            Player.Functions.SetJob("doctor", tonumber(args[2]))
        end
    end
end)

BJCore.Functions.CreateUseableItem("bandage", function(source, item)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseBandage", source)
	end
end)

BJCore.Functions.CreateUseableItem("painkillers", function(source, item)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UsePainkillers", source)
	end
end)

BJCore.Functions.CreateUseableItem("firstaid", function(source, item)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseFirstAid", source)
	end
end)

function IsHighCommand(citizenid)
    local retval = false
    for k, v in pairs(Config.Whitelist) do
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('hospital:server:UseFirstAid')
AddEventHandler('hospital:server:UseFirstAid', function(targetId)
	local src = source
	local Target = BJCore.Functions.GetPlayer(targetId)
	if Target ~= nil then
		TriggerClientEvent('hospital:client:CanHelp', targetId, src)
	end
end)

RegisterServerEvent('hospital:server:CanHelp')
AddEventHandler('hospital:server:CanHelp', function(helperId, canHelp)
	local src = source
	if canHelp then
		TriggerClientEvent('hospital:client:HelpPerson', helperId, src)
	else
		TriggerClientEvent('BJCore:Notify', helperId, "You can\'t help this person", "error")
	end
end)

EMSCount = 0

Patients = {}
Citizen.CreateThread(function()
	for i=1,#Config.Hospitals, 1 do
        Patients[i] = {}
	end
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
	for i=1,#Config.Hospitals, 1 do
        for k,v in pairs(Patients[i]) do
        	if Patients[i][k] == src then
        		Patients[i][k] = false
        	end
        end
	end
end)

BJCore.Commands.Add("resetbeds", "Treat a player at a hospital bed", {}, false, function(source, args)
	for i=1,#Config.Hospitals, 1 do
        Patients[i] = {}
	end
	TriggerClientEvent('BJCore:Notify', source, "Hospital beds reset", "error")
end, "god")

BJCore.Commands.Add("treatplayer", "Treat a player at a hospital bed", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("Pillbox:TreatPlayer", Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
	end
end)

-- BJCore.Commands.Add("clearbeds", "Clear beds in current hospital", {}, false, function(source, args)
-- 	local Player = BJCore.Functions.GetPlayer(source)
-- 	if Player.PlayerData.job.name == "ambulance" then
-- 		TriggerClientEvent("Pillbox:TreatPlayer", source)
-- 	else
-- 		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services")
-- 	end
-- end)

function GetNewId(curH)
	for k=1,#Config.Hospitals[curH]["beds"],1 do
		if not Patients[curH][k] then 
			return k
		end
	end
	return false
end

function GetPatientCount(curH)
	local count, hasCapacity = 0, true
	for k,v in pairs(Patients[curH]) do
		if v then count = count + 1; end
	end
	if count >= #Config.Hospitals[curH]["beds"] then hasCapacity = false; end
	return hasCapacity
end

function GetEMSCount()
	while true do
	local count = 0
	local players = BJCore.Functions.GetPlayers()
	for k,v in pairs(players) do
		local pData = BJCore.Functions.GetPlayer(v)
		while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(v); end
		local job = pData.PlayerData.job.name
		if job == "ambulance" then
			count = count + 1
		end
	end
	EMSCount = count
	Wait(30 * 1000)
	end
end

function NotifyEMS()
	local players = BJCore.Functions.GetPlayers()
	for k,v in pairs(players) do
		local pData = BJCore.Functions.GetPlayer(v)
		while not pData do Citizen.Wait(0); pData = BJCore.Functions.GetPlayer(v); end
		local job = pData.PlayerData.job.name
		if job == "ambulance" then
			TriggerClientEvent('Pillbox:DoNotify', v)
		end
	end
end

RegisterServerEvent('Pillbox:pay')
AddEventHandler('Pillbox:pay', function()
	local _source = source
	local pData = BJCore.Functions.GetPlayer(source)
	local billing = math.random(250,450)

	local societyAccount = nil
	--   TriggerEvent('tac_addonaccount:getSharedAccount', 'society_ambulance', function(account)
	--     societyAccount = account
	--   end)

	--pData.Functions.RemoveMoney("bank",billing,"Hospital bill")
	--societyAccount.addMoney(billing)
	--TriggerClientEvent('tac:showNotification', _source, 'You have been billed £~g~'..billing ..'~w~ for using these services')
	--TriggerClientEvent('mythic_notify:client:SendAlert', pData.PlayerData.source, { type = 'inform', text = 'You have been billed '..BJCore.Config.Currency.Symbol..billing ..' for using these services', length = 3000 })

end)

BJCore.Functions.RegisterServerCallback('ems:server:CanPayHidden', function(source, cb, cost)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player and Player.PlayerData and Player.PlayerData.money and Player.PlayerData.money["crypto"] and Player.PlayerData.money["crypto"] >= cost then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('ems:server:HiddenRevive')
AddEventHandler('ems:server:HiddenRevive', function(target, cost)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local TPlayer = BJCore.Functions.GetPlayer(target)
    if Player.Functions.RemoveMoney('crypto', cost, 'Payment illegal hospital') then
    	TriggerClientEvent('BJCore:Notify', src, "Patient is being treated", "primary")
    	TriggerClientEvent('ems:server:HiddenTreatment', target)
    	TriggerEvent("bj-log:server:CreateLog", "ems", "Crim Revive", "green", "**"..Player.PlayerData.name .. "** has paid "..cost.." IMP(s) to revive "..TPlayer.PlayerData.name..".")
    end
end)

RegisterNetEvent('Pillbox:CheckIn')
RegisterNetEvent('Pillbox:CheckOut')
RegisterNetEvent('Pillbox:NotifyEMS')
RegisterNetEvent('Pillbox:TreatPlayer')
AddEventHandler('Pillbox:CheckIn', function(id,curH) Patients[curH][id] = source; end)
AddEventHandler('Pillbox:CheckOut', function(id,curH) Patients[curH][id] = false; end)
AddEventHandler('Pillbox:NotifyEMS', function(...) NotifyEMS(...); end)
AddEventHandler('Pillbox:TreatPlayer', function(id) TriggerClientEvent('Pillbox:GetTreated', id); end)
BJCore.Functions.RegisterServerCallback('Pillbox:GetCapacity', function(source,cb, curH) cb(GetPatientCount(curH),GetNewId(curH)) end)
BJCore.Functions.RegisterServerCallback('Pillbox:GetOnlineEMS', function(source,cb) cb(EMSCount) end)

Citizen.CreateThread(function(...) while not BJCore do Citizen.Wait(0); end GetEMSCount(...); end)
BJCore = nil
isLoggedIn = false
local requiredItemsShowed = false

Citizen.CreateThread(function()
	while BJCore == nil do
		TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler("crypto:client:AttemptDecrypt", function()
	if not Crypto.Exchange.RebootInfo.state then
		BJCore.Functions.TriggerServerCallback('crypto:server:HasSticky', function(HasItem)
			if HasItem then
				TriggerEvent("mhacking:show")
				TriggerEvent("mhacking:start", math.random(4, 6), 45, HackingSuccess)
			else
				BJCore.Functions.Notify('You dont have a Cryptostick', 'error')
			end
		end)
	else
		BJCore.Functions.Notify('System is rebooting - '..Crypto.Exchange.RebootInfo.percentage..'%')
	end	
end)

function ExchangeSuccess()
	TriggerServerEvent('crypto:server:ExchangeSuccess', math.random(1, 10))
end

function ExchangeFail()
	local Odd = 5
	local RemoveChance = math.random(1, Odd)
	local LosingNumber = math.random(1, Odd)

	if RemoveChance == LosingNumber then
		TriggerServerEvent('crypto:server:ExchangeFail')
		TriggerServerEvent('crypto:server:SyncReboot')
		-- Crypto.Exchange.RebootInfo.state = true
		-- SystemCrashCooldown()
	end
end

RegisterNetEvent('crypto:client:SyncReboot')
AddEventHandler('crypto:client:SyncReboot', function()
	Crypto.Exchange.RebootInfo.state = true
	SystemCrashCooldown()
end)

function SystemCrashCooldown()
	Citizen.CreateThread(function()
		while Crypto.Exchange.RebootInfo.state do

			if (Crypto.Exchange.RebootInfo.percentage + 1) <= 100 then
				Crypto.Exchange.RebootInfo.percentage = Crypto.Exchange.RebootInfo.percentage + 1
				TriggerServerEvent('crypto:server:Rebooting', true, Crypto.Exchange.RebootInfo.percentage)
			else
				Crypto.Exchange.RebootInfo.percentage = 0
				Crypto.Exchange.RebootInfo.state = false
				TriggerServerEvent('crypto:server:Rebooting', false, 0)
			end

			Citizen.Wait(1200)
		end
	end)
end

function HackingSuccess(success, timeremaining)
    if success then
        TriggerEvent('mhacking:hide')
        ExchangeSuccess()
    else
		TriggerEvent('mhacking:hide')
		ExchangeFail()
	end
	TriggerEvent("crim:client:InteractionComplete")
end

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	TriggerServerEvent('crypto:server:FetchWorth')
	TriggerServerEvent('crypto:server:GetRebootState')
end)

RegisterNetEvent('crypto:client:UpdateCryptoWorth')
AddEventHandler('crypto:client:UpdateCryptoWorth', function(crypto, amount, history)
	Crypto.Worth[crypto] = amount
	if history ~= nil then
		Crypto.History[crypto] = history
	end
end)

RegisterNetEvent('crypto:client:GetRebootState')
AddEventHandler('crypto:client:GetRebootState', function(RebootInfo)
	if RebootInfo.state then
		Crypto.Exchange.RebootInfo.state = RebootInfo.state
		Crypto.Exchange.RebootInfo.percentage = RebootInfo.percentage
		SystemCrashCooldown()
	end
end)

Citizen.CreateThread(function()
	isLoggedIn = true
	TriggerServerEvent('crypto:server:FetchWorth')
	TriggerServerEvent('crypto:server:GetRebootState')
end)
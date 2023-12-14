mooseUI = {
	VoiceType = 2 -- 0 esx_voice, 1 tokovoip, 2 mumble
}

local MUI = mooseUI

MUI.Version = '1.0.00'

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
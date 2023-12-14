thermite = {}

cfg = {
	debug = true,
	useItem = true,
	itemName = "thermite",
	takeItemOnFail = true,
	takeOnFailCount = 1,
	takeItemOnSuccess = true,
	takeOnSuccessCount = 1,

	fireOnFail = true,
	fireChance = 70,
}

messages = {
	notEnoughItem = "You don't have enough "..cfg.itemName,
	failMsg       = "You failed to correctly rig up the thermite",
	successMsg    = "You successfully set off the thermite",
}

uiCfg = {
	difficulty        = 0.5,
	keepgoing         = false,
	speedScale        = 1.5,
	scoreInc          = 0.5,

	onStart           = "http://thermite/onStart",
	onStop            = "http://thermite/onStop",
	onStartCountdown  = "http://thermite/onStartCountdown",
	onCount           = "http://thermite/onCount",
	onHit             = "http://thermite/onHit",
	onMiss            = "http://thermite/onMiss",
	onFail            = "http://thermite/onFail",
	onSucces          = "http://thermite/onSuccess",
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
Config = {}

Config.AllTattooList = json.decode(LoadResourceFile(GetCurrentResourceName(), 'tattoos.json'))
Config.TattooCats = {
	{"ZONE_HEAD", "Head", {vector3(0.0, 0.7, 0.7), vector3(0.7, 0.0, 0.7), vector3(0.0, -0.7, 0.7), vector3(-0.7, 0.0, 0.7)}, vector3(0.0, 0.0, 0.5)},
	{"ZONE_LEFT_LEG", "Left Leg", {vector3(-0.2, 0.7, -0.7), vector3(-0.7, 0.0, -0.7), vector3(-0.2, -0.7, -0.7)}, vector3(-0.2, 0.0, -0.6)},
	{"ZONE_LEFT_ARM", "Left Arm", {vector3(-0.4, 0.5, 0.2), vector3(-0.7, 0.0, 0.2), vector3(-0.4, -0.5, 0.2)}, vector3(-0.2, 0.0, 0.2)},
	{"ZONE_RIGHT_LEG", "Right Leg", {vector3(0.2, 0.7, -0.7), vector3(0.7, 0.0, -0.7), vector3(0.2, -0.7, -0.7)}, vector3(0.2, 0.0, -0.6)},
	{"ZONE_TORSO", "Torso", {vector3(0.0, 0.7, 0.2), vector3(0.0, -0.7, 0.2)}, vector3(0.0, 0.0, 0.2)},
	{"ZONE_RIGHT_ARM", "Right Arm", {vector3(0.4, 0.5, 0.2), vector3(0.7, 0.0, 0.2), vector3(0.4, -0.5, 0.2)}, vector3(0.2, 0.0, 0.2)},
}

Config.Shops = {
	vector3(1322.6, -1651.9, 51.2),
	vector3(-1153.6, -1425.6, 4.9),
	vector3(322.1, 180.4, 103.5),
	vector3(-3170.0, 1075.0, 20.8),
	vector3(1864.6, 3747.7, 33.0),
	vector3(-293.7, 6200.0, 31.4)
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
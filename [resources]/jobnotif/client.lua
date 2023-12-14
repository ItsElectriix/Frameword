local TSE = TriggerServerEvent
local CT = Citizen.CreateThread
local Hidden = false

function Awake(...)
  while not BJCore do Citizen.Wait(1000); end
  while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
  PlayerData = BJCore.Functions.GetPlayerData()
  --Start()
end

function Start()
  Update()
end

UiOpen = false

RegisterKeyMapping('-jobnotif', 'Job Notifications~', 'keyboard', 'Y')
RegisterCommand('-jobnotif', function()
  if Config.RestrictedUsage then
    if PlayerData.job and Config.Jobs[PlayerData.job.name] then
      if IsControlJustPressed(0, Keys["Y"]) then
        UiOpen = not UiOpen
        SendNUIMessage({ type = 'toggleDisplay'})
        Update()
      end
    end
  end
end, false)

function Update(...)
  Citizen.CreateThread(function()
    local lastKeyTimer = GetGameTimer()
    TriggerEvent('police:client:pauseKeybind', true)
    while UiOpen do
      Citizen.Wait(0)
      DisableControlAction(0, Keys["RIGHT"], true)
      DisableControlAction(0, Keys["LEFT"], true)
      DisableControlAction(0, Keys["G"], true)
      DisableControlAction(0, Keys["H"], true)
      DisableControlAction(0, Keys["M"], true)

      if IsDisabledControlJustPressed(0, Keys["RIGHT"]) then
        SendNUIMessage({ type = 'changeSelection', data = {
          ['direction'] = 'up',
        }})
      elseif IsDisabledControlJustPressed(0, Keys["LEFT"]) then
        SendNUIMessage({ type = 'changeSelection', data = {
          ['direction'] = 'down',
        }})
      end
      if IsControlPressed(0, Keys["LEFTSHIFT"]) and IsDisabledControlJustPressed(0, Keys["H"]) then
        SendNUIMessage({ type = 'clearNotifications' })
      elseif IsDisabledControlJustPressed(0, Keys["H"]) and (GetGameTimer() - lastKeyTimer) > 150 then
        SendNUIMessage({ type = 'deleteNotification', data = {
          ['id'] = 'cur',
        }})
        lastKeyTimer = GetGameTimer()
      end

      if IsDisabledControlJustPressed(0, Keys["G"])  then
        SendNUIMessage({ type = 'setGps' })
      end
    end
    TriggerEvent('police:client:pauseKeybind', false)
  end)
end

function SetJob(source,job)
  PlayerData.job = job
end

local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" };

local notifTypes = {
  ["firearm"] = {["type"] = 1, ["title"] = "10-32", ["icon"] = "fas fa-headset"},
  ["shotsfired"] = {["type"] = 2, ["title"] = "10-32", ["icon"] = "fas fa-headset"},
  ["carjack"] = {["type"] = 0, ["title"] = "10-31", ["icon"] = "fas fa-headset"},
  ["streetdrugs"] = {["type"] = 1, ["title"] = "10-31", ["icon"] = "fas fa-headset"},
  ["deliverdrugs"] = {["type"] = 2, ["title"] = "10-31", ["icon"] = "fas fa-headset"},
  ["fight"] = {["type"] = 0, ["title"] = "10-10", ["icon"] = "fas fa-headset"},
  ["polpanic"] = {["type"] = 3, ["title"] = "10-33", ["icon"] = "fas fa-exclamation-circle"},
  ["emspanic"] = {["type"] = 2, ["title"] = "10-33", ["icon"] = "fas fa-exclamation-circle"},
  ["poldown"] = {["type"] = 2, ["title"] = "10-33", ["icon"] = "fas fa-exclamation-circle"},
  ["emsdown"] = {["type"] = 2, ["title"] = "10-33", ["icon"] = "fas fa-exclamation-circle"},
  ["bank"] = {["type"] = 2, ["title"] = "10-90", ["icon"] = "fas fa-headset"},
  ["atm"] = {["type"] = 1, ["title"] = "10-90", ["icon"] = "fas fa-headset"},
  ["bande"] = {["type"] = 2, ["title"] = "10-31", ["icon"] = "fas fa-headset"},
  ["civreport"] = {["type"] = 1, ["title"] = "10-31", ["icon"] = "fas fa-headset"},
  ["hospital"] = {["type"] = 1, ["title"] = "10-47", ["icon"] = "fas fa-headset"},
  ["assistance"] = {["type"] = 3, ["title"] = "10-13", ["icon"] = "fas fa-headset"},
}

function AddMessage(source,msg,pos,job,type)
  if not source then return; end
  if not PlayerData.job.onduty then return; end
  if notifTypes[type] == nil then return; end
  if not job then job = pos; pos = msg; msg = source; end
  if not PlayerData then return; end
  if not PlayerData.job or PlayerData.job.name ~= job then return; end

  zoneName = zones[GetNameOfZone(pos.x, pos.y, pos.z)]
  streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
  local streetDesc = zoneName or ''
  if streetName then
  	streetDesc = streetName
  	if zoneName then
  		streetDesc = streetDesc..', '..zoneName
  	end
  end

  SendNUIMessage({ type = 'addNotification', data = {
    ['job'] = job,
    ['iconCss'] = notifTypes[type]["icon"],
    ['title'] = notifTypes[type]["title"],
    ['body'] = msg,
    ['street'] = streetDesc,
    ['coords'] = VectorToString(pos),
    ['category'] = notifTypes[type]["type"],
    ['hidden'] = Hidden,
  }})
  -- SendNUIMessage({action = 'display', style = job, info = {
  -- 	["code"] = "Test",
  -- 	["name"] = (msg or ''):gsub("~[a-zA-Z0-9]~", ""),
  -- 	["loc"] = streetDesc
  -- }})
end

RegisterNUICallback('SetGps', function(data)
  SetNewWaypoint(StringToVector(data.coords))
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		local isInCar = false
		if vehicle ~= 0 then
			isInCar = true
		end
    --print(tostring(isEls))
		--SendNUIMessage({action = 'vehicleInfo', inVehicle = (vehicle ~= 0), isElsVehicle = isEls })
    SendNUIMessage({type = 'setInCar', data = { isInCar = isInCar }})
	end
end)

function VectorToString(vec)
	return vec.x..', '..vec.y..', '..vec.z
end

function StringToVector(str)
  local coord = {};
  for num in string.gmatch(str, "[-%d%.]+") do
    table.insert(coord, tonumber(num));
  end
  return vector3(table.unpack(coord))
end

NewEvent(true,AddMessage,'MF_Trackables:DoNotify')
NewEvent(true,Responding,'MF_Trackables:Responding')

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
  PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
  PlayerData.job = JobInfo
end)

RegisterCommand('opennotif', function(...) UiOpen = not UiOpen; end)

CT(function(...) Awake(...); end)
AddEventHandler("hud:toggle", function(b) Hidden = not b end)
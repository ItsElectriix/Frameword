local debugEnabled = false
local comboZone = nil
local insideZone = false
local createdZones = {}

local function addToComboZone(zone)
	if comboZone ~= nil then
		comboZone:AddZone(zone)
	else
		comboZone = ComboZone:Create({ zone }, { name = "polyzone" })
		comboZone:onPlayerInOutExhaustive(function(isPointInside, point, insideZones, enteredZones, leftZones)
			if leftZones ~= nil then
				for i = 1, #leftZones, 1 do
					TriggerEvent("polyzone:exit", leftZones[i].name, leftZones[i].data)
				end
			end
			if enteredZones ~= nil then
				for i = 1, #enteredZones, 1 do
					TriggerEvent("polyzone:entered", enteredZones[i].name, enteredZones[i].data, enteredZones[i].center)
				end
			end
		end, 500)
	end
end

local function doCreateZone(options)
	if options.data and options.data.id then
		local key = options.name.."_"..tostring(options.data.id)
		if not createdZones[key] then
			createdZones[key] = true
			return true
		else
			print('duplicate polyzone: '..key)
			return false
		end
	end
	return true
end

local function addZoneEvent(eventName, zoneName)
	if comboZone.events and comboZone.events[eventName] ~= nil then return; end
	comboZone:addEvent(eventName, zoneName)
end

local function addZoneEvents(zone, zoneEvents)
	if zoneEvents == nil then return; end
	for _, v in ipairs(zoneEvents) do
		addZoneEvent(v, zone.name)
	end
end

exports("AddBoxZone", function(name, vectors, length, width, options)
	if not options then options = {}; end
	options.name = name
	if not doCreateZone(options) then return; end
	local boxCenter = type(vectors) ~= 'vector3' and vector3(vectors.x, vectors.y, vectors.z) or vectors
	local zone = BoxZone:Create(boxCenter, length, width, options)
	addToComboZone(zone)
	addZoneEvents(zone, options.zoneEvents)
end)

exports("AddCircleZone", function(name, center, radius, options)
	if not options then options = {}; end
	options.name = name
	if not doCreateZone(options) then return; end
	local circleCenter = type(center) ~= 'vector3' and vector3(center.x, center.y, center.z) or center
	local zone = CircleZone:Create(circleCenter, radius, options)
	addToComboZone(zone)
	addZoneEvents(zone, options.zoneEvents)
end)

exports("AddPolyZone", function(name, vectors, options)
	if not options then options = {}; end
	options.name = name
	if not doCreateZone(options) then return; end
	local zone = PolyZone:Create(vectors, options)
	addToComboZone(zone)
	addZoneEvents(zone, options.zoneEvents)
end)

exports("AddZoneEvent", function(eventName, zoneName)
	addZoneEvent(eventName, zoneName)
end)

local function toggleDebug(state)
	if state == debugEnabled then return; end
	debugEnabled = state
	if debugEnabled then
		while debugEnabled do
			comboZone:draw()
			Citizen.Wait(0)
		end
	end
end

AddEventHandler("polyzone:toggledebug", function()
	toggleDebug(not debugEnabled)
end)
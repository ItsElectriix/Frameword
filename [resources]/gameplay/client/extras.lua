Extras = {}
local AvailableExtras = {['VehicleExtras'] = {}, ['TrailerExtras'] = {}}
local Items = {['Vehicle'] = {}, ['Trailer'] = {}}
local Menupool = MenuPool.New()
local MainMenu = UIMenu.New('Vehicle Extras', '~b~Enable/Disable vehicle extras', 1320)
MainMenu:DisEnableControls(true)
local TrailerMenu, MenuExists, Vehicle, TrailerHandle, GotTrailer, DeletingMenu
Menupool:Add(MainMenu)
Menupool:MouseEdgeEnabled(false)
Menupool:MouseControlsEnabled(false)
Menupool:ControlDisablingEnabled(false)

local start = false
local opened = false

RegisterNetEvent('vehextras:menu')
AddEventHandler('vehextras:menu', function()
    start = true
    runningTick()
end)

function runningTick()
    Citizen.CreateThread(function() --Controls
        while start do
            Citizen.Wait(0)
    
            if not DeletingMenu then
                Menupool:ProcessMenus()
            end
            
            local IsInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)

            local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local Got, Handle = GetVehicleTrailerVehicle(CurrentVehicle)
    
            if not MenuExists and IsInVehicle then
                Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                Extras.CreateMenu(Got, Handle)
            elseif MenuExists and (not IsInVehicle or (TrailerMenu and not Got) or Handle ~= TrailerHandle or Vehicle ~= CurrentVehicle) then
                Extras.DeleteMenu()
                Citizen.Wait(500)
            end
			if MenuExists and not opened then
				opened = true
				MainMenu:Visible(not MainMenu:Visible())
			end
			if not MainMenu:Visible() then opened = false start = false; end
        end
    end)
end

-- ] Actual Menu

-- Functions [

function Extras.CreateMenu(Got, Handle)
	GotVehicleExtras = false
	GotTrailerExtras = false
	GotTrailer = Got
	TrailerHandle = Handle

	for ExtraID = 0, 20 do
		if DoesExtraExist(Vehicle, ExtraID) then
			AvailableExtras.VehicleExtras[ExtraID] = (IsVehicleExtraTurnedOn(Vehicle, ExtraID) == 1)
			GotVehicleExtras = true
		end
		
		if GotTrailer and DoesExtraExist(TrailerHandle, ExtraID) then
			if not TrailerMenu then
				TrailerMenu = Menupool:AddSubMenu(MainMenu, 'Trailer Extras', '~b~Enable/Disable trailer extras')
			end
			
			AvailableExtras.TrailerExtras[ExtraID] = (IsVehicleExtraTurnedOn(TrailerHandle, ExtraID) == 1)
			GotTrailerExtras = true
		end
	end

	-- Vehicle Extras
			if GotVehicleExtras then
				SetVehicleAutoRepairDisabled(Vehicle, true)
				
				for Key, Value in pairs(AvailableExtras.VehicleExtras) do
					local ExtraItem = UIMenuCheckboxItem.New('Extra ' .. Key, AvailableExtras.VehicleExtras[Key])
					MainMenu:AddItem(ExtraItem)
					Items.Vehicle[Key] = ExtraItem
				end

				MainMenu.OnCheckboxChange = function(Sender, Item, Checked)
					for Key, Value in pairs(Items.Vehicle) do
						if Item == Value then
							AvailableExtras.VehicleExtras[Key] = Checked
							if AvailableExtras.VehicleExtras[Key] then
								print("toggle")
								print("disable")
								print("vehicle: "..Vehicle.."| Key: "..Key)
								SetVehicleExtra(Vehicle, Key, 0)
								SetVehiclePetrolTankHealth(Vehicle,4000.0)
							else
								print("vehicle: "..Vehicle.."| Key: "..Key)
								print("enable")
								print("toggle")
								SetVehicleExtra(Vehicle, Key, 1)
								SetVehiclePetrolTankHealth(Vehicle,4000.0)
							end
						end
					end
				end
			end

	-- Trailer Extras
			if GotTrailerExtras then
				SetVehicleAutoRepairDisabled(TrailerHandle, true)
				
				for Key, Value in pairs(AvailableExtras.TrailerExtras) do
					local ExtraItem = UIMenuCheckboxItem.New('Extra ' .. Key, AvailableExtras.TrailerExtras[Key])
					TrailerMenu:AddItem(ExtraItem)
					Items.Trailer[Key] = ExtraItem
				end

				TrailerMenu.OnCheckboxChange = function(Sender, Item, Checked)
					for Key, Value in pairs(Items.Trailer) do
						if Item == Value then
							AvailableExtras.TrailerExtras[Key] = Checked
							local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(Vehicle)
							if AvailableExtras.TrailerExtras[Key] then
								SetVehicleExtra(TrailerHandle, Key, 0)
							else
								SetVehicleExtra(TrailerHandle, Key, 1)
							end
						end
					end
				end
			end

	if GotVehicleExtras or GotTrailerExtras then
		Menupool:RefreshIndex()
		MenuExists = true
	end
end

function Extras.DeleteMenu()
	DeletingMenu = true
	Vehicle = nil
	AvailableExtras = {['VehicleExtras'] = {}, ['TrailerExtras'] = {}}
	Items = {['Vehicle'] = {}, ['Trailer'] = {}}

	Menupool = MenuPool.New()
	MainMenu = UIMenu.New('Vehicle Extras', '~b~Enable/Disable vehicle extras', 1320)
	Menupool:Add(MainMenu)
	Menupool:MouseEdgeEnabled(false)
	Menupool:MouseControlsEnabled(false)
	Menupool:ControlDisablingEnabled(false)
	MenuExists = false
	DeletingMenu = false
end

function GetIsControlJustPressed(Control)
	if IsControlJustPressed(1, Control) or IsDisabledControlJustPressed(1, Control) then
		return true
	end
	return false
end


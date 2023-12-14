local areControlsDisabled = false

local resourceName = GetCurrentResourceName()

local _SetNuiFocus = SetNuiFocus
SetNuiFocus = function(input, mouse)
	--print('Triggered Custom SetNuiFocus')
	if input or mouse then
		areControlsDisabled = true
		--SetNuiFocusKeepInput(true)
		-- TriggerEvent('core:NuiFocus', resourceName) -- Potential future thing to reset based on a callback?
		_SetNuiFocus(input, mouse)
		--DisableControlThread()
	else
		--print('Disable NUI focus called at: '..GetGameTimer())
		areControlsDisabled = false
		--SetNuiFocusKeepInput(false)
		_SetNuiFocus(input, mouse)
	end
end

local _NuiCloseCallback = function() end

SetNuiCloseCallback = function(cb)
	if cb then
		_NuiCloseCallback = cb
	end
end

AddEventHandler('core:NuiFocus', function(resName)
	if resName ~= resourceName and areControlsDisabled then
		areControlsDisabled = false
		-- _SetNuiFocus(false, false)

		_NuiCloseCallback()
	end
end)

--function DoDisableControls()
--	DisableAllControlActions(0)
--	DisableAllControlActions(1)
--	DisableAllControlActions(2)
--	DisableControlAction(0, 24, true)
--	EnableControlAction(1, 249, true)
--end
--
--function DoEnableControls()
--	EnableAllControlActions(0)
--	EnableAllControlActions(1)
--	EnableAllControlActions(2)
--	EnableControlAction(1, 249, true)
--end
--
--function DisableControlThread()
--	Citizen.CreateThread(function()
--		local player = PlayerId()
--		while areControlsDisabled do
--			DoDisableControls()
--			Wait(1)
--		end
--		DoEnableControls()
--		print('Input handed back at: '..GetGameTimer())
--	end)
--end
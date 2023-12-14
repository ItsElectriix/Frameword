Config = {}
Config.JobLocked = '[E] ~r~Locked'
Config.Locked = '~r~Locked'
Config.JobUnlocked = '[E] ~g~Unlocked'
Config.Unlocked = '~g~Unlocked'
Config.LockingDoor = 'Locking...'
Config.UnlockingDoor = 'Unlocking...'
Config.LockpickText = 'Disabling...'
Config.LockpickDistance = 2
Config.RemoteAnim = {
    dict = 'anim@heists@keycard@',
    name = 'exit',
    blendin = 5.0,
    blendout = 1.0,
    duration = -1,
    flag = 48,
    pbr = 0
}
Config.LockPickingAnim = {
    dict = 'veh@break_in@0h@p_m_one@',
    name = 'low_force_entry_ds',
    blendin = 3.0,
    blendout = 1.0,
    duration = 1200,
    flag = 11,
    pbr = 0
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
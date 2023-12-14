Config = {}

Config.UsingSaltyChat = false
Config.MaxFrequency = 500

Config.SecondaryRadioChannel = 'LS Emergency Radio'

Config.SecondaryAllowedJobs = {
    ['police'] = true,
    ['ambulance'] = true
}

Config.messages = {
  ['not_on_radio'] = 'You\'re not connected to a frequency',
  ['on_radio'] = 'You\'re already connected to this frequency: <b>',
  ['joined_to_radio'] = 'You\'re connected to: <b>',
  ['restricted_channel_error'] = 'You can\'t connect to this frequency!',
  ['you_on_radio'] = 'You\'re already connected to this frequency: <b>',
  ['you_leave'] = 'You left the frequency'
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
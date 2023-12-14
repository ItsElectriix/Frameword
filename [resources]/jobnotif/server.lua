local TCE = TriggerClientEvent
local CT = Citizen.CreateThread
local inIPL = false
local iplName = nil
power = true

powerOn = function()
  power = true
end

powerOff = function()
  power = false
end

AddEventHandler('powerplant:powerOn', powerOn)
AddEventHandler('powerplant:powerOff', powerOff)

function Awake(...)
  while not BJCore do Citizen.Wait(0); end
  Update()
end

function Update(...)
  while true do
    Citizen.Wait(0)
  end
end

function Notify(source,msg,pos,job,type)
  if job == "police" and not power then return; end
  TCE('MF_Trackables:DoNotify',-1,msg,pos,job,type)
end

function Respond(source,text)
  if job == "police" and not power then return; end
  TCE('MF_Trackables:Responding',-1,text)
end

NewEvent(true,Notify,'MF_Trackables:Notify')
NewEvent(true,Respond,'MF_Trackables:Respond')

CT(function(...) Awake(...); end)

RegisterServerEvent('thiefInProgressPos')
AddEventHandler('thiefInProgressPos', function(tx, ty, tz)
    TriggerClientEvent('thiefPlace', -1, tx, ty, tz)
end)

RegisterServerEvent('gunshotInProgressPos')
AddEventHandler('gunshotInProgressPos', function(gx, gy, gz)
    TriggerClientEvent('gunshotPlace', -1, gx, gy, gz)
end)

RegisterServerEvent('meleeInProgressPos')
AddEventHandler('meleeInProgressPos', function(mx, my, mz)
    TriggerClientEvent('meleePlace', -1, mx, my, mz)
end)

RegisterServerEvent('firearmInProgressPos')
AddEventHandler('firearmInProgressPos', function(fx, fy, fz)
    TriggerClientEvent('firearmPlace', -1, fx, fy, fz)
end)

RegisterServerEvent('explosionInProgressPos')
AddEventHandler('explosionInProgressPos', function(pos)
    TriggerClientEvent('explosionPlace', -1, pos)
end)

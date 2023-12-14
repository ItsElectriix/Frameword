local isDrilling = false
local soundPlaying = false
local drillObj = false

function LoadScaleform(name)
  local scaleform = RequestScaleformMovie(name)
  while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0); end
  return scaleform
end

function SetScaleformFloat(scaleform,method,val)
  BeginScaleformMovieMethod(scaleform, method)
  PushScaleformMovieMethodParameterFloat(val)
  EndScaleformMovieMethod()
end

function SpawnDrill()
  if drillObj then return; end
  local hash = GetHashKey("hei_prop_heist_drill")  
  while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end

  local plyPed = PlayerPedId()
  local plyPos = GetEntityCoords(plyPed)

  drillObj = CreateObject(hash, plyPos, false, false)
  SetEntityAsMissionEntity(drillObj, true, true)

  local boneIndex = GetPedBoneIndex(plyPed, 57005)
  AttachEntityToEntity(drillObj, plyPed, boneIndex, 0.125, 0.0, -0.05, 100.0, 300.0, 135.0, true, true, false, true, 1, true)
  SetModelAsNoLongerNeeded(hash)
end

function DeleteDrill()
  if not drillObj then return; end
  SetEntityAsMissionEntity(drillObj, true, true)  
  NetworkRequestControlOfEntity(drillObj)
  local count = 0
  while not NetworkHasControlOfEntity(drillObj) and count < 10 do
    count = count + 1
    Wait(100)
  end
  DeleteEntity(drillObj)
  drillObj = false
end

function PlayAnimation()
  local plyPed = PlayerPedId()
  FreezeEntityPosition(plyPed,true) 
  while not HasAnimDictLoaded("anim@heists@fleeca_bank@drilling") do RequestAnimDict("anim@heists@fleeca_bank@drilling"); Citizen.Wait(0); end
  TaskPlayAnim(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 8.0, 8.0, -1, 2, 1.0, false,false,false) 
end

function StartDrilling(...)
  if isDrilling then return; end
  isDrilling = true

  Citizen.CreateThread(function(...)
    local crackedLock = false
    local curSpeed    = 0.00
    local curPos      = 0.00
    local curDepth    = 0.10
    local curTemp     = 0.00

    local lastSpeed,lastPos,lastDepth,lastTemp
    local scaleform = LoadScaleform("DRILLING")
    SetScaleformFloat(scaleform,"SET_HOLE_DEPTH",0.0)

    SpawnDrill()
    --PlayAnimation()
    local plyPed = PlayerPedId()
    FreezeEntityPosition(plyPed,true) 
    while not HasAnimDictLoaded("anim@heists@fleeca_bank@drilling") do RequestAnimDict("anim@heists@fleeca_bank@drilling"); Citizen.Wait(0); end
    TaskPlayAnim(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 8.0, 8.0, -1, 2, 1.0, false,false,false) 
    StartSound()

    while isDrilling do
      DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
      DisableControlAction(0,30,true)
      DisableControlAction(0,31,true)
      DisableControlAction(0,32,true)
      DisableControlAction(0,34,true)

      if IsControlPressed(0, Config.Controls.Accelerate) then curSpeed = math.min(1.0, curSpeed + Config.DrillAccel); end
      if IsControlPressed(0, Config.Controls.Decelerate) then curSpeed = math.max(0.0, curSpeed - Config.DrillDecel); end

      local grinding = false
      if IsControlPressed(0, Config.Controls.Forward) then 
        if curSpeed > 0.2 or curPos < curDepth then
          if curSpeed > 0.8 and curPos >= curDepth then
            curTemp = curTemp + (Config.TempAccel)
            grinding = true
          else
            curPos = math.min(1.0, curPos + Config.MoveAccel) 
          end
        else
          if curSpeed > 0.0 and curSpeed < 0.2 and curPos >= curDepth then
            curTemp = curTemp + Config.TempAccel
          end
        end
      elseif IsControlPressed(0, Config.Controls.Back) then 
        curPos = math.max(0.0, curPos - Config.MoveDecel)
      end

      local doSound = true

      if not lastDepth then lastDepth = curDepth; end
      if curPos > curDepth then
        curTemp = math.min(1.0,curTemp + (Config.TempAccel * curSpeed))
        curDepth = curPos
      else
        if not grinding then 
          curTemp = math.max(0.0,curTemp - Config.TempDecel)
          doSound = false
        end
      end

      if curTemp >= 1.0 then
        crackedLock = false
        isDrilling = false
      end

      if curPos >= 1.0 then
        crackedLock = true
        isDrilling = false
      end

      if curSpeed > 0.0 and doSound then soundPlaying = curSpeed;
      else soundPlaying = false
      end

      if not lastSpeed  or curSpeed ~= lastSpeed  then lastSpeed = curSpeed; SetScaleformFloat(scaleform,"SET_SPEED",curSpeed);        end
      if not lastPos    or curPos   ~= lastPos    then lastPos   = curPos;   SetScaleformFloat(scaleform,"SET_DRILL_POSITION",curPos); end
      if not lastTemp   or curTemp  ~= lastTemp   then lastTemp  = curTemp;  SetScaleformFloat(scaleform,"SET_TEMPERATURE",curTemp);   end
      Citizen.Wait(0)
    end

    if crackedLock then
      BJCore.Functions.Notify('You cracked the lock', 'success')
      StopGameplayCamShaking(true)
    else
      BJCore.Functions.Notify('You failed to crack the lock','error')
      StopGameplayCamShaking(true)
    end

    local plyPed = PlayerPedId()
    FreezeEntityPosition(plyPed,false) 
    ClearPedTasksImmediately(plyPed)
    soundPlaying = false
    StopGameplayCamShaking(true)

    isDrilling = false
    DeleteDrill()
    RemoveScaleformScriptHudMovie(scaleform)

    TriggerEvent('Drilling:Finish',crackedLock,...) 
  end)
end

function StartSound()
  Citizen.CreateThread(function(...)
    while isDrilling do
      Citizen.Wait(100 / (soundPlaying or 1.0))  
      if soundPlaying then
        PlaySoundFrontend(-1, "Drill_Pin_Break", "DLC_HEIST_FLEECA_SOUNDSET", true)
        ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)
      else
        StopGameplayCamShaking(true)
      end
    end
  end)
end

RegisterNetEvent('Drilling:Start')
AddEventHandler('Drilling:Start', function(...) StartDrilling(...); end)

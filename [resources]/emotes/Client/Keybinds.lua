local emob1 = ""
local emob2 = ""
local emob3 = ""
local emob4 = ""
local emob5 = ""
local emob6 = ""
local keyb1 = "num4"
local keyb2 = "num5"
local keyb3 = "num6"
local keyb4 = "num7"
local keyb5 = "num8"
local keyb6 = "num9" 
CurrentWalk = ""
Initialized = false
kvpKey = nil
FavData = {}
PlayerData = false
cid = nil

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not BJCore do Citizen.Wait(1000); end
    while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end
    PlayerData = BJCore.Functions.GetPlayerData()
    kvpKey = "emotesFav_cid:"..tostring(PlayerData.citizenid)
    local temp_FavData = GetResourceKvpString(kvpKey)
    if temp_FavData == nil then
        createDefaultFavs()
    else
        FavData = json.decode(temp_FavData)                                          
    end
    setKeybinds()
end)

function createDefaultFavs()
    local data = { 
        keyb1="",
        keyb2="", 
        keyb3="", 
        keyb4="", 
        keyb5="", 
        keyb6="", 
        CurrentWalk=nil
    }
    --print("created data")
    SetResourceKvp(kvpKey, json.encode(data))
    local temp_FavData = GetResourceKvpString(kvpKey)
    if temp_FavData ~= nil then FavData = json.decode(temp_FavData); end
end

local function KeyBindUpdate()
    Citizen.CreateThread(function()
        while true do
			local sleep = 500
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
				sleep = 3
                for k, v in pairs(Config.KeybindKeys) do
                    if IsControlJustReleased(0, v) then
                        if k == keyb1 then if emob1 ~= "" then EmoteCommandStart(nil,{emob1, 0}) end end
                        if k == keyb2 then if emob2 ~= "" then EmoteCommandStart(nil,{emob2, 0}) end end
                        if k == keyb3 then if emob3 ~= "" then EmoteCommandStart(nil,{emob3, 0}) end end
                        if k == keyb4 then if emob4 ~= "" then EmoteCommandStart(nil,{emob4, 0}) end end
                        if k == keyb5 then if emob5 ~= "" then EmoteCommandStart(nil,{emob5, 0}) end end
                        if k == keyb6 then if emob6 ~= "" then EmoteCommandStart(nil,{emob6, 0}) end end
                        Wait(1000)
                    end
                end

                --if CurrentWalk ~= "" and not exports['tbh_customcommands']:IsMoveStateChanged() then
     
                if not crouched and CurrentWalk ~= nil and CurrentWalk ~= "" then
                    RequestWalking(CurrentWalk)
                    SetPedMovementClipset(PlayerPedId(), CurrentWalk, 0.2)
                end
                DisableControlAction(0, 36, true )
            end
            Citizen.Wait(sleep)
        end
    end)        
end

RegisterNetEvent('emotes:SetorResetWalk')
AddEventHandler('emotes:SetorResetWalk', function()
    if CurrentWalk ~= nil then
        RequestWalking(CurrentWalk)
        SetPedMovementClipset(PlayerPedId(), CurrentWalk, 0.2)
    else
        ResetPedMovementClipset(PlayerPedId(),0.0)
    end
end)

RegisterNetEvent('dp:ClientSetWalkStyle')
AddEventHandler('dp:ClientSetWalkStyle', function(walk)
	CurrentWalk = walk
end)

RegisterNetEvent("dp:ClientKeybindExist")
AddEventHandler("dp:ClientKeybindExist", function(does)
    if does then
    	TriggerServerEvent("dp:ServerKeybindGrab")
    else
    	TriggerServerEvent("dp:ServerKeybindCreate")
    end
end)

RegisterNetEvent("dp:ClientKeybindGet")
AddEventHandler("dp:ClientKeybindGet", function(k1, e1, k2, e2, k3, e3, k4, e4, k5, e5, k6, e6, walk)
    keyb1 = k1 emob1 = e1 keyb2 = k2 emob2 = e2 keyb3 = k3 emob3 = e3 keyb4 = k4 emob4 = e4 keyb5 = k5 emob5 = e5 keyb6 = k6 emob6 = e6
	CurrentWalk = walk
    Initialized = true  
end)

function setKeybinds()
    emob1 = FavData.keyb1 emob2 = FavData.keyb2 emob3 = FavData.keyb3 emob4 = FavData.keyb4 emob5 = FavData.keyb5 emob6 = FavData.keyb6
    CurrentWalk = FavData.CurrentWalk
    Initialized = true
    KeyBindUpdate()
end

RegisterNetEvent("dp:ClientKeybindGetOne")
AddEventHandler("dp:ClientKeybindGetOne", function(key, e)
    SimpleNotify(Config.Languages[lang]['bound']..""..e.." "..Config.Languages[lang]['to'].." "..firstToUpper(key).."")
	if key == "num4" then emob1 = e keyb1 = "num4" elseif key == "num5" then emob2 = e keyb2 = "num5" elseif key == "num6" then emob3 = e keyb3 = "num6" elseif key == "num7" then emob4 = e keyb4 = "num7" elseif key == "num8" then emob5 = e keyb5 = "num8" elseif key == "num9" then emob6 = e keyb6 = "num9" end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteBindsStart()
    TriggerEvent('chatMessage', "SYSTEM", "warning", Config.Languages[lang]['currentlyboundemotes'].."\n"
        ..firstToUpper(keyb1).." = '^2"..emob1.."^7'\n"
        ..firstToUpper(keyb2).." = '^2"..emob2.."^7'\n"
        ..firstToUpper(keyb3).." = '^2"..emob3.."^7'\n"
        ..firstToUpper(keyb4).." = '^2"..emob4.."^7'\n"
        ..firstToUpper(keyb5).." = '^2"..emob5.."^7'\n"
        ..firstToUpper(keyb6).." = '^2"..emob6.."^7'\n")
end

function EmoteBindStart(source, args, raw)
    if #args > 0 then
        local key = string.lower(args[1])
        print("arg key: "..key)
        local emote = string.lower(args[2])
        local chosenk = nil
        if key == "num4" then chosenk = keyb1 elseif key == "num5" then chosenk = emob2 elseif key == "num6" then chosenk = emob3 elseif key == "num7" then chosenk = emob4 elseif key == "num8" then chosenk = emob5 elseif key == "num9" then chosenk = emob6 end
        if (Config.KeybindKeys[key]) ~= nil then
        	if DP.Emotes[emote] ~= nil then
                --TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
                addToKeybind(key, emote)
			elseif DP.DogEmotes[emote] ~= nil then
                --TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
                addToKeybind(key, emote)
        	elseif DP.Dances[emote] ~= nil then
                --TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
                addToKeybind(key, emote)
        	elseif DP.PropEmotes[emote] ~= nil then
                --TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
                addToKeybind(key, emote)
            elseif emote == 'c' then
                addToKeybind(key, emote)
        	else
          		EmoteChatMessage("'"..emote.."' "..Config.Languages[lang]['notvalidemote'].."")
            end
        else
        	EmoteChatMessage("'"..key.."' "..Config.Languages[lang]['notvalidkey'])
        end
    else
        print("invalid")
    end
end

function addToKeybind(key, emote)
    if key == "num4" then
        print("do save num4")
        FavData.keyb1 = emote
    elseif key == "num5" then
        FavData.keyb2 = emote  
    elseif key == "num6" then
        FavData.keyb3 = emote 
    elseif key == "num7" then
        FavData.keyb4 = emote  
    elseif key == "num8" then
        FavData.keyb5 = emote
    elseif key == "num9" then
        FavData.keyb6 = emote
    end        
    print(tostring(FavData.keyb1))                      
    SetResourceKvp(kvpKey, json.encode(FavData))
    emob1 = FavData.keyb1 emob2 = FavData.keyb2 emob3 = FavData.keyb3 emob4 = FavData.keyb4 emob5 = FavData.keyb5 emob6 = FavData.keyb6
end
BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

local isDead = false
local isInstructorMode = false
local isNearSmelter = false
local isNearCarpenter = false
local isInLaundry = false
local isNearWeedDealer = false
local isNearMiner = false
local isNearFueler = false
local isNearLumber = false
local inApartment = false
local IsInVineyard = false
local IsInLumberYard = false
local isAtCooker = false

local insideOwnedHouse = false

local PlayerData = {}
Citizen.CreateThread(function() while BJCore == nil do Wait(1000); end while not BJCore.Functions.IsPlayerLoaded() do Citizen.Wait(1000); end PlayerData = BJCore.Functions.GetPlayerData() end)

WeedSeedsOptions = {
    [1] = "weedseeds:skunk",
    [2] = "weedseeds:purplehaze",
    [3] = "weedseeds:ogkush",
    [4] = "weedseeds:amnesia",
    [5] = "weedseeds:ak47",
    [6] = "weedseeds:whitewidow",
}

function getSeedItems()
    PlayerData = BJCore.Functions.GetPlayerData()
    local washrep = PlayerData.metadata["dealerrep"]
    local WeedSeedsItems = {}
    local max = 1
    if washrep >= 10 then
        max = 6
    elseif washrep >= 8 then
        max = 5
    elseif washrep >= 6 then
        max = 4
    elseif washrep >= 4 then
        max = 3
    elseif washrep >= 2 then
        max = 2
    end
    for i = 1, max, 1 do
        table.insert(WeedSeedsItems, WeedSeedsOptions[i])
    end
    return WeedSeedsItems
end
 
rootMenuConfig =  {
    {
        id = "general",
        displayName = "General",
        icon = "#globe-europe",
        enableMenu = function()
            return not isDead
        end,    
        subMenus = {"general:escort", "general:putinvehicle", "general:carry" ,"general:contactdetails", "general:keysgive", "general:robplayer", "general:hostage", "general:pickupsafe", "general:pickupcraft", "job:startfishing", "job:hotdog", "job:delivery", "job:mining"}
    },
    {
        id = "general-vehicle",
        displayName = "General Vehicle",
        icon = "#vehicle-options-vehicle",
        enableMenu = function()
            return not isDead and not IsPedInAnyVehicle(PlayerPedId(), false) and BJCore.Functions.VehicleInFront() ~= 0
        end,
        subMenus = {"general:flipvehicle", "general:putinvehicle", "general:getintrunk", "general:putintrunk", "general:dragouttrunk"}
    },    
    {
        id = "blip-manager",
        displayName = "Blip Manager",
        icon = "#general-blipmanager",
        enableMenu = function()
            return not isDead
        end,
        subMenus = {"blip:allOn", "blip:allOff", "blip:pd", "blip:hospital", "blip:publicjobs", "blip:shop", "blip:tool", "blip:bank", "blip:clothes", "blip:barbers", "blip:motel", "blip:garage", "blip:impound", "blip:paint", "blip:benny", "blip:carwash", "blip:pdm", "blip:craftsman","blip:vangelico", "blip:grovecustom", "blip:cityhall", "blip:drivingschool", "blip:casino", "blip:ammunation", "blip:airport"}
    },    
    {
        id = "mechanic-action",
        displayName = "Mechanic Actions",
        icon = "#mech-action",
        enableMenu = function()
            if PlayerData.job.name == "mechanic" and PlayerData.job.onduty and not isDead then
                return true
            end
        end,
        subMenus = {"mechanic:unlock", "mechanic:clean", "mechanic:impound", "mechanic:repair", "mechanic:flatbed", "mechanic:removeFakePlate"}
    },    
    {
        id = "police-action",
        displayName = "Police Actions",
        icon = "#police-action",
        enableMenu = function()
            if PlayerData.job.name == "police" and PlayerData.job.onduty and not isDead then
                return true
            end
        end,
        subMenus = {"police:frisk", "police:search", "police:gsr", "police:openmdt", "police:impound", "police:depot", "police:checkstatus", "medic:emergencybutton", "police:fineplayer", "medic:checkhealth", "police:seizeCash", "police:seizeDriverLicense", "police:seizeGunLicense"}
    },
    {
        id = "police-objects",
        displayName = "Police Objects",
        icon = "#police-object",
        enableMenu = function()
            if PlayerData.job.name == "police" and PlayerData.job.onduty and not isDead and not IsPedInAnyVehicle(PlayerPedId(), false) then
                return true
            end
        end,
        subMenus = {"police:pickup", "police:cone", "police:barrier", "police:tent", "police:light", "police:spikes"}
    },
    {
        id = "restricted-radios",
        displayName = "Radio Channels",
        icon = "#restricted-radios",
        enableMenu = function()
            if (PlayerData.job.name == "police" or PlayerData.job.name == "ambulance" or PlayerData.job.name == "doctor") and PlayerData.job.onduty and not isDead then
                return true
            end
        end,
        subMenus = {"radio:channel:1", "radio:channel:2", "radio:channel:3", "radio:channel:4", "radio:channel:5", "radio:channel:toggle"}
    },
    {
        id = "police-vehicle",
        displayName = "Police Radar",
        icon = "#police-vehicle",
        functionName = "wk:toggleRadar",
        enableMenu = function()
            if PlayerData.job.name == "police" and PlayerData.job.onduty and not isDead and IsPedInAnyVehicle(PlayerPedId(), false) then
                return true
            end
        end,
    },
    {
        id = "drivinginstructor",
        displayName = "Driving Instructor",
        icon = "#drivinginstructor",
        enableMenu = function()
            return (not isDead and isInstructorMode)
        end,
        subMenus = { "drivinginstructor:drivingtest", "drivinginstructor:submittest", }
    },    
    {
        id = "policeDead",
        displayName = "10-13",
        icon = "#police-dead",
        functionName = "police:client:SendPoliceEmergencyAlert",
        enableMenu = function()
            if PlayerData.job.name == "police" and isDead then
                return true
            end
        end,
    },
    {
        id = "emsDead",
        displayName = "10-14",
        icon = "#police-dead",
        functionName = "police:client:SendPoliceEmergencyAlert",
        enableMenu = function()
            if PlayerData.job.name == "ambulance" and isDead then
                return true
            end
        end,
    },
    {
        id = "animations",
        displayName = "Emotes",
        icon = "#general-emotes",
        functionName = "openEmoteMenu",
        enableMenu = function()
            if not isDead then
                return true
            end
        end,
    },
    {
        id = "expressions",
        displayName = "Expressions",
        icon = "#expressions",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "expressions:normal", "expressions:drunk", "expressions:angry", "expressions:dumb", "expressions:electrocuted", "expressions:grumpy", "expressions:happy", "expressions:injured", "expressions:joyful", "expressions:mouthbreather", "expressions:oneeye", "expressions:shocked", "expressions:sleeping", "expressions:smug", "expressions:speculative", "expressions:stressed", "expressions:sulking", "expressions:weird", "expressions:weird2"}
    },
    {
        id = "medic",
        displayName = "Medical",
        icon = "#medic",
        enableMenu = function()
            if PlayerData.job.name == "ambulance" and PlayerData.job.onduty and not isDead then
                return true
            end
        end,
        subMenus = {"police:checkstatus",  "medic:checkhealth", "medic:treatwounds", "medic:revive", "general:escort", "general:putinvehicle", "medic:treatbed", "medic:emergencybutton"}     
    },
    {
        id = "doctor",
        displayName = "Doctor",
        icon = "#doctor",
        enableMenu = function()
            return (not isDead and isDoctor)
        end,
        subMenus = { "general:escort", "medic:revive", "general:checktargetstates", "medic:heal" }
    },
    {
        id = "news",
        displayName = "News",
        icon = "#news",
        enableMenu = function()
            return (not isDead and isNews)
        end,
        subMenus = { "news:setCamera", "news:setMicrophone", "news:setBoom" }
    },
    {
        id = "vehicle",
        displayName = "Vehicle Options",
        icon = "#vehicle-options-vehicle",
        --functionName = "gameplay:carControl",
        enableMenu = function()
            if not isDead and IsPedInAnyVehicle(PlayerPedId(), false) then
                return true
            end
        end,
        subMenus = { "general:carControl", "general:carExtras", "general:hotwire" }
    },
    {
        id = "interact-safe",
        displayName = "Safe",
        icon = "#general-safe",
        functionName = "playersafes:getPlayerSafe",
        functionParameters = "access",
        enableMenu = function()
            if not isDead and exports['storage']:IsNearSafe() then
                return true
            end
        end,
    },
    {
        id = "interact-atm",
        displayName = "ATM",
        icon = "#general-atm",
        functionName = "banking:checkForATM",
        enableMenu = function()
            if not isDead and exports['banking']:IsNearATM(true) then
                return true
            end
        end,
    },
    {
        id = "hack-atm",
        displayName = "Hack ATM",
        icon = "#general-atm",
        functionName = "banking:hackATM",
        enableMenu = function()
            if not isDead and exports['banking']:CanHackATM() then
                return true
            end
        end,
    },
    {
        id = "hack-trafficlight",
        displayName = "Hack Traffic Light",
        icon = "#hack-traffic",
        functionName = "crim:hackTraffic",
        enableMenu = function()
            if not isDead and exports['crim']:CanHackTrafficLights() then
                return true
            end
        end,
    },    
    {
        id = "interact-bin",
        displayName = "Bin",
        icon = "#general-bin",
        functionName = "bins:GetBin",
        enableMenu = function()
            if not isDead and exports['storage']:IsNearBin() then
                return true
            end
        end,
    },
    {
        id = "interact-vending",
        displayName = "Vending Machince",
        icon = "#general-vending",
        functionName = "inventory:checkForVending",
        enableMenu = function()
            if not isDead and exports['inventory']:IsNearVending() then
                return true
            end
        end,
    },
    {
        id = "cornerselling",
        displayName = "Corner Selling",
        icon = "#cornerselling",
        functionName = "drugs:client:cornerselling",
        enableMenu = function()
            return not isDead and hasDrugs() and PlayerData.job.name ~= "police" and not IsPedInAnyVehicle(PlayerPedId(), false)
        end
    },
    {
        id = "smelter-options",
        displayName = "Smelter Options",
        icon = "#job-smelter",
        enableMenu = function()
            return not isDead and isNearSmelter
        end,
        subMenus = { "smelter:option1", "smelter:option2", "smelter:option3", "smelter:option4" }
    },
    {
        id = "miner-options",
        displayName = "Toggle Mining",
        icon = "#job-carpenter",
        functionName = "mining:client:toggleMining",
        enableMenu = function()
            return not isDead and isNearMiner
        end,
    }, 
    {
        id = "fueler-options",
        displayName = "Toggle Fueler",
        icon = "#job-carpenter",
        functionName = "fueler:client:toggleFuelRun",
        enableMenu = function()
            return not isDead and isNearFueler
        end,
    },
    {
        id = "lumber-options",
        displayName = "Toggle Lumber",
        icon = "#job-carpenter",
        functionName = "lumber:client:toggleLumberRun",
        enableMenu = function()
            return not isDead and isNearLumber
        end,
    },
    {
        id = "carpenter-options",
        displayName = "Craftsman Options",
        icon = "#job-carpenter",
        enableMenu = function()
            return not isDead and isNearCarpenter
        end,
        subMenus = { "carpenter:checkorders", "carpenter:craftingtable", "carpenter:pickaxe" }
    },
    {
        id = "moneywash-options",
        displayName = "Washing Options",
        icon = "#job-moneywash",
        enableMenu = function()
            return not isDead and isInLaundry
        end,
        subMenus = { "moneywash:checkorders", "moneywash:startorderbag", "moneywash:startorderroll", "moneywash:startorderband", "moneywash:cancelorder" }
    },
    {
        id = "job-vehicleshop-return",
        displayName = "Return Test Drive",
        icon = "#police-delete",
        functionName = "vehicleshop:client:returnTestDrive",
        enableMenu = function()
            return exports["vehicleshop"]:IsInTestDrive()
        end,
    },   
    {
        id = "job-pdm-options",
        displayName = "PDM",
        icon = "#general-keys-give",
        enableMenu = function()
            return PlayerData.job.name == "pdm" and PlayerData.job.onduty and not isDead
        end,
        subMenus = { "vehshop:changevehicle", "vehshop:testdrive", "vehshop:togglesalepoint" }
    },     
    {
        id = "job-handle-options",
        displayName = "HandleBar Haven",
        icon = "#job-handlebar",
        enableMenu = function()
            return PlayerData.job.name == "handlebar" and PlayerData.job.onduty and not isDead
        end,
        subMenus = { "vehshop:changevehicle", "vehshop:testdrive", "vehshop:togglesalepoint" }
    },
    {
        id = "job-grove-options",
        displayName = "Grove St Customs",
        icon = "#blip-moonlight",
        enableMenu = function()
            return PlayerData.job.name == "grovestcustom" and PlayerData.job.onduty and not isDead
        end,
        subMenus = { "vehshop:changevehicle", "vehshop:testdrive", "vehshop:togglesalepoint" }
    },  
    {
        id = "house-options",
        displayName = "House Options",
        icon = "#judge-licenses-grant-house",
        enableMenu = function()
            return insideOwnedHouse and not isDead
        end,
        subMenus = { "furni:toggle", "houses:givekeys", "houses:managekeys" }
    },  
    {
        id = "weed-dealer",
        displayName = "Unknown",
        icon = "#unknown-question",
        enableMenu = function()
            return not isDead and isNearWeedDealer
        end,
        subMenus = {}
    },
    {
        id = "real-estate",
        displayName = "Real Estate",
        icon = "#real-estate",
        enableMenu = function()
            return not isDead and PlayerData.job.name == "realestate"
        end,
        subMenus = { "realestate:createhouse", "realestate:creategarage", "realestate:createstash", "realestate:createlogout", "realestate:createoutfits" }
    },
    {
        id = "apartment-keys",
        displayName = "Manage Keys",
        icon = "#property-manage",
        functionName = "apartments:client:manageKeys",
        enableMenu = function()
            return not isDead and inApartment
        end,
    }, 
    {
        id = "apartment-givekeys",
        displayName = "Give Keys",
        icon = "#property-key",
        functionName = "apartments:client:giveAptKey",
        enableMenu = function()
            return not isDead and inApartment
        end,
    },
    {
        id = "taxi-job",
        displayName = "Taxi Job",
        icon = "#drivinginstructor",
        enableMenu = function()
            return not isDead and PlayerData.job.name == "taxi"
        end,
        subMenus = { "taxi:NPCrun" }
    },
    {
        id = "vineyard-job",
        displayName = "Vineyard",
        icon = "#vineyard",
        enableMenu = function()
            return not isDead and IsInVineyard
        end,
        subMenus = { "vineyard:pick", "vineyard:destroy" }
    },
    {
        id = "lumberyard-job",
        displayName = "Lumber Yard",
        icon = "#lumberyard",
        enableMenu = function()
            return not isDead and IsInLumberYard
        end,
        subMenus = { "lumberyard:chop", "lumberyard:destroy" }
    },
    {
        id = "cooker-options",
        displayName = "Cook",
        icon = "#job-smelter",
        enableMenu = function()
            return not isDead and isAtCooker
        end,
        subMenus = { "cooker:option1", "cooker:option2", "cooker:option3", "cooker:option4" }
    },
    {
        id = "traffic-options",
        displayName = "Traffic Options",
        icon = "#hack-traffic",
        enableMenu = function()
            if (PlayerData.job.name == "police") and PlayerData.job.onduty and not isDead then
                return true
            end
        end,
        subMenus = {"traffic:1", "traffic:2", "trafficsign:1", "trafficsign:2"}
    },
}

newSubMenus = {
    ['general:atm'] = {
        title = "ATM",
        icon = "#general-atm",
        functionName = "banking:checkForATM"
    }, 
    ['general:safe'] = {
        title = "Safe",
        icon = "#general-safe",
        functionName = "playersafes:getPlayerSafe",
        functionParameters = "access"
    }, 
    ['general:bin'] = {
        title = "Dumpster",
        icon = "#general-bin",
        functionName = "bins:GetBin"
    },    
    ['general:vending'] = {
        title = "Vending Machine",
        icon = "#general-vending",
        functionName = "inventory:checkForVending"
    },  
    ['general:emotes'] = {
        title = "Emotes",
        icon = "#general-emotes",
        functionName = "openEmoteMenu"
    },    
    ['general:keysgive'] = {
        title = "Give Key",
        icon = "#general-keys-give",
        functionName = "keys:giveKey"
    },
    ['general:carControl'] = {
        title = "Vehicle Controls",
        icon = "#vehicle-options-vehicle",
        functionName = "gameplay:carControl"
    },
    ['general:carExtras'] = {
        title = "Vehicle Extras",
        icon = "#vehicle-options-vehicle",
        functionName = "vehextras:menu"
    }, 
    ['general:hotwire'] = {
        title = "Hotwire Vehicle",
        icon = "#vehicle-hotwire",
        functionName = "vehiclelock:hotwire"
    },        
    ['general:apartgivekey'] = {
        title = "Give Key",
        icon = "#general-apart-givekey",
        functionName = "menu:givekeys"
    },
    ['general:aparttakekey'] = {
        title = "Take Key",
        icon = "#general-apart-givekey",
        functionName = "menu:takekeys"
    },
     ['general:checkoverself'] = {
        title = "Examine Self",
        icon = "#general-check-over-self",
        functionName = "Evidence:CurrentDamageList"
    },
    ['general:checktargetstates'] = {
        title = "Examine Target",
        icon = "#general-check-over-target",
        functionName = "requestWounds"
    },
    ['general:checkvehicle'] = {
        title = "Examine Vehicle",
        icon = "#general-check-vehicle",
        functionName = "towgarage:annoyedBouce"
    },
    ['general:escort'] = {
        title = "Escort",
        icon = "#general-escort",
        functionName = "police:client:EscortPlayer"
    },    
    ['general:putinvehicle'] = {
        title = "Seat Vehicle",
        icon = "#general-put-in-veh",
        functionName = "police:client:PutPlayerInVehicle"
    },
    ['general:unseatnearest'] = {
        title = "Unseat Nearest",
        icon = "#general-unseat-nearest",
        functionName = "police:client:unseatPly"
    },
    ['general:getintrunk'] = {
        title = "Get in Trunk",
        icon = "#general-unseat-nearest",
        functionName = "gameplay:getintrunk"
    },
    ['general:putintrunk'] = {
        title = "Put in Trunk",
        icon = "#general-unseat-nearest",
        functionName = "gameplay:dragouttrunk"
    },
    ['general:dragouttrunk'] = {
        title = "Drag out Trunk",
        icon = "#general-unseat-nearest",
        functionName = "gameplay:dragouttrunk"
    },    
    ['general:carry'] = {
        title = "Carry",
        icon = "#general-carry",
        functionName = "police:client:KidnapPlayer"
    },
    ['general:robplayer'] = {
        title = "Rob Player",
        icon = "#general-illegal",
        functionName = "police:client:RobPlayer"
    },    
    ['general:hostage'] = {
        title = "Take Hostage",
        icon = "#general-illegal",
        functionName = "A5:Client:TakeHostage"
    },                    
    ['general:flipvehicle'] = {
        title = "Flip Vehicle",
        icon = "#general-flip-vehicle",
        functionName = "FlipVehicle"
    },
    ['general:contactdetails'] = {
        title = "Contact Details",
        icon = "#general-contact-details",
        functionName = "phone:client:GiveContactDetails"
    },
    ['general:pickupsafe'] = {
        title = "Pickup Safe",
        icon = "#general-safe",
        functionName = "playersafes:getPlayerSafe",
        functionParameters = "pickup"
    },
    ['general:pickupcraft'] = {
        title = "Pickup Crafting Table",
        icon = "#order-crafttable",
        functionName = "Crafting:deleteCraftingTable",
    },
    ['drivinginstructor:drivingtest'] = {
        title = "Driving Test",
        icon = "#drivinginstructor-drivingtest",
        functionName = "drivingInstructor:testToggle"
    },
    ['drivinginstructor:submittest'] = {
        title = "Submit Test",
        icon = "#drivinginstructor-submittest",
        functionName = "drivingInstructor:submitTest"
    },
    ['blip:allOn'] = {
        title = "All On",
        icon = "#blip-allOn",
        functionName = "blipManager:toggleAllBlip",
        functionParameters = "on"      
    },
    ['blip:allOff'] = {
        title = "All Off",
        icon = "#blip-allOff",
        functionName = "blipManager:toggleAllBlip",
        functionParameters = "off"    
    },           
    ['blip:pd'] = {
        title = "Police Stations",
        icon = "#blip-pd",
        functionName = "blipManager:toggleBlip",
        functionParameters = "pd"     
    },
    ['blip:hospital'] = {
        title = "Hospitals",
        icon = "#blip-hospital",
        functionName = "blipManager:toggleBlip",
        functionParameters = "hospital"        
    },
    ['blip:ammunation'] = {
        title = "Gun Store",
        icon = "#blip-ammunation",
        functionName = "blipManager:toggleBlip",
        functionParameters = "ammunation"       
    },
    ['blip:shop'] = {
        title = "General Store",
        icon = "#blip-shop",
        functionName = "blipManager:toggleBlip",
        functionParameters = "shop"       
    },
    ['blip:tool'] = {
        title = "Tool Store",
        icon = "#blip-tool",
        functionName = "blipManager:toggleBlip",
        functionParameters = "tool"        
    },
    ['blip:bank'] = {
        title = "Banks",
        icon = "#blip-bank",
        functionName = "blipManager:toggleBlip",
        functionParameters = "bank"        
    },
    ['blip:clothes'] = {
        title = "Clothes Shop",
        icon = "#blip-clothes",
        functionName = "blipManager:toggleBlip",
        functionParameters = "clothes"        
    },
    ['blip:barbers'] = {
        title = "Barbers",
        icon = "#blip-barbers",
        functionName = "blipManager:toggleBlip",
        functionParameters = "barbers"        
    },        
    ['blip:garage'] = {
        title = "Garages",
        icon = "#blip-garage",
        functionName = "blipManager:toggleBlip",
        functionParameters = "garage"
    },
    ['blip:impound'] = {
        title = "Hayes Depot",
        icon = "#blip-impound",
        functionName = "blipManager:toggleBlip",
        functionParameters = "impound"
    },
    ['blip:paint'] = {
        title = "LS Customs",
        icon = "#blip-paint",
        functionName = "blipManager:toggleBlip",
        functionParameters = "paint"
    },
    ['blip:benny'] = {
        title = "Bennys Mechanic",
        icon = "#blip-benny",
        functionName = "blipManager:toggleBlip",
        functionParameters = "benny"
    },
    ['blip:vangelico'] = {
        title = "Vangelico Store",
        icon = "#blip-vangelico",
        functionName = "blipManager:toggleBlip",
        functionParameters = "vangelico"
    },
    ['blip:pdm'] = {
        title = "PDM Vehicle Shop",
        icon = "#blip-carwash",
        functionName = "blipManager:toggleBlip",
        functionParameters = "pdm"
    },
    ['blip:craftsman'] = {
        title = "Craftsman",
        icon = "#job-carpenter",
        functionName = "blipManager:craftsman",
        functionParameters = "craftsman"
    },        
    ['blip:grovecustom'] = {
        title = "Grove St Customs",
        icon = "#blip-moonlight",
        functionName = "blipManager:toggleBlip",
        functionParameters = "grovecustom"
    },
    ['blip:cityhall'] = {
        title = "City Hall",
        icon = "#blip-cityhall",
        functionName = "blipManager:toggleBlip",
        functionParameters = "cityhall"        
    }, 
    ['blip:drivingschool'] = {
        title = "Driving School",
        icon = "#blip-driveschool",
        functionName = "blipManager:toggleBlip",
        functionParameters = "drivingschool"
    },
    ['blip:carwash'] = {
        title = "Car Wash",
        icon = "#blip-carwash",
        functionName = "blipManager:toggleBlip",
        functionParameters = "carwash"        
    }, 
    ['blip:motel'] = {
        title = "Motels",
        icon = "#blip-motel",
        functionName = "blipManager:toggleBlip",
        functionParameters = "motel"
    },
    ['blip:casino'] = {
        title = "Diamond Casino",
        icon = "#blip-casino",
        functionName = "blipManager:toggleBlip",
        functionParameters = "casino"
    },
    ['blip:airport'] = {
        title = "Airports",
        icon = "#blip-airport",
        functionName = "blipManager:toggleBlip",
        functionParameters = "airport"
    },
	['blip:publicjobs'] = {
		title = "Public Jobs",
        icon = "#blip-publicjobs",
        functionName = "blipManager:togglePublicJobs"
	},
    ['animations:brave'] = {
        title = "Brave",
        icon = "#animation-brave",
        functionName = "AnimSet:Brave"
    },
    ['animations:hurry'] = {
        title = "Hurry",
        icon = "#animation-hurry",
        functionName = "AnimSet:Hurry"
    },
    ['animations:business'] = {
        title = "Business",
        icon = "#animation-business",
        functionName = "AnimSet:Business"
    },
    ['animations:tipsy'] = {
        title = "Tipsy",
        icon = "#animation-tipsy",
        functionName = "AnimSet:Tipsy"
    },
    ['animations:injured'] = {
        title = "Injured",
        icon = "#animation-injured",
        functionName = "AnimSet:Injured"
    },
    ['animations:tough'] = {
        title = "Tough",
        icon = "#animation-tough",
        functionName = "AnimSet:ToughGuy"
    },
    ['animations:sassy'] = {
        title = "Sassy",
        icon = "#animation-sassy",
        functionName = "AnimSet:Sassy"
    },
    ['animations:sad'] = {
        title = "Sad",
        icon = "#animation-sad",
        functionName = "AnimSet:Sad"
    },
    ['animations:posh'] = {
        title = "Posh",
        icon = "#animation-posh",
        functionName = "AnimSet:Posh"
    },
    ['animations:alien'] = {
        title = "Alien",
        icon = "#animation-alien",
        functionName = "AnimSet:Alien"
    },
    ['animations:nonchalant'] =
    {
        title = "Nonchalant",
        icon = "#animation-nonchalant",
        functionName = "AnimSet:NonChalant"
    },
    ['animations:hobo'] = {
        title = "Hobo",
        icon = "#animation-hobo",
        functionName = "AnimSet:Hobo"
    },
    ['animations:money'] = {
        title = "Money",
        icon = "#animation-money",
        functionName = "AnimSet:Money"
    },
    ['animations:swagger'] = {
        title = "Swagger",
        icon = "#animation-swagger",
        functionName = "AnimSet:Swagger"
    },
    ['animations:shady'] = {
        title = "Shady",
        icon = "#animation-shady",
        functionName = "AnimSet:Shady"
    },
    ['animations:maneater'] = {
        title = "Man Eater",
        icon = "#animation-maneater",
        functionName = "AnimSet:ManEater"
    },
    ['animations:chichi'] = {
        title = "ChiChi",
        icon = "#animation-chichi",
        functionName = "AnimSet:ChiChi"
    },
    ['animations:default'] = {
        title = "Default",
        icon = "#animation-default",
        functionName = "AnimSet:default"
    },
    ['mechanic:unlock'] = {
        title = "Unlock Vehicle",
        icon = "#mech-action-unlock",
        functionName = "mech:client:menuOnUnlock"
    },
    ['mechanic:repair'] = {
        title = "Recovery Repair",
        icon = "#mech-action-repair",
        functionName = "mech:client:menuOnRepair"
    },
    ['mechanic:clean'] = {
        title = "Clean Vehicle",
        icon = "#mech-action-clean",
        functionName = "mech:client:menuOnClean",
        functionParameters = true
    },
    ['mechanic:impound'] = {
        title = "Impound",
        icon = "#police-vehicle",
        functionName = "mech:client:menuOnImpound"
    },
    ['mechanic:flatbed'] = {
        title = "Flatbed",
        icon = "#mech-action-flatbed",
        functionName = "mech:client:menuFlatbed"
    },    
    ['mechanic:npctow'] = {
        title = "NPC Flatbed Job",
        icon = "#mech-action-npc",
        functionName = "mech:client:menuNPCJob"
    },
    ["mechanic:removeFakePlate"] = {
        title = "Remove Plate",
        icon = "#police-delete",
        functionName = "mech:client:attemptRemovePlate"
    },
    ['cuffs:cuff'] = {
        title = "Hard Cuff",
        icon = "#cuffs-cuff",
        functionName = "st:handcuff"
    }, 
    ['cuffs:softcuff'] = {
        title = "Soft Cuff",
        icon = "#cuffs-cuff",
        functionName = "st:softcuff"
    },
    ['cuffs:uncuff'] = {
        title = "Uncuff",
        icon = "#cuffs-uncuff",
        functionName = "st:uncuff"
    },
--[[     ['cuffs:remmask'] = {
        title = "Remove Mask Hat",
        icon = "#cuffs-remove-mask",
        functionName = "police:remmask"
    }, ]]
    ['cuffs:checkinventory'] = {
        title = "Search Person",
        icon = "#cuffs-check-inventory",
        functionName = "police:client:SearchPlayer"
    },
    ['cuffs:unseat'] = {
        title = "Unseat",
        icon = "#cuffs-unseat-player",
        functionName = "esx_ambulancejob:pullOutVehicle"
    },
    ['cuffs:checkphone'] = {
        title = "Read Phone",
        icon = "#cuffs-check-phone",
        functionName = "police:checkPhone"
    },
    ['medic:revive'] = {
        title = "Revive",
        icon = "#medic-revive",
        functionName = "hospital:client:RevivePlayer"
    },
    ['medic:treatbed'] = {
        title = "Treat Patient",
        icon = "#medic-bedtreat",
        functionName = "Pillbox:TreatPlayer"
    },
    ['medic:treatwounds'] = {
        title = "Treat Wounds",
        icon = "#medic-heal",
        functionName = "hospital:client:TreatWounds"
    },
    ['medic:emergencybutton'] = {
        title = "Emergency Button",
        icon = "#general-illegal",
        functionName = "police:client:SendPoliceEmergencyAlert"
    },
    ['medic:putinvehicle'] = {
        title = "Put in vehicle",
        icon = "#general-put-in-veh",
        functionName = "st:emsputinvehicle"
    },
    ['medic:takeoutvehicle'] = {
        title = "Take out vehicle",
        icon = "#general-unseat-nearest",
        functionName = "st:emstakeoutvehicle"
    },
    ['medic:drag'] = {
        title = "Drag",
        icon = "#general-escort",
        functionName = "st:emsdrag"
    },
    ['medic:undrag'] = {
        title = "Undrag",
        icon = "#general-escort",
        functionName = "st:emsundrag"
    },
    ['medic:checkhealth'] = {
        title = "Check Health",
        icon = "#police-action-gsr",
        functionName = "hospital:client:CheckStatus"
    },    
    ['police:escort'] = {
        title = "Escort",
        icon = "#general-escort",
        functionName = "st:escort"
    },
    ['police:revive'] = {
        title = "Revive",
        icon = "#medic-revive",
        functionName = "st:pdrevive"
    },
    ['police:putinvehicle'] = {
        title = "Seat Vehicle",
        icon = "#general-put-in-veh",
        functionName = "st:putinvehicle"
    },
    ['police:unseatnearest'] = {
        title = "Unseat Nearest",
        icon = "#general-unseat-nearest",
        functionName = "st:takeoutvehicle"
    },
    ['police:impound'] = {
        title = "Impound/Seize",
        icon = "#police-vehicle",
        functionName = "police:client:DepotVehicle",
        functionParameters = "impound"
    },
    ['police:depot'] = {
        title = "Send Depot",
        icon = "#police-vehicle",
        functionName = "police:client:DepotVehicle",
        functionParameters = "depot"        
    },    
    ['police:cuff'] = {
        title = "Cuff",
        icon = "#cuffs-cuff",
        functionName = "police:cuffFromMenu"
    },
    ['police:checkbank'] = {
        title = "Check Bank",
        icon = "#police-check-bank",
        functionName = "police:checkBank"
    },
    ['police:checklicenses'] = {
        title = "Check Licenses",
        icon = "#police-check-licenses",
        functionName = "police:checkLicenses"
    },
--[[     ['police:removeweapons'] = {
        title = "Remove Weapons License",
        icon = "#police-action-remove-weapons",
        functionName = "police:removeWeapon"
    }, ]]
    ['police:gsr'] = {
        title = "GSR Test",
        icon = "#police-action-gsr",
        functionName = "police:client:GSRTest"
    },
    ['police:openmdt'] = {
        title = "MDT",
        icon = "#judge-licenses-grant-business",
        functionName = "openMDT"
    },
    ['police:getid'] = {
        title = "Get ID",
        icon = "#police-vehicle-plate",
        functionName = "st:getid"
    },
    ['police:toggleradar'] = {
        title = "Toggle Radar",
        icon = "#police-vehicle-radar",
        functionName = "startSpeedo"
    },
    ['police:runplate'] = {
        title = "Run Plate",
        icon = "#police-vehicle-plate",
        functionName = "st:mdtvehiclesearch"
    },
    ['police:frisk'] = {
        title = "Frisk",
        icon = "#police-action-frisk",
        functionName = "police:client:FriskPlayer"
    },
    ['police:checkstatus'] = {
        title = "Check Status",
        icon = "#police-action-gsr",
        functionName = "police:client:CheckStatus"
    }, 
    ['police:fineplayer'] = {
        title = "Fine",
        icon = "#police-fine",
        functionName = "police:client:BillPlayer"
    },
    ['police:search'] = {
        title = "Search",
        icon = "#police-action-gsr",
        functionName = "police:client:SearchPlayer"
    },
    ['police:seizeDriverLicense'] = {
        title = "Take Drivers License",
        icon = "#general-keys-give",
        functionName = "police:client:SeizeDriverLicense"
    },
    ['police:seizeGunLicense'] = {
        title = "Take Gun License",
        icon = "#general-seizegun",
        functionName = "police:client:SeizeGunLicense"
    },    
    ['police:seizeCash'] = {
        title = "Take cash",
        icon = "#police-seizecash",
        functionName = "police:client:SeizeCash"
    },    
    ['police:pickup'] = {
        title = "Pickup",
        icon = "#police-delete",
        functionName = "police:client:deleteObject"
    },      
    ['police:cone'] = {
        title = "Cone",
        icon = "#police-object",
        functionName = "police:client:spawnCone"
    },
    ['police:barrier'] = {
        title = "Barrier",
        icon = "#police-object",
        functionName = "police:client:spawnBarrier"
    },    
    ['police:tent'] = {
        title = "Tent",
        icon = "#police-object",
        functionName = "police:client:spawnTent"
    },
    ['police:light'] = {
        title = "Light",
        icon = "#police-object",
        functionName = "police:client:spawnLight"
    },
    ['police:spikes'] = {
        title = "Spike Strips",
        icon = "#general-illegal",
        functionName = "police:client:SpawnSpikeStrip"
    },                
    ["expressions:angry"] = {
        title="Angry",
        icon="#expressions-angry",
        functionName = "expressions",
        functionParameters =  { "mood_angry_1" }
    },
    ["expressions:drunk"] = {
        title="Drunk",
        icon="#expressions-drunk",
        functionName = "expressions",
        functionParameters =  { "mood_drunk_1" }
    },
    ["expressions:dumb"] = {
        title="Dumb",
        icon="#expressions-dumb",
        functionName = "expressions",
        functionParameters =  { "pose_injured_1" }
    },
    ["expressions:electrocuted"] = {
        title="Electrocuted",
        icon="#expressions-electrocuted",
        functionName = "expressions",
        functionParameters =  { "electrocuted_1" }
    },
    ["expressions:grumpy"] = {
        title="Grumpy",
        icon="#expressions-grumpy",
        functionName = "expressions", 
        functionParameters =  { "mood_drivefast_1" }
    },
    ["expressions:happy"] = {
        title="Happy",
        icon="#expressions-happy",
        functionName = "expressions",
        functionParameters =  { "mood_happy_1" }
    },
    ["expressions:injured"] = {
        title="Injured",
        icon="#expressions-injured",
        functionName = "expressions",
        functionParameters =  { "mood_injured_1" }
    },
    ["expressions:joyful"] = {
        title="Joyful",
        icon="#expressions-joyful",
        functionName = "expressions",
        functionParameters =  { "mood_dancing_low_1" }
    },
    ["expressions:mouthbreather"] = {
        title="Mouthbreather",
        icon="#expressions-mouthbreather",
        functionName = "expressions",
        functionParameters = { "smoking_hold_1" }
    },
    ["expressions:normal"]  = {
        title="Normal",
        icon="#expressions-normal",
        functionName = "expressions:clear"
    },
    ["expressions:oneeye"]  = {
        title="One Eye",
        icon="#expressions-oneeye",
        functionName = "expressions",
        functionParameters = { "pose_aiming_1" }
    },
    ["expressions:shocked"]  = {
        title="Shocked",
        icon="#expressions-shocked",
        functionName = "expressions",
        functionParameters = { "shocked_1" }
    },
    ["expressions:sleeping"]  = {
        title="Sleeping",
        icon="#expressions-sleeping",
        functionName = "expressions",
        functionParameters = { "dead_1" }
    },
    ["expressions:smug"]  = {
        title="Smug",
        icon="#expressions-smug",
        functionName = "expressions",
        functionParameters = { "mood_smug_1" }
    },
    ["expressions:speculative"]  = {
        title="Speculative",
        icon="#expressions-speculative",
        functionName = "expressions",
        functionParameters = { "mood_aiming_1" }
    },
    ["expressions:stressed"]  = {
        title="Stressed",
        icon="#expressions-stressed",
        functionName = "expressions",
        functionParameters = { "mood_stressed_1" }
    },
    ["expressions:sulking"]  = {
        title="Sulking",
        icon="#expressions-sulking",
        functionName = "expressions",
        functionParameters = { "mood_sulk_1" },
    },
    ["expressions:weird"]  = {
        title="Weird",
        icon="#expressions-weird",
        functionName = "expressions",
        functionParameters = { "effort_2" }
    },
    ["expressions:weird2"]  = {
        title="Weird 2",
        icon="#expressions-weird2",
        functionName = "expressions",
        functionParameters = { "effort_3" }
    },
    ["job:startfishing"]  = {
        title="Toggle Fishing",
        icon="#job-fishing",
        functionName = "fishing:startFish",
    },
    ["job:starthunting"]  = {
        title="Toggle Hunting",
        icon="#job-hunting",
        functionName = "hunting:toggle",
    },
    ["job:hotdog"]  = {
        title="Toggle Hotdog Selling",
        icon="#job-hotdog",
        functionName = "hotdogjob:client:ToggleSell",
    },
    ["job:delivery"]  = {
        title="Toggle Delivery Job",
        icon="#job-delivery",
        functionName = "delivery:toggle",
    },
    ["job:mining"] = {
        title="Toggle Mining Job",
        icon="#job-carpenter",
        functionName = "mining:client:toggleMining",
    },
    ["smelter:option1"]  = {
        title="Option 1",
        icon="#job-option1",
        functionName = "smelter:client:interact",
        functionParameters = { 1 },
    },
    ["smelter:option2"]  = {
        title="Option 2",
        icon="#job-option2",
        functionName = "smelter:client:interact",
        functionParameters = { 2 },
    },
    ["smelter:option3"]  = {
        title="Option 3",
        icon="#job-option3",
        functionName = "smelter:client:interact",
        functionParameters = { 3 },
    },
    ["smelter:option4"]  = {
        title="Option 4",
        icon="#job-option4",
        functionName = "smelter:client:interact",
        functionParameters = { 4 },
    },
    ["carpenter:checkorders"]  = {
        title="Check Orders",
        icon="#job-check",
        functionName = "carpenter:client:GetOrders",
    },
    ["carpenter:craftingtable"]  = {
        title="Crafting Table",
        icon="#order-crafttable",
        functionName = "carpenter:client:DoOrder",
        functionParameters = { 1 },
    },
    ["carpenter:pickaxe"]  = {
        title="Pickaxe",
        icon="#order-crafttable",
        functionName = "carpenter:client:DoOrder",
        functionParameters = { 2 },
    },
    ["moneywash:checkorders"]  = {
        title="Check Orders",
        icon="#job-check",
        functionName = "moneywash:client:CheckOrders",
    },
    ["moneywash:startorderbag"]  = {
        title="Start Money Bag Order",
        icon="#job-moneywashstart",
        functionName = "moneywash:client:StartOrder",
        functionParameters = "moneybag"  
    },
    ["moneywash:startorderroll"]  = {
        title="Start Cash Roll Order",
        icon="#job-moneywashstart",
        functionName = "moneywash:client:StartOrder",
        functionParameters = "cashroll"
    },
    ["moneywash:startorderband"]  = {
        title="Start Cash Band Order",
        icon="#job-moneywashstart",
        functionName = "moneywash:client:StartOrder",
        functionParameters = "cashband"
    },
    ["moneywash:cancelorder"]  = {
        title="Cancel Current",
        icon="#police-delete",
        functionName = "moneywash:client:CancelCurrent",
    },
    ["vehshop:changevehicle"]  = {
        title="Change Display",
        icon="#job-vehshop-swap",
        functionName = "vehicleshop:client:ChangeDisplayCurrent",
    },
    ["vehshop:testdrive"]  = {
        title="Test Drive",
        icon="#general-interact",
        functionName = "vehicleshop:client:TestDriveCurrent",
    },
    ["vehshop:togglesalepoint"]  = {
        title="Toggle Sale Point",
        icon="#blip-bank",
        functionName = "vehicleshop:client:ToggleSalePoint",
    },
    ["radio:channel:1"] = {
        title="Channel 1",
        icon="#radio-wifi-1",
        functionName="radio:client:doJoinRadio",
        functionParameters = "1"
    },
    ["radio:channel:2"] = {
        title="Channel 2",
        icon="#radio-wifi-2",
        functionName="radio:client:doJoinRadio",
        functionParameters = "2"
    },
    ["radio:channel:3"] = {
        title="Channel 3",
        icon="#radio-wifi-3",
        functionName="radio:client:doJoinRadio",
        functionParameters = "3"
    },
    ["radio:channel:4"] = {
        title="Channel 4",
        icon="#radio-wifi-4",
        functionName="radio:client:doJoinRadio",
        functionParameters = "4"
    },
    ["radio:channel:5"] = {
        title="Channel 5",
        icon="#radio-wifi-5",
        functionName="radio:client:doJoinRadio",
        functionParameters = "5"
    },
    ["radio:channel:toggle"] = {
        title="Toggle Radio",
        icon="#radio-toggle",
        functionName="radio:client:toggleRadio",     
    },
    ["weedseeds:skunk"] = {
        title="Skunk",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_skunk_seed" 
    },
    ["weedseeds:purplehaze"] = {
        title="Purple Haze",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_purple-haze_seed"        
    },
    ["weedseeds:ogkush"] = {
        title="OG Kush",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_og-kush_seed"
    },
    ["weedseeds:amnesia"] = {
        title="Amnesia",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_amnesia_seed"        
    },
    ["weedseeds:ak47"] = {
        title="AK47",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_ak47_seed"        
    },
    ["weedseeds:whitewidow"] = {
        title="White Widow",
        icon="#weed-cultivation",
        functionName="handleWeedDealer",
        functionParameters = "weed_white-widow_seed"        
    },
    ["furni:toggle"] = {
        title="Furni",
        icon="#property-furni",
        functionName="furni:client:toggleFurni",
    },
    ["houses:givekeys"] = {
        title="Give Keys",
        icon="#property-key",
        functionName="bj-houses:client:giveHouseKey",
    },
    ["houses:managekeys"] = {
        title="Manage Keys",
        icon="#property-manage",
        functionName="bj-houses:client:removeHouseKey",
    },
    ["realestate:createhouse"] = {
        title="Create Property",
        icon="#real-estate-create",
        functionName="bj-houses:client:createHouses",
    },
    ["realestate:creategarage"] = {
        title="Create Garage",
        icon="#blip-garage",
        functionName="bj-houses:client:addGarage",
    },
    ["realestate:createstash"] = {
        title="Create Stash",
        icon="#real-estate-stash",
        functionName="bj-houses:client:setLocation",
        functionParameters="stash",
    },
    ["realestate:createlogout"] = {
        title="Create Logout",
        icon="#general-unseat-nearest",
        functionName="bj-houses:client:setLocation",
        functionParameters="logout",
    },
    ["realestate:createoutfits"] = {
        title="Create Outfit",
        icon="#blip-clothes",
        functionName="bj-houses:client:setLocation",
        functionParameters="outfit",
    },
    ["taxi:NPCrun"] = {
        title="Toggle NPC Fare",
        icon="#police-seizecash",
        functionName="taxi:client:DoTaxiNpc"
    },
    ["vineyard:pick"] = {
        title="Pick Vine",
        icon="#police-action-frisk",
        functionName="vineyard:client:pickVine"
    },
    ["vineyard:destroy"] = {
        title="Destroy",
        icon="#police-delete",
        functionName="vineyard:client:removeVine"
    },
    ["lumberyard:chop"] = {
        title="Chop Tree",
        icon="#blip-tool",
        functionName="lumberyard:client:chopTree"
    },
    ["lumberyard:destroy"] = {
        title="Destroy",
        icon="#police-delete",
        functionName="lumberyard:client:removeTree"
    },
    ["cooker:option1"]  = {
        title="Option 1",
        icon="#job-option1",
        functionName = "restaurant:client:cookInteract",
        functionParameters = { 1 },
    },
    ["cooker:option2"]  = {
        title="Option 2",
        icon="#job-option2",
        functionName = "restaurant:client:cookInteract",
        functionParameters = { 2 },
    },
    ["cooker:option3"]  = {
        title="Option 3",
        icon="#job-option3",
        functionName = "restaurant:client:cookInteract",
        functionParameters = { 3 },
    },
    ["cooker:option4"]  = {
        title="Option 4",
        icon="#job-option4",
        functionName = "restaurant:client:cookInteract",
        functionParameters = { 4 },
    },
    ["traffic:1"] = {
        title="Traffic 1",
        icon="#hack-traffic",
        functionName = "mmtraffic:traffic",
        functionParameters = 1,
    },
    ["traffic:2"] = {
        title="Traffic 2",
        icon="#hack-traffic",
        functionName = "mmtraffic:traffic",
        functionParameters = 2,
    },
    ["trafficsign:1"] = {
        title="Traffic Sign 1",
        icon="#hack-traffic",
        functionName = "mmtraffic:trafficsign",
        functionParameters = 1,
    },
    ["trafficsign:2"] = {
        title="Traffic Sign 2",
        icon="#hack-traffic",
        functionName = "mmtraffic:trafficsign",
        functionParameters = 2,
    },
}

AddEventHandler("mmtraffic:trafficsign", function(num)
    print("num: "..num)
end)

RegisterNetEvent('ems:deathcheck')
AddEventHandler('ems:deathcheck', function()
    if not isDead then
        isDead = true
    else
        isDead = false
    end
end)

RegisterNetEvent("drivingInstructor:instructorToggle")
AddEventHandler("drivingInstructor:instructorToggle", function(mode)
    if PlayerData.job.name == "drivinginstructor" then
        isInstructorMode = mode
    end
end)

function HandleVehShop()
    local menu = {}

    return menu
end

local CornerDrugs = {
    "weed_white-widow_bag",
    "weed_skunk_bag",
    "weed_purple-haze_bag",
    "weed_og-kush_bag",
    "weed_amnesia_bag",
    "weed_ak47_bag",
}

function hasDrugs()
    local has = false
    for i = 1, #CornerDrugs, 1 do
        for k,v in pairs(PlayerData.items) do
            if v.name == CornerDrugs[i] and v.amount > 0 then
                has = true
                break
            end
        end
    end
    return has
end

AddEventHandler('isAtCooker', function(b) isAtCooker = b; end)
AddEventHandler('isNearSmelter', function(b) isNearSmelter = b; end)
AddEventHandler('isNearCarpenter', function(b) isNearCarpenter = b; end)
AddEventHandler('isInLaundry', function(b) isInLaundry = b; end)
AddEventHandler('isNearWeedDealer', function(b) isNearWeedDealer = b end)
AddEventHandler('isNearMiner', function(b) isNearMiner = b; end)
AddEventHandler('isNearFueler', function(b) isNearFueler = b; end)
AddEventHandler('isNearLumber', function(b) isNearLumber = b; end)
AddEventHandler('inApartment', function(b) inApartment = b; end)
AddEventHandler('IsInVineyard', function(b) IsInVineyard = b; end)
AddEventHandler('IsInLumberYard', function(b) IsInLumberYard = b; end)

AddEventHandler('bj-houses:client:insideHouse', function(b) insideOwnedHouse = b end)

RegisterNetEvent('BJCore:Player:SetPlayerData')
AddEventHandler('BJCore:Player:SetPlayerData', function(Player)
    PlayerData = Player
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('BJCore:Player:UpdateClientInventoryCache')
AddEventHandler('BJCore:Player:UpdateClientInventoryCache', function(itemCache)
    if PlayerData then
        PlayerData.items = itemCache
    end
end)
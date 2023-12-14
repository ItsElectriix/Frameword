Config = {}

Config.ViewingTime = 5 -- minutes

Config.FreeApartment = 10

Config.Buildings = {
	[1] = {
		label = "Eclipse Towers",
		name = "eclipsetowers",
		isOffice = false,
		price = 2000,
		doorModel = -658026477, -- or false if not needed
		doorPos = vector4(-782.4497, 317.5156, 217.7876, 179.600),
		entry = vector4(-776.9959, 319.74215, 85.662658, 179.7051),
		insidePos = {
			entry = vector4(-781.8128, 317.91983, 217.63879, 6.0717191),
			stash = vector3(-796.2607, 328.42025, 217.03819),
			outfits = vector3(-797.8322, 327.70651, 220.4384),
			logout = vector3(-800.1095, 338.30355, 220.43847)
		},
		maxLeases = 50,
	},
	[2] = {
		label = "4 Integrity Way",
		name = "4integrity",
		isOffice = false,
		price = 2200,
		doorModel = 34120519,
		doorPos = vector4(-24.97746, -598.1375, 80.18041, 249.562),
		entry = vector4(-43.4213, -584.7264, 38.161083, 71.126358),
		insidePos = {
			entry = vector4(-24.43674, -597.6713, 80.031097, 248.84298),
			stash = vector3(-12.70783, -597.0857, 79.430175),
			outfits = vector3(-38.23781, -589.2897, 78.830337),
			logout = vector3(-36.12416, -580.7166, 78.830322)
		},
		maxLeases = 50,
	},
    [3] = {
        label = "Maze Tower",
        name = "mazetower",
        isOffice = true,
        price = 3750,
        doorModel = false,
        doorPos = false,
        entry = vector4(-67.10777, -802.4338, 44.227275, 161.79298),
        insidePos = {
            entry = vector4(-75.37277, -827.2547, 243.38575, 68.439048),
            stash = vector3(-82.23387, -809.986, 243.38594),
            outfits = vector3(-78.37545, -812.3466, 243.38575),
        },
        maxLeases = 50,
    },
    [4] = {
        label = "Arcadius Business Centre",
        name = "arcadius",
        isOffice = true,
        price = 3750,
        doorModel = false,
        doorPos = false,
        entry = vector4(-116.74, -604.78, 36.28, 247.01),
        insidePos = {
            entry = vector4(-141.31, -620.97, 168.82, 273.3),
            stash = vector3(-128.03, -632.63, 168.82),
            outfits = vector3(-132.53, -632.82, 168.82),
        },
        maxLeases = 50,
    },
    [5] = {
        label = "Lom Bank",
        name = "lombank",
        isOffice = true,
        price = 3750,
        doorModel = false,
        doorPos = false,
        entry = vector4(-1581.86, -557.62, 34.95, 35.97),
        insidePos = {
            entry = vector4(-1579.43, -564.88, 108.52, 304.68),
            stash = vector3(-1562.12, -568.48, 108.52),
            outfits = vector3(-1566, -570.85, 180.52),
        },
        maxLeases = 50,
    },
    [6] = {
        label = "Maze Bank West",
        name = "mazebankwest",
        isOffice = true,
        price = 3750,
        doorModel = false,
        doorPos = false,
        entry = vector4(-1371.43, -503.88, 33.16, 128.65),
        insidePos = {
            entry = vector4(-1392.58, -480.05, 72.04, 6.5),
            stash = vector3(-1381.36, -466.57, 72.04),
            outfits = vector3(-1380.99, -471.19, 72.04),
        },
        maxLeases = 50,
    },
    [7] = {
        label = "Richard Majestic",
        name = "richardmajestic",
        isOffice = false,
        price = 2500,
        doorModel = 34120519, -- or false if not needed
        doorPos = vector4(-919.1519, -367.7008, 114.4243, 117),
        entry = vector4(-933.4, -383.97, 38.96, 119.42),
        insidePos = {
            entry = vector4(-919.73, -368.67, 114.27, 112.43),
            stash = vector3(-927.11, -377.92, 113.67),
            outfits = vector3(-903.62, -364.33, 113.07),
            logout = vector3(-898.38, -365.63, 113.07)
        },
        maxLeases = 50,
    },
    [8] = {
        label = "Tinsel Towers",
        name = "tinseltowers",
        isOffice = false,
        price = 2500,
        doorModel = 34120519, -- or false if not needed
        doorPos = vector4(-610.0969, 59.60177, 98.34972, 90),
        entry = vector4(-621.02, 46.19, 43.59, 175.21),
        insidePos = {
            entry = vector4(-611.1, 58.96, 98.2, 87.93),
            stash = vector3(-621.99, 54.13, 97.6),
            outfits = vector3(-594.65, 55.66, 97),
            logout = vector3(-590.2, 52.06, 97)
        },
        maxLeases = 50,
    },
    [9] = {
        label = "Dell Perro Heights",
        name = "dellperro",
        isOffice = false,
        price = 4250,
        doorModel = 330294775, -- or false if not needed
        doorPos = vector4(-1456.818, -520.5037, 57.04281, 305),
        entry = vector4(-1447.55, -537.8, 34.74, 211.55),
        insidePos = {
            entry = vector4(-1457.99, -520.43, 56.93, 124.33),
            stash = vector3(-1456.95, -530.42, 56.94),
            outfits = vector3(-1467.89, -537.45, 50.73),
            logout = vector3(-1461.89, -531.94, 50.72)
        },
        maxLeases = 50,
    },
}

Config.ActionText = {
	entry = "[~g~E~w~] Leave",
	stash = "[~g~E~w~] Stash",
	outfits = "[~g~E~w~] Outfits",
	logout = "[~r~E~w~] Logout",
}

function getBuildingId(name)
    for k,v in pairs(Config.Buildings) do
        if v.name == name then
            return k
        end
    end
end

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
BJ = {}

BJ.Locations = {
    --["legion"] = { coords = { x = 195.17, y = -933.77, z = 29.7, h = 144.5 } },
    --["policedp"] = { coords = { x = 428.23, y = -984.28, z = 29.76, h = 3.5 } },
    --["motel"] = { coords = { x = 327.56, y = -205.08, z = 53.08, h = 163.5 } },
    ["lsia"] = { coords =  { x = -1037.74, y = -2738.04, z = 20.1693, h = 282.91 } },
    ["bus"] = { coords =  { x = 454.349, y = -661.036, z = 27.6534, h = 282.91 } },
    ["train"] = { coords =  { x = -206.674, y = -1015.1, z = 30.1381, h = 282.91 } },
    ["paleto"] = { coords =  { x = -215.027, y = 6218.83, z = 31.4915, h = 282.91 } },
    ["sandy"] = { coords =  { x = 1955.54, y = 3843.48, z = 32.0165, h = 282.91 } },
    ["pier"] = { coords =  { x = -1686.61, y = -1068.16, z = 13.1522, h = 282.91 } },
    ["vinewood"] = { coords =  { x = 328.52, y = -200.65, z = 54.23, h = 156.62 } },  
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
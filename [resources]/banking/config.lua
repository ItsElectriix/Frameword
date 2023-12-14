Config = {}

Config.Banks = {
    [1] = vector3(314.187, -278.621, 54.170),	
    [2] = vector3(150.266, -1040.203, 29.374),
    [3] = vector3(-1212.980, -330.841, 37.787),
    [4] = vector3(-2962.582, 482.627, 15.703),
    [5] = vector3(1175.0643310547, 2706.6435546875, 38.094036102295),  
    [6] = vector3(-351.534, -49.529, 49.042),      
    [7] = vector3(-112.19, 6469.42, 31.63),
    [8] = vector3(247.18, 222.77, 106.29),
}

Config.ParticleModelOffsets = {
    [-870868698] = vector3(0.0, -0.2, 0.75),
    [-1126237515] = vector3(-0.08, -0.0, 0.99),
    [506770882] = vector3(-0.08, -0.0, 0.99),
    [150237004] = vector3(-0.08, -0.0, 0.99),
    [-239124254] = vector3(-0.08, -0.0, 0.99),
    [-1364697528] = vector3(-0.08, -0.0, 0.99),
}

BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)
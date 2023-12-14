robbery.doLock = {} 
robbery.lootOffsets = (robbery.lootOffsets or {    
  ['entertainment unit'] = vector3(-8.29,16.00,0.79),    
  ['drawers'] = vector3(-7.21,9.16,0.79),    
  ['bookshelf'] = vector3(-1.2,16.99,1.2),    
  ['chest'] = vector3(5.4,13.71,0.79),    
  ['wardrobe'] = vector3(4.5,18.91,0.79),    
  ['bedside table'] = vector3(2.73,17.63,0.79),    
  ['bathroom cabinet'] = vector3(0.83,18.41,0.79),  
  }
)     
robbery.awake = function()
  robbery.houseData = {}
  local diff = math.random(2,6)
  for k,v in pairs(Config.Entrys) do
    robbery.houseData[v.pos] = {
      entry = v.pos,
      difficulty = diff,
      locked = (diff >= 2 and true or false),
      spawnPed = (diff >= 2 and true or false),
      spawnDog = (diff >= 4 and Config.UseDog and true or false),
      loot = robbery.generateLoot(v),
    }     
  end    
  robbery.ready = true
  robbery.update() 
end    

robbery.update = function()   
  while true do     
  Wait(1000)     
    robbery.houseLocker()   
  end 
end  

robbery.generateLoot = function(pos)    
  local loot = {}    
    for k,v in pairs(robbery.lootOffsets) do      
      loot[v] = {tab = k, looted = false}     
    end    
  return loot  
end    

robbery.getHouseData = function(source,cb,pos)    
  while not robbery.ready do 
  Wait(0); end    
  cb(robbery.houseData[pos])   
end    

robbery.tryLoot = function(source,cb,entry,pos)    
  local val = robbery.houseData[entry].loot[pos].looted    
  if not val then      
    robbery.houseData[entry].loot[pos].looted = true    
  end
  cb(val)  
end    

robbery.looted = function(tab,diff)    
  local _source = source    
  local loot = robbery.lowlootTable[tab]--robbery.lootTable[tab]    
  local pData = BJCore.Functions.GetPlayer(_source)   
  while not pData do pData = BJCore.Functions.GetPlayer(_source); Wait(10); end
  for k,v in pairs(loot) do 
    local chance = math.random(0,1000)      
    if chance <= v.chance then        
        -- if string.find(k, 'WEAPON_') then
        --   print("looted weap: "..k.." | amount: "..v.max)
        --     --pData.Functions.AddItem(k, v.max)
        --     --TriggerEvent('tac_discord:send', 'House Robbery - Weapon Dropped', pData.Data.name .. ' has found ' .. k .. ' with ' .. tostring(v.max) .. ' ammo.', 11750815)
        -- else
          local amount = math.ceil(math.random(1,v.max))
          --print("looted items: "..k.." | amount: "..amount)
          pData.Functions.AddItem(k,amount)
          for i = 1, amount, 1 do
            TriggerClientEvent('inventory:client:ItemBox', _source, BJCore.Shared.Items[k], "add")
          end          
    		  local itemData = BJCore.Shared.Items[k:lower()]
    		  TriggerClientEvent('BJCore:Notify', _source, 'You found '..tostring(amount)..'x '..itemData.label)
          TriggerEvent("bj-log:server:CreateLog", "crim", "Burglary", "green", "**"..pData.PlayerData.name .. "** has looted item: "..BJCore.Shared.Items[k].label.." | amount: "..amount)
        --end
    end    
  end  
end    

robbery.unlockHouse = function(pos)    
  robbery.houseData[pos].locked = false    
  robbery.doLock[pos] = GetGameTimer() 
end    

robbery.alert = function(_source, pos)
  TriggerClientEvent('robbery:alertPolice', _source, pos)  
end      

robbery.houseReset = function(...)       
  for key,v in pairs(robbery.houseData) do          
    local diff = math.random(2,6)          
    robbery.houseData[key].difficulty = diff          
    robbery.houseData[key].spawnDog = (diff >= 4 and true or false)          
    robbery.houseData[key].spawnPed = (diff >= 2 and true or false)          
    robbery.houseData[key].locked = true          
    for k,v in pairs(v.loot) do              
      robbery.houseData[key].loot[k].looted = false          
    end       
  end   
end    

robbery.dogOffset = vector3(-3.5, 0.0, -0.5)   
robbery.leave = function(pos)    
  local data = robbery.houseData[pos]    
  if data.spawnDog then      
    robbery.houseData[pos].spawnDog = false 
    local spawnPos = pos.xyz - robbery.dogOffset 
    TriggerClientEvent('robbery:spawnDog',source,spawnPos)    
  end  
end    

robbery.pedOffset = vector3(3.15, 16.88, -0.2)   
robbery.getPed = function(source,cb,house,pos)    
  local data = robbery.houseData[house]    
  if data.spawnPed then      
    cb(true,vector3(pos.x + robbery.pedOffset.x, pos.y + robbery.pedOffset.y, pos.z + robbery.pedOffset.z))    
  else      
    cb(false)    
  end  
end    

robbery.pedAttack = function(house,pos)    
  local _source = source     
  if not robbery.houseData[house].spawnPed then return; end    
  robbery.houseData[house].spawnPed = false    
  TriggerClientEvent('robbery:delPed',-1,house)    
  Wait(30)    
  local nP = vector3(pos.x + robbery.pedOffset.x, pos.y + robbery.pedOffset.y, pos.z + robbery.pedOffset.z)    
  robbery.alert(_source, house)
  TriggerClientEvent('robbery:pedAttacked',_source,nP)  
end    

robbery.plyConnect = function(source,pData)   
  local job = (pData and pData.job)   
end  

plyDropped = function(reason)    
end   

robbery.houseLocker = function()   
  local delTab = {}   
  local time = GetGameTimer()   
  for key,val in pairs(robbery.doLock) do     
    if (time - val) > (Config.ResetAfterMinutes * 60 * 1000) then       
      local diff = math.random(2,6)            
      robbery.houseData[key].difficulty = diff            
      robbery.houseData[key].spawnDog = (diff >= 4 and true or false)            
      robbery.houseData[key].spawnPed = (diff >= 2 and true or false)            
      robbery.houseData[key].locked = true            
      for k,v in pairs(robbery.houseData[key].loot) do                
        robbery.houseData[key].loot[k].looted = false            
      end        
    delTab[key] = true      
    end   
  end   
  for k,v in pairs(delTab) do robbery.doLock[k] = nil; end 
end  

robbery.takeLockpick = function()   
  local _source = source   
  local pData   while not pData do pData = BJCore.Functions.GetPlayer(_source); Wait(0); end   
  local i = pData.Functions.GetItemByName(Config.LockpickItemName)   
  if i and type(i) == "table" and i.amount and i.amount > 0 then     
    pData.Functions.RemoveItem(Config.LockpickItemName,1)   
  end 
end  

AddEventHandler('tac:playerLoaded', robbery.plyConnect)  
AddEventHandler('playerDropped', robbery.plyDropped)  
RegisterNetEvent('robbery:addCop')  
RegisterNetEvent('robbery:alert')  
AddEventHandler('robbery:alert', robbery.alert)   
RegisterNetEvent('robbery:pedAttack')  
AddEventHandler('robbery:pedAttack', robbery.pedAttack)   
RegisterNetEvent('robbery:leave')  
AddEventHandler('robbery:leave', robbery.leave)   
RegisterNetEvent('robbery:unlockHouse')  
AddEventHandler('robbery:unlockHouse', robbery.unlockHouse) 
RegisterNetEvent('robbery:looted')  
AddEventHandler('robbery:looted', robbery.looted)   
RegisterNetEvent('robbery:takeLockpick')  
AddEventHandler('robbery:takeLockpick', robbery.takeLockpick)    
BJCore.Functions.RegisterServerCallback('robbery:getHouseData', robbery.getHouseData)  
BJCore.Functions.RegisterServerCallback('robbery:getPed', robbery.getPed)  
BJCore.Functions.RegisterServerCallback('robbery:tryLoot', robbery.tryLoot)    
BJCore.Functions.RegisterServerCallback('robbery:getStartData', function(source, cb) while not robbery.ready do Citizen.Wait(0); end cb( (robbery.cops or 0) ) end)

Citizen.CreateThread(robbery.awake)  
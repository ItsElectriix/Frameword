function SCAddReward(rewards)
  local src = source
  local pData = BJCore.Functions.GetPlayer(src)
  if not pData then return; end
  if rewards == nil or next(rewards) == nil then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: safecracker:AddReward", src) return; end

  if rewards.CashAmount then pData.Functions.AddMoney("cash",rewards.CashAmount,"Safe loot"); end

  if rewards.Items then
    for k,v in pairs(rewards.Items) do
      local randomCount = math.random(1, rewards.ItemsAmount)
      pData.Functions.AddItem(v, randomCount)
      TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[v], "add")
      TriggerEvent("bj-log:server:CreateLog", "crim", "Safe Cracking", "green", "**"..pData.PlayerData.name .. "** has looted: "..BJCore.Shared.Items[v]['label'].." amount: "..randomCount.." from successfully cracking a safe.")
    end
  end
  
  if rewards.HiddenItems then
    for k,v in pairs(rewards.HiddenItems) do
      local rand = math.random(1, 100) / 100
      if rand < v then
        pData.Functions.AddItem(k, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[k], "add")
        TriggerEvent("bj-log:server:CreateLog", "crim", "Safe Cracking", "green", "**"..pData.PlayerData.name .. "** has looted (RARE CHANCE): "..BJCore.Shared.Items[k]['label'].." amount: 1 from successfully cracking a safe.")
      end
    end
  end
end

RegisterNetEvent('safecracker:AddReward')
AddEventHandler('safecracker:AddReward', function(rewards) SCAddReward(rewards); end)
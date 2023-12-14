BankData = {
    [1] = true,
    [2] = true, 
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true, 
    [7] = true,
    [8] = true,           
}

HackedATMs = {}

RegisterServerEvent('banking:closeBank')
AddEventHandler('banking:closeBank', function(bank)
    BankData[bank] = false
    TriggerClientEvent('banking:syncData', -1, BankData)
end)

RegisterServerEvent('banking:openBank')
AddEventHandler('banking:openBank', function(bank)
    BankData[bank] = true
    TriggerClientEvent('banking:syncData', -1, BankData)
end)

RegisterServerEvent("banking:getBankAmount")
AddEventHandler("banking:getBankAmount", function()
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    local money = pData.PlayerData.money.bank
    local name = pData.PlayerData.charinfo.firstname.." "..pData.PlayerData.charinfo.lastname
    --print("BANKSHIT")
    TriggerClientEvent("banking:money", source, money, name)
end)

RegisterServerEvent("banking:syncAtmParticles")
AddEventHandler("banking:syncAtmParticles", function(target, coords, heading)
    TriggerClientEvent('banking:atmParticles', target, coords, heading)
end)

RegisterServerEvent("banking:rewardAtmRobbery")
AddEventHandler("banking:rewardAtmRobbery", function(coords, stayedClose)
    local _source = source
    if coords == nil or type(coords) ~= "vector3" then TriggerEvent("animalcrossing:server:banPlayer", "Event abuse detected: banking:rewardAtmRobbery", src) return; end
    HackedATMs[coords] = true
    local pData = BJCore.Functions.GetPlayer(_source)
    if math.random(100) <= 80 then
        local hackValue = pData.PlayerData.metadata["hackerrep"] and pData.PlayerData.metadata["hackerrep"] or 0
        pData.Functions.SetMetaData('hackerrep', hackValue + 1)
    end
    if stayedClose then
        local amount = math.random(8, 16)
        pData.Functions.AddMoney('cash', amount, 'ATM Robbery')
        TriggerClientEvent('BJCore:Notify', _source, "You received $"..amount, 'success')
    else
        TriggerClientEvent('BJCore:Notify', _source, "No cash collected. You ran off.", 'error')
    end
    TriggerClientEvent('banking:atmHacked', -1, coords)
end) 

RegisterServerEvent("banking:deposit")
AddEventHandler("banking:deposit", function(depositAmount, depositDate)
    local _depositAmount = tonumber(depositAmount)
    --print(_depositAmount)
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    local _citizenid = pData.PlayerData.citizenid
    if _depositAmount == nil or _depositAmount <= 0 or _depositAmount > pData.PlayerData.money.cash then
        TriggerClientEvent("banking:send:alert", -1, "error", "Invalid deposit")
    else
        pData.Functions.RemoveMoney("cash",_depositAmount,"Cash deposit")
        pData.Functions.AddMoney("bank",_depositAmount,"Cash deposit")
        TriggerClientEvent("banking:send:alert", -1, "success", "Deposit was successful")
        TriggerEvent("bj-log:server:CreateLog", "banking", "Bank Deposit", "green", "**"..GetPlayerName(_source) .. "** has deposited $".._depositAmount.." to their bank account.")
        exports['ghmattimysql']:execute("INSERT INTO transactions (`citizenid`, `type`, `amount`, `date`) VALUES (@citizenid, @type, @amount, @date);", 
            {
                citizenid = _citizenid,
                type = "Deposit",
                amount = _depositAmount,
                date = depositDate

            }, function()
        end)
    end
end)

RegisterServerEvent("banking:withdraw")
AddEventHandler("banking:withdraw", function(withdrawAmount, withdrawDate)
    local _withdrawAmount = tonumber(withdrawAmount)
    --print(_withdrawAmount)
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    local _citizenid = pData.PlayerData.citizenid
    base = pData.PlayerData.money.bank
    if _withdrawAmount == nil or _withdrawAmount <= 0 or _withdrawAmount > base then
        TriggerClientEvent("banking:send:alert", -1, "error", "Invalid withdraw")
    else
        pData.Functions.AddMoney("cash",_withdrawAmount,"Cash Withdraw")
        pData.Functions.RemoveMoney("bank",_withdrawAmount,"Cash Withdraw")
        TriggerClientEvent("banking:send:alert", -1, "success", "Withdraw was successful")
        TriggerEvent("bj-log:server:CreateLog", "banking", "Bank Withdraw", "red", "**"..GetPlayerName(_source) .. "** has withdrawn $".._withdrawAmount.." from their bank account.")
        exports['ghmattimysql']:execute("INSERT INTO transactions (`citizenid`, `type`, `amount`, `date`) VALUES (@citizenid, @type, @amount, @date);", 
            {
                citizenid = _citizenid,
                type = "Withdraw",
                amount = _withdrawAmount,
                date = withdrawDate
            
            }, function()
        end)
    end
end)

RegisterServerEvent("banking:transfer")
AddEventHandler("banking:transfer", function(transferAmount, transferDate, transferName)
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    local _citizenid = pData.PlayerData.citizenid
    local target = BJCore.Functions.GetPlayer(tonumber(transferName))
    if (target == nil or target == -1) then
        --print("This is not a valid name")
        TriggerClientEvent("banking:send:alert", _source, "error", "The ID is invalid")
    else
        balance = pData.PlayerData.money.bank
        tbalance = target.PlayerData.money.bank

        if tonumber(_source) == tonumber(transferName) then
            TriggerClientEvent("banking:send:alert", _source, "error", "You cannot transfer money to yourself.")
        else
            if balance <= 0 or balance < tonumber(transferAmount) or tonumber(transferAmount) <= 0 then
                TriggerClientEvent("banking:send:alert", _source, "error", "You dont have enough money in the bank.")
            else
                pData.Functions.RemoveMoney('bank', tonumber(transferAmount), 'Bank transfer (out)')
                target.Functions.AddMoney('bank', tonumber(transferAmount), 'Bank transfer (in)')
                local targetName = target.PlayerData.charinfo.firstname.." "..target.PlayerData.charinfo.lastname;
                TriggerClientEvent("banking:send:alert", _source, "success", "Transfer successful to " .. targetName .. "")
                TriggerEvent("bj-log:server:CreateLog", "banking", "Bank Transfer", "green", "**"..GetPlayerName(_source) .. "** has transfered $"..transferAmount.." to **"..target.PlayerData.name.."** from their bank account.")
                exports['ghmattimysql']:execute("INSERT INTO transactions (`citizenid`, `type`, `amount`, `date`) VALUES (@citizenid, @type, @amount, @date);", 
                    {
                        citizenid = _citizenid,
                        type = "Transfer to " .. targetName .. "",
                        amount = transferAmount,
                        date = transferDate
            
                    }, function()
                end)
            end
        end
    end
    --print(transferAmount, transferDate, transferName)
end)

BJCore.Functions.RegisterServerCallback('banking:get:transactions', function(source, cb)
    local _source = source
    local pData = BJCore.Functions.GetPlayer(_source)
    local _citizenid = pData.PlayerData.citizenid

    exports['ghmattimysql']:execute("SELECT * FROM transactions WHERE citizenid = @citizenid ORDER BY id DESC" , 
        {
            ['@citizenid'] = _citizenid,
        }, function(transactions)
            for k,v in pairs(transactions) do
                v.amount = "$"..v.amount
            end
        cb(transactions)
    end)
end)

BJCore.Commands.Add("givecash", "Give cash to a player", {{name="id", help="Player ID"},{name="amount", help="Amount of cash"}}, true, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
    local TargetId = tonumber(args[1])
    local Target = BJCore.Functions.GetPlayer(TargetId)
    local amount = tonumber(args[2])
  
    if Target ~= nil then
        if amount ~= nil then
            if amount > 0 then
                if Player.PlayerData.money.cash >= amount and amount > 0 then
                    if TargetId ~= source then
                        TriggerClientEvent('banking:client:CheckDistance', source, TargetId, amount)
                    else
                        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You cannot give money to yourself")     
                    end
                else
                    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You dont have enough cash")
                end
            else
                TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "The amount must be higher then 0")
            end
        else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Enter an amount")
        end
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
    end    
end)

RegisterServerEvent('banking:server:giveCash')
AddEventHandler('banking:server:giveCash', function(trgtId, amount)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayer(trgtId)

    if src ~= trgtId then
        Player.Functions.RemoveMoney('cash', amount, "Cash given to "..Player.PlayerData.citizenid)
        Target.Functions.AddMoney('cash', amount, "Cash received from "..Target.PlayerData.citizenid)

        TriggerEvent("bj-log:server:CreateLog", "banking", "Give cash", "blue", "**"..GetPlayerName(src) .. "** has given $"..amount.." to **" .. GetPlayerName(trgtId) .. "**")
    
        TriggerClientEvent('BJCore:Notify', trgtId, "You received $"..amount.." from "..Player.PlayerData.charinfo.firstname, 'success')
        TriggerClientEvent('BJCore:Notify', src, "You gave $"..amount.." to "..Target.PlayerData.charinfo.firstname, 'success')
    else
        TriggerEvent("bj-admin:server:banPlayer", "Cheating")
        TriggerEvent("bj-log:server:CreateLog", "anticheat", "Banned player! ", "red", "** @everyone " ..GetPlayerName(player).. "** tried to give **"..amount.." to himself")  
    end
end)

BJCore.Functions.RegisterServerCallback("banking:GetStartData", function(source, cb) cb(BankData, HackedATMs);end)

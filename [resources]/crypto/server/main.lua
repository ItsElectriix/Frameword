BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

function updateCryptoWorth(crypto, NewWorth, src)
    if Crypto.Worth[crypto] ~= nil then
        if NewWorth ~= nil then
            local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
            local ChangeLabel = "+"
            if PercentageChange < 0 then
                ChangeLabel = "-"
                PercentageChange = (PercentageChange * -1)
            end
            if Crypto.Worth[crypto] == 0 then
                PercentageChange = 0
                ChangeLabel = ""
            end

            table.insert(Crypto.History[crypto], {
                PreviousWorth = Crypto.Worth[crypto],
                NewWorth = NewWorth
            })

            if src then
                TriggerClientEvent('BJCore:Notify', src, "You set the worth of "..Crypto.Labels[crypto].." from: ("..BJCore.Config.Currency.Symbol..Crypto.Worth[crypto].." to: "..BJCore.Config.Currency.Symbol..NewWorth..") ("..ChangeLabel.." "..PercentageChange.."%)")
            end
            Crypto.Worth[crypto] = NewWorth
            TriggerClientEvent('crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
            TriggerClientEvent('phone:client:CryptoUpdateNotification', -1, crypto, NewWorth, ""..ChangeLabel.." "..PercentageChange.."%")
            BJCore.Functions.ExecuteSql(false, "UPDATE `crypto` SET `worth` = @worth, `history` = @history WHERE `crypto` = @crypto", nil, {
                ['@worth'] = NewWorth,
                ['@history'] = json.encode(Crypto.History[crypto]),
                ['@crypto'] = crypto
            })
        elseif src then
            TriggerClientEvent('BJCore:Notify', src, "You have not given a new value.. Current worth: "..Crypto.Worth[crypto])
        end
    elseif src then
        TriggerClientEvent('BJCore:Notify', src, "This Crypto does not exist")
    end
end

function cryptoFloat(crypto)
	Citizen.Wait(7)
	local CurrWorth = Crypto.Worth[crypto]

	local behavior = math.random(1, 100)
	local luck = math.random(1, 50)
	local amount
	local change

	if luck > 45 then
		amount = math.random(100, 500)
	else
		amount = math.random(1, 100)
	end

    if behavior >= 50 then
        
		if CurrWorth + amount > Crypto.MaxValue then
			change = CurrWorth - amount
		else
			change = CurrWorth + amount
		end
	else
		if CurrWorth - amount < Crypto.MinValue then
			change = CurrWorth + amount
		else
			change = CurrWorth - amount 
		end
	end
    updateCryptoWorth(crypto, change)
    print('[^2CRYPTO^7] Updated '..crypto..' to '..BJCore.Config.Currency.Symbol..tostring(change))
end

function doCryptoTimeout()
    Citizen.SetTimeout(Crypto.UpdateTimespan, function()
        for k,v in pairs(Crypto.Labels) do
            cryptoFloat(k)
        end
        doCryptoTimeout()
    end)
end

if GetConvar("server_type", "DEV") == "LIVE" then
	doCryptoTimeout()
	print('[Crypto] Market Started')
end

BJCore.Commands.Add("setcryptoworth", "Set crypto worth", {{name="crypto", help="Name of the crypto"}, {name="Worth", help="New worth of the crypto currency"}}, false, function(source, args)
    local src = source
    local crypto = tostring(args[1])

    if crypto ~= nil then
        updateCryptoWorth(crypto, math.ceil(tonumber(args[2])), src)
        TriggerEvent("bj-log:server:CreateLog", "bans", "Crypto Updated by Command", "green", "**"..GetPlayerName(src) .. "** has updated "..crypto.." to "..math.ceil(tonumber(args[2]))..".")
    else
        TriggerClientEvent('BJCore:Notify', src, "You didnt insert a Crypto")
    end
end, "admin")

BJCore.Commands.Add("checkcryptoworth", "", {}, false, function(source, args)
    local src = source
    TriggerClientEvent('BJCore:Notify', src, "The "..Crypto.Labels["bjcoin"].." has a value of: "..BJCore.Config.Currency.Symbol..Crypto.Worth["bjcoin"])
end, "admin")

BJCore.Commands.Add("crypto", "", {}, false, function(source, args)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local MyPocket = math.ceil(Player.PlayerData.money.crypto * Crypto.Worth["bjcoin"])

    TriggerClientEvent('BJCore:Notify', src, "You have: "..Player.PlayerData.money.crypto.." "..Crypto.Labels["bjcoin"]..", with a worth of: "..BJCore.Config.Currency.Symbol..MyPocket..",-")
end, "admin")

function doFetchLoad(cb)
    for name,_ in pairs(Crypto.Worth) do
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `crypto` WHERE `crypto` = @crypto", function(result)
            if result[1] ~= nil then
                Crypto.Worth[name] = result[1].worth
                if result[1].history ~= nil then
                    Crypto.History[name] = json.decode(result[1].history)
                    if cb then
                        cb(name, result[1].worth, Crypto.History[name])
                    end
                elseif cb then
                    cb(name, result[1].worth, nil)
                end
            end
        end, { ['@crypto'] = name })
    end
end

RegisterServerEvent('crypto:server:FetchWorth')
AddEventHandler('crypto:server:FetchWorth', function()
    doFetchLoad(function(name, worth, history)
        TriggerClientEvent('crypto:client:UpdateCryptoWorth', -1, name, worth, history)
    end)
end)

Citizen.CreateThread(function()
    doFetchLoad(function(name)
        print('[Crypto] Initial load complete for '..name)
    end)
end)

RegisterServerEvent('crypto:server:ExchangeFail')
AddEventHandler('crypto:server:ExchangeFail', function()
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        Player.Functions.RemoveItem("cryptostick", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('BJCore:Notify', src, "Attempt failed, the stick crashed..", 'error', 5000)
    end
end)

RegisterServerEvent('crypto:server:Rebooting')
AddEventHandler('crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('crypto:server:GetRebootState')
AddEventHandler('crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('crypto:server:SyncReboot')
AddEventHandler('crypto:server:SyncReboot', function()
    TriggerClientEvent('crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('crypto:server:ExchangeSuccess')
AddEventHandler('crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 2000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        Player.Functions.RemoveItem("cryptostick", 1)
        Player.Functions.AddMoney('crypto', Amount)
        TriggerClientEvent('BJCore:Notify', src, "You have exchanged your Cryptostick for: "..Amount.." "..Crypto.Labels["bjcoin"].."(\'s)", "success", 3500)
        TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('phone:client:AddTransaction', src, {}, Amount.." "..Crypto.Labels["bjcoin"].."('s) credited", "Credit")
        TriggerEvent("bj-log:server:CreateLog", "banking", "Crypto Exchange", "green", "**"..Player.PlayerData.name .. "** has exchanged a Cryptostick for "..Amount.." "..Crypto.Labels["bjcoin"].."(s).")
    end
end)

BJCore.Functions.RegisterServerCallback('crypto:server:HasSticky', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("cryptostick")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

BJCore.Functions.RegisterServerCallback('crypto:server:GetCryptoData', function(source, cb, name)
    local Player = BJCore.Functions.GetPlayer(source)
    local CryptoData = {
        History = Crypto.History[name],
        Worth = Crypto.Worth[name],
        Portfolio = Player.PlayerData.money.crypto,
        WalletId = Player.PlayerData.metadata["walletid"],
    }

    cb(CryptoData)
end)

BJCore.Functions.RegisterServerCallback('crypto:server:BuyCrypto', function(source, cb, data)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.bank >= tonumber(data.Price) then
        local CryptoData = {
            History = Crypto.History["bjcoin"],
            Worth = Crypto.Worth["bjcoin"],
            Portfolio = Player.PlayerData.money.crypto + tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('bank', tonumber(data.Price))
        TriggerClientEvent('phone:client:AddTransaction', source, data, "You bought "..tonumber(data.Coins).." "..Crypto.Labels["bjcoin"].."('s) for "..BJCore.Config.Currency.Symbol..tonumber(data.Price), "Credit")
        Player.Functions.AddMoney('crypto', tonumber(data.Coins))
        TriggerEvent("bj-log:server:CreateLog", "banking", "Crypto Buy", "green", "**"..Player.PlayerData.name .. "** has purchased "..data.Coins.." "..Crypto.Labels["bjcoin"].."(s) for "..BJCore.Config.Currency.Symbol..(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end   
end)

BJCore.Functions.RegisterServerCallback('crypto:server:SellCrypto', function(source, cb, data)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["bjcoin"],
            Worth = Crypto.Worth["bjcoin"],
            Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('phone:client:AddTransaction', source, data, "You sold "..tonumber(data.Coins).." "..Crypto.Labels["bjcoin"].."('s) for "..BJCore.Config.Currency.Symbol..tonumber(data.Price), "Sale")
        Player.Functions.AddMoney('bank', tonumber(data.Price))
        TriggerEvent("bj-log:server:CreateLog", "banking", "Crypto Sell", "green", "**"..Player.PlayerData.name .. "** has sold "..data.Coins.." "..Crypto.Labels["bjcoin"].."(s) for "..BJCore.Config.Currency.Symbol..(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end
end)

BJCore.Functions.RegisterServerCallback('crypto:server:TransferCrypto', function(source, cb, data)
    local Player = BJCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE metadata->'$.walletid' = @walletId OR charinfo->'$.account' = @walletId", function(result)
            if result[1] ~= nil then
                local CryptoData = {
                    History = Crypto.History["bjcoin"],
                    Worth = Crypto.Worth["bjcoin"],
                    Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
                    WalletId = Player.PlayerData.metadata["walletid"],
                }
                Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('phone:client:AddTransaction', source, data, "You transfered "..tonumber(data.Coins).." "..Crypto.Labels["bjcoin"].."('s)", "Sale")
                local Target = BJCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

                if Target ~= nil then
                    Target.Functions.AddMoney('crypto', tonumber(data.Coins))
                    TriggerClientEvent('phone:client:AddTransaction', Target.PlayerData.source, data, "There were "..tonumber(data.Coins).." "..Crypto.Labels["bjcoin"].."(s) credited", "Credit")
                else
                    MoneyData = json.decode(result[1].money)
                    MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                    BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = @money WHERE `citizenid` = @citizenid", nil, {
                        ['@money'] = json.encode(MoneyData),
                        ['@citizenid'] = result[1].citizenid
                    })
                end
                TriggerEvent("bj-log:server:CreateLog", "banking", "Crypto Transfer", "green", "**"..Player.PlayerData.name .. "** has transfered "..data.Coins.." "..Crypto.Labels["bjcoin"].."(s) to **"..result[1].name.."**")
                cb(CryptoData)
            else
                cb("notvalid")
            end
        end, {
            ['@walletId'] = data.WalletId
        })
    else
        cb("notenough")
    end
end)

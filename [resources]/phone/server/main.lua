BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

-- Code

local BJPhone = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}

RegisterServerEvent('phone:server:AddAdvert')
AddEventHandler('phone:server:AddAdvert', function(msg)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    local CitizenId = Player.PlayerData.citizenid

    if Adverts[CitizenId] ~= nil then
        Adverts[CitizenId].message = msg
        Adverts[CitizenId].name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname
        Adverts[CitizenId].number = Player.PlayerData.charinfo.phone
    else
        Adverts[CitizenId] = {
            message = msg,
            name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
            number = Player.PlayerData.charinfo.phone,
        }
    end

    TriggerClientEvent('phone:client:UpdateAdverts', -1, Adverts, "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname)
end)

function GetOnlineStatus(number)
    local Target = BJCore.Functions.GetPlayerByPhone(number)
    local retval = false
    if Target ~= nil then retval = true end
    return retval
end

BJCore.Functions.RegisterServerCallback('phone:server:SyncTweets', function(source, cb)
    cb(Tweets)
end)

RegisterServerEvent('phone:server:AddTweet')
AddEventHandler('phone:server:AddTweet', function(NewTweet)
    local src = source
    table.insert(Tweets, NewTweet)
    local Player = BJCore.Functions.GetPlayer(src)
    TriggerEvent("bj-log:server:CreateLog", "admin", "New Tweet", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.cid..") has tweeted: "..BJCore.Common.Dump(NewTweet.message)..".")
    TriggerClientEvent('phone:client:AddTweet', -1, src, NewTweet)
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetContacts', function(source, cb)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM player_contacts WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `name` ASC", function(result)
        local Contacts = {}
        if result[1] ~= nil then
            for k, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end
            
            cb(result)
        else
            cb({})
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetPhoneData', function(source, cb)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
            Invoices = {},
            Garage = {},
            Mails = {},
            Adverts = {},
            CryptoTransactions = {},
            InstalledApps = Player.PlayerData.metadata["phonedata"].InstalledApps,
        }

        PhoneData.Adverts = Adverts

        BJCore.Functions.ExecuteSql(false, "SELECT * FROM player_contacts WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `name` ASC", function(result)
            local Contacts = {}
            if result[1] ~= nil then
                for k, v in pairs(result) do
                    v.status = GetOnlineStatus(v.number)
                end
                
                PhoneData.PlayerContacts = result
            end

            BJCore.Functions.ExecuteSql(false, "SELECT * FROM phone_invoices WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(invoices)
                if invoices[1] ~= nil then
                    for k, v in pairs(invoices) do
                        local Ply = BJCore.Functions.GetPlayerByCitizenId(v.sender)
                        if Ply ~= nil then
                            v.number = Ply.PlayerData.charinfo.phone
                            v.name = Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname
                        else
                            BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                                if res[1] ~= nil then
                                    res[1].charinfo = json.decode(res[1].charinfo)
                                    v.number = res[1].charinfo.phone
                                    v.name = res[1].charinfo.firstname..' '..res[1].charinfo.lastname
                                else
                                    v.number = nil
                                    v.name = 'Unknown'
                                end
                            end)
                        end

                        v.jobLabel = 'Personal'
                        if v.job and BJCore.Shared.Jobs[v.job] then
                            v.jobLabel = BJCore.Shared.Jobs[v.job].label
                        end
                    end
                    PhoneData.Invoices = invoices
                end
                
                BJCore.Functions.ExecuteSql(false, "SELECT * FROM player_vehicles WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(garageresult)
                    if garageresult[1] ~= nil then
                        -- for k, v in pairs(garageresult) do
                        --     if (BJCore.Shared.Vehicles[v.vehicle] ~= nil) and (Garages[v.garage] ~= nil) then
                        --         v.garage = Garages[v.garage].label
                        --         v.vehicle = BJCore.Shared.Vehicles[v.vehicle].name
                        --         v.brand = BJCore.Shared.Vehicles[v.vehicle].brand
                        --     end
                        -- end

                        PhoneData.Garage = garageresult
                    end
                    
                    BJCore.Functions.ExecuteSql(false, "SELECT * FROM phone_messages WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(messages)
                        if messages ~= nil and next(messages) ~= nil then 
                            PhoneData.Chats = messages
                        end

                        if AppAlerts[Player.PlayerData.citizenid] ~= nil then 
                            PhoneData.Applications = AppAlerts[Player.PlayerData.citizenid]
                        end

                        if MentionedTweets[Player.PlayerData.citizenid] ~= nil then 
                            PhoneData.MentionedTweets = MentionedTweets[Player.PlayerData.citizenid]
                        end

                        if Hashtags ~= nil and next(Hashtags) ~= nil then
                            PhoneData.Hashtags = Hashtags
                        end

                        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
                            if mails[1] ~= nil then
                                for k, v in pairs(mails) do
                                    if mails[k].button ~= nil then
                                        mails[k].button = json.decode(mails[k].button)
                                    end
                                end
                                PhoneData.Mails = mails
                            end

                            BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `crypto_transactions` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(transactions)
                                if transactions[1] ~= nil then
                                    for _, v in pairs(transactions) do
                                        table.insert(PhoneData.CryptoTransactions, {
                                            TransactionTitle = v.title,
                                            TransactionMessage = v.message,
                                        })
                                    end
                                end
    
                                cb(PhoneData)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetCallState', function(source, cb, ContactData)
    local Target = BJCore.Functions.GetPlayerByPhone(ContactData.number)

    if Target ~= nil then
        if Calls[Target.PlayerData.citizenid] ~= nil then
            if Calls[Target.PlayerData.citizenid].inCall then
                cb(false, true)
            else
                cb(true, true)
            end
        else
            cb(true, true)
        end
    else
        cb(false, false)
    end
end)

RegisterServerEvent('phone:server:SetCallState')
AddEventHandler('phone:server:SetCallState', function(bool)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)

    if Calls[Ply.PlayerData.citizenid] ~= nil then
        Calls[Ply.PlayerData.citizenid].inCall = bool
    else
        Calls[Ply.PlayerData.citizenid] = {}
        Calls[Ply.PlayerData.citizenid].inCall = bool
    end
end)

RegisterServerEvent('phone:server:RemoveMail')
AddEventHandler('phone:server:RemoveMail', function(MailId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, 'DELETE FROM `player_mails` WHERE `mailid` = "'..MailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(100, function()
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('phone:client:UpdateMails', src, mails)
        end)
    end)
end)

function GenerateMailId()
    return math.random(111111, 999999)
end

RegisterServerEvent('phone:server:sendNewMail')
AddEventHandler('phone:server:sendNewMail', function(mailData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    if mailData.button == nil then
        exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0')", {
	        ['@citizenid'] = Player.PlayerData.citizenid,
        	['@sender'] = mailData.sender,
			['@subject'] = mailData.subject,
			['@message'] = mailData.message,
    	    ['@mailid'] = GenerateMailId()
	    }, function(data)end)
    else
		exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0', @button)", {
	        ['@citizenid'] = Player.PlayerData.citizenid,
        	['@sender'] = mailData.sender,
			['@subject'] = mailData.subject,
			['@message'] = mailData.message,
    	    ['@mailid'] = GenerateMailId(),
			['@button'] = json.encode(mailData.button)
	    }, function(data)end)
    end
    TriggerClientEvent('phone:client:NewMailNotify', src, mailData)
    SetTimeout(200, function()
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('phone:server:sendNewMailToOffline')
AddEventHandler('phone:server:sendNewMailToOffline', function(citizenid, mailData)
    local Player = BJCore.Functions.GetPlayerByCitizenId(citizenid)

    if Player ~= nil then
        local src = Player.PlayerData.source

        if mailData.button == nil then
            exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0')", {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId()
            }, function(data)end)            
            TriggerClientEvent('phone:client:NewMailNotify', src, mailData)
        else
            exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0', @button)", {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@button'] = json.encode(mailData.button)
            }, function(data)end)            
            TriggerClientEvent('phone:client:NewMailNotify', src, mailData)
        end

        SetTimeout(200, function()
            BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
                if mails[1] ~= nil then
                    for k, v in pairs(mails) do
                        if mails[k].button ~= nil then
                            mails[k].button = json.decode(mails[k].button)
                        end
                    end
                end
        
                TriggerClientEvent('phone:client:UpdateMails', src, mails)
            end)
        end)
    else
        if mailData.button == nil then
            exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0')", {
                ['@citizenid'] = citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId()
            }, function(data)end)            
        else
            exports['ghmattimysql']:execute("INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, '0', @button)", {
                ['@citizenid'] = citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@button'] = json.encode(mailData.button)
            }, function(data)end)
        end
    end
end)

RegisterServerEvent('phone:server:sendNewEventMail')
AddEventHandler('phone:server:sendNewEventMail', function(citizenid, mailData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    
    if mailData.button == nil then
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
    else
        BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
    end
    SetTimeout(200, function()
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('phone:server:ClearButtonData')
AddEventHandler('phone:server:ClearButtonData', function(mailId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, 'UPDATE `player_mails` SET `button` = "" WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(200, function()
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('phone:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('phone:server:MentionedPlayer')
AddEventHandler('phone:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.charinfo.firstname == firstName and Player.PlayerData.charinfo.lastname == lastName) then
                BJPhone.SetPhoneAlerts(Player.PlayerData.citizenid, "twitter")
                BJPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('phone:client:GetMentioned', Player.PlayerData.source, TweetMessage, AppAlerts[Player.PlayerData.citizenid]["twitter"])
            else
                BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE @firstname AND `charinfo` LIKE @lastname", function(result)
                    if result[1] ~= nil then
                        local MentionedTarget = result[1].citizenid
                        BJPhone.SetPhoneAlerts(MentionedTarget, "twitter")
                        BJPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                    end
                end, {
                    ['@firstname'] = '%'..firstName..'%',
                    ['@lastname'] = '%'..lastName..'%'
                })
            end
        end
	end
end)

RegisterServerEvent('phone:server:CallContact')
AddEventHandler('phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)
    local Target = BJCore.Functions.GetPlayerByPhone(TargetData.number)

    if Target ~= nil then
        TriggerClientEvent('phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
    end
end)

function GetInvoiceTitle(title, job, sender)
    if title then
        return title
    elseif job then
        if job and BJCore.Shared.Jobs[job] then
            return 'Payment Request ('..BJCore.Shared.Jobs[job].label..')'
        end
        return 'Payment Request ('..job..')'
    elseif sender then
        return 'Payment Request ('..sender..')'
    else
        return ''
    end
end

function GetInvoiceDetail(title, job, citizenid, amount)
    local res = ('Invoice Title: %s<br />Amount: %s%s'):format(GetInvoiceTitle(title, job, citizenid), BJCore.Config.Currency.Symbol, tostring(amount))

    if job and BJCore.Shared.Jobs[job] then
        res = res..'<br/>Company: '..BJCore.Shared.Jobs[job].label
    end
    return res
end

function InvoiceSuccessfullyPaid(data, Player)
    TriggerEvent('phone:server:sendNewMailToOffline', data.sender, {
        sender = 'Notifications - Bank',
        subject = "Automated: Invoice Paid",
        message = ('Hello,<br /><br />This is an automated notification that your sent invoice has been paid. Please see invoice details below.<br /><br />Invoice Recipient: %s %s<br />%s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, GetInvoiceDetail(data.title, data.job, data.sender, data.amount))
    })
end

function RefreshInvoices(citizenid, cb)
    local Invoices = {}
    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..citizenid.."'", function(invoices)
        if invoices[1] ~= nil then
            for k, v in pairs(invoices) do
                local Target = BJCore.Functions.GetPlayerByCitizenId(v.sender)
                if Target ~= nil then
                    v.number = Target.PlayerData.charinfo.phone
                    v.name = Target.PlayerData.charinfo.firstname..' '..Target.PlayerData.charinfo.lastname
                else
                    BJCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                        if res[1] ~= nil then
                            res[1].charinfo = json.decode(res[1].charinfo)
                            v.number = res[1].charinfo.phone
                            v.name = res[1].charinfo.firstname..' '..res[1].charinfo.lastname
                        else
                            v.number = nil
                            v.name = 'Unknown'
                        end
                    end)
                end

                v.jobLabel = 'Personal'
                if v.job and BJCore.Shared.Jobs[v.job] then
                    v.jobLabel = BJCore.Shared.Jobs[v.job].label
                end
            end
            Invoices = invoices
        end
        cb(Invoices)
    end)
end

BJCore.Functions.RegisterServerCallback('phone:server:SendInvoice', function(source, cb, data)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)
    data.amount = tonumber(data.amount)
    if data.amount < 1 then
        cb('Invalid amount')
        return
    end

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE @iban", function(result)
        if result[1] ~= nil then
            local receiver = BJCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

            BJCore.Functions.ExecuteSql(true, "INSERT INTO phone_invoices (citizenid, sender, job, title, amount) VALUES (@citizenid, @sender, @job, @title, @amount)", function() end, {
                ['@citizenid'] = result[1].citizenid,
                ['@sender'] = Ply.PlayerData.citizenid,
                ['@job'] = data.job,
                ['@title'] = data.title,
                ['@amount'] = data.amount
            })

            if receiver ~= nil then
                RefreshInvoices(result[1].citizenid, function(invs, additionalData)
                    TriggerClientEvent('phone:client:UpdateInvoices', receiver.PlayerData.source, invs)
                end)
            end
            TriggerEvent('phone:server:sendNewMailToOffline', result[1].citizenid, {
                sender = 'Updates - Bank',
                subject = "Automated: Invoice Received",
                message = ('Hello,<br /><br />This is an automated notification that you have received an invoice. Please see invoice details below.<br /><br />Invoice Sender: %s %s<br />%s'):format(Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname, GetInvoiceDetail(data.title, data.job, Ply.PlayerData.citizenid, data.amount))
            })
            cb(true)
        else
            cb('Invalid account number')
        end
    end, {
        ['@iban'] = '%'..data.recipient..'%'
    })
end)

BJCore.Functions.RegisterServerCallback('phone:server:PayInvoice', function(source, cb, data) --, sender, job, amount, invoiceId)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)
    local Trgt = BJCore.Functions.GetPlayerByCitizenId(data.sender)
    data.amount = tonumber(data.amount)
    if data.amount < 0 then data.amount = 0; end

    if data.job ~= nil and exports.utils:DoesMoneysafeExist(data.job) then
        if Ply.PlayerData.money.bank >= data.amount then
            Ply.Functions.RemoveMoney('bank', data.amount, "paid-invoice")
            TriggerEvent('moneysafe:server:DepositMoneyFromInvoice', data.job, data.amount, src, data.sender)
            BJCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `id` = '"..data.invoiceId.."'")
            InvoiceSuccessfullyPaid(data, Ply)
            RefreshInvoices(Ply.PlayerData.citizenid, function(invs)
                cb(true, invs)
            end)
        else
            cb(false)
        end
    elseif Trgt ~= nil then
        if Ply.PlayerData.money.bank >= data.amount then
            Ply.Functions.RemoveMoney('bank', data.amount, "paid-invoice")
            Trgt.Functions.AddMoney('bank', data.amount, "paid-invoice")

            BJCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `id` = '"..data.invoiceId.."'")
            InvoiceSuccessfullyPaid(data, Ply)
            RefreshInvoices(Ply.PlayerData.citizenid, function(invs)
                cb(true, invs)
            end)
        else
            cb(false)
        end
    else
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..data.sender.."'", function(result)
            if result[1] ~= nil then
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = math.ceil((moneyInfo.bank + data.amount))
                BJCore.Functions.ExecuteSql(true, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..data.sender.."'")
                Ply.Functions.RemoveMoney('bank', data.amount, "paid-invoice")
                
                BJCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `id` = '"..data.invoiceId.."'")
                InvoiceSuccessfullyPaid(data, Ply)
                RefreshInvoices(Ply.PlayerData.citizenid, function(invs)
                    cb(true, invs)
                end)
            else
                cb(false)
            end
        end)
    end
end)

BJCore.Functions.RegisterServerCallback('phone:server:DeclineInvoice', function(source, cb, data)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)
    local Invoices = {}

    TriggerEvent('phone:server:sendNewMailToOffline', data.sender, {
        sender = 'Notifications - Bank',
        subject = "Automated: Declined Invoice",
        message = ('Hello,<br /><br />This is an automated notification that your sent invoice has been declined. Please see invoice details below.<br /><br />Invoice Recipient: %s %s<br />%s'):format(Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname, GetInvoiceDetail(data.title, data.job, data.sender, data.amount))
    })

    BJCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `id` = '"..data.invoiceId.."'")
    RefreshInvoices(Ply.PlayerData.citizenid, function(invs)
        cb(true, invs)
    end)
end)

RegisterServerEvent('phone:server:UpdateHashtags')
AddEventHandler('phone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
        table.insert(Hashtags[Handle].messages, messageData)
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(Hashtags[Handle].messages, messageData)
    end
    TriggerClientEvent('phone:client:UpdateHashtags', -1, Handle, messageData)
end)

BJPhone.AddMentionedTweet = function(citizenid, TweetData)
    if MentionedTweets[citizenid] == nil then MentionedTweets[citizenid] = {} end
    table.insert(MentionedTweets[citizenid], TweetData)
end

BJPhone.SetPhoneAlerts = function(citizenid, app, alerts)
    if citizenid ~= nil and app ~= nil then
        if AppAlerts[citizenid] == nil then
            AppAlerts[citizenid] = {}
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = alerts
                end
            end
        else
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 1
                else
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 0
                end
            end
        end
    end
end

BJCore.Functions.RegisterServerCallback('phone:server:GetContactPictures', function(source, cb, Chats)
    for k, v in pairs(Chats) do
        local Player = BJCore.Functions.GetPlayerByPhone(v.number)
        
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..v.number.."%'", function(result)
            if result[1] ~= nil then
                local MetaData = json.decode(result[1].metadata)

                if MetaData.phone.profilepicture ~= nil then
                    v.picture = MetaData.phone.profilepicture
                else
                    v.picture = "default"
                end
            end
        end)
    end
    SetTimeout(100, function()
        cb(Chats)
    end)
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetContactPicture', function(source, cb, Chat)
    local Player = BJCore.Functions.GetPlayerByPhone(Chat.number)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..Chat.number.."%'", function(result)
        local MetaData = json.decode(result[1].metadata)

        if MetaData.phone.profilepicture ~= nil then
            Chat.picture = MetaData.phone.profilepicture
        else
            Chat.picture = "default"
        end
    end)
    SetTimeout(100, function()
        cb(Chat)
    end)
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetPicture', function(source, cb, number)
    local Player = BJCore.Functions.GetPlayerByPhone(number)
    local Picture = nil

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..number.."%'", function(result)
        if result[1] ~= nil then
            local MetaData = json.decode(result[1].metadata)

            if MetaData.phone.profilepicture ~= nil then
                Picture = MetaData.phone.profilepicture
            else
                Picture = "default"
            end
            cb(Picture)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('phone:server:SetPhoneAlerts')
AddEventHandler('phone:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local CitizenId = BJCore.Functions.GetPlayer(src).citizenid
    BJPhone.SetPhoneAlerts(CitizenId, app, alerts)
end)

RegisterServerEvent('phone:server:UpdateTweets')
AddEventHandler('phone:server:UpdateTweets', function(NewTweets, TweetData)
    Tweets = NewTweets
    local TwtData = TweetData
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    TriggerEvent("bj-log:server:CreateLog", "admin", "New Tweet", "green", "**"..Player.PlayerData.name .. "** ("..Player.PlayerData.cid..") has tweeted: "..BJCore.Common.Dump(TweetData.message)..".")
    TriggerClientEvent('phone:client:UpdateTweets', -1, src, Tweets, TwtData)
end)

RegisterServerEvent('phone:server:TransferMoney')
AddEventHandler('phone:server:TransferMoney', function(iban, amount)
    local src = source
    local sender = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
        if result[1] ~= nil then
            local recieverSteam = BJCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

            if recieverSteam ~= nil then
                local PhoneItem = recieverSteam.Functions.GetItemByName("phone")
                recieverSteam.Functions.AddMoney('bank', amount, "phone-transfered-from-"..sender.PlayerData.citizenid)
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered-to-"..recieverSteam.PlayerData.citizenid)

                if PhoneItem ~= nil then
                    TriggerClientEvent('phone:client:TransferMoney', recieverSteam.PlayerData.source, amount, recieverSteam.PlayerData.money.bank)
                end
            else
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = round((moneyInfo.bank + amount))
                BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered")
            end
        else
            TriggerClientEvent('BJCore:Notify', src, "This account number doesn't exist", "error")
        end
    end)
end)

RegisterServerEvent('phone:server:EditContact')
AddEventHandler('phone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    BJCore.Functions.ExecuteSql(false, "UPDATE `player_contacts` SET `name` = '"..newName.."', `number` = '"..newNumber.."', `iban` = '"..newIban.."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `name` = '"..oldName.."' AND `number` = '"..oldNumber.."'")
end)

RegisterServerEvent('phone:server:RemoveContact')
AddEventHandler('phone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    
    exports['ghmattimysql']:execute("DELETE FROM `player_contacts` WHERE `name` = @name AND `number` = @number AND `citizenid` = @citizenid", {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@name'] = tostring(Name),
        ['@number'] = tostring(Number)
    }, function(data)end)
end)

RegisterServerEvent('phone:server:AddNewContact')
AddEventHandler('phone:server:AddNewContact', function(name, number, iban)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute("INSERT INTO `player_contacts` (`citizenid`, `name`, `number`, `iban`) VALUES (@citizenid, @name, @number, @iban)", {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@name'] = tostring(name),
        ['@number'] = tostring(number),
        ['@iban'] = tostring(iban)
    }, function(data)end)
end)

RegisterServerEvent('phone:server:UpdateMessages')
AddEventHandler('phone:server:UpdateMessages', function(ChatMessages, ChatNumber, ChatTS, New)
    local src = source
    local SenderData = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..ChatNumber.."%'", function(Player)
        if Player[1] ~= nil then
            Player[1].charinfo = json.decode(Player[1].charinfo)
            local TargetData = BJCore.Functions.GetPlayerByCitizenId(Player[1].citizenid)

            exports['ghmattimysql']:execute("INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES (@citizenid, @number, @messages) ON DUPLICATE KEY UPDATE messages = @messages", {
                ['@citizenid'] = Player[1].citizenid,
                ['@number'] = SenderData.PlayerData.charinfo.phone,
                ['@messages'] = json.encode(ChatMessages)
            }, function(data)end)

            exports['ghmattimysql']:execute("INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES (@citizenid, @number, @messages) ON DUPLICATE KEY UPDATE messages = @messages", {
                ['@citizenid'] = SenderData.PlayerData.citizenid,
                ['@number'] = Player[1].charinfo.phone,
                ['@messages'] = json.encode(ChatMessages)
            }, function(data)end)

            if TargetData ~= nil then
                TriggerClientEvent('phone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, ChatTS, false)
            end
        end
    end)
end)

RegisterServerEvent('phone:server:AddRecentCall')
AddEventHandler('phone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = BJCore.Functions.GetPlayer(src)

    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour..":"..Minute

    TriggerClientEvent('phone:client:AddRecentCall', src, data, label, type)

    local Trgt = BJCore.Functions.GetPlayerByPhone(data.number)
    if Trgt ~= nil then
        TriggerClientEvent('phone:client:AddRecentCall', Trgt.PlayerData.source, {
            name = Ply.PlayerData.charinfo.firstname .. " " ..Ply.PlayerData.charinfo.lastname,
            number = Ply.PlayerData.charinfo.phone,
            anonymous = anonymous
        }, label, "outgoing")
    end
end)

RegisterServerEvent('phone:server:CancelCall')
AddEventHandler('phone:server:CancelCall', function(ContactData)
    local Ply = BJCore.Functions.GetPlayerByPhone(ContactData.TargetData.number)

    if Ply ~= nil then
        if not Config.UsingSaltyChat then
            exports['voice']:setPlayerCall(source, 0)
            exports['voice']:setPlayerCall(Ply.PlayerData.source, 0)
        else
            exports.saltychat:EndCall(source, Ply.PlayerData.source)
        end
        TriggerClientEvent('phone:client:CancelCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('phone:server:AnswerCall')
AddEventHandler('phone:server:AnswerCall', function(CallData)
    local _source = tonumber(source)
    local Ply = BJCore.Functions.GetPlayerByPhone(CallData.TargetData.number)

    if Ply ~= nil then
        if not Config.UsingSaltyChat then
            exports['voice']:setPlayerCall(_source, CallData.CallId)
            exports['voice']:setPlayerCall(Ply.PlayerData.source, CallData.CallId)
        else
            exports.saltychat:EstablishCall(_source, Ply.PlayerData.source)
        end
        TriggerClientEvent('phone:client:AnswerCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('phone:server:SaveMetaData')
AddEventHandler('phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        local MetaData = json.decode(result[1].metadata)
        MetaData.phone = MData
        BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `metadata` = '"..json.encode(MetaData).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
    end)

    Player.Functions.SetMetaData("phone", MData)
end)

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

BJCore.Functions.RegisterServerCallback('phone:server:FetchResult', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}

    local query = 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'"'
    -- Split on " " and check each var individual
    local searchParameters = SplitStringToArray(search)
    
    -- Construct query dynamicly for individual parm check
    if #searchParameters > 1 then
        query = query .. ' OR `charinfo` LIKE "%'..searchParameters[1]..'%"'
        for i = 2, #searchParameters do
            query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] ..'%"'
        end
    else
        query = query .. ' OR `charinfo` LIKE "%'..search..'%"'
    end
    
    BJCore.Functions.ExecuteSql(false, query, function(result)
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `apartments`', function(ApartmentData)
            for k, v in pairs(ApartmentData) do
                ApaData[v.citizenid] = ApartmentData[k]
            end

            if result[1] ~= nil then
                for k, v in pairs(result) do
                    local charinfo = json.decode(v.charinfo)
                    local metadata = json.decode(v.metadata)
                    local appiepappie = {}
                    if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
                        appiepappie = ApaData[v.citizenid]
                    end
                    table.insert(searchData, {
                        citizenid = v.citizenid,
                        firstname = charinfo.firstname,
                        lastname = charinfo.lastname,
                        birthdate = charinfo.birthdate,
                        phone = charinfo.phone,
                        nationality = charinfo.nationality,
                        gender = charinfo.gender,
                        warrant = false,
                        driverlicense = metadata["licences"]["driver"],
                        appartmentdata = appiepappie,
                    })
                end
                cb(searchData)
            else
                cb(nil)
            end
        end)
    end)
end)

function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        table.insert(retval, i)
    end
    return retval
end

BJCore.Functions.RegisterServerCallback('phone:server:GetVehicleSearchResults', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `citizenid` = "'..search..'"', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                BJCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].citizenid..'"', function(player)
                    if player[1] ~= nil then 
                        local charinfo = json.decode(player[1].charinfo)
                        local vehicleInfo = BJCore.Shared.Vehicles[result[k].vehicle]
                        if vehicleInfo ~= nil then 
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = vehicleInfo["name"]
                            })
                        else
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = "Name not found.."
                            })
                        end
                    end
                end)
            end
        else
            if GeneratedPlates[search] ~= nil then
                table.insert(searchData, {
                    plate = GeneratedPlates[search].plate,
                    status = GeneratedPlates[search].status,
                    owner = GeneratedPlates[search].owner,
                    citizenid = GeneratedPlates[search].citizenid,
                    label = "Brand unknown.."
                })
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[search] = {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                table.insert(searchData, {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                    label = "Brand unknown.."
                })
            end
        end
        cb(searchData)
    end)
end)

BJCore.Functions.RegisterServerCallback('phone:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then 
        BJCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` = "'..plate..'"', function(result)
            if result[1] ~= nil then
                BJCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].citizenid..'"', function(player)
                    local charinfo = json.decode(player[1].charinfo)
                    vehicleData = {
                        plate = plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[1].citizenid,
                    }
                end)
            elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then 
                vehicleData = GeneratedPlates[plate]
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[plate] = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                vehicleData = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
            end
            cb(vehicleData)
        end)
    else
        TriggerClientEvent('BJCore:Notify', src, "No vehicle nearby..", "error")
        cb(nil)
    end
end)

function GenerateOwnerName()
    local names = {
        [1] = { name = "Jan Bloksteen", citizenid = "DSH091G93" },
        [2] = { name = "Jay Dendam", citizenid = "AVH09M193" },
        [3] = { name = "Ben Klaariskees", citizenid = "DVH091T93" },
        [4] = { name = "Karel Bakker", citizenid = "GZP091G93" },
        [5] = { name = "Klaas Adriaan", citizenid = "DRH09Z193" },
        [6] = { name = "Nico Wolters", citizenid = "KGV091J93" },
        [7] = { name = "Mark Hendrickx", citizenid = "ODF09S193" },
        [8] = { name = "Bert Johannes", citizenid = "KSD0919H3" },
        [9] = { name = "Karel de Grote", citizenid = "NDX091D93" },
        [10] = { name = "Jan Pieter", citizenid = "ZAL0919X3" },
        [11] = { name = "Huig Roelink", citizenid = "ZAK09D193" },
        [12] = { name = "Corneel Boerselman", citizenid = "POL09F193" },
        [13] = { name = "Hermen Klein Overmeen", citizenid = "TEW0J9193" },
        [14] = { name = "Bart Rielink", citizenid = "YOO09H193" },
        [15] = { name = "Antoon Henselijn", citizenid = "QBC091H93" },
        [16] = { name = "Aad Keizer", citizenid = "YDN091H93" },
        [17] = { name = "Thijn Kiel", citizenid = "PJD09D193" },
        [18] = { name = "Henkie Krikhaar", citizenid = "RND091D93" },
        [19] = { name = "Teun Blaauwkamp", citizenid = "QWE091A93" },
        [20] = { name = "Dries Stielstra", citizenid = "KJH0919M3" },
        [21] = { name = "Karlijn Hensbergen", citizenid = "ZXC09D193" },
        [22] = { name = "Aafke van Daalen", citizenid = "XYZ0919C3" },
        [23] = { name = "Door Leeferds", citizenid = "ZYX0919F3" },
        [24] = { name = "Nelleke Broedersen", citizenid = "IOP091O93" },
        [25] = { name = "Renske de Raaf", citizenid = "PIO091R93" },
        [26] = { name = "Krisje Moltman", citizenid = "LEK091X93" },
        [27] = { name = "Mirre Steevens", citizenid = "ALG091Y93" },
        [28] = { name = "Joosje Kalvenhaar", citizenid = "YUR09E193" },
        [29] = { name = "Mirte Ellenbroek", citizenid = "SOM091W93" },
        [30] = { name = "Marlieke Meilink", citizenid = "KAS09193" },
    }
    return names[math.random(1, #names)]
end

BJCore.Functions.RegisterServerCallback('phone:server:GetGarageVehicles', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    local Vehicles = {}

    BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                local VehicleData = BJCore.Shared.Vehicles[v.vehicle]

                if not VehicleData or VehicleData == nil then
                    VehicleData = BJCore.Shared.Vehicles[v.vehicle]
                end

                local VehicleGarage = "None"
                if v.garage ~= nil and v.type ~= nil then
                    VehicleGarage = exports["garages"]:GetGarageLabel(v.type, v.garage)
                end

                local VehicleState = "Out/Hayes Depot"
                if v.state == 1 then
                    VehicleState = "In"
                elseif v.state == 2 then
                    VehicleState = "Police Impound"
                elseif v.state == 3 then
                    VehicleState = "Repossessed"
                end

                local vehdata = {}

                if VehicleData ~= nil and VehicleData["brand"] ~= nil then
                    vehdata = {
                        fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                        brand = VehicleData["brand"],
                        model = VehicleData["name"],
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                elseif VehicleData ~= nil and VehicleData["name"] ~= nil then
                    vehdata = {
                        fullname = VehicleData["name"],
                        brand = VehicleData["name"],
                        model = VehicleData["name"],
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                else
                    print("[PHONE] - Plate: "..v.plate.." has missing data in BJCore.Shared.Vehicles and/or BJCore.Shared.Vehicles")
                    vehdata = {
                        fullname = "Unkown Name",
                        brand = "Unknown Brand",
                        model = "Unknown Model",
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }                    
                end

                table.insert(Vehicles, vehdata)
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

BJCore.Functions.RegisterServerCallback('phone:server:HasPhone', function(source, cb)
    local Player = BJCore.Functions.GetPlayer(source)
    
    if Player ~= nil then
        local HasPhone = Player.Functions.GetItemByName("phone")
        local retval = false

        if HasPhone ~= nil then
            cb(true)
        else
            cb(false)
        end
    end
end)

BJCore.Functions.RegisterServerCallback('phone:server:CanTransferMoney', function(source, cb, amount, iban)
    local Player = BJCore.Functions.GetPlayer(source)

    if (Player.PlayerData.money.bank - amount) >= 0 then
        BJCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
            if result[1] ~= nil then
                local Reciever = BJCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

                Player.Functions.RemoveMoney('bank', amount)

                if Reciever ~= nil then
                    Reciever.Functions.AddMoney('bank', amount)
                else
                    local RecieverMoney = json.decode(result[1].money)
                    RecieverMoney.bank = (RecieverMoney.bank + amount)
                    BJCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(RecieverMoney).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                end
                TriggerEvent("bj-log:server:CreateLog", "banking", "Bank Transfer", "green", "**"..Player.PlayerData.name .. "** has transfered "..BJCore.Config.Currency.Symbol..amount.." to **"..result[1].name.."** from their bank account.")
                cb(true)
            else
                TriggerClientEvent('BJCore:Notify', src, "This account number does not exist", "error")
                cb(false)
            end
        end)
    end
end)

RegisterServerEvent('phone:server:GiveContactDetails')
AddEventHandler('phone:server:GiveContactDetails', function(PlayerId)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    local SuggestionData = {
        name = {
            [1] = Player.PlayerData.charinfo.firstname,
            [2] = Player.PlayerData.charinfo.lastname
        },
        number = Player.PlayerData.charinfo.phone,
        bank = Player.PlayerData.charinfo.account
    }

    TriggerClientEvent('phone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterServerEvent('phone:server:AddTransaction')
AddEventHandler('phone:server:AddTransaction', function(data)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)

    BJCore.Functions.ExecuteSql(false, "INSERT INTO `crypto_transactions` (`citizenid`, `title`, `message`) VALUES ('"..Player.PlayerData.citizenid.."', '"..escape_sqli(data.TransactionTitle).."', '"..escape_sqli(data.TransactionMessage).."')")
end)

BJCore.Functions.RegisterServerCallback('phone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in pairs(BJCore.Functions.GetPlayers()) do
        local Player = BJCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "lawyer" then
                table.insert(Lawyers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(Lawyers)
end)

RegisterServerEvent('phone:server:InstallApplication')
AddEventHandler('phone:server:InstallApplication', function(ApplicationData)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.PlayerData.metadata["phonedata"].InstalledApps[ApplicationData.app] = ApplicationData
    Player.Functions.SetMetaData("phonedata", Player.PlayerData.metadata["phonedata"])

    -- TriggerClientEvent('phone:RefreshPhone', src)
end)

RegisterServerEvent('phone:server:RemoveInstallation')
AddEventHandler('phone:server:RemoveInstallation', function(App)
    local src = source
    local Player = BJCore.Functions.GetPlayer(src)
    Player.PlayerData.metadata["phonedata"].InstalledApps[App] = nil
    Player.Functions.SetMetaData("phonedata", Player.PlayerData.metadata["phonedata"])

    -- TriggerClientEvent('phone:RefreshPhone', src)
end)
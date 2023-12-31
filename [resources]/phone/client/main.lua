BJCore = nil
Citizen.CreateThread(function(...) while BJCore == nil do TriggerEvent("BJCore:GetObject", function(obj) BJCore = obj end); Citizen.Wait(1000); end; end)

-- Code

local PlayerJob = {}

phoneProp = 0

local phoneDisabled = false

PhoneData = {
    MetaData = {},
    isOpen = false,
    PlayerData = nil,
    Contacts = {},
    Tweets = {},
    MentionedTweets = {},
    Hashtags = {},
    Chats = {},
    Invoices = {},
    CallData = {},
    RecentCalls = {},
    Garage = {},
    Mails = {},
    Adverts = {},
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    SuggestedContacts = {},
    CryptoTransactions = {},
    Notes = {},
    Settings = {
        DisabledNotificationTypes = {
            'crypto'
        }
    },
    Camera = {
        TakingPhoto = false
    }
}

RegisterNetEvent('phone:client:RaceNotify')
AddEventHandler('phone:client:RaceNotify', function(message)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Racing",
                text = message,
                icon = "fas fa-flag-checkered",
                color = "#353b48",
                timeout = 1500
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Racing", 
                content = message, 
                icon = "fas fa-flag-checkered", 
                timeout = 3500, 
                color = "#353b48",
            },
        })
    end
end)

RegisterNetEvent('phone:client:AddRecentCall')
AddEventHandler('phone:client:AddRecentCall', function(data, time, type)
    table.insert(PhoneData.RecentCalls, {
        name = IsNumberInContacts(data.number),
        time = time,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    })
    TriggerServerEvent('phone:server:SetPhoneAlerts', "phone")
    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    SendNUIMessage({ 
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
end)

RegisterNetEvent('BJCore:Client:OnJobUpdate')
AddEventHandler('BJCore:Client:OnJobUpdate', function(JobInfo)
    SendNUIMessage({
        action = "UpdateApplications",
        JobData = JobInfo,
        applications = Config.PhoneApplications,
        hasMoneySafe = exports['utils']:DoesMoneysafeExist(JobInfo.name)
    })

    PlayerJob = JobInfo
end)

RegisterNUICallback('ClearRecentAlerts', function(data, cb)
    TriggerServerEvent('phone:server:SetPhoneAlerts', "phone", 0)
    Config.PhoneApplications["phone"].Alerts = 0
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('SetBackground', function(data)
    local background = data.background

    PhoneData.MetaData.background = background
    TriggerServerEvent('phone:server:SaveMetaData', PhoneData.MetaData)
end)

RegisterNUICallback('GetMissedCalls', function(data, cb)
    cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('GetSuggestedContacts', function(data, cb)
    cb(PhoneData.SuggestedContacts)
end)

function IsNumberInContacts(num)
    local retval = num
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
        end
    end
    return retval
end

local DefaultKvp = {
}

function LoadNotes()
    if PhoneData.PlayerData and PhoneData.PlayerData.citizenid then
        local notesKvp = GetResourceKvpString('notes_'..PhoneData.PlayerData.citizenid)

        if notesKvp ~= nil then
            print('Character Notes Found.')
            notesKvp = json.decode(notesKvp)
        else
            print('No Notes Found.')
            notesKvp = DefaultKvp
            SaveNotes(notesKvp)
        end

        return notesKvp
    end
    return DefaultKvp
end

function SaveNotes(notes)
    if PhoneData.PlayerData and PhoneData.PlayerData.citizenid then
        SetResourceKvp('notes_'..PhoneData.PlayerData.citizenid, json.encode(notes))
    end
end

function SendNotesRefresh()
    SendNUIMessage({
        action = "RefreshNotes",
        Notes = PhoneData.Notes
    })
end

RegisterNUICallback('AddNote', function(note, cb)
    if PhoneData.Notes then
        table.insert(PhoneData.Notes, note)
        SaveNotes(PhoneData.Notes)
    end
    if cb then
        cb()
    end
    SendNotesRefresh()
end)

RegisterNUICallback('EditNote', function(data, cb)
    if PhoneData.Notes and PhoneData.Notes[data.Index] then
        PhoneData.Notes[data.Index] = data.Note
        SaveNotes(PhoneData.Notes)
    end
    if cb then
        cb()
    end
    SendNotesRefresh()
end)

RegisterNUICallback('DeleteNote', function(data, cb)
    if PhoneData.Notes and #PhoneData.Notes >= data.index then
        table.remove(PhoneData.Notes, data.index)
        SaveNotes(PhoneData.Notes)
    end
    if cb then
        cb()
    end
    SendNotesRefresh()
end)

local DefaultSettings = {
    DisabledNotificationTypes = {
        'crypto'
    }
}

function LoadSettings()
    if PhoneData.PlayerData and PhoneData.PlayerData.citizenid then
        local settingsKvp = GetResourceKvpString('settings_'..PhoneData.PlayerData.citizenid)

        if settingsKvp ~= nil then
            print('Character Settings Found.')
            settingsKvp = json.decode(settingsKvp)
        else
            print('No Settings Found.')
            settingsKvp = DefaultSettings
            SaveSettings(settingsKvp)
        end

        return settingsKvp
    end
    return DefaultSettings
end

function SaveSettings(settings)
    if PhoneData.PlayerData and PhoneData.PlayerData.citizenid then
        SetResourceKvp('settings_'..PhoneData.PlayerData.citizenid, json.encode(settings))
    end
end

RegisterNUICallback('SaveSettings', function(data, cb)
    SaveSettings(data)
    PhoneData.Settings = data
    if cb then
        cb();
    end
end)

function UpdateSettings()
    SendNUIMessage({
        action = "RefreshSettings",
        Settings = LoadSettings()
    })
end

local isLoggedIn = false


isRPDead = false
RegisterNetEvent('ems:deathcheck')
AddEventHandler('ems:deathcheck', function()
    if not isRPDead then
        print("set isrpdead")
        isRPDead = true
        SendNUIMessage({
            action = "close",
        })
        CancelCall()
    else
        print("false isrpdead")
        isRPDead = false
    end
end)

local serverId = GetPlayerServerId(PlayerId())
AddStateBagChangeHandler('InLaststand', 'player:'..tostring(serverId), function(bagName, key, value, reserved, replicated)
    print("inlas value: "..tostring(value))
    if value == nil then return; end
    if value and value == true then
        print("InLaststand close")
        SendNUIMessage({
            action = "close",
        })
        CancelCall()
    end
end)

RegisterKeyMapping('-openphone', 'Phone~', 'keyboard', 'F1')
RegisterCommand('-openphone', function()
    if IsPedCuffed(PlayerPedId()) then return; end
    print("isRPDead: "..tostring(isRPDead))
    print("LocalPlayer.state.InLaststand: "..tostring(LocalPlayer.state.InLaststand))
    if isRPDead or LocalPlayer.state.InLaststand == true then return; end
    if not PhoneData.isOpen then
        OpenPhone()
    end
end, false)

RegisterKeyMapping('-hangup', 'Phone Hang-Up~', 'keyboard', 'H')
RegisterCommand('-hangup', function()
    CancelCall()
end)

RegisterKeyMapping('-answer', 'Phone Answer~', 'keyboard', 'CAPITAL')
RegisterCommand('-answer', function()
    AnswerCall()
end)

function CalculateTimeToDisplay()
	hour = GetClockHours()
    minute = GetClockMinutes()
    
    local obj = {}
    
	if minute <= 9 then
		minute = "0" .. minute
    end
    
    obj.hour = hour
    obj.minute = minute

    return obj
end

Citizen.CreateThread(function()
    while true do
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "UpdateTime",
                InGameTime = CalculateTimeToDisplay(),
            })
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)

        if BJCore.Functions.IsPlayerLoaded() then
            BJCore.Functions.TriggerServerCallback('phone:server:GetContacts', function(PlayerContacts)   
                if PlayerContacts ~= nil and next(PlayerContacts) ~= nil then 
                    PhoneData.Contacts = PlayerContacts
                end

                SendNUIMessage({
                    action = "RefreshContacts",
                    Contacts = PhoneData.Contacts
                })
            end)
        end
    end
end)

function LoadPhone()
    Citizen.Wait(100)
    isLoggedIn = true
    BJCore.Functions.TriggerServerCallback('phone:server:GetPhoneData', function(pData)
        PlayerJob = BJCore.Functions.GetPlayerData().job
        PhoneData.PlayerData = BJCore.Functions.GetPlayerData()
        local PhoneMeta = PhoneData.PlayerData.metadata["phone"]
        PhoneData.MetaData = PhoneMeta
        PhoneData.Notes = LoadNotes()
        PhoneData.Settings = LoadSettings()
        PhoneData.Camera = Config.Camera
        PhoneData.Camera.TakingPhoto = false

        if pData.InstalledApps ~= nil and next(pData.InstalledApps) ~= nil then
            for k, v in pairs(pData.InstalledApps) do
                local AppData = Config.StoreApps[v.app]
                if AppData ~= nil then
                    Config.PhoneApplications[v.app] = {
                        app = v.app,
                        color = AppData.color,
                        icon = AppData.icon,
                        tooltipText = AppData.title,
                        tooltipPos = AppData.tooltipPos,
                        job = AppData.job,
                        blockedjobs = AppData.blockedjobs,
                        slot = AppData.slot,
                        Alerts = 0,
                    }
                end
            end
        end

        if PhoneMeta.profilepicture == nil then
            PhoneData.MetaData.profilepicture = "default"
        else
            PhoneData.MetaData.profilepicture = PhoneMeta.profilepicture
        end

        if pData.Applications ~= nil and next(pData.Applications) ~= nil then
            for k, v in pairs(pData.Applications) do 
                Config.PhoneApplications[k].Alerts = v 
            end
        end

        if pData.MentionedTweets ~= nil and next(pData.MentionedTweets) ~= nil then 
            PhoneData.MentionedTweets = pData.MentionedTweets 
        end

        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 
            PhoneData.Contacts = pData.PlayerContacts
        end

        if pData.Chats ~= nil and next(pData.Chats) ~= nil then
            local Chats = {}
            for k, v in pairs(pData.Chats) do
                Chats[v.number] = {
                    name = IsNumberInContacts(v.number),
                    number = v.number,
                    messages = json.decode(v.messages),
                    last_updated = v.last_updated
                }
            end

            PhoneData.Chats = Chats
        end

        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
            for _, invoice in pairs(pData.Invoices) do
                invoice.contactName = IsNumberInContacts(invoice.number)
            end
            PhoneData.Invoices = pData.Invoices
        end

        if pData.Hashtags ~= nil and next(pData.Hashtags) ~= nil then
            PhoneData.Hashtags = pData.Hashtags
        end

        if pData.Mails ~= nil and next(pData.Mails) ~= nil then
            PhoneData.Mails = pData.Mails
        end

        if pData.Adverts ~= nil and next(pData.Adverts) ~= nil then
            PhoneData.Adverts = pData.Adverts
        end

        if pData.CryptoTransactions ~= nil and next(pData.CryptoTransactions) ~= nil then
            PhoneData.CryptoTransactions = pData.CryptoTransactions
        end

        BJCore.Functions.TriggerServerCallback('phone:server:SyncTweets', function(Tweets)
            PhoneData.Tweets = Tweets

            SendNUIMessage({ 
                action = "LoadPhoneData", 
                PhoneData = PhoneData, 
                PlayerData = PhoneData.PlayerData,
                PlayerJob = PhoneData.PlayerData.job,
                applications = Config.PhoneApplications,
                hasMoneySafe = exports['utils']:DoesMoneysafeExist(PhoneData.PlayerData.job.name)
            })
        end)
    end)
end

Citizen.CreateThread(function()
    Wait(500)
    LoadPhone()
end)

RegisterNetEvent('BJCore:Client:OnPlayerUnload')
AddEventHandler('BJCore:Client:OnPlayerUnload', function()
    PhoneData = {
        MetaData = {},
        isOpen = false,
        PlayerData = nil,
        Contacts = {},
        Tweets = {},
        MentionedTweets = {},
        Hashtags = {},
        Chats = {},
        Invoices = {},
        CallData = {},
        RecentCalls = {},
        Garage = {},
        Mails = {},
        Adverts = {},
        GarageVehicles = {},
        AnimationData = {
            lib = nil,
            anim = nil,
        },
        SuggestedContacts = {},
        CryptoTransactions = {},
    }

    isLoggedIn = false
end)

RegisterNetEvent('BJCore:Client:OnPlayerLoaded')
AddEventHandler('BJCore:Client:OnPlayerLoaded', function()
    LoadPhone()
end)

RegisterNUICallback('HasPhone', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:HasPhone', function(HasPhone)
        cb(HasPhone)
    end)
end)

function OpenPhone()
    BJCore.Functions.TriggerServerCallback('phone:server:HasPhone', function(HasPhone)
        if HasPhone then
            PhoneData.PlayerData = BJCore.Functions.GetPlayerData()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open",
                Tweets = PhoneData.Tweets,
                AppData = Config.PhoneApplications,
                CallData = PhoneData.CallData,
                PlayerData = PhoneData.PlayerData,
                HtmlCurrency = BJCore.Config.Currency.HtmlSymbols[BJCore.Config.Currency.Symbol],
                dataLoaded = PhoneData.Loaded,
                phoneDisabled = phoneDisabled
            })
            PhoneData.isOpen = true

            -- Citizen.CreateThread(function()
            --     while PhoneData.isOpen do
            --         DisableDisplayControlActions()
            --         Citizen.Wait(1)
            --     end
            -- end)
            
            if not PhoneData.CallData.InCall then
                DoPhoneAnimation('cellphone_text_in')
            else
                DoPhoneAnimation('cellphone_call_to_text')
            end

            SetTimeout(250, function()
                newPhoneProp()
            end)
        else
            BJCore.Functions.Notify("You don't have a phone", "error")
        end
    end)
end

RegisterNUICallback('SetupGarageVehicles', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetGarageVehicles', function(vehicles)
        PhoneData.GarageVehicles = vehicles
        cb(PhoneData.GarageVehicles)
    end)
end)

RegisterNUICallback('Close', function()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetNuiFocus(false, false)
    SetTimeout(500, function()
        PhoneData.isOpen = false
    end)
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local MailId = data.mailId

    TriggerServerEvent('phone:server:RemoveMail', MailId)
    cb('ok')
end)

RegisterNetEvent('phone:client:UpdateMails')
AddEventHandler('phone:client:UpdateMails', function(NewMails)
    SendNUIMessage({
        action = "UpdateMails",
        Mails = NewMails
    })
    PhoneData.Mails = NewMails
end)

RegisterNUICallback('AcceptMailButton', function(data)
    TriggerEvent(data.buttonEvent, data.buttonData)
    TriggerServerEvent('phone:server:ClearButtonData', data.mailId)
end)

RegisterNUICallback('AddNewContact', function(data, cb)
    table.insert(PhoneData.Contacts, {
        name = data.ContactName,
        number = data.ContactNumber,
        iban = data.ContactIban
    })
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[data.ContactNumber] ~= nil and next(PhoneData.Chats[data.ContactNumber]) ~= nil then
        PhoneData.Chats[data.ContactNumber].name = data.ContactName
    end
    TriggerServerEvent('phone:server:AddNewContact', data.ContactName, data.ContactNumber, data.ContactIban)
end)

RegisterNUICallback('GetMails', function(data, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('GetWhatsappChat', function(data, cb)
    if PhoneData.Chats[data.phone] ~= nil then
        cb(PhoneData.Chats[data.phone])
    else
        cb(false)
    end
end)

RegisterNUICallback('GetProfilePicture', function(data, cb)
    local number = data.number

    BJCore.Functions.TriggerServerCallback('phone:server:GetPicture', function(picture)
        cb(picture)
    end, number)
end)

RegisterNUICallback('GetBankContacts', function(data, cb)
    cb(PhoneData.Contacts)
end)

RegisterNUICallback('GetInvoices', function(data, cb)
    if PhoneData.Invoices ~= nil and next(PhoneData.Invoices) ~= nil then
        cb(PhoneData.Invoices)
    else
        cb(nil)
    end
end)

function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] ~= nil then
        if PhoneData.Chats[Number].messages ~= nil then
            for key, chat in pairs(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

function GetKeyByNumber(Number)
    local retval = nil
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                retval = k
            end
        end
    end
    return retval
end

function ReorganizeChats(key)
    return
    -- local ReorganizedChats = {}
    -- ReorganizedChats[1] = PhoneData.Chats[key]
    -- for k, chat in pairs(PhoneData.Chats) do
    --     if k ~= key then
    --         table.insert(ReorganizedChats, chat)
    --     end
    -- end
    -- PhoneData.Chats = ReorganizedChats
end

RegisterNUICallback('SendMessage', function(data, cb)
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType
    local ChatTS = data.ChatTS

    local Ped = PlayerPedId()
    local Pos = GetEntityCoords(Ped)
    local NumberKey = GetKeyByNumber(ChatNumber)
    local ChatKey = GetKeyByDate(NumberKey, ChatDate)
    if PhoneData.Chats[NumberKey] ~= nil then
        PhoneData.Chats[NumberKey].last_updated = ChatTS
        if(PhoneData.Chats[NumberKey].messages == nil) then
            PhoneData.Chats[NumberKey].messages = {}
        end
        if PhoneData.Chats[NumberKey].messages[ChatKey] ~= nil then
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = "Shared Location",
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            end
            TriggerServerEvent('phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, ChatTS, false)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        else
            table.insert(PhoneData.Chats[NumberKey].messages, {
                date = ChatDate,
                messages = {},
            })
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = "Shared Location",
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            end
            TriggerServerEvent('phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, ChatTS, true)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        end
    else
        PhoneData.Chats[ChatNumber] = {
            name = IsNumberInContacts(ChatNumber),
            number = ChatNumber,
            messages = {},
            last_updated = ChatTS
        }

        NumberKey = GetKeyByNumber(ChatNumber)
        table.insert(PhoneData.Chats[NumberKey].messages, {
            date = ChatDate,
            messages = {},
        })
        ChatKey = GetKeyByDate(NumberKey, ChatDate)
        if ChatType == "message" then
            table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                message = ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
            })
        elseif ChatType == "location" then
            table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                message = "Shared Location",
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    x = Pos.x,
                    y = Pos.y,
                },
            })
        end
        TriggerServerEvent('phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, ChatTS, true)
        NumberKey = GetKeyByNumber(ChatNumber)
        ReorganizeChats(NumberKey)
    end

    BJCore.Functions.TriggerServerCallback('phone:server:GetContactPicture', function(Chat)
        SendNUIMessage({
            action = "UpdateChat",
            chatData = Chat,
            chatNumber = ChatNumber,
        })
    end,  PhoneData.Chats[GetKeyByNumber(ChatNumber)])
end)

RegisterNUICallback('SharedLocation', function(data)
    local x = data.coords.x
    local y = data.coords.y

    SetNewWaypoint(x, y)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Whatsapp",
            text = "Location has been set",
            icon = "fab fa-whatsapp",
            color = "#25D366",
            timeout = 1500,
            type = "system-info"
        },
    })
end)

RegisterNetEvent('phone:client:UpdateMessages')
AddEventHandler('phone:client:UpdateMessages', function(ChatMessages, SenderNumber, ChatTS, New)
    local Sender = IsNumberInContacts(SenderNumber)

    local NumberKey = GetKeyByNumber(SenderNumber)

    if New or NumberKey == nil then
        PhoneData.Chats[SenderNumber] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = ChatMessages,
            last_updated = ChatTS
        }

        NumberKey = GetKeyByNumber(SenderNumber)

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "New message from "..IsNumberInContacts(SenderNumber),
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                        type = "whatsapp-message"
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "Why are you sending messages to yourself you sadfuck?",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                        type = "system-info"
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Wait(100)
            SendNUIMessage({
                action = "UpdateChat",
                chatData = Chats[GetKeyByNumber(SenderNumber)],
                chatNumber = SenderNumber,
                Chats = PhoneData.Chats,
            })
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "Whatsapp", 
                    content = "You received a new message from "..IsNumberInContacts(SenderNumber), 
                    icon = "fab fa-whatsapp", 
                    timeout = 3500, 
                    color = "#25D366",
                    type = "whatsapp-message"
                },
            })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('phone:server:SetPhoneAlerts', "whatsapp")
        end
    else
        PhoneData.Chats[NumberKey].last_updated = ChatTS
        PhoneData.Chats[NumberKey].messages = ChatMessages

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "New message from "..IsNumberInContacts(SenderNumber),
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                        type = "whatsapp-message"
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "Why are you sending messages to yourself you sadfuck?",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                        type = "system-info"
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)
            
            Wait(100)
            BJCore.Functions.TriggerServerCallback('phone:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = "UpdateChat",
                    chatData = Chats[GetKeyByNumber(SenderNumber)],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end,  PhoneData.Chats)
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "Whatsapp", 
                    content = "You received a new message from "..IsNumberInContacts(SenderNumber), 
                    icon = "fab fa-whatsapp", 
                    timeout = 3500, 
                    color = "#25D366",
                    type = "whatsapp-message"
                },
            })

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('phone:server:SetPhoneAlerts', "whatsapp")
        end
    end
end)

RegisterNetEvent("phone-new:client:BankNotify")
AddEventHandler("phone-new:client:BankNotify", function(text)
    SendNUIMessage({
        action = "Notification",
        NotifyData = {
            title = "Bank", 
            content = text, 
            icon = "fas fa-university", 
            timeout = 3500, 
            color = "#ff002f",
            type = "bank"
        },
    })
end)

RegisterNetEvent('phone:client:NewMailNotify')
AddEventHandler('phone:client:NewMailNotify', function(MailData)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Mail",
                text = "You received a new mail from "..MailData.sender,
                icon = "fas fa-envelope",
                color = "#ff002f",
                timeout = 1500,
                type = "mail"
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Mail", 
                content = "You received a new mail from "..MailData.sender, 
                icon = "fas fa-envelope", 
                timeout = 3500, 
                color = "#ff002f",
                type = "mail"
            },
        })
    end
    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
    TriggerServerEvent('phone:server:SetPhoneAlerts', "mail")
end)

RegisterNUICallback('PostAdvert', function(data)
    TriggerServerEvent('phone:server:AddAdvert', data.message)
end)

RegisterNetEvent('phone:client:UpdateAdverts')
AddEventHandler('phone:client:UpdateAdverts', function(Adverts, LastAd)
    PhoneData.Adverts = Adverts

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Advertisement",
                text = "A new ad has been posted by "..LastAd,
                icon = "fas fa-ad",
                color = "#ff8f1a",
                timeout = 2500,
                type = "advert"
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Advertisement", 
                content = "A new ad has been posted by "..LastAd,
                icon = "fas fa-ad", 
                timeout = 2500, 
                color = "#ff8f1a",
                type = "advert"
            },
        })
    end

    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('LoadAdverts', function()
    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local chat = data.number
    local ChatKey = GetKeyByNumber(chat)

    if PhoneData.Chats[ChatKey].Unread ~= nil then
        local newAlerts = (Config.PhoneApplications['whatsapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts
        TriggerServerEvent('phone:server:SetPhoneAlerts', "whatsapp", newAlerts)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end
end)

RegisterNetEvent('phone:client:UpdateInvoices')
AddEventHandler('phone:client:UpdateInvoices', function(Invoices)
    for _, invoice in pairs(Invoices) do
        invoice.contactName = IsNumberInContacts(invoice.number)
    end
    PhoneData.Invoices = Invoices
end)

RegisterNUICallback('SendInvoice', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:SendInvoice', function(response)
        cb(response)
    end, data)
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local sender = data.sender
    local job = data.job
    local amount = data.amount
    local invoiceId = data.invoiceId

    BJCore.Functions.TriggerServerCallback('phone:server:PayInvoice', function(CanPay, Invoices)
        if CanPay then
            for _, invoice in pairs(Invoices) do
                invoice.contactName = IsNumberInContacts(invoice.number)
            end
            PhoneData.Invoices = Invoices
        end
        cb(CanPay)
    end, data)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)

    BJCore.Functions.TriggerServerCallback('phone:server:DeclineInvoice', function(CanPay, Invoices)
        for _, invoice in pairs(Invoices) do
            invoice.contactName = IsNumberInContacts(invoice.number)
        end
        PhoneData.Invoices = Invoices
        cb('ok')
    end, data)
end)

RegisterNUICallback('EditContact', function(data, cb)
    local NewName = data.CurrentContactName
    local NewNumber = data.CurrentContactNumber
    local NewIban = data.CurrentContactIban
    local OldName = data.OldContactName
    local OldNumber = data.OldContactNumber
    local OldIban = data.OldContactIban

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == OldName and v.number == OldNumber then
            v.name = NewName
            v.number = NewNumber
            v.iban = NewIban
        end
    end
    if PhoneData.Chats[NewNumber] ~= nil and next(PhoneData.Chats[NewNumber]) ~= nil then
        PhoneData.Chats[NewNumber].name = NewName
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    TriggerServerEvent('phone:server:EditContact', NewName, NewNumber, NewIban, OldName, OldNumber, OldIban)
end)

local function escape_str(s)
	-- local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	-- local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	-- for i, c in ipairs(in_char) do
	--   s = s:gsub(c, '\\' .. out_char[i])
	-- end
	return s
end

function GenerateTweetId()
    local tweetId = "TWEET-"..math.random(11111111, 99999999)
    return tweetId
end

RegisterNetEvent('phone:client:UpdateHashtags')
AddEventHandler('phone:client:UpdateHashtags', function(Handle, msgData)
    if PhoneData.Hashtags[Handle] ~= nil then
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    else
        PhoneData.Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    end

    SendNUIMessage({
        action = "UpdateHashtags",
        Hashtags = PhoneData.Hashtags,
    })
end)

RegisterNUICallback('GetHashtagMessages', function(data, cb)
    if PhoneData.Hashtags[data.hashtag] ~= nil and next(PhoneData.Hashtags[data.hashtag]) ~= nil then
        cb(PhoneData.Hashtags[data.hashtag])
    else
        cb(nil)
    end
end)

RegisterNUICallback('GetTweets', function(data, cb)
    cb(PhoneData.Tweets)
end)

RegisterNUICallback('UpdateProfilePicture', function(data)
    local pf = data.profilepicture

    PhoneData.MetaData.profilepicture = pf
    
    TriggerServerEvent('phone:server:SaveMetaData', PhoneData.MetaData)
end)

local patt = "[?!@#]"

RegisterNetEvent('phone:client:AddTweet')
AddEventHandler('phone:client:AddTweet', function(src, NewTweetData)
    local MyPlayerId = -1
    if PhoneData and PhoneData.PlayerData and PhoneData.PlayerData.source then
        MyPlayerId = PhoneData.PlayerData.source
    else
        MyPlayerId = GetPlayerServerId(PlayerId())
    end

    if src ~= MyPlayerId then
        table.insert(PhoneData.Tweets, NewTweetData)
        if not PhoneData.isOpen then
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "New Tweet (@"..NewTweetData.firstName.." "..NewTweetData.lastName..")", 
                    content = NewTweetData.message, 
                    icon = "fab fa-twitter", 
                    timeout = 3500, 
                    color = "#1DA1F2",
                    type = "twitter-alltweets"
                },
            })
        else
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "New Tweet (@"..NewTweetData.firstName.." "..NewTweetData.lastName..")", 
                    text = NewTweetData.message, 
                    icon = "fab fa-twitter",
                    color = "#1DA1F2",
                    type = "twitter-alltweets"
                },
            })
        end
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Twitter", 
                text = "The Tweet has been posted", 
                icon = "fab fa-twitter",
                color = "#1DA1F2",
                timeout = 1000,
                type = "system-info"
            },
        })
    end
end)

RegisterNUICallback('PostNewTweet', function(data, cb)
    local TweetMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        message = escape_str(data.Message),
        time = data.Date,
        tweetId = GenerateTweetId(),
        picture = data.Picture
    }

    local TwitterMessage = data.Message
    local MentionTag = TwitterMessage:split("@")

    if data.Hashtags then
        for _,v in ipairs(data.Hashtags) do
            TriggerServerEvent('phone:server:UpdateHashtags', v, TweetMessage)
        end
    end

    for i = 2, #MentionTag, 1 do
        local Handle = MentionTag[i]:split(" ")[1]
        if Handle ~= nil or Handle ~= "" then
            local Fullname = Handle:split("_")
            local Firstname = Fullname[1]
            table.remove(Fullname, 1)
            local Lastname = table.concat(Fullname, " ")

            if (Firstname ~= nil and Firstname ~= "") and (Lastname ~= nil and Lastname ~= "") then
                if Firstname ~= PhoneData.PlayerData.charinfo.firstname and Lastname ~= PhoneData.PlayerData.charinfo.lastname then
                    TriggerServerEvent('phone:server:MentionedPlayer', Firstname, Lastname, TweetMessage)
                else
                    SetTimeout(2500, function()
                        SendNUIMessage({
                            action = "PhoneNotification",
                            PhoneNotify = {
                                title = "Twitter", 
                                text = "You can't mention yourself", 
                                icon = "fab fa-twitter",
                                color = "#1DA1F2",
                                type = "system-info"
                            },
                        })
                    end)
                end
            end
        end
    end

    table.insert(PhoneData.Tweets, TweetMessage)
    Citizen.Wait(100)
    cb(PhoneData.Tweets)

    --TriggerServerEvent('phone:server:UpdateTweets', PhoneData.Tweets, TweetMessage)
    TriggerServerEvent('phone:server:AddTweet', TweetMessage)
end)

RegisterNetEvent('phone:client:TransferMoney')
AddEventHandler('phone:client:TransferMoney', function(amount, newmoney)
    PhoneData.PlayerData.money.bank = newmoney
    if PhoneData.isOpen then
        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "Bank", text = BJCore.Config.Currency.HtmlSymbols[BJCore.Config.Currency.Symbol]..amount.." has been added to your account", icon = "fas fa-university", color = "#8c7ae6", type = "bank-important" }, })
        SendNUIMessage({ action = "UpdateBank", NewBalance = PhoneData.PlayerData.money.bank })
    else
        SendNUIMessage({ action = "Notification", NotifyData = { title = "Bank", content = BJCore.Config.Currency.HtmlSymbols[BJCore.Config.Currency.Symbol]..amount.." has been added to your account", icon = "fas fa-university", timeout = 2500, color = nil, type = "bank-important" }, })
    end
end)


-- RegisterNetEvent('phone:client:UpdateTweets')
-- AddEventHandler('phone:client:UpdateTweets', function(src, Tweets, NewTweetData)
--     PhoneData.Tweets = Tweets
--     local MyPlayerId = PhoneData.PlayerData.source
-- 
--     if src ~= MyPlayerId then
--         if not PhoneData.isOpen then
--             SendNUIMessage({
--                 action = "Notification",
--                 NotifyData = {
--                     title = "New Tweet (@"..NewTweetData.firstName.." "..NewTweetData.lastName..")", 
--                     content = NewTweetData.message, 
--                     icon = "fab fa-twitter", 
--                     timeout = 3500, 
--                     color = "#1DA1F2",
--                 },
--             })
--         else
--             SendNUIMessage({
--                 action = "PhoneNotification",
--                 PhoneNotify = {
--                     title = "New Tweet (@"..NewTweetData.firstName.." "..NewTweetData.lastName..")", 
--                     text = NewTweetData.message, 
--                     icon = "fab fa-twitter",
--                     color = "#1DA1F2",
--                 },
--             })
--         end
--     else
--         SendNUIMessage({
--             action = "PhoneNotification",
--             PhoneNotify = {
--                 title = "Twitter", 
--                 text = "The Tweet has been posted", 
--                 icon = "fab fa-twitter",
--                 color = "#1DA1F2",
--                 timeout = 1000,
--             },
--         })
--     end
-- end)

RegisterNUICallback('GetMentionedTweets', function(data, cb)
    cb(PhoneData.MentionedTweets)
end)

RegisterNUICallback('GetHashtags', function(data, cb)
    if PhoneData.Hashtags ~= nil and next(PhoneData.Hashtags) ~= nil then
        cb(PhoneData.Hashtags)
    else
        cb(nil)
    end
end)

RegisterNetEvent('phone:client:GetMentioned')
AddEventHandler('phone:client:GetMentioned', function(TweetMessage, AppAlerts)
    Config.PhoneApplications["twitter"].Alerts = AppAlerts
    if not PhoneData.isOpen then
        SendNUIMessage({ action = "Notification", NotifyData = { title = "You have been mentioned in a Tweet", content = TweetMessage.message, icon = "fab fa-twitter", timeout = 3500, color = nil, type = "twitter-mention" }, })
    else
        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "You have been mentioned in a Tweet", text = TweetMessage.message, icon = "fab fa-twitter", color = "#1DA1F2", type = "twitter-mention" }, })
    end
    local TweetMessage = {firstName = TweetMessage.firstName, lastName = TweetMessage.lastName, message = escape_str(TweetMessage.message), time = TweetMessage.time, picture = TweetMessage.picture}
    table.insert(PhoneData.MentionedTweets, TweetMessage)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    SendNUIMessage({ action = "UpdateMentionedTweets", Tweets = PhoneData.MentionedTweets })
end)

RegisterNUICallback('ClearMentions', function()
    Config.PhoneApplications["twitter"].Alerts = 0
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
    TriggerServerEvent('phone:server:SetPhoneAlerts', "twitter", 0)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('ClearGeneralAlerts', function(data)
    SetTimeout(400, function()
        Config.PhoneApplications[data.app].Alerts = 0
        SendNUIMessage({
            action = "RefreshAppAlerts",
            AppData = Config.PhoneApplications
        })
        TriggerServerEvent('phone:server:SetPhoneAlerts', data.app, 0)
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end)
end)

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

RegisterNUICallback('TransferMoney', function(data, cb)
    data.amount = tonumber(data.amount)
    if tonumber(PhoneData.PlayerData.money.bank) >= data.amount then
        local amaountata = PhoneData.PlayerData.money.bank - data.amount
        TriggerServerEvent('phone:server:TransferMoney', data.iban, data.amount)
        local cbdata = {
            CanTransfer = true,
            NewAmount = amaountata 
        }
        cb(cbdata)
    else
        local cbdata = {
            CanTransfer = false,
            NewAmount = nil,
        }
        cb(cbdata)
    end
end)

RegisterNUICallback('CanTransferMoney', function(data, cb)
    local amount = tonumber(data.amountOf)
    local iban = data.sendTo
    local PlayerData = BJCore.Functions.GetPlayerData()

    if (PlayerData.money.bank - amount) >= 0 then
        BJCore.Functions.TriggerServerCallback('phone:server:CanTransferMoney', function(Transferd)
            if Transferd then
                cb({TransferedMoney = true, NewBalance = (PlayerData.money.bank - amount)})
            else
                cb({TransferedMoney = false})
            end
        end, amount, iban)
    else
        cb({TransferedMoney = false})
    end
end)

RegisterNUICallback('GetWhatsappChats', function(data, cb)
    cb(json.encode(PhoneData.Chats))
--    BJCore.Functions.TriggerServerCallback('phone:server:GetContactPictures', function(Chats)
        
--    end, PhoneData.Chats)
end)

RegisterNUICallback('CallContact', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetCallState', function(CanCall, IsOnline)
        local status = { 
            CanCall = CanCall, 
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        cb(status)
        if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.charinfo.phone) then
            CallContact(data.ContactData, data.Anonymous)
        end
    end, data.ContactData)
end)

function GenerateCallId(caller, target)
    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
    return CallId
end

CallContact = function(CallData, AnonymousCall)
    local RepeatCount = 0
    PhoneData.CallData.CallType = "outgoing"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.charinfo.phone, CallData.number)

    TriggerServerEvent('phone:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
    TriggerServerEvent('phone:server:SetCallState', true)
    
    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                else
                    break
                end
                Citizen.Wait(Config.RepeatTimeout)
            else
                CancelCall()
                break
            end
        else
            break
        end
    end
end

RegisterNetEvent("weathersync:client:RPBlackOut", function(b)
    if b then
        phoneDisabled = true
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "disablePhone",
                phoneDisabled = phoneDisabled
            })
        end
        CancelCall()
    else
        phoneDisabled = false
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "disablePhone",
                phoneDisabled = phoneDisabled
            })
        end
    end
end)

-- RegisterCommand('batlow', function()
--     phoneDisabled = true
--     if PhoneData.isOpen then
--         SendNUIMessage({
--             action = "disablePhone",
--             phoneDisabled = phoneDisabled
--         })
--     end
-- end)
-- RegisterCommand('batres', function()
--     phoneDisabled = false
--     if PhoneData.isOpen then
--         SendNUIMessage({
--             action = "disablePhone",
--             phoneDisabled = phoneDisabled
--         })
--     end
-- end)

CancelCall = function()
    if PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing" or PhoneData.CallData.CallType == "ongoing" then
        TriggerServerEvent('phone:server:CancelCall', PhoneData.CallData)
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.InCall = false
        PhoneData.CallData.AnsweredCall = false
        PhoneData.CallData.TargetData = {}
        PhoneData.CallData.CallId = nil

        if not PhoneData.isOpen then
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        else
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end

        TriggerServerEvent('phone:server:SetCallState', false)

        if not PhoneData.isOpen then
            SendNUIMessage({ 
                action = "Notification", 
                NotifyData = { 
                    title = "Telephone",
                    content = "The call has been ended", 
                    icon = "fas fa-phone", 
                    timeout = 3500, 
                    color = "#e84118",
                    type = "system-info"
                }, 
            })            
        else
            SendNUIMessage({ 
                action = "PhoneNotification", 
                PhoneNotify = { 
                    title = "Telephone", 
                    text = "The call has been ended", 
                    icon = "fas fa-phone", 
                    color = "#e84118",
                    type = "system-info"
                }, 
            })
        end
        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })
        SendNUIMessage({
            action = "CancelOutgoingCall",
        })

        SendNUIMessage({
            action = "CancelOngoingCall"
        })
    end
end

RegisterNetEvent('phone:client:CancelCall')
AddEventHandler('phone:client:CancelCall', function()
    if PhoneData.CallData.CallType == "ongoing" then
        SendNUIMessage({
            action = "CancelOngoingCall"
        })
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('phone:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({ 
            action = "Notification", 
            NotifyData = { 
                title = "Telephone",
                content = "The call has been ended", 
                icon = "fas fa-phone", 
                timeout = 3500, 
                color = "#e84118",
                type = "system-info"
            }, 
        })            
    else
        SendNUIMessage({ 
            action = "PhoneNotification", 
            PhoneNotify = { 
                title = "Telephone", 
                text = "The call has been ended", 
                icon = "fas fa-phone", 
                color = "#e84118",
                type = "system-info"
            }, 
        })

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = "CancelOutgoingCall",
        })
    end
end)

RegisterNetEvent('phone:client:GetCalled')
AddEventHandler('phone:client:GetCalled', function(CallerNumber, CallId, AnonymousCall)
    local RepeatCount = 0
    local CallData = {
        number = CallerNumber,
        name = IsNumberInContacts(CallerNumber),
        anonymous = AnonymousCall
    }

    if AnonymousCall then
        CallData.name = "Anonymous"
    end

    PhoneData.CallData.CallType = "incoming"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.CallId = CallId

    TriggerServerEvent('phone:server:SetCallState', true)

    SendNUIMessage({
        action = "SetupHomeCall",
        CallData = PhoneData.CallData,
    })

    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    BJCore.Functions.TriggerServerCallback('phone:server:HasPhone', function(HasPhone)
                        if HasPhone then
                            RepeatCount = RepeatCount + 1
                            TriggerServerEvent("InteractSound_SV:PlayOnSource", "ringing", 0.2)
                            
                            if not PhoneData.isOpen then
                                SendNUIMessage({
                                    action = "IncomingCallAlert",
                                    CallData = PhoneData.CallData.TargetData,
                                    Canceled = false,
                                    AnonymousCall = AnonymousCall,
                                })
                            end
                        end
                    end)
                else
                    SendNUIMessage({
                        action = "IncomingCallAlert",
                        CallData = PhoneData.CallData.TargetData,
                        Canceled = true,
                        AnonymousCall = AnonymousCall,
                    })
                    TriggerServerEvent('phone:server:AddRecentCall', "missed", CallData)
                    break
                end
                Citizen.Wait(Config.RepeatTimeout)
            else
                SendNUIMessage({
                    action = "IncomingCallAlert",
                    CallData = PhoneData.CallData.TargetData,
                    Canceled = true,
                    AnonymousCall = AnonymousCall,
                })
                TriggerServerEvent('phone:server:AddRecentCall', "missed", CallData)
                break
            end
        else
            TriggerServerEvent('phone:server:AddRecentCall', "missed", CallData)
            break
        end
    end
end)

RegisterNUICallback('CancelOutgoingCall', function()
    CancelCall()
end)

RegisterNUICallback('DenyIncomingCall', function()
    CancelCall()
end)

RegisterNUICallback('CancelOngoingCall', function()
    CancelCall()
end)

RegisterNUICallback('AnswerCall', function()
    AnswerCall()
end)

function AnswerCall()
    if PhoneData.CallData.CallType == "outgoing" or PhoneData.CallData.CallType == "ongoing" then return; end
    if PhoneData.CallData.CallType == "incoming" and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)

        TriggerServerEvent('phone:server:AnswerCall', PhoneData.CallData)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        -- SendNUIMessage({ 
        --     action = "PhoneNotification", 
        --     PhoneNotify = { 
        --         title = "Phone", 
        --         text = "You don't have an incoming call", 
        --         icon = "fas fa-phone", 
        --         color = "#e84118",
        --         type = "system-info"
        --     }, 
        -- })
    end
end

RegisterCommand('answer', AnswerCall)
RegisterCommand('hangup', function()
    TriggerServerEvent('phone:server:CancelCall', PhoneData.CallData)
    TriggerEvent('phone:client:CancelCall')
end)

RegisterNetEvent('phone:client:AnswerCall')
AddEventHandler('phone:client:AnswerCall', function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        SendNUIMessage({ 
            action = "PhoneNotification", 
            PhoneNotify = { 
                title = "Phone", 
                text = "You don't have an incoming call", 
                icon = "fas fa-phone", 
                color = "#e84118",
                type = "system-info"
            }, 
        })
    end
end)

-- AddEventHandler('onResourceStop', function(resource)
--     if resource == GetCurrentResourceName() then
--         -- SetNuiFocus(false, false)
--     end
-- end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:FetchResult', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleResults', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetVehicleSearchResults', function(result)
        if result ~= nil then 
            for k, v in pairs(result) do
                BJCore.Functions.TriggerServerCallback('police:IsPlateFlagged', function(flagged)
                    result[k].isFlagged = flagged
                end, result[k].plate)
                Citizen.Wait(50)
            end
        end
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleScan', function(data, cb)
    local vehicle = BJCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    BJCore.Functions.TriggerServerCallback('phone:server:ScanPlate', function(result)
        BJCore.Functions.TriggerServerCallback('police:IsPlateFlagged', function(flagged)
            result.isFlagged = flagged
            local vehicleInfo = BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[model]["model"]] ~= nil and BJCore.Shared.Vehicles[BJCore.Shared.VehicleModels[model]["model"]] or {["brand"] = "Unknown brand..", ["name"] = ""}
            result.label = vehicleInfo["name"]
            cb(result)
        end, plate)
    end, plate)
end)

RegisterNetEvent('phone:client:addPoliceAlert')
AddEventHandler('phone:client:addPoliceAlert', function(alertData)
    PlayerJob = BJCore.Functions.GetPlayerData().job
    if PlayerJob.name == 'police' and PlayerJob.onduty then
        SendNUIMessage({
            action = "AddPoliceAlert",
            alert = alertData,
        })
    end
end)

RegisterNUICallback('SetAlertWaypoint', function(data)
    local coords = data.alert.coords

    BJCore.Functions.Notify('GPS Location set: '..data.alert.title)
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNUICallback('RemoveSuggestion', function(data, cb)
    local data = data.data

    if PhoneData.SuggestedContacts ~= nil and next(PhoneData.SuggestedContacts) ~= nil then
        for k, v in pairs(PhoneData.SuggestedContacts) do
            if (data.name[1] == v.name[1] and data.name[2] == v.name[2]) and data.number == v.number and data.bank == v.bank then
                table.remove(PhoneData.SuggestedContacts, k)
            end
        end
    end
end)

function GetClosestPlayer()
    local closestPlayers = BJCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

RegisterNetEvent('phone:client:GiveContactDetails')
AddEventHandler('phone:client:GiveContactDetails', function()
    local ped = PlayerPedId()

    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        TriggerServerEvent('phone:server:GiveContactDetails', PlayerId)
    else
        BJCore.Functions.Notify("No one nearby", "error")
    end
end)

-- Citizen.CreateThread(function()
--     Wait(1000)
--     TriggerServerEvent('phone:server:GiveContactDetails', 1)
-- end)

RegisterNUICallback('DeleteContact', function(data, cb)
    local Name = data.CurrentContactName
    local Number = data.CurrentContactNumber
    local Account = data.CurrentContactIban

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == Name and v.number == Number then
            table.remove(PhoneData.Contacts, k)
            if PhoneData.isOpen then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Phone",
                        text = "Contact deleted", 
                        icon = "fa fa-phone-alt",
                        color = "#04b543",
                        timeout = 1500,
                        type = "system-info"
                    },
                })
            else
                SendNUIMessage({
                    action = "Notification",
                    NotifyData = {
                        title = "Phone", 
                        content = "Contact deleted", 
                        icon = "fa fa-phone-alt", 
                        timeout = 3500, 
                        color = "#04b543",
                        type = "system-info"
                    },
                })
            end
            break
        end
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[Number] ~= nil and next(PhoneData.Chats[Number]) ~= nil then
        PhoneData.Chats[Number].name = Number
    end
    TriggerServerEvent('phone:server:RemoveContact', Name, Number)
end)

RegisterNetEvent('phone:client:AddNewSuggestion')
AddEventHandler('phone:client:AddNewSuggestion', function(SuggestionData)
    table.insert(PhoneData.SuggestedContacts, SuggestionData)

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Phone",
                text = "You have a new suggested contact", 
                icon = "fa fa-phone-alt",
                color = "#04b543",
                timeout = 1500,
                type = "system-info"
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Phone", 
                content = "You have a new suggested contact", 
                icon = "fa fa-phone-alt", 
                timeout = 3500, 
                color = "#04b543",
                type = "system-info"
            },
        })
    end

    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    TriggerServerEvent('phone:server:SetPhoneAlerts', "phone", Config.PhoneApplications["phone"].Alerts)
end)

RegisterNUICallback('GetCryptoData', function(data, cb)
    BJCore.Functions.TriggerServerCallback('crypto:server:GetCryptoData', function(CryptoData)
        cb(CryptoData)
    end, data.crypto)
end)

RegisterNUICallback('BuyCrypto', function(data, cb)
    BJCore.Functions.TriggerServerCallback('crypto:server:BuyCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    BJCore.Functions.TriggerServerCallback('crypto:server:SellCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('TransferCrypto', function(data, cb)
    BJCore.Functions.TriggerServerCallback('crypto:server:TransferCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNetEvent('phone:client:RemoveBankMoney')
AddEventHandler('phone:client:RemoveBankMoney', function(amount)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Bank",
                text = BJCore.Config.Currency.Symbol..amount.." has been debited from your account", 
                icon = "fas fa-university", 
                color = "#ff002f",
                timeout = 3500,
                type = "bank-important"
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Bank",
                content = BJCore.Config.Currency.Symbol..amount.." has been debited from your account", 
                icon = "fas fa-university",
                timeout = 3500, 
                color = "#ff002f",
                type = "bank-important"
            },
        })
    end
end)

RegisterNetEvent('phone:client:CryptoUpdateNotification')
AddEventHandler('phone:client:CryptoUpdateNotification', function(crypto, NewWorth, ChangeLabel)
    if ChangeLabel then
        print(ChangeLabel)
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Crypto",
                    text = 'Crypto is now worth '..BJCore.Config.Currency.Symbol..tostring(NewWorth)..' ('..ChangeLabel..')', 
                    icon = "fas fa-chart-pie",
                    color = "#004682",
                    timeout = 1500,
                    type = "crypto"
                },
            })
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "Crypto",
                    content = 'Crypto is now worth '..BJCore.Config.Currency.Symbol..tostring(NewWorth)..' ('..ChangeLabel..')', 
                    icon = "fas fa-chart-pie",
                    timeout = 3500, 
                    color = "#004682",
                    type = "crypto"
                },
            })
        end
    end
end)

RegisterNetEvent('phone:client:AddTransaction')
AddEventHandler('phone:client:AddTransaction', function(TransactionData, Message, Title)
    local Data = {
        TransactionTitle = Title,
        TransactionMessage = Message,
    }
    
    table.insert(PhoneData.CryptoTransactions, Data)

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Crypto",
                text = Message, 
                icon = "fas fa-chart-pie",
                color = "#04b543",
                timeout = 1500,
                type = "system-info"
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Crypto",
                content = Message, 
                icon = "fas fa-chart-pie",
                timeout = 3500, 
                color = "#04b543",
                type = "system-info"
            },
        })
    end

    SendNUIMessage({
        action = "UpdateTransactions",
        CryptoTransactions = PhoneData.CryptoTransactions
    })

    TriggerServerEvent('phone:server:AddTransaction', Data)
end)

RegisterNUICallback('GetCryptoTransactions', function(data, cb)
    local Data = {
        CryptoTransactions = PhoneData.CryptoTransactions
    }
    cb(Data)
end)

RegisterNUICallback('GetAvailableRaces', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:GetRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('JoinRace', function(data)
    TriggerServerEvent('lapraces:server:JoinRace', data.RaceData)
end)

RegisterNUICallback('LeaveRace', function(data)
    TriggerServerEvent('lapraces:server:LeaveRace', data.RaceData)
end)

RegisterNUICallback('StartRace', function(data)
    TriggerServerEvent('lapraces:server:StartRace', data.RaceData.RaceId)
end)

RegisterNetEvent('phone:client:UpdateLapraces')
AddEventHandler('phone:client:UpdateLapraces', function()
    SendNUIMessage({
        action = "UpdateRacingApp",
    })
end)

RegisterNUICallback('GetRaces', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:GetListedRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('GetTrackData', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:GetTrackData', function(TrackData, CreatorData)
        TrackData.CreatorData = CreatorData
        cb(TrackData)
    end, data.RaceId)
end)

RegisterNUICallback('SetupRace', function(data, cb)
    TriggerServerEvent('lapraces:server:SetupRace', data.RaceId, tonumber(data.AmountOfLaps))
end)

RegisterNUICallback('HasCreatedRace', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:HasCreatedRace', function(HasCreated)
        cb(HasCreated)
    end)
end)

RegisterNUICallback('IsInRace', function(data, cb)
    local InRace = exports['lapraces']:IsInRace()
    cb(InRace)
end)

RegisterNUICallback('IsAuthorizedToCreateRaces', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:IsAuthorizedToCreateRaces', function(IsAuthorized, NameAvailable)
        local data = {
            IsAuthorized = IsAuthorized,
            IsBusy = exports['lapraces']:IsInEditor(),
            IsNameAvailable = NameAvailable,
        }
        cb(data)
    end, data.TrackName)
end)

RegisterNUICallback('StartTrackEditor', function(data, cb)
    TriggerServerEvent('lapraces:server:CreateLapRace', data.TrackName)
end)

RegisterNUICallback('GetRacingLeaderboards', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:GetRacingLeaderboards', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('RaceDistanceCheck', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:GetRacingData', function(RaceData)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local checkpointcoords = RaceData.Checkpoints[1].coords
        local dist = GetDistanceBetweenCoords(coords, checkpointcoords.x, checkpointcoords.y, checkpointcoords.z, true)
        if dist <= 115.0 then
            if data.Joined then
                TriggerEvent('lapraces:client:WaitingDistanceCheck')
            end
            cb(true)
        else
            BJCore.Functions.Notify('You\'re too far away from the race. GPS has been set to the race', 'error', 5000)
            SetNewWaypoint(checkpointcoords.x, checkpointcoords.y)
            cb(false)
        end
    end, data.RaceId)
end)

RegisterNUICallback('IsBusyCheck', function(data, cb)
    if data.check == "editor" then
        cb(exports['lapraces']:IsInEditor())
    else
        cb(exports['lapraces']:IsInRace())
    end
end)

RegisterNUICallback('CanRaceSetup', function(data, cb)
    BJCore.Functions.TriggerServerCallback('lapraces:server:CanRaceSetup', function(CanSetup)
        cb(CanSetup)
    end)
end)

RegisterNUICallback('GetPlayerHouses', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetPlayerHouses', function(Houses)
        cb(Houses)
    end)
end)

RegisterNUICallback('GetPlayerKeys', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetHouseKeys', function(Keys)
        cb(Keys)
    end)
end)

RegisterNUICallback('SetHouseLocation', function(data, cb)
    SetNewWaypoint(data.HouseData.HouseData.coords.enter.x, data.HouseData.HouseData.coords.enter.y)
    BJCore.Functions.Notify("GPS has been set on " .. data.HouseData.HouseData.adress, "success")
end)

RegisterNUICallback('RemoveKeyholder', function(data)
    TriggerServerEvent('houses:server:removeHouseKey', data.HouseData.name, {
        citizenid = data.HolderData.citizenid,
        firstname = data.HolderData.charinfo.firstname,
        lastname = data.HolderData.charinfo.lastname,
    })
end)

RegisterNUICallback('TransferCid', function(data, cb)
    local TransferedCid = data.newBsn

    BJCore.Functions.TriggerServerCallback('phone:server:TransferCid', function(CanTransfer)
        cb(CanTransfer)
    end, TransferedCid, data.HouseData)
end)

RegisterNUICallback('SetGPSLocation', function(data, cb)
    local ped = PlayerPedId()

    SetNewWaypoint(data.coords.x, data.coords.y)
    BJCore.Functions.Notify('GPS has been set', 'success')
end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    local ApartmentData = data.data.appartmentdata
    local TypeData = Apartments.Locations[ApartmentData.type]

    SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
    BJCore.Functions.Notify('GPS has been set', 'success')
end)

RegisterNUICallback('GetCurrentLawyers', function(data, cb)
    BJCore.Functions.TriggerServerCallback('phone:server:GetCurrentLawyers', function(lawyers)
        cb(lawyers)
    end)
end)

RegisterNUICallback('SetupStoreApps', function(data, cb)
    local PlayerData = BJCore.Functions.GetPlayerData()
    local data = {
        StoreApps = Config.StoreApps,
        PhoneData = PlayerData.metadata["phonedata"]
    }
    cb(data)
end)

function GetFirstAvailableSlot()
    local retval = 0
    for k, v in pairs(Config.PhoneApplications) do
        retval = retval + 1
    end
    return (retval + 1)
end

local CanDownloadApps = true

RegisterNUICallback('InstallApplication', function(data, cb)
    local ApplicationData = Config.StoreApps[data.app]
    local NewSlot = GetFirstAvailableSlot()

    if not CanDownloadApps then
        return
    end
    
    if NewSlot <= Config.MaxSlots then
        TriggerServerEvent('phone:server:InstallApplication', {
            app = data.app,
        })
        cb({
            app = data.app,
            data = ApplicationData
        })
    else
        cb(false)
    end
end)

RegisterNUICallback('RemoveApplication', function(data, cb)
    TriggerServerEvent('phone:server:RemoveInstallation', data.app)
end)

RegisterNetEvent('phone:RefreshPhone')
AddEventHandler('phone:RefreshPhone', function()
    LoadPhone()
    SetTimeout(250, function()
        SendNUIMessage({
            action = "RefreshAlerts",
            AppData = Config.PhoneApplications,
        })
    end)
end)

RegisterNUICallback('GetTruckerData', function(data, cb)
    local TruckerMeta = BJCore.Functions.GetPlayerData().metadata["jobrep"]["trucker"]
    local TierData = exports['qb-trucker']:GetTier(TruckerMeta)
    cb(TierData)
end)

-- Disables GTA controls when display is active
-- this allows for NUI input with ingame input
function DisableDisplayControlActions()
    DisableControlAction(0, 1, true) -- disable mouse look
    DisableControlAction(0, 2, true) -- disable mouse look
    DisableControlAction(0, 3, true) -- disable mouse look
    DisableControlAction(0, 4, true) -- disable mouse look
    DisableControlAction(0, 5, true) -- disable mouse look
    DisableControlAction(0, 6, true) -- disable mouse look

    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee

    DisableControlAction(0, 177, true) -- disable escape
    DisableControlAction(0, 200, true) -- disable escape
    DisableControlAction(0, 202, true) -- disable escape
    DisableControlAction(0, 322, true) -- disable escape

    DisableControlAction(0, 245, true) -- disable chat  
end

function InPhone()
    return PhoneData.isOpen
end

SetNuiCloseCallback(function()
    SendNUIMessage({
        action = "close",
    })
end)

RegisterNetEvent("core:resetUi")
AddEventHandler("core:resetUi", function()
    SendNUIMessage({
        action = "close",
    })
end)

local frontCam = false

RegisterNUICallback('TakePhoto', function(data, cb)
    if not Config.Camera or not Config.Camera.Enabled then
        cb(false)
        return
    end

    if GetResourceState('screenshot-basic') ~= 'started' then
        print('Please ensure screenshot-basic is started properly. It currently has a state of: '..GetResourceState('screenshot-basic'))
        cb(false)
        return
    end

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "photoDisplay",
        show = false
    })
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    PhoneData.Camera.TakingPhoto = true
    frontCam = false
    Citizen.Wait(0)
    
    TriggerEvent('hud:toggle', false)

    local scaleform = CreateCameraButtonScaleform()
  
    while PhoneData.Camera.TakingPhoto do
        Wait(0)

        if IsControlJustPressed(1, 244) then -- Mode (M)
            frontCam = not frontCam
            Citizen.InvokeNative(0x2491A93618B7D838, frontCam) -- CellFrontCamActivate missing native.
        elseif IsControlJustPressed(1, 177) then -- Cancel (Backspace)
            DestroyMobilePhone()
            CellCamActivate(false, false)
            PhoneData.Camera.TakingPhoto = false
            cb(false)
            break
        elseif IsControlJustPressed(1, 176) then -- Take photo (Enter/LMB)
            PhoneData.Camera.TakingPhoto = false
            Wait(50)
            exports['screenshot-basic']:requestScreenshot(function(data)
                Wait(50)
                DestroyMobilePhone()
                CellCamActivate(false, false)
                cb(json.encode({ base64 = data }))
                TriggerEvent('hud:toggle', true)
            end)
            break
        end
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end
    Wait(800)
    TriggerEvent('hud:toggle', true)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "photoDisplay",
        show = true
    })
end)

function CreateCameraButtonScaleform()
    local scaleform = RequestScaleformMovie('instructional_buttons')
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, 'CLEAR_ALL')
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, 'SET_CLEAR_SPACE')
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 244, true))
    InstructionButtonMessage('Toggle Selfie Mode')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
    PushScaleformMovieFunctionParameterInt(2)
    InstructionButton(GetControlInstructionalButton(1, 177, true))
    InstructionButtonMessage('Cancel')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
    PushScaleformMovieFunctionParameterInt(3)
    InstructionButton(GetControlInstructionalButton(1, 176, true))
    InstructionButtonMessage('Take Photo')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_BACKGROUND_COLOUR')
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end
BJ = {}
BJ.Phone = {}
BJ.Screen = {}
BJ.Phone.Functions = {}
BJ.Phone.Animations = {}
BJ.Phone.Notifications = {}
BJ.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

BJ.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
    Currency: '&dollar;',
    JobHasSafe: false,
    Settings: {
        DisabledNotificationTypes: []
    },
    Camera: {
        Enabled: false
    }
}

BJ.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

let NotificationQueue = [];

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && BJ.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

BJ.Phone.Functions.SetupApplications = function(data) {
    BJ.Phone.Data.Applications = data.applications;
    BJ.Phone.Data.JobHasSafe = data.hasMoneySafe;

    var i;
    for (i = 1; i <= BJ.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, BJ.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === BJ.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

BJ.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

BJ.Phone.Functions.StripAngledBrackets = function(str) {
    return str.replace(/</g, "&lt;").replace(/>/g, "&gt;");
};

BJ.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
            return false;
        }
    });
    return retval;
}

BJ.Phone.Functions.ContainsBlacklistedText = function(text) {
    var retval = false;
    $.each(Config.BlacklistedPhrases, function(i, blacklistedPhrase){
        if (text.match(new RegExp(blacklistedPhrase, 'gi')) != null) {
            retval = true;
        }
    });

    return retval;
}

function RefreshApplicationData(PressedApplication) {
    if (PressedApplication == "settings") {
        $("#myPhoneNumber").text(BJ.Phone.Data.PlayerData.charinfo.phone);
        $("#mySerialNumber").text("BJ-" + BJ.Phone.Data.PlayerData.metadata["phonedata"].SerialNumber);
    } else if (PressedApplication == "twitter") {
        $.post('http://phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
            BJ.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
        })
        $.post('http://phone/GetHashtags', JSON.stringify({}), function(Hashtags){
            BJ.Phone.Notifications.LoadHashtags(Hashtags)
        })
        if (BJ.Phone.Data.IsOpen) {
            $.post('http://phone/GetTweets', JSON.stringify({}), function(Tweets){
                BJ.Phone.Notifications.LoadTweets(Tweets);
            });
        }
    } else if (PressedApplication == "bank") {
        BJ.Phone.Functions.DoBankOpen();
        $.post('http://phone/GetBankContacts', JSON.stringify({}), function(contacts){
            BJ.Phone.Functions.LoadBankContactsWithNumber(contacts);
        });
        $.post('http://phone/GetInvoices', JSON.stringify({}), function(invoices){
            BJ.Phone.Functions.LoadBankInvoices(invoices);
        });
    } else if (PressedApplication == "whatsapp") {
        $.post('http://phone/GetWhatsappChats', JSON.stringify({}), function(chats){
            BJ.Phone.Functions.LoadWhatsappChats(JSON.parse(chats));
        });
    } else if (PressedApplication == "phone") {
        $.post('http://phone/GetMissedCalls', JSON.stringify({}), function(recent){
            BJ.Phone.Functions.SetupRecentCalls(recent);
        });
        $.post('http://phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
            BJ.Phone.Functions.SetupSuggestedContacts(suggested);
        });
        $.post('http://phone/ClearGeneralAlerts', JSON.stringify({
            app: "phone"
        }));
    } else if (PressedApplication == "mail") {
        $.post('http://phone/GetMails', JSON.stringify({}), function(mails){
            BJ.Phone.Functions.SetupMails(mails);
        });
        $.post('http://phone/ClearGeneralAlerts', JSON.stringify({
            app: "mail"
        }));
    } else if (PressedApplication == "advert") {
        $.post('http://phone/LoadAdverts', JSON.stringify({}), function(Adverts){
            BJ.Phone.Functions.RefreshAdverts(Adverts);
        })
    } else if (PressedApplication == "garage") {
        $.post('http://phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
            SetupGarageVehicles(Vehicles);
        })
    } else if (PressedApplication == "crypto") {
        $.post('http://phone/GetCryptoData', JSON.stringify({
            crypto: "bjcoin",
        }), function(CryptoData){
            SetupCryptoData(CryptoData);
        })

        $.post('http://phone/GetCryptoTransactions', JSON.stringify({}), function(data){
            RefreshCryptoTransactions(data);
        })
        $.post('http://phone/GetBankContacts', JSON.stringify({}), function(contacts){
            BJ.Phone.Functions.LoadCryptoContactsWithNumber(contacts);
        });
    } else if (PressedApplication == "racing") {
        $.post('http://phone/GetAvailableRaces', JSON.stringify({}), function(Races){
            SetupRaces(Races);
        });
    } else if (PressedApplication == "houses") {
        $.post('http://phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
            SetupPlayerHouses(Houses);
        });
        $.post('http://phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
            $(".house-app-mykeys-container").html("");
            if (Keys.length > 0) {
                $.each(Keys, function(i, key){
                    var elem = '<div class="mykeys-key" id="keyid-'+i+'"> <span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Klik om GPS in te stellen</span> </div>';

                    $(".house-app-mykeys-container").append(elem);
                    $("#keyid-"+i).data('KeyData', key);
                });
            }
        });
    } else if (PressedApplication == "lawyers") {
        $.post('http://phone/GetCurrentLawyers', JSON.stringify({}), function(data){
            SetupLawyers(data);
        });
    } else if (PressedApplication == "store") {
        $.post('http://phone/SetupStoreApps', JSON.stringify({}), function(data){
            SetupAppstore(data); 
        });
    } else if (PressedApplication == "trucker") {
        $.post('http://phone/GetTruckerData', JSON.stringify({}), function(data){
            SetupTruckerInfo(data);
        });
    } else if (PressedApplication == "notes") {
        $.post('http://phone/GetNoteData', JSON.stringify({}), function(data){
            SetupNotes(data);
        });
    }
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (BJ.Phone.Data.currentApplication == null) {
                BJ.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                BJ.Phone.Functions.ToggleApp(PressedApplication, "block");
                
                if (BJ.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    BJ.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                BJ.Phone.Data.currentApplication = PressedApplication;
    
                RefreshApplicationData(PressedApplication);
            }
        }
    } else {
        BJ.Phone.Notifications.Add("fas fa-exclamation-circle", "System", BJ.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('http://phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (BJ.Phone.Data.currentApplication === null) {
        BJ.Phone.Functions.Close();
    } else {
        BJ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        BJ.Phone.Animations.TopSlideUp('.'+BJ.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            BJ.Phone.Functions.ToggleApp(BJ.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        BJ.Phone.Functions.HeaderTextColor("white", 300);

        if (BJ.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (BJ.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        }

        BJ.Phone.Data.currentApplication = null;
    }
});

let lowBattery = false;
let flashTimer = 750;

BJ.Phone.Functions.Open = async function(data) {
    BJ.Phone.Animations.BottomSlideUp('.container', 300, 0);
    BJ.Phone.Notifications.LoadTweets(data.Tweets);
    BJ.Phone.Data.IsOpen = true;

    await BJ.Phone.Functions.LowBatteryMode(data.phoneDisabled);
    if (BJ.Phone.Data.currentApplication !== null) {
        RefreshApplicationData(BJ.Phone.Data.currentApplication);
    }
}

BJ.Phone.Functions.LowBatteryMode = function(isLowBattery) {
    return new Promise(resolve => {
        isLowBattery = isLowBattery == true;

        if (lowBattery != isLowBattery) {
            lowBattery = isLowBattery;

            if (isLowBattery) {
                $('.low-battery-container').show();
                $('.low-battery').animate({opacity: 0}, flashTimer, () => {
                    $('.low-battery').animate({opacity: 1}, flashTimer, () => {
                        $('.low-battery').animate({opacity: 0}, flashTimer, () => {
                            $('.low-battery').animate({opacity: 1}, flashTimer, () => {
                                $('.low-battery').animate({opacity: 0}, flashTimer, () => {
                                    $('.low-battery').animate({opacity: 1}, flashTimer, () => {
                                        $('.low-battery').animate({opacity: 0}, flashTimer, () => {
                                            resolve();
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
                lowBattery = false;
            } else {
                $('.phone-loading').show().css({top:0});
                $('.low-battery-container').hide();
                setTimeout(() => {
                    BJ.Phone.Animations.TopSlideUp('.phone-loading', 300, -160);
                    resolve();
                }, 1500);
            }
        }
        else {
            resolve();
        }
    });
}

BJ.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

BJ.Phone.Functions.Close = function() {

    if (BJ.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            BJ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            BJ.Phone.Animations.TopSlideUp('.'+BJ.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            BJ.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            BJ.Phone.Data.currentApplication = null;
        }, 500)
    }

    BJ.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('http://phone/Close');
    BJ.Phone.Data.IsOpen = false;
}

BJ.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

BJ.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

BJ.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

BJ.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

BJ.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

BJ.Phone.Notifications.Add = function(icon, title, text, color, timeout, type, cb) {
    if (cb == null && cb == undefined) {
        if (type && type == 'system-info') {
            NotificationQueue.unshift({
                icon,
                title,
                text,
                color,
                type: type ?? title
            })
        } else {;
            NotificationQueue.push({
                icon,
                title,
                text,
                color,
                type: type ?? title
            });
        }
    }
    else {
        $.post('http://phone/HasPhone', JSON.stringify({}), function(HasPhone){
            if (HasPhone) {
                if (timeout == null && timeout == undefined) {
                    timeout = 1500;
                }
                if (BJ.Phone.Notifications.Timeout == undefined || BJ.Phone.Notifications.Timeout == null) {
                    if (color != null || color != undefined) {
                        $(".notification-icon").css({"color":color});
                        $(".notification-title").css({"color":color});
                    } else if (color == "default" || color == null || color == undefined) {
                        $(".notification-icon").css({"color":"#e74c3c"});
                        $(".notification-title").css({"color":"#e74c3c"});
                    }
                    BJ.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                    $(".notification-title").html(title);
                    $(".notification-text").html(text);
                    if (BJ.Phone.Notifications.Timeout !== undefined || BJ.Phone.Notifications.Timeout !== null) {
                        clearTimeout(BJ.Phone.Notifications.Timeout);
                    }
                    BJ.Phone.Notifications.Timeout = setTimeout(function(){
                        BJ.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                        BJ.Phone.Notifications.Timeout = null;
                        if (cb) {
                            cb();
                        }
                    }, timeout);
                } else {
                    if (color != null || color != undefined) {
                        $(".notification-icon").css({"color":color});
                        $(".notification-title").css({"color":color});
                    } else {
                        $(".notification-icon").css({"color":"#e74c3c"});
                        $(".notification-title").css({"color":"#e74c3c"});
                    }
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                    $(".notification-title").html(title);
                    $(".notification-text").html(text);
                    if (BJ.Phone.Notifications.Timeout !== undefined || BJ.Phone.Notifications.Timeout !== null) {
                        clearTimeout(BJ.Phone.Notifications.Timeout);
                    }
                    BJ.Phone.Notifications.Timeout = setTimeout(function(){
                        BJ.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                        BJ.Phone.Notifications.Timeout = null;
                        if (cb) {
                            cb();
                        }
                    }, timeout);
                }
            }
        });
    }
}

BJ.Phone.Functions.LoadPhoneData = function(data) {
    BJ.Phone.Data.PlayerData = data.PlayerData;
    BJ.Phone.Data.PlayerJob = data.PlayerJob;
    BJ.Phone.Data.MetaData = data.PhoneData.MetaData;
    BJ.Phone.Data.Settings = data.PhoneData.Settings;
    BJ.Phone.Data.Camera = data.PhoneData.Camera;
    BJ.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    BJ.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    SetupNotes(data.PhoneData.Notes)
    BJ.Phone.Functions.SetupApplications(data);

    if (data.PhoneData.Camera && data.PhoneData.Camera.Enabled) {
        $('#take-photo').show();
        $('#tw-take-photo').show();
    } else {
        $('#take-photo').hide();
        $('#tw-take-photo').hide();
    }
    // console.log("Phone succesfully loaded!");
}

BJ.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html(MessageTime + " <span style='font-size: 1.1vh;'>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

BJ.Phone.Functions.UploadPhoto = function(base64Data, cb) {
    if (base64Data.indexOf('data:image/') > -1) {
        base64Data = base64Data.replace('data:image/jpeg;base64,', '').replace('data:image/jpg;base64,', '').replace('data:image/png;base64,', '');
    }

    var xhttp = new XMLHttpRequest();

    xhttp.open('POST', 'https://api.imgur.com/3/image', true);
    xhttp.setRequestHeader('Content-Type', 'application/json');
    xhttp.setRequestHeader('Authorization', 'Client-ID ' + BJ.Phone.Data.Camera.ImgurClientId);
    xhttp.onreadystatechange = function () {
        if (this.readyState === 4) {
            if (this.status >= 200 && this.status < 300) {
                var response = '';
                try {
                    response = JSON.parse(this.responseText);
                } catch (err) {
                    response = this.responseText;
                }
                if (cb) cb(response);
            } else {
                throw new Error(this.status + " - " + this.statusText);
            }
        }
    };
    xhttp.send(JSON.stringify({
        image: base64Data,
        type: 'base64'
    }));
    xhttp = null;
}

var NotificationTimeout = null;

BJ.Screen.Notification = function(title, content, icon, timeout, color, type, cb) {
    if (cb == null || cb == undefined) {
        if (type && type == 'system-info') {
            NotificationQueue.unshift({
                icon,
                title,
                text: content,
                color,
                type: type ?? title
            })
        } else {
            NotificationQueue.push({
                icon,
                title,
                text: content,
                color,
                type: type ?? title
            });
        }
    }
    else {
        $.post('http://phone/HasPhone', JSON.stringify({}), function(HasPhone){
            if (HasPhone) {
                if (color != null && color != undefined) {
                    $(".screen-notifications-container").css({"background-color":color});
                }
                $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
                $(".screen-notification-title").text(title);
                $(".screen-notification-content").text(content);
                $(".screen-notifications-container").css({'display':'block'}).animate({
                    right: 5+"vh",
                }, 200);
            
                if (NotificationTimeout != null) {
                    clearTimeout(NotificationTimeout);
                }
            
                NotificationTimeout = setTimeout(function(){
                    $(".screen-notifications-container").animate({
                        right: -35+"vh",
                    }, 200, function(){
                        $(".screen-notifications-container").css({'display':'none'});
                    });
                    NotificationTimeout = null;
                    if (cb) {
                        cb();
                    }
                }, timeout);
            }
        });
    }
}

DoNotifCheck = function() {
    if (NotificationQueue.length > 0) {
        let notif = NotificationQueue.shift();
        
        if (!(notif.type && BJ.Phone.Data.Settings && BJ.Phone.Data.Settings.DisabledNotificationTypes &&
            BJ.Phone.Data.Settings.DisabledNotificationTypes.indexOf(notif.type) > -1)) {
            
            if (BJ.Phone.Data.IsOpen) {
                BJ.Phone.Notifications.Add(notif.icon, notif.title, notif.text, notif.color, notif.timeout, notif.type, () => {
                    setTimeout(DoNotifCheck, 250);
                });
            } else {
                BJ.Screen.Notification(notif.title, notif.text, notif.icon, notif.timeout ?? 3500, notif.color, notif.type, () => {
                    setTimeout(DoNotifCheck, 250);
                });
            }
        } else {
            console.log('Notification skipped: ', notif);
            setTimeout(DoNotifCheck, 100);
        }
    } else {
        setTimeout(DoNotifCheck, 500);
    }
}

setTimeout(DoNotifCheck, 500);

// BJ.Screen.Notification("Nieuwe Tweet", "Dit is een test tweet like #YOLO", "fab fa-twitter", 4000);

$(document).ready(function(){
    window.addEventListener('message', async function(event) {
        switch(event.data.action) {
            case "open":
                await BJ.Phone.Functions.Open(event.data);
                BJ.Phone.Functions.SetupAppWarnings(event.data.AppData);
                BJ.Phone.Functions.SetupCurrentCall(event.data.CallData);
                BJ.Phone.Data.IsOpen = true;
                BJ.Phone.Data.PlayerData = event.data.PlayerData;
                BJ.Phone.Data.Currency = event.data.HtmlCurrency;
                break;
            case "close":
                BJ.Phone.Functions.Close();
                break;
            case "disablePhone":
                BJ.Phone.Functions.LowBatteryMode(event.data.phoneDisabled);
                break;                
            case "photoDisplay":
                if (event.data.show) {
                    $('.container').show();
                } else {
                    $('.container').hide();
                }
                break;
            case "RefreshSettings":
                BJ.Phone.Data.Settings = event.data.Settings;
                break;
            // case "LoadPhoneApplications":
            //     BJ.Phone.Functions.SetupApplications(event.data);
            //     break;
            case "LoadPhoneData":
                BJ.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                BJ.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                BJ.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color, event.data.NotifyData.type);
                break;
            case "PhoneNotification":
                BJ.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout, event.data.PhoneNotify.type);
                break;
            case "RefreshAppAlerts":
                BJ.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                BJ.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html(BJ.Phone.Data.Currency+" "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (BJ.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        BJ.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        BJ.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                BJ.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                BJ.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('http://phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('http://phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                BJ.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                BJ.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!BJ.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                BJ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    BJ.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                BJ.Phone.Functions.HeaderTextColor("white", 300);
    
                BJ.Phone.Data.CallActive = false;
                BJ.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                BJ.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                BJ.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (BJ.Phone.Data.currentApplication == "advert") {
                    BJ.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                BJ.Phone.Data.PlayerJob = event.data.JobData;
                BJ.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('http://phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                BJ.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "RefreshNotes":
                SetupNotes(event.data.Notes);
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            BJ.Phone.Functions.Close();
            break;
    }
});

// BJ.Phone.Functions.Open();
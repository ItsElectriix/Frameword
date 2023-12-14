var OpenedMail = null;

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    BJ.Phone.Functions.SetupMail(MailData);

    OpenedMail = $(this).attr('id');
});

$(document).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
});

$(document).on('click', '#accept-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('http://phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        mailId: MailData.mailid,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '#remove-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('http://phone/RemoveMail', JSON.stringify({
        mailId: MailData.mailid
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

BJ.Phone.Functions.SetupMails = function(Mails) {
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
    var MessageTime = Hourssssss + ":" + Minutessss;

    $("#mail-header-mail").html(BJ.Phone.Data.PlayerData.charinfo.firstname+"."+BJ.Phone.Data.PlayerData.charinfo.lastname+"@cols.com");
    $("#mail-header-lastsync").html("Last synchronized "+MessageTime);
    if (Mails !== null && Mails !== undefined) {
        if (Mails.length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var date = new Date(mail.date);
                var DateString = date.getDate()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
                var element = '<div class="mail" id="mail-'+mail.mailid+'"><span class="mail-sender" style="font-weight: bold;">'+mail.sender+'</span> <div class="mail-text"><p>'+mail.subject+'</p></div> <div class="mail-time">'+DateString+'</div></div>';
    
                $(".mail-list").append(element);
                $("#mail-"+mail.mailid).data('MailData', mail);
            });
        } else {
            $(".mail-list").html('<p class="nomails">You don\'t have any mails..</p>');
        }

    }
}

var MonthFormatting = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

BJ.Phone.Functions.SetupMail = function(MailData) {
    var date = new Date(MailData.date);
    var DateString = date.getDate()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    $(".mail-subject").html("<p><span style='font-weight: bold;'>"+MailData.sender+"</span><br>"+MailData.subject+"</p>");
    $(".mail-date").html("<p>"+DateString+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");

    var AcceptElem = '<div class="opened-mail-footer-item" id="accept-mail"><i class="fas fa-check-circle mail-icon"></i></div>';
    var RemoveElem = '<div class="opened-mail-footer-item" id="remove-mail"><i class="fas fa-trash-alt mail-icon"></i></div>';

    $(".opened-mail-footer").html("");    

    if (MailData.button !== undefined && MailData.button !== null) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"100%"});
    }
}

// Advert JS

$(document).on('click', '.test-slet', function(e){
    e.preventDefault();

    $(".advert-home").animate({
        left: 30+"vh"
    });
    $(".new-advert").animate({
        left: 0+"vh"
    });
});

$(document).on('click', '#new-advert-back', function(e){
    e.preventDefault();

    $(".advert-home").animate({
        left: 0+"vh"
    });
    $(".new-advert").animate({
        left: -30+"vh"
    });
});

$(document).on('click', '#new-advert-submit', function(e){
    e.preventDefault();

    var Advert = $(".new-advert-textarea").val();

    if (Advert !== "") {
        if (BJ.Phone.Functions.ContainsBlacklistedText(Advert)) {
            BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", "There was an issue sending this tweet", "#1DA1F2", 1750);
            BJ.Phone.Notifications.Add("fas fa-ad", "Advertisement", "There was an issue posting this advert", "#ff8f1a", 1750);
        } else {
            $(".advert-home").animate({
                left: 0+"vh"
            });
            $(".new-advert").animate({
                left: -30+"vh"
            });
            $.post('http://phone/PostAdvert', JSON.stringify({
                message: Advert,
            }));
        }
    } else {
        BJ.Phone.Notifications.Add("fas fa-ad", "Advertisement", "You can\'t post an empty ad!", "#ff8f1a", 2000);
    }
});

$(document).on('click', '.advert-call', function(e){
    e.preventDefault();

    let advertData = $(this).closest('.advert').data('advert');
    
    if (advertData.number !== BJ.Phone.Data.PlayerData.charinfo.phone) {
        $('.advert-application-container').animate({
            top: -160+"%"
        });
        BJ.Phone.Functions.HeaderTextColor("white", 400);
        setTimeout(function(){
            $('.advert-application-container').animate({
                top: 0+"%"
            });
    
            let name = advertData.number;

            if (BJ.Phone.Contacts) {
                $.each(BJ.Phone.Contacts, (i, contact) => {
                    if (contact.number == advertData.number) {
                        name = contact.name;
                    }
                });
            }
        
            BJ.Phone.Functions.ToggleApp("advert", "none");
            SetupCall({
                name: name,
                number: advertData.number
            });
        }, 400)
    } else {
        BJ.Phone.Notifications.Add("fa fa-phone-alt", "Phone", "You can't call yourself", "default", 3500);
    }
});

$(document).on('click', '.advert-message', function(e){
    e.preventDefault();

    let advertData = $(this).closest('.advert').data('advert');

    if (advertData.number !== BJ.Phone.Data.PlayerData.charinfo.phone) {
        $('.advert-application-container').animate({
            top: -160+"%"
        });
        BJ.Phone.Functions.HeaderTextColor("white", 400);
        setTimeout(function(){
            $('.advert-application-container').animate({
                top: 0+"%"
            });
    
            BJ.Phone.Functions.ToggleApp("advert", "none");
            BJ.Phone.Functions.ToggleApp("whatsapp", "block");
            BJ.Phone.Data.currentApplication = "whatsapp";

            let name = advertData.number;

            if (BJ.Phone.Contacts) {
                $.each(BJ.Phone.Contacts, (i, contact) => {
                    if (contact.number == advertData.number) {
                        name = contact.name;
                    }
                });
            }
        
            $.post('http://phone/GetWhatsappChat', JSON.stringify({phone: advertData.number}), function(chat){
                BJ.Phone.Functions.SetupChatMessages(chat, {
                    name: name,
                    number: advertData.number
                });
            });
        
            $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);
            $(".whatsapp-openedchat").css({"display":"block"});
            $(".whatsapp-openedchat").css({left: 0+"vh"});
            $(".whatsapp-chats").animate({left: 30+"vh"},100, function(){
                $(".whatsapp-chats").css({"display":"none"});
            });
        }, 400)
    } else {
        BJ.Phone.Notifications.Add("fa fa-phone-alt", "Phone", "You can't whatsapp yourself", "default", 3500);
    }
});

BJ.Phone.Functions.RefreshAdverts = function(Adverts) {
    $("#advert-header-name").html("@"+BJ.Phone.Data.PlayerData.charinfo.firstname+""+BJ.Phone.Data.PlayerData.charinfo.lastname+" | "+BJ.Phone.Data.PlayerData.charinfo.phone);
    if (Adverts.length > 0 || Adverts.length == undefined) {
        $(".advert-list").html("");
        $.each(Adverts, function(i, advert){
            var element = '<div class="advert" data-id="' + i + '"><span class="advert-sender">'+advert.name+' | '+advert.number+' | <i class="fas fa-phone advert-call"></i><i class="fas fa-comment-alt advert-message"></i></span><p>'+BJ.Phone.Functions.StripAngledBrackets(advert.message)+'</p></div>';
            $(".advert-list").append(element);
            $('.advert[data-id=' + i + ']').data('advert', advert);
        });
    } else {
        $(".advert-list").html("");
        var element = '<div class="advert"><span class="advert-sender">There are no advertisements yet!</span></div>';
        $(".advert-list").append(element);
    }
}
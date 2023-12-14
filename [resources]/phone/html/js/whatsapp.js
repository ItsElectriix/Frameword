var WhatsappSearchActive = false;
var OpenedChatPicture = null;

$(document).ready(function(){
    $("#whatsapp-search-input").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".whatsapp-chats .whatsapp-chat").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '#whatsapp-search-chats', function(e){
    e.preventDefault();

    if ($("#whatsapp-search-input").css('display') == "none") {
        $("#whatsapp-search-input").fadeIn(150);
        WhatsappSearchActive = true;
    } else {
        $("#whatsapp-search-input").fadeOut(150);
        WhatsappSearchActive = false;
    }
});

$(document).on('click', '.whatsapp-chat', function(e){
    e.preventDefault();

    var ChatId = $(this).attr('id');
    var ChatData = $("#"+ChatId).data('chatdata');

    BJ.Phone.Functions.SetupChatMessages(ChatData);

    $.post('http://phone/ClearAlerts', JSON.stringify({
        number: ChatData.number
    }));

    if (WhatsappSearchActive) {
        $("#whatsapp-search-input").fadeOut(150);
    }

    $(".whatsapp-openedchat").css({"display":"block"});
    $(".whatsapp-openedchat").animate({
        left: 0+"vh"
    },200);
    
    $(".whatsapp-chats").animate({
        left: 30+"vh"
    },200, function(){
        $(".whatsapp-chats").css({"display":"none"});
    });

    $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);

    if (OpenedChatPicture == null) {
        OpenedChatPicture = "./img/default.png";
        if (ChatData.picture != null || ChatData.picture != undefined || ChatData.picture != "default") {
            OpenedChatPicture = ChatData.picture
        }
        $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
    }
});

$(document).on('click', '#whatsapp-openedchat-back', function(e){
    e.preventDefault();
    $.post('http://phone/GetWhatsappChats', JSON.stringify({}), function(chats){
        BJ.Phone.Functions.LoadWhatsappChats(JSON.parse(chats));
    });
    OpenedChatData.number = null;
    $(".whatsapp-chats").css({"display":"block"});
    $(".whatsapp-chats").animate({
        left: 0+"vh"
    }, 200);
    $(".whatsapp-openedchat").animate({
        left: -30+"vh"
    }, 200, function(){
        $(".whatsapp-openedchat").css({"display":"none"});
    });
    OpenedChatPicture = null;
});

BJ.Phone.Functions.GetLastMessage = function(messages) {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth();
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var LastDate = new Date(1990, 0, 1);
    var LastMessageData = {
        time: "00:00",
        date: "Today",
        message: "nothing"
    }

    $.each(messages, function(i, msg){
        var msgData = msg.messages[msg.messages.length - 1];
        var TestDate = msg.date.split("-");
        var TestTime = msgData.time.split(':');
        var thisDate = new Date(TestDate[2], parseInt(TestDate[1]) - 1, TestDate[0], TestTime[0], TestTime[1]);
        if (LastDate < thisDate) {
            LastMessageData.time = msgData.time;
            LastMessageData.message = BJ.Phone.Functions.StripAngledBrackets(msgData.message);
            LastMessageData.date = msg.date;
            LastDate = thisDate;
        }
    });

    return LastMessageData
}

GetCurrentDateKey = function() {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth() + 1;
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var CurDate = ""+CurrentDOM+"-"+CurrentMonth+"-"+CurrentYear+"";

    return CurDate;
}

BJ.Phone.Functions.LoadWhatsappChats = function(chats) {
    $(".whatsapp-chats").html("");
    var items = Object.keys(chats).map(function(key) {
        return [key, chats[key]];
    }).sort(function(a, b) {
        return b[1].last_updated - a[1].last_updated;
    });
    $.each(items, function(k, chatDict){
        var i = chatDict[0];
        var chat = chatDict[1];
        var profilepicture = "./img/default.png";
        if (chat.picture !== "default") {
            profilepicture = chat.picture
        }
        var LastMessage = BJ.Phone.Functions.GetLastMessage(chat.messages);
        var chatDate = FormatChatDate(LastMessage.date);
        if (LastMessage.date == "Today") {
            chatDate = LastMessage.time
        }
        var ChatElement = '<div class="whatsapp-chat" id="whatsapp-chat-'+i+'"><div class="whatsapp-chat-picture" style="background-image: url('+profilepicture+');"></div><div class="whatsapp-chat-name"><p>'+chat.name+'</p></div><div class="whatsapp-chat-lastmessage"><p>'+BJ.Phone.Functions.StripAngledBrackets(LastMessage.message)+'</p></div> <div class="whatsapp-chat-lastmessagetime"><p>'+chatDate+'</p></div><div class="whatsapp-chat-unreadmessages unread-chat-id-'+i+'">1</div></div>';
        
        $(".whatsapp-chats").append(ChatElement);
        $("#whatsapp-chat-"+i).data('chatdata', chat);

        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

BJ.Phone.Functions.ReloadWhatsappAlerts = function(chats) {
    $.each(chats, function(i, chat){
        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

const monthNames = ["January", "February", "March", "April", "May", "June", "JulY", "August", "September", "October", "November", "December"];

FormatChatDate = function(date) {
    var TestDate = date.split("-");
    var NewDate = new Date(TestDate[2], parseInt(TestDate[1]) - 1, TestDate[0]);

    var CurrentMonth = monthNames[NewDate.getMonth()];
    var CurrentDOM = NewDate.getDate();
    var CurrentYear = NewDate.getFullYear();
    var CurDateee = CurrentDOM + "-" + (NewDate.getMonth() + 1) + "-" + CurrentYear;
    var ChatDate = CurrentDOM + " " + CurrentMonth + " " + CurrentYear;
    var CurrentDate = GetCurrentDateKey();

    var ReturnedValue = ChatDate;
    if (CurrentDate == CurDateee) {
        ReturnedValue = "Today";
    }

    return ReturnedValue;
}

FormatMessageTime = function() {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    if (NewHour < 10) {
        Hourssssss = "0" + NewHour;
    }
    var MessageTime = Hourssssss + ":" + Minutessss
    return MessageTime;
}

$(document).on('click', '#whatsapp-openedchat-send', function(e){
    e.preventDefault();

    var Message = $("#whatsapp-openedchat-message").val();

    if (Message !== null && Message !== undefined && Message !== "") {
        if (BJ.Phone.Functions.ContainsBlacklistedText(Message)) {
            BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "There was an issue sending this message", "#25D366", 1750);
        } else {
            $.post('http://phone/SendMessage', JSON.stringify({
                ChatNumber: OpenedChatData.number,
                ChatDate: GetCurrentDateKey(),
                ChatMessage: BJ.Phone.Functions.StripAngledBrackets(Message),
                ChatTime: FormatMessageTime(),
                ChatType: "message",
                ChatTS: new Date().valueOf()
            }));
            $("#whatsapp-openedchat-message").val("");
        }
    } else {
        BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "You can't send a empty message", "#25D366", 1750);
    }
});

$(document).on('keypress', function (e) {
    if (OpenedChatData.number !== null) {
        if(e.which === 13){
            var Message = $("#whatsapp-openedchat-message").val();
    
            if (Message !== null && Message !== undefined && Message !== "") {
                if (BJ.Phone.Functions.ContainsBlacklistedText(Message)) {
                    BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "There was an issue sending this message", "#25D366", 1750);
                } else {
                    $.post('http://phone/SendMessage', JSON.stringify({
                        ChatNumber: OpenedChatData.number,
                        ChatDate: GetCurrentDateKey(),
                        ChatMessage: BJ.Phone.Functions.StripAngledBrackets(Message),
                        ChatTime: FormatMessageTime(),
                        ChatType: "message",
                        ChatTS: new Date().valueOf()
                    }));
                    $("#whatsapp-openedchat-message").val("");
                }
            } else {
                BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "You can't send a empty message", "#25D366", 1750);
            }
        }
    }
});

$(document).on('click', '#send-location', function(e){
    e.preventDefault();

    $.post('http://phone/SendMessage', JSON.stringify({
        ChatNumber: OpenedChatData.number,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Shared location",
        ChatTime: FormatMessageTime(),
        ChatType: "location",
        ChatTS: new Date().valueOf()
    }));
    CloseExtraButtons();
});

$(document).on('click', '#take-photo', function(e) {
    $.post('http://phone/TakePhoto', JSON.stringify({}), function(data) {
        $('whatsapp-loading').show();
        CloseExtraButtons();
        if (data == false) {
            $('whatsapp-loading').hide();
            return;
        }
        if (data && typeof(data) === 'string') {
            try {
                data = JSON.parse(data)
            }
            catch {}

            if (data.base64) {
                BJ.Phone.Functions.UploadPhoto(data.base64, (result) => {
                    $('whatsapp-loading').hide();
                    if (result && result.success && result.data) {
                        var Message = $("#whatsapp-openedchat-message").val();

                        if (Message && Message.length > 0) {
                            Message = `${Message} ${result.data.link} `;
                        } else {
                            Message = `${result.data.link} `;
                        }

                        $("#whatsapp-openedchat-message").val(Message);
                        $("#whatsapp-openedchat-message").focus();
                    } else {
                        BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "There was an error uploading your photo", "#25D366", 1750);
                    }
                });
                return;
            }
        }
        $('whatsapp-loading').hide();
        BJ.Phone.Notifications.Add("fab fa-whatsapp", "Whatsapp", "There was an error uploading your photo", "#25D366", 1750);
    })
});

// BJ.Phone.Functions.SetupChatMessages = function(cData, NewChatData) {
//     if (cData) {
//         OpenedChatData.number = cData.number;

//         if (OpenedChatPicture == null) {
//             $.post('http://phone/GetProfilePicture', JSON.stringify({
//                 number: OpenedChatData.number,
//             }), function(picture){
//                 OpenedChatPicture = "./img/default.png";
//                 if (picture != "default" && picture != null) {
//                     OpenedChatPicture = picture
//                 }
//                 $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
//             });
//         } else {
//             $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
//         }

//         $(".whatsapp-openedchat-name").html("<p>"+cData.name+"</p>");
//         $(".whatsapp-openedchat-messages").html("");

//         $.each(cData.messages, function(i, chat){
//             var ChatDate = FormatChatDate(i);
//             var ChatDiv = '<div class="whatsapp-openedchat-messages-'+i+' unique-chat"><div class="whatsapp-openedchat-date">'+ChatDate+'</div></div>';
    
//             $.each(cData.messages[i], function(index, message){
//                 var Sender = "me";
//                 if (message.sender !== BJ.Phone.Data.PlayerData.citizenid) { Sender = "other"; }
//                 var MessageElement
//                 if (message.type == "message") {
//                     MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+'" data-toggle="tooltip" data-placement="bottom" title="'+ChatDate+'">'+message.message+'<div class="whatsapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
//                 } else if (message.type == "location") {
//                     MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+' whatsapp-shared-location" data-x="'+message.data.x+'" data-y="'+message.data.y+'" data-toggle="tooltip" data-placement="bottom" title="'+ChatDate+'"><span style="font-size: 1.2vh;"><i class="fas fa-thumbtack" style="font-size: 1vh;"></i> Locatie</span><div class="whatsapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
//                 }
//                 $(".whatsapp-openedchat-messages").append(MessageElement);

//                 $('[data-toggle="tooltip"]').tooltip();
//             });
//         });
//         $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
//     } else {
//         OpenedChatData.number = NewChatData.number;
//         if (OpenedChatPicture == null) {
//             $.post('http://phone/GetProfilePicture', JSON.stringify({
//                 number: OpenedChatData.number,
//             }), function(picture){
//                 OpenedChatPicture = "./img/default.png";
//                 if (picture != "default" && picture != null) {
//                     OpenedChatPicture = picture
//                 }
//                 $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
//             });
//         }

//         $(".whatsapp-openedchat-name").html("<p>"+NewChatData.name+"</p>");
//         $(".whatsapp-openedchat-messages").html("");
//         // var NewDate = new Date();
//         // var NewDateMonth = NewDate.getMonth();
//         // var NewDateDOM = NewDate.getDate();
//         // var NewDateYear = NewDate.getFullYear();
//         // var DateString = ""+NewDateDOM+"-"+(NewDateMonth+1)+"-"+NewDateYear;
//         // var ChatDiv = '<div class="whatsapp-openedchat-messages-'+DateString+' unique-chat"></div>';
//         // $(".whatsapp-openedchat-messages").append(ChatDiv);
//     }

//     $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
// }

BJ.Phone.Functions.SetupChatMessages = function(cData, NewChatData) {
    if (cData) {
        OpenedChatData.number = cData.number;

        if (OpenedChatPicture == null) {
            $.post('http://phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        } else {
            $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
        }

        $(".whatsapp-openedchat-name").html("<p>"+cData.name+"</p>");
        $(".whatsapp-openedchat-messages").html("");

        $.each(cData.messages, function(i, chat){
            var ChatDate = FormatChatDate(chat.date);
            var ChatDiv = '<div class="whatsapp-openedchat-messages-'+i+' unique-chat"><div class="whatsapp-openedchat-date">'+ChatDate+'</div></div>';

            $(".whatsapp-openedchat-messages").append(ChatDiv);
    
            $.each(cData.messages[i].messages, function(index, message){
                var Sender = "me";
                if (message.sender !== BJ.Phone.Data.PlayerData.citizenid) { Sender = "other"; }
                var MessageElement
                if (message.type == "message") {
                    MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+'">'+BJ.Phone.Functions.StripAngledBrackets(message.message).replace(/(https?:\/\/\S+(\.png|\.jpg|\.gif))/g, '<img src="$1"/>')+'<div class="whatsapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                } else if (message.type == "location") {
                    MessageElement = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+Sender+' whatsapp-shared-location" data-x="'+message.data.x+'" data-y="'+message.data.y+'"><span style="font-size: 1.2vh;"><i class="fas fa-thumbtack" style="font-size: 1vh;"></i> Location</span><div class="whatsapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                }
                $(".whatsapp-openedchat-messages-"+i).append(MessageElement);
            });
        });
        $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
    } else {
        OpenedChatData.number = NewChatData.number;
        if (OpenedChatPicture == null) {
            $.post('http://phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".whatsapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        }

        $(".whatsapp-openedchat-name").html("<p>"+NewChatData.name+"</p>");
        $(".whatsapp-openedchat-messages").html("");
        var NewDate = new Date();
        var NewDateMonth = NewDate.getMonth();
        var NewDateDOM = NewDate.getDate();
        var NewDateYear = NewDate.getFullYear();
        var DateString = ""+NewDateDOM+"-"+(NewDateMonth+1)+"-"+NewDateYear;
        var ChatDiv = '<div class="whatsapp-openedchat-messages-'+DateString+' unique-chat"><div class="whatsapp-openedchat-date">TODAY</div></div>';

        $(".whatsapp-openedchat-messages").append(ChatDiv);
    }

    $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 1);
}

$(document).on('click', '.whatsapp-shared-location', function(e){
    e.preventDefault();
    var messageCoords = {}
    messageCoords.x = $(this).data('x');
    messageCoords.y = $(this).data('y');

    $.post('http://phone/SharedLocation', JSON.stringify({
        coords: messageCoords,
    }))
});

var ExtraButtonsOpen = false;

$(document).on('click', '#whatsapp-openedchat-message-extras', function(e){
    e.preventDefault();

    ToggleExtraButtons();
});

function ToggleExtraButtons() {
    if (!ExtraButtonsOpen) {
        $(".whatsapp-extra-buttons").css({"display":"block"}).animate({
            left: 0+"vh"
        }, 250);
        ExtraButtonsOpen = true;
    } else {
        $(".whatsapp-extra-buttons").animate({
            left: -10+"vh"
        }, 250, function(){
            $(".whatsapp-extra-buttons").css({"display":"block"});
            ExtraButtonsOpen = false;
        });
    }
}

function CloseExtraButtons() {
    if (ExtraButtonsOpen) {
        ToggleExtraButtons();
    }
}
var CurrentTwitterTab = "twitter-home"
var HashtagOpen = false;
var MinimumTrending = 10;

let viewport = document.querySelector('.twitter-home-tab')
let content = viewport.querySelector('.twitter-tweet-container')

let scr = new ScrollBooster({
    viewport: viewport,
    content: content,
    direction: 'vertical',
    emulateScroll: true,
    onUpdate: (data)=> {
      // viewport.scrollLeft = data.position.x
      // viewport.scrollTop = data.position.y
      content.style.transform = `translate(
        ${-data.position.x}px,
        ${-data.position.y}px
      )`
    },
    onPointerUp: (data) => {
        setTimeout(() => {
            if (data.position.y <= -75 && data.dragOffset.y >= 75) {
                $.post('http://phone/GetTweets', JSON.stringify({}), function(Tweets){
                    BJ.Phone.Notifications.LoadTweets(Tweets);
                });
            }
        }, 100);
    }
})


$(document).on('click', '.twitter-header-tab', function(e){
    e.preventDefault();

    var PressedTwitterTab = $(this).data('twittertab');
    var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');

    if (PressedTwitterTab !== CurrentTwitterTab) {
        $(this).addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');

        $("."+CurrentTwitterTab+"-tab").css({"display":"none"});
        $("."+PressedTwitterTab+"-tab").css({"display":"block"});

        if (PressedTwitterTab === "twitter-mentions") {
            $.post('http://phone/ClearMentions');
        }

        if (PressedTwitterTab == "twitter-home") {
            $.post('http://phone/GetTweets', JSON.stringify({}), function(Tweets){
                BJ.Phone.Notifications.LoadTweets(Tweets);
            });
        }

        CurrentTwitterTab = PressedTwitterTab;

        if (HashtagOpen) {
            event.preventDefault();

            $(".twitter-hashtag-tweets").css({"left": "30vh"});
            $(".twitter-hashtags").css({"left": "0vh"});
            $(".twitter-new-tweet").css({"display":"block"});
            $(".twitter-hashtags").css({"display":"block"});
            HashtagOpen = false;
        }
    } else if (CurrentTwitterTab == "twitter-hashtags" && PressedTwitterTab == "twitter-hashtags") {
        if (HashtagOpen) {
            event.preventDefault();

            $(".twitter-hashtags").css({"display":"block"});
            $(".twitter-hashtag-tweets").animate({
                left: 30+"vh"
            }, 150);
            $(".twitter-hashtags").animate({
                left: 0+"vh"
            }, 150);
            HashtagOpen = false;
        }
    } else if (CurrentTwitterTab == "twitter-home" && PressedTwitterTab == "twitter-home") {
        event.preventDefault();

        $.post('http://phone/GetTweets', JSON.stringify({}), function(Tweets){
            BJ.Phone.Notifications.LoadTweets(Tweets);
        });
    } else if (CurrentTwitterTab == "twitter-mentions" && PressedTwitterTab == "twitter-mentions") {
        event.preventDefault();

        $.post('http://phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
            BJ.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
        })
    }
});

$(document).on('click', '.twitter-new-tweet', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
});

BJ.Phone.Notifications.LoadTweets = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-tweet-container").html('<div class="twitter-home-refresh"><i class="fas fa-redo-alt"></i> Release to refresh</div>');
        $.each(Tweets, function(i, Tweet){
            var TwtMessage = BJ.Phone.Functions.FormatTwitterMessage(Tweet.message);
            var today = new Date();
            var TweetTime = new Date(Tweet.time);
            var diffMs = (today - TweetTime);
            var diffDays = Math.floor(diffMs / 86400000);
            var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
            var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
            var diffSeconds = Math.round(diffMs / 1000);
            var TimeAgo = diffSeconds + ' s';

            if (diffMins > 0) {
                TimeAgo = diffMins + ' m';
            } else if (diffHrs > 0) {
                TimeAgo = diffHrs + ' h';
            } else if (diffDays > 0) {
                TimeAgo = diffDays + ' d';
            }

            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png"
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }
            
            var TweetElement = '<div class="twitter-tweet" data-localid="' + i + '" data-twthandler="@'+TwitterHandle.replace(" ", "_")+'"><div class="tweet-reply"><i class="fas fa-reply"></i></div>'+
                '<div class="tweet-tweeter">'+Tweet.firstName+' '+Tweet.lastName+' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+' &middot; '+TimeAgo+'</span></div>'+
                '<div class="tweet-message">'+TwtMessage+'</div>'+
                '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div>' +
            '</div>';

            $(".twitter-tweet-container").append(TweetElement);
        });
    }
}

$(document).on('click', '.tweet-reply', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    var mentions = $(`.twitter-tweet-container .twitter-tweet[data-localid=${$(this).parent().data('localid')}] .mentioned-tag`);

    let currentUser = `@${BJ.Phone.Data.PlayerData.charinfo.firstname}_${BJ.Phone.Data.PlayerData.charinfo.lastname}`;

    if (TwtName == currentUser) {
        TwtName = ''
    } else {
        TwtName += ' ';
    }

    if (mentions) {
        for (var i = 0; i < mentions.length; i++) {
            if (currentUser != $(mentions[i]).text()) {
                TwtName = `${TwtName}${$(mentions[i]).text()} `;
            }
        }
    }

    $("#tweet-new-message").val(TwtName);
    BJ.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
});

BJ.Phone.Notifications.LoadMentionedTweets = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets.length > 0) {
        $(".twitter-mentions-tab").html("");
        $.each(Tweets, function(i, Tweet){
            var TwtMessage = BJ.Phone.Functions.FormatTwitterMessage(Tweet.message);
            var today = new Date();
            var TweetTime = new Date(Tweet.time);
            var diffMs = (today - TweetTime);
            var diffDays = Math.floor(diffMs / 86400000);
            var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
            var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
            var diffSeconds = Math.round(diffMs / 1000);
            var TimeAgo = diffSeconds + ' s';

            if (diffSeconds > 60) {
                TimeAgo = diffMins + ' m';
            } else if (diffMins > 60) {
                TimeAgo = diffHrs + ' h';
            } else if (diffHrs > 24) {
                TimeAgo = diffDays + ' d';
            }
    
            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png";
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }
    
            var TweetElement = 
            '<div class="twitter-tweet">'+
                '<div class="tweet-tweeter">'+Tweet.firstName+' '+Tweet.lastName+' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+' &middot; '+TimeAgo+'</span></div>'+
                '<div class="tweet-message">'+TwtMessage+'</div>'+
            '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div></div>';

            $(".twitter-mentioned-tweet").css({"background-color":"#F5F8FA"});
            $(".twitter-mentions-tab").append(TweetElement);
        });
    }
}

BJ.Phone.Functions.FormatTwitterMessage = function(TwitterMessage) {
    var TwtMessage = TwitterMessage;
    var res = TwtMessage.split("@");
    var tags = TwtMessage.split("#");
    var InvalidSymbols = [
        "[",
        "?",
        "!",
        "@",
        "#",
        "]",
    ]

    TwtMessage = BJ.Phone.Functions.StripAngledBrackets(TwtMessage);

    TwtMessage = TwtMessage.replace(/(@[A-Za-z0-9_]*)/gm, "<span class='mentioned-tag' data-mentiontag='$1' style='color: rgb(27, 149, 224);'>$1</span>");

    TwtMessage = TwtMessage.replace(/(#[A-Za-z0-9-_]*)/gm, "<span class='hashtag-tag-text' data-hashtag='$1' style='color: rgb(27, 149, 224);'>$1</span>");

    return TwtMessage.replace(/(https?:\/\/\S+(\.png|\.jpg|\.gif))/g, '<img src="$1" style="width: 100%" />')
}

$(document).on('click', '#send-tweet', function(e){
    e.preventDefault();

    var TweetMessage = $("#tweet-new-message").val();

    if (TweetMessage != "") {
        var CurrentDate = new Date();

        var hashtags = TweetMessage.match(/(#[A-Za-z0-9-_]*)/gm);

        if (BJ.Phone.Functions.ContainsBlacklistedText(TweetMessage)) {
            BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", "There was an issue sending this tweet", "#1DA1F2", 1750);
        } else {
            $.post('http://phone/PostNewTweet', JSON.stringify({
                Message: TweetMessage,
                Hashtags: hashtags,
                Date: CurrentDate,
                Picture: BJ.Phone.Data.MetaData.profilepicture
            }), function(Tweets){
                $("#tweet-new-message").val('');
                BJ.Phone.Notifications.LoadTweets(Tweets);

                $.post('http://phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                    BJ.Phone.Notifications.LoadHashtags(Hashtags)
                })
            });
            BJ.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
        }
    } else {
        BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Fill a message", "#1DA1F2");
    }
});

$(document).on('click', '#tw-take-photo', function(e) {
    $.post('http://phone/TakePhoto', JSON.stringify({}), function(data) {
        if (data == false) {
            return;
        }
        if (data && typeof(data) === 'string') {
            try {
                data = JSON.parse(data)
            }
            catch {}

            if (data.base64) {
                BJ.Phone.Functions.UploadPhoto(data.base64, (result) => {
                    if (result && result.success && result.data) {
                        var Message = $("#tweet-new-message").val();

                        if (Message && Message.length > 0) {
                            Message = `${Message} ${result.data.link} `;
                        } else {
                            Message = `${result.data.link} `;
                        }

                        $("#tweet-new-message").val(Message);
                        $("#tweet-new-message").focus();
                    } else {
                        BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", "There was an error uploading your photo", "#1DA1F2", 1750);
                    }
                });
                return;
            }
        }
        BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", "There was an error uploading your photo", "#1DA1F2", 1750);
    })
});

$(document).on('click', '#cancel-tweet', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
});

$(document).on('click', '.mentioned-tag', function(e){
    e.preventDefault();
    CopyMentionTag(this);
});

$(document).on('click', '.hashtag-tag-text', function(e){
    e.preventDefault();
    if (!HashtagOpen) {
        var Hashtag = $(this).data('hashtag');
        var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');
    
        $("#twitter-hashtags").addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');
    
        $("."+CurrentTwitterTab+"-tab").css({"display":"none"});
        $(".twitter-hashtags-tab").css({"display":"block"});
    
        $.post('http://phone/GetHashtagMessages', JSON.stringify({hashtag: Hashtag}), function(HashtagData){
            BJ.Phone.Notifications.LoadHashtagMessages(HashtagData.messages);
        });
    
        $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
        $(".twitter-hashtag-tweets").css({"left": "0vh"});
        $(".twitter-hashtags").css({"left": "-30vh"});
        $(".twitter-hashtags").css({"display":"none"});
        HashtagOpen = true;
    
        CurrentTwitterTab = "twitter-hashtags";
    }
});

function CopyMentionTag(elem) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(elem).data('mentiontag')).select();
    BJ.Phone.Notifications.Add("fab fa-twitter", "Twitter", $(elem).data('mentiontag')+ " copied", "rgb(27, 149, 224)", 1250);
    document.execCommand("copy");
    $temp.remove();
}

BJ.Phone.Notifications.LoadHashtags = function(hashtags) {
    if (hashtags !== null) {
        $(".twitter-hashtags").html("");
        $.each(hashtags, function(i, hashtag){
            var Elem = '';
            var TweetHandle = "Tweet";
            if (hashtag.messages.length > 1 ) {
               TweetHandle = "Tweets";
            }
            if (hashtag.messages.length >= MinimumTrending) {
                Elem = '<div class="twitter-hashtag" id="tag-'+hashtag.hashtag.replace('#', '')+'"><div class="twitter-hashtag-status">Trending in Los Santos</div> <div class="twitter-hashtag-tag">'+hashtag.hashtag+'</div> <div class="twitter-hashtag-messages">'+hashtag.messages.length+' '+TweetHandle+'</div> </div>';
            } else {
                Elem = '<div class="twitter-hashtag" id="tag-'+hashtag.hashtag.replace('#', '')+'"><div class="twitter-hashtag-status">Not trending</div> <div class="twitter-hashtag-tag">'+hashtag.hashtag+'</div> <div class="twitter-hashtag-messages">'+hashtag.messages.length+' '+TweetHandle+'</div> </div>';
            }
        
            $(".twitter-hashtags").append(Elem);
            $("#tag-"+hashtag.hashtag.replace('#', '')).data('tagData', hashtag);
        });
    }
}

BJ.Phone.Notifications.LoadHashtagMessages = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-hashtag-tweets").html("");
        $.each(Tweets, function(i, Tweet){
            var TwtMessage = BJ.Phone.Functions.FormatTwitterMessage(Tweet.message);
            var today = new Date();
            var TweetTime = new Date(Tweet.time);
            var diffMs = (today - TweetTime);
            var diffDays = Math.floor(diffMs / 86400000);
            var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
            var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
            var diffSeconds = Math.round(diffMs / 1000);
            var TimeAgo = diffSeconds + ' s';

            if (diffSeconds > 60) {
                TimeAgo = diffMins + ' m';
            } else if (diffMins > 60) {
                TimeAgo = diffHrs + ' h';
            } else if (diffHrs > 24) {
                TimeAgo = diffDays + ' d';
            }

            var TwitterHandle = Tweet.firstName + ' ' + Tweet.lastName
            var PictureUrl = "./img/default.png"
            if (Tweet.picture !== "default") {
                PictureUrl = Tweet.picture
            }
    
            var TweetElement = 
            '<div class="twitter-tweet">'+
                '<div class="tweet-tweeter">'+Tweet.firstName+' '+Tweet.lastName+' &nbsp;<span>@'+TwitterHandle.replace(" ", "_")+' &middot; '+TimeAgo+'</span></div>'+
                '<div class="tweet-message">'+TwtMessage+'</div>'+
            '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image"></div></div>';
                    
            $(".twitter-hashtag-tweets").append(TweetElement);
        });
    }
}


$(document).on('click', '.twitter-hashtag', function(event){
    event.preventDefault();

    var TweetId = $(this).attr('id');
    var TweetData = $("#"+TweetId).data('tagData');

    BJ.Phone.Notifications.LoadHashtagMessages(TweetData.messages);

    $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
    $(".twitter-hashtag-tweets").animate({
        left: 0+"vh"
    }, 150);
    $(".twitter-hashtags").animate({
        left: -30+"vh"
    }, 150, function(){
        $(".twitter-hashtags").css({"display":"none"});
    });
    HashtagOpen = true;
});
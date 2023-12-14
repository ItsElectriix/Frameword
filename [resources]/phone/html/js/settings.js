BJ.Phone.Settings = {};
BJ.Phone.Settings.Background = "default";
BJ.Phone.Settings.OpenedTab = null;
BJ.Phone.Settings.Backgrounds = {
    'default': {
        label: "Default"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;
var CacheNotifSettings = [];

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        BJ.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        BJ.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "notifications") {
        BJ.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        BJ.Phone.Settings.OpenedTab = PressedTab;
        CacheNotifSettings = BJ.Phone.Data.Settings.DisabledNotificationTypes;
        SetupNotificationSettings(CacheNotifSettings);
    } else if (PressedTab == "profilepicture") {
        BJ.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        BJ.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        BJ.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", BJ.Phone.Data.AnonymousCall);

        if (!BJ.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    } else if ($(this).hasClass('notif')) {
        setTimeout(() => {
            var checked = CacheNotifSettings.indexOf(PressedTab) > -1;
            if (!checked) {
                if (CacheNotifSettings.indexOf(PressedTab) < 0) {
                    CacheNotifSettings.push(PressedTab);
                }
                $(`#${PressedTab} p`).text('Off');
            } else {
                if (CacheNotifSettings.indexOf(PressedTab) > -1) {
                    CacheNotifSettings.splice(CacheNotifSettings.indexOf(PressedTab), 1);
                }
                $(`#${PressedTab} p`).text('On');
            }
        
            $(`.${PressedTab}-box`).prop('checked', checked);
        
            BJ.Phone.Data.Settings.DisabledNotificationTypes = CacheNotifSettings;
        
            $.post('http://phone/SaveSettings', JSON.stringify(BJ.Phone.Data.Settings));
        }, 100);
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = BJ.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", BJ.Phone.Settings.Backgrounds[BJ.Phone.Settings.Background].label+" is set")
        BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+BJ.Phone.Settings.Background+".png')"})
    } else {
        BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set")
        BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+BJ.Phone.Settings.Background+"')"});
    }

    $.post('http://phone/SetBackground', JSON.stringify({
        background: BJ.Phone.Settings.Background,
    }))
});

BJ.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        BJ.Phone.Settings.Background = MetaData.background;
    } else {
        BJ.Phone.Settings.Background = "default";
    }

    var hasCustomBackground = BJ.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+BJ.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+BJ.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

BJ.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(BJ.Phone.Settings.Backgrounds, function(i, background){
        if (BJ.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    //if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            BJ.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            BJ.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    //}
});

let urlMatch = new RegExp(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/gi);

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();
    var NewBackground = $(".custom-background-input").val();

    if (NewBackground.match(urlMatch)) {
        BJ.Phone.Settings.Background = NewBackground
        $(OldBackground).fadeOut(50, function(){
            $(OldBackground).remove();
        });
        $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        BJ.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
    } else {
        BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Invalid URL")
    }
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = BJ.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set")
        BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        if (ProfilePicture.match(urlMatch)) {
            BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set")
            BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
            $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
        } else {
            BJ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Invalid URL")
        }
    }
    $.post('http://phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    BJ.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    BJ.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    //if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            BJ.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            BJ.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    //}
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    BJ.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

SetupNotificationSettings = function(disabledNotifs) {
    $('.settings-notifications-tab .switch input[type=checkbox]').prop('checked', true);
    $('.settings-notifications-tab .settings-tab-description p').text('On');

    $.each(disabledNotifs, function(i, notif) {
        $(`.settings-notifications-tab div[data-settingstab=${notif}] .switch input[type=checkbox]`).prop('checked', false);
        $(`#${notif} p`).text('Off');
    });
};

$(document).on('click', '#accept-notifications', function(e){
    e.preventDefault();

    BJ.Phone.Data.Settings.DisabledNotificationTypes = CacheNotifSettings;

    $.post('http://phone/SaveSettings', JSON.stringify(BJ.Phone.Data.Settings));
    
    BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

$(document).on('click', '#cancel-notifications', function(e){
    e.preventDefault();
    
    BJ.Phone.Animations.TopSlideUp(".settings-"+BJ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});
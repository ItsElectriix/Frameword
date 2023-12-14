var charId = null;
let lastVoiceVal = '';
let currentTalkType = 'MIC';

window.addEventListener('message', function (event) {


    switch(event.data.action) {
        case 'tick':
            $(".container").css("display", event.data.show ? "none" : "block");
			//healthProgress.animate(event.data.health / 100);
			//armourProgress.animate(event.data.armor / 100);
			$('#healthSlider').css('height', event.data.health+'%');
			if (event.data.health > 33) {
				$('#healthbg').removeClass('pulse');
			} else {
				$('#healthbg').addClass('pulse');
			}
		    $('#armourSlider').css('height', event.data.armor+'%');
			if (event.data.armor == 0) {
				$('#armourbg').hide();
			} else {
				$('#armourbg').show();
			}
            $("#boxStamina").css("height", event.data.stamina + "%");
            break;
        case 'updateStatus':
            if (event.data.action == "updateStatus")
                updateStatus(event.data.st);        
//            updateStatus(event.data.hunger, event.data.thirst);            
            break;
        case 'showui':
            $('body').show();
            break;
        case 'hideui':
            $('body').hide();
            break;
        case 'set-voice':
            setVoiceLevel(event.data.value);
            break;
        case 'voice-color':
            setTalking(event.data.isTalking);
            break;
		case 'toko-update':
			setVoiceLevel(event.data.voiceVal);
			setTalking(event.data.isTalking);
            $('#microphoneSlider .fas').removeClass('fa-microphone').removeClass('walkie').removeClass('fa-mobile-alt').removeClass('fa-bullhorn');
			if (event.data.talkType == "PHONE") {
				$('#microphoneSlider .fas').addClass('fa-mobile-alt');
			}
			else if (event.data.talkType == "RADIO") {
				$('#microphoneSlider .fas').addClass('walkie');
			}
            else if (event.data.talkType == "MEGAPHONE") {
				$('#microphoneSlider .fas').addClass('fa-bullhorn');
			}
			else {
				$('#microphoneSlider .fas').addClass('fa-microphone');
			}
            currentTalkType = event.data.talkType;
			break;
		case 'range-update':
			setVoiceLevel(event.data.voiceVal);
			break;
		case 'type-update':
            if (currentTalkType == "MEGAPHONE" && event.data.talkType != "MEGAPHONE") {
                $("#microphoneSlider").css("height", lastVoiceVal + "%");
            }
			$('#microphoneSlider .fas').removeClass('fa-microphone').removeClass('walkie').removeClass('fa-mobile-alt').removeClass('fa-bullhorn');
			if (event.data.talkType == "PHONE") {
				$('#microphoneSlider .fas').addClass('fa-mobile-alt');
			}
			else if (event.data.talkType == "RADIO") {
				$('#microphoneSlider .fas').addClass('walkie');
			}
            else if (event.data.talkType == "MEGAPHONE") {
				$('#microphoneSlider .fas').addClass('fa-bullhorn');
                $("#microphoneSlider").css("height", "100%");
			}
			else {
				$('#microphoneSlider .fas').addClass('fa-microphone');
			}
            currentTalkType = event.data.talkType;
			break;
		case 'set-char':
			charId = event.data.charId;
			$('#mugshot').css('background-image', 'url(http://chars.lls.gg/api/chars/' + charId + '.jpg?t=' + Date.now().toString() + ')');
			setInterval(function() {
				$('#mugshot').css('background-image', 'url(http://chars.lls.gg/api/chars/' + charId + '.jpg?t=' + Date.now().toString() + ')');
			}, 60000);
			break;
    }
});

function setVoiceLevel(val) {
    if (currentTalkType != "MEGAPHONE") {
        $("#microphoneSlider").css("height", val + "%");
    }
    lastVoiceVal = val;
}

function setTalking(isTalking) {
	if (isTalking) {
        $('#microphonebg').addClass('active');
    } else {
        $('#microphonebg').removeClass('active');
    }
}

var drugEnabled = true;

function updateStatus(status){
    $('#boxHunger').css('height', status.hunger+'%')
    $('#boxThirst').css('height', status.thirst+'%')
    $('#boxStress').css('height', status.stress+'%')
	if (status.stress < 100) {
		$('#stressbg').fadeIn();
	} else {
		$('#stressbg').fadeOut();
	}
	if (status.drug >= 1) {
		if (!drugEnabled) {
			drugEnabled = true;
			$("#drugbg").fadeIn();
		}
		$('#boxDrug').css('height', (status.drug / 1000)+'%')
	}
	else if (drugEnabled) {
		drugEnabled = false;
		$("#drugbg").fadeOut();
	}
//    $('#boxStamina').css('width', status[2].percent+'%')
}

$(function() {
    window.addEventListener('message', function(event) {
      if (event.data.type == "usingStamina") {
        if (event.data.DoShow == false) {
            $("#staminabg").fadeOut();
        } else {
            (event.data.DoShow == true)
            $("#staminabg").fadeIn();
        }
      } 
    }    
  )}
);

$(function() {
    window.addEventListener('message', function(event) {
      if (event.data.type == "minHunger") {
        if (event.data.DoShow == false) {
            $("#hungerbg").fadeOut();
        } else {
            (event.data.DoShow == true)
            $("#hungerbg").fadeIn();
        }
      } 
    }    
  )}
);

$(function() {
    window.addEventListener('message', function(event) {
      if (event.data.type == "minThirst") {
        if (event.data.DoShow == false) {
            $("#thirstbg").fadeOut();
        } else {
            (event.data.DoShow == true)
            $("#thirstbg").fadeIn();
        }
      } 
    }    
  )}
);

var healthProgress = new ProgressBar.SemiCircle('#healthBar', {
    color: '#42F545',
    easing: 'easeInOut',
	strokeWidth: 4,
	duration: 50
});

var armourProgress = new ProgressBar.SemiCircle('#armourBar', {
    color: '#34C0EB',
    easing: 'easeInOut',
	strokeWidth: 4,
	duration: 50
});

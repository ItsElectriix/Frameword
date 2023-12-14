////////////////////////////////////////////////////////////
// SOUND
////////////////////////////////////////////////////////////

createjs.Sound.alternateExtensions = ["mp3"];

createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/pin1.ogg', 'soundPin1');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/pin2.ogg', 'soundPin2');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/pin3.ogg', 'soundPin3');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/soundTimer.ogg', 'soundTimer');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/bonus.ogg', 'soundBonus');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/door_unlock.ogg', 'soundDoorUnlock');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/success.ogg', 'soundSuccess');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/fail.ogg', 'soundFail');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/connect_in.ogg', 'soundConnectIn');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/connect_out.ogg', 'soundConnectOut');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/safe_unlock.ogg', 'soundSafeUnlock');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/safe_unlock_individual.ogg', 'soundSafeUnlockIndividual');
createjs.Sound.registerSound('https://cdn.themoddingcollective.com/shared/minigames/sounds/soundPowerLoop.ogg', 'soundPowerLoop');

function playSound(target, loop){
	var isLoop;
	if(loop){
		isLoop = -1;
		createjs.Sound.stop();
		musicLoop = createjs.Sound.play(target, createjs.Sound.INTERRUPT_NONE, 0, 0, isLoop, 1);
		if (musicLoop == null || musicLoop.playState == createjs.Sound.PLAY_FAILED) {
			return;
		}else{
			musicLoop.removeAllEventListeners();
			musicLoop.addEventListener ("complete", function(musicLoop) {
				
			});
		}
	}else{
		isLoop = 0;
		createjs.Sound.play(target);
	}
}

function stopSound(){
	createjs.Sound.stop();
}


/*!
 * 
 * PLAY MUSIC - This is the function that runs to play and stop music
 * 
 */
$.sound = {};
function playSoundLoop(sound){
	if($.sound[sound]==null){
		$.sound[sound] = createjs.Sound.play(sound);
		$.sound[sound].removeAllEventListeners();
		$.sound[sound].addEventListener ("complete", function() {
			$.sound[sound].play();
		});
	}
}

function stopSoundLoop(sound){
	if($.sound[sound]!=null){
		$.sound[sound].stop();
		$.sound[sound]=null;
	}
}

function setSoundVolume(sound, vol){
	if($.sound[sound]!=null){
		$.sound[sound].volume = vol;
	}
}

/*!
 * 
 * TOGGLE MUTE - This is the function that runs to toggle mute
 * 
 */
function toggleMute(con){
	createjs.Sound.setMute(con);	
}

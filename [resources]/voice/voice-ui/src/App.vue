<template>
	<body>
		<audio id="audio_on" src="mic_click_on.ogg"></audio>
		<audio id="audio_off" src="mic_click_off.ogg"></audio>
		<div class="voiceInfo">
			<p v-if="voice.callInfo !== 0" :class="{ talking: voice.talking }">
				[Call]
			</p>
			<p v-if="voice.radioEnabled && voice.radioChannel !== 0" :class="{ talking: voice.usingRadio }">
				{{ voice.radioChannel }} Mhz [Radio]
			</p>
			<p v-if="voice.voiceModes.length" :class="{ talking: voice.talking }">
				{{ voice.voiceModes[voice.voiceMode][1] }} [Range]
			</p>
		</div>
        <div class="radio-list-container hidden" id="voip-radio-list">
            <div v-if="Object.keys(voice.radioList).length !== 0 && voice.radioChannel !== 0" id="voip-radio-list-header">
                📡 Radio {{voice.radioChannel}}
            </div>
            <div v-for="(radioUser, vid, index) in voice.radioList" :key="`${ vid }-${ index }`" v-bind:id="'voip-radio-list-item'+vid" v-bind:class="{ talking: radioUser.talking }">
                {{radioUser.name}} {{radioUser.talking ? '🔸' : '🔹' }}
            </div>
        </div>
	</body>
</template>

<script>
import { reactive } from "vue";
export default {
	name: "App",
	setup() {
		const voice = reactive({
			voiceModes: [],
			voiceMode: 0,
			radioChannel: 0,
			radioEnabled: false,
			usingRadio: false,
			callInfo: 0,
			talking: false,
            radioList: {}
		});

		// stops from toggling voice at the end of talking
		let usingUpdated = false
		window.addEventListener("message", function(event) {
			const data = event.data;

			if (data.voiceModes !== undefined) {
				voice.voiceModes = JSON.parse(data.voiceModes);
			}

			if (data.voiceMode !== undefined) {
				voice.voiceMode = data.voiceMode;
			}

			if (data.radioChannel !== undefined) {
				voice.radioChannel = data.radioChannel;
			}

			if (data.radioEnabled !== undefined) {
				voice.radioEnabled = data.radioEnabled;
			}

			if (data.callInfo !== undefined) {
				voice.callInfo = data.callInfo;
			}

			if (data.usingRadio !== voice.usingRadio) {
				usingUpdated = true
				voice.usingRadio = data.usingRadio
				setTimeout(function(){
					usingUpdated = false
				}, 100)
			}
			
			if ((data.talking !== undefined) && !voice.usingRadio && !usingUpdated){
				voice.talking = data.talking
			}

			if (data.sound && voice.radioEnabled) {
				let click = document.getElementById(data.sound);
				// discard these errors as its usually just a 'uncaught promise' from two clicks happening too fast.
				click.load();
				click.volume = data.volume;
				click.play().catch((e) => {});
			}

            if (data.radioList !== undefined) {
                voice.radioList = data.radioList;
            }

            if (data.radioPlayerAdded !== undefined) {
                voice.radioList[data.radioPlayerAdded.toString()] = {
                    talking: false,
                    name: data.currentPlayerName
                };
            }

            if (data.radioTalkSource !== undefined && data.radioIsTalking !== undefined) {
                if (voice.radioList[data.radioTalkSource]) {
                    voice.radioList[data.radioTalkSource.toString()].talking = data.radioIsTalking;
                }
            }

            if (data.radioPlayerRemoved !== undefined) {
                if (voice.radioList[data.radioPlayerRemoved.toString()]) {
                    delete voice.radioList[data.radioPlayerRemoved.toString()];
                }
            }

            if (data.radioNameUpdateId !== undefined && data.radioNameUpdateName !== undefined) {
                if (voice.radioList[data.radioNameUpdateId.toString()]) {
                    voice.radioList[data.radioNameUpdateId.toString()].name = data.radioNameUpdateName;
                }
            }

            if (data.clearRadio !== undefined && data.clearRadio) {
                voice.radioList = {};
            }
		});

		return { voice };
	},
};
</script>

<style>
.voiceInfo {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	position: fixed;
	text-align: right;
	bottom: 5px;
	padding: 0;
	right: 5px;
	font-size: 12px;
	font-weight: bold;
	color: rgb(148, 150, 151);
	/* https://stackoverflow.com/questions/4772906/css-is-it-possible-to-add-a-black-outline-around-each-character-in-text */
	text-shadow: 1.25px 0 0 #000, 0 -1.25px 0 #000, 0 1.25px 0 #000,
		-1.25px 0 0 #000;
}
.talking {
	color: rgba(255, 255, 255, 0.822);
}
p {
	margin: 0;
}
.radio-list-container {
	position: absolute;
	top: 1%;
	right: 0%;
	text-align: right;
	padding: 5px;
	font-family: sans-serif;
	font-weight: bold;
	color: rgb(1, 176, 240);
	font-size: 0.7vw;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}

.radio-list-container .talking {
	color: #ccff00;
}

#voip-radio-list-header {
    text-decoration: underline;
}
</style>

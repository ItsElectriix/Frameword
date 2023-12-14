var stageW=1280;
var stageH=768;
var contentW = 1024;
var contentH = 576;

var hasLoaded = false;

function loadMessageListener(type) {
    if (!hasLoaded) {
        hasLoaded = true;

        window.addEventListener('message', function(event) {
            var data = event.data;
        
            if (data.type == 'startGame') {
                if (BJ && BJ.Minigames && BJ.Minigames[data.mgType]) {
                    $('.minigame').hide();
                    $('.minigame[data-mg=' + data.mgType + ']').show();
                    BJ.Minigames[data.mgType].startGame(data.mgData);
                }
            } else if (data.type == 'stopGame') {
                if (BJ && BJ.Minigames && BJ.Minigames[data.mgType]) {
                    $('.minigame').hide();
                    BJ.Minigames[data.mgType].stopGame();
                }
            } else if (data.type == 'hideUI') {
                $('.minigame').hide();
            } else if (data.type == 'mouseClicked') {
                if (BJ.Minigames[data.mgType].mouseClicked !== undefined) {
                    BJ.Minigames[data.mgType].mouseClicked();
                }
            }
        });
    } else {
        console.log(`Skipped loading from source: ${type} as the scripts have already finished loading.`)
    }
}

setTimeout(() => {
    loadMessageListener('Timeout');
}, 2500);

window.addEventListener('load', () => {

    loadMessageListener('Load event');
});

function startMinigame(type, data) {
    var event = new CustomEvent('message');
    event.data = {
        type: 'startGame',
        mgType: type,
        mgData: data
    }
    window.dispatchEvent(event);
}

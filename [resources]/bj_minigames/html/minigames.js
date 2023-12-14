function getBitmapImage(url, cb) {
    var image = document.createElement("img");
    image.crossOrigin = "Anonymous"; // Should work fine
    image.src = url;
    if (cb) {
        image.onload = cb;
    }
    return image;
}

function getDistance(objA, objB) {
    var deltaX = objA.x-objB.x;
    var deltaY = objA.y-objB.y;
    var dist2 = Math.floor(Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)));
    return dist2;
}

function randomBoolean(){
    return Math.random() < 0.5;
}

function animateObject(obj, con, alpha){
	if(con){
		var alphaNum = 1;
		if(alpha){
			alpha = false;
			alphaNum = .5;
		}else{
			alpha = true;
		}
		TweenMax.to(obj, .2, {alpha:alphaNum, overwrite:true, onComplete:animateObject, onCompleteParams:[obj, con, alpha]});
	}else{
		TweenMax.to(obj, .2, {alpha:1, overwrite:true});	
	}
}

function shuffle(array) {
	var currentIndex = array.length
	, temporaryValue
	, randomIndex
	;
	
	// While there remain elements to shuffle...
	while (0 !== currentIndex) {
		// Pick a remaining element...
		randomIndex = Math.floor(Math.random() * currentIndex);
		currentIndex -= 1;
		
		// And swap it with the current element.
		temporaryValue = array[currentIndex];
		array[currentIndex] = array[randomIndex];
		array[randomIndex] = temporaryValue;
	}
	
	return array;
}

function lockboxGame() {
    var gradBackg;
    var gradFill;
    var gameBar;
    var gameSweetspot;
    var gameThumb;
    var thumbDir = 1;
    var thumbSpeed = 5;
    var timeout = false;
    var timeouttime = 1200;
    var hasinit = false;
    var paused = false;
    var stages = {cur: 1, max: 3};
    var tries = {cur: 1, max: 5};
    var showHelp = false;
    var stageText;
    var difficulty = 1;
    var stageTimeout = false;
    var stageTimeoutLength = 3000;
    
    function mouseClicked() {
        gameThumb.x > gameSweetspot.x && gameThumb.x < gameSweetspot.x + gameSweetspot.width - gameThumb.width ? zoneClick(true) : zoneClick(false);
    }

    $(function(){
        gameArea.canvas.addEventListener("mousedown", mouseClicked);
    });
    
    function startGame(mgData){
        if (mgData != null) {
            if (mgData.difficulty != null) {
                difficulty = mgData.difficulty
            }
            if (mgData.speed != null) {
                thumbSpeed = mgData.speed
            }
            if (mgData.attempts != null) {
                tries.max = mgData.attempts
            }
            if (mgData.stages != null) {
                stages.max = mgData.stages
            }
            if (mgData.stageTimeout != null) {
                stageTimeoutLength = mgData.stageTimeout
            }
            if (mgData.showHelp != null) {
                showHelp = mgData.showHelp
            }
        }
        if (!hasinit){
            gameArea.start();
            gradBackg = new gradComponent(420, 38, "#000000", "#000000", gameArea.canvas.width / 2 - 210, gameArea.canvas.height - 113, 180);
            gradFill = new component(410, 28, "#000000", gradBackg.x + 5, gradBackg.y + 5);
            gameBar = new component(400, 8, "#1f314c", gameArea.canvas.width / 2 - 200, gameArea.canvas.height - 100);
            gameSweetspot = new component(60, gameBar.height, "#4e76b2", gameBar.x + gameBar.width / 2 - 20, gameBar.y);
            gameThumb = new component(9, 25, "skyblue", gameBar.x + gameBar.width / 2, gameBar.y - gameBar.height);
            stageText = new textComponent(22, "Roboto", gameArea.canvas.width / 2, gameArea.canvas.height - 20);
            hasinit = true;
        }
        else{
            paused = false;
        }
        startStageTimer();
    }
    
    function resetGame(){
        console.log(stageTimeout);
        if (stageTimeout !== undefined && stageTimeout !== null) {
            clearTimeout(stageTimeout);
        }
        stages.cur = 1;
        stages.max = 3;
        tries.cur = 1;
        tries.max = 5;
        difficulty = 1;
        showHelp = false;
        thumbSpeed = 5;
        stageTimeoutLength = 3000;
        randomizeSweetspot();
    }
    
    function stopGame(){
		resetGame();
        paused = true;
		sendData("minigameResult", { type: 'Lockbox', result: false });
    }
    
    var gameArea = {
        canvas: document.getElementById("lockboxCanvas"),
        start: function(){
          this.canvas.id = "lockBoxMiniGameCanvas";
          this.canvas.width = window.innerWidth - 50;
          this.canvas.height = window.innerHeight - 50;
          this.context = this.canvas.getContext("2d");
          //document.body.insertBefore(this.canvas, document.body.childNodes[0]);
          this.interval = setInterval(updateGameArea, 10);
        },
        clear: function(){
          this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        }
    }
    
    function component(width, height, color, x, y){
        this.width = width;
        this.height = height;
        this.x = x;
        this.y = y;
        this.update = function(){
            ctx = gameArea.context;
            ctx.fillStyle = color;
            ctx.fillRect(this.x, this.y, this.width, this.height);
        }
    }
    
    function gradComponent(width, height, colf, colt, x, y, angle){
        this.width = width;
        this.height = height;
        this.x = x;
        this.y = y;
        this.colorfrom = colf;
        this.colorto = colt;
        this.angle = angle;
        this.update = function(){
            ctx = gameArea.context;
            var ang = angle / 180 * Math.PI;
            var x2 = this.x + Math.cos(ang) * this.width;
            var y2 = this.y + Math.sin(ang) * this.width;
            var grad = ctx.createLinearGradient(this.x, this.y, x2, y2);
            grad.addColorStop(0, this.colorfrom);
            grad.addColorStop(1, this.colorto);
            ctx.fillStyle = grad;
            ctx.fillRect(this.x, this.y, this.width, this.height);
        }
    }
    
    function textComponent(fontsize, font, x, y, text){
        this.fontsize = fontsize;
        this.font = font;
        this.x = x;
        this.y = y;
        this.text = text;
        this.update = function(){
            if (showHelp) {
                ctx = gameArea.context;
                ctx.font = fontsize + "px " + font;
                ctx.textAlign = "center";
                ctx.lineWidth = 6;
                ctx.strokeStyle = "black";
                ctx.strokeText(this.text || "", x, y);
                ctx.fillStyle = "skyblue";
                ctx.fillText(this.text || "", x, y);
            }
        }
    }
    
    function updateGameArea(){
        if (!paused){
            gameArea.clear();
        
            var barextents = {left: gameBar.x - gameThumb.width / 2, right: gameBar.x + gameBar.width - gameThumb.width / 2};
        
            if (!timeout){
                thumbDir == 1 && gameThumb.x < barextents.right ? gameThumb.x += thumbSpeed : thumbDir = 0;
                thumbDir == 0 && gameThumb.x > barextents.left ? gameThumb.x -= thumbSpeed : thumbDir = 1;
            }
        
            stageText.text = `Stage: ${stages.cur} of ${stages.max}   |   Attempts: ${tries.cur} of ${tries.max}`;
            gameSweetspot.width = Math.floor(120 / difficulty);
        
            gradBackg.update();
            gradFill.update();
            gameBar.update();
            gameSweetspot.update();
            gameThumb.update();
            stageText.update();
        }
    }
    
    function getRandomArbitrary(min, max) {
        return Math.random() * (max - min) + min;
    }
    
    function randomizeSweetspot(){
        var sswidth = Math.floor(120 / difficulty);
    
        gameSweetspot.x = getRandomArbitrary(gameBar.x + sswidth / 2, gameBar.x + gameBar.width - sswidth);
    }
    
    function zoneClick(success){
        if (timeout == false) {    
            if (stageTimeout !== false) {
                clearTimeout(stageTimeout);
                stageTimeout = false;
            }
            if (success){
                gradBackg.colorfrom = "#09a025";
                timeout = true;

                setTimeout(function(){
                    gradBackg.colorfrom = "#000000";
                    timeout = false;
                    increaseStage();
                    startStageTimer();
                }, timeouttime);
            }
            else{
                tries.cur += 1;

                if (tries.cur > tries.max){
                    sendData("minigameResult", { type: 'Lockbox', result: false });
                    console.log("sent failed");
                    resetGame();
                    paused = true;
                }
                else{
                    gradBackg.colorfrom = "#9e1809";
                    timeout = true;
                
                    setTimeout(function(){
                        gradBackg.colorfrom = "#000000";
                        timeout = false;
                        randomizeSweetspot();
                        startStageTimer();
                    }, timeouttime);
                }
            }
        }
    }

    function startStageTimer() {
        if (stageTimeout !== false) {
            clearTimeout(stageTimeout);
            stageTimeout = false;
        }
        stageTimeout = setTimeout(function() {
            if (!paused) {
                zoneClick(false);
            }
        }, stageTimeoutLength);
    }
    
    function increaseStage(){
        stages.cur += 1;
        
        if (stages.cur > stages.max){
            sendData("minigameResult", { type: 'Lockbox', result: true });
            console.log("sent success");
            resetGame();
            paused = true;
        }

        randomizeSweetspot();
    }
    
    function sendData(name, data){
        $.post("http://bj_minigames/" + name, JSON.stringify(data), function(datab) {
            console.log(datab);
        });
    }
    
    return {
        startGame: startGame,
        resetGame: resetGame,
        stopGame: stopGame,
        mouseClicked: mouseClicked
    }
}

var BJ = BJ || {};
BJ.Minigames = BJ.Minigames || {};
BJ.Minigames.Lockbox = new lockboxGame();

function pincodeGame() {
    
    var maxCharacters = 4,
        passcode = 1138;

    var msg = {
        success: 'Unlocked',
        error: 'Error',
        set: 'Set'
    }

    var module = {
        init: function() {
            this.domCache();
            this.setPrivateMethods();
            this.setEventHandlers();
            this.addEventListeners();
        },
        
        domCache: function() {
            this.$screen = $('.screen');
            this.$cursor = $('.cursor');
            this.$input = $('.text');
            this.$keypad = $('button');
            this.$values = this.$keypad.html().split('');
        },

        setPrivateMethods: function() {
            this.getInput = function() {
                return module.$input.html();
            };
    
            this.getInputLength = function() {
                var input = module.getInput();
                return input.length;
            };
    
            this.messageDisplayed = function() {
                return (module.getInput() === msg.success || module.getInput() === msg.error) ? true : false;
            }
    
            this.showCursor = function() {
                module.$cursor.css({
                    'display':'block'
                });
            };
    
            this.updateCursor = function() {
                var characters = module.getInputLength();
      
                if (characters < maxCharacters) {
                    var shift = (characters * 16) + 10;
                    module.$cursor.css({
                        'left': shift + 'px'
                    });
                } else {
                    module.$cursor.css({
                        'left': '10px',
                        'display':'none'
                    });
                }
            };

            this.authenticate = function() {
                var input = module.getInput();
                if (input === passcode && passcode !== null) {
                    module.clearScreen();
                    module.pushToScreen(msg.success);
        
                    setTimeout(function() {
                        module.clearScreen();
                        module.showCursor();
                        sendData("minigameResult", { type: 'Pincode', result: true, data: input });
                    }, 2000);
                } else if (input.length === maxCharacters) {
                    module.clearScreen();
                    if (passcode === null) {
                        module.pushToScreen(msg.set);
                    } else {
                        module.pushToScreen(msg.error);
                    }

                    setTimeout(function() {
                        module.clearScreen();
                        module.showCursor();
                        sendData("minigameResult", { type: 'Pincode', result: (passcode === null ? true : false), data: input });
                    }, 2000);
                }
            };

            this.pushToScreen = function(input) {
                module.$input.css({
                    'opacity': '1'
                });
                module.$input.append(input);
            };

            this.removeLastDigit = function() {
                var input = module.$input.text();
                input = input.slice(0, -1);
                module.$input.text(input);
            };
    
            this.clearScreen = function() {
                module.$input.text('');
            };
        },
  
        setEventHandlers: function() {
            this.keypressHandler = function(e) {
                var reg = /^\d$/,
                    backspace = 8,
                    key,
                    isDigit;
                    
                if (e.which === backspace) {
                    e.preventDefault();
                    module.removeLastDigit();
                } else {
                    key = e.which - 48;
                }

                isDigit = reg.test(key);

                if (!isDigit) {
                    key = undefined;
                }
            
                if (key) {
                    if (!module.messageDisplayed()) {
                        module.pushToScreen(key);
                    }
                    module.authenticate();
                    module.updateCursor();
                }
            };
    
            this.clickHandler =  function(e) {
                var target = e.target,
                    key = target.innerHTML;
            
                if (key === 'DEL') {
                    module.removeLastDigit();
                } else if (key === 'CAN') {
                    module.clearScreen();
                    module.showCursor();
                    sendData("minigameResult", { type: 'Pincode', result: false });
                } else if (!module.messageDisplayed()) {
                    module.pushToScreen(key);
                }
            
                module.authenticate();
                module.updateCursor();
            };
        },
  
        addEventListeners: function() {
            $(document).on('keypress', this.keypressHandler);
            this.$keypad.on('click.keypad', module.clickHandler);
        }
    };

    module.init();

    function startGame(mgData){
        if (mgData.maxCharacters != null) {
            maxCharacters = mgData.maxCharacters
        }
        passcode = mgData.passcode === undefined ? null : mgData.passcode;
        module.clearScreen();
        module.showCursor();
    }
    
    function resetGame(){
        module.clearScreen();
        module.showCursor();
        maxCharacters = 4;
        passcode = '0000';
    }
    
    function stopGame(){
        module.clearScreen();
        module.showCursor();
        maxCharacters = 4;
        passcode = '0000';
		sendData("minigameResult", { type: 'Pincode', result: false });
    }
    
    function sendData(name, data){
        $.post("http://bj_minigames/" + name, JSON.stringify(data), function(datab) {
            console.log(datab);
        });
    }
    
    return {
        startGame: startGame,
        resetGame: resetGame,
        stopGame: stopGame
    }
}

var BJ = BJ || {};
BJ.Minigames = BJ.Minigames || {};
BJ.Minigames.Pincode = new pincodeGame();

function lockpickGame() {
    var canvasContainer, mainContainer, gameContainer, game1Container, game1, timerBgBar, timerBar, gameUnlockData, gameUnlockAnimate, stage, canvasH, canvasW;

    var gameData = {type:0, stageX:0, stageY:0, oldX:0, oldY:0, dirX:'', dirY:'', paused:false, timerEnable:false, timerStart:0, timerCount:0, timerTotal:0, timerSound:false, type_arr:[1,2,3,4], typeNum:0};
    var game1Data = {totalPins:0, timerPins:0, lock_arr:[], lockSeq_arr:[], lockNum:0};
    var pinBgColor = '#293a4c'; //pin background level color
    var pinTopColor = '#ddd'; //pin top color
    var pinBottomColor = '#fff'; //pin bottom color
    var pinSuccessColor = '#4fbbaf'; //pin success color
    var pinHeight = 160; //pin height
    var pinBgHeight = 310; //pin width

    var timerBarColor = '#51b8ac'; //timer bar color
    var timerBgBarColor = '#3B4F5E'; //timer background bar color
    var timerBarH = 10; //timer bar height

    var timeoutLength = 18000;
    var totalPins = 3;
    
    var offset = {x:0, y:0, left:0, top:0};

    function startGame(mgData) {
        if (mgData != null) {
            if (mgData.pins) {
                totalPins = mgData.pins;
            }
            if (mgData.timeout) {
                timeoutLength = mgData.timeout;
            }
        }
        gameData.typeNum = 0;
        game1Data.totalPins = totalPins;
        game1Data.timerPins = timeoutLength;

        
        game1Container.visible = false;
        gameUnlockAnimate.visible = false;
        
	    var targetContainer = null;
        
	    timerBgBar.visible = timerBar.visible = true;
	    gameData.type = 1;
        
        targetContainer = game1Container;
	    itemPin.x = canvasW/100*20;
		itemPin.y = canvasH/100*65;
    
	    drawLocks(game1Data.totalPins);
	    shuffle(game1Data.lockSeq_arr);
	    game1Data.lockNum = 0;
	    toggleGameTimer(true, game1Data.timerPins);
    
	    if(targetContainer != null){
	    	targetContainer.visible = true;
	    	targetContainer.alpha = 0;
	    	TweenMax.to(targetContainer, .5, {alpha:1, overwrite:true});
	    }
    
	    gameData.paused = false;
    }

    function initGameCanvas(w,h){
        var gameCanvas = document.getElementById("lockpickGameCanvas");
        gameCanvas.width = w;
        gameCanvas.height = h;
        
        canvasW=w;
        canvasH=h;
        stage = new createjs.Stage("lockpickGameCanvas");
        
        createjs.Touch.enable(stage);
        stage.enableMouseOver(20);
        stage.mouseMoveOutside = true;
        
        createjs.Ticker.setFPS(60);
        createjs.Ticker.addEventListener("tick", updateGame);	
    }

    function toggleGameTimer(con, total){
        if(con){
            gameData.timerTotal = total;
            gameData.timerStart = new Date();
            gameData.timerAccumulate = 0;
            gameData.timerCurrent = 0;	
        }else{
            gameData.timerSound = false;	
        }
        gameData.timerEnable = con;
    }

    function dragWithinArea(obj, startX, endX, startY, endY){
        if(obj.x <= startX){
            obj.x = startX;
        }else if(obj.x >= endX){
            obj.x = endX;
        }
        
        if(obj.y <= startY){
            obj.y = startY;
        }else if(obj.y >= endY){
            obj.y = endY;
        }
    }

    function moveLockPicker(evt){
        itemPin.x = gameData.stageX - 380;
        dragWithinArea(itemPin, canvasW/100 * 20, canvasW/100 * 48, itemPin.y, itemPin.y);
        gameData.stageX = evt.stageX;
        gameData.stageY = evt.stageY;
    }

    function toggleUnlock(n){
        if (!gameData.paused){
            
            var randomNum = Math.floor(Math.random()*2)+1;
            playSound('soundPin'+randomNum);
                
            var rotateSpeed = .1;
            TweenMax.to(itemPin, rotateSpeed, {rotation:-3, overwrite:true, onComplete:function(){
                TweenMax.to(itemPin, rotateSpeed, {rotation:0, overwrite:true, onComplete:function(){
                    TweenMax.to(itemPin, rotateSpeed, {rotation:-3, overwrite:true, onComplete:function(){
                        TweenMax.to(itemPin, rotateSpeed, {rotation:0, overwrite:true});	
                    }});
                }});
            }});
            
            if(game1Data.lockSeq_arr[game1Data.lockNum] == n){
                playSound('soundBonus');
                var newY = game1Data.lock_arr[n].y - (pinHeight - game1Data.lock_arr[n].space);
                var ySpeed = .3;
                TweenMax.to(game1Data.lock_arr[n].success, ySpeed, {y:newY, overwrite:true});
                TweenMax.to(game1Data.lock_arr[n].top, ySpeed, {y:newY, overwrite:true});
                
                game1Data.lock_arr[n].bg.unlock = true;
                game1Data.lock_arr[n].success.visible = true;
                
                game1Data.lockNum++;
                if(game1Data.lockNum > game1Data.lock_arr.length-1){
                    gameFinish(true);
                }
            }else{
                //reset
                for(var n=0; n<game1Data.lock_arr.length; n++){
                    game1Data.lock_arr[n].success.visible = false;
                    game1Data.lock_arr[n].bg.unlock = false;	
                }
                game1Data.lockNum = 0;	
            }
        }
    }

    function drawLocks(total){
        game1Data.lock_arr = []
        game1Data.lockSeq_arr = [];
        game1Data.lockNum = 0;
        game1LockContainer.removeAllChildren();
        
        var startX = canvasW/100 * 52;
        var startY = canvasH/100 * 63;
        var curX = startX;
        var pinStrikeH = 10;
        
        var pinW = 40;
        var pinSpace = 55;
        var level_arr = [60,90,70,50,80,30,65,85,95];
        shuffle(level_arr);
        
        for(var n=0; n<total; n++){
            var extraBgSpace = 20;
            var newLockBg = new createjs.Shape();
            newLockBg.graphics.beginFill(pinBgColor);
            newLockBg.graphics.moveTo((pinW/2)+5, -(extraBgSpace)).lineTo((pinW/2)+5, -(pinBgHeight)).lineTo(-((pinW/2)+5), -(pinBgHeight)).lineTo(-((pinW/2)+5), -(extraBgSpace));
            newLockBg.graphics.endFill();
            
            var newLockBottom = new createjs.Shape();
            newLockBottom.graphics.beginFill(pinBottomColor);
            newLockBottom.graphics.moveTo(0,0).lineTo(pinW/2, -(pinStrikeH)).lineTo(pinW/2, -(level_arr[n])).lineTo(-(pinW/2), -(level_arr[n])).lineTo(-(pinW/2), -(pinStrikeH));
            newLockBottom.graphics.endFill();
            
            var spaceBottom = -(level_arr[n] + 10);
            var newLockTop = new createjs.Shape();
            newLockTop.graphics.beginFill(pinTopColor);
            newLockTop.graphics.moveTo(pinW/2, spaceBottom).lineTo(pinW/2, spaceBottom-(pinHeight - (level_arr[n]))).lineTo(-(pinW/2), spaceBottom-(pinHeight - (level_arr[n]))).lineTo(-(pinW/2), spaceBottom);
            newLockTop.graphics.endFill();
            
            var successLock = new createjs.Shape();
            successLock.graphics.beginFill(pinSuccessColor);
            successLock.graphics.moveTo(pinW/2, spaceBottom).lineTo(pinW/2, spaceBottom-(pinHeight - (level_arr[n]))).lineTo(-(pinW/2), spaceBottom-(pinHeight - (level_arr[n]))).lineTo(-(pinW/2), spaceBottom);
            successLock.graphics.endFill();
            successLock.visible = false;
            
            newLockBg.x = successLock.x = newLockBottom.x = newLockTop.x = curX;
            newLockBg.y = successLock.y = newLockBottom.y = newLockTop.y = startY;
            game1Data.lock_arr.push({bg:newLockBg, bottom:newLockBottom, top:newLockTop, success:successLock, y:startY, space:level_arr[n]});
            game1Data.lockSeq_arr.push(n);
            
            newLockBg.unlock = false;
            newLockBg.cursor = "pointer";
            newLockBg.clickNum = n;
            newLockBg.addEventListener("click", function(evt) {
                moveLockPicker(evt);
                toggleUnlock(evt.target.clickNum);
            });
            
            curX+= pinSpace;
            game1LockContainer.addChild(newLockBg, newLockTop, successLock, newLockBottom);
        }
    }

    function buildGameCanvas(){
        canvasContainer = new createjs.Container();
        mainContainer = new createjs.Container();
        gameContainer = new createjs.Container();
        game1Container = new createjs.Container();
        
        //game 1
	    game1LockContainer = new createjs.Container();
	    game1 = new createjs.Bitmap('https://cdn.themoddingcollective.com/shared/minigames/game_layout1.png');
	
	    itemPin = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/item_lock_pick.png', () => {
            centerReg(itemPin);
        }));
	    itemPin.regY = 21;
	
	    game1Container.addChild(game1, itemPin, game1LockContainer);
        
        
        timerBgBar = new createjs.Shape();
        timerBar = new createjs.Shape();
        
        var _frameW=120;
        var _frameH=180;
        var _frame = {"regX": (_frameW/2), "regY": (_frameH/2), "height": _frameH, "count": 2, "width": _frameW};
        var _animations = {lock:{frames: [0], speed:1},
                            animate:{frames: [0,0,0,1], speed:.2, next:'unlock'},
                            unlock:{frames: [1], speed:1}};
                            
        gameUnlockData = new createjs.SpriteSheet({
            "images": ['https://cdn.themoddingcollective.com/shared/minigames/unlock.png'],
            "frames": _frame,
            "animations": _animations
        });
        
        gameUnlockAnimate = new createjs.Sprite(gameUnlockData, "lock");
        gameUnlockAnimate.framerate = 20;
        gameUnlockAnimate.x = canvasW/2;
        gameUnlockAnimate.y = canvasH/2;
        
        gameContainer.addChild(game1Container, gameUnlockAnimate, timerBgBar, timerBar);
        
        canvasContainer.addChild(mainContainer, gameContainer);
        stage.addChild(canvasContainer);
        
        resizeCanvas();
    }

    function resizeCanvas(){
        if(canvasContainer!=undefined){
           timerBgBar.x = offset.x;
           timerBar.x = offset.x;
           timerBgBar.y = canvasH - (offset.y +10);
           timerBar.y = canvasH - (offset.y +10);
       }
    }

    function centerReg(obj){
	    obj.regX=obj.image.naturalWidth/2;
	    obj.regY=obj.image.naturalHeight/2;
    }

    function setupGames(){
        stage.on("stagemousedown", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
        });
        stage.on("stagemousemove", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
            moveLockPicker(evt);
        });
        stage.on("stagemouseup", function(evt) {
            
        });
    }

    function drawTimerBar(con){
        timerBgBar.graphics.clear();
        timerBgBar.graphics.beginFill(timerBgBarColor);
        timerBgBar.graphics.drawRect(0, 0, stageW, timerBarH);
        timerBgBar.graphics.endFill();
        
        var currentW = canvasW - (offset.x);
        var timerCount = gameData.timerTotal - gameData.timerCount;
        var newWidth = timerCount / gameData.timerTotal * currentW;
        if(!con){
            newWidth = currentW;
        }
        
        timerBar.graphics.clear();
        timerBar.graphics.beginFill(timerBarColor);
        timerBar.graphics.drawRect(0, 0, newWidth, timerBarH);
        timerBar.graphics.endFill();
        
        if(timerCount <= 10000 && con){
            if(!gameData.timerSound){
                gameData.timerSound = true;
                playSoundLoop('soundTimer');
                animateObject(timerBar, true, true);
            }
        }
        
        if (newWidth <= 0 && !gameData.paused) {
            gameFinish(false);
        }
    }

    function checkWithinLockArea(x){
        for(var n=0; n<game1Data.lock_arr.length; n++){
            var curLockX = game1Data.lock_arr[n].bg.x;
            if(x >= curLockX-30 && x <= curLockX+30){
                TweenMax.to(game1Data.lock_arr[n].bottom, .5, {y:game1Data.lock_arr[n].y-20, overwrite:true});
            }else{
                TweenMax.to(game1Data.lock_arr[n].bottom, .5, {y:game1Data.lock_arr[n].y, overwrite:true});
            }
            
            if(!game1Data.lock_arr[n].bg.unlock){
                game1Data.lock_arr[n].success.y = game1Data.lock_arr[n].top.y = game1Data.lock_arr[n].bottom.y;
            }
        }
    }

    function updateGame(event){
        stage.update(event);

        if(gameData.timerEnable){
            var nowDate = new Date();
            gameData.timerCurrent = (nowDate.getTime() - gameData.timerStart.getTime());
            gameData.timerCurrent = gameData.timerCurrent + gameData.timerAccumulate;
            gameData.timerCount = gameData.timerCurrent;
            drawTimerBar(true);
        }

        checkWithinLockArea(gameData.stageX);
    }

    function gameFinish(success) {
        function timeoutComplete() {
            gameUnlockAnimate.visible = false;
            sendData("minigameResult", { type: 'Lockpick', result: success });
        }
        stopSoundLoop('soundTimer');
        gameData.paused = true;
        toggleGameTimer(false);
        gameUnlockAnimate.gotoAndStop("lock");
        TweenMax.to(gameUnlockAnimate, 1, {overwrite:true, onComplete:function(){
            gameUnlockAnimate.visible = true;
            if (success) {
                playSound('soundSuccess');
                gameUnlockAnimate.gotoAndPlay('animate');
                TweenMax.to(gameUnlockAnimate, .8, {overwrite:true, onComplete:function(){
                    playSound('soundDoorUnlock');
		    	    TweenMax.to(gameUnlockAnimate, 1.2, {overwrite:true, onComplete:function(){
		    		    TweenMax.to(gameUnlockAnimate, 2, {overwrite:true, onComplete:function(){
                            timeoutComplete()
		    		    }});	
		    	    }});
		        }});
            }
            else {
                playSound('soundFail');
                setTimeout(timeoutComplete, 1000);
            }
        }});
    }

    function sendData(name, data){
        $.post("http://bj_minigames/" + name, JSON.stringify(data), function(datab) {
            console.log(datab);
        });
    }
	
	function stopGame() {
		gameData.paused = false;
		sendData("minigameResult", { type: 'Lockpick', result: false });
	}

    initGameCanvas(1280,768);
	buildGameCanvas();
	setupGames();

    return {
        startGame: startGame,
		stopGame: stopGame
    }
}

var BJ = BJ || {};
BJ.Minigames = BJ.Minigames || {};
BJ.Minigames.Lockpick = new lockpickGame();

function connectionGame() {
    var gameData = {type:0, stageX:0, stageY:0, oldX:0, oldY:0, dirX:'', dirY:'', paused:false, timerEnable:false, timerStart:0, timerCount:0, timerTotal:0, timerSound:false, type_arr:[1,2,3,4], typeNum:0};
    game4Data = {totalCable:0, timerCable:0, pointNum:0, lineNum:0, lines_arr:[], point_arr:[], connect_arr:[], seq_arr:[]};
    var canvasContainer, mainContainer, gameContainer, gameUnlockAnimate, game4Container, game4WireContainer, game4, timerBgBar, timerBar, gameUnlockData, stage, canvasH, canvasW;

    var cableStroke = 8; //cable stroke
    var cableColor = '#51b9ae'; //cable color

    var timerBarColor = '#51b8ac'; //timer bar color
    var timerBgBarColor = '#3B4F5E'; //timer background bar color
    var timerBarH = 10; //timer bar height

    var timeoutLength = 18000;
    var totalCable = 3;
    
    var offset = {x:0, y:0, left:0, top:0};

    function startGame(mgData) {
        if (mgData != null) {
            if (mgData.cable) {
                totalCable = mgData.cable;
            }
            if (mgData.timeout) {
                timeoutLength = mgData.timeout;
            }
        }
        game4Data.totalCable = totalCable;
        game4Data.timerCable = timeoutLength;

        game4Container.visible = false;
        gameUnlockAnimate.visible = false;
        
        var targetContainer = null;
        
        targetContainer = game4Container;
		createWires(game4Data.totalCable);
		toggleGameTimer(true, game4Data.timerCable);
        
        timerBgBar.visible = timerBar.visible = true;
        
        if(targetContainer != null){
	    	targetContainer.visible = true;
	    	targetContainer.alpha = 0;
	    	TweenMax.to(targetContainer, .5, {alpha:1, overwrite:true});
	    }
    
	    gameData.paused = false;
    }

    function randomIntFromInterval(min,max){
        return Math.floor(Math.random()*(max-min+1)+min);
    }

    function dragWithinArea(obj, startX, endX, startY, endY){
        if(obj.x <= startX){
            obj.x = startX;
        }else if(obj.x >= endX){
            obj.x = endX;
        }
        
        if(obj.y <= startY){
            obj.y = startY;
        }else if(obj.y >= endY){
            obj.y = endY;
        }
    }

    function adjustCenterPoint(lineNum){
        var startPoint = game4Data.lines_arr[lineNum].lines[0].point;
        var startCurvePoint = game4Data.lines_arr[lineNum].lines[1].point;
        var centerPoint = game4Data.lines_arr[lineNum].lines[2].point;
        var endCurvePoint = game4Data.lines_arr[lineNum].lines[3].point;
        var endPoint = game4Data.lines_arr[lineNum].lines[4].point;
        var extraNum = game4Data.connect_arr[lineNum].connector.extraNum;
        
        endPoint.x = game4Data.connect_arr[lineNum].connector.x;
        endPoint.y = game4Data.connect_arr[lineNum].connector.y;
        
        startCurvePoint.x = startPoint.x + ((endPoint.x - startPoint.x)/100 * 30);
        startCurvePoint.y = startPoint.y - ((endPoint.y - startPoint.y)/100 * (50+extraNum));
        
        centerPoint.x = startPoint.x + ((endPoint.x - startPoint.x)/2);
        centerPoint.y = startPoint.y + ((endPoint.y - startPoint.y)/2);
        
        endCurvePoint.x = startPoint.x + ((endPoint.x - startPoint.x)/100 * 70);
        endCurvePoint.y = endPoint.y + ((endPoint.y - startPoint.y)/100 * (50+extraNum));
        
        redrawLine();
    }

    function redrawLine(){
        for(var n=0; n<game4Data.lines_arr.length; n++){
            game4Data.lines_arr[n].drawLine.graphics.clear();
            game4Data.lines_arr[n].drawLine.graphics.setStrokeStyle(cableStroke);
            game4Data.lines_arr[n].drawLine.graphics.beginStroke(cableColor);
            
            game4Data.lines_arr[n].drawLine.graphics.moveTo(game4Data.lines_arr[n].lines[0].point.x, game4Data.lines_arr[n].lines[0].point.y);
            for(var p=0; p<game4Data.lines_arr[n].lines.length; p++){
                if(game4Data.lines_arr[n].lines.length - p > 2 && isEven(p)){
                    game4Data.lines_arr[n].drawLine.graphics.curveTo(game4Data.lines_arr[n].lines[p+1].point.x, game4Data.lines_arr[n].lines[p+1].point.y, game4Data.lines_arr[n].lines[p+2].point.x, game4Data.lines_arr[n].lines[p+2].point.y);
                }
            }
        }
    }

    function checkConnector(connector){
        var rangeXNum = 100;
        var rangeYNum = 30;
        
        for(var n=0; n<game4Data.connect_arr.length;n++){
            var targetEnd = game4Data.connect_arr[n].end;
            
            if(!targetEnd.connected){
                if(connector.x + 100 >= targetEnd.x - rangeXNum && connector.x + 100 <= targetEnd.x + rangeXNum){
                    if(connector.y >= targetEnd.y - rangeYNum && connector.y <= targetEnd.y + rangeYNum){
                        playSound('soundConnectIn');
                        targetEnd.connected = true;
                        
                        if(connector.lineNum == game4Data.seq_arr[targetEnd.lineNum]){
                            playSound('soundBonus');
                            targetEnd.gotoAndStop('on');
                            checkAllConnected();
                        }
                        
                        connector.x = targetEnd.x - 160;
                        connector.y = targetEnd.y;
                        connector.connected = targetEnd;
                        
                        adjustCenterPoint(connector.lineNum);
                        n = game4Data.connect_arr.length;
                    }	
                }
            }
        }
    }

    function checkAllConnected(){
        var connectCount = 0;
        for(var n=0; n<game4Data.connect_arr.length;n++){
            var targetEnd = game4Data.connect_arr[n].end;
            if(targetEnd.currentFrame == 1){
                connectCount++;	
            }
        }
        
        if(connectCount == game4Data.totalCable){
            gameFinish(true);
        }
    }

    function toggleDragEvent(obj, con){
        if(gameData.paused){
            return;	
        }
        
        switch(con){
            case 'drag':
                obj.target.offset = {x:obj.target.x-(obj.stageX), y:obj.target.y-(obj.stageY)};
                if(obj.target.connected != null){
                    playSound('soundConnectOut');
                    obj.target.connected.gotoAndStop('off');
                    obj.target.connected.connected = false;
                    obj.target.connected = null;	
                }
            break;
            
            case 'move':
                obj.target.x = (obj.stageX) + obj.target.offset.x;
                obj.target.y = (obj.stageY) + obj.target.offset.y;
                
                dragWithinArea(obj.target, canvasW/100 * 25, canvasW/100 * 70, canvasH/100 * 20, canvasH/100 * 80);
                adjustCenterPoint(obj.target.lineNum);
            break;
            
            case 'drop':
                checkConnector(obj.target);
            break;
        }
    }

    function createLines(startX, startY, endX, endY){
        game4Data.lines_arr.push({lines:[], drawLine:0});
        
        addPoint(startX, startY, true);
        addPoint(startX, startY, false);
        addPoint(startX, startY, false);
        addPoint(startX, startY, false);
        addPoint(endX, endY, true);
        
        game4Data.lines_arr[game4Data.lineNum].drawLine = new createjs.Shape();
        game4WireContainer.addChild(game4Data.lines_arr[game4Data.lineNum].drawLine);
        
        game4Data.lineNum++;
    }

    function isEven(value) {
        if (value%2 == 0)
            return true;
        else
            return false;
    }
     
    function addPoint(x, y, drag){
        var newPoint = new createjs.Shape();
        newPoint.x = x;
        newPoint.y = y;
        newPoint.lineNum = game4Data.lineNum;
        game4Data.lines_arr[game4Data.lineNum].lines.push({point:newPoint});
        game4WireContainer.addChild(newPoint); 
    }

    function createWires(total){
        game4Data.seq_arr = [];
        game4Data.connect_arr = [];
        game4Data.lines_arr = [];
        game4Data.lineNum = 0;
        
        game4WireContainer.removeAllChildren();
        game4ConnectContainer.removeAllChildren();
        
        var startX = canvasW/100 * 22;
        var startY = canvasH/2;
        var endX = canvasW/100 * 82;
        var connectSpace = 80;
        var curY = startY - ((connectSpace * total)/2);
        curY += connectSpace/2;
        
        for(var n=0; n<total; n++){
            var connectStart = itemConnectStart.clone();
            var connectEnd = itemConnectEndAnimate.clone();
            var connector = itemConnector.clone();
            connectEnd.gotoAndStop('off');
            connectEnd.connected = false;
            connectEnd.lineNum = n;
            
            connectStart.x = startX;
            connectEnd.x = endX;
            connectStart.y = connectEnd.y = curY;
            
            connector.lineNum = n;
            connector.extraNum = randomIntFromInterval(-20,20);
            connector.x = randomIntFromInterval(canvasW/100* 40, canvasW/100* 70);
            connector.y = randomIntFromInterval(canvasH/100* 30, canvasH/100* 70);
            connector.connected = null;
            connector.cursor = "pointer";
            connector.addEventListener("mousedown", function(evt) {
                toggleDragEvent(evt, 'drag')
            });
            connector.addEventListener("pressmove", function(evt) {
                toggleDragEvent(evt, 'move')
            });
            connector.addEventListener("pressup", function(evt) {
                toggleDragEvent(evt, 'drop')
            });
            
            createLines(startX, curY, connector.x, connector.y);
            
            curY += connectSpace;
            
            game4Data.seq_arr.push(n);
            game4Data.connect_arr.push({start:connectStart, end:connectEnd, connector:connector, connected:false});
            game4ConnectContainer.addChild(connectStart, connectEnd);
            game4WireContainer.addChild(connector);
            
            adjustCenterPoint(n);
        }
    }

    function initGameCanvas(w,h){
        var gameCanvas = document.getElementById("connectionGameCanvas");
        gameCanvas.width = w;
        gameCanvas.height = h;
        
        canvasW=w;
        canvasH=h;
        stage = new createjs.Stage("connectionGameCanvas");
        
        createjs.Touch.enable(stage);
        stage.enableMouseOver(20);
        stage.mouseMoveOutside = true;
        
        createjs.Ticker.setFPS(60);
        createjs.Ticker.addEventListener("tick", updateGame);	
    }

    function toggleGameTimer(con, total){
        if(con){
            gameData.timerTotal = total;
            gameData.timerStart = new Date();
            gameData.timerAccumulate = 0;
            gameData.timerCurrent = 0;	
        }else{
            gameData.timerSound = false;	
        }
        gameData.timerEnable = con;
    }

    function buildGameCanvas(){
        canvasContainer = new createjs.Container();
        mainContainer = new createjs.Container();
        gameContainer = new createjs.Container();
        game4Container = new createjs.Container();
        
        //game4 = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/game_layout4.png'));
        game4WireContainer = new createjs.Container();
        game4ConnectContainer = new createjs.Container();
        
        itemConnectStart = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/item_connect_start.png'));
        centerReg(itemConnectStart);
        itemConnectStart.regX = 120;
        itemConnectStart.regY = 30;
        itemConnectStart.x = -200;
        
        itemConnector = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/item_connector.png'));
        centerReg(itemConnector);
        itemConnector.regX = 0;
        itemConnector.regY = 20;
        itemConnector.x = -200;
        
        var _frameW=125;
        var _frameH=65;
        var _frame = {"regX": (_frameW/2), "regY": (_frameH/2), "height": _frameH, "count": 2, "width": _frameW};
        var _animations = {off:{frames: [0], speed:1},
                            on:{frames: [1], speed:1}};
                            
        itemConnectEndData = new createjs.SpriteSheet({
            "images": [getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/item_connect_end.png')],
            "frames": _frame,
            "animations": _animations
        });
        
        itemConnectEndAnimate = new createjs.Sprite(itemConnectEndData, "off");
        itemConnectEndAnimate.framerate = 20;
        itemConnectEndAnimate.x = -200;
        
        game4Container.addChild(itemConnectStart, itemConnectEndAnimate, itemConnector, game4WireContainer, game4ConnectContainer);

        timerBgBar = new createjs.Shape();
        timerBar = new createjs.Shape();
        
        var _frameW=120;
        var _frameH=180;
        var _frame = {"regX": (_frameW/2), "regY": (_frameH/2), "height": _frameH, "count": 2, "width": _frameW};
        var _animations = {lock:{frames: [0], speed:1},
                            animate:{frames: [0,0,0,1], speed:.2, next:'unlock'},
                            unlock:{frames: [1], speed:1}};
                            
        gameUnlockData = new createjs.SpriteSheet({
            "images": [getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/unlock.png')],
            "frames": _frame,
            "animations": _animations
        });
        
        gameUnlockAnimate = new createjs.Sprite(gameUnlockData, "lock");
        gameUnlockAnimate.framerate = 20;
        gameUnlockAnimate.x = canvasW/2;
        gameUnlockAnimate.y = canvasH/2;
        gameUnlockAnimate.visible = false;
        
        gameContainer.addChild(game4Container, gameUnlockAnimate, timerBgBar, timerBar);
        
        canvasContainer.addChild(mainContainer, gameContainer);
        stage.addChild(canvasContainer);
        
        resizeCanvas();
    }

    function resizeCanvas(){
        if(canvasContainer!=undefined){
           timerBgBar.x = offset.x;
           timerBar.x = offset.x;
           timerBgBar.y = canvasH - (offset.y +10);
           timerBar.y = canvasH - (offset.y +10);
       }
    }

    function centerReg(obj){
	    obj.regX=obj.image.naturalWidth/2;
	    obj.regY=obj.image.naturalHeight/2;
    }

    function setupGames(){
        stage.on("stagemousedown", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
        });
        stage.on("stagemousemove", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
        });
        stage.on("stagemouseup", function(evt) {
            
        });
    }

    function drawTimerBar(con){
        timerBgBar.graphics.clear();
        timerBgBar.graphics.beginFill(timerBgBarColor);
        timerBgBar.graphics.drawRect(0, 0, stageW, timerBarH);
        timerBgBar.graphics.endFill();
        
        var currentW = canvasW - (offset.x);
        var timerCount = gameData.timerTotal - gameData.timerCount;
        var newWidth = timerCount / gameData.timerTotal * currentW;
        if(!con){
            newWidth = currentW;
        }
        
        timerBar.graphics.clear();
        timerBar.graphics.beginFill(timerBarColor);
        timerBar.graphics.drawRect(0, 0, newWidth, timerBarH);
        timerBar.graphics.endFill();
        
        if(timerCount <= 10000 && con){
            if(!gameData.timerSound){
                gameData.timerSound = true;
                playSoundLoop('soundTimer');
                animateObject(timerBar, true, true);
            }
        }
        
        if (newWidth <= 0 && !gameData.paused) {
            gameFinish(false);
        }
    }

    function updateGame(event){
        stage.update(event);

        if(gameData.timerEnable){
            var nowDate = new Date();
            gameData.timerCurrent = (nowDate.getTime() - gameData.timerStart.getTime());
            gameData.timerCurrent = gameData.timerCurrent + gameData.timerAccumulate;
            gameData.timerCount = gameData.timerCurrent;
            drawTimerBar(true);
        }
    }

    function gameFinish(success) {
        function timeoutComplete() {
            gameUnlockAnimate.visible = false;
            sendData("minigameResult", { type: 'Connection', result: success });
        }
        stopSoundLoop('soundTimer');
        gameData.paused = true;
        toggleGameTimer(false);
        gameUnlockAnimate.gotoAndStop("lock");
        TweenMax.to(gameUnlockAnimate, 1, {overwrite:true, onComplete:function(){
            gameUnlockAnimate.visible = true;
            if (success) {
                playSound('soundSuccess');
                gameUnlockAnimate.gotoAndPlay('animate');
                TweenMax.to(gameUnlockAnimate, .8, {overwrite:true, onComplete:function(){
                    playSound('soundDoorUnlock');
		    	    TweenMax.to(gameUnlockAnimate, 1.2, {overwrite:true, onComplete:function(){
		    		    TweenMax.to(gameUnlockAnimate, 2, {overwrite:true, onComplete:function(){
                            timeoutComplete()
		    		    }});	
		    	    }});
		        }});
            }
            else {
                playSound('soundFail');
                setTimeout(timeoutComplete, 1000);
            }
        }});
        //timeoutComplete()
    }

    function sendData(name, data){
        $.post("http://bj_minigames/" + name, JSON.stringify(data), function(datab) {
            console.log(datab);
        });
    }
	
	function stopGame() {
		gameData.paused = false;
		sendData("minigameResult", { type: 'Lockpick', result: false });
	}

    initGameCanvas(1280,768);
	buildGameCanvas();
	setupGames();

    return {
        startGame: startGame,
		stopGame: stopGame
    }
}

var BJ = BJ || {};
BJ.Minigames = BJ.Minigames || {};
BJ.Minigames.Connection = new connectionGame();

function safecrackGame() {
    var gameData = {type:0, stageX:0, stageY:0, oldX:0, oldY:0, dirX:'', dirY:'', paused:false, timerEnable:false, timerStart:0, timerCount:0, timerTotal:0, timerSound:false, type_arr:[1,2,3,4], typeNum:0};
    game2Data = {totalCombination:0, timerCombination:0, direction:0, detect:true, detectNum:0, turnNum:0, rotation:0, cRotation:0, angle:0, angle_arr:[], seq_arr:[], seqNum:0, levelNum:0};
    var canvasContainer, mainContainer, gameContainer, game2Container, game2, itemCombiLevel, itemCombiPixel, timerBgBar, timerBar, gameUnlockData, stage, canvasH, canvasW;

    var combiNumber_arr = [0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60,63,67,70,73,77]; //combination number
    var combinationLevelColor = '#4fbbaf'; //combination level color
    var combinationLevelW = 18; //combination level width
    var combinationLevelH = 400; //combination level height

    var timerBarColor = '#51b8ac'; //timer bar color
    var timerBgBarColor = '#3B4F5E'; //timer background bar color
    var timerBarH = 10; //timer bar height

    var totalCombination = 4;
    var timeoutLength = 60000;
        
    var offset = {x:0, y:0, left:0, top:0};

    function startGame(mgData) {
        if (mgData != null) {
            if (mgData.combinations) {
                totalCombination = mgData.combinations;
            }
            if (mgData.timeout) {
                timeoutLength = mgData.timeout;
            }
        }
        game2Data.totalCombination = totalCombination;
        game2Data.timerCombination = timeoutLength;

        game2Container.visible = false;
        gameUnlockAnimate.visible = false;
        
        var targetContainer = null;
        
        targetContainer = game2Container;
		//playSoundLoop('soundPowerLoop');
		createCombiLights(game2Data.totalCombination);
		toggleGameTimer(true, game2Data.timerCombination);
        
        timerBgBar.visible = timerBar.visible = true;
        
        if(targetContainer != null){
	    	targetContainer.visible = true;
	    	targetContainer.alpha = 0;
	    	TweenMax.to(targetContainer, .5, {alpha:1, overwrite:true});
	    }
    
        gameData.paused = false;
        console.log(targetContainer)
    }

    function initGameCanvas(w,h){
        var gameCanvas = document.getElementById("safecrackerGameCanvas");
        gameCanvas.width = w;
        gameCanvas.height = h;
        
        canvasW=w;
        canvasH=h;
        stage = new createjs.Stage("safecrackerGameCanvas");
        
        createjs.Touch.enable(stage);
        stage.enableMouseOver(20);
        stage.mouseMoveOutside = true;
        
        createjs.Ticker.setFPS(60);
        createjs.Ticker.addEventListener("tick", updateGame);	
    }

    function setupCombinationButton(){
        itemCombination1.cursor = "pointer";
        itemCombination1.addEventListener("mousedown", handlerCombiMethod);
        itemCombination1.addEventListener("pressmove", handlerCombiMethod);
        itemCombination1.addEventListener("pressup", handlerCombiMethod);
    }

    function handlerCombiMethod(evt) {
        switch (evt.type){
            case 'mousedown':
                game2Data.cRotation = setDirection(gameData.stageX, gameData.stageY, itemCombination2.x, itemCombination2.y);
                game2Data.cRotation = convertRotate(game2Data.cRotation);
                game2Data.rotation = convertRotate(itemCombination2.rotation);
                break;
               
            case 'pressmove':
                var rads = Math.atan2(gameData.stageY - itemCombination1.y, gameData.stageX - itemCombination1.x);
                var angle = rads * (180 / Math.PI);
                angle = convertRotate(angle+90);
                itemCombination2.rotation = itemCombiPoint.rotation = game2Data.rotation+((angle)-game2Data.cRotation);
               
                getDirection(Math.floor(angle));
                game2Data.angle = Math.floor(angle);
               
                if(!game2Data.detect){
                    game2Data.detect = true;
                    game2Data.turnNum = 50;
                }
                break;
               
            case 'pressup':
                
                break;
        }
    }

    function getDirection(angle){
        if(game2Data.angle <= 10 && angle >= 350){
            return;	
        }else if(game2Data.angle >= 350 && angle <= 10){
            return;	
        }else if(game2Data.angle == angle){
            return;	
        }
        
        if(game2Data.angle > angle){
            game2Data.direction = false;	
        }else if(game2Data.angle <= angle){
            game2Data.direction = true;	
        }
    }

    function setDirection(x1, y1, x2, y2) {
        var radiance = 180/Math.PI;
        var walkdirection = -(Math.atan2(x2-x1, y2-y1))*radiance;
        return walkdirection;
    }

    function convertRotate(angle){
        if(angle<0){
             angle = 180+(angle + 180);
        }
        return angle;	
    }
  
    function createCombiLights(total){
        itemCombination2.rotation = 0;
        
        game2Data.turnNum = 0;
        game2Data.detect = true;
        game2Data.seqNum = 0;
        game2Data.seq_arr = [];
        game2Data.angle_arr = [];
        game2LightContainer.removeAllChildren();
        
        var numGrant = 15;
        var divideNum = Math.floor(24/total);
        
        for(var n=0; n<total; n++){
            var thisAngle = Math.floor(Math.random()*divideNum);
            thisAngle += (n*divideNum);
            
            game2Data.angle_arr.push(numGrant*thisAngle);
        }
        
        shuffle(game2Data.angle_arr);
        var direction = randomBoolean();
        var startX = canvasW/100 * 20;
        var startY = canvasH/2;
        var lightSpace = 65;
        var curY = startY - ((lightSpace * total)/2);
        curY += lightSpace/2;
        
        for(var n=0; n<total; n++){
            var lightButton = itemLightAnimate.clone();
            lightButton.x = startX;
            lightButton.y = curY;
            lightButton.gotoAndStop('off');
            curY += lightSpace;
            
            var lightText = new createjs.Text();
            lightText.font = "22px caviar_dreamsbold";
            lightText.color = "#fff";
            lightText.textAlign = "center";
            lightText.textBaseline='alphabetic';
            lightText.text = '';
            lightText.x = lightButton.x;
            lightText.y = lightButton.y+10;
            
            game2Data.seq_arr.push({rotate:game2Data.angle_arr[n], direction:direction, obj:lightButton, text:lightText});
            direction = direction == true ? false : true;
            
            game2LightContainer.addChild(lightButton, lightText);
        }
    }

    function toggleGameTimer(con, total){
        if(con){
            gameData.timerTotal = total;
            gameData.timerStart = new Date();
            gameData.timerAccumulate = 0;
            gameData.timerCurrent = 0;	
        }else{
            gameData.timerSound = false;	
        }
        gameData.timerEnable = con;
    }

    function buildGameCanvas(){
        canvasContainer = new createjs.Container();
        mainContainer = new createjs.Container();
        gameContainer = new createjs.Container();
        game2Container = new createjs.Container();

        game2 = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/game_layout2.png'));
	    game2LightContainer = new createjs.Container();
	    itemCombination1 = new createjs.Bitmap(getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/item_combination_1.png', () => {
            centerReg(itemCombination1);
        }));
	    itemCombination2 = new createjs.Bitmap(getBitmapImage("https://cdn.themoddingcollective.com/shared/minigames/item_combination_2.png", () => {
            centerReg(itemCombination2);
        }));
	
	    itemCombination1.x = canvasW/100 * 50;
	    itemCombination1.y = canvasH/100 * 50;
	    itemCombination2.x = itemCombination1.x;
	    itemCombination2.y = itemCombination1.y;
        
        var _frameW=128;
	    var _frameH=52;
	    var _frame = {"regX": (_frameW/2), "regY": (_frameH/2), "height": _frameH, "count": 2, "width": _frameW};
	    var _animations = {off:{frames: [0], speed:1},
						    on:{frames: [1], speed:1}};

        itemLightData = new createjs.SpriteSheet({
            "images": [getBitmapImage("https://cdn.themoddingcollective.com/shared/minigames/item_light.png")],
            "frames": _frame,
            "animations": _animations
        });
        
        itemLightAnimate = new createjs.Sprite(itemLightData, "off");
        itemLightAnimate.framerate = 20;
        itemLightAnimate.x = -100;
        
        itemCombiPixel = new createjs.Shape();
        itemCombiPixel.graphics.beginFill(combinationLevelColor);
        itemCombiPixel.graphics.drawRect(-5, -5, 10, 10);
        itemCombiPixel.graphics.endFill();
        
        itemCombiPoint = new createjs.Shape();
        itemCombiPoint.graphics.beginFill(combinationLevelColor);
        itemCombiPoint.graphics.drawRect(-5, -5, 10, 10);
        itemCombiPoint.graphics.endFill();
        itemCombiPoint.visible = itemCombiPixel.visible = false;
        
        itemCombiLevel = new createjs.Shape();
        
        game2Container.addChild(game2, itemCombiLevel, itemCombiPixel, itemLightAnimate, game2LightContainer, itemCombination1, itemCombination2, itemCombiPoint);

        timerBgBar = new createjs.Shape();
        timerBar = new createjs.Shape();
        
        var _frameW=120;
        var _frameH=180;
        var _frame = {"regX": (_frameW/2), "regY": (_frameH/2), "height": _frameH, "count": 2, "width": _frameW};
        var _animations = {lock:{frames: [0], speed:1},
                            animate:{frames: [0,0,0,1], speed:.2, next:'unlock'},
                            unlock:{frames: [1], speed:1}};
                            
        gameUnlockData = new createjs.SpriteSheet({
            "images": [getBitmapImage('https://cdn.themoddingcollective.com/shared/minigames/unlock.png')],
            "frames": _frame,
            "animations": _animations
        });
        
        gameUnlockAnimate = new createjs.Sprite(gameUnlockData, "lock");
        gameUnlockAnimate.framerate = 20;
        gameUnlockAnimate.x = canvasW/2;
        gameUnlockAnimate.y = canvasH/2;
        
        gameContainer.addChild(game2Container, gameUnlockAnimate, timerBgBar, timerBar);
        
        canvasContainer.addChild(mainContainer, gameContainer);
        stage.addChild(canvasContainer);
        
        resizeCanvas();
    }

    function resizeCanvas(){
        if(canvasContainer!=undefined){
           timerBgBar.x = offset.x;
           timerBar.x = offset.x;
           timerBgBar.y = canvasH - (offset.y +10);
           timerBar.y = canvasH - (offset.y +10);
       }
    }

    function centerReg(obj){
	    obj.regX=obj.image.naturalWidth/2;
	    obj.regY=obj.image.naturalHeight/2;
    }

    function setupGames(){
        stage.on("stagemousedown", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
        });
        stage.on("stagemousemove", function(evt) {
            gameData.stageX = evt.stageX
            gameData.stageY = evt.stageY;
        });
        stage.on("stagemouseup", function(evt) {
            
        });
    }

    function drawTimerBar(con){
        timerBgBar.graphics.clear();
        timerBgBar.graphics.beginFill(timerBgBarColor);
        timerBgBar.graphics.drawRect(0, 0, stageW, timerBarH);
        timerBgBar.graphics.endFill();
        
        var currentW = canvasW - (offset.x);
        var timerCount = gameData.timerTotal - gameData.timerCount;
        var newWidth = timerCount / gameData.timerTotal * currentW;
        if(!con){
            newWidth = currentW;
        }
        
        timerBar.graphics.clear();
        timerBar.graphics.beginFill(timerBarColor);
        timerBar.graphics.drawRect(0, 0, newWidth, timerBarH);
        timerBar.graphics.endFill();
        
        if(timerCount <= 10000 && con){
            if(!gameData.timerSound){
                gameData.timerSound = true;
                playSoundLoop('soundTimer');
                animateObject(timerBar, true, true);
            }
        }
        
        if (newWidth <= 0 && !gameData.paused) {
            gameFinish(false);
        }
    }

    function detectLevel(){
        var levelHeight = 0;
        var extraLevel = Math.floor(Math.random()*20);
        
        if(game2Data.turnNum >= 0){
            game2Data.turnNum--;
        }
        
        if(game2Data.turnNum <= 0){
            if(game2Data.seqNum < game2Data.seq_arr.length && game2Data.detect){
                var curAngle = itemCombination2.rotation;
                var curSeq = game2Data.seq_arr[game2Data.seqNum].rotate;
                
                setAnglePosition(itemCombiPixel, itemCombination2.x, itemCombination2.y, 170, curSeq-90);
                setAnglePosition(itemCombiPoint, itemCombination2.x, itemCombination2.y, 100, curAngle-90);
                
                var distance = Math.abs(70 - getDistance(itemCombiPixel, itemCombiPoint));
                var detectDistance = 120;
                
                //if(game2Data.direction == game2Data.seq_arr[game2Data.seqNum].direction){
                    if(Math.abs(distance) <= detectDistance){
                        levelHeight = Math.floor(detectDistance - Math.abs(distance));
                        levelHeight = (levelHeight/detectDistance) * 80;
                        if(Math.abs(distance) <= 2){
                            levelHeight = 98;	
                        }
                        
                        if(Math.abs(distance) == 0){
                            if(game2Data.detectNum <= 0){
                                playSound('soundSafeUnlockIndividual');
                                playSound('soundBonus');
                                
                                game2Data.detect = false;
                                game2Data.seq_arr[game2Data.seqNum].obj.gotoAndStop('on');
                                
                                var negativeString = game2Data.seq_arr[game2Data.seqNum].direction ? '' : '-';
                                game2Data.seq_arr[game2Data.seqNum].text.text = negativeString+combiNumber_arr[curSeq/15];
                                game2Data.seqNum++;
                                game2Data.direction = game2Data.direction == true ? false : game2Data.direction;
                                
                                if(game2Data.seqNum > game2Data.seq_arr.length-1){
                                    playSound('soundSafeUnlock');
                                    gameFinish(true);
                                }
                            }else{
                                game2Data.detectNum--;	
                            }
                        }else{
                            game2Data.detectNum = 50;	
                        }
                    }
                //}else{
                    //reset
                    /*game2Data.detect = false;
                    game2Data.seqNum = 0;
                    for(var n=0; n<game2Data.seq_arr.length; n++){
                        if(game2Data.seq_arr[n].obj.currentFrame == 1){
                            playSound('soundLock');
                        }
                        game2Data.seq_arr[n].obj.gotoAndStop('off');
                        game2Data.seq_arr[n].text.text = '';
                    }
                    TweenMax.to(itemCombiPixel, .3, {overwrite:true, onComplete:function(){
                        game2Data.detect = true;
                    }});*/	
                //}
            }
        }
        
        levelHeight += extraLevel;
        levelHeight = levelHeight > 100 ? 100 : levelHeight;
        
        TweenMax.to(game2Data, .5, {levelNum:combinationLevelH/100 * (levelHeight), overwrite:true, onUpdate:adjustLevel, onUpdateParams:[game2Data.levelNum]});
    }

    function adjustLevel(level){
        itemCombiLevel.graphics.clear();
        itemCombiLevel.graphics.beginFill(combinationLevelColor);
        itemCombiLevel.graphics.drawRect(-(combinationLevelW/2), -(level), combinationLevelW, level);
        itemCombiLevel.graphics.endFill();	
        
        itemCombiLevel.x = canvasW/100*81.2;
        itemCombiLevel.y = canvasH/100*77;
        
        setSoundVolume('soundPowerLoop', level/combinationLevelH * 1)
    }

    function setAnglePosition(obj, x1, y1, radius, angle){
        obj.x = x1 + radius * Math.cos(angle * Math.PI/180)
        obj.y = y1 + radius * Math.sin(angle * Math.PI/180)
    }

    function updateGame(event){
        //return;
        stage.update(event);

        if(gameData.timerEnable){
            var nowDate = new Date();
            gameData.timerCurrent = (nowDate.getTime() - gameData.timerStart.getTime());
            gameData.timerCurrent = gameData.timerCurrent + gameData.timerAccumulate;
            gameData.timerCount = gameData.timerCurrent;
            drawTimerBar(true);
        }

        detectLevel()
    }

    function gameFinish(success) {
        function timeoutComplete() {
            gameUnlockAnimate.visible = false;
            sendData("minigameResult", { type: 'Safecrack', result: success });
        }
        stopSoundLoop('soundTimer');
        gameData.paused = true;
        toggleGameTimer(false);
        gameUnlockAnimate.gotoAndStop("lock");
        TweenMax.to(gameUnlockAnimate, 1, {overwrite:true, onComplete:function(){
            gameUnlockAnimate.visible = true;
            if (success) {
                playSound('soundSuccess');
                gameUnlockAnimate.gotoAndPlay('animate');
                TweenMax.to(gameUnlockAnimate, .8, {overwrite:true, onComplete:function(){
                    playSound('soundDoorUnlock');
		    	    TweenMax.to(gameUnlockAnimate, 1.2, {overwrite:true, onComplete:function(){
		    		    TweenMax.to(gameUnlockAnimate, 2, {overwrite:true, onComplete:function(){
                            timeoutComplete()
		    		    }});	
		    	    }});
		        }});
            }
            else {
                playSound('soundFail');
                setTimeout(timeoutComplete, 1000);
            }
        }});

        totalCombination = 4;
        timeoutLength = 60000;
    }

    function sendData(name, data){
        $.post("http://bj_minigames/" + name, JSON.stringify(data), function(datab) {
            console.log(datab);
        });
    }
	
	function stopGame() {
		gameData.paused = false;
		sendData("minigameResult", { type: 'Lockpick', result: false });
	}

    initGameCanvas(1280,768);
	buildGameCanvas();
	setupGames();
    setupCombinationButton();

    return {
        startGame: startGame,
		stopGame: stopGame
    }
}

var BJ = BJ || {};
BJ.Minigames = BJ.Minigames || {};
BJ.Minigames.Safecrack = new safecrackGame();

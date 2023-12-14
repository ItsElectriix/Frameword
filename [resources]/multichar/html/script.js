var entered = false;

$(document).ready(function() {

    $(".container").show();
    $(".bars").show();
    $(".welcomescreen").hide().fadeIn(500)
    $(".multicharacter").hide();
    $('#myProgress').hide()
    $(".delete-character").hide();
    $(".create-character").hide();

    window.addEventListener('message', function(event) {
        var data = event.data;
        if (data.type === "charSelect") {
            if (data.status == true) {
                $(".container").fadeIn(250);
            } else {
                $(".container").fadeOut(250);
            }
        }

        if (data.type === "setupCharacters") {
            var characters = data.characters
            if (characters !== null) {
                $.each(characters, function(index, char) {
                    $('[data-charid=' + char.cid +']').html('')
                    $('[data-charid=' + char.cid +']').html('<div class="slot-name"><p><span id="slot-player-name">Slot ' + char.cid + '</span></p></div>' +
                    '<div class="play-button" data-charid="' + char.cid +'" data-cid="' + char.citizenid + '"><p>Select Character</p></div>' +
                    '<div class="delete-button" data-charid="' + char.cid +'" data-cid="' + char.citizenid + '"><p>Remove Character</p></div>' +
                    '<div class="player-info"><div class="player-character"><p><span id="bold-text">Name</span>: <span id="player-fn">'+char.charinfo.firstname+' </span><span id="player-ln">'+char.charinfo.lastname+' </span></p><p><span id="bold-text">Birthday</span>: <span id="player-dob">' + char.charinfo.birthdate + '</span></p><p><span id="bold-text">Sex</span>: <span id="player-sex">'+(char.charinfo.gender == 0 ? 'Male' : 'Female')+'</span></p><p><span id="bold-text">Phone-number</span>: <span id="player-phone">'+char.charinfo.phone+'</span></p><p><span id="bold-text">PUID</span>: <span id="player-bsn">'+char.citizenid+'</span></p></div>' +
                    '<div class="player-account"><p><span id="bold-text">Cash</span>: '+data.currencySymbol+' <span id="player-cash">'+formatMoney(char.money.cash)+'</span></p><p><span id="bold-text">Bank</span>: '+data.currencySymbol+' <span id="player-bank">'+formatMoney(char.money.bank)+'</span></p><p><span id="bold-text">Crypto</span>: $ <span id="player-crypto">'+formatMoney(char.money.crypto)+'</span></p><p><span id="bold-text">Account Number</span>: <span id="player-bank-1">'+char.charinfo.account+'</span></p></div>' +
                    '<div class="player-job"><p><span id="bold-text">Job</span>: <span id="player-job">'+char.job.label+'</span></p></div></div>')
                })
            }
            if (data.numChar !== undefined && data.numChar !== null) {
                $('[data-charid]').hide();
                for (let index = 0; index < data.numChar; index++) {
                    $('[data-charid=' + (index + 1) +']').show();
                }
            }
        }
    });


    $(".character").on("click", ".play-button", function(evt) {
        evt.preventDefault();
        var characterid = $(this).data('cid')

        $.post('http://multichar/selectCharacter', JSON.stringify({
            cid: characterid
        }));
    });

    $(".character").on("click", ".delete-button", function(evt){
        evt.preventDefault();
        var citizenid = $(this).data('cid')
        var charid = $(this).data('charid')
        $(".multicharacter").fadeOut(250);
        $(".delete-character").fadeIn(250);
        $(".accept-delete").data('cid', citizenid)
        $(".accept-delete").data('charid', charid)
    });

    document.onkeyup = function (data) {
        if (data.which == 13) {
            if (entered === false) {
                entered = true;
                $('.welcomescreen').fadeOut(250)
                $('#myProgress').fadeIn(250)
                move()
                loadingText()
                retrieveData()
                return
            }
        }
    };
	
	$.post('http://multichar/nuiReady', JSON.stringify({}));
});

$("#accept-delete").click(function(e) {
    e.preventDefault();
    var citizenid = $(this).data('cid')
    var charid = $(this).data('charid')
    $.post('http://multichar/deleteCharacter', JSON.stringify({
        cid: citizenid
    }));
    entered = false;
    $(".delete-character").hide();
    setTimeout(function() {
        $(".welcomescreen").fadeIn(250);
        $('.character[data-charid=' + charid +']').html('<div class="create-button" id="create-cid-'+charid+'" data-cid="' + charid + '"><p>New Character</p></div><div class="slot-name"><p><span id="slot-player-name">Slot ' + charid + '</span></p></div>')
    }, 500);
});

$('.multicharacter').on('click', ".create-button", function(e){
    e.preventDefault();
    var cid = $(this).data('cid');
    console.log(cid)
    $(".multicharacter").children().addClass("reverseAnimation");
    $(".multicharacter").fadeOut(1000);
    setTimeout(function(){
        $(".reverseAnimation").removeClass("reverseAnimation");
    }, 1000);
    $(".create-character").fadeIn(250);
    $('.accept-create').data('cid', cid)
})

$(".deny-create").click(function(e){
    e.preventDefault();
    $(".multicharacter").fadeIn(300);
    $(".create-character").addClass("create-character-reverse")
    setTimeout(function(){
        $(".create-character-reverse").removeClass("create-character-reverse");
    }, 750);
    $(".create-character").fadeOut(400);
})

$("#deny-delete").click(function(e) {
    e.preventDefault();
    $(".multicharacter").fadeIn(250);
    $(".delete-character").fadeOut(250);
});

$(".accept-create").click(function(e) {
    e.preventDefault();
    var charid = $(this).data('cid');
    var data = {
        firstname: $('#firstname').val(),
        lastname: $('#lastname').val(),
        nationality: $('#nationality').val(),
        gender: $('#sex').val(),
        birthdate: $('#dob').val(),
        cid: charid
    };
    $.post('http://multichar/createCharacter', JSON.stringify({
        charData: data
    }))
    entered = false;
    $(".create-character").fadeOut(250);
    $(".welcomescreen").fadeIn(250);
});

function move() {
    var elem = document.getElementById("myBar");
    var width = 0;
    var id = setInterval(frame, 50);
    function frame() {
        if (width >= 100) {
            clearInterval(id);
            $('#myProgress').addClass("myProgressHide")
            setTimeout(function(){
                $(".myProgressHide").hide();
                $(".myProgressHide").removeClass("myProgressHide");
            }, 1000);
            $(".multicharacter").fadeIn(250);
        } else {
            width++;
        }
    }
}

function loadingText() {
    setTimeout(function() {
        $("#progbar-wait").append(".");
        setTimeout(function() {
            $("#progbar-wait").append(".");
            setTimeout(function() {
                $("#progbar-wait").append(".");
                setTimeout(function() {
                    $("#progbar-wait").html("Please wait");
                    setTimeout(function() {
                        $("#progbar-wait").append(".");
                        setTimeout(function() {
                            $("#progbar-wait").append(".");
                            setTimeout(function() {
                                $("#progbar-wait").append(".");
                                setTimeout(function() {
                                    $("#progbar-wait").html("Please wait");
                                }, 600);
                            }, 600);
                        }, 600);
                    }, 600);
                }, 600);
            }, 600);
        }, 600);
    }, 600);
}

function retrieveData() {
    setTimeout(function() {
        $("#progbar-text").html("Loading Characters");
        setTimeout(function() {
            $("#progbar-text").html("Loading Vehicles");
            setTimeout(function() {
                $("#progbar-text").html("Loading Inventories");
                setTimeout(function() {
                    $("#progbar-text").html("Loading Weapons");
                    setTimeout(function() {
                        $("#progbar-text").html("Loading Properties");
                    }, 1300);
                }, 800);
            }, 900);
        }, 1500);
    }, 1);
}

function formatMoney(n, c, d, t) {
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};
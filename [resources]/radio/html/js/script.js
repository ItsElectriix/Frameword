$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "open") {
            BJRadio.SlideUp()
        }

        if (event.data.type == "close") {
            BJRadio.SlideDown()
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://radio/escape', JSON.stringify({}));
            BJRadio.SlideDown()
        } else if (data.which == 13) { // Escape key
            $.post('http://radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            }));
        }
    };
});

BJRadio = {}

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('http://radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('http://radio/leaveRadio');
});

BJRadio.SlideUp = function() {
    $(".container").css("display", "block");
    $(".radio-container").animate({bottom: "6vh",}, 250);
}

BJRadio.SlideDown = function() {
    $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
        $(".container").css("display", "none");
    });
}
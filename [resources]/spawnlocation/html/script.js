$('document').ready(function() {

    $(".container").hide();
    $("#submit-spawn").hide()

    window.addEventListener('message', function(event) {
        var data = event.data;
        if (data.type === "ui") {
            if (data.status == true) {
                $(".container").fadeIn(250);
            } else {
                $(".container").fadeOut(250);
                $('.property').remove();
            }
        } else if (data.type == "properties") {
            $('.property').remove();
            for (var k in data.properties["houses"]) {
                $(`<div class="location property" id="location" data-location="property" data-key="${data.properties["houses"][k].house}" data-label="${data.properties["houses"][k].address}">
                    <p><span id="property">${data.properties["houses"][k].address}</span></p>
                </div>`).insertBefore('#submit-spawn');
            }
            for (var k in data.properties["apartments"]) {
                $(`<div class="location property" id="location" data-location="apartment" data-key="${data.properties["apartments"][k].building}" data-label="${data.properties["apartments"][k].address}">
                    <p><span id="property">${data.properties["apartments"][k].address}</span></p>
                </div>`).insertBefore('#submit-spawn');
            }
            $('#property').text(data.propertyType);
        }
    })

    $('.spawn-locations').on('click', '.location', function(evt){
        evt.preventDefault(); //dont do default anchor stuff
        var location = $(this).data('location'); //get the text
        var label = $(this).data('label'); //get the text
        var key = $(this).data('key');
        $("#spawn-label").html("Confirm Location (" + label +")")
        $("#submit-spawn").attr("data-location", location);
        $("#submit-spawn").attr("data-key", key);
        $("#submit-spawn").fadeIn(100)
        $.post('http://spawnlocation/setCam', JSON.stringify({
            posname: location,
            key: key
        }));
    });

    $('#submit-spawn').on('click', function(evt){
        evt.preventDefault(); //dont do default anchor stuff
        var location = $(this).attr('data-location');
        var key = $(this).attr('data-key');
        $(".container").addClass("hideContainer").fadeOut("9000");
        setTimeout(function(){
            $(".hideContainer").removeClass("hideContainer");
			$("#submit-spawn").attr("data-location", "");
			$("#submit-spawn").hide();
            $('.property').remove();
        }, 900);
        $.post('http://spawnlocation/spawnplayer', JSON.stringify({
            spawnloc: location,
            key: key
        }));
    });
})

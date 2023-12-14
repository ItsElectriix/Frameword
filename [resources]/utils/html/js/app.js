var noteId = null
$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            Notepad.Close();
            break;
    }
});

$(document).on('click', '#drop', function(){
    Notepad.Close();
    $.post("https://utils/DropNote", JSON.stringify({
        text: $("#notetext").val(),
        noteid: noteId,
    }));
});

$(document).on('click', '#save', function(){
    if ($("#notetext").val().length > 0) {
        Notepad.Close();
        $.post("https://utils/SaveNote", JSON.stringify({
            text: $("#notetext").val(),
            noteid: noteId,
        }));
    }
});

(() => {
    Notepad = {};

    Notepad.Open = function(data) {
        $(".notepad-container").css("display", "block");
        noteId = data.noteid;
        if (data.text != null) {
            $("#notetext").val(data.text);
        }
    };

    Notepad.Close = function() {
        $(".notepad-container").css("display", "none");
        $.post("https://utils/CloseNotepad", JSON.stringify({
            noteid: noteId,
        }));
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case "open":
                    Notepad.Open(event.data);
                    break;
                case "close":
                    Notepad.Close();
                    break;
            }
        })
    }

})();
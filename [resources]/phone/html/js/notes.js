function SetupNotePage(type, data, index) {
    $(".new-note").data('type', type);
    
    if (type != 'view') {
        $('.new-note-title').show();
        $('.new-note-textarea').show();
        $('#note-render-content').hide();
    }

    if (type == 'new') {
        $('.new-note-title').val('');
        $('.new-note-textarea').val('');
        $('.new-note').data('id', '');
        $(".new-note").data('note', {});
        $('#new-note-header-text').html('New note');
    }
    else if (type == 'edit') {
        $('#new-note-header-text').html('Edit note')
        $('.new-note-title').val(data.Title);
        $('.new-note-textarea').val(data.Message);

        $('.new-note').data('id', index);
        $(".new-note").data('note', data);
    }
    else {
        $('.new-note-title').val(data.Title);
        $('.new-note-textarea').val(data.Message);
        
        var converter = new showdown.Converter({tables: true, strikethrough: true, parseImgDimensions: true});
        document.getElementById('note-view-md').innerHTML = converter.makeHtml(BJ.Phone.Functions.StripAngledBrackets(data.Message));
        
        $('.new-note-title').hide();
        $('.new-note-textarea').hide();
        $('#note-render-content').show();
        
        $('#new-note-header-text').html(data.Title);
    }

    $('.new-note-title').prop('disabled', type == 'view');
    $('.new-note-textarea').prop('disabled', type == 'view');

    $(".note-home").animate({
        left: 30+"vh"
    });
    $(".new-note").animate({
        left: 0+"vh"
    });
}

$(document).on('click', '.create-note', function(e){
    e.preventDefault();

    SetupNotePage('new');
});

$(document).on('click', '.note-edit', function(e){
    e.preventDefault();

    let noteParent = $(this).closest('.note');
    let data = $(noteParent).data('note');
    let index = $(noteParent).data('id');

    SetupNotePage('edit', data, index);
});

$(document).on('click', '.note-view', function(e){
    e.preventDefault();

    let noteParent = $(this).closest('.note');
    let data = $(noteParent).data('note');
    let index = $(noteParent).data('id');

    SetupNotePage('view', data, index);
});

$(document).on('click', '#new-note-back', function(e){
    e.preventDefault();

    $(".note-home").animate({
        left: 0+"vh"
    });
    $(".new-note").animate({
        left: -30+"vh"
    });
});

$(document).on('click', '#new-note-submit', function(e){
    e.preventDefault();

    let type = $(".new-note").data('type');

    if (type == 'view') {
        $(".note-home").animate({
            left: 0+"vh"
        });
        $(".new-note").animate({
            left: -30+"vh"
        });
    }

    var noteText = $(".new-note-textarea").val();
    var noteTitle = $(".new-note-title").val();

    if (noteTitle !== "") {
        if (type == 'new') {
            $.post('http://phone/AddNote', JSON.stringify({
                Title: noteTitle,
                Message: noteText,
                Created: new Date().valueOf(),
                Updated: new Date().valueOf()
            }));
        }
        else if (type == 'edit') {
            let index = $('.new-note').data('id');
            let note = $(".new-note").data('note');

            note.Title = noteTitle;
            note.Message = noteText;
            note.Updated = new Date().valueOf();

            $.post('http://phone/EditNote', JSON.stringify({
                Index: index,
                Note: note
            }));
        }
        $(".note-home").animate({
            left: 0+"vh"
        });
        $(".new-note").animate({
            left: -30+"vh"
        });
        $(".new-note-textarea").val('');
        $(".new-note-title").val('');
    } else {
        BJ.Phone.Notifications.Add("fas fa-sticky-note", "Notes", "You can\'t save an empty note!", "#1af0ff", 2000);
    }
});

$(document).on('click', '.note-delete', function(e){
    e.preventDefault();

    let noteData = $(this).closest('.note').data('note');
    let noteIndex = $(this).closest('.note').data('id');
    
    $('#accept-note-del').data('id', noteIndex);

    $(".note-home").animate({
        left: 30+"vh"
    });
    $(".note-del-confirm").animate({
        left: 0+"vh"
    });
});

$(document).on('click', '#accept-note-del', function(e){
    e.preventDefault();
    
    BJ.Phone.Notifications.Add("fas fa-sticky-note", "Notes", "Note deleted");
    $.post('http://phone/DeleteNote', JSON.stringify({
        index: $(this).data('id')
    }));
    $(this).data('id', '');
    setTimeout(() => {
        $(".note-home").animate({
            left: 0+"vh"
        });
        $(".note-del-confirm").animate({
            left: -30+"vh"
        });
    }, 150);
});

$(document).on('click', '#cancel-note-del', function(e){
    e.preventDefault();
    $('#accept-note-del').data('id', '');
    $(".note-home").animate({
        left: 0+"vh"
    });
    $(".note-del-confirm").animate({
        left: -30+"vh"
    });
});

SetupNotes = function(notes) {
    $("#note-header-name").html(BJ.Phone.Data.PlayerData.charinfo.firstname+" "+BJ.Phone.Data.PlayerData.charinfo.lastname+"'s Personal Notes");
    if (Array.isArray(notes) && notes.length > 0) {
        $(".note-list").html("");
        $.each(notes.reverse(), function(i, note){
            let index = notes.length - i;
            var element = '<div class="note" data-id="' + index + '"><table><tr><td class="note-cont"><div class="note-sender">'+note.Title+'</div><div class="note-info">Updated: '+new Date(note.Updated).toLocaleString()+'</div></td><td class=""><div class=""><i class="fas fa-eye note-view"></i><i class="fas fa-edit note-edit"></i><i class="fas fa-trash note-delete"></i></div></td></table></div>';
            $(".note-list").append(element);
            $('.note[data-id=' + index + ']').data('note', note);
        });
    } else {
        $(".note-list").html("");
        var element = '<div class="note"><span class="note-sender" style="font-size: 1vh;line-height: 3vh;">You have no notes yet!</span></div>';
        $(".note-list").append(element);
    }
}
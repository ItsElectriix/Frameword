
window.addEventListener('load', () => {
    window.addEventListener('message', function(event) {
        var data = event.data;

        if (data.type == 'show') {
            $('#charPicture').attr('src', data.profilePicture);
            $('#charName').text(`${data.charInfo.firstname} ${data.charInfo.lastname}`);
            $('#charBirthdate').text(data.charInfo.birthdate);
            $('#charNationality').text(data.charInfo.nationality);
            $('#charGender').text(data.charInfo.gender.toString() == '0' ? 'Male' : 'Female');

            $('#repList').empty();

            for (var k in data.repInfo) {
                let rep = data.repInfo[k];
                $('#repList').append(`<p>${rep.name}: ${rep.title}`);
            }

            $('#container').show("slide", { direction: "left" }, 1000);
            setTimeout(() => {
                $('#container').hide("slide", { direction: "left" }, 1000);
            }, 10000);
        } else if (data.type == 'hide') {
            $('#container').hide("slide", { direction: "left" }, 1000);
        }
    });
});
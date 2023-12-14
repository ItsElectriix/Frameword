let alertId = 0;
let notifications = [];
let selectedNotification = 0;

let addAlert = function(alertHtml) {
    $(alertHtml).insertAfter('.notifications-list').show("blind", {
        direction: "up"
    }, 1000);
};

let categories = {
    0: { id: 0, name: 'Low Priority', sound: null },
    1: { id: 1, name: 'Standard', sound: 'pager' },
    2: { id: 2, name: 'Priority', sound: 'panic' },
    3: { id: 3, name: 'High Priority', sound: 'panicdispatch' }
};

let queuedAlerts = [];
let notifAudioPlayer = null;

let processQueue = function() {
    if (queuedAlerts.length > 0) {
        var alert = queuedAlerts.shift();
        var newAlert = $(alert.html);

        $('.notification-list').append(newAlert);
        $('.notification-list').css('top', newAlert.height() + 20);
        $('.notification-list').animate({'top': 0}, 750);

        if (notifAudioPlayer != null) notifAudioPlayer.pause();

        if (alert.sound != null) {
            notifAudioPlayer = new Howl({src: ["./sounds/" + alert.sound + ".ogg"]});
            notifAudioPlayer.volume(0.2);
            notifAudioPlayer.play();
        }

        setTimeout(function() {
            $(`#notification-${alert.id}`).animate({'opacity': '0'}, 750, function() {
                $(`#notification-${alert.id}`).remove();
            });
        }, 7800);
        setTimeout(processQueue, 800);
    }
    else {
        setTimeout(processQueue, 100);
    }
};
setTimeout(processQueue, 100);

let createNotification = function(job, notifIcon, notifType, body, loc, coords, category, hidden) {
    alertId++;

    let notif = {
        job: job,
        icon: notifIcon,
        type: notifType,
        text: body,
        location: loc,
        coords: coords,
        timestamp: new Date(),
        category: category !== undefined && category !== null ? category : 1
    };

    notifications.push(notif);
    if (hidden === false) {
        queuedAlerts.push({id: alertId, html: `
            <div class="notification job-${job}" id="notification-${alertId}">
                <div class="notification-type"><i class="${notif.icon} notification-type-icon"></i>${notif.type}</div>
                <div class="notification-body">${notif.text}</div>
            </div>
            `, sound: categories[notif.category].sound}); 
    }

    if (selectedNotification == (notifications.length - 1)) {
        changeSelectedNotification(true); // Stay on latest alert unless user specifically changes off it
    }

    updateNotificationCount();
};

let updateNotificationCount = function() {
    $('.notification-count').text(`${selectedNotification} / ${notifications.length}`)
};

let changeSelectedNotification = function(up) {
    if (up) {
        if (selectedNotification < notifications.length) {
            selectedNotification = selectedNotification + 1;
            reloadNotification();
        }
    } else {
        if (selectedNotification > 0) {
            selectedNotification = selectedNotification - 1;
            reloadNotification();
        }
    }
};

let deleteNotification = function(id) {
    if (notifications.length >= id) {
        if (id == notifications.length && id == selectedNotification) {
            selectedNotification = selectedNotification - 1
        }
        notifications.splice(id - 1, 1);
    }
    reloadNotification();
};

let reloadNotification = function() {
    console.log("reload")
    let notif = notifications[selectedNotification - 1];

    if (notif !== undefined && notif !== null) {
        $('.notification-body p').text(notif.text);
        $('.notification-location').text(notif.location);
        $('.notification-time').text(formatDate(notif.timestamp))
    }
    else {
        $('.notification-body p').text('');
        $('.notification-location').text('');
        $('.notification-time').text('');
    }
    updateNotificationCount();
};

let events = {
    toggleDisplay: (eventData) => {
        $('.notification-manager').toggleClass('hidden')
    },
    setInCar: (eventData) => {
        if (eventData.isInCar) {
            $('.notification-toasts').addClass('in-car');
        }
        else {
            $('.notification-toasts').removeClass('in-car');
        }
    },
    changeSelection: (eventData) => {
        if (eventData.direction == 'up') {
            changeSelectedNotification(true);
        }
        else {
            changeSelectedNotification(false);
        }
    },
	clearNotifications: (eventData) => {
		notifications = [];
		selectedNotification = 0;
		reloadNotification();
	},
    addNotification: (eventData) => {
        createNotification(eventData.job, eventData.iconCss, eventData.title, eventData.body, eventData.street, eventData.coords, eventData.category, eventData.hidden);
    },
    deleteNotification: (eventData) => {
        if (eventData.id === 'cur') {
            console.log("delete cur UI")
            deleteNotification(selectedNotification);
        }
        else {
            deleteNotification(eventData.id);
        }
    },
    setGps: (eventData) => {
        let currentNotif = notifications[selectedNotification - 1];
        if (currentNotif !== undefined && currentNotif !== null) {
            $.post('http://jobnotif/SetGps', JSON.stringify({
                coords: currentNotif.coords
            }));
        }
    }
};

window.addEventListener('message', function(event) {
    if (event.data) {
        //console.log('Event Received: ' + event.data.type);
        if (events[event.data.type]) {
            events[event.data.type](event.data.data);
        }
    }
});

let sendFakeEvent = function(eventType, data) {
    let event = new CustomEvent('message');
    event.data = {
        type: eventType,
        data: data
    };

    window.dispatchEvent(event);
};

let formatDate = function(date) {
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12; // the hour '0' should be '12'
    hours = hours < 10 ? '0'+hours : hours;
    minutes = minutes < 10 ? '0'+minutes : minutes;
    var strTime = hours + ':' + minutes + ampm;
    return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + " " + strTime;
};

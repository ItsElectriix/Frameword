$(function() {
    let zones = { AIRP: "Los Santos International Airport", ALAMO: "Alamo Sea", ALTA: "Alta", ARMYB: "Fort Zancudo", BANHAMC: "Banham Canyon Dr", BANNING: "Banning", BEACH: "Vespucci Beach", BHAMCA: "Banham Canyon", BRADP: "Braddock Pass", BRADT: "Braddock Tunnel", BURTON: "Burton", CALAFB: "Calafia Bridge", CANNY: "Raton Canyon", CCREAK: "Cassidy Creek", CHAMH: "Chamberlain Hills", CHIL: "Vinewood Hills", CHU: "Chumash", CMSW: "Chiliad Mountain State Wilderness", CYPRE: "Cypress Flats", DAVIS: "Davis", DELBE: "Del Perro Beach", DELPE: "Del Perro", DELSOL: "La Puerta", DESRT: "Grand Senora Desert", DOWNT: "Downtown", DTVINE: "Downtown Vinewood", EAST_V: "East Vinewood", EBURO: "El Burro Heights", ELGORL: "El Gordo Lighthouse", ELYSIAN: "Elysian Island", GALFISH: "Galilee", GOLF: "GWC and Golfing Society", GRAPES: "Grapeseed", GREATC: "Great Chaparral", HARMO: "Harmony", HAWICK: "Hawick", HORS: "Vinewood Racetrack", HUMLAB: "Humane Labs and Research", JAIL: "Bolingbroke Penitentiary", KOREAT: "Little Seoul", LACT: "Land Act Reservoir", LAGO: "Lago Zancudo", LDAM: "Land Act Dam", LEGSQU: "Legion Square", LMESA: "La Mesa", LOSPUER: "La Puerta", MIRR: "Mirror Park", MORN: "Morningwood", MOVIE: "Richards Majestic", MTCHIL: "Mount Chiliad", MTGORDO: "Mount Gordo", MTJOSE: "Mount Josiah", MURRI: "Murrieta Heights", NCHU: "North Chumash", NOOSE: "N.O.O.S.E", OCEANA: "Pacific Ocean", PALCOV: "Paleto Cove", PALETO: "Paleto Bay", PALFOR: "Paleto Forest", PALHIGH: "Palomino Highlands", PALMPOW: "Palmer-Taylor Power Station", PBLUFF: "Pacific Bluffs", PBOX: "Pillbox Hill", PROCOB: "Procopio Beach", RANCHO: "Rancho", RGLEN: "Richman Glen", RICHM: "Richman", ROCKF: "Rockford Hills", RTRAK: "Redwood Lights Track", SANAND: "San Andreas", SANCHIA: "San Chianski Mountain Range", SANDY: "Sandy Shores", SKID: "Mission Row", SLAB: "Stab City", STAD: "Maze Bank Arena", STRAW: "Strawberry", TATAMO: "Tataviam Mountains", TERMINA: "Terminal", TEXTI: "Textile City", TONGVAH: "Tongva Hills", TONGVAV: "Tongva Valley", VCANA: "Vespucci Canals", VESP: "Vespucci", VINE: "Vinewood", WINDF: "Ron Alternates Wind Farm", WVINE: "West Vinewood", ZANCUDO: "Zancudo River", ZP_ORT: "Port of South Los Santos", ZQ_UAR: "Davis Quartz" };
    let directions = ['N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE', 'N'];
	let speedColours = ["#fff6aa","#fff0a7","#ffeaa4","#ffe4a1","#ffde9e","#ffd89b","#ffd298","#ffcc95","#ffc692","#ffc08f","#ffba8c","#ffb489","#ffae87","#ffa884","#ffa281","#ff9c7e","#ff967b","#ff9078","#ff8a75","#ff8472","#ff7e6f","#ff786c","#ff7269","#ff6c66","#ff6663"];
    let config = {
        warnClass: "ui-warn",
        fuelWarn: 15,
        speedWarn: 75
    };
    let carHudData = {
        inVehicle: false,
		time: {
			time: "00:00",
			type: "AM"
		},
        location: {
            heading: 0,
            streetName: null,
            zoneName: "AIRP"
        },
        seatbelt: false,
        cruise: false,
		cruiseSpeed: 0,
		isHeli: false,
		altitude: 0,
		altitudeSea: 0,
        speed: 0,
        fuel: 0
    };

    window.addEventListener('message', function(event) {
		switch (event.data.type) {
            case "uiUpdate":
                for (var i in event.data) {
                    if (carHudData[i] !== undefined) {
                        carHudData[i] = event.data[i];
                    }
                }
                triggerHudUpdate();
                break;
            case "enableUi":
                $("body").show();
                break;
            case "disableUi":
                $("body").hide();
                break;
        }
    });

    function triggerHudUpdate() {
        if (carHudData.inVehicle) {
            $(".in-car").show();
			$("#carUi").addClass("is-in-car");
			
			if (carHudData.isHeli) {
				$(".in-heli").show();
			}
			else {
				$(".in-heli").hide();
			}
		}
        else {
            $(".in-car").hide();
			$(".in-heli").hide();
			$("#carUi").removeClass("is-in-car");
		}

        var heading = directions[Math.floor((carHudData.location.heading + 22.5) / 45.0)]
        var zoneName = zones[carHudData.location.zoneName];

        var locationText = heading;
        if (carHudData.location.streetName != null && carHudData.location.streetName != "") {
            locationText = `${locationText} | ${carHudData.location.streetName}`;
        }
        if (zoneName != null && zoneName != "") {
            locationText = `${locationText} | ${zoneName}`;
        }

        $("#location").text(locationText);
        $("#time").text(carHudData.time.time);
		$("#time-container .label").text(carHudData.time.type);

        var currSpeed = Math.ceil(carHudData.speed * 2.237);
        $("#speed").text(`${currSpeed}`);
		if (currSpeed >= 50) {
			if (currSpeed >= 50 + speedColours.length) {
				$("#speed").css("color", speedColours[speedColours.length - 1]);
			}
			else {
				$("#speed").css("color", speedColours[currSpeed - 51]);
			}
		}
		else {
			$("#speed").css("color", "white");
		}
        if (currSpeed >= config.speedWarn) {
            $("#speed").addClass(config.warnClass);
        }
		else {
			$(`#speed.${config.warnClass}`).removeClass(config.warnClass);
		}

        var currFuel = Math.ceil(carHudData.fuel);
        $("#fuel").text(`${currFuel}`);
        if (currFuel <= config.fuelWarn) {
            $("#fuel").addClass(config.warnClass);
        }
		else {
			$(`#fuel.${config.warnClass}`).removeClass(config.warnClass);
		}
        if (carHudData.cruise) {
			var cruiseSpeed = Math.floor(carHudData.cruiseSpeed * 2.237)
            $("#cruise").html(`LIMIT (${cruiseSpeed} <small>MPH</small>)`).addClass("on");
        }
        else {
            $("#cruise").html(`LIMIT`).removeClass("on");
        }

        if (carHudData.seatbelt) {
            $("#seatbelt").addClass("on");
        }
        else {
            $("#seatbelt").removeClass("on");
        }
		
		var currAltitude = Math.ceil(carHudData.altitude * 3.281)
		$('#altitude').text(currAltitude)
		var currAltitudeSea = Math.ceil(carHudData.altitudeSea * 3.281)
		$('#altitudeSea').text(currAltitudeSea)
    }
});
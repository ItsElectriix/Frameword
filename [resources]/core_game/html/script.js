( () => {

	const debounce = ( func, delay ) => {

        let debounceTimer
    
        return function ( ...args ) {
    
            const context = this
            clearTimeout( debounceTimer )
            debounceTimer = setTimeout( () => func.apply( context, args ), delay )
    
        }
    
    }

	// DOM elements
    const crosshairElement = document.querySelector( '#crosshair' )
    const crosshairWrapperElement = document.querySelector( '.crosshair-wrapper' )
	const crosshairImg = document.querySelector( '#crosshairImg' )
	const opacityInput = document.querySelector( '#setting-opacity' )
	const opacityOutput = document.querySelector( '#output-opacity' )
    const selectCrosshairBtn = document.querySelector( '#select-crosshair-button' )
    const dontBtn = document.querySelector( '#done-button' )
	const sizeInput = document.querySelector( '#setting-size' )
    const sizeOutput = document.querySelector( '#output-size' )
    const settingsContainerElement = document.querySelector( '#settings-container' )
    const chooserElement = document.querySelector( '#crosshair-chooser' )
    const generalSettingsElement = document.querySelector( '.settings' )
    
    const defaults = {
        color: 'black',
        crosshair: "crosshairs/no-crosshair.png",
        opacity: "100",
        sight: "cross",
        size: 100,
    }

    let config = localStorage.getItem('config');

    const saveData = () => {
        localStorage.setItem('config', JSON.stringify(config));
    }

    if (config == null) {
        config = JSON.parse(JSON.stringify(defaults));
        saveData();
    } else {
        config = JSON.parse(config);
    }
    
	// Create color picker
	const pickr = Pickr.create( {
		el: '.color-picker',
		theme: 'nano', // Or 'monolith', or 'nano'
		closeOnScroll: true,
		position: 'left-middle',

		swatches: [
			'rgba(244, 67, 54, 1)',
			'rgba(233, 30, 99, 0.95)',
			'rgba(156, 39, 176, 0.9)',
			'rgba(103, 58, 183, 0.85)',
			'rgba(63, 81, 181, 0.8)',
			'rgba(33, 150, 243, 0.75)',
			'rgba(3, 169, 244, 0.7)',
			'rgba(0, 188, 212, 0.7)',
			'rgba(0, 150, 136, 0.75)',
			'rgba(76, 175, 80, 0.8)',
			'rgba(139, 195, 74, 0.85)',
			'rgba(205, 220, 57, 0.9)',
			'rgba(255, 235, 59, 0.95)',
			'rgba(255, 193, 7, 1)'
		],

		components: {
			// Main components
			preview: true,
			opacity: true,
			hue: true,

			// Input / output Options
			interaction: {
				hex: false,
				rgba: false,
				hsla: false,
				hsva: false,
				cmyk: false,
				input: true,
				clear: false,
				save: true
			}
		}
	} )
	window.pickr = pickr

	const setCrosshair = crosshair => {

		if ( crosshair === 'none' ) {

			crosshairImg.style.display = 'none'

		} else {

			crosshairImg.src = crosshair
			crosshairImg.style.display = 'block'

        }
        
        config.crosshair = crosshair

        settingsContainerElement.style.display = 'none';

        saveData();
	}

	// Color
	const stripHex = color => {

		const hex = color.toHEXA().toString()
		if ( hex.length > 7 ) {

			return hex.slice( 0, 7 )

		}

		return hex

	}

	const setColor = color => {

		document
			.querySelector( '.sight' )
            .style.setProperty( '--sight-background', `${color}` )
            

    }

	pickr
		.on( 'change', color => {

            setColor( stripHex( color ) )
            config.color = stripHex(color);
			saveData();

		} )
		.on( 'save', color => {

            pickr.hide()

		} )
		.on( 'show', () => {

			document.body.classList.add( 'pickr-open' )

		} )
		.on( 'hide', () => {

			document.body.classList.remove( 'pickr-open' )

        } )
        .on( 'init', () => {
            pickr.setColor(config.color);
        } )

	// Opacity
	const dOpacityInput = debounce( value => {

        config.opacity = value
		saveData();

	}, 1000 )

	const setOpacity = opacity => {

		opacityInput.value = opacity
		opacityOutput.textContent = opacity
		crosshairImg.style.opacity = `${opacity / 100}`
		document.querySelector( '.sight' ).style.opacity = `${opacity / 100}`
		dOpacityInput( opacity )

	}

	opacityInput.addEventListener( 'input', event => {

		setOpacity( event.target.value )

	} )

	// Size
	const dSizeInput = debounce( value => {

        config.size = value
		saveData();

	}, 1000 )

	const setSize = size => {

		sizeInput.value = size
		sizeOutput.textContent = size
		crosshairElement.style = `width: ${size}px;height: ${size}px;`
		dSizeInput( size )

	}

	sizeInput.addEventListener( 'input', event => {

		setSize( event.target.value )

	} )

	// Sight
	const setSight = sight => {

		document.querySelector( '.sight' ).classList.remove( 'dot', 'cross', 'off' )
		document.querySelector( '.sight' ).classList.add( sight )
        document.querySelector( `.radio.${sight} input` ).checked = true
        config.sight = sight
		saveData();

	}

	const sightInputs = document.querySelectorAll( '.radio' )
	for ( const element of sightInputs ) {

		element.addEventListener( 'change', event => {

			setSight( event.target.value )

		} )

	}

    let crosshairsLoaded = false;

	// Button to open crosshair chooser
	selectCrosshairBtn.addEventListener( 'click', () => {

        // Send open request with current crosshair
        if (!crosshairsLoaded) {
            loadCrosshairs(Crosshairs, config.crosshair);
            crosshairsLoaded = true;
        }
        
        settingsContainerElement.style.display = 'block';
    } )

	// Crosshair Images -> <select> input
	const loadCrosshairs = (crosshairs, current) => {

		// Create "No crosshair" option

		for ( const element of crosshairs ) {

			if ( typeof element === 'string' ) {

				const img = createImage( element, current )
				chooserElement.append( img )

			} else if ( typeof element === 'object' ) {

				createGroup( element, current )

			}

		}

	}

	// Title Case and spacing
	function prettyFilename( string ) {

        // Remove path and extension
        if (string.indexOf('/') > -1) {
            string = string.split('/')[1];
        }

        if (string.indexOf('.') > -1) {
            string = string.split('.')[0];
        }

		string = string
			.split( '-' )
			.map( w => w[0].toUpperCase() + w.slice( 1 ).toLowerCase() )
			.join( ' ' )

		return string

	}

	// Create option elements
	const createImage = ( file, current ) => {

		const name = prettyFilename( file )
		const div = document.createElement( 'DIV' )
		const p = document.createElement( 'P' )
		const img = document.createElement( 'IMG' )

        file = 'crosshairs/' + file;

		div.classList.add( 'crosshair-option' )
		p.textContent = name

		img.alt = name
		img.draggable = false
		img.src = file

		if ( current === file ) {

			img.classList = 'current'

		}

		img.addEventListener( 'click', event => {

			setCrosshair( file )

			// Set 'selected' border color
			const current = document.querySelector( '.current' )
			if ( current ) {

				current.classList.remove( 'current' )

			}

			event.target.classList.add( 'current' )

		} )

		div.append( img, p )

		return div

	}

	// Setup optgroup elements
	const createGroup = ( files, current ) => {

		const group = document.createElement( 'DIV' )
		const title = document.createElement( 'P' )

		// Split path into name and remove slashes
		let label = files[0].split('/')[0].replace('_', ' ');

		for ( const element of files ) {

			if ( typeof element === 'string' ) {

				const img = createImage( element, current )
				group.append( img )

			}

		}

		title.classList.add( 'group-label' )
		title.textContent = label

		chooserElement.append( title )
		chooserElement.append( group )

    }

    const isset = val => {
        return val !== null && val !== undefined;
    };

    if (isset(config.crosshair)) {
        setCrosshair(config.crosshair);
    }
    if (isset(config.color)) {
        setColor(config.color);
    }
    if (isset(config.opacity)) {
        setOpacity(config.opacity);
    }
    if (isset(config.sight)) {
        setSight(config.sight);
    }
    if (isset(config.size)) {
        setSize(config.size);
    }

    window.addEventListener('message', function(e) {
        var event = e.data;
        if (event.type === "showCrosshair") {
            crosshairWrapperElement.style.display = 'flex';
        } else if (event.type === "hideCrosshair") {
            crosshairWrapperElement.style.display = 'none';
        } else if (event.type === "focusUi") {
            generalSettingsElement.style.display = 'block';
            crosshairWrapperElement.style.display = 'flex';
        } else if (event.type === "unfocusUi") {
            generalSettingsElement.style.display = 'none';
            settingsContainerElement.style.display = 'none';
            crosshairWrapperElement.style.display = 'none';
        }
    });

    dontBtn.addEventListener( 'click', () => {
        generalSettingsElement.style.display = 'none';
        settingsContainerElement.style.display = 'none';
        crosshairWrapperElement.style.display = 'none';

        var xhr = new XMLHttpRequest();
        xhr.open("POST", 'https://core_game/UnfocusUi', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send();
    } )
} )()
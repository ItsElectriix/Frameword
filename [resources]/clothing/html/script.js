BJClothing = {}

var selectedTab = ".characterTab"
var lastCategory = "character"
var selectedCam = null;
var hasTracker = false;
var canChange = true;
var cameraKeybindsEnabled = true;

var clothingCategorys = [];

var isService = false;

let mothers = ["Hannah", "Aubrey", "Jasmine", "Gisele", "Amelia", "Isabella", "Zoe", "Ava", "Camila", "Violet", "Sophia", "Evelyn", "Nicole", "Ashley", "Gracie", "Brianna", "Natalie", "Olivia", "Elizabeth", "Charlotte", "Emma", "Hannah", "Aubrey", "Jasmine", "Gisele", "Amelia", "Isabella", "Zoe", "Ava", "Camila", "Violet", "Sophia", "Evelyn", "Nicole", "Ashley", "Gracie", "Brianna", "Natalie", "Olivia", "Elizabeth", "Samantha", "Stella", "Brenna", "Mary", "Alannah", "Jane", "Jennifer", "Alexa", "Rhea", "Sylvia", "Gypsy", "Rose", "Leah", "Gemma", "Jocasta", "Sarah", "Amalia", "Norma", "Lynn", "Karen", "Erin", "Mara", "Jessie"];
let fathers = ["Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan", "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Santiago", "Kevin", "Louis", "Samuel", "Anthony",  "Claude", "Niko", "Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan", "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Jack", "Ian", "Virgil", "Matthew", "Tony", "Edgar", "Teddy", "Robert", "Reed", "CJ", "Milton", "Nick", "Chris", "Ryan", "Wayne", "BM", "Greyson", "Waters", "Logan", "Xavier", "Ken", "Lincoln"];

let whitelisted = {
	// jackets:[19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,67,68,70,71,73,74,76,81,82,83,105,149,205],
    // undershirts:[16,17,19,20,22,24,25,26,28,29,33,34,35,36,39,40,42,57,58,102,115,116,166,173,174],
    // pants:[21,22,23,24,25,28,35],
    // decals:[1,2,3,4,5,6,58],
    // vest:[1,2,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23],
    // hats:[20,21,24,25,26,27,30,33,34,50,90,166],
};

//whitelisted["female"] = {
    // jackets:[17,18,19,20,21,22,23,24,25,26,27,28,29,30,67,68,102,157],
    // undershirts:[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,66,67,68,70,71,72,78,79,105,143,198],
    // pants:[18,19,20,21,22,23,24,39],
    // vest:[8,9,11,12,13,14,15,16,17,18,19,21,22],
    // hats:[20,21,23,24,25,26,28,29,31,37,39,75,77,153],
//}

$(document).on('click', '.clothing-menu-header-btn', function(e){
    var category = $(this).data('category');

    $(selectedTab).removeClass("selected");
    $(this).addClass("selected");
    $(".clothing-menu-"+lastCategory+"-container").css({"display": "none"});

    lastCategory = category;
    selectedTab = this;

    $(".clothing-menu-"+category+"-container").css({"display": "block"});
})

BJClothing.ResetItemTexture = function(obj, category) {
    var itemTexture = $(obj).parent().parent().find('[data-type="texture"]');
    var defaultTextureValue = clothingCategorys[category].defaultTexture;
    $(itemTexture).val(defaultTextureValue);

    $.post('http://clothing/updateSkin', JSON.stringify({
        clothingType: category,
        articleNumber: defaultTextureValue,
        type: "texture",
    }));
}

function getNextAvailableClothing(type, input, isUp) {
	var isNotValid = true;
	var selected = input;
	while (isNotValid) {
		if (whitelisted[type] && whitelisted[type].indexOf(selected) > -1) {
			isNotValid = true;
			selected = (isUp ? selected + 1 : selected - 1);
		} else {
			isNotValid = false;
		}
	}
	return selected;
}

let rightInterval = 0;

$(document).on('mousedown', '.clothing-menu-option-item-right', function(e) {
    let that = this;
    rightButton(e, that);
    rightInterval = setInterval(() => {
        rightButton(e, that);
    }, 200);
});

$(document).on('mouseup', '.clothing-menu-option-item-right', function(e) {
    clearInterval(rightInterval);
});

$(document).on('mouseleave', '.clothing-menu-option-item-right', function(e) {
    clearInterval(rightInterval);
});


function rightButton(e, that){
    e.preventDefault();

    var clothingCategory = $(that).parent().parent().data('type');
    var buttonType = $(that).data('type');
    var inputElem = $(that).parent().find('input');
    var inputVal = $(inputElem).val();
    var newValue = parseFloat(inputVal) + 1;
	
    if (buttonType == 'item') {
        newValue = getNextAvailableClothing(clothingCategory, newValue, true);
    }
    let max = $(inputElem).attr('max') || false;
    if (max != false && newValue > max) {
        newValue = max;
    }
	$(inputElem).val(newValue);

    if (canChange) {
        if (hasTracker && clothingCategory == "accessory") {
            $.post('http://clothing/TrackerError');
            return
        } else {
            if (clothingCategory == "model") {
                $(inputElem).val(newValue);
                $.post('http://clothing/setCurrentPed', JSON.stringify({ped: newValue}), function(model){
                    $("#current-model").html("<p>"+model+"</p>")
                });
                canChange = true;
                BJClothing.ResetValues()
            } else if (clothingCategory == "mom") {
                $(inputElem).val(newValue);
                if (buttonType == "item") {
                    var buttonMax = $(that).parent().find('[data-headertype="item-header"]').data('maxItem');
                    if (newValue <= parseInt(buttonMax)) {
                        $(inputElem).val(newValue);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: newValue,
                            type: buttonType,
                        }));
                        $("#current-mother").html("<p>"+mothers[newValue]+"</p>")
                    }
                }
            } else if (clothingCategory == "dad") {
                $(inputElem).val(newValue);
                if (buttonType == "item") {
                    var buttonMax = $(that).parent().find('[data-headertype="item-header"]').data('maxItem');
                    if (newValue <= parseInt(buttonMax)) {
                        $(inputElem).val(newValue);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: newValue,
                            type: buttonType,
                        }));
                        $("#current-father").html("<p>"+fathers[newValue]+"</p>")
                    }
                }
            } else if (clothingCategory == "hair") {
                $(inputElem).val(newValue);
                $.post('http://clothing/updateSkin', JSON.stringify({
                    clothingType: clothingCategory,
                    articleNumber: newValue,
                    type: buttonType,
                }));
                if (buttonType == "item") {
                    BJClothing.ResetItemTexture(that, clothingCategory);
                }
            } else {
                if (buttonType == "item") {
                    var buttonMax = $(that).parent().find('[data-headertype="item-header"]').data('maxItem');
                    if (clothingCategory == "accessory" && newValue == 13) {
                        $(inputElem).val(14);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: 14,
                            type: buttonType,
                        }));
                    } else {
                        if (newValue <= parseInt(buttonMax)) {
                            $(inputElem).val(newValue);
                            $.post('http://clothing/updateSkin', JSON.stringify({
                                clothingType: clothingCategory,
                                articleNumber: newValue,
                                type: buttonType,
                            }));
                        }
                    }
                    BJClothing.ResetItemTexture(that, clothingCategory);
                } else {
                    var buttonMax = $(that).parent().find('[data-headertype="texture-header"]').data('maxTexture');
                    if (newValue <= parseInt(buttonMax)) {
                        $(inputElem).val(newValue);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: newValue,
                            type: buttonType,
                        }));
                    }
                }
            }
        }
    }
}

let leftInterval = 0;

$(document).on('mousedown', '.clothing-menu-option-item-left', function(e) {
    let that = this;
    leftButton(e, that);
    leftInterval = setInterval(() => {
        leftButton(e, that);
    }, 200);
});

$(document).on('mouseup', '.clothing-menu-option-item-left', function(e) {
    clearInterval(leftInterval);
});

$(document).on('mouseleave', '.clothing-menu-option-item-left', function(e) {
    clearInterval(leftInterval);
});

function doSlide(elem) {
    var clothingCategory = $(elem).parent().parent().data('type');
    var buttonType = $(elem).data('type');
    var inputVal = elem.value;

    $.post('http://clothing/updateSkin', JSON.stringify({
        clothingType: clothingCategory,
        articleNumber: inputVal,
        type: buttonType,
    }));
}

function leftButton(e, that){
    e.preventDefault();

    var clothingCategory = $(that).parent().parent().data('type');
    var buttonType = $(that).data('type');
    var inputElem = $(that).parent().find('input');
    var inputVal = $(inputElem).val();
    var newValue = parseFloat(inputVal) - 1;
	
	newValue = getNextAvailableClothing(clothingCategory, newValue, false);
    let min = $(inputElem).attr('min') || false;
    if (min != false && newValue < min) {
        newValue = min;
    }
	$(inputElem).val(newValue);

    if (canChange) {
        if (hasTracker && clothingCategory == "accessory") {
            $.post('http://clothing/TrackerError');
            return
        } else {
            if (clothingCategory == "model") {
                if (newValue != 0) {
                    $(inputElem).val(newValue);
                    $.post('http://clothing/setCurrentPed', JSON.stringify({ped: newValue}), function(model){
                        $("#current-model").html("<p>"+model+"</p>")
                    });
                    canChange = true;
                    BJClothing.ResetValues();
                }
            } else if (clothingCategory == "mom") {
                $(inputElem).val(newValue);
                if (buttonType == "item") {
                    var buttonMax = $(that).parent().find('[data-headertype="item-header"]').data('maxItem');
                    if (newValue <= parseInt(buttonMax)) {
                        $(inputElem).val(newValue);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: newValue,
                            type: buttonType,
                        }));
                        $("#current-mother").html("<p>"+mothers[newValue]+"</p>")
                    }
                }
            } else if (clothingCategory == "dad") {
                $(inputElem).val(newValue);
                if (buttonType == "item") {
                    var buttonMax = $(that).parent().find('[data-headertype="item-header"]').data('maxItem');
                    if (newValue <= parseInt(buttonMax)) {
                        $(inputElem).val(newValue);
                        $.post('http://clothing/updateSkin', JSON.stringify({
                            clothingType: clothingCategory,
                            articleNumber: newValue,
                            type: buttonType,
                        }));
                        $("#current-father").html("<p>"+fathers[newValue]+"</p>")
                    }
                }
            } else {
                if (buttonType == "item") {
                    if (newValue >= clothingCategorys[clothingCategory].defaultItem) {
                        if (clothingCategory == "accessory" && newValue == 13) {
                            $(inputElem).val(12);
                            $.post('http://clothing/updateSkin', JSON.stringify({
                                clothingType: clothingCategory,
                                articleNumber: 12,
                                type: buttonType,
                            }));
                        } else {
                            $(inputElem).val(newValue);
                            $.post('http://clothing/updateSkin', JSON.stringify({
                                clothingType: clothingCategory,
                                articleNumber: newValue,
                                type: buttonType,
                            }));
                        }
                    }
                    BJClothing.ResetItemTexture(that, clothingCategory);
                } else {
                    if (newValue >= clothingCategorys[clothingCategory].defaultTexture) {
                        if (clothingCategory == "accessory" && newValue == 13) {
                            $(inputElem).val(12);
                            $.post('http://clothing/updateSkin', JSON.stringify({
                                clothingType: clothingCategory,
                                articleNumber: 12,
                                type: buttonType,
                            }));
                        } else {
                            $(inputElem).val(newValue);
                            $.post('http://clothing/updateSkin', JSON.stringify({
                                clothingType: clothingCategory,
                                articleNumber: newValue,
                                type: buttonType,
                            }));
                        }
                    }
                }
            }
        }
    }
}

var changingCat = null;

function ChangeUp() {
    var clothingCategory = $(changingCat).parent().parent().data('type');
    var buttonType = $(changingCat).data('type');
    var inputVal = parseFloat($(changingCat).val());

    if (clothingCategory == "accessory" && inputVal + 1 == 13) {
        $(changingCat).val(14 - 1)
    }
}

function ChangeDown() {
    var clothingCategory = $(changingCat).parent().parent().data('type');
    var buttonType = $(changingCat).data('type');
    var inputVal = parseFloat($(changingCat).val());


    if (clothingCategory == "accessory" && inputVal - 1 == 13) {
        $(changingCat).val(12 + 1)
    }
}

$(document).on('change', '.item-number', function(){
    var clothingCategory = $(this).parent().parent().data('type');
    var buttonType = $(this).data('type');
    var inputVal = $(this).val();

	inputVal = getNextAvailableClothing(clothingCategory, parseFloat(inputVal), true);
    let min = $(this).attr('min') || false;
    let max = $(this).attr('max') || false;
    if (min != false && inputVal < min) {
        inputVal = min;
    } else if (max != false && inputVal > max) {
        inputVal = max;
    }
	$(this).val(inputVal);

    changingCat = this;

    if (hasTracker && clothingCategory == "accessory") {
        $.post('http://clothing/TrackerError');
        $(this).val(13);
        return
    } else {
        if (clothingCategory == "accessory" && inputVal == 13) {
            $(this).val(12);
            return
        } else {
            $.post('http://clothing/updateSkinOnInput', JSON.stringify({
                clothingType: clothingCategory,
                articleNumber: parseFloat(inputVal),
                type: buttonType,
            }));
        }
    }
});

$(document).on('click', '.toggle-open-button', function() {
    $(this).parent().toggleClass('open');
    $(this).find('.fas').toggleClass('fa-angle-double-left').toggleClass('fa-angle-double-right');
});

$(document).on('click', '.toggle-button', function() {
    $.post('http://clothing/toggleFacewear', JSON.stringify({
        type: $(this).data('toggle')
    }));
});

$(document).on('click', '.clothing-menu-header-camera-btn', function(e){
    e.preventDefault();

    var camValue = parseFloat($(this).data('value'));

    if (selectedCam == null) {
        $(this).addClass("selected-cam");
        $.post('http://clothing/setupCam', JSON.stringify({
            value: camValue
        }));
        selectedCam = this;
    } else {
        if (selectedCam == this) {
            $(selectedCam).removeClass("selected-cam");
            $.post('http://clothing/setupCam', JSON.stringify({
                value: 0
            }));

            selectedCam = null;
        } else {
            $(selectedCam).removeClass("selected-cam");
            $(this).addClass("selected-cam");
            $.post('http://clothing/setupCam', JSON.stringify({
                value: camValue
            }));

            selectedCam = this;
        }
    }
});

$(document).on('keydown', function() {
    if (cameraKeybindsEnabled) {
        switch(event.keyCode) {
            case 68: // D
                $.post('http://clothing/rotateRight');
                break;
            case 65: // A
                $.post('http://clothing/rotateLeft');
                break;
            case 38: // UP
                ChangeUp();
                break;
            case 40: // DOWN
                ChangeDown();
                break;
        }
    }
});

BJClothing.ToggleChange = function(bool) {
    canChange = bool;
}

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                BJClothing.Open(event.data);
                break;
            case "close":
                BJClothing.Close();
                break;
            case "updateMax":
                BJClothing.SetMaxValues(event.data.maxValues);
                break;
            case "reloadMyOutfits":
                BJClothing.ReloadOutfits(event.data.outfits);
                break;
            case "toggleChange":
                BJClothing.ToggleChange(event.data.allow);
                break;
            case "ResetValues":
                BJClothing.ResetValues();
                break;
        }
    })
});

BJClothing.ReloadOutfits = function(outfits) {
    $(".clothing-menu-myOutfits-container").html("");
    $.each(outfits, function(index, outfit){
        var elem = '<div class="clothing-menu-option" data-myOutfit="'+(index + 1)+'"> <div class="clothing-menu-option-header"><p>'+outfit.outfitname+'</p></div><div class="clothing-menu-myOutfit-option-button"><p>Select</p></div><div class="clothing-menu-myOutfit-option-button-remove"><p>Delete</p></div></div>'
        $(".clothing-menu-myOutfits-container").append(elem)
        
        $("[data-myOutfit='"+(index + 1)+"']").data('myOutfitData', outfit)
    });
}

$(document).on('click', "#save-menu", function(e){
    e.preventDefault();
    BJClothing.Close();
    $.post('http://clothing/saveClothing');
});

$(document).on('click', "#cancel-menu", function(e){
    e.preventDefault();
    BJClothing.Close();
    $.post('http://clothing/resetOutfit');
});

let outfitIgnore = [
    'model', 'mom', 'dad', 'face', 'ageing', 'nose', 'nose_profile', 'nose_peak', 'cheekbones', 'cheeks', 'eyes', 'lips', 'jaw', 'chin', 'shape_chin', 'hair', 'hair2', 'eyebrows', 'beard', 'chest_hair', 'complexion', 'sun_damage', 'makeup', 'moles_freckles', 'lipstick', 'blush', 'appearance_opacity_1', 'appearance_opacity_2', 'appearance_opacity_3', 'appearance_opacity_4'
];

BJClothing.SetCurrentValues = function(clothingValues, settingOutfit) {
    if (typeof(clothingValues) === 'string') {
        try {
            clothingValues = JSON.parse(clothingValues);
        }
        catch(e) {
            return;
        }
    }
    $.each(clothingValues, function(i, item){
        var itemCats = $(".clothing-menu-container").find('[data-type="'+i+'"]');
        var input = $(itemCats).find('input[data-type="item"]');
        var texture = $(itemCats).find('input[data-type="texture"]');

        if (settingOutfit != true || outfitIgnore.indexOf(i) == -1) {
            $(input).val(item.item);
            $(texture).val(item.texture);
        }
    });
}

BJClothing.Open = function(data) {
    cameraKeybindsEnabled = true;
    clothingCategorys = data.currentClothing;

    if (data.hasTracker) {
        hasTracker = true;
    } else {
        hasTracker = false;
    }

    $(".change-camera-buttons").fadeIn(150);

    $(".clothing-menu-roomOutfits-container").css("display", "none");
    $(".clothing-menu-myOutfits-container").css("display", "none");
    $(".clothing-menu-character-container").css("display", "none");
    $(".clothing-menu-clothing-container").css("display", "none");
    $(".clothing-menu-extra-container").css("display", "none");
    $(".clothing-menu-accessories-container").css("display", "none");
    $(".clothing-menu-container").css({"display":"block"}).animate({right: 0,}, 200, () => {
        $(".clothing-menu-option-toggle").fadeIn(150);
    });
    BJClothing.SetMaxValues(data.maxValues);
    $(".clothing-menu-header").html("");
    BJClothing.SetCurrentValues(data.currentClothing);
	whitelisted = data.whitelisted || {};
    $(".clothing-menu-roomOutfits-container").html("");
    $(".clothing-menu-myOutfits-container").html("");
    if (data.allowModels) {
        $('.clothing-menu-option[data-type=model]').show();
    } else {
        $('.clothing-menu-option[data-type=model]').hide();
    }
    $.each(data.menus, function(i, menu){
        if (menu.selected) {
            $(".clothing-menu-header").append('<div class="clothing-menu-header-btn '+menu.menu+'Tab selected" data-category="'+menu.menu+'"><p>'+menu.label+'</p></div>')
            $(".clothing-menu-"+menu.menu+"-container").css({"display":"block"});
            selectedTab = "." + menu.menu + "Tab";
            lastCategory = menu.menu;

        } else {
            $(".clothing-menu-header").append('<div class="clothing-menu-header-btn '+menu.menu+'Tab" data-category="'+menu.menu+'"><p>'+menu.label+'</p></div>')
        }

        if (menu.menu == "roomOutfits") {
            $.each(menu.outfits, function(index, outfit){
                var elem = '<div class="clothing-menu-option" data-outfit="'+(index + 1)+'"> <div class="clothing-menu-option-header"><p>'+outfit.outfitLabel+'</p></div> <div class="clothing-menu-outfit-option-button"><p>Select Outfit</p></div> </div>'
                $(".clothing-menu-roomOutfits-container").append(elem)
                
                $("[data-outfit='"+(index + 1)+"']").data('outfitData', outfit)
            });
        }

        if (menu.menu == "myOutfits") {
            $.each(menu.outfits, function(index, outfit){
                var elem = '<div class="clothing-menu-option" data-myOutfit="'+(index + 1)+'"> <div class="clothing-menu-option-header"><p>'+outfit.outfitname+'</p></div><div class="clothing-menu-myOutfit-option-button"><p>Select</p></div><div class="clothing-menu-myOutfit-option-button-remove"><p>Delete</p></div></div>'
                $(".clothing-menu-myOutfits-container").append(elem)
                
                $("[data-myOutfit='"+(index + 1)+"']").data('myOutfitData', outfit)
            });
        }
    });

    var menuWidth = (100 / data.menus.length)

    $(".clothing-menu-header-btn").css("width", menuWidth + "%");
}

$(document).on('click', '.clothing-menu-outfit-option-button', function(e){
    e.preventDefault();

    var oData = $(this).parent().data('outfitData');

    BJClothing.SetCurrentValues(oData.outfitData, true);

    $.post('http://clothing/selectOutfit', JSON.stringify({
        outfitData: oData.outfitData,
        outfitName: oData.outfitLabel
    }))
});

$(document).on('click', '.clothing-menu-myOutfit-option-button', function(e){
    e.preventDefault();

    var outfitData = $(this).parent().data('myOutfitData');

    BJClothing.SetCurrentValues(outfitData.skin, true);

    $.post('http://clothing/selectOutfit', JSON.stringify({
        outfitData: outfitData.skin,
        outfitName: outfitData.outfitname,
        outfitId: outfitData.outfitId,
    }))
});

$(document).on('click', '.clothing-menu-myOutfit-option-button-remove', function(e){
    e.preventDefault();

    var outfitData = $(this).parent().data('myOutfitData');

    $.post('http://clothing/removeOutfit', JSON.stringify({
        outfitData: outfitData.skin,
        outfitName: outfitData.outfitname,
        outfitId: outfitData.outfitId,
    }));
});

BJClothing.Close = function() {
    $.post('http://clothing/close');
    $(".change-camera-buttons").fadeOut(150);
    $(".clothing-menu-roomOutfits-container").css("display", "none");
    $(".clothing-menu-myOutfits-container").css("display", "none");
    $(".clothing-menu-character-container").css("display", "none");
    $(".clothing-menu-clothing-container").css("display", "none");
    $(".clothing-menu-extra-container").css("display", "none");
    $(".clothing-menu-accessories-container").css("display", "none");
    $(".clothing-menu-option-toggle").css("display", "none").removeClass("open");
    $(".toggle-open-button i").addClass('fa-angle-double-left').removeClass('fa-angle-double-right');
    $(".clothing-menu-header").html("");

    $(selectedCam).removeClass('selected-cam');
    $(selectedTab).removeClass("selected");
    selectedCam = null;
    selectedTab = null;
    lastCategory = null;
	whitelisted = {};
    $(".clothing-menu-container").css({"display":"block"}).animate({right: "-25vw",}, 200, function(){
        $(".clothing-menu-container").css({"display":"none"});
    });
}

BJClothing.SetMaxValues = function(maxValues) {
    $.each(maxValues, function(i, cat){
        if (cat.type == "character") {
            var containers = $(".clothing-menu-character-container").find('[data-type="'+i+'"]');
            var itemMax = $(containers).find('[data-headertype="item-header"]');
            var headerMax = $(containers).find('[data-headertype="texture-header"]');
    
            $(itemMax).data('maxItem', maxValues[containers.data('type')].item)
            $(headerMax).data('maxTexture', maxValues[containers.data('type')].texture)
    
            $(itemMax).html("<p>Item: " + maxValues[containers.data('type')].item + "</p>")
            $(headerMax).html("<p>Texture: " + maxValues[containers.data('type')].texture + "</p>")
        } else if (cat.type == "clothing") {
            var containers = $(".clothing-menu-clothing-container").find('[data-type="'+i+'"]');
            var itemMax = $(containers).find('[data-headertype="item-header"]');
            var headerMax = $(containers).find('[data-headertype="texture-header"]');
    
            $(itemMax).data('maxItem', maxValues[containers.data('type')].item)
            $(headerMax).data('maxTexture', maxValues[containers.data('type')].texture)
    
            $(itemMax).html("<p>Item: " + maxValues[containers.data('type')].item + "</p>")
            $(headerMax).html("<p>Texture: " + maxValues[containers.data('type')].texture + "</p>")
        } else if (cat.type == "extra") {
            var containers = $(".clothing-menu-extra-container").find('[data-type="'+i+'"]');
            var itemMax = $(containers).find('[data-headertype="item-header"]');
            var headerMax = $(containers).find('[data-headertype="texture-header"]');
    
            $(itemMax).data('maxItem', maxValues[containers.data('type')].item)
            $(headerMax).data('maxTexture', maxValues[containers.data('type')].texture)
    
            $(itemMax).html("<p>Item: " + maxValues[containers.data('type')].item + "</p>")
            $(headerMax).html("<p>Texture: " + maxValues[containers.data('type')].texture + "</p>")
        } else if (cat.type == "accessories") {
            var containers = $(".clothing-menu-accessories-container").find('[data-type="'+i+'"]');
            var itemMax = $(containers).find('[data-headertype="item-header"]');
            var headerMax = $(containers).find('[data-headertype="texture-header"]');
    
            $(itemMax).data('maxItem', maxValues[containers.data('type')].item)
            $(headerMax).data('maxTexture', maxValues[containers.data('type')].texture)
    
            $(itemMax).html("<p>Item: " + maxValues[containers.data('type')].item + "</p>")
            $(headerMax).html("<p>Texture: " + maxValues[containers.data('type')].texture + "</p>")
        }
    })
}

BJClothing.ResetValues = function() {
    $.each(clothingCategorys, function(i, cat){
        var itemCats = $(".clothing-menu-container").find('[data-type="'+i+'"]');
        var input = $(itemCats).find('input[data-type="item"]');
        var texture = $(itemCats).find('input[data-type="texture"]');
        
        $(input).val(cat.defaultItem);
        $(texture).val(cat.defaultTexture);
    })
}

$(document).on('click', '#save-outfit', function(e){
    e.preventDefault();
    cameraKeybindsEnabled = false;
    $(".clothing-menu-container").css({"display":"block"}).animate({right: "-25vw",}, 200, function(){
        $(".clothing-menu-container").css({"display":"none"});
    });

    $(".clothing-menu-save-outfit-name").fadeIn(150);
});

$(document).on('click', '#save-outfit-save', function(e){
    e.preventDefault();
    cameraKeybindsEnabled = true;
    $(".clothing-menu-container").css({"display":"block"}).animate({right: 0,}, 200);
    $(".clothing-menu-save-outfit-name").fadeOut(150);

    $.post('http://clothing/saveOutfit', JSON.stringify({
        outfitName: $("#outfit-name").val()
    }));
});

$(document).on('click', '#cancel-outfit-save', function(e){
    e.preventDefault();
    cameraKeybindsEnabled = true;
    $(".clothing-menu-container").css({"display":"block"}).animate({right: 0,}, 200);
    $(".clothing-menu-save-outfit-name").fadeOut(150);
});

$(document).on('click', '.change-camera-button', function(e){
    e.preventDefault();
    var rotationType = $(this).data('rotation');

    $.post('http://clothing/rotateCam', JSON.stringify({
        type: rotationType
    }))
});

//BJClothing.Open({menus: [
//    {menu: "character", label: "Character", selected: true},
//    {menu: "clothing", label: "Clothing", selected: false},
//    {menu: "accessories", label: "Accesories", selected: false}
//]})

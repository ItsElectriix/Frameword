var SelectedCryptoTab = Config.DefaultCryptoPage;
var ActionTab = null;
$(".cryptotab-"+SelectedCryptoTab).css({"display":"block"});
$(".crypto-header-footer").find('[data-cryptotab="'+SelectedCryptoTab+'"]').addClass('crypto-header-footer-item-selected');

var CryptoData = [];
CryptoData.Portfolio = 0;
CryptoData.Worth = 1000;
CryptoData.WalletId = null;
CryptoData.History = [];

function SetupCryptoData(Crypto) {
    CryptoData.History = Crypto.History;
    CryptoData.Portfolio = (Crypto.Portfolio).toFixed(6);
    CryptoData.Worth = Crypto.Worth;
    CryptoData.WalletId = Crypto.WalletId;
    $(".crypto-action-page-wallet").html("Wallet: "+CryptoData.Portfolio+" BJCoin('s)");
    $(".crypto-walletid").html(CryptoData.WalletId);
    $(".cryptotab-course-list").html("");
    if (CryptoData.History.length > 0) {
        CryptoData.History = CryptoData.History.reverse();
        $.each(CryptoData.History, function(i, change){
            var PercentageChange = ((change.NewWorth - change.PreviousWorth) / change.PreviousWorth) * 100;
            var PercentageElement = '<span style="color: green;" class="crypto-percentage-change"><i style="color: green; transform: rotate(-45deg);" class="fas fa-arrow-right"></i> +('+Math.ceil(PercentageChange)+'%)</span>';
            if (PercentageChange < 0 ) {
                PercentageChange = (PercentageChange * -1);
                PercentageElement = '<span style="color: red;" class="crypto-percentage-change"><i style="color: red; transform: rotate(125deg);" class="fas fa-arrow-right"></i> -('+Math.ceil(PercentageChange)+'%)</span>';
            }
            var Element =   '<div class="cryptotab-course-block">' +
                                '<i class="fas fa-exchange-alt"></i>' +
                                '<span class="cryptotab-course-block-title">Course change</span>' +
                                '<span class="cryptotab-course-block-happening"><span style="font-size: 1.3vh;">$'+change.PreviousWorth+'</span> to <span style="font-size: 1.3vh;">$'+change.NewWorth+'</span>'+PercentageElement+'</span>' +
                            '</div>';
    
            $(".cryptotab-course-list").append(Element);                
        });
    }

    $(".crypto-portofolio").find('p').html(CryptoData.Portfolio);
    $(".crypto-course").find('p').html("$"+CryptoData.Worth);
    $(".crypto-volume").find('p').html("$"+Math.ceil(CryptoData.Portfolio * CryptoData.Worth));
}

function UpdateCryptoData(Crypto) {
    CryptoData.History = Crypto.History;
    CryptoData.Portfolio = (Crypto.Portfolio).toFixed(6);
    CryptoData.Worth = Crypto.Worth;
    CryptoData.WalletId = Crypto.WalletId;

    $(".crypto-action-page-wallet").html("Wallet: "+CryptoData.Portfolio+" BJCoin('s)");
    $(".crypto-walletid").html(CryptoData.WalletId);
    $(".cryptotab-course-list").html("");
    if (CryptoData.History.length > 0) {
        CryptoData.History = CryptoData.History.reverse();
        $.each(CryptoData.History, function(i, change){
            var PercentageChange = ((change.NewWorth - change.PreviousWorth) / change.PreviousWorth) * 100;
            var PercentageElement = '<span style="color: green;" class="crypto-percentage-change"><i style="color: green; transform: rotate(-45deg);" class="fas fa-arrow-right"></i> +('+Math.ceil(PercentageChange)+'%)</span>';
            if (PercentageChange < 0 ) {
                PercentageChange = (PercentageChange * -1);
                PercentageElement = '<span style="color: red;" class="crypto-percentage-change"><i style="color: red; transform: rotate(125deg);" class="fas fa-arrow-right"></i> -('+Math.ceil(PercentageChange)+'%)</span>';
            }
            var Element =   '<div class="cryptotab-course-block">' +
                                '<i class="fas fa-exchange-alt"></i>' +
                                '<span class="cryptotab-course-block-title">Course change</span>' +
                                '<span class="cryptotab-course-block-happening"><span style="font-size: 1.3vh;">$'+change.PreviousWorth+'</span> to <span style="font-size: 1.3vh;">$'+change.NewWorth+'</span>'+PercentageElement+'</span>' +
                            '</div>';
    
            $(".cryptotab-course-list").append(Element);                
        });
    }

    $(".crypto-portofolio").find('p').html(CryptoData.Portfolio);
    $(".crypto-course").find('p').html("$"+CryptoData.Worth);
    $(".crypto-volume").find('p').html("$"+Math.ceil(CryptoData.Portfolio * CryptoData.Worth));
}

function RefreshCryptoTransactions(data) {
    $(".cryptotab-transactions-list").html("");
    if (data.CryptoTransactions.length > 0) {
        data.CryptoTransactions = (data.CryptoTransactions).reverse();
        $.each(data.CryptoTransactions, function(i, transaction){
            var Title = "<span style='color: green;'>"+transaction.TransactionTitle+"</span>"
            if (transaction.TransactionTitle == "Withdrawn") {
                Title = "<span style='color: red;'>"+transaction.TransactionTitle+"</span>"
            }
            var Element = '<div class="cryptotab-transactions-block"> <i class="fas fa-exchange-alt"></i> <span class="cryptotab-transactions-block-title">'+Title+'</span> <span class="cryptotab-transactions-block-happening">'+transaction.TransactionMessage+'</span></div>';
            
            $(".cryptotab-transactions-list").append(Element);                
        });
    }
}

$(document).on('click', '.crypto-header-footer-item', function(e){
    e.preventDefault();

    var CurrentTab = $(".crypto-header-footer").find('[data-cryptotab="'+SelectedCryptoTab+'"]');
    var SelectedTab = this;
    var HeaderTab = $(SelectedTab).data('cryptotab');

    if (HeaderTab !== SelectedCryptoTab) {
        $(CurrentTab).removeClass('crypto-header-footer-item-selected');
        $(SelectedTab).addClass('crypto-header-footer-item-selected');
        $(".cryptotab-"+SelectedCryptoTab).css({"display":"none"});
        $(".cryptotab-"+HeaderTab).css({"display":"block"});
        SelectedCryptoTab = $(SelectedTab).data('cryptotab');
    }
});

$(document).on('click', '.cryptotab-general-action', function(e){
    e.preventDefault();

    var Tab = $(this).data('action');

    $(".crypto-action-page").css({"display":"block"});
    $(".crypto-action-page").animate({
        left: 0,
    }, 300);
    $(".crypto-action-page-"+Tab).css({"display":"block"});
    BJ.Phone.Functions.HeaderTextColor("black", 300);
    ActionTab = Tab;
});

$(document).on('click', '#cancel-crypto', function(e){
    e.preventDefault();

    $(".crypto-action-page").animate({
        left: -30+"vh",
    }, 300, function(){
        $(".crypto-action-page-"+ActionTab).css({"display":"none"});
        $(".crypto-action-page").css({"display":"none"});
        ActionTab = null;
    });
    BJ.Phone.Functions.HeaderTextColor("white", 300);
});

function CloseCryptoPage() {
    $(".crypto-action-page").animate({
        left: -30+"vh",
    }, 300, function(){
        $(".crypto-action-page-"+ActionTab).css({"display":"none"});
        $(".crypto-action-page").css({"display":"none"});
        ActionTab = null;
    });
    BJ.Phone.Functions.HeaderTextColor("white", 300);
}

$(document).on('click', '#buy-crypto', function(e){
    e.preventDefault();

    var Coins = $(".crypto-action-page-buy-crypto-input-coins").val();
    var Price = $(".crypto-action-page-buy-crypto-input-money").val();

    if ((Coins !== "") && (Coins > 0) && (Price !== "") && (Price > 0)) {
        if (BJ.Phone.Data.PlayerData.money.bank >= Price) {
            $.post('http://phone/BuyCrypto', JSON.stringify({
                Coins: Coins,
                Price: Price,
            }), function(CryptoData){
                if (CryptoData !== false) {
                    UpdateCryptoData(CryptoData)
                    CloseCryptoPage()
                    BJ.Phone.Data.PlayerData.money.bank = parseInt(BJ.Phone.Data.PlayerData.money.bank) - parseInt(Price);
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", BJ.Phone.Data.Currency+" "+Price+",- has been withdrawn from your balance", "#badc58", 2500);
                } else {
                    BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough money..", "#badc58", 1500);
                }
            });
        } else {
            BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough money..", "#badc58", 1500);
        }
    } else {
        BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "Fill out all fields!", "#badc58", 1500);
    }
});

$(document).on('click', '#sell-crypto', function(e){
    e.preventDefault();

    var Coins = $(".crypto-action-page-sell-crypto-input-coins").val();
    var Price = $(".crypto-action-page-sell-crypto-input-money").val();

    if ((Coins !== "") && (Coins > 0) && (Price !== "") && (Price > 0)) {
        if (CryptoData.Portfolio >= parseInt(Coins)) {
            $.post('http://phone/SellCrypto', JSON.stringify({
                Coins: Coins,
                Price: Price,
            }), function(CryptoData){
                if (CryptoData !== false) {
                    UpdateCryptoData(CryptoData)
                    CloseCryptoPage()
                    BJ.Phone.Data.PlayerData.money.bank = parseInt(BJ.Phone.Data.PlayerData.money.bank) + parseInt(Price);
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", BJ.Phone.Data.Currency+" "+Price+",- has been added to your balance", "#badc58", 2500);
                } else {
                    BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough BJCoins..", "#badc58", 1500);
                }
            });
        } else {
            BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough BJCoins..", "#badc58", 1500);
        }
    } else {
        BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "Fill out all fields!", "#badc58", 1500);
    }
});

$(document).on('click', '#transfer-crypto', function(e){
    e.preventDefault();

    var Coins = $(".crypto-action-page-transfer-crypto-input-coins").val();
    var WalletId = $(".crypto-action-page-transfer-crypto-input-walletid").val();

    if ((Coins !== "") && (WalletId !== "")) {
        if (CryptoData.Portfolio >= Coins) {
            if (WalletId !== CryptoData.WalletId) {
                $.post('http://phone/TransferCrypto', JSON.stringify({
                    Coins: Coins,
                    WalletId: WalletId,
                }), function(CryptoData){
                    if (CryptoData == "notenough") {
                        BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough BJCoins..", "#badc58", 1500);
                    } else if (CryptoData == "notvalid") {
                        BJ.Phone.Notifications.Add("fas fa-university", "Crypto", "this Wallet-ID doesn't exist!", "#badc58", 2500);
                    } else {
                        UpdateCryptoData(CryptoData)
                        CloseCryptoPage()
                        BJ.Phone.Notifications.Add("fas fa-university", "Crypto", "You transferred "+Coins+",- to "+WalletId+"!", "#badc58", 2500);
                    }
                });
            } else {
                BJ.Phone.Notifications.Add("fas fa-university", "Crypto", "You can't transfer to yourself..", "#badc58", 2500);
            }
        } else {
            BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "You don't have enough BJCoins..", "#badc58", 1500);
        }
    } else {
        BJ.Phone.Notifications.Add("fas fa-chart-pie", "Crypto", "Fill out all fields!!", "#badc58", 1500);
    }
});

$(".crypto-action-page-buy-crypto-input-money").keyup(function(){
    var MoneyInput = this.value

    $(".crypto-action-page-buy-crypto-input-coins").val((MoneyInput / CryptoData.Worth).toFixed(6));
}); 

$(".crypto-action-page-buy-crypto-input-coins").keyup(function(){
    var MoneyInput = this.value

    $(".crypto-action-page-buy-crypto-input-money").val(Math.ceil(CryptoData.Worth * MoneyInput));
});

$(".crypto-action-page-sell-crypto-input-money").keyup(function(){
    var MoneyInput = this.value

    $(".crypto-action-page-sell-crypto-input-coins").val((MoneyInput / CryptoData.Worth).toFixed(6));
}); 

$(".crypto-action-page-sell-crypto-input-coins").keyup(function(){
    var MoneyInput = this.value

    $(".crypto-action-page-sell-crypto-input-money").val(Math.ceil(CryptoData.Worth * MoneyInput));
});

BJ.Phone.Functions.LoadCryptoContactsWithNumber = function(myContacts) {
    var ContactsObject = $(".crypto-app-my-contacts-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $("#crypto-app-my-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".crypto-app-my-contacts-list .crypto-app-my-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var RandomNumber = Math.floor(Math.random() * 6);
            var ContactColor = BJ.Phone.ContactColors[RandomNumber];
            var ContactElement = '<div class="crypto-app-my-contact" data-cryptocontactid="'+i+'"> <div class="crypto-app-my-contact-firstletter">'+((contact.name).charAt(0)).toUpperCase()+'</div> <div class="crypto-app-my-contact-name">'+contact.name+'</div> </div>'
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-cryptocontactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '.crypto-app-my-contacts-list-back', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".crypto-app-my-contacts", 400, -100);
});

$(document).on('click', '.crypto-transfer-mycontacts-icon', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideDown(".crypto-app-my-contacts", 400, 0);
});

$(document).on('click', '.crypto-app-my-contact', function(e){
    e.preventDefault();
    var PressedContactData = $(this).data('contactData');

    if (PressedContactData.iban !== "" && PressedContactData.iban !== undefined && PressedContactData.iban !== null) {
        $(".crypto-action-page-transfer-crypto-input-walletid").val(PressedContactData.iban);
    } else {
        BJ.Phone.Notifications.Add("fas fa-university", "Crypto", "There is no bank account attached to this number", "#badc58", 2500);
    }
    BJ.Phone.Animations.TopSlideUp(".crypto-app-my-contacts", 400, -100);
});
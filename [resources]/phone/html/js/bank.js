var FoccusedBank = null;

$(document).on('click', '.bank-app-account', function(e){
    var copyText = document.getElementById("iban-account");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "Account number. copied", "#badc58", 1750);
});

var CurrentTab = "accounts";

$(document).on('click', '.bank-app-header-button', function(e){
    e.preventDefault();

    var PressedObject = this;
    var PressedTab = $(PressedObject).data('headertype');

    if (CurrentTab != PressedTab) {
        var PreviousObject = $(".bank-app-header").find('[data-headertype="'+CurrentTab+'"]');

        if (PressedTab == "invoices") {
            $(".bank-app-"+CurrentTab).animate({
                left: -30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        } else if (PressedTab == "accounts") {
            $(".bank-app-"+CurrentTab).animate({
                left: 30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        }

        $(PreviousObject).removeClass('bank-app-header-button-selected');
        $(PressedObject).addClass('bank-app-header-button-selected');
        setTimeout(function(){ CurrentTab = PressedTab; }, 300)
    }
})

BJ.Phone.Functions.DoBankOpen = function() {
    BJ.Phone.Data.PlayerData.money.bank = parseFloat(BJ.Phone.Data.PlayerData.money.bank).toFixed();
    $(".bank-app-account-number").val(BJ.Phone.Data.PlayerData.charinfo.account);
    $(".bank-app-account-balance").html(BJ.Phone.Data.Currency+" "+BJ.Phone.Data.PlayerData.money.bank);
    $(".bank-app-account-balance").data('balance', BJ.Phone.Data.PlayerData.money.bank);

    $(".bank-app-loaded").css({"display":"none", "padding-left":"30vh"});
    $(".bank-app-accounts").css({"left":"30vh"});
    $(".bank-logo").css({"left": "0vh"});
    $("#bank-text").css({"opacity":"0.0", "left":"9vh"});
    $(".bank-app-loading").css({
        "display":"block",
        "left":"0vh",
    });
    setTimeout(function(){
        CurrentTab = "accounts";
        $(".bank-logo").animate({
            left: -12+"vh"
        }, 500);
        setTimeout(function(){
            $("#bank-text").animate({
                opacity: 1.0,
                left: 14+"vh"
            });
        }, 100);
        setTimeout(function(){
            $(".bank-app-loaded").css({"display":"block"}).animate({"padding-left":"0"}, 300);
            $(".bank-app-accounts").animate({left:0+"vh"}, 300);
            $(".bank-app-loading").animate({
                left: -30+"vh"
            },300, function(){
                $(".bank-app-loading").css({"display":"none"});
            });
        }, 1500)
    }, 500)
}

$(document).on('click', '.bank-app-account-actions', function(e){
    BJ.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
});

$(document).on('click', '#cancel-transfer', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
});

$(document).on('click', '#accept-transfer', function(e){
    e.preventDefault();

    var iban = $("#bank-transfer-iban").val();
    var amount = $("#bank-transfer-amount").val();
    var amountData = $(".bank-app-account-balance").data('balance');

    if (iban != "" && amount != "") {
            $.post('http://phone/CanTransferMoney', JSON.stringify({
                sendTo: iban,
                amountOf: amount,
            }), function(data){
                if (data.TransferedMoney) {
                    $("#bank-transfer-iban").val("");
                    $("#bank-transfer-amount").val("");

                    $(".bank-app-account-balance").html(BJ.Phone.Data.Currency+" " + (data.NewBalance).toFixed(0));
                    $(".bank-app-account-balance").data('balance', (data.NewBalance).toFixed(0));
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You have transfered "+BJ.Phone.Data.Currency+" "+amount+"", "#badc58", 1500);
                } else {
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You don't have enough balance", "#badc58", 1500);
                }
                BJ.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
            });
    } else {
        BJ.Phone.Notifications.Add("fas fa-university", "Bank", "Fill out all fields", "#badc58", 1750);
    }
});

GetInvoiceLabel = function(inv) {
    retval = null;
    if (inv.title && inv.title.length > 0) {
        retval = inv.title;
    } else if (inv.job && inv.job.length > 0) {
        if (inv.jobLabel && inv.jobLabel.length > 0) {
            retval = `Payment Request (${inv.jobLabel})`;
        }
        else {
            retval = `Payment Request (${inv.job})`;
        }
    } else if (inv.sender) {
        retval = `Payment Request (${inv.sender})`;
    }
    return retval
}

$(document).on('click', '.pay-invoice', function(event){
    event.preventDefault();

    var InvoiceId = $(this).parent().parent().attr('id');
    var InvoiceData = $("#"+InvoiceId).data('invoicedata');
    var BankBalance = $(".bank-app-account-balance").data('balance');

    if (BankBalance >= InvoiceData.amount) {
        $.post('http://phone/PayInvoice', JSON.stringify({
            sender: InvoiceData.sender,
            job: InvoiceData.job,
            amount: InvoiceData.amount,
            invoiceId: InvoiceData.id,
        }), function(CanPay){
            if (CanPay) {
                $("#"+InvoiceId).animate({
                    left: 30+"vh",
                }, 300, function(){
                    setTimeout(function(){
                        $("#"+InvoiceId).remove();
                    }, 100);
                });
                BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You have paid "+BJ.Phone.Data.Currency+InvoiceData.amount+"", "#badc58", 1500);
                var amountData = $(".bank-app-account-balance").data('balance');
                var NewAmount = (amountData - InvoiceData.amount).toFixed();
                $("#bank-transfer-amount").val(NewAmount);
                $(".bank-app-account-balance").data('balance', NewAmount);
            } else {
                BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You don't have enough balance", "#badc58", 1500);
            }
        });
    } else {
        BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You don't have enough balance", "#badc58", 1500);
    }
});

$(document).on('click', '.decline-invoice', function(event){
    event.preventDefault();
    var InvoiceId = $(this).parent().parent().attr('id');
    var InvoiceData = $("#"+InvoiceId).data('invoicedata');

    $.post('http://phone/DeclineInvoice', JSON.stringify({
        sender: InvoiceData.sender,
        job: InvoiceData.job,
        title: InvoiceData.title,
        amount: InvoiceData.amount,
        invoiceId: InvoiceData.id,
    }));
    $("#"+InvoiceId).animate({
        left: 30+"vh",
    }, 300, function(){
        setTimeout(function(){
            $("#"+InvoiceId).remove();
        }, 100);
    });
    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "You have declined the invoice", "#badc58", 1500);
});

BJ.Phone.Functions.LoadBankInvoices = function(invoices) {
    if (invoices !== null) {
        $(".bank-app-invoices-list").html("");

        $.each(invoices, function(i, invoice){
            var Elem = '<div class="bank-app-invoice" id="invoiceid-'+i+'"> <div class="bank-app-invoice-title">'+BJ.Phone.Functions.StripAngledBrackets(GetInvoiceLabel(invoice))+' <br /><span style="font-size: 1vh; color: gray;">Sender: '+(invoice.number == invoice.contactName && invoice.name ? invoice.name : invoice.contactName)+` (${invoice.jobLabel})`+'</span></div> <div class="bank-app-invoice-amount">'+BJ.Phone.Data.Currency+' '+invoice.amount+'</div> <div class="bank-app-invoice-buttons"> <i class="fas fa-check-circle pay-invoice"></i> <i class="fas fa-times-circle decline-invoice"></i> </div> </div>';

            $(".bank-app-invoices-list").append(Elem);
            $("#invoiceid-"+i).data('invoicedata', invoice);
        });
    }
}

BJ.Phone.Functions.LoadBankContactsWithNumber = function(myContacts) {
    var ContactsObject = $(".bank-app-my-contacts-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $("#bank-app-my-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".bank-app-my-contacts-list .bank-app-my-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var RandomNumber = Math.floor(Math.random() * 6);
            var ContactColor = BJ.Phone.ContactColors[RandomNumber];
            var ContactElement = '<div class="bank-app-my-contact" data-bankcontactid="'+i+'"> <div class="bank-app-my-contact-firstletter">'+((contact.name).charAt(0)).toUpperCase()+'</div> <div class="bank-app-my-contact-name">'+contact.name+'</div> </div>'
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-bankcontactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '.bank-app-my-contacts-list-back', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});

let currentContactTarget = '';

$(document).on('click', '.bank-transfer-mycontacts-icon', function(e){
    e.preventDefault();
    currentContactTarget = '#bank-transfer-iban';
    BJ.Phone.Animations.TopSlideDown(".bank-app-my-contacts", 400, 0);
});

$(document).on('click', '.bank-new-invoice-mycontacts-icon', function(e){
    e.preventDefault();
    currentContactTarget = '#bank-new-invoice-iban';
    BJ.Phone.Animations.TopSlideDown(".bank-app-my-contacts", 400, 0);
});

$(document).on('click', '.bank-app-my-contact', function(e){
    e.preventDefault();
    var PressedContactData = $(this).data('contactData');

    if (PressedContactData.iban !== "" && PressedContactData.iban !== undefined && PressedContactData.iban !== null) {
        $(currentContactTarget).val(PressedContactData.iban);
    } else {
        BJ.Phone.Notifications.Add("fas fa-university", "Bank", "There is no bank account attached to this number", "#badc58", 2500);
    }
    BJ.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});

$(document).on('click', '.new-inv-button', function(e){
    e.preventDefault();

    $(".bank-app-loaded").animate({
        left: 30+"vh"
    });
    $(".new-invoice").animate({
        left: 0+"vh"
    });

    if (BJ.Phone.Data.JobHasSafe) {
        $('.bank-type-container[data-type=job]').show();
        let job = BJ.Phone.Data.PlayerJob.name.charAt(0).toUpperCase() + BJ.Phone.Data.PlayerJob.name.slice(1);
        $('.bank-type-container[data-type=job] label').text('Job ('+job+')');
        $('#bank-new-invoice-job').prop("checked", true);
    }
    else {
        $('.bank-type-container[data-type=job]').hide();
        $('#bank-new-invoice-personal').prop("checked", true);
    }
});

$(document).on('click', '.new-inv-button', function(e){
    BJ.Phone.Animations.TopSlideDown(".bank-app-new-invoice", 400, 0);
});

$(document).on('click', '#cancel-new-invoice', function(e){
    e.preventDefault();

    BJ.Phone.Animations.TopSlideUp(".bank-app-new-invoice", 400, -100);
});

$(document).on('click', '#accept-new-invoice', function(e){
    e.preventDefault();

    var job = $('#bank-new-invoice-job').prop('checked') == true ? BJ.Phone.Data.PlayerJob.name : null;
    var title = $("#bank-new-invoice-title").val();
    var iban = $("#bank-new-invoice-iban").val();
    var amount = $("#bank-new-invoice-amount").val();
    var amountData = $(".bank-app-account-balance").data('balance');

    if (iban != "" && amount != "") {
            $.post('http://phone/SendInvoice', JSON.stringify({
                title: title != "" ? title : null,
                job: job != "" ? job : null,
                recipient: iban,
                amount: amount,
            }), function(data) {
                if (typeof(data) === 'string') {
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", data, "#badc58", 1500);
                } else if (data === true) {
                    $("#bank-new-invoice-title").val("");
                    $("#bank-new-invoice-iban").val("");
                    $("#bank-new-invoice-amount").val("");

                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "Invoice sent", "#badc58", 1500);
                    BJ.Phone.Animations.TopSlideUp(".bank-app-new-invoice", 400, -100);
                } else {
                    BJ.Phone.Notifications.Add("fas fa-university", "Bank", "Could not send invoice", "#badc58", 1500);
                }
            });
    } else {
        BJ.Phone.Notifications.Add("fas fa-university", "Bank", "Fill out all fields", "#badc58", 1750);
    }
});
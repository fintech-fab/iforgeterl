function signup(form) {
    form.onsubmit = function () {
        return false;
    };

    $.post("/api/user",
        {
            username: form['email'].value,
            password: form['password'].value
        },
        function (data) {
            form.onsubmit = function () {
                return signup(form);
            };

            if (data.uuid != undefined) {
                window.location = '/';
            }
        }
    );
    return false;
}

function send_notice() {
    var dp = $('#datepicker').data('datepicker');
    var tp = $('#timepicker').data('timepicker');

    var time;

    if (dp.getFormattedDate() == ''){
        var dt = new Date();
        dt.setMinutes(0);
        dt.setHours(0);
        dt.setSeconds(0);
        time = dt.getTime();
    } else {
        time = dp.getDate().getTime();
    }

    time = time + (tp.hour  * 3600 + tp.minute * 60) * 1000;

    $.post("/api/notice/",
        {
            notice: $('#notice').val(),
            group: $('#receiver').val(),
            datetime: Math.ceil(time/1000)
        },
        function (data) {
            if (data.uuid != undefined) {
                alert("Напоминалка поставлена");
            }
        }
    );
}

$(function(){
    $.post("/user/sess", function(data){
        if (data.uuid == undefined || data.uuid == false){
            $(".nav > .guest").show();
            return;
        }
        $(".nav > .guest").hide();
        $(".nav > .profile").show();
    });
});

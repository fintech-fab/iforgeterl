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
    $.post("/api/notice/",
        {
            notice: $('#notice').val(),
            group: $('#reciever').val(),
            datetime: $('#datepick').val()
        },
        function (data) {
            window.location = '/';
        }
    );
}
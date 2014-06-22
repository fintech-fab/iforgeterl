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
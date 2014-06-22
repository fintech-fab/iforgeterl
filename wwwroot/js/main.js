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
            console.log(data);

            if (data.ui)
                form.onsubmit = function () {
                    return signup(form);
                };
        }
    );
    return false;
}
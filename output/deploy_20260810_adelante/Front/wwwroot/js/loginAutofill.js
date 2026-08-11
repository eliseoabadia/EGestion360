window.egestionLogin = (function () {
    function readInputValue(inputId) {
        var input = document.getElementById(inputId);
        if (!input || typeof input.value !== "string") {
            return "";
        }

        return input.value;
    }

    function getCredentials(userInputId, passwordInputId) {
        return {
            Usuario: readInputValue(userInputId),
            Password: readInputValue(passwordInputId)
        };
    }

    return {
        getCredentials: getCredentials
    };
})();

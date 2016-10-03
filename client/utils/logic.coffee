exports.emailIsValid = (email) -> /^.+@.+\..+$/.test email
exports.passwordIsValid = (password) -> password.length >= 6
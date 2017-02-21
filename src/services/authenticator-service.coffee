class AuthenticatorService
  authenticate: ({ }, callback) =>
    callback()

  _createError: (message='Internal Server Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = AuthenticatorService

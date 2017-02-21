debug = require('debug')('meshblu-authenticator-saml:authenticator-service')

class AuthenticatorService
  authenticate: (request, profile, callback) ->
    debug 'got profile', profile
    unless profile?
      return callback @_createError 'Invalid profile response', 406
    { email, firstName, lastName } = profile
    callback null, { email, firstName, lastName }

  _createError: (message='Internal Server Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = AuthenticatorService

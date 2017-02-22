_                       = require 'lodash'
MeshbluHttp             = require 'meshblu-http'
{ DeviceAuthenticator } = require 'meshblu-authenticator-core'
debug                   = require('debug')('meshblu-authenticator-saml:authenticator-service')

DEFAULT_PASSWORD = 'no-need-for-this'

class AuthenticatorService
  constructor: ({ meshbluConfig, privateKey, @namespace }) ->
    throw new Error 'AuthenticatorService: requires namespace' unless @namespace?
    throw new Error 'AuthenticatorService: requires meshbluConfig' unless meshbluConfig?
    throw new Error 'AuthenticatorService: requires privateKey' unless privateKey?
    @authenticatorName = 'Meshblu Authenticator Name'
    @authenticatorUuid = meshbluConfig.uuid
    throw new Error 'AuthenticatorService: requires an authenticator uuid' unless @authenticatorUuid?
    @meshbluHttp = new MeshbluHttp meshbluConfig
    @meshbluHttp.setPrivateKey privateKey
    @deviceModel = new DeviceAuthenticator {
      @authenticatorUuid
      @authenticatorName
      @meshbluHttp
    }

  authenticate: (request, profile, callback) =>
    debug 'got profile', profile
    unless profile?
      return callback @_createError 'Invalid profile response', 406
    { email, firstName, lastName } = profile
    @ensureUser { email, firstName, lastName }, (error, creds) =>
      return callback error if error?
      { uuid, token } = creds
      callback null, { email, firstName, lastName, uuid, token }

  ensureUser: ({ email, firstName, lastName }, callback) =>
    @_validateRequest { email, firstName, lastName }, (error) =>
      return callback error if error?
      @_maybeCreateDevice { email, firstName, lastName }, (error, device) =>
        return callback error if error?
        @_generateToken { device }, callback

  _createError: (message='Internal Server Error', code=500) =>
    error = new Error message
    error.code = code
    return error

  _createSearchId: ({ email }) =>
    email = @_lowerCase email
    return "#{@authenticatorUuid}:#{@namespace}:#{email}"

  _createUserDevice: ({ email, firstName, lastName }, callback) =>
    debug 'create device', { email }
    email = @_lowerCase email
    searchId = @_createSearchId { email }
    query = {}
    query['meshblu.search.terms'] = { $in: [searchId] }
    @deviceModel.create {
      query: query
      data:
        user:
          metadata: { firstName, lastName, email }
        email: email
        name: "#{firstName} #{lastName}"
      user_id: email
      secret: DEFAULT_PASSWORD
    }, (error, device) =>
      return callback error if error?
      @_updateSearchTerms { device, searchId }, (error) =>
        return callback error if error?
        callback null, device

  _findUserDevice: ({ email }, callback) =>
    searchId = @_createSearchId { email }
    query = {}
    query['meshblu.search.terms'] = { $in: [searchId] }
    @deviceModel.findVerified { query, password: DEFAULT_PASSWORD }, callback

  _generateToken: ({ device }, callback) =>
    debug 'generate token', device.uuid
    @meshbluHttp.generateAndStoreToken device.uuid, callback

  _lowerCase: (email='') =>
    return email.toLowerCase()

  _maybeCreateDevice: ({ email, firstName, lastName }, callback) =>
    debug 'maybe create device', { email }
    @_findUserDevice { email }, (error, device) =>
      return callback error if error?
      return callback null, device if device?
      @_createUserDevice { email, firstName, lastName }, callback

  _validateRequest: ({ email, firstName, lastName }, callback) =>
    return callback @_createError 'Last Name required', 422 if _.isEmpty lastName
    return callback @_createError 'First Name required', 422 if _.isEmpty firstName
    return callback @_createError 'Email required', 422 if _.isEmpty email
    callback null

  _updateSearchTerms: ({ device, searchId }, callback) =>
    query =
      $addToSet:
        'meshblu.search.terms': searchId
    @meshbluHttp.updateDangerously device.uuid, query, callback

module.exports = AuthenticatorService

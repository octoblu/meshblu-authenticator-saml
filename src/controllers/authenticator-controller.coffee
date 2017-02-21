url   = require 'url'
debug = require('debug')('meshblu-authenticator-saml:authenticator-controller')

class AuthenticatorController
  constructor: ({ @authenticatorService }) ->
    throw new Error 'Missing authenticatorService' unless @authenticatorService?

  initialize: (request, response, next) =>
    { callbackUrl } = request.query
    request.session.callbackUrl = callbackUrl if callbackUrl?
    return next() if callbackUrl?
    request.session.destroy next

  finish: (request, response) =>
    { callbackUrl } = request.session
    { user } = request
    { uuid, token } = user
    debug 'sucessful', callbackUrl, user
    request.session.destroy (error) =>
      return response.sendError error if error?
      return response.send user unless callbackUrl?
      response.redirect @_rebuildUrl { callbackUrl, uuid, token }

  _rebuildUrl: ({ callbackUrl, uuid, token }) =>
    uriParams = url.parse callbackUrl, true
    delete uriParams.search
    uriParams.query ?= {}
    uriParams.query.uuid = uuid
    uriParams.query.token = token
    return url.format uriParams

module.exports = AuthenticatorController

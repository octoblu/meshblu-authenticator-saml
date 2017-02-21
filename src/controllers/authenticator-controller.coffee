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
    debug 'sucessful', callbackUrl, request.user
    return response.send(request.user) unless callbackUrl?
    delete request.session.callbackUrl
    uriParams = url.parse callbackUrl, true
    delete uriParams.search
    uriParams.query ?= {}
    uriParams.query.uuid = 'hello-uuid'
    uriParams.query.token = 'hello-token'
    rebuiltUrl = url.format(uriParams)
    return response.redirect rebuiltUrl

module.exports = AuthenticatorController

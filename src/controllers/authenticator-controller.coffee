url   = require 'url'
debug = require('debug')('meshblu-authenticator-saml:authenticator-controller')

class AuthenticatorController
  constructor: ({ @authenticatorService }) ->
    throw new Error 'Missing authenticatorService' unless @authenticatorService?

  initialize: (request, response, next) =>
    { callbackUrl } = request.query
    response.cookie 'callbackUrl', callbackUrl, { maxAge: 60 * 60 * 1000 }
    next()

  finish: (request, response) =>
    { callbackUrl } = request.cookies
    { user } = request
    { uuid, token } = user
    debug 'sucessful', callbackUrl, user
    response.cookie 'callbackUrl', null, maxAge: -1
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

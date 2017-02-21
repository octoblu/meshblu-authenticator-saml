{ Strategy } = require 'passport-saml'
debug        = require('debug')('meshblu-authenticator-saml:saml-strategy')

class SamlStrategy
  constructor: (env) ->
    { @SAML_LOGIN_URL, @SAML_LOGOUT_URL, @SAML_ISSUER, @SAML_CERT } = env
    throw new Error 'SamlStrategy: requires SAML_LOGIN_URL' unless @SAML_LOGIN_URL?
    throw new Error 'SamlStrategy: requires SAML_LOGOUT_URL' unless @SAML_LOGOUT_URL?
    throw new Error 'SamlStrategy: requires SAML_ISSUER' unless @SAML_ISSUER?
    throw new Error 'SamlStrategy: requires SAML_CERT' unless @SAML_CERT?
    debug {
      @SAML_LOGIN_URL
      @SAML_LOGOUT_URL
      @SAML_ISSUER
    }

  get: (callback) =>
    return new Strategy({
      path: '/authenticate/callback'
      entryPoint: @SAML_LOGIN_URL
      logoutUrl: @SAML_LOGOUT_URL
      issuer: @SAML_ISSUER
      cert: @SAML_CERT
      passReqToCallback: true
    }, callback)

module.exports = SamlStrategy

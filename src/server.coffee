enableDestroy           = require 'server-destroy'
octobluExpress          = require 'express-octoblu'
session                 = require 'express-session'
passport                = require 'passport'
Router                  = require './router'
AuthenticatorService    = require './services/authenticator-service'
AuthenticatorController = require './controllers/authenticator-controller'
SamlStrategy            = require './strategies/saml-strategy'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig, @env } = options
    throw new Error 'Missing meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing env' unless @env?

  address: =>
    @server.address()

  destroy: =>
    @server.destroy()

  run: (callback) =>
    app = octobluExpress { @logFn, @disableLogging }

    app.use session @_sessionOptions()

    authenticatorService = new AuthenticatorService
    passport.serializeUser   (user, done) => done null, user
    passport.deserializeUser (user, done) => done null, user
    passport.use new SamlStrategy(@env).get(authenticatorService.authenticate)

    app.use passport.initialize()
    app.use passport.session()

    authenticatorController = new AuthenticatorController { authenticatorService }
    router = new Router { authenticatorController }

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  _sessionOptions: =>
    return {
      secret: 'some-secret-that-does-not-really-matter'
      resave: false
      saveUninitialized: true
      cookie:
        secure: process.env.NODE_ENV == 'production'
        maxAge: 60 * 60 * 1000
    }


module.exports = Server

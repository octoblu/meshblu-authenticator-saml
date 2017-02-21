enableDestroy        = require 'server-destroy'
octobluExpress       = require 'express-octoblu'
Router               = require './router'
AuthenticatorService = require './services/authenticator-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig } = options
    throw new Error 'Missing meshbluConfig' unless @meshbluConfig?

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress { @logFn, @disableLogging }

    authenticatorService = new AuthenticatorService
    router = new Router {  @meshbluConfig, authenticatorService }

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server

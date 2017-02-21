AuthenticatorController = require './controllers/authenticator-controller'

class Router
  constructor: ({ @authenticatorService }) ->
    throw new Error 'Missing authenticatorService' unless @authenticatorService?

  route: (app) =>
    authenticatorController = new AuthenticatorController { @authenticatorService }

    app.get '/authenticate', authenticatorController.authenticate

module.exports = Router

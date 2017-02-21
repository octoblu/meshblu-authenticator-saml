passport = require 'passport'

class Router
  constructor: ({ @authenticatorController }) ->
    throw new Error 'Router: requires authenticatorController' unless @authenticatorController?

  route: (app) =>
    app.get '/authenticate', @authenticatorController.initialize, passport.authenticate('saml')
    app.post '/authenticate/callback', passport.authenticate('saml', { failureRedirect: '/' }), @authenticatorController.finish

module.exports = Router

class AuthenticatorController
  constructor: ({ @authenticatorService }) ->
    throw new Error 'Missing authenticatorService' unless @authenticatorService?

  authenticate: (request, response) =>
    @authenticatorService.authenticate { }, (error) =>
      return response.sendError error if error?
      response.sendStatus 200

module.exports = AuthenticatorController

_              = require 'lodash'
envalid        = require 'envalid'
MeshbluConfig  = require 'meshblu-config'
SigtermHandler = require 'sigterm-handler'
Server         = require './src/server'

base64 = envalid.makeValidator (value) =>
  return throw new Error 'Expected a string' unless _.isString value
  return new Buffer(value, 'base64').toString('utf8')

envConfig = {
  PORT: envalid.num({ default: 80, devDefault: 5656 })
  SAML_LOGIN_URL: envalid.url { desc: 'Login URL for IdP' }
  SAML_LOGOUT_URL: envalid.url { desc: 'Logout URL for IdP' }
  SAML_ISSUER: envalid.str { desc: 'SAML IdP issuer name' }
  SAML_CERT: base64 { desc: 'Base64 encoded certificate for IdP' }
}

class Command
  constructor: ->
    env = envalid.cleanEnv process.env, envConfig
    @serverOptions = {
      meshbluConfig : new MeshbluConfig().toJSON()
      port          : env.PORT
      env           : env
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      {port} = server.address()
      console.log "AuthenticatorService listening on port: #{port}"

    sigtermHandler = new SigtermHandler()
    sigtermHandler.register server.stop


command = new Command()
command.run()

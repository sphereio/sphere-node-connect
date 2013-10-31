querystring = require('querystring')
request = require('request')
_ = require("underscore")._

exports.OAuth2 = (opts = {})->
  throw new Error("Missing 'client_id'") unless opts.client_id
  throw new Error("Missing 'client_secret'") unless opts.client_secret
  throw new Error("Missing 'project_key'") unless opts.project_key

  @_options =
    config:
      client_id: opts.client_id
      client_secret: opts.client_secret
      project_key: opts.project_key
    host: opts.host or "auth.sphere.io"
    accessTokenUrl: opts.accessTokenUrl or "/oauth/token"
  @

exports.OAuth2.prototype.getAccessToken = (callback)->
  params =
    grant_type: "client_credentials"
    scope: "manage_project:#{@_options.config.project_key}"

  payload = querystring.stringify(params)
  request_options =
    uri: "https://#{@_options.config.client_id}:#{@_options.config.client_secret}@#{@_options.host}#{@_options.accessTokenUrl}"
    method: "POST"
    body: payload
    headers:
      "Content-Type": "application/x-www-form-urlencoded"
      "Content-Length": payload.length
    timeout: 20000

  request request_options, (error, response, body)->
    callback(error, response, body)

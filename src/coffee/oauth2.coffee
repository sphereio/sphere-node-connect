_ = require("underscore")._
querystring = require('querystring')
request = require('request')

exports.OAuth2 = (opts = {})->
  config = opts.config
  throw new Error("Missing credentials") unless config
  throw new Error("Missing 'client_id'") unless config.client_id
  throw new Error("Missing 'client_secret'") unless config.client_secret
  throw new Error("Missing 'project_key'") unless config.project_key

  rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
  @_options =
    config: config
    host: opts.host or "auth.sphere.io"
    accessTokenUrl: opts.accessTokenUrl or "/oauth/token"
    timeout: opts.timeout or 20000
    rejectUnauthorized: rejectUnauthorized
  return

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
    timeout: @_options.timeout
    rejectUnauthorized: @_options.rejectUnauthorized

  request request_options, callback

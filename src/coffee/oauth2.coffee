querystring = require('querystring')
request = require('request')
_ = require("underscore")._

exports.OAuth2 = (options = {})->
  throw new Error("Missing 'client_id'") unless options.client_id
  throw new Error("Missing 'client_secret'") unless options.client_secret
  throw new Error("Missing 'project_key'") unless options.project_key

  @_options = _.defaults options,
    host: "auth.sphere.io"
    accessTokenUrl: "/oauth/token"
  @

exports.OAuth2.prototype.getAccessToken = (callback)->
  params =
    grant_type: "client_credentials"
    scope: "manage_project:#{@_options.project_key}"

  payload = querystring.stringify(params)
  request_options =
    uri: "https://#{@_options.client_id}:#{@_options.client_secret}@#{@_options.host}#{@_options.accessTokenUrl}"
    method: "POST"
    body: payload
    headers:
      "Content-Type": "application/x-www-form-urlencoded"
      "Content-Length": payload.length
    timeout: 20000

  request request_options, (error, response, body)->
    if response.statusCode is 200
      json_body = JSON.parse(body)
      callback(json_body)
    else
      throw new Error("Failed to get Access Token.")

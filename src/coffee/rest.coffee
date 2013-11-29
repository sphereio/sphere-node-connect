_ = require("underscore")._
request = require("request")
OAuth2 = require("./oauth2").OAuth2

exports.Rest = (opts = {})->
  config = opts.config
  throw new Error("Missing credentials") unless config
  throw new Error("Missing 'client_id'") unless config.client_id
  throw new Error("Missing 'client_secret'") unless config.client_secret
  throw new Error("Missing 'project_key'") unless config.project_key

  rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
  @_options =
    config: config
    host: opts.host or "api.sphere.io"
    access_token: opts.access_token or undefined
    timeout: opts.timeout or 20000
    rejectUnauthorized: rejectUnauthorized
  @_options.uri = "https://#{@_options.host}/#{@_options.config.project_key}"

  oauth_options = _.clone(opts)
  _.extend oauth_options,
    host: opts.oauth_host
  @_oauth = new OAuth2 oauth_options

  if @_options.access_token
    _.extend @_options,
      headers:
        "Authorization": "Bearer #{@_options.access_token}"
  return

exports.Rest.prototype.GET = (resource, callback)->
  params =
    resource: resource
    method: "GET"
  exports.preRequest(@_oauth, @_options, params, callback)

exports.Rest.prototype.POST = (resource, payload, callback)->
  params =
    resource: resource
    method: "POST"
    body: payload
  exports.preRequest(@_oauth, @_options, params, callback)

exports.Rest.prototype.DELETE = (resource, callback)->
  params =
    resource: resource
    method: "DELETE"
  exports.preRequest(@_oauth, @_options, params, callback)

exports.Rest.prototype.PUT = -> #noop

exports.preRequest = (oa, options, params, callback)->
  _req = (retry)->
    unless options.access_token
      oa.getAccessToken (error, response, body)->
        if response.statusCode is 200
          data = JSON.parse(body)
          access_token = data.access_token
          options.access_token = access_token
          _.extend options,
            headers:
              "Authorization": "Bearer #{access_token}"
          # call itself again (this time with the access_token)
          _req(0)
        else
          # try again to get an access token
          if retry is 10
            throw new Error "Could not retrive access_token after 10 attempts.\n" +
              "Status code: #{response.statusCode}\n" +
              "Body: #{body}\n"
          else
            retry++
            _req(retry)
    else
      request_options =
        uri: "#{options.uri}#{params.resource}"
        method: params.method
        headers: options.headers
        timeout: options.timeout
        rejectUnauthorized: options.rejectUnauthorized

      if params.body
        request_options.body = params.body

      exports.doRequest(request_options, callback)

  _req(0)

exports.doRequest = (options, callback)->
  request options, callback

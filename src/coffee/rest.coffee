_ = require("underscore")._
request = require("request")
OAuth2 = require("./oauth2").OAuth2
Config = require('../config').config

exports.Rest = (options = {})->
  @_options = _.defaults options,
    project_key: Config.project_key
    host: "api.sphere.io"

  _.extend @_options,
    request:
      uri: "https://#{@_options.host}/#{@_options.project_key}"
      timeout: 20000

  if @_options.access_token
    _.extend @_options.request,
      headers:
        "Authorization": "Bearer #{@_options.access_token}"
  @

exports.Rest.prototype.GET = (resource, callback)->
  options = @_options
  _get = ->
    unless options.access_token
      exports.doAuth (data)->
        access_token = data.access_token
        options.access_token = access_token
        _.extend options.request,
          headers:
            "Authorization": "Bearer #{access_token}"
        # call itself again (this time with the access_token)
        _get()

    request_options = _.clone(options.request)
    _.extend request_options,
      uri: "#{request_options.uri}#{resource}"
      method: "GET"
    exports.doRequest(request_options, callback)
  _get()

exports.Rest.prototype.POST = (resource, payload, callback)->
  options = _.clone(@_options.request)
  _.extend options,
    uri: "#{options.uri}#{resource}"
    method: "POST"
    body: payload

  exports.doRequest(options, callback)

exports.Rest.prototype.PUT = -> #noop
exports.Rest.prototype.DELETE = -> #noop

exports.doRequest = (options, callback)->
  request options, (error, response, body)->
    callback(error, response, body)

exports.doAuth = (callback)->
  oa = new OAuth2 Config
  oa.getAccessToken (data)-> callback(data)
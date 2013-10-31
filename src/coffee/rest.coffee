_ = require("underscore")._
request = require('request')

exports.Rest = (options = {})->
  # host
  # project_key
  # access_token
  @_options = _.defaults options,
    host: "api.sphere.io"

  _.extend @_options,
    uri: "https://#{@_options.host}/#{@_options.project_key}"
    headers:
      "Authorization": "Bearer #{@_options.access_token}"
    timeout: 20000
  @

exports.Rest.prototype.GET = (resource, callback)->
  options = _.clone(@_options)
  _.extend options,
    uri: "#{options.uri}#{resource}"
    method: "GET"

  doRequest(options, callback)

exports.Rest.prototype.POST = (resource, payload, callback)->
  options = _.clone(@_options)
  _.extend options,
    uri: "#{options.uri}#{resource}"
    method: "POST"
    body: payload

  doRequest(options, callback)

exports.Rest.prototype.PUT = -> #noop
exports.Rest.prototype.DELETE = -> #noop

exports.doRequest = (options, callback)->
  request options, (error, response, body)->
    callback(error, response, body)

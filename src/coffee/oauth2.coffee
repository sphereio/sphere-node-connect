_ = require('underscore')._
querystring = require 'querystring'
request = require 'request'
Logger = require './logger'

class OAuth2

  constructor: (opts = {}) ->
    config = opts.config
    throw new Error('Missing credentials') unless config
    throw new Error('Missing \'client_id\'') unless config.client_id
    throw new Error('Missing \'client_secret\'') unless config.client_secret
    throw new Error('Missing \'project_key\'') unless config.project_key

    @logger = new Logger opts.logConfig

    rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
    @_options =
      config: config
      host: opts.host or 'auth.sphere.io'
      accessTokenUrl: opts.accessTokenUrl or '/oauth/token'
      timeout: opts.timeout or 20000
      rejectUnauthorized: rejectUnauthorized

    @logger.debug @_options, 'OAuth constructor initialized.'
    return

  getAccessToken: (callback) ->
    params =
      grant_type: 'client_credentials'
      scope: "manage_project:#{@_options.config.project_key}"

    payload = querystring.stringify(params)
    request_options =
      uri: "https://#{@_options.config.client_id}:#{@_options.config.client_secret}@#{@_options.host}#{@_options.accessTokenUrl}"
      json: true
      method: 'POST'
      body: payload
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': payload.length
      timeout: @_options.timeout
      rejectUnauthorized: @_options.rejectUnauthorized

    @logger.info 'Retrieving access_token...'
    @_doRequest(request_options, callback)

  _doRequest: (options, callback) ->
    request options, (e, r, b) =>
      @logger.error e if e
      @logger.debug request: r.request, response: r, 'OAuth response'
      callback(e, r, b)

###
Exports object
###
module.exports = OAuth2

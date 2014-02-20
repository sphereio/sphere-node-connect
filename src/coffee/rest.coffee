_ = require('underscore')._
request = require 'request'
Logger = require './logger'
OAuth2 = require './oauth2'

class Rest

  constructor: (opts = {}) ->
    config = opts.config
    throw new Error('Missing credentials') unless config
    throw new Error('Missing \'client_id\'') unless config.client_id
    throw new Error('Missing \'client_secret\'') unless config.client_secret
    throw new Error('Missing \'project_key\'') unless config.project_key

    @logger = new Logger opts.logConfig

    rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
    userAgent = if _.isUndefined(opts.user_agent) then 'sphere-node-connect' else opts.user_agent
    @_options =
      config: config
      host: opts.host or 'api.sphere.io'
      access_token: opts.access_token or undefined
      timeout: opts.timeout or 20000
      rejectUnauthorized: rejectUnauthorized
      headers:
        'User-Agent': userAgent
    @_options.uri = "https://#{@_options.host}/#{@_options.config.project_key}"

    oauth_options = _.clone(opts)
    _.extend oauth_options,
      host: opts.oauth_host
    @_oauth = new OAuth2 oauth_options

    if @_options.access_token
      @_options.headers['Authorization'] = "Bearer #{@_options.access_token}"

    @logger.debug @_options, 'Rest constructor initialized.'
    return

  GET: (resource, callback) ->
    @logger.info 'GET', resource
    params =
      resource: resource
      method: 'GET'
    @_preRequest(params, callback)

  POST: (resource, payload, callback) ->
    @logger.info 'POST', resource, payload
    params =
      resource: resource
      method: 'POST'
      body: payload
    @_preRequest(params, callback)

  DELETE: (resource, callback) ->
    @logger.info 'DELETE', resource
    params =
      resource: resource
      method: 'DELETE'
    @_preRequest(params, callback)

  PUT: ->
    @logger.warn 'PUT', 'Method not implemented yet'
    throw new Error 'Not implemented yet'

  _preRequest: (params, callback) ->
    _req = (retry) =>
      unless @_options.access_token
        @_oauth.getAccessToken (error, response, body) =>
          if error
            if retry is 10
              @logger.warn error, 'Error on retrieving access_token after 10 attempts.'
              throw new Error 'Error on retrieving access_token after 10 attempts.\n' +
                "Error: #{error}\n"
            else
              @logger.debug "Failed to retrieve access_token, retrying...#{retry + 1}"
              return _req(retry + 1)
          if response.statusCode isnt 200
            # try again to get an access token
            if retry is 10
              @logger.warn body, 'Error on retrieving access_token after 10 attempts.'
              throw new Error 'Could not retrieve access_token after 10 attempts.\n' +
                "Status code: #{response.statusCode}\n" +
                "Body: #{body}\n"
            else
              @logger.debug "Failed to retrieve access_token, retrying...#{retry + 1}"
              _req(retry + 1)
          else
            access_token = body.access_token
            @_options.access_token = access_token
            @_options.headers['Authorization'] = "Bearer #{@_options.access_token}"
            @logger.info 'New access_token received', access_token
            # call itself again (this time with the access_token)
            _req(0)
      else
        request_options =
          uri: "#{@_options.uri}#{params.resource}"
          json: true
          method: params.method
          headers: @_options.headers
          timeout: @_options.timeout
          rejectUnauthorized: @_options.rejectUnauthorized

        if params.body
          request_options.body = params.body

        @_doRequest(request_options, callback)

    _req(0)

  _doRequest: (options, callback) ->
    request options, (e, r, b) =>
      @logger.error e if e
      @logger.debug request: r.request, response: r, 'Rest response'
      callback(e, r, b)

###
Exports object
###
module.exports = Rest

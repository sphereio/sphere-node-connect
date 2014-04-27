_ = require 'underscore'
Config = require('../config').config
OAuth2 = require '../lib/oauth2'
Rest = require '../lib/rest'

_.each ['valid-ssl', 'self-signed-ssl'], (mode) ->
  isSelfSigned = mode is 'self-signed-ssl'

  describe "Integration test (#{mode})", ->

    beforeEach ->
      if isSelfSigned
        @oa = new OAuth2
          config: Config.staging
          host: Config.staging.oauth_host
          rejectUnauthorized: false
        @rest = new Rest
          config: Config.staging
          host: Config.staging.api_host
          oauth_host: Config.staging.oauth_host
          rejectUnauthorized: false
      else
        @oa = new OAuth2
          config: Config.prod
        @rest = new Rest
          config: Config.prod
      @rest.logger.info = -> # don't print to console
      @rest.logger.warn = -> # don't print to console
      @rest._oauth.logger.info = -> # don't print to console
      @oa.logger.info = -> # don't print to console

    afterEach ->
      @oa = null
      @rest = null

    it 'should get access token', (done) ->
      @oa.getAccessToken (error, response, body) ->
        # as jasmine does not stop on the first failing expectation, we use an if here to distingush good and bad case
        if error
          # We don't want any error!
          expect(error).toBeUndefined()
          # This allows us to check the error case when we eg. use a wrong oauth host name
        else
          expect(body.access_token).toBeDefined()
        done()

    it 'should create, get and delete channel', (done) ->
      @rest.POST '/channels', {key: 'foo'}, (error, response, body) =>
        @rest.GET '/channels?where=key+%3D+%22foo%22', (error, response, body) =>
          expect(response.statusCode).toBe 200
          expect(body).toBeDefined()
          channel = body.results[0]
          expect(channel.key).toEqual 'foo'
          @rest.DELETE "/channels/#{channel.id}?version=#{channel.version}", (error, response, body) ->
            expect(response.statusCode).toBe 200
            done()

    it 'should return 404 if product is not found', (done) ->
      @rest.GET '/products/123', (error, response, body) ->
        expect(response.statusCode).toBe 404
        done()

    it 'should create an delete custom object', (done) ->
      data =
        container: 'integration'
        key: 'foo'
        value: 'bar'
      @rest.POST '/custom-objects', data, (error, response, body) =>
        expect(response.statusCode).toBe 201
        @rest.DELETE '/custom-objects/integration/foo', (error, response, body) ->
          expect(response.statusCode).toBe 200
          done()

_ = require 'underscore'
Config = require('../config').config
OAuth2 = require '../lib/oauth2'

describe 'OAuth2', ->

  it 'should initialize with default options', ->
    oa = new OAuth2
      config: Config.prod
    expect(oa).toBeDefined()
    expect(oa._options.host).toBe 'auth.sphere.io'
    expect(oa._options.accessTokenUrl).toBe '/oauth/token'
    expect(oa._options.timeout).toBe 20000
    expect(oa._options.rejectUnauthorized).toBe true

  it 'should throw error if no credentials are given', ->
    oa = -> new OAuth2
    expect(oa).toThrow new Error 'Missing credentials'

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config.prod)
      delete opt[key]
      oa = -> new OAuth2 config: opt
      expect(oa).toThrow new Error "Missing '#{key}'"

  it "should pass 'host' option", ->
    oa = new OAuth2
      config: Config.prod
      host: 'example.com'
    expect(oa._options.host).toBe 'example.com'

  it 'should pass \'accessTokenUrl\' option', ->
    oa = new OAuth2
      config: Config.prod
      accessTokenUrl: '/foo/bar'
    expect(oa._options.accessTokenUrl).toBe '/foo/bar'

  it 'should pass \'timeout\' option', ->
    oa = new OAuth2
      config: Config.prod
      timeout: 100
    expect(oa._options.timeout).toBe 100

  it 'should pass \'rejectUnauthorized\' option', ->
    oa = new OAuth2
      config: Config.prod
      rejectUnauthorized: false
    expect(oa._options.rejectUnauthorized).toBe false

  it 'should not fail to log if request times out', (done) ->
    oa = new OAuth2
      config: Config.prod
      timeout: 1
    oa.logger.error = -> # don't print to console
    callMe = -> done()
    expect(-> oa.getAccessToken(callMe)).not.toThrow()

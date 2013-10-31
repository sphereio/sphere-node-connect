_ = require("underscore")._
OAuth2 = require("../lib/oauth2").OAuth2
Config = require('../config').config

describe "OAuth2", ->
  beforeEach ->
    @oa = new OAuth2 Config

  it "should initialize", ->
    expect(@oa).toBeDefined()

  _.each ["client_id", "client_secret", "project_key"], (key)->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      oa = -> new OAuth2 opt
      expect(oa).toThrow new Error("Missing '#{key}'")

describe "OAuth2.getAccessToken", ->
  beforeEach ->
    @oa = new OAuth2 Config

  xit "should send request for access token", (done)->
    @oa.getAccessToken (data)->
      expect(data.access_token).toBeDefined()
      done()
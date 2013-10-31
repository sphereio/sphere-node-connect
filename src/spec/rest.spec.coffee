OAuth2 = require("../lib/oauth2").OAuth2
Rest = require("../lib/rest").Rest
Config = require('../config').config

describe "Rest", ->

  getAccessToken = (f)->
    oa = new OAuth2 Config
    oa.getAccessToken (data)->
      access_token = data.access_token
      expect(access_token).toBeDefined()
      f(access_token)

  it "should initialize", ->
    rest = new Rest()
    expect(rest).toBeDefined()

  it "should initialize with options", (done)->
    getAccessToken (access_token)->
      rest = new Rest
        project_key: Config.project_key
        access_token: access_token

      expect(rest._options).toEqual
        project_key: Config.project_key
        access_token: access_token
        host: "api.sphere.io"
        uri: "https://api.sphere.io/#{Config.project_key}"
        headers:
          "Authorization": "Bearer #{access_token}"
        timeout: 20000

      done()
_ = require("underscore")._
OAuth2 = require("../lib/oauth2").OAuth2
Rest = require("../lib/rest").Rest
Config = require('../config').config

describe "Integration test", ->

  it "should get access token", (done)->
    oa = new OAuth2 Config
    oa.getAccessToken (error, response, body)->
      data = JSON.parse(body)
      expect(data.access_token).toBeDefined()
      done()

  it "should get products", (done)->
    rest = new Rest Config
    rest.GET "/product-projections", (error, response, body)->
      expect(response.statusCode).toBe 200
      json = JSON.parse(body)
      expect(json).toBeDefined()
      results = json.results
      expect(results.length).toBeGreaterThan 0
      expect(results[0].id).toEqual jasmine.any(String)
      done()

  it "should return 404 if product is not found", (done)->
    rest = new Rest Config
    rest.GET "/products/123", (error, response, body)->
      expect(response.statusCode).toBe 404
      done()
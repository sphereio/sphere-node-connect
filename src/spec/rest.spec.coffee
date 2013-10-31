Rest = require("../lib/rest").Rest
Config = require('../config').config

describe "Rest", ->

  it "should initialize", ->
    rest = new Rest()
    expect(rest).toBeDefined()

  it "should initialize with options", ->
    rest = new Rest
      project_key: Config.project_key

    expect(rest._options).toEqual
      project_key: Config.project_key
      host: "api.sphere.io"
      request:
        uri: "https://api.sphere.io/#{Config.project_key}"
        timeout: 20000

describe "exports", ->

  beforeEach ->
    @rest = require("../lib/rest")
    spyOn(@rest, "doRequest")

  it "should call doRequest", ->
    @rest.doRequest()
    expect(@rest.doRequest).toHaveBeenCalled()

describe "Rest.GET", ->

  beforeEach ->
    @lib = require("../lib/rest")
    spyOn(@lib, "doRequest").andCallFake((options, callback)-> callback(null, null, {id: "123"}))
    spyOn(@lib, "doAuth").andCallFake((callback)-> callback({access_token: "foo"}))

  xit "should send GET request", (done)->
    rest = new Rest
      project_key: Config.project_key
      access_token: "foo"

    callMe = (e, r, b)->
      expect(b.id).toBe "123"
      done()
    rest.GET("/product-projections", callMe)

    expected_options =
      uri: "https://api.sphere.io/#{Config.project_key}/product-projections"
      method: "GET"
      headers:
        "Authorization": "Bearer foo"
      timeout: 20000
    expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should send GET request withOAuth", (done)->
    rest = new Rest
      project_key: Config.project_key

    callMe = (e, r, b)->
      expect(b.id).toBe "123"
      done()
    rest.GET("/product-projections", callMe)

    expect(@lib.doAuth).toHaveBeenCalledWith(jasmine.any(Function))
    expected_options =
      uri: "https://api.sphere.io/#{Config.project_key}/product-projections"
      method: "GET"
      headers:
        "Authorization": "Bearer foo"
      timeout: 20000
    expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

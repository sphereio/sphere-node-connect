_ = require("underscore")._
Rest = require("../lib/rest").Rest
Config = require('../config').config

describe "Rest", ->

  beforeEach ->
    @rest = new Rest Config

  it "should initialize", ->
    expect(@rest).toBeDefined()

  it "should initialize with options", ->
    @rest = new Rest Config

    expected_options =
      config: Config
      host: "api.sphere.io"
      request:
        uri: "https://api.sphere.io/#{Config.project_key}"
        timeout: 20000
    expect(@rest._options).toEqual expected_options

  _.each ["client_id", "client_secret", "project_key"], (key)->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      rest = -> new Rest opt
      expect(rest).toThrow new Error("Missing '#{key}'")

describe "exports", ->

  beforeEach ->
    @lib = require("../lib/rest")

  _.each ["preRequest", "doRequest", "doAuth"], (method)->
    it "should call #{method}", ->
      spyOn(@lib, "#{method}")
      @lib[method]()
      expect(@lib[method]).toHaveBeenCalled()

describe "Rest requests", ->

  beforeEach ->
    @lib = require("../lib/rest")
    spyOn(@lib, "doRequest").andCallFake((options, callback)-> callback(null, null, {id: "123"}))
    spyOn(@lib, "doAuth").andCallFake((config, callback)-> callback(null, {statusCode: 200}, JSON.stringify(access_token: "foo")))

    opts = _.clone(Config)
    opts.access_token = "foo"
    @rest = new Rest opts

  prepareRequest = (done, f)->
    callMe = (e, r, b)->
      expect(b.id).toBe "123"
      done()
    expected_options =
      uri: "https://api.sphere.io/#{Config.project_key}/product-projections"
      method: "GET"
      headers:
        "Authorization": "Bearer foo"
      timeout: 20000
    f(callMe, expected_options)

  it "should send GET request", (done)->
    prepareRequest done, (callMe, expected_options)=>
      @rest.GET("/product-projections", callMe)
      expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should send GET request withOAuth", (done)->
    rest = new Rest Config
    prepareRequest done, (callMe, expected_options)=>
      rest.GET("/product-projections", callMe)
      expect(@lib.doAuth).toHaveBeenCalledWith(Config, jasmine.any(Function))
      expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should send POST request", (done)->
    prepareRequest done, (callMe, expected_options)=>
      @rest.POST("/products", {name: "Foo"}, callMe)
      _.extend expected_options,
        uri: "https://api.sphere.io/#{Config.project_key}/products"
        method: "POST"
        body: {name: "Foo"}
      expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should send POST request withOAuth", (done)->
    rest = new Rest Config
    prepareRequest done, (callMe, expected_options)=>
      rest.POST("/products", {name: "Foo"}, callMe)
      _.extend expected_options,
        uri: "https://api.sphere.io/#{Config.project_key}/products"
        method: "POST"
        body: {name: "Foo"}
      expect(@lib.doAuth).toHaveBeenCalledWith(Config, jasmine.any(Function))
      expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should fail to getting an access_token after 10 attempts", ->
    @lib.doAuth.isSpy = false
    spyOn(@lib, "doAuth").andCallFake((config, callback)-> callback(null, {statusCode: 500}, null))
    req = => @lib.preRequest({}, {}, ->)
    expect(req).toThrow new Error("Could not retrive access_token after 10 attempts")

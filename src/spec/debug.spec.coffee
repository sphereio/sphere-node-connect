log = require('npmlog')
debug = require('../lib/debug')

describe 'Debug', ->

  beforeEach ->
    @response =
      statusCode: 200
      headers: {}
      body: ''
      request:
        uri: {}
        method: 'GET'
        headers: {}

    spyOn(log, 'http')

  it 'should log request', ->
    debug.http(true, @response)
    expect(log.http).toHaveBeenCalled()

  it 'should not log request (if no verbose option is given)', ->
    debug.http(false, @response)
    expect(log.http).not.toHaveBeenCalled()

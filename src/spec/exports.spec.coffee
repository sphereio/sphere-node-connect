{Rest, OAuth2, Logger} = require '../lib/main'

describe 'exports', ->

  it 'Rest', ->
    expect(Rest).toBeDefined()

  it 'OAuth2', ->
    expect(OAuth2).toBeDefined()

  it 'Logger', ->
    expect(Logger).toBeDefined()

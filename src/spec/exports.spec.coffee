{ Rest } = require '../lib/main'
{ OAuth2 } = require '../lib/main'

describe 'exports', ->

  it 'Rest', ->
    expect(Rest).toBeDefined()

  it 'OAuth2', ->
    expect(OAuth2).toBeDefined()

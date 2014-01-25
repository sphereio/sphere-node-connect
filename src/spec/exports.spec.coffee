Rest = require('../lib/main').Rest
OAuth2 = require('../lib/main').OAuth2

describe "exports", ->
  it "Rest", ->
    expect(Rest).toBeDefined()

  it "OAuth2", ->
    expect(OAuth2).toBeDefined()

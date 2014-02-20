logger = require '../lib/logger'

describe 'Logger', ->

  it 'should initialize with default options', ->
    log = logger.init()

    expect(log.streams[0].type).toBe 'stream'
    expect(log.streams[0].level).toBe 30 # info
    expect(log.streams[1].type).toBe 'file'
    expect(log.streams[1].level).toBe 20 # debug
    expect(log.streams[1].path).toBe './sphere-node-connect-debug.log'
    expect(log.fields.name).toBe 'sphere-node-connect'
    expect(log.serializers.request).toEqual jasmine.any(Function)
    expect(log.serializers.response).toEqual jasmine.any(Function)
    expect(log.src).toBe false

  it 'should initialize with custom options', ->
    log = logger.init
      levelStream: 'error'
      levelFile: 'trace'
      path: './another-path.log'
      name: 'foo'
      serializers: foo: -> 'bar'
      src: true

    expect(log.streams[0].type).toBe 'stream'
    expect(log.streams[0].level).toBe 50 # error
    expect(log.streams[1].type).toBe 'file'
    expect(log.streams[1].level).toBe 10 # trace
    expect(log.streams[1].path).toBe './another-path.log'
    expect(log.fields.name).toBe 'foo'
    expect(log.serializers.foo()).toBe 'bar'
    expect(log.src).toBe true

  it 'should use given logger', ->
    existingLogger = logger.init name: 'foo'
    log = logger.init logger: existingLogger

    expect(log.fields.name).toBe 'foo'
    expect(log.fields.widget_type).toBe 'sphere-node-connect'

_ = require('underscore')._
bunyan = require 'bunyan'

module.exports = class

  @appName: 'sphere-node-connect'

  @levelStream: 'info'

  @levelFile: 'debug'

  @path: './sphere-node-connect-debug.log'

  ###*
   * https://www.npmjs.org/package/bunyan
   *
   * Initialize the logger with following options:
   * - levelStream: log level for stdout stream 'trace | debug | info | warn | error | fatal' (default 'info')
   * - levelFile: log level for file stream 'trace | debug | info | warn | error | fatal' (default 'debug')
   * - path: the file path where to write the stream (default './log')
   * - logger: a {Bunyan} logger to use instead of creating a new one (usually used from a parent module)
   * - name: the name of the app
   * - serializers: a mapping of log record field name to a serializer function.
   *   By default the {Bunyan} serializers are extended with some custom serializers for {request} objects.
   *   (https://github.com/trentm/node-bunyan#serializers)
   * - src: includes a log of the call source location (file, line, function). Determining the source call
   *   is slow, therefor it's recommended not to enable this on production.
   * - streams: a list of streams that defines the type of output for log messages
   *   (default:
   *     'stream': 'info' -> stdout
   *     'file': 'debug' -> file (path)
   *   )
   *
   * @param  {Object} [config] The configuration for the logger
   * @return {Object} A {Bunyan} logger
  ###
  constructor: (config = {}) ->

    {levelStream, levelFile, path, logger, name, serializers, src} = _.defaults config,
      levelStream: @constructor.levelStream
      levelFile: @constructor.levelFile
      path: @constructor.path
      name: @constructor.appName
      serializers: _.extend bunyan.stdSerializers,
        request: @reqSerializer
        response: @resSerializer
      src: false # never use this option on production
    {streams} = _.defaults config,
      streams: [
        {level: levelStream, stream: process.stdout}
        {level: levelFile, path: path}
      ]

    if logger
      logger = logger.child widget_type: @constructor.appName
    else
      logger = bunyan.createLogger
        name: name
        src: src
        serializers: serializers
        streams: streams

    return logger

  reqSerializer: (req) ->
    type: 'REQUEST'
    uri: req.uri
    method: req.method
    headers: req.headers

  resSerializer: (res) ->
    type: 'RESPONSE'
    status: res.statusCode
    headers: res.headers
    body: res.body

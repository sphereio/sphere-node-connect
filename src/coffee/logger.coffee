_ = require('underscore')._
bunyan = require 'bunyan'

module.exports = class

  ###*
   * https://www.npmjs.org/package/bunyan
   *
   * Initialize the logger with following options:
   * - level: log level 'trace | debug | info | warn | error | fatal' (default 'info')
   * - path: the file path where to write the stream (default './log')
   * - logger: a {Bunyan} logger to use instead of creating a new one (usually used from a parent module)
   * - name: the name of the app
   * - serializers: a mapping of log record field name to a serializer function.
   *   By default the {Bunyan} serializers are extended with some custom serializers for {request} objects.
   *   (https://github.com/trentm/node-bunyan#serializers)
   * - src: includes a log of the call source location (file, line, function). Determining the source call
   *   is slow, therefor it's recommended not to enable this on production.
   *
   * @param  {Object} [config] The configuration for the logger
   * @return {Object} A {Bunyan} logger
  ###
  @init: (config = {}) ->

    {levelStream, levelFile, path, logger, name, serializers, src} = _.defaults config,
      levelStream: 'info'
      levelFile: 'debug'
      path: './sphere-node-connect-debug.log'
      name: 'sphere-node-connect'
      serializers: _.extend bunyan.stdSerializers,
        request: reqSerializer
        response: resSerializer
      src: false # never use this option on production

    if logger
      logger = logger.child widget_type: 'sphere-node-connect'
    else
      logger = bunyan.createLogger
        name: name
        serializers: serializers
        src: src
        streams: [
          {level: levelStream, stream: process.stdout}
          {level: levelFile, path: path}
        ]

    logger

reqSerializer = (req) ->
  type: 'REQUEST'
  uri: req.uri
  method: req.method
  headers: req.headers

resSerializer = (res) ->
  type: 'RESPONSE'
  status: res.statusCode
  headers: res.headers
  body: res.body

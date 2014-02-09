log = require('npmlog')

module.exports = class

  @http: (isActive, response)->
    if isActive
      log.http('CONNECT', 'request ====================>')
      log.http('URI', response.request.uri)
      log.http('Method', response.request.method)
      log.http('Headers', response.request.headers)
      log.http('CONNECT', 'response ====================>')
      log.http('Status', response.statusCode)
      log.http('Headers', response.headers)
      log.http('Body', response.body)

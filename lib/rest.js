/* ===========================================================
# sphere-node-connect - v0.0.7
# ==============================================================
# Copyright (c) 2013 Nicola Molinari
# Licensed under the MIT license.
*/
var OAuth2, request, _;

_ = require("underscore")._;

request = require("request");

OAuth2 = require("./oauth2").OAuth2;

exports.Rest = function(opts) {
  if (opts == null) {
    opts = {};
  }
  if (!opts.client_id) {
    throw new Error("Missing 'client_id'");
  }
  if (!opts.client_secret) {
    throw new Error("Missing 'client_secret'");
  }
  if (!opts.project_key) {
    throw new Error("Missing 'project_key'");
  }
  this._options = {
    config: {
      client_id: opts.client_id,
      client_secret: opts.client_secret,
      project_key: opts.project_key
    },
    host: opts.host || "api.sphere.io",
    access_token: opts.access_token || void 0
  };
  _.extend(this._options, {
    request: {
      uri: "https://" + this._options.host + "/" + this._options.config.project_key,
      timeout: 20000
    }
  });
  if (this._options.access_token) {
    _.extend(this._options.request, {
      headers: {
        "Authorization": "Bearer " + this._options.access_token
      }
    });
  }
  return this;
};

exports.Rest.prototype.GET = function(resource, callback) {
  var params;
  params = {
    resource: resource,
    method: "GET"
  };
  return exports.preRequest(this._options, params, callback);
};

exports.Rest.prototype.POST = function(resource, payload, callback) {
  var params;
  params = {
    resource: resource,
    method: "POST",
    body: payload
  };
  return exports.preRequest(this._options, params, callback);
};

exports.Rest.prototype.PUT = function() {};

exports.Rest.prototype.DELETE = function() {};

exports.preRequest = function(options, params, callback) {
  var _req;
  _req = function() {
    var request_options;
    if (!options.access_token) {
      return exports.doAuth(options.config, function(data) {
        var access_token;
        access_token = data.access_token;
        options.access_token = access_token;
        _.extend(options.request, {
          headers: {
            "Authorization": "Bearer " + access_token
          }
        });
        return _req();
      });
    } else {
      request_options = _.clone(options.request);
      _.extend(request_options, {
        uri: "" + request_options.uri + params.resource,
        method: params.method
      });
      if (params.body) {
        request_options.body = params.body;
      }
      return exports.doRequest(request_options, callback);
    }
  };
  return _req();
};

exports.doRequest = function(options, callback) {
  return request(options, function(error, response, body) {
    return callback(error, response, body);
  });
};

exports.doAuth = function(config, callback) {
  var oa;
  if (config == null) {
    config = {};
  }
  oa = new OAuth2(config);
  return oa.getAccessToken(function(error, response, body) {
    var data;
    data = JSON.parse(body);
    return callback(data);
  });
};

/* ===========================================================
# sphere-node-connect - v0.1.2
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

exports.Rest.prototype.DELETE = function(resource, callback) {
  var params;
  params = {
    resource: resource,
    method: "DELETE"
  };
  return exports.preRequest(this._options, params, callback);
};

exports.Rest.prototype.PUT = function() {};

exports.preRequest = function(options, params, callback) {
  var _req;
  _req = function(retry) {
    var request_options;
    if (!options.access_token) {
      return exports.doAuth(options.config, function(error, response, body) {
        var access_token, data;
        if (response.statusCode === 200) {
          data = JSON.parse(body);
          access_token = data.access_token;
          options.access_token = access_token;
          _.extend(options.request, {
            headers: {
              "Authorization": "Bearer " + access_token
            }
          });
          return _req(0);
        } else {
          if (retry === 10) {
            throw new Error("Could not retrive access_token after 10 attempts");
          } else {
            retry++;
            return _req(retry);
          }
        }
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
  return _req(0);
};

exports.doRequest = function(options, callback) {
  return request(options, callback);
};

exports.doAuth = function(config, callback) {
  var oa;
  if (config == null) {
    config = {};
  }
  oa = new OAuth2(config);
  return oa.getAccessToken(callback);
};

/* ===========================================================
# sphere-node-connect - v0.2.4
# ==============================================================
# Copyright (c) 2013 Nicola Molinari
# Licensed under the MIT license.
*/
var OAuth2, request, _;

_ = require("underscore")._;

request = require("request");

OAuth2 = require("./oauth2").OAuth2;

exports.Rest = function(opts) {
  var config, oauth_options, rejectUnauthorized, userAgent;
  if (opts == null) {
    opts = {};
  }
  config = opts.config;
  if (!config) {
    throw new Error("Missing credentials");
  }
  if (!config.client_id) {
    throw new Error("Missing 'client_id'");
  }
  if (!config.client_secret) {
    throw new Error("Missing 'client_secret'");
  }
  if (!config.project_key) {
    throw new Error("Missing 'project_key'");
  }
  rejectUnauthorized = _.isUndefined(opts.rejectUnauthorized) ? true : opts.rejectUnauthorized;
  userAgent = _.isUndefined(opts.user_agent) ? 'sphere-node-connect' : opts.user_agent;
  this._options = {
    config: config,
    host: opts.host || "api.sphere.io",
    access_token: opts.access_token || void 0,
    timeout: opts.timeout || 20000,
    rejectUnauthorized: rejectUnauthorized,
    headers: {
      'User-Agent': userAgent
    }
  };
  this._options.uri = "https://" + this._options.host + "/" + this._options.config.project_key;
  oauth_options = _.clone(opts);
  _.extend(oauth_options, {
    host: opts.oauth_host
  });
  this._oauth = new OAuth2(oauth_options);
  if (this._options.access_token) {
    this._options.headers["Authorization"] = "Bearer " + this._options.access_token;
  }
};

exports.Rest.prototype.GET = function(resource, callback) {
  var params;
  params = {
    resource: resource,
    method: "GET"
  };
  return this.preRequest(params, callback);
};

exports.Rest.prototype.POST = function(resource, payload, callback) {
  var params;
  params = {
    resource: resource,
    method: "POST",
    body: payload
  };
  return this.preRequest(params, callback);
};

exports.Rest.prototype.DELETE = function(resource, callback) {
  var params;
  params = {
    resource: resource,
    method: "DELETE"
  };
  return this.preRequest(params, callback);
};

exports.Rest.prototype.PUT = function() {};

exports.Rest.prototype.preRequest = function(params, callback) {
  var _req,
    _this = this;
  _req = function(retry) {
    var request_options;
    if (!_this._options.access_token) {
      return _this._oauth.getAccessToken(function(error, response, body) {
        var access_token, data;
        if (error) {
          if (retry === 10) {
            throw new Error("Error on retrieving access_token after 10 attempts.\n" + ("Error: " + error + "\n"));
          } else {
            return _req(retry + 1);
          }
        }
        if (response.statusCode !== 200) {
          if (retry === 10) {
            throw new Error("Could not retrieve access_token after 10 attempts.\n" + ("Status code: " + response.statusCode + "\n") + ("Body: " + body + "\n"));
          } else {
            return _req(retry + 1);
          }
        } else {
          data = JSON.parse(body);
          access_token = data.access_token;
          _this._options.access_token = access_token;
          _this._options.headers["Authorization"] = "Bearer " + _this._options.access_token;
          return _req(0);
        }
      });
    } else {
      request_options = {
        uri: "" + _this._options.uri + params.resource,
        method: params.method,
        headers: _this._options.headers,
        timeout: _this._options.timeout,
        rejectUnauthorized: _this._options.rejectUnauthorized
      };
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

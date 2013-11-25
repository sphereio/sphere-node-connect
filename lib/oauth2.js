/* ===========================================================
# sphere-node-connect - v0.1.2
# ==============================================================
# Copyright (c) 2013 Nicola Molinari
# Licensed under the MIT license.
*/
var querystring, request, _;

querystring = require('querystring');

request = require('request');

_ = require("underscore")._;

exports.OAuth2 = function(opts) {
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
    host: opts.host || "auth.sphere.io",
    accessTokenUrl: opts.accessTokenUrl || "/oauth/token"
  };
  return this;
};

exports.OAuth2.prototype.getAccessToken = function(callback) {
  var params, payload, request_options;
  params = {
    grant_type: "client_credentials",
    scope: "manage_project:" + this._options.config.project_key
  };
  payload = querystring.stringify(params);
  request_options = {
    uri: "https://" + this._options.config.client_id + ":" + this._options.config.client_secret + "@" + this._options.host + this._options.accessTokenUrl,
    method: "POST",
    body: payload,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Content-Length": payload.length
    },
    timeout: 20000
  };
  return request(request_options, function(error, response, body) {
    return callback(error, response, body);
  });
};

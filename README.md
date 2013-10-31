# sphere-node-connect [![Build Status](https://secure.travis-ci.org/emmenko/sphere-node-connect.png?branch=master)](http://travis-ci.org/emmenko/sphere-node-connect)

Quick and easy way to connect your Node.js app with SPHERE.IO.

## Getting Started
Install the module with: `npm install sphere-node-connect`

```javascript
var sphere_connect = require('sphere-node-connect');
var oa = sphere_connect.OAuth2;
var rest = sphere_connect.Rest;
```

Define your SPHERE.IO credentials into a `config.js`

```javascript
/* SPHERE.IO credentials */
exports.config = {
  client_id: "",
  client_secret: "",
  project_key: ""
}
```

## Documentation
The connector exposes 2 objects: `OAuth2` and `Rest`.

The `OAuth2` is used to retrieve an `access_token`

```javascript
var oa = new OAuth2({
  client_id: "",
  client_secret: "",
  project_key: "",
  host: "auth.sphere.io", // optional
  accessTokenUrl: "/oauth/token" // optional
});
oa.getAccessToken(function(error, response, body){
  if (response.statusCode is 200) {
    var data = JSON.parse(body);
    var access_token = data.access_token;
  } else
    throw new Error("Failed to get Access Token.")
})
```

The `Rest` is used to comunicate with the HTTP API.

```javascript
var rest = new Rest({
  client_id: "",
  client_secret: "",
  project_key: "",
  host: "api.sphere.io", // optional
  access_token: "" // optional (if not provided it will automatically retrieve an access_token)
});

rest.GET("/product-projections", function(error, response, body){
  var data = JSON.parse(body);
  if (response.statusCode is 200) {
  } else
    console.log(data)
})
```

Currently `GET` and `POST` are supported


## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 Nicola Molinari
Licensed under the MIT license.

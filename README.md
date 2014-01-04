# sphere-node-connect 

[![Build Status](https://secure.travis-ci.org/emmenko/sphere-node-connect.png?branch=master)](http://travis-ci.org/emmenko/sphere-node-connect) [![NPM version](https://badge.fury.io/js/sphere-node-connect.png)](http://badge.fury.io/js/sphere-node-connect) [![Coverage Status](https://coveralls.io/repos/emmenko/sphere-node-connect/badge.png?branch=master)](https://coveralls.io/r/emmenko/sphere-node-connect?branch=master) [![Dependency Status](https://gemnasium.com/emmenko/sphere-node-connect.png)](https://gemnasium.com/emmenko/sphere-node-connect)

Quick and easy way to connect your Node.js app with [SPHERE.IO](http://sphere.io).

## Getting Started
Install the module with: `npm install sphere-node-connect`

```javascript
var sphere_connect = require('sphere-node-connect');
var oa = sphere_connect.OAuth2;
var rest = sphere_connect.Rest;
```

## Documentation
The connector exposes 2 objects: `OAuth2` and `Rest`.

The `OAuth2` is used to retrieve an `access_token`

```javascript
var oa = new OAuth2({
  config: {
    client_id: "",
    client_secret: "",
    project_key: ""
  },
  host: "auth.sphere.io", // optional
  accessTokenUrl: "/oauth/token" // optional,
  timeout: 20000, // optional
  rejectUnauthorized: true // optional
});
oa.getAccessToken(callback)
```

The `Rest` is used to comunicate with the HTTP API.

```javascript
var rest = new Rest({
  config: {
    client_id: "",
    client_secret: "",
    project_key: ""
  },
  host: "api.sphere.io", // optional
  access_token: "", // optional (if not provided it will automatically retrieve an access_token)
  timeout: 20000, // optional
  rejectUnauthorized: true, // optional
  oauth_host: "auth.sphere.io" // optional (used when retrieving the access_token internally) 
  user_agent: 'my client v0.1' // optional
});

rest.GET(resource, callback)
rest.POST(resource, payload, callback)
```

The `Rest` object, when instantiated, has an internal instance of the `OAuth` module accessible with `rest._oauth`. This is mainly used internally to automatically retrieve an `access_token`.

Currently `GET`, `POST` and `DELETE` are supported.


## Examples
```javascript
oa.getAccessToken(function(error, response, body){
  if (response.statusCode is 200) {
    var data = JSON.parse(body);
    var access_token = data.access_token;
  } else
    throw new Error("Failed to get Access Token.")
})
```

```javascript
// Get a list of all products
rest.GET("/products", function(error, response, body){
  var data = JSON.parse(body);
  console.log(data);
});

// Create a new product
rest.POST("/products", {
  name: { en: "Foo" },
  slug: { en: "foo" },
  productType: { id: "123", typeId: "product-type" }
}, function(error, response, body){
  var data = JSON.parse(body);
  console.log(data);
});

// Update a product
rest.POST("/products/123", {
  version: 1,
  actions: [
    { action: "changeName", name: { en: "Boo" } }
  ]
}, function(error, response, body){
  var data = JSON.parse(body);
  console.log(data);
});

// Delete a product
rest.DELETE("/product/abc?version=3", function(error, response, body) {
  if (response.statusCode == 200) {
    console.log("Product successfully deleted.");
  } else if (response.statusCode == 404) {
    console.log("Product does not exist.");
  } else if (response.statusCode == 400) {
    console.log("Product version does not match.");
  }
});
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

Define your SPHERE.IO credentials into a `config.js`. Since the tests run against 2 projects on different environments you need to provide the credentials for both. If you just have one project You can provide the same credentials for both. 

```javascript
/* SPHERE.IO credentials */
exports.config = {
  staging: {
    client_id: "",
    client_secret: "",
    project_key: "",
    oauth_host: "auth.sphere.io",
    api_host: "api.sphere.io"
  },
  prod: {
    client_id: "",
    client_secret: "",
    project_key: "",
    oauth_host: "auth.sphere.io",
    api_host: "api.sphere.io"
  }
}
```

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## License
Copyright (c) 2013 Nicola Molinari
Licensed under the MIT license.

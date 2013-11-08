# sphere-node-connect [![Build Status](https://secure.travis-ci.org/emmenko/sphere-node-connect.png?branch=master)](http://travis-ci.org/emmenko/sphere-node-connect)

Quick and easy way to connect your Node.js app with [SPHERE.IO](http://sphere.io).

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
oa.getAccessToken(callback)
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

rest.GET(resource, callback)
rest.POST(resource, payload, callback)
```

Currently `GET` and `POST` are supported.


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
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

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

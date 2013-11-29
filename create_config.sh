#!/bin/bash

cat > "config.js" << EOF
/* SPHERE.IO credentials */
exports.config = {
  staging: {
    client_id: "${SPHERE_STAGING_CLIENT_ID}",
    client_secret: "${SPHERE_STAGING_CLIENT_SECRET}",
    project_key: "${SPHERE_STAGING_PROJECT_KEY}",
    oauth_host: "auth.escemo.com",
    api_host: "api.escemo.com"
  },
  prod: {
    client_id: "${SPHERE_CLIENT_ID}",
    client_secret: "${SPHERE_CLIENT_SECRET}",
    project_key: "${SPHERE_PROJECT_KEY}",
    oauth_host: "auth.sphere.io",
    api_host: "api.sphere.io"
  }
}
EOF
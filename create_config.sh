#!/bin/bash

cat > "config.js" << EOF
/* SPHERE.IO credentials */
exports.config = {
  staging: {
    client_id: "${SPHERE_STAGING_CLIENT_ID}",
    client_secret: "${SPHERE_STAGING_CLIENT_SECRET}",
    project_key: "${SPHERE_STAGING_PROJECT_KEY}"
  },
  prod: {
    client_id: "${SPHERE_CLIENT_ID}",
    client_secret: "${SPHERE_CLIENT_SECRET}",
    project_key: "${SPHERE_PROJECT_KEY}"
  }
}
EOF
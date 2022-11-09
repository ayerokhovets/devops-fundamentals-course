#!/bin/bash

# Install the app’s npm dependencies
# npm i

# Run quality-check
npm run lint
npm run test
npm audit

# Build server
npm run build

# Build a Docker image
docker build -t nestjs-rest-api .

# Run the Docker image with the accessable port
docker run --publish 3000:3000 nestjs-rest-api

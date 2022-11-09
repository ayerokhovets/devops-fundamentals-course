#!/bin/bash

# Variables
SCRIPT_DIR=`dirname "$(readlink -f "$BASH_SOURCE")"`
ROOT_DIR=${SCRIPT_DIR%/*}
CLIENT_BUILD_DIR=$ROOT_DIR/dist
CLIENT_REMOTE_DIR=/var/www/shop
ENV_CONFIGURATION=production

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh ubuntu-sshuser "[ ! -d $1 ]"; then
    echo "Creating: $1"
	ssh -t ubuntu-sshuser "sudo bash -c 'mkdir -p $1 && chown -R sshuser: $1'"
  else
    echo "Clearing: $1"
    ssh ubuntu-sshuser "sudo -S rm -r $1/*"
  fi
}

# Install the app’s npm dependencies
npm i

# Run quality-check
npm run lint
npm run test
npm run test:coverage
npm audit

# Build client
npm run build -- --configuration=$ENV_CONFIGURATION --output-path=$CLIENT_BUILD_DIR
echo "Client app was built with $ENV_CONFIGURATION configuration."

# Copy files to remote
check_remote_dir_exists $CLIENT_REMOTE_DIR
echo "Building and transfering client files - START::"
scp -Cr $CLIENT_BUILD_DIR/* ubuntu-sshuser:$CLIENT_REMOTE_DIR
echo "Building and transfering - COMPLETE::"

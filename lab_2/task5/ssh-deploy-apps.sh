#!/bin/bash

# Local folders
SERVER_HOST_DIR=$(pwd)/nestjs-rest-api
CLIENT_HOST_DIR=$(pwd)/shop-react-redux-cloudfront

# Remote folders
SERVER_REMOTE_DIR=/var/app/nestjs-rest-api
CLIENT_REMOTE_DIR=/var/www/shop

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

check_remote_dir_exists $SERVER_REMOTE_DIR
check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "Building and copying server files - START::"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && npm run build
scp -Cr $SERVER_HOST_DIR/dist/* ubuntu-sshuser:$SERVER_REMOTE_DIR
echo "Building and transfering server - COMPLETE::"

echo "Building and transfering client files - START::"
echo $CLIENT_HOST_DIR
cd $CLIENT_HOST_DIR && npm run build
scp -Cr $CLIENT_HOST_DIR/dist/* ubuntu-sshuser:$CLIENT_REMOTE_DIR
echo "Building and transfering - COMPLETE::"

ssh ubuntu-sshuser "cd $SERVER_REMOTE_DIR && pm2 start main.js --name nestjs-api"
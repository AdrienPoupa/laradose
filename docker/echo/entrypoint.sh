#!/bin/sh

# Install echo if needed https://stackoverflow.com/a/26759734/11989865
if ! [ -x "$(command -v laravel-echo-server)" ]; then
  npm install -g laravel-echo-server
fi

# Launch Echo Server
# We are using exec so echo can shutdown properly and remove the lock file
exec laravel-echo-server start

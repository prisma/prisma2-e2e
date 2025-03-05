#!/bin/sh

set -eu

echo "Disabling StrictHostKeyChecking"
mkdir -p ~/.ssh
ssh -vvv ec2-54-209-135-27.compute-1.amazonaws.com
ssh-keyscan -vvv ec2-54-209-135-27.compute-1.amazonaws.com >> ~/.ssh/known_hosts
echo "$SSH_KEY_GRAVITON" > ./server-key.pem

if test -f "./server-key.pem"; then
    chmod 600 ./server-key.pem
fi

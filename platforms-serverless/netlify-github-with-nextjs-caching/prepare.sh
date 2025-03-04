#!/bin/sh

set -eu

export PRISMA_TELEMETRY_INFORMATION='ecosystem-tests platforms-serverless netlify-github-with-nextjs-caching build'

rm -fr .git # because cannot currently be done in finally.sh if failure happens
npm install

# create ssh key
mkdir -p ~/.ssh
echo "$SSH_KEY_NETLIFY_GITHUB_NETXJS_CACHING" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-keyscan github.com >> ~/.ssh/known_hosts

# setup git
git config --global user.email "prismabots@gmail.com"
git config --global user.name "Prismo"

# push project to Netlify
git init
git remote add origin "git@github.com:prisma/prisma-ecosystem-tests-netlify-github-with-nextjs-caching.git"

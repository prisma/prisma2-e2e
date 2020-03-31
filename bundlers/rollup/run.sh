#!/bin/sh

set -eu

yarn install
yarn prisma2 generate
rm -rf dist/
yarn rollup src/index.js --file dist/index.js --format cjs

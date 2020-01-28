#!/bin/sh

set -eux

rm -rf prisma/migrations/
rm -rf prisma/dev.db

yarn install
yarn prisma2 generate

yarn build
yarn seed
yarn start &
pid=$!

sleep 30

expected="Hello stuff, first name: Lisa!"
actual=$(curl -v localhost:3600/hello/stuff)

if [ "$expected" != "$actual" ]; then
	echo "expected '$expected', got '$actual'"
	exit 1
fi

echo "result: $actual"

kill $pid

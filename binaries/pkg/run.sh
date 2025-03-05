#!/bin/sh

set -eu

pnpm install

# This means that we resolve the location of the @prisma/engines package starting to the location of the prisma package
ENGINES_PACKAGE=$(node -e "console.log(path.dirname(require.resolve('@prisma/engines/package.json', {paths: [path.dirname(require.resolve('prisma/package.json'))]})))")

# This is a hack to work around a problem that pkg would otherwise have with the Engines binaries missing in the package
mkdir -p node_modules/prisma/node_modules/@prisma
cp -fr $ENGINES_PACKAGE node_modules/prisma/node_modules/@prisma || echo "Could not copy engines package"

#!/bin/sh

set -eu

pnpm install

# This means that we resolve the location of the @prisma/engines package starting to the location of the prisma package
ENGINES_PACKAGE=$(node -e "console.log(path.dirname(require.resolve('@prisma/engines/package.json', {paths: [path.dirname(require.resolve('prisma/package.json'))]})))")

# This is a hack to work around a problem that pkg would otherwise have with the Engines binaries missing in the package
find $ENGINES_PACKAGE -type f -exec cp -a {} node_modules/prisma/build/ \;

#!/bin/sh

FILE0=node_modules/.prisma/client/index.js
FILE1=sub-project-1/node_modules/.prisma/client/index.js
FILE2=sub-project-2/node_modules/.prisma/client/index.js

set -eux

cd workspace

if [ -f "$FILE1" ] || [ -f "$FILE2" ]; then
    echo "Client should not generate in sub-folder"; exit 1;
fi;

if [ ! -f "$FILE0" ]; then
    echo "Client did not generate"; exit 1;
fi;

pnpm -r run cmd

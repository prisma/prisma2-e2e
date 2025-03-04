#!/bin/sh

set -eux
DEPLOYED_URL=$( tail -n 1 deployment-url.txt )

if [ "$PRISMA_CLIENT_ENGINE_TYPE" == "binary" ]; then
  files=',"files":["default.d.ts","default.js","deno","edge.d.ts","edge.js","index-browser.js","index.d.ts","index.js","package.json","query-engine-rhel-openssl-3.0.x","schema.prisma","wasm.d.ts","wasm.js"]'
else
  files=',"files":["default.d.ts","default.js","deno","edge.d.ts","edge.js","index-browser.js","index.d.ts","index.js","libquery_engine-rhel-openssl-3.0.x.so.node","package.json","schema.prisma","wasm.d.ts","wasm.js"]'
fi

pnpm ts-node ../../utils/fetch-retry-and-confirm-version.ts --url $DEPLOYED_URL --prisma-version $(sh ../../utils/prisma_version.sh) --binary-string ${files}

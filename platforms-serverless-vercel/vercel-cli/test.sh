#!/bin/sh

set -eux

if [ "$PRISMA_CLIENT_ENGINE_TYPE" == "binary" ]; then
  echo "Binary"
  files=',"files":["default.js","index.js","package.json","query-engine-rhel-openssl-3.0.x","schema.prisma"]'
  # TODO Use deployment, not production
  pnpm ts-node ../../utils/fetch-retry-and-confirm-version.ts --url https://e2e-vercel-api-binary.vercel.app/api --prisma-version $(sh ../../utils/prisma_version.sh) --binary-string $files
else
  echo "Library (Default)"
  files=',"files":["default.js","index.js","libquery_engine-rhel-openssl-3.0.x.so.node","package.json","schema.prisma"]'
  # TODO Use deployment, not production
  pnpm ts-node ../../utils/fetch-retry-and-confirm-version.ts --url https://e2e-vercel-api.vercel.app/api --prisma-version $(sh ../../utils/prisma_version.sh) --binary-string $files
fi

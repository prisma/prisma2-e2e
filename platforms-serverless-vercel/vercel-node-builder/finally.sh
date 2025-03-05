#!/bin/sh

set -eu

if [ $PRISMA_CLIENT_ENGINE_TYPE == "binary" ]; then
  echo "Binary"
  pnpm vercel inspect --logs e2e-vercel-node-builder-binary.vercel.app --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID
else
  echo "Library (Default)"
  pnpm vercel inspect --logs e2e-vercel-node-builder.vercel.app --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID
fi

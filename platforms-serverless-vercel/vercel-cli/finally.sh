#!/bin/sh

set -eu

pnpm vercel inspect --logs e2e-vercel-api.vercel.app --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID

#!/bin/sh

set -eu

pnpm vercel logs e2e-driver-adapters-planetscale-vercel-nextjs.vercel.app --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID

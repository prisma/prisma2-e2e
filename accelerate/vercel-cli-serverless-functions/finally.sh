#!/bin/sh

set -eu

pnpm vercel inspect --logs https://e2e-dataproxy-vercel-cli.vercel.app --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID

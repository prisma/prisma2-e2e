#!/usr/bin/env bash

export PRISMA_TELEMETRY_INFORMATION='ecosystem-tests dataproxy vercel-cli-serverless-functions build'

# we set the vercel project & organization environment variables
export VERCEL_PROJECT_ID=$DATAPROXY_VERCEL_CLI_SERVERLESS_FUNCTIONS_PROJECT_ID
export VERCEL_ORG_ID=$VERCEL_ORG_ID

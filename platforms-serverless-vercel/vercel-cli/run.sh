#!/bin/sh

set -eu
# Replace by the following line to debug this script
# set -eux

export PRISMA_TELEMETRY_INFORMATION='ecosystem-tests platforms vercel-cli build'

pnpm install

# Note: be aware that Vercel truncates logs, so if you add something like `--build-env DEBUG="prisma:*"` plenty of logs will be missing.
# That will likely influence the "Postinstall hook" check below, which will result in the CI failing with error code `1`.

if [ "$PRISMA_CLIENT_ENGINE_TYPE" == "binary" ]; then
  echo "Binary"
  export VERCEL_PROJECT_ID=$VERCEL_API_BINARY_PROJECT_ID
else
 echo "Library (Default)"
  export VERCEL_PROJECT_ID=$VERCEL_API_PROJECT_ID
  # Set local var to `library` for the `vercel deploy` command below
  PRISMA_CLIENT_ENGINE_TYPE=library
fi

export VERCEL_ORG_ID=$VERCEL_ORG_ID
echo "VERCEL_ORG_ID: $VERCEL_ORG_ID"
echo "VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
echo "PRISMA_CLIENT_ENGINE_TYPE: $PRISMA_CLIENT_ENGINE_TYPE"
pnpm vercel deploy --prod --yes --force --token=$VERCEL_TOKEN --env DATABASE_URL=$DATABASE_URL --build-env PRISMA_CLIENT_ENGINE_TYPE="$PRISMA_CLIENT_ENGINE_TYPE" --scope=$VERCEL_ORG_ID 1> deployment-url.txt

echo ''
cat deployment-url.txt
DEPLOYED_URL=$( tail -n 1 deployment-url.txt )
echo ''
echo "Deployed to ${DEPLOYED_URL}"

sleep 15

OUTPUT=$(pnpm vercel inspect --logs $DEPLOYED_URL --token=$VERCEL_TOKEN --scope=$VERCEL_ORG_ID)
echo "${OUTPUT}"

# Check the Vercel Build Logs for "Generated Prisma Client"
if echo "${OUTPUT}" | grep -q 'Generated Prisma Client'; then
  echo 'Prisma Client Was Successfully Generated'
else
  echo "Prisma Client Was NOT GENERATED"
  exit 1
fi

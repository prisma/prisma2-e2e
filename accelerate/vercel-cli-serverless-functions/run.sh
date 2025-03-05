#!/bin/sh

set -eu

pnpm install

pnpm vercel deploy \
--prod \
--yes \
--force \
--token=$VERCEL_TOKEN \
--scope=$VERCEL_ORG_ID \
--build-env PRISMA_GENERATE_DATAPROXY="true" \
--env DATAPROXY_COMMON_URL="$DATAPROXY_COMMON_URL" \
--build-env DATAPROXY_FLAVOR="$DATAPROXY_FLAVOR" \
--env DATAPROXY_FLAVOR="$DATAPROXY_FLAVOR" \
1> deployment-url.txt

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
  echo 'Prisma Client was successfully generated'
else
  echo "Prisma Client was NOT GENERATED"
  exit 1
fi

# Check the Vercel Build Logs for "engine=none" in generate
if echo "${OUTPUT}" | grep -q 'engine=none'; then
  echo 'Data Proxy was successfully enabled'
else
  echo "Data Proxy was NOT ENABLED"
  exit 1
fi

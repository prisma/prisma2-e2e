#!/bin/sh

set -eux
export DEBUG="*"

DOCKER_PLATFORM_ARCH="linux/amd64"
PRISMA_DOCKER_IMAGE_NAME="prisma-debian-bullseye-amd64-openssl-1.1.x"

if [ ! -f "client-cert.pem" ]; then
    echo "$GCP_POSTGRESQL_SSL_CLIENT_CERT" >> client-cert.pem
fi

if [ ! -f "client-key.pem" ]; then
    echo "$GCP_POSTGRESQL_SSL_CLIENT_KEY" >> client-key.pem
fi

chmod 600 ./client-key.pem

if [ ! -f "server-ca.pem" ]; then
    echo "$GCP_POSTGRESQL_SSL_SERVER_CA" >> server-ca.pem
fi

openssl pkcs12 -export -out client-identity.p12 \
  -inkey client-key.pem -in client-cert.pem -password pass:prisma \
  -keypbe AES-256-CBC -certpbe AES-256-CBC -macalg SHA256

docker buildx build --load \
  --platform="${DOCKER_PLATFORM_ARCH}" \
  --build-context app=. \
  --build-context utils=../_utils \
  --build-arg DEBUG=${DEBUG} \
  --build-arg PRISMA_TELEMETRY_INFORMATION="${PRISMA_TELEMETRY_INFORMATION}" \
  --build-arg PRISMA_ENGINES_MIRROR=${PRISMA_ENGINES_MIRROR} \
  --build-arg PRISMA_CLIENT_ENGINE_TYPE=${PRISMA_CLIENT_ENGINE_TYPE} \
  --build-arg PRISMA_CLI_QUERY_ENGINE_TYPE=${PRISMA_CLIENT_ENGINE_TYPE} \
  --build-arg CI=${CI} \
  . -t "${PRISMA_DOCKER_IMAGE_NAME}" \
  --progress plain

docker run -p 3000:3000 \
  -e DEBUG=${DEBUG} \
  -e DATABASE_URL=${GCP_POSTGRESQL_SSL_DB_URL} \
  -e CI=${CI} \
  -e PRISMA_CLIENT_ENGINE_TYPE=${PRISMA_CLIENT_ENGINE_TYPE} \
  -e PRISMA_CLI_QUERY_ENGINE_TYPE=${PRISMA_CLIENT_ENGINE_TYPE} \
  -e PRISMA_TELEMETRY_INFORMATION="${PRISMA_TELEMETRY_INFORMATION}" \
  "${PRISMA_DOCKER_IMAGE_NAME}" &

sleep 15

pnpm install
pnpm prisma generate

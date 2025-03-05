#!/bin/sh

set -eu

pnpm install
pnpm prisma generate

rm -rf lambda.zip

GENERATED_CLIENT=$(node -e "
  console.log(
    path.dirname(require.resolve('.prisma/client/package.json', {
      paths: [path.dirname(require.resolve('@prisma/client/package.json'))]
    }))
  )
")

pnpm esbuild index.js --bundle --platform=node --target=node18 --outfile=dist/index.js --format=cjs --alias:'@libsql/client=@libsql/client/web'
cp "$GENERATED_CLIENT"/libquery_engine-rhel-openssl-1.0.x.so.node dist
cp "$GENERATED_CLIENT"/schema.prisma dist

zip -rj lambda.zip dist

aws lambda update-function-configuration --function-name driver-adapters-turso-lambda-basic --runtime nodejs18.x --environment "Variables={DRIVER_ADAPTERS_TURSO_LAMBDA_BASIC_DATABASE_URL=$DRIVER_ADAPTERS_TURSO_LAMBDA_BASIC_DATABASE_URL,DRIVER_ADAPTERS_TURSO_LAMBDA_BASIC_TOKEN=$DRIVER_ADAPTERS_TURSO_LAMBDA_BASIC_TOKEN}" --timeout 30
aws lambda update-function-code --function-name driver-adapters-turso-lambda-basic --zip-file "fileb://lambda.zip"

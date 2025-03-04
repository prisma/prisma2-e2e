#!/bin/sh

set -eux

# commit .env to private repo to deploy easily
echo "DATABASE_URL=$DATABASE_URL" > .env

# 1. Deploy the project with the initial schema

ID=$(date +%s%N)

cp script1.sh script.sh
cp index1.test.js index.test.js
cp pages/api/index1.js pages/api/index.js
cp prisma/schema1.prisma prisma/schema.prisma
npx prisma db push --force-reset # clean it

git add .
git commit -m "push to netlify: $ID, engine = $PRISMA_CLIENT_ENGINE_TYPE"
git branch $ID
git push -u origin $ID

sleep 80 # give some time to build and deploy

DEPLOYED_URL="https://$ID--netlify-github-with-nextjs-caching.netlify.app/"
echo "$DEPLOYED_URL" > deployment-url.txt
echo "Deployed to ${DEPLOYED_URL}"

npm test

# 2. Deploy the project with the updated schema

ID=$(date +%s%N)

cp script2.sh script.sh
cp index2.test.js index.test.js
cp pages/api/index2.js pages/api/index.js
cp prisma/schema2.prisma prisma/schema.prisma
npx prisma db push # don't reset the db

git add .
git commit -m "push to netlify: $ID, engine = $PRISMA_CLIENT_ENGINE_TYPE"
git branch $ID
git push -u origin $ID

sleep 80 # give some time to build and deploy

DEPLOYED_URL="https://$ID--netlify-github-with-nextjs-caching.netlify.app/"
echo "$DEPLOYED_URL" > deployment-url.txt
echo "Deployed to ${DEPLOYED_URL}"

npm test

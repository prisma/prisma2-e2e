#!/bin/bash

echo "-------------- Checking Generated Client QE file --------------"

dir=$1
project=$2

# These are being skipped for a variety of reasons like:
# - Custom project structure
# - Custom output location
# - They do not generate a client
# - They do not set an PRISMA_CLIENT_ENGINE_TYPE
# TODO Adapt tests so they also work here, or adapt project to fit into the mold
skipped_projects=(
  engine-types                                # No PRISMA_CLIENT_ENGINE_TYPE
  # no client
  prisma-dbml-generator                       # No generated Client, so only Client stub with no engine included
  prisma-json-schema-generator                # No generated Client, so only Client stub with no engine included
  pkg                                         # No generated Client, so only Client stub with no engine included
  # no local project
  aws-graviton                                # No local project at all (everything happens on server), so no `prisma` or `node_modules`
  # subfolder
  generate-client-install-on-sub-project-npm  # Client is generated into a subfolder
  generate-client-install-on-sub-project-pnpm # Client is generated into a subfolder
  generate-client-install-on-sub-project-yarn # Client is generated into a subfolder
  pnpm-workspaces-custom-output               # Client is generated into a subfolder
  pnpm-workspaces-default-output              # Client is generated into a subfolder
  webpack-browser-custom-output               # Client is generated into a subfolder
  yarn3-workspaces-pnp                        # Client is generated into a subfolder
  serverless-framework-lambda-pnpm            # Client is generated into a subfolder
  deno                                        # Client is generated into a subfolder
  # custom output
  jest-with-multiple-generators               # No generated Client locally in default path, both Clients have custom `output`
  netlify-cli                                 # Client is generated into `../functions/generated/client` via use of `output`
  # other
  vercel-with-redwood                         # Yarn workspace with prisma generated in ./api
  firebase-functions                          # No local project at expected location (but in `functions` subfolder)
  studio                                      # TODO: No generated Client in `node_modules/.prisma/client/`
)

case "${skipped_projects[@]}" in  *$2*)
  echo "Skipping as $2 is present in skipped_projects"
  exit 0
  ;;
esac

# Check to see if the env var "PRISMA_CLIENT_ENGINE_TYPE" is set if not then exit
if [ -z "$PRISMA_CLIENT_ENGINE_TYPE" ]; then
  echo "No PRISMA_CLIENT_ENGINE_TYPE set, so exiting."
  exit 1
else
  echo "Using env(PRISMA_CLIENT_ENGINE_TYPE): $PRISMA_CLIENT_ENGINE_TYPE"
  CLIENT_ENGINE_TYPE=$PRISMA_CLIENT_ENGINE_TYPE
fi

# Identify OS
case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    os_name=linux
    ;;
  darwin*)
    os_name=osx
    ;;
  msys*)
    os_name=windows
    ;;
  *)
    os_name=windows
    ;;
esac

os_architecture=$(uname -m)

echo "Assumed OS: $os_name"
echo "Architecture: $os_architecture"
echo "CLIENT_ENGINE_TYPE == $CLIENT_ENGINE_TYPE"

GENERATED_CLIENT=$(node -e "
  console.log(
    path.dirname(require.resolve('.prisma/client/package.json', {
      paths: [path.dirname(require.resolve('@prisma/client/package.json'))]
    }))
  )
")

if [ $CLIENT_ENGINE_TYPE == "binary" ]; then
  echo "Binary: Enabled"
  case $os_name in
    linux)
      if [ "$os_architecture" = "aarch64" ]; then
        qe_location="$GENERATED_CLIENT/query-engine-linux-arm64-openssl-3.0.x"
      else
        qe_location="$GENERATED_CLIENT/query-engine-debian-openssl-1.1.x"
      fi
      ;;
    osx)
      if [ "$os_architecture" = "arm64" ]; then
        qe_location="$GENERATED_CLIENT/query-engine-darwin-arm64"
      else
        qe_location="$GENERATED_CLIENT/query-engine-darwin"
      fi
      ;;
    windows)
      qe_location="$GENERATED_CLIENT\query-engine-windows.exe"
      ;;
  esac
elif [ $CLIENT_ENGINE_TYPE == "library" ]; then
  echo "Library: Enabled"
  case $os_name in
    linux)
      if [ "$os_architecture" = "aarch64" ]; then
        qe_location="$GENERATED_CLIENT/libquery_engine-linux-arm64-openssl-3.0.x.so.node"
      else
        qe_location="$GENERATED_CLIENT/libquery_engine-debian-openssl-1.1.x.so.node"
      fi
      ;;
    osx)
      if [ "$os_architecture" = "arm64" ]; then
        qe_location="$GENERATED_CLIENT/libquery_engine-darwin-arm64.dylib.node"
      else
        qe_location="$GENERATED_CLIENT/libquery_engine-darwin.dylib.node"
      fi
      ;;
    windows*)
      qe_location="$GENERATED_CLIENT\query_engine-windows.dll.node"
      ;;
    *)
      os_name=notset
      ;;
  esac
elif [ $CLIENT_ENGINE_TYPE == "wasm" ]; then
  echo "WasmEngine: Enabled"
  case $os_name in
    linux)
      qe_location="$GENERATED_CLIENT/query_engine_bg.wasm"
      ;;
    osx)
      qe_location="$GENERATED_CLIENT/query_engine_bg.wasm"
      ;;
    windows*)
      qe_location="$GENERATED_CLIENT\query_engine_bg.wasm"
      ;;
    *)
      os_name=notset
      ;;
  esac
elif [ $CLIENT_ENGINE_TYPE == "<accelerate>" ]; then
  echo "Accelerate: Enabled"
else
  echo "❌ CLIENT_ENGINE_TYPE was not set"
  exit 1
fi

# Actually check for file
if [ $CLIENT_ENGINE_TYPE == "<accelerate>" ]; then
  echo "✔ Data Proxy has no Query Engine" # TODO: actually check that there isn't one
elif [ -f "$qe_location" ]; then
  echo "✔ Correct Query Engine exists at ${qe_location}"
else
  echo "❌ Could not find Query Engine in ${qe_location} when using ${os_name}"
  echo "$ ls $GENERATED_CLIENT"
  ls $GENERATED_CLIENT
  exit 1
fi

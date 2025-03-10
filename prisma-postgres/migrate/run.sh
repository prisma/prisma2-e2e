#!/bin/sh

set -eu

pnpm install
pnpm prisma migrate reset --force

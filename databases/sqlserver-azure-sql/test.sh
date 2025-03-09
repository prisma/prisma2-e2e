#!/bin/sh

set -eux

export DEBUG=*

pnpm test

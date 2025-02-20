# syntax=docker/dockerfile:1

FROM node:lts-bullseye-slim

WORKDIR /usr/src/app
COPY --from=app . ./
COPY --from=utils . ./

COPY client-cert.pem .
COPY client-key.pem .
COPY server-ca.pem .
COPY client-identity.p12 .

# Update system dependencies
RUN apt-get update -y

# expected target architecture, retrieved by `uname -m`
ARG EXPECTED_UNAME_ARCH="x86_64"
ENV EXPECTED_UNAME_ARCH=$EXPECTED_UNAME_ARCH
RUN ./uname.sh

# Only OpenSSL 1.1 is expected to be on this system
RUN ldconfig -p | grep ssl | sed "s/.*=>\s*//"
RUN if [ ! -e /usr/lib/${EXPECTED_UNAME_ARCH}-linux-gnu/libssl.so.1.1* ]; then echo "OpenSSL 1.1 not found in /usr/lib/${EXPECTED_UNAME_ARCH}-linux-gnu/libssl.so.1.1*"; exit 1; fi
RUN if [ -e /usr/lib/${EXPECTED_UNAME_ARCH}-linux-gnu/libssl.so.3* ]; then echo "OpenSSL 3 must not be installed (found in /usr/lib/${EXPECTED_UNAME_ARCH}-linux-gnu/libssl.so.3*)"; exit 1; fi

# We are testing the case where OpenSSL versions mismatch
RUN if ! node -e 'if (process.versions.openssl.split(".")[0] < 3) process.exit(1)'; then \
      echo "Node.js must be compiled with OpenSSL 3.0 or newer for this test"; \
      exit 1; \
    fi

# expected target platform for Prisma, retrieved by `prisma -v`
ARG EXPECTED_PRISMA_TARGET_PLATFORM="debian-openssl-1.1.x"
ARG PRISMA_ENGINES_MIRROR
ARG PRISMA_CLIENT_ENGINE_TYPE
ARG PRISMA_CLI_QUERY_ENGINE_TYPE
ARG CI
ARG DEBUG
ARG PRISMA_TELEMETRY_INFORMATION

ENV PRISMA_ENGINES_MIRROR=$PRISMA_ENGINES_MIRROR
ENV PRISMA_CLIENT_ENGINE_TYPE=$PRISMA_CLIENT_ENGINE_TYPE
ENV PRISMA_CLI_QUERY_ENGINE_TYPE=$PRISMA_CLI_QUERY_ENGINE_TYPE
ENV CI=$CI
ENV DEBUG=$DEBUG
ENV PRISMA_TELEMETRY_INFORMATION=$PRISMA_TELEMETRY_INFORMATION
ENV EXPECTED_PRISMA_TARGET_PLATFORM=$EXPECTED_PRISMA_TARGET_PLATFORM

RUN npm i -g pnpm@8
RUN pnpm install
RUN ./version.sh
RUN pnpm prisma generate

CMD node server.js
EXPOSE 3000

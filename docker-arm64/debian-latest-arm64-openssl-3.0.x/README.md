# OS support: debian-latest-arm64-openssl-3.0.x

- Base Docker image: `arm64v8/node:lts-slim`
- OS: Linux Debian (latest)
- Arch: arm64 (aarch64)
- OpenSSL location: `/usr/lib/aarch64-linux-gnu/libssl.so.3`
- Binary target: `linux-arm64-openssl-3.0.x`

`node:lts-slim` ships with Debian Bookworm, and no longer ships `openssl` by default.
We've installed `openssl-3.0.x` via `apt-get install openssl`.

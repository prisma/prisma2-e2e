# OS support: fail-debian-buster-amd64-openssl-1.1.x

- Base Docker image: `node:lts-buster-slim`
- OS: Linux Debian Buster
- Arch: amd64 (x86_64)
- OpenSSL location: not found
- Binary target: `debian-openssl-1.1.x`

This Docker image doesn't come with any `openssl` version installed.
Running `prisma` -v will fail with:

```sh
Error: Unable to require(`/usr/src/app/node_modules/@prisma/engines/libquery_engine-debian-openssl-1.1.x.so.node`)
  libssl.so.1.1: cannot open shared object file: No such file or directory
```

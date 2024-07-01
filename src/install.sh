#! /bin/bash

set -eux
set -o pipefail

apk update

# install required libs
apk add curl
apk add gnupg
apk add openssl
apk add sqlite

# install go-cron
curl -L https://github.com/ivoronin/go-cron/releases/download/v0.0.5/go-cron_0.0.5_linux_${TARGETARCH}.tar.gz -O
tar xvf go-cron_0.0.5_linux_${TARGETARCH}.tar.gz
rm go-cron_0.0.5_linux_${TARGETARCH}.tar.gz
mv go-cron /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron

# cleanup
rm -rf /var/cache/apk/*

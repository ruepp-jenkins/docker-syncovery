#!/bin/bash
set -e
echo "Install packages"

apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    libcrypto++8 \
    libsmbclient \
    libssl-dev \
    openssh-client \
    openssl \
    sqlite3 \
    tzdata

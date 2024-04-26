#!/bin/bash
set -e
echo "Preparing syncovery installation"

mkdir -p /tmp
mkdir -p /config
mkdir -p /syncovery

# extract package
tar -xf /tmp/syncovery.tar.gz --directory /syncovery

# finalize
chmod +x /syncovery/SyncoveryCL

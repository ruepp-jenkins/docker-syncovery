#!/bin/bash
set -e
echo "Cleanup"

apt-get autoclean
apt-get autoremove -y

rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /build

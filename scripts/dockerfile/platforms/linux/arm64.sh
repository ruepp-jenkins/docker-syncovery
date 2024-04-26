#!/bin/bash
set -e
echo "Run arm64 tasks"

# download syncovery
curl -sS -o /tmp/syncovery.tar.gz ${SYNCOVERY_ARM64_DOWNLOADLINK}

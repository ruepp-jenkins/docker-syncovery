#!/bin/bash
set -e
echo "Run amd64 tasks"

# download syncovery
curl -sS -o /tmp/syncovery.tar.gz ${SYNCOVERY_AMD64_DOWNLOADLINK}

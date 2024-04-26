#!/bin/bash
set -e
echo "Cleanup docker"

docker buildx prune -a -f

#!/bin/bash
set -e
echo "Starting build workflow"

scripts/docker_initialize.sh
. scripts/syncovery.sh

# run build
echo "Building image:  ${IMAGE_FULLNAME}"
docker buildx build \
    --build-arg SYNCOVERY_AMD64_DOWNLOADLINK=${SYNCOVERY_AMD64_DOWNLOADLINK} \
    --build-arg SYNCOVERY_ARM64_DOWNLOADLINK=${SYNCOVERY_ARM64_DOWNLOADLINK} \
    --platform linux/amd64,linux/arm64 \
    -t ${IMAGE_FULLNAME}:ubuntu-v${SYNCOVERY_MAIN_VERSION} \
    -t ${IMAGE_FULLNAME}:ubuntu-${SYNCOVERY_VERSION} \
    -t ${IMAGE_FULLNAME}:${SYNCOVERY_MAIN_VERSION} \
    -t ${IMAGE_FULLNAME}:${SYNCOVERY_VERSION} \
    -t ${IMAGE_FULLNAME}:latest \
    --push .

# cleanup
scripts/docker_cleanup.sh

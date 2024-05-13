#!/bin/bash
set -e
echo "Starting build workflow"

scripts/docker_initialize.sh
. scripts/syncovery.sh

# run build
echo "[${BRANCH_NAME}] Building images: ${IMAGE_FULLNAME}"
if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
then
    docker buildx build \
        --build-arg SYNCOVERY_AMD64_DOWNLOADLINK=${SYNCOVERY_AMD64_DOWNLOADLINK} \
        --build-arg SYNCOVERY_ARM64_DOWNLOADLINK=${SYNCOVERY_ARM64_DOWNLOADLINK} \
        --platform linux/amd64,linux/arm64 \
        -t ${IMAGE_FULLNAME}:ubuntu-v${SYNCOVERY_MAIN_VERSION} \
        -t ${IMAGE_FULLNAME}:ubuntu-${SYNCOVERY_VERSION} \
        -t ${IMAGE_FULLNAME}:ubuntu-latest \
        -t ${IMAGE_FULLNAME}:${SYNCOVERY_MAIN_VERSION} \
        -t ${IMAGE_FULLNAME}:${SYNCOVERY_VERSION} \
        -t ${IMAGE_FULLNAME}:latest \
        --push .
else
    docker buildx build \
        --build-arg SYNCOVERY_AMD64_DOWNLOADLINK=${SYNCOVERY_AMD64_DOWNLOADLINK} \
        --build-arg SYNCOVERY_ARM64_DOWNLOADLINK=${SYNCOVERY_ARM64_DOWNLOADLINK} \
        --platform linux/amd64 \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME}-ubuntu-v${SYNCOVERY_MAIN_VERSION} \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME}-ubuntu-${SYNCOVERY_VERSION} \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME}-${SYNCOVERY_MAIN_VERSION} \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME}-${SYNCOVERY_VERSION} \
        --push .
fi

# cleanup
scripts/docker_cleanup.sh

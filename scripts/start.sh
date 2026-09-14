#!/bin/bash
set -e
echo "Starting build workflow"

if [ -z "${IMAGE_FULLNAMES// }" ]
then
    echo "IMAGE_FULLNAMES is empty - no image name to push to"
    exit 1
fi

scripts/docker_initialize.sh
. scripts/syncovery.sh

# collect the tags for every image name, all of them are pushed by one single build
TAGS=()
for IMAGE_FULLNAME in ${IMAGE_FULLNAMES}
do
    if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
    then
        TAGS+=(
            -t "${IMAGE_FULLNAME}:ubuntu-v${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_FULLNAME}:ubuntu-${SYNCOVERY_VERSION}"
            -t "${IMAGE_FULLNAME}:ubuntu-latest"
            -t "${IMAGE_FULLNAME}:${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_FULLNAME}:${SYNCOVERY_VERSION}"
            -t "${IMAGE_FULLNAME}:latest"
        )
    else
        TAGS+=(
            -t "${IMAGE_FULLNAME}-test:${BRANCH_NAME}-ubuntu-v${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_FULLNAME}-test:${BRANCH_NAME}-ubuntu-${SYNCOVERY_VERSION}"
            -t "${IMAGE_FULLNAME}-test:${BRANCH_NAME}-${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_FULLNAME}-test:${BRANCH_NAME}-${SYNCOVERY_VERSION}"
        )
    fi
done

# run build
echo "[${BRANCH_NAME}] Building images: ${IMAGE_FULLNAMES}"
docker buildx build \
    --build-arg SYNCOVERY_AMD64_DOWNLOADLINK=${SYNCOVERY_AMD64_DOWNLOADLINK} \
    --build-arg SYNCOVERY_ARM64_DOWNLOADLINK=${SYNCOVERY_ARM64_DOWNLOADLINK} \
    --platform linux/amd64,linux/arm64 \
    "${TAGS[@]}" \
    --pull \
    --push .

# cleanup
scripts/docker_cleanup.sh

#!/bin/bash
set -e
echo "Starting build workflow"

# space separated list of names, IMAGE_FULLNAME is the old single name variable
# and still accepted so a replayed run with an older Jenkinsfile keeps working
# (globbing is disabled while splitting, a name must never match a file)
set -f
IMAGE_NAMES=(${IMAGE_FULLNAMES:-${IMAGE_FULLNAME}})
set +f
if [ ${#IMAGE_NAMES[@]} -eq 0 ]
then
    echo "IMAGE_FULLNAMES is empty - no image name to push to"
    exit 1
fi

scripts/docker_initialize.sh
. scripts/syncovery.sh

# collect the tags for every image name, all of them are pushed by one single build
TAGS=()
for IMAGE_NAME in "${IMAGE_NAMES[@]}"
do
    if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
    then
        TAGS+=(
            -t "${IMAGE_NAME}:ubuntu-v${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_NAME}:ubuntu-${SYNCOVERY_VERSION}"
            -t "${IMAGE_NAME}:ubuntu-latest"
            -t "${IMAGE_NAME}:${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_NAME}:${SYNCOVERY_VERSION}"
            -t "${IMAGE_NAME}:latest"
        )
    else
        TAGS+=(
            -t "${IMAGE_NAME}-test:${BRANCH_NAME}-ubuntu-v${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_NAME}-test:${BRANCH_NAME}-ubuntu-${SYNCOVERY_VERSION}"
            -t "${IMAGE_NAME}-test:${BRANCH_NAME}-${SYNCOVERY_MAIN_VERSION}"
            -t "${IMAGE_NAME}-test:${BRANCH_NAME}-${SYNCOVERY_VERSION}"
        )
    fi
done

# run build
echo "[${BRANCH_NAME}] Building images: ${IMAGE_NAMES[*]}"
docker buildx build \
    --build-arg "SYNCOVERY_AMD64_DOWNLOADLINK=${SYNCOVERY_AMD64_DOWNLOADLINK}" \
    --build-arg "SYNCOVERY_ARM64_DOWNLOADLINK=${SYNCOVERY_ARM64_DOWNLOADLINK}" \
    --platform linux/amd64,linux/arm64 \
    "${TAGS[@]}" \
    --pull \
    --push .

# cleanup
scripts/docker_cleanup.sh

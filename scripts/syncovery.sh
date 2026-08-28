#!/bin/bash
set -e

AMD64_VERSION=$(curl -fsS 'https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt')
ARM64_VERSION=$(curl -fsS 'https://www.syncovery.com/linver_aarch64-Web.tar.gz.txt')

# extract info based on line numbers
export SYNCOVERY_VERSION=$(echo "${AMD64_VERSION}" | awk 'NR==5')
export SYNCOVERY_AMD64_DOWNLOADLINK=$(echo "${AMD64_VERSION}" | awk 'NR==3')
export SYNCOVERY_ARM64_DOWNLOADLINK=$(echo "${ARM64_VERSION}" | awk 'NR==3')

# get the main version - this also makes sure we really got a version and not
# something unexpected (all of them end up as docker tags)
if [[ "${SYNCOVERY_VERSION}" =~ ^([0-9]+)(\.[0-9]+)+$ ]]; then
    export SYNCOVERY_MAIN_VERSION="${BASH_REMATCH[1]}"
else
    echo "Could not determine syncovery version - got '${SYNCOVERY_VERSION}'" >&2
    exit 1
fi

# the download links are used as build arguments - make sure they are links
for LINK in "${SYNCOVERY_AMD64_DOWNLOADLINK}" "${SYNCOVERY_ARM64_DOWNLOADLINK}"; do
    if [[ "${LINK}" != https://* ]]; then
        echo "Could not determine syncovery download link - got '${LINK}'" >&2
        exit 1
    fi
done

printenv | grep 'SYNCOVERY' | sort -h

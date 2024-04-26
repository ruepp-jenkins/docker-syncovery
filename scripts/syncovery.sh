#!/bin/bash
set -e

AMD64_VERSION=$(curl -s 'https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt' 2> /dev/null)
ARM64_VERSION=$(curl -s 'https://www.syncovery.com/linver_aarch64-Web.tar.gz.txt' 2> /dev/null)

# extract info based on line numbers
export SYNCOVERY_VERSION=$(echo "${AMD64_VERSION}" | awk 'NR==5')
export SYNCOVERY_AMD64_DOWNLOADLINK=$(echo "${AMD64_VERSION}" | awk 'NR==3')
export SYNCOVERY_ARM64_DOWNLOADLINK=$(echo "${ARM64_VERSION}" | awk 'NR==3')

# get main version
if [[ $AMD64_VERSION =~ $REGEX ]]; then
    export SYNCOVERY_MAIN_VERSION=$(echo "${SYNCOVERY_VERSION}" | cut -d'.' -f1)
else
    exit 1
fi

printenv | grep 'SYNCOVERY' | sort -h

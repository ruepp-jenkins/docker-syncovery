#!/bin/bash
set -e
echo "Start build process"

# avoid some dialogs
export DEBIAN_FRONTEND=noninteractive

find /build -type f -iname "*.sh" -exec chmod +x {} \;

# preparations
/build/apt-get.sh
/build/tzdata.sh

# determinate build platform
. /build/platforms/${TARGETPLATFORM}.sh

# install syncovery
/build/syncovery.sh

# add persisting
mkdir -p /docker
mv /build/files/start.sh /docker/

# cleanup
/build/cleanup.sh

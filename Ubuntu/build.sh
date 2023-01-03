#!/usr/bin/env bash

wget -O linver_x86_64-Web.tar.gz.txt      https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt      2>/dev/null
wget -O linver_guardian_x86_64.tar.gz.txt https://www.syncovery.com/linver_guardian_x86_64.tar.gz.txt 2>/dev/null
wget -O linver_rs_x86_64.tar.gz.txt       https://www.syncovery.com/linver_rs_x86_64.tar.gz.txt       2>/dev/null

mapfile -t syncovery <linver_x86_64-Web.tar.gz.txt
mapfile -t guardian  <linver_guardian_x86_64.tar.gz.txt
mapfile -t remote    <linver_rs_x86_64.tar.gz.txt

SYNCOVERY_DOWNLOADLINK=${syncovery[2]}
VERSION=${syncovery[4]}
GUARD_DOWNLOADLINK=${guardian[2]}
REMOTE_DOWNLOADLINK=${remote[2]}

docker build . -t docker_syncovery:${VERSION}-ubuntu \
  --build-arg SYNCOVERY_DOWNLOADLINK=${SYNCOVERY_DOWNLOADLINK} \
  --build-arg GUARD_DOWNLOADLINK=${GUARD_DOWNLOADLINK} \
  --build-arg REMOTE_DOWNLOADLINK=${REMOTE_DOWNLOADLINK}

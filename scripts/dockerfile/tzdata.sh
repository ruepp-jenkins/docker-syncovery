#!/bin/bash
set -e
echo "Configure tzdata"

ln -fs /usr/share/zoneinfo/$TZ /etc/localtime 
dpkg-reconfigure -f noninteractive tzdata

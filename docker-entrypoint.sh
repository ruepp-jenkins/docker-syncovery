#!/bin/bash

if [ ! -f /config/.Syncovery/Syncovery.cfg ]; then
    echo "Setting configuration setting for webserver"
    /syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0
fi

echo "OS Date: $(date)"
echo "Starting Server"
/syncovery/SyncoveryCL
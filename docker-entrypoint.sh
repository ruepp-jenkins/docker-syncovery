#!/bin/bash

if [ ! -f /config/.Syncovery/Syncovery.cfg ]; then
    echo "Setting configuration setting for webserver"
    exec /syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0
fi

echo "Starting Server"
exec /syncovery/SyncoveryCL
#!/bin/bash

echo "Setting configuration setting for webserver"
exec /syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0

echo "Starting Server"
exec /SyncoveryCL
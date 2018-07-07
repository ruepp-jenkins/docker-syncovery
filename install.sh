#!/bin/bash

TMP="$(mktemp)"
wget -O "$TMP" 'https://www.syncovery.com/release/SyncoveryCL-x86_64-7.98c-Web.tar.gz'
tar -xvf "$TMP" --directory /syncovery
rm -f "$TMP"
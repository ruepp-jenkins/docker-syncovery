#!/bin/bash
# Ensure a persistent machine-id exists and is written to the expected locations.
# Mount /machine-id as a volume to make the ID survive container restarts/recreations.

MACHINE_ID_DIR="/machine-id"
MACHINE_ID_FILE="${MACHINE_ID_DIR}/machine-id"

mkdir -p "${MACHINE_ID_DIR}"

# Generate a new machine-id if none is persisted yet
if [ ! -s "${MACHINE_ID_FILE}" ]; then
    echo "Generating new machine-id"
    cat /proc/sys/kernel/random/uuid | tr -d '-' > "${MACHINE_ID_FILE}"
fi

MACHINE_ID=$(cat "${MACHINE_ID_FILE}")
echo "Using machine-id: ${MACHINE_ID}"

# Place the id in both expected locations
mkdir -p /var/lib/dbus
echo "${MACHINE_ID}" > /etc/machine-id
echo "${MACHINE_ID}" > /var/lib/dbus/machine-id

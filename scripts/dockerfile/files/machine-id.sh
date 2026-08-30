#!/bin/bash
# Ensure a persistent machine-id exists and is written to the expected locations.
# Mount /machine-id as a volume to make the ID survive container restarts/recreations.

MACHINE_ID_DIR="/machine-id"
MACHINE_ID_FILE="${MACHINE_ID_DIR}/machine-id"

mkdir -p "${MACHINE_ID_DIR}"

# Warn if the id is not stored on a volume of your own. Docker creates an
# anonymous volume on its own (see VOLUME in the Dockerfile) but that one is
# thrown away together with the container, so it counts as "not persisted".
MACHINE_ID_MOUNT=$(awk -v dir="${MACHINE_ID_DIR}" '$5 == dir { print $4 }' /proc/self/mountinfo | tail -1)
MACHINE_ID_VOLUME=$(basename "$(dirname "${MACHINE_ID_MOUNT:-/}")")

if [ -z "${MACHINE_ID_MOUNT}" ] || [[ "${MACHINE_ID_VOLUME}" =~ ^[0-9a-f]{64}$ ]]; then
    echo "WARNING: ${MACHINE_ID_DIR} is not mounted to a volume of your own!"
    echo "WARNING: the machine-id is lost as soon as this container is recreated,"
    echo "WARNING: which invalidates all credentials stored in syncovery."
    echo "WARNING: mount ${MACHINE_ID_DIR} to keep it (see readme)."
fi

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

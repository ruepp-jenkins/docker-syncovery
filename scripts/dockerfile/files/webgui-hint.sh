#!/bin/bash
# Print the addresses the web GUI can be reached at.
#
# Syncovery skips the login when the GUI is opened via localhost / 127.0.0.1.
# Inside a container that detection only half works: the GUI loads but keeps
# asking for the login anyway. Every other address (the container itself, the
# docker host, any domain name - even one resolving to 127.0.0.1) behaves
# normally, so print what can be used instead.

WEBGUI_DEFAULT_PORT=8999
WEBGUI_LOOPDNS="syncovery.c.loopdns.de"
WEBGUI_LOOPDNS_SITE="https://loopdns.de"

# port of the web GUI: environment wins, then the config, then the default.
# Syncovery.cfg is a sqlite database, the port lives in section WEBSERVER as
# "Port1" - opened read only so the running syncovery is not disturbed.
function webgui_port() {
    local config="${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg"
    local port="${SYNCOVERY_SET_WEBPORT}"

    if [ -z "${port}" ] && [ -f "${config}" ]; then
        port=$(sqlite3 "file:${config}?mode=ro" \
            "SELECT d.VALUE FROM DATA d JOIN SECTIONS s ON s.ID = d.SECTIONID \
             WHERE s.SECTIONNAME = 'WEBSERVER' AND d.NAME = 'Port1';" 2>/dev/null)
    fi

    if [[ ! "${port}" =~ ^[0-9]+$ ]]; then
        port="${WEBGUI_DEFAULT_PORT}"
    fi

    echo "${port}"
}

# keep the ipv4 addresses of a list, loopback and duplicates removed
# (written without a {3} interval - mawk does not match those reliably)
function filter_ipv4() {
    awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $0 !~ /^127\./ && !seen[$0]++'
}

# the addresses docker gave this container - it writes one line per network
# into /etc/hosts. stays empty with --network host or --network none.
function container_ips() {
    getent hosts "$(hostname)" 2>/dev/null | awk '{ print $1 }' | filter_ipv4
}

# every address of the network stack, used when docker did not hand out an own
# one (--network host), where the container shares the stack of the host
function host_ips() {
    hostname -I 2>/dev/null | tr ' ' '\n' | filter_ipv4
}

# gateway of the default route - the docker host on a bridge network
function default_gateway() {
    local hex
    hex=$(awk '$2 == "00000000" && $8 == "00000000" { print $3; exit }' /proc/net/route)

    if [ -z "${hex}" ] || [ "${hex}" == "00000000" ]; then
        return
    fi

    # the value is stored as little endian hex, so read it back to front
    printf "%d.%d.%d.%d" "0x${hex:6:2}" "0x${hex:4:2}" "0x${hex:2:2}" "0x${hex:0:2}"
}

function print_url() {
    printf "  %-42s %s\n" "$1" "$2"
}

PORT=$(webgui_port)
mapfile -t IPS < <(container_ips)
IPS_LABEL="(this container)"
GATEWAY=$(default_gateway)

if [ ${#IPS[@]} -eq 0 ]; then
    # without an own address the gateway is not the docker host but whatever
    # router the host itself uses, so do not advertise it
    mapfile -t IPS < <(host_ips)
    IPS_LABEL="(this host)"
    GATEWAY=""
fi

echo "Web GUI addresses:"

for ip in "${IPS[@]}"; do
    print_url "http://${ip}:${PORT}" "${IPS_LABEL}"
done

if [ -n "${GATEWAY}" ]; then
    print_url "http://${GATEWAY}:${PORT}" "(your docker host, needs a published port)"
fi

print_url "http://${WEBGUI_LOOPDNS}:${PORT}" "(public dns name for 127.0.0.1)"

echo "NOTE: syncovery skips the login when the web GUI is opened via localhost or"
echo "NOTE: 127.0.0.1 - inside a container that only half works, the GUI loads but"
echo "NOTE: keeps asking for the login. Use one of the addresses above instead,"
echo "NOTE: any other ip or name works normally - see readme."
echo "NOTE: for a name pointing to another local address than 127.0.0.1 you can"
echo "NOTE: create an account on ${WEBGUI_LOOPDNS_SITE} and add your own entries."

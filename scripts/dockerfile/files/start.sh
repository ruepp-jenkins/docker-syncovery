#!/bin/bash

# initialize trap to forceful stop the bot
trap terminator SIGHUP SIGINT SIGQUIT SIGTERM
function terminator() {
  echo
  echo "Stopping Syncovery $child..."
  kill -TERM "$child" 2>/dev/null
  stop
  echo "Exiting."
}

function stop() {
  /syncovery/SyncoveryCL stop
}

# every environment variable named SYNCOVERY_SET_<setting> is handed over to
# "SyncoveryCL SET" as "/<setting>=<value>" (e.g. SYNCOVERY_SET_WEBPORT=1234 -> /WEBPORT=1234)
function apply_settings() {
  local -a settings=()
  local var name

  # on the very first start the web server has to listen on all interfaces,
  # otherwise the web GUI would not be reachable from outside the container -
  # afterwards the value stored in the config file is left alone
  if [ ! -f ${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg ] && [ -z "${SYNCOVERY_SET_WEBSERVER}" ]; then
    settings+=("/WEBSERVER=0.0.0.0")
  fi

  while IFS= read -r var; do
    name="${var#SYNCOVERY_SET_}"

    if [ -z "${name}" ]; then
      continue
    fi

    settings+=("/${name}=${!var}")
  done < <(compgen -v | grep "^SYNCOVERY_SET_" | sort)

  if [ ${#settings[@]} -eq 0 ]; then
    return
  fi

  echo "Applying syncovery settings:"
  for setting in "${settings[@]}"; do
    # do not print passwords into the container log
    if [[ "${setting^^}" == *PASS* ]]; then
      echo "  ${setting%%=*}=***"
    else
      echo "  ${setting}"
    fi
  done

  /syncovery/SyncoveryCL SET "${settings[@]}"
}

function start() {
  echo "OS Date: $(date)"
  /docker/machine-id.sh
  mkdir -p ${SYNCOVERY_HOME}/.Syncovery
  touch ${SYNCOVERY_HOME}/.Syncovery/WebGUI.log
  
  apply_settings

  echo "Starting Syncovery"
  /syncovery/SyncoveryCL start
}

start
tail -f ${SYNCOVERY_HOME}/.Syncovery/WebGUI.log &

child=$!
wait "$child"

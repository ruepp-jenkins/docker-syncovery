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

function start() {
  echo "OS Date: $(date)"
  mkdir -p ${SYNCOVERY_HOME}/.Syncovery
  touch ${SYNCOVERY_HOME}/.Syncovery/WebGUI.log
  
  if [ ! -f ${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg ]; then
      echo "Setting configuration setting for webserver"
      /syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0
  fi

  echo "Starting Syncovery"
  /syncovery/SyncoveryCL start
}

start
tail -f ${SYNCOVERY_HOME}/.Syncovery/WebGUI.log &

child=$!
wait "$child"

#!/bin/bash
set -x
MM_HOME=/opt/mattermost
MM_CONFIG=${MM_HOME}/config/config.json
MM_CONFIG_ORIG=${MM_HOME}/config.json

function updatejson() {
  set -o nounset
  key=$1
  value=$2
  file=$3
  jq "$key = \"$value\"" $file > ${file}.new
  mv ${file}.new ${file}
  echo "Updated file $file"
  set +o nounset
}

if [[ ! -f $MM_CONFIG ]]; then
  cp -f $MM_CONFIG_ORIG $MM_CONFIG
fi

if [[ "$1" == "mattermost" ]]; then
  if [[ -z $MM_DB_HOST ]]; then echo "MM_DB_HOST not set."; exit 1; fi
  if [[ -z $MM_DB_PORT ]]; then echo "MM_DB_PORT not set."; exit 1; fi
  if [[ -z $MM_DB_USER ]]; then echo "MM_DB_USER not set."; exit 1; fi
  if [[ -z $MM_DB_PASS ]]; then echo "MM_DB_PASS not set."; exit 1; fi
  if [[ -z $MM_DB_NAME ]]; then echo "MM_DB_NAME not set."; exit 1; fi

  echo "Updating mattermost configuration..."
  updatejson ".SqlSettings.DriverName" "postgres" $MM_CONFIG
  updatejson ".SqlSettings.DataSource" "postgres://${MM_DB_USER}:${MM_DB_PASS}@${MM_DB_HOST}:${MM_DB_PORT}/${MM_DB_NAME}?sslmode=disable&connect_timeout=10" $MM_CONFIG
  
  while ! echo | nc -w1 $MM_DB_HOST $MM_DB_PORT > /dev/null 2>&1; do
    echo "Could not connect to database at ${MM_DB_HOST}:${MM_DB_PORT}... Retrying..."
    sleep 1
  done
  
  echo "Starting platform"
  cd ${MM_HOME}
  ./bin/platform
else
  exec "$@"
fi

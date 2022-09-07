#!/bin/bash

set -eou pipefail

# Uncomment this line to see each command for debugging
set -o xtrace

connection_uri=${1:-''}
if [ -z ${connection_uri+x} ]; then
  echo '{"connection_uri": ""}' > connections.json
else
  CONN_URI=$(echo -n $connection_uri | base64 --decode)
  echo '{"connection_uri": "'$CONN_URI'" }' > connections.json
fi

cat connections.json

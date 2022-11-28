#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Packages:
#   apt-get install curl jq
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export RECORDER_PASSWD="my-secret-password"
#
#   bash jibri-start.sh
# ------------------------------------------------------------------------------

JSON=$(cat <<EOF
{
  "callParams": {
    "callUrlInfo": {
      "baseUrl": "$JITSI_HOST",
      "callName": "$JITSI_ROOM"
    }
  },
  "componentParams": {
    "type": "JIBRI",
    "region": "default-region",
    "environment": "default-env"
  },
  "metadata": {
    "sinkType": "FILE"
  },
  "callLoginParams": {
    "domain": "recorder.jitsi.nordeck.corp",
    "username": "recorder",
    "password": "$RECORDER_PASSWD"
  }
}
EOF
)

curl -sk \
  -X POST https://jitsi.nordeck.corp/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

#!/usr/bin/bash
set -e

# -----------------------------------------------------------------------------
# Packages:
#   apt-get install curl jq
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export PROSODY_RECORDER_PASSWD="recorder-password"
#
#   bash recording-start.sh
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
    "password": "$PROSODY_RECORDER_PASSWD"
  }
}
EOF
)

curl -sk \
  -X POST $JITSI_HOST/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

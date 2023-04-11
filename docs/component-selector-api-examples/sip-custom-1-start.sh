#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# Warning:
#   This script only works for jibri newer than 8.0-140-gccc7278-1
#
# Packages:
#   apt-get install curl jq
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export TOKEN="token-value-..."
#
#   bash sip-custom-1-start.sh <DISPLAY_NAME>
#
# Example:
#   bash sip-custom-1-start.sh "cisco"
# ------------------------------------------------------------------------------

DISPLAY_NAME="$1"

JSON=$(cat <<EOF
{
  "callParams": {
    "callUrlInfo": {
      "baseUrl": "$JITSI_HOST",
      "callName": "$JITSI_ROOM?jwt=$TOKEN"
    }
  },
  "componentParams": {
    "type": "SIP-JIBRI",
    "region": "default-region",
    "environment": "default-env"
  },
  "metadata": {
    "sipClientParams": {
      "sipAddress": "sip:jibri@127.0.0.1",
      "displayName": "$DISPLAY_NAME",
      "autoAnswer": true
    }
  }
}
EOF
)

curl -sk \
  -X POST https://jitsi.nordeck.corp/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# Warning:
#   This script doesn't work because there is an issue on the server side.
#
# Packages:
#   apt-get install curl jq
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export SIP_PASSWD="my-secret-password"
#
#   bash sip-inbound-start.sh <CALLEE>
#
# Example:
#   bash sip-inbound-start.sh "sip:1001@freeswitch.mydomain.corp"
# ------------------------------------------------------------------------------

CALLER="$1"

JSON=$(cat <<EOF
{
  "callParams": {
    "callUrlInfo": {
      "baseUrl": "$JITSI_HOST",
      "callName": "$JITSI_ROOM"
    }
  },
  "componentParams": {
    "type": "SIP-JIBRI",
    "region": "default-region",
    "environment": "default-env"
  },
  "metadata": {
    "sipClientParams": {
      "autoAnswer": true,
      "sipAddress": "$CALLER",
      "displayName": "Caller"
    }
  },
  "callLoginParams": {
    "domain": "sip.jitsi.nordeck.corp",
    "username": "sip",
    "password": "$SIP_PASSWD"
  }
}
EOF
)

curl -sk \
  -X POST https://jitsi.nordeck.corp/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

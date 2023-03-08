#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# Packages:
#   apt-get install curl jq
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export PROSODY_SIP_PASSWD="my-secret-password"
#   export CALLER_USERNAME="1009@sip.nordeck.corp"
#   export CALLER_PASSWORD="1234"
#   export SIP_PROXY="sip:sip.nordeck.corp;transport=udp;hide"
#
#   bash sip-outbound-start.sh <CALLEE>
#
# Example:
#   bash sip-outbound-start.sh "sip:1001@sip.nordeck.corp"
# ------------------------------------------------------------------------------

CALLEE="$1"

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
      "userName": "$CALLER_USERNAME",
      "password": "$CALLER_PASSWORD",
      "sipAddress": "$CALLEE",
      "displayName": "Caller",
      "proxy": "$SIP_PROXY",
      "autoAnswer": false
    }
  },
  "callLoginParams": {
    "domain": "sip.jitsi.nordeck.corp",
    "username": "sip",
    "password": "$PROSODY_SIP_PASSWD"
  }
}
EOF
)

curl -sk \
  -X POST https://jitsi.nordeck.corp/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

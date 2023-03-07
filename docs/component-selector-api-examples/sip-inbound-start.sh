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
#   export PROSODY_SIP_PASSWD="my-secret-password"
#   export INVITER_USERNAME="1009@sip.nordeck.corp"
#   export INVITER_PASSWORD="1234"
#   export INVITER_CONTACT="<sip:1009@172.17.17.36:5060;transport=udp>"
#
#   bash sip-inbound-start.sh <INVITEE>
#
# Example:
#   bash sip-inbound-start.sh "sip:1001@sip.nordeck.corp"
# ------------------------------------------------------------------------------

INVITEE="$1"

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
      "userName": "$INVITER_USERNAME",
      "password": "$INVITER_PASSWORD",
      "contact": "$INVITER_CONTACT",
      "sipAddress": "$INVITEE",
      "displayName": "Caller",
      "autoAnswer": true
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

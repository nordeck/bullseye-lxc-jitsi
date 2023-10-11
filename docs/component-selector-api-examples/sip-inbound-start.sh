#!/usr/bin/bash
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
DISPLAY_NAME=$(echo $INVITEE | cut -d: -f2 | cut -d@ -f1)

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
      "displayName": "$DISPLAY_NAME",
      "autoAnswer": true
    }
  }
}
EOF
)

curl -sk \
  -X POST $JITSI_HOST/jitsi-component-selector/sessions/start \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

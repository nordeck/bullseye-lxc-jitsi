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
#   #export INVITER_CONTACT="<sip:1009@192.168.1.1>"
#   export PRIVATE_KEY_FILE="./signal.key"
#
#   bash sip-inbound-start.sh <INVITEE>
#
# Example:
#   bash sip-inbound-start.sh "sip:1001@sip.nordeck.corp"
# ------------------------------------------------------------------------------
[[ -z "$PRIVATE_KEY_FILE" ]] && PRIVATE_KEY_FILE="./signal.key" || true

INVITEE="$1"
DISPLAY_NAME=$(echo $INVITEE | cut -d: -f2 | cut -d@ -f1)
AUTO_ANSWER_TIMEOUT=30

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
      "autoAnswer": true,
      "autoAnswerTimer": $AUTO_ANSWER_TIMEOUT
    }
  }
}
EOF
)

# generate the bearer token
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT","kid":"jitsi/signal"}' | \
  base64 | tr '+/' '-_' | tr -d '=\n')
PAYLOAD=$(echo -n '{"iss":"signal","aud":"jitsi-component-selector"}' | \
  base64 | tr '+/' '-_' | tr -d '=\n')
SIGN=$(echo -n "$HEADER.$PAYLOAD" | \
  openssl dgst -sha256 -binary -sign $PRIVATE_KEY_FILE | \
  openssl enc -base64 | tr '+/' '-_' | tr -d '=\n')
TOKEN="$HEADER.$PAYLOAD.$SIGN"

curl -sk \
  -X POST $JITSI_HOST/jitsi-component-selector/sessions/start \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON | jq '.'

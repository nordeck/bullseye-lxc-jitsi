#!/usr/bin/bash
set -e

# -----------------------------------------------------------------------------
# Packages:
#   apt-get install curl
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#
#   bash sip-outbound-stop.sh <SESSION_ID>
# ------------------------------------------------------------------------------

SESSION_ID="$1"

JSON=$(cat <<EOF
{
  "sessionId": "$SESSION_ID",
  "callParams": {
    "callUrlInfo": {
      "baseUrl": "$JITSI_HOST",
      "callName": "$JITSI_ROOM"
    }
  }
}
EOF
)

curl -sk \
  -X POST $JITSI_HOST/jitsi-component-selector/sessions/stop \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON

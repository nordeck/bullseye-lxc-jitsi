#!/usr/bin/bash
set -e

# -----------------------------------------------------------------------------
# Packages:
#   apt-get install curl
#
# Usage:
#   export JITSI_HOST="https://jitsi.nordeck.corp"
#   export JITSI_ROOM="myroom"
#   export PRIVATE_KEY_FILE="./signal.key"
#
#   bash sip-inbound-stop.sh <SESSION_ID>
# ------------------------------------------------------------------------------
[[ -z "$PRIVATE_KEY_FILE" ]] && PRIVATE_KEY_FILE="./signal.key" || true

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
  -X POST $JITSI_HOST/jitsi-component-selector/sessions/stop \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/json" \
  --data @- <<< $JSON

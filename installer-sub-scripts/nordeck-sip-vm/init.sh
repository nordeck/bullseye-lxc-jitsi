#!/bin/bash

# ------------------------------------------------------------------------------
# INIT.SH
# ------------------------------------------------------------------------------
set -e

# ------------------------------------------------------------------------------
# CHECKS
# ------------------------------------------------------------------------------
echo

[[ -z "$JITSI_FQDN" ]] && echo "JITSI_FQDN not found" && false
[[ -z "$(dig +short $JITSI_FQDN)" ]] && echo "unresolvable JITSI_FQDN" && false
[[ -z "$JIBRI_PASSWD" ]] && echo "JIBRI_PASSWD not found" && false
[[ -z "$JIBRI_SIP_PASSWD" ]] && echo "JIBRI_SIP_PASSWD not found" && false

true

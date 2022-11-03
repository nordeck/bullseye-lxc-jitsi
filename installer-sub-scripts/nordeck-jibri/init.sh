#!/bin/bash

# ------------------------------------------------------------------------------
# INIT.SH
# ------------------------------------------------------------------------------
set -e

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
cd $INSTALLER

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_INIT" = true ]] && exit

# ------------------------------------------------------------------------------
# CHECKS
# ------------------------------------------------------------------------------
echo

[[ -z "$JITSI_FQDN" ]] && echo "JITSI_FQDN not found" && false
[[ -z "$(dig +short $JITSI_FQDN)" ]] && echo "unresolvable JITSI_FQDN" && false
[[ -z "$JIBRI_PASSWD" ]] && echo "JIBRI_PASSWD not found" && false
[[ -z "$RECORDER_PASSWD" ]] && echo "RECORDER_PASSWD not found" && false

# ------------------------------------------------------------------------------
# INSTALLER CONFIGURATION
# ------------------------------------------------------------------------------
cp -ap ../nordeck-base/* .

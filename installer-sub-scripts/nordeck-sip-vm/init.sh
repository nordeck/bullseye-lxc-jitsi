#!/bin/bash

# ------------------------------------------------------------------------------
# INIT.SH
# ------------------------------------------------------------------------------
set -e

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
echo
echo "-------------------------- CHECKING -------------------------"

# ------------------------------------------------------------------------------
# CHECKS
# ------------------------------------------------------------------------------
echo

[[ -z "$JITSI_FQDN" ]] && echo "JITSI_FQDN not found" && false
[[ -z "$(dig +short $JITSI_FQDN)" ]] && echo "unresolvable JITSI_FQDN" && false
[[ -z "$JIBRI_PASSWD" ]] && echo "JIBRI_PASSWD not found" && false
[[ -z "$JIBRI_SIP_PASSWD" ]] && echo "JIBRI_SIP_PASSWD not found" && false

KERNEL=$(apt-get --simulate dist-upgrade | grep "Inst linux-image-" || true)
if [[ -n "$KERNEL" ]]; then
    cat <<EOF
Your kernel is not up-to-date on the target machine. Please upgrade the kernel
on the target machine first, reboot it by using the new kernel and then try
again.

$KERNEL
EOF
    exit 1
fi

# always return true
true

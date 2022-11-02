# ------------------------------------------------------------------------------
# HOST.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="nordeck-jitsi-host"
cd $MACHINES/$MACH

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_JITSI_HOST" = true ]] && exit

echo
echo "-------------------------- $MACH --------------------------"

# ------------------------------------------------------------------------------
# SSH FOLDER
# ------------------------------------------------------------------------------
mkdir -p /root/.ssh
chmod 700 /root/.ssh

cp root/.ssh/jms-config /root/.ssh/

# ------------------------------------------------------------------------------
# TOOLS
# ------------------------------------------------------------------------------
cp usr/local/sbin/set-letsencrypt-cert /usr/local/sbin/
chmod 744 /usr/local/sbin/set-letsencrypt-cert

cp usr/local/sbin/add-jvb-node /usr/local/sbin/
chmod 744 /usr/local/sbin/add-jvb-node
cp usr/local/sbin/add-jibri-node /usr/local/sbin/
chmod 744 /usr/local/sbin/add-jibri-node
#cp usr/local/sbin/add-sip-node /usr/local/sbin/
#chmod 744 /usr/local/sbin/add-sip-node

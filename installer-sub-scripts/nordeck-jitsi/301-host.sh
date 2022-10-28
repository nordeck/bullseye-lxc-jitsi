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

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

apt-get $APT_PROXY -y install kmod alsa-utils

# ------------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# ------------------------------------------------------------------------------
# snd_aloop
[ -z "$(egrep '^snd_aloop' /etc/modules)" ] && \
    cat etc/modules.custom.alsa >>/etc/modules

cp etc/modprobe.d/alsa-loopback.conf /etc/modprobe.d/

rmmod -f snd_aloop || true
modprobe snd_aloop || true
[[ "$DONT_CHECK_SND_ALOOP" = true ]] || [[ -n "$(lsmod | ack snd_aloop)" ]]

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

#cp usr/local/sbin/add-jvb-node /usr/local/sbin/
#chmod 744 /usr/local/sbin/add-jvb-node
#cp usr/local/sbin/add-jibri-node /usr/local/sbin/
#chmod 744 /usr/local/sbin/add-jibri-node
#cp usr/local/sbin/add-sip-node /usr/local/sbin/
#chmod 744 /usr/local/sbin/add-sip-node

# jibri-ephemeral-container service
cp usr/local/sbin/jibri-ephemeral-start /usr/local/sbin/
chmod 744 /usr/local/sbin/jibri-ephemeral-start
cp usr/local/sbin/jibri-ephemeral-stop /usr/local/sbin/
chmod 744 /usr/local/sbin/jibri-ephemeral-stop
cp etc/systemd/system/jibri-ephemeral-container.service /etc/systemd/system/

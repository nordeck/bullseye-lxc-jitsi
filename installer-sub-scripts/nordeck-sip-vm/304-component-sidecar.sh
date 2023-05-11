# ------------------------------------------------------------------------------
# COMPONENT-SIDECAR.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="$TAG-sip-template"
cd $MACHINES/$MACH

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_COMPONENT_SIDECAR" = true ]] && exit

echo
echo "-------------------- COMPONENT SIDECAR --------------------"

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get $APT_PROXY -y install redis

# nodejs
cp etc/apt/sources.list.d/nodesource.list /etc/apt/sources.list.d/
wget -T 30 -qO /tmp/nodesource.gpg.key \
    https://deb.nodesource.com/gpgkey/nodesource.gpg.key
cat /tmp/nodesource.gpg.key | gpg --dearmor >/usr/share/keyrings/nodesource.gpg
apt-get $APT_PROXY update

apt-get $APT_PROXY -y install nodejs
npm install npm -g

# jitsi-component-sidecar
debconf-set-selections <<< "\
    jitsi-component-sidecar jitsi-component-sidecar/selector-address string \
    $JITSI_FQDN"

dpkg -i /root/meta/jitsi-component-sidecar.deb

# ------------------------------------------------------------------------------
# COMPONENT-SIDECAR
# ------------------------------------------------------------------------------
if [[ -f "/root/.ssh/sidecar.key" ]] && [[ -f "/root/.ssh/sidecar.pem" ]]; then
    cp /root/.ssh/sidecar.key /etc/jitsi/sidecar/asap.key
    cp /root/.ssh/sidecar.pem /etc/jitsi/sidecar/asap.pem
fi

if [[ -f "/root/meta/env.sidecar" ]]; then
    cp /root/meta/env.sidecar /etc/jitsi/sidecar/env
else
    cp etc/jitsi/sidecar/env /etc/jitsi/sidecar/
fi
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/" /etc/jitsi/sidecar/env

chown jitsi-sidecar:jitsi /etc/jitsi/sidecar/*
systemctl restart jitsi-component-sidecar.service

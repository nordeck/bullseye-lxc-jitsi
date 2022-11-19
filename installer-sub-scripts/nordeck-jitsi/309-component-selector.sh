# ------------------------------------------------------------------------------
# COMPONENT-SELECTOR.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="nordeck-component-selector"
cd $MACHINES/$MACH

ROOTFS="/var/lib/lxc/$MACH/rootfs"
DNS_RECORD=$(grep "address=/$MACH/" /etc/dnsmasq.d/nordeck-jitsi | head -n1)
IP=${DNS_RECORD##*/}
SSH_PORT="30$(printf %03d ${IP##*.})"
echo COMPONENT_SELECTOR="$IP" >> $INSTALLER/000-source

JITSI_MACH="nordeck-jitsi"
JITSI_ROOTFS="/var/lib/lxc/$JITSI_MACH/rootfs"

# ------------------------------------------------------------------------------
# NFTABLES RULES
# ------------------------------------------------------------------------------
# the public ssh
nft delete element nordeck-nat tcp2ip { $SSH_PORT } 2>/dev/null || true
nft add element nordeck-nat tcp2ip { $SSH_PORT : $IP }
nft delete element nordeck-nat tcp2port { $SSH_PORT } 2>/dev/null || true
nft add element nordeck-nat tcp2port { $SSH_PORT : 22 }

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_COMPONENT_SELECTOR" = true ]] && exit

echo
echo "-------------------------- $MACH --------------------------"

# ------------------------------------------------------------------------------
# CONTAINER SETUP
# ------------------------------------------------------------------------------
# stop the template container if it's running
set +e
lxc-stop -n nordeck-bullseye
lxc-wait -n nordeck-bullseye -s STOPPED
set -e

# remove the old container if exists
set +e
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED
lxc-destroy -n $MACH
rm -rf /var/lib/lxc/$MACH
sleep 1
set -e

# create the new one
lxc-copy -n nordeck-bullseye -N $MACH -p /var/lib/lxc/

# the shared directories
mkdir -p $SHARED/cache

# the container config
rm -rf $ROOTFS/var/cache/apt/archives
mkdir -p $ROOTFS/var/cache/apt/archives

cat >> /var/lib/lxc/$MACH/config <<EOF

# Start options
lxc.start.auto = 1
lxc.start.order = 309
lxc.start.delay = 2
lxc.group = nordeck-group
lxc.group = onboot
EOF

# container network
cp $MACHINE_COMMON/etc/systemd/network/eth0.network $ROOTFS/etc/systemd/network/
sed -i "s/___IP___/$IP/" $ROOTFS/etc/systemd/network/eth0.network
sed -i "s/___GATEWAY___/$HOST/" $ROOTFS/etc/systemd/network/eth0.network

# start the container
lxc-start -n $MACH -d
lxc-wait -n $MACH -s RUNNING

# wait for the network to be up
for i in $(seq 0 9); do
    lxc-attach -n $MACH -- ping -c1 host.loc && break || true
    sleep 1
done

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------
# fake install
lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -dy reinstall hostname
EOS

# update
lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY update
apt-get $APT_PROXY -y dist-upgrade
EOS

# packages
lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -y install gnupg
apt-get $APT_PROXY -y install redis
EOS

# nodejs
cp etc/apt/sources.list.d/nodesource.list $ROOTFS/etc/apt/sources.list.d/

lxc-attach -n $MACH -- zsh <<EOS
set -e
wget -T 30 -qO /tmp/nodesource.gpg.key \
    https://deb.nodesource.com/gpgkey/nodesource.gpg.key
cat /tmp/nodesource.gpg.key | gpg --dearmor >/usr/share/keyrings/nodesource.gpg
apt-get $APT_PROXY update
EOS

lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -y install nodejs
npm install npm -g
EOS

# jitsi-component-selector
cp /root/nordeck-store/jitsi-component-selector.deb $ROOTFS/tmp/

lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
dpkg -i /tmp/jitsi-component-selector.deb
EOS

# ------------------------------------------------------------------------------
# ASAP
# ------------------------------------------------------------------------------
rm -rf $JITSI_ROOTFS/var/www/asap
cp -arp $MACHINES/$JITSI_MACH/var/www/asap $JITSI_ROOTFS/var/www/

cp $MACHINES/$JITSI_MACH/etc/nginx/sites-available/asap.conf \
    $JITSI_ROOTFS/etc/nginx/sites-available/
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/" \
    $JITSI_ROOTFS/etc/nginx/sites-available/asap.conf
rm -f $JITSI_ROOTFS/etc/nginx/sites-enabled/asap.conf
ln -s /etc/nginx/sites-available/asap.conf \
    $JITSI_ROOTFS/etc/nginx/sites-enabled/

lxc-attach -qn $JITSI_MACH -- true && \
    lxc-attach -n $JITSI_MACH -- systemctl restart nginx.service

# ------------------------------------------------------------------------------
# COMPONENT-SELECTOR
# ------------------------------------------------------------------------------
cp etc/jitsi/selector/env $ROOTFS/etc/jitsi/selector/

lxc-attach -n $MACH -- systemctl restart jitsi-component-selector.service

# ------------------------------------------------------------------------------
# CONTAINER SERVICES
# ------------------------------------------------------------------------------
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED
lxc-start -n $MACH -d
lxc-wait -n $MACH -s RUNNING

# wait for the network to be up
for i in $(seq 0 9); do
    lxc-attach -n $MACH -- ping -c1 host.loc && break || true
    sleep 1
done

# ------------------------------------------------------------------------------
# JIBRI.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="nordeck-jibri-template"
cd $MACHINES/$MACH

ROOTFS="/var/lib/lxc/$MACH/rootfs"
JITSI_ROOTFS="/var/lib/lxc/nordeck-jitsi/rootfs"
MACH_JITSI="$MACHINES/nordeck-jitsi"

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_JIBRI" = true ]] && exit

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
systemctl stop jibri-ephemeral-container.service

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
mkdir -p $SHARED/recordings

# the container config
rm -rf $ROOTFS/var/cache/apt/archives
mkdir -p $ROOTFS/var/cache/apt/archives
rm -rf $ROOTFS/usr/local/nordeck/recordings
mkdir -p $ROOTFS/usr/local/nordeck/recordings

cat >> /var/lib/lxc/$MACH/config <<EOF
lxc.mount.entry = $SHARED/recordings usr/local/nordeck/recordings none bind 0 0

# Devices
lxc.cgroup2.devices.allow = c 116:* rwm
lxc.mount.entry = /dev/snd dev/snd none bind,optional,create=dir

# Start options
lxc.start.auto = 1
lxc.start.order = 303
lxc.start.delay = 2
lxc.group = nordeck-group
lxc.group = nordeck-jibri
EOF

# start the container
lxc-start -n $MACH -d
lxc-wait -n $MACH -s RUNNING

# wait for the network to be up
for i in $(seq 0 9); do
    lxc-attach -n $MACH -- ping -c1 host.loc && break || true
    sleep 1
done

# ------------------------------------------------------------------------------
# HOSTNAME
# ------------------------------------------------------------------------------
lxc-attach -n $MACH -- zsh <<EOS
set -e
echo $MACH > /etc/hostname
sed -i 's/\(127.0.1.1\s*\).*$/\1$MACH/' /etc/hosts
hostname $MACH
EOS

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
apt-get $APT_PROXY -y install gnupg unzip unclutter
apt-get $APT_PROXY -y install libnss3-tools
apt-get $APT_PROXY -y install va-driver-all vdpau-driver-all
apt-get $APT_PROXY -y --install-recommends install ffmpeg
apt-get $APT_PROXY -y install x11vnc
EOS

# google chrome
cp etc/apt/sources.list.d/google-chrome.list $ROOTFS/etc/apt/sources.list.d/
lxc-attach -n $MACH -- zsh <<EOS
set -e
wget -T 30 -qO /tmp/google-chrome.gpg.key \
    https://dl.google.com/linux/linux_signing_key.pub
cat /tmp/google-chrome.gpg.key | gpg --dearmor \
    >/usr/share/keyrings/google-chrome.gpg
apt-get $APT_PROXY update
EOS

lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -y --install-recommends install google-chrome-stable
apt-mark hold google-chrome-stable
EOS

# fix overwritten google-chrome sources list by recopying it
# google tries to add its key as a globally trusted one, limit its permissions
cp etc/apt/sources.list.d/google-chrome.list $ROOTFS/etc/apt/sources.list.d/

lxc-attach -n $MACH -- zsh <<EOS
set -e
rm -f /etc/apt/trusted.gpg.d/google-chrome.*
apt-get $APT_PROXY update
EOS

# chromedriver
lxc-attach -n $MACH -- zsh <<EOS
set -e
CHROME_VER=\$(dpkg -s google-chrome-stable | egrep "^Version" | \
    cut -d " " -f2 | cut -d. -f1)
CHROMEDRIVER_VER=\$(curl -s \
    https://chromedriver.storage.googleapis.com/LATEST_RELEASE_\$CHROME_VER)
wget -T 30 -qO /tmp/chromedriver_linux64.zip \
    https://chromedriver.storage.googleapis.com/\$CHROMEDRIVER_VER/chromedriver_linux64.zip
unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin/
chmod 755 /usr/local/bin/chromedriver
EOS

# jibri
cp etc/apt/sources.list.d/jitsi-stable.list $ROOTFS/etc/apt/sources.list.d/
lxc-attach -n $MACH -- zsh <<EOS
set -e
wget -T 30 -qO /tmp/jitsi.gpg.key https://download.jitsi.org/jitsi-key.gpg.key
cat /tmp/jitsi.gpg.key | gpg --dearmor >/usr/share/keyrings/jitsi.gpg
apt-get $APT_PROXY update
EOS

lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -y install openjdk-11-jre-headless
apt-get $APT_PROXY -y install jibri
apt-mark hold jibri
EOS

# removed packages
lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get -y purge upower
EOS

# ------------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# ------------------------------------------------------------------------------
# disable ssh service
lxc-attach -n $MACH -- zsh <<EOS
set -e
systemctl stop ssh.service
systemctl disable ssh.service
EOS

# jitsi host
echo -e "$JITSI\t$JITSI_FQDN" >> $ROOTFS/etc/hosts

# certificates
cp /root/nordeck-certs/nordeck-CA.pem \
    $ROOTFS/usr/local/share/ca-certificates/jms-CA.crt
lxc-attach -n $MACH -- zsh <<EOS
set -e
update-ca-certificates
EOS

# google chrome managed policies
mkdir -p $ROOTFS/etc/opt/chrome/policies/managed
cp etc/opt/chrome/policies/managed/nordeck-policies.json \
    $ROOTFS/etc/opt/chrome/policies/managed/

# ------------------------------------------------------------------------------
# JITSI CUSTOMIZATION FOR JIBRI
# ------------------------------------------------------------------------------

# jitsi-meet config
sed -i "/^\s*\/\/ Recording$/a \
\\
\n\
\    recordingService: {\n\
\        enabled: true,\n\
\        sharingEnabled: true,\n\
\        hideStorageWarning: false,\n\
\    },\n\
\n\
\    liveStreamingEnabled: true,\n\
\    hiddenDomain: 'recorder.$JITSI_FQDN'," \
    $JITSI_ROOTFS/etc/jitsi/meet/$JITSI_FQDN-config.js

# ------------------------------------------------------------------------------
# JIBRI
# ------------------------------------------------------------------------------
cp $ROOTFS/etc/jitsi/jibri/xorg-video-dummy.conf \
    $ROOTFS/etc/jitsi/jibri/xorg-video-dummy.conf.org

# meta
lxc-attach -n $MACH -- zsh <<EOS
set -e
mkdir -p /root/meta
VERSION=\$(apt-cache policy jibri | grep Installed | rev | cut -d' ' -f1 | rev)
echo \$VERSION > /root/meta/jibri-version
EOS

# jibri groups
lxc-attach -n $MACH -- zsh <<EOS
set -e
chsh -s /bin/bash jibri
usermod -aG adm,audio,video,plugdev jibri
chown jibri:jibri /home/jibri
EOS

# jibri ssh
mkdir -p $ROOTFS/home/jibri/.ssh
chmod 700 $ROOTFS/home/jibri/.ssh
cp home/jibri/.ssh/jibri-config $ROOTFS/home/jibri/.ssh/
cp /root/.ssh/jibri $ROOTFS/home/jibri/.ssh/

lxc-attach -n $MACH -- zsh <<EOS
set -e
chown jibri:jibri /home/jibri/.ssh -R
EOS

# jibri, icewm
mkdir -p $ROOTFS/home/jibri/.icewm
cp home/jibri/.icewm/theme $ROOTFS/home/jibri/.icewm/
cp home/jibri/.icewm/prefoverride $ROOTFS/home/jibri/.icewm/
cp home/jibri/.icewm/startup $ROOTFS/home/jibri/.icewm/
chmod 755 $ROOTFS/home/jibri/.icewm/startup

# recordings directory
lxc-attach -n $MACH -- zsh <<EOS
set -e
chown jibri:jibri /usr/local/nordeck/recordings -R
EOS

# pki
lxc-attach -n $MACH -- zsh <<EOS
set -e
mkdir -p /home/jibri/.pki/nssdb
chmod 700 /home/jibri/.pki
chmod 700 /home/jibri/.pki/nssdb

certutil -A -n "jitsi" -i /usr/local/share/ca-certificates/jms-CA.crt \
    -t "TCu,Cu,Tu" -d sql:/home/jibri/.pki/nssdb/
chown jibri:jibri /home/jibri/.pki -R
EOS

# jibri config
cp etc/jitsi/jibri/jibri.conf $ROOTFS/etc/jitsi/jibri/
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/" $ROOTFS/etc/jitsi/jibri/jibri.conf
sed -i "s/___PASSWD1___/$PASSWD1/" $ROOTFS/etc/jitsi/jibri/jibri.conf
sed -i "s/___PASSWD2___/$PASSWD2/" $ROOTFS/etc/jitsi/jibri/jibri.conf

# the customized scripts
cp usr/local/bin/finalize-recording.sh $ROOTFS/usr/local/bin/
chmod 755 $ROOTFS/usr/local/bin/finalize-recording.sh
cp usr/local/bin/ffmpeg $ROOTFS/usr/local/bin/
chmod 755 $ROOTFS/usr/local/bin/ffmpeg

# jibri ephemeral config service
cp usr/local/sbin/jibri-ephemeral-config $ROOTFS/usr/local/sbin/
chmod 744 $ROOTFS/usr/local/sbin/jibri-ephemeral-config
cp etc/systemd/system/jibri-ephemeral-config.service \
    $ROOTFS/etc/systemd/system/

lxc-attach -n $MACH -- zsh <<EOS
set -e
systemctl daemon-reload
systemctl enable jibri-ephemeral-config.service
EOS

# jibri service
lxc-attach -n $MACH -- zsh <<EOS
set -e
systemctl enable jibri.service
systemctl start jibri.service
EOS

# jibri, vnc
lxc-attach -n $MACH -- zsh <<EOS
set -e
mkdir -p /home/jibri/.vnc
x11vnc -storepasswd jibri /home/jibri/.vnc/passwd
chown jibri:jibri /home/jibri/.vnc -R
EOS

# jibri, Xdefaults
cp home/jibri/.Xdefaults $ROOTFS/home/jibri/
lxc-attach -n $MACH -- zsh <<EOS
set -e
chown jibri:jibri /home/jibri/.Xdefaults
EOS

# ------------------------------------------------------------------------------
# CONTAINER SERVICES
# ------------------------------------------------------------------------------
lxc-attach -n $MACH -- systemctl stop jibri-xorg.service
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED

# ------------------------------------------------------------------------------
# CLEAN UP
# ------------------------------------------------------------------------------
find $ROOTFS/var/log/jitsi/jibri -type f -delete

# ------------------------------------------------------------------------------
# ON HOST
# ------------------------------------------------------------------------------
systemctl daemon-reload
systemctl enable jibri-ephemeral-container.service
systemctl start jibri-ephemeral-container.service

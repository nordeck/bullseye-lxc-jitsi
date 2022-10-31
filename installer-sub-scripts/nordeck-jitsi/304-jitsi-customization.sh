# ------------------------------------------------------------------------------
# JITSI-CUSTOMIZATION.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="nordeck-jitsi-host"
cd $MACHINES/$MACH

JITSI_ROOTFS="/var/lib/lxc/nordeck-jitsi/rootfs"

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[ "$DONT_RUN_JITSI_CUSTOMIZATION" = true ] && exit

echo
echo "------------------- JITSI CUSTOMIZATION -------------------"

# ------------------------------------------------------------------------------
# CONFIG.JS
# ------------------------------------------------------------------------------
# dial-plan
if [[ "$DONT_RUN_SIP_DIAL_PLAN" != true ]]; then
    sed -i "/^var config =/a \
\    peopleSearchQueryTypes: ['conferenceRooms'],\n\
\    peopleSearchUrl: 'https://$JITSI_FQDN/get-dial-plan',\n" \
        $JITSI_ROOTFS/etc/jitsi/meet/$JITSI_FQDN-config.js
fi

# recording
sed -i "/^\s*\/\/ Recording$/a \
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
# CUSTOMIZATION FOLDER & TOOLS
# ------------------------------------------------------------------------------
FOLDER="/root/jitsi-customization"

# is there an old customization folder?
if [[ -d "/root/jitsi-customization" ]]; then
    FOLDER="/root/jitsi-customization-new"
    rm -rf $FOLDER

    echo "There is already an old customization folder."
    echo "A new folder will be created as $FOLDER"
fi

cp -arp root/jitsi-customization $FOLDER

sed -i "s/___TURN_FQDN___/$TURN_FQDN/g" $FOLDER/README.md
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/g" $FOLDER/README.md
sed -i "s/___TURN_FQDN___/$TURN_FQDN/g" $FOLDER/customize.sh
sed -i "s/___JITSI_FQDN___/$JITSI_FQDN/g" $FOLDER/customize.sh

mkdir -p $FOLDER/files
cp $JITSI_ROOTFS/etc/jitsi/meet/$JITSI_FQDN-config.js $FOLDER/files/
cp $JITSI_ROOTFS//usr/share/jitsi-meet/interface_config.js $FOLDER/files/
cp $JITSI_ROOTFS/usr/share/jitsi-meet/images/favicon.ico $FOLDER/files/
cp $JITSI_ROOTFS/usr/share/jitsi-meet/images/watermark.svg $FOLDER/files/

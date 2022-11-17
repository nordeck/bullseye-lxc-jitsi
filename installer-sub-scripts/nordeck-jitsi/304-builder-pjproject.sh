# ------------------------------------------------------------------------------
# BUILDER-PJPROJECT.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
MACH="nordeck-builder"
cd $MACHINES/$MACH

ROOTFS="/var/lib/lxc/$MACH/rootfs"
PJPROJECT_REPO="https://github.com/jitsi/pjproject"
PJPROJECT_BRANCH="jibri-2.10-dev1"

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_BUILD_PJPROJECT" = true ]] && exit

echo
echo "------------------------ PJPROJECT ------------------------"

# ------------------------------------------------------------------------------
# CONTAINER
# ------------------------------------------------------------------------------
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
# pjproject releated packages
lxc-attach -n $MACH -- zsh <<EOS
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY -y install libv4l-dev libsdl2-dev libavcodec-dev \
    libavdevice-dev libavfilter-dev libavformat-dev libavresample-dev \
    libavutil-dev libswresample-dev libswscale-dev libasound2-dev libopus-dev \
    libvpx-dev
EOS

# ------------------------------------------------------------------------------
# PJPROJECT
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONTAINER SERVICES
# ------------------------------------------------------------------------------
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED

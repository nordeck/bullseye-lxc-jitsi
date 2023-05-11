# ------------------------------------------------------------------------------
# REMOVE-BUILDER.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$RUN_REMOVE_BUILDER" != true ]] && exit

echo
echo "--------------------- REMOVE BUILDER ---------------------"

# ------------------------------------------------------------------------------
# KERNEL MODULES
# ------------------------------------------------------------------------------
cp /lib/modules/$(uname -r)/updates/dkms/v4l2loopback.ko \
    /lib/modules/$(uname -r)/kernel/drivers/video/

# ------------------------------------------------------------------------------
# REMOVE BUILDING PACKAGES
# ------------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

apt-get -y purge v4l2loopback-dkms v4l2loopback-utils
apt-get -y purge build-essential binutils dpkg-dev make
apt-get -y autoremove --purge

# ------------------------------------------------------------------------------
# UPDATE MODULE DEPENDENCIES
# ------------------------------------------------------------------------------
depmod

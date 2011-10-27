#!/bin/bash

# The initramfs source path.
INITRAMFSDIR=${HOME}/anomaly_kernel_platform_SGH-T989/initramfs/root/

# Change directories to the initramfs directory.
cd ${HOME}/anomaly_kernel_platform_SGH-T989/initramfs/root/
# Remove the hidden git files if they are in the directory.
rm -rf .git/

# Change directory to the kernel source.
cd ${HOME}/anomaly_kernel_platform_SGH-T989/source/
# Tell the compiler we are building for arm.
export ARCH=arm
# Export to where the cross compiler is.
export CROSS_COMPILE=${HOME}/anomaly_kernel_platform_SGH-T989/toolchain/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-

# Triple make sure the build directory is clean.
make distclean
make mrproper
make clean
make clean
make clean

# Configure the correct defconfig.
make anomaly_kernel_platform_SGH-T989_defconfig

# Set the initramfs directory and build the zImage.
make -j8 CONFIG_INITRAMFS_SOURCE="$INITRAMFSDIR"

# Copy the freshly compiled modules to the initramfs.
cp arch/arm/mach-msm/dal_remotetest.ko $INITRAMFSDIR/lib/modules/
cp arch/arm/common/cpaccess.ko $INITRAMFSDIR/lib/modules/
cp arch/arm/mach-msm/dma_test.ko $INITRAMFSDIR/lib/modules/
cp arch/arm/oprofile/oprofile.ko $INITRAMFSDIR/lib/modules/
cp arch/arm/perfmon/ksapi.ko $INITRAMFSDIR/lib/modules/
cp crypto/ansi_cprng.ko $INITRAMFSDIR/lib/modules/
cp drivers/bluetooth/bthid/bthid.ko $INITRAMFSDIR/lib/modules/
cp drivers/crypto/msm/qce.ko $INITRAMFSDIR/lib/modules/
cp drivers/crypto/msm/qcrypto.ko $INITRAMFSDIR/lib/modules/
cp drivers/crypto/msm/qcedev.ko $INITRAMFSDIR/lib/modules/
cp drivers/input/evbug.ko $INITRAMFSDIR/lib/modules/
cp drivers/media/video/gspca/gspca_main.ko $INITRAMFSDIR/lib/modules/
cp drivers/misc/msm_tsif.ko $INITRAMFSDIR/lib/modules/
cp drivers/misc/tsif_chrdev.ko $INITRAMFSDIR/lib/modules/
cp drivers/misc/vibetonz/vibrator.ko $INITRAMFSDIR/lib/modules/
cp drivers/net/wireless/bcm4330/dhd.ko $INITRAMFSDIR/lib/modules/
cp drivers/scsi/scsi_wait_scan.ko $INITRAMFSDIR/lib/modules/
cp drivers/net/wireless/libra/librasdioif.ko $INITRAMFSDIR/lib/modules/
cp drivers/spi/spidev.ko $INITRAMFSDIR/lib/modules/
cp drivers/video/backlight/lcd.ko $INITRAMFSDIR/lib/modules/

# Build the kernel again with the same initramfs, but with newly compiled modules.
make -j8 CONFIG_INITRAMFS_SOURCE="$INITRAMFSDIR"



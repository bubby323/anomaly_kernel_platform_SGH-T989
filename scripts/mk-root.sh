#!/bin/bash

TOPDIR=$(pwd)/..
SRCDIR=${TOPDIR}/source
BLDDIR=${TOPDIR}/build
INITRAMFSDIR=${TOPDIR}/initramfs/root

# Location of the toolchain prefix.
TOOLCHAIN=${TOPDIR}/toolchain/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-

# Number of make jobs to run in parallel.
MKJOBS=8

STD_MK_OPTS="-j${MKJOBS} O=${TOPDIR}/build ARCH=arm CROSS_COMPILE=${TOOLCHAIN}"

# clear .git* from initramfs root
find ${INITRAMFSDIR} -name '\.git*' | xargs rm -rf

# Change directory to the kernel source.
rm -rf ${BLDDIR}
mkdir ${BLDDIR}
pushd ${SRCDIR}

# Clean the build directory
make ${STD_MK_OPTS} distclean

# Configure the correct defconfig.
make ${STD_MK_OPTS} anomaly_kernel_platform_SGH-T989_defconfig

# Set the initramfs directory and build the zImage.
make ${STD_MK_OPTS} CONFIG_INITRAMFS_SOURCE=${INITRAMFSDIR}

# Copy the freshly compiled modules to the initramfs.
cp ${BLDDIR}/arch/arm/mach-msm/dal_remotetest.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/arch/arm/common/cpaccess.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/arch/arm/mach-msm/dma_test.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/arch/arm/oprofile/oprofile.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/arch/arm/perfmon/ksapi.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/crypto/ansi_cprng.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/bluetooth/bthid/bthid.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/crypto/msm/qce.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/crypto/msm/qcrypto.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/crypto/msm/qcedev.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/input/evbug.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/media/video/gspca/gspca_main.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/misc/msm_tsif.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/misc/tsif_chrdev.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/misc/vibetonz/vibrator.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/net/wireless/bcm4330/dhd.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/scsi/scsi_wait_scan.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/net/wireless/libra/librasdioif.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/spi/spidev.ko ${INITRAMFSDIR}/lib/modules/
cp ${BLDDIR}/drivers/video/backlight/lcd.ko ${INITRAMFSDIR}/lib/modules/

# Build the kernel again with the same initramfs, but with newly compiled modules.
make ${STD_MK_OPTS} CONFIG_INITRAMFS_SOURCE=${INITRAMFSDIR}
popd

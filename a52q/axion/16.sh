#!/bin/bash
set +e

WORK_DIR="/tmp/src/android"
MK="device/samsung/a52q/lineage_a52q.mk"

echo "debug - cleanup $(pwd)"
rm -rf device/samsung/a52q device/samsung/sm7125-common kernel/samsung/sm7125 vendor/samsung/sm7125-common vendor/samsung/a52q hardware/samsung-ext/interfaces

if [ ! -e no_rmrf_out ]; then
  echo Removing out
  rm -rf out
  touch no_rmrf_out
fi

repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --git-lfs
echo "debug - syncing $(pwd)"
/opt/crave/resync.sh

if [ ! -d tmp ]; then
    echo "debug - creating nfc backup $(pwd)"
    mkdir tmp
    mv hardware/samsung/* tmp/
fi

echo "debug - trees $(pwd)"
git clone https://github.com/crdroidandroid/android_device_samsung_a52q device/samsung/a52q
git clone https://github.com/matei9/android_device_samsung_sm7125-common device/samsung/sm7125-common
git clone https://github.com/crdroidandroid/android_kernel_samsung_sm7125 kernel/samsung/sm7125
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_sm7125-common vendor/samsung/sm7125-common
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_a52q vendor/samsung/a52q
rm -rf hardware/samsung
echo "debug - cloning hardware samsung $(pwd)"
git clone https://github.com/crdroidandroid/android_hardware_samsung hardware/samsung
git clone https://github.com/crdroidandroid/hardware_samsung-extra_interfaces hardware/samsung-ext/interfaces

echo "debug - restore backup $(pwd)"
cp -r tmp/* hardware/samsung/
rm -rf tmp

echo "debug - build $(pwd)"
source build/envsetup.sh
gk -s

writeFlag AXION_CAMERA_REAR_INFO 64,12,5
writeFlag AXION_CAMERA_FRONT_INFO 32
writeFlag AXION_MAINTAINER wojtekojtek
writeFlag AXION_PROCESSOR Snapdragon_720G
writeFlag TARGET_INCLUDE_AXFX true
writeFlag TARGET_DISABLE_EPPE true

axion a52q userdebug va
ax -br -j$(nproc)

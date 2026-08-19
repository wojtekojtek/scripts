#!/bin/bash
set +e

WORK_DIR="/tmp/src/android"
MK="device/samsung/a52q/halcyon_a52q.mk"

echo "debug - cleanup $(pwd)"
rm -rf device/samsung/a52q device/samsung/sm7125-common kernel/samsung/sm7125 vendor/samsung/sm7125-common vendor/samsung/a52q hardware/samsung-ext/interfaces

repo init -u https://github.com/halcyonproject/manifest -b 16.0
echo "debug - syncing $(pwd)"
/opt/crave/resync.sh

if [ ! -d tmp ]; then
    echo "debug - creating nfc backup $(pwd)"
    mkdir tmp
    mv hardware/samsung/* tmp/
fi

echo "debug - trees $(pwd)"
git clone https://github.com/crdroidandroid/android_device_samsung_a52q device/samsung/a52q
git clone https://github.com/crdroidandroid/android_device_samsung_sm7125-common device/samsung/sm7125-common
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

echo "debug - patching device tree $(pwd)"
sed -i 's/lineage/halcyon/g' device/samsung/a52q/AndroidProducts.mk
mv device/samsung/a52q/lineage_a52q.mk "$MK"
sed -i 's/lineage_a52q/halcyon_a52q/g' "$MK"
#sed -i 's|device/lineage/sepolicy/libperfmgr/sepolicy.mk|device/halcyon/sepolicy/libperfmgr/sepolicy.mk|g' device/samsung/sm7125-common/BoardConfigCommon.mk

if ! grep -q 'TARGET_BOOT_ANIMATION_RES' "$MK"; then
    echo 'TARGET_BOOT_ANIMATION_RES := 1080' >> "$MK"
fi
if ! grep -q 'TARGET_FACE_UNLOCK_SUPPORTED' "$MK"; then
    echo 'TARGET_FACE_UNLOCK_SUPPORTED := true' >> "$MK"
fi
if ! grep -q 'TARGET_ENABLE_BLUR' "$MK"; then
    echo 'TARGET_ENABLE_BLUR := true' >> "$MK"
fi
if ! grep -q 'EXTRA_UDFPS_ANIMATIONS' "$MK"; then
    echo 'EXTRA_UDFPS_ANIMATIONS := true' >> "$MK"
fi
if ! grep -q 'TORCH_STR_SUPPORTED' "$MK"; then
    echo 'TORCH_STR_SUPPORTED := true' >> "$MK"
fi

echo "debug - build $(pwd)"
source build/envsetup.sh
lunch halcyon_a52q-bp2a-userdebug
mka carthage

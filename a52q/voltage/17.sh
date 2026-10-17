#!/bin/bash
set +e

WORK_DIR="/tmp/src/android"
MK="device/samsung/a52q/voltage_a52q.mk"

echo "-----"
free -h
echo "-----"
echo "debug - cleanup $(pwd)"
rm -rf device/samsung/a52q device/samsung/sm7125-common kernel/samsung/sm7125 vendor/samsung/sm7125-common vendor/samsung/a52q hardware/samsung-ext/interfaces

repo init -u https://github.com/VoltageOS/manifest.git -b 17 --git-lfs --no-clone-bundle
echo "debug - syncing $(pwd)"
/opt/crave/resync.sh

cd build/soong

git fetch https://github.com/PixelOS-AOSP/android_build_soong 173bd39389e5d1d91b27db80000f3479dbaf7add || true
git cherry-pick 173bd39389e5d1d91b27db80000f3479dbaf7add || true

git fetch https://github.com/15168142/build_soong-pos b299e2b78014e79edbf017db5beb28e995ec0a80 ||  true
git cherry-pick b299e2b78014e79edbf017db5beb28e995ec0a80 || true

cd ../..

if [ ! -d tmp ]; then
    echo "debug - creating nfc backup $(pwd)"
    mkdir tmp
    mv hardware/samsung/* tmp/
fi

echo "debug - trees $(pwd)"
git clone https://github.com/crdroidandroid/android_device_samsung_a52q device/samsung/a52q
git clone https://github.com/crdroidandroid/android_device_samsung_sm7125-common device/samsung/sm7125-common
git clone https://github.com/matei9/android_kernel_samsung_sm7125 kernel/samsung/sm7125
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_sm7125-common vendor/samsung/sm7125-common
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_a52q vendor/samsung/a52q
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_nfc hardware/samsung_slsi/nfc -b lineage-24.0


rm -rf hardware/samsung
echo "debug - cloning hardware samsung $(pwd)"
git clone https://github.com/LineageOS/android_hardware_samsung hardware/samsung -b lineage-24.0
git clone https://github.com/crdroidandroid/hardware_samsung-extra_interfaces hardware/samsung-ext/interfaces

echo "debug - restore backup $(pwd)"
cp -r tmp/* hardware/samsung/
rm -rf tmp

echo "debug - patching device tree $(pwd)"
sed -i 's/lineage/voltage/g' device/samsung/a52q/AndroidProducts.mk
mv device/samsung/a52q/lineage_a52q.mk "$MK"
sed -i 's/lineage/voltage/g' "$MK"
sed -i 's|device/lineage/sepolicy/libperfmgr/sepolicy.mk|device/voltage/sepolicy/libperfmgr/sepolicy.mk|g' device/samsung/sm7125-common/BoardConfigCommon.mk
sed -i 's#include device/lineage/sepolicy/libion/sepolicy.mk#include device/voltage/sepolicy/libion/sepolicy.mk#' device/samsung/sm7125-common/BoardConfigCommon.mk || true

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

echo "debug - keys $(pwd)"
rm -rf vendor/voltage-priv/keys
echo "1 $(pwd)"
git clone https://github.com/VoltageOS/vendor_voltage-priv_keys vendor/voltage-priv/keys
echo "2 $(pwd)"
cd vendor/voltage-priv/keys
echo "3 $(pwd)"
bash keys.sh || true
echo "4 $(pwd)"
cd "$WORK_DIR"
echo "5 $(pwd)"
touch .keys_generated
echo "6 $(pwd)"

echo "debug - apply tee workaround $(pwd)"
echo "7 $(pwd)"
mkdir -p system/sepolicy/private
echo "8 $(pwd)"
if ! grep -q 'allow tee gatekeeper_vendor_data_file:dir' system/sepolicy/private/tee.te 2>/dev/null; then
    printf '\nallow tee gatekeeper_vendor_data_file:dir rw_dir_perms;\nallow tee gatekeeper_vendor_data_file:file create_file_perms;\n' >> system/sepolicy/private/tee.te
fi
echo "9 $(pwd)"

echo "debug - add maintainer string $(pwd)"
OVERLAY_DIR="device/samsung/a52q/overlay-voltage/packages/apps/Settings/res/values"
mkdir -p "$OVERLAY_DIR"
if [ ! -f "$OVERLAY_DIR/voltage_strings.xml" ]; then
    printf '<?xml version="1.0" encoding="utf-8"?>\n<resources xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">\n    <string name="voltage_maintainer">wojtekojtek</string>\n</resources>\n' \
        > "$OVERLAY_DIR/voltage_strings.xml"
fi

sed -i 's|<string name="voltage_maintainer">Unofficial Maintainer</string>|<string name="voltage_maintainer">wojtekojtek</string>|' ./packages/apps/Settings/res/values/voltage_strings.xml || true

echo "debug - build $(pwd)"
source build/envsetup.sh
croot
brunch a52q

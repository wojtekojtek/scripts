#!/bin/bash
set -e

WORK_DIR="/tmp/src/android"
MK="device/samsung/a52q/voltage_a52q.mk"

repo init -u https://github.com/VoltageOS/manifest.git -b 16.2 --git-lfs --no-clone-bundle
echo "debug - syncing"
/opt/crave/resync.sh

if [ ! -d tmp ]; then
    echo "debug - creating nfc backup"
    mkdir tmp
    mv hardware/samsung/* tmp/
fi

echo "debug - trees"
git clone https://github.com/crdroidandroid/android_device_samsung_a52q device/samsung/a52q
git clone https://github.com/crdroidandroid/android_device_samsung_sm7125-common device/samsung/sm7125-common
git clone https://github.com/crdroidandroid/android_kernel_samsung_sm7125 kernel/samsung/sm7125
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_sm7125-common vendor/samsung/sm7125-common
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_a52q vendor/samsung/a52q
git clone https://github.com/crdroidandroid/android_hardware_samsung hardware/samsung
git clone https://github.com/crdroidandroid/hardware_samsung-extra_interfaces hardware/samsung-ext/interfaces

echo "debug - restore backup"
mv tmp/* hardware/samsung/
rm -r tmp

echo "debug - patching device tree"
sed -i 's/lineage/voltage/g' device/samsung/a52q/AndroidProducts.mk
mv device/samsung/a52q/lineage_a52q.mk "$MK"
sed -i 's/lineage/voltage/g' "$MK"

grep -q 'TARGET_BOOT_ANIMATION_RES'    "$MK" || echo 'TARGET_BOOT_ANIMATION_RES := 1080'      >> "$MK"
grep -q 'TARGET_FACE_UNLOCK_SUPPORTED' "$MK" || echo 'TARGET_FACE_UNLOCK_SUPPORTED := true'   >> "$MK"
grep -q 'TARGET_ENABLE_BLUR'           "$MK" || echo 'TARGET_ENABLE_BLUR := true'             >> "$MK"
grep -q 'EXTRA_UDFPS_ANIMATIONS'       "$MK" || echo 'EXTRA_UDFPS_ANIMATIONS := true'         >> "$MK"
grep -q 'TORCH_STR_SUPPORTED'          "$MK" || echo 'TORCH_STR_SUPPORTED := true'            >> "$MK"

echo "debug - keys"
rm -rf vendor/voltage-priv/keys
echo 1
git clone https://github.com/VoltageOS/vendor_voltage-priv_keys vendor/voltage-priv/keys
echo 2
cd vendor/voltage-priv/keys
echo 3
bash keys.sh
echo 4
cd "$WORK_DIR"
echo 5

touch .keys_generated
echo 6

echo "debug - apply tee workaround"
echo 7
mkdir -p system/sepolicy/private
echo 8
grep -q 'allow tee gatekeeper_vendor_data_file:dir' system/sepolicy/private/tee.te 2>/dev/null || \
    printf '\nallow tee gatekeeper_vendor_data_file:dir rw_dir_perms;\nallow tee gatekeeper_vendor_data_file:file create_file_perms;\n' \
    >> system/sepolicy/private/tee.te
echo 9

echo "debug - add maintainer string"
OVERLAY_DIR="device/samsung/a52q/overlay-voltage/packages/apps/Settings/res/values"
mkdir -p "$OVERLAY_DIR"
[ -f "$OVERLAY_DIR/voltage_strings.xml" ] || printf '<?xml version="1.0" encoding="utf-8"?>\n<resources xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">\n    <string name="voltage_maintainer">wojtekojtek</string>\n</resources>\n' \
    > "$OVERLAY_DIR/voltage_strings.xml"

echo "debug - build"
source build/envsetup.sh
croot
brunch a52q
#!/bin/bash
set -e

WORK_DIR="/tmp/src/android"
MK="device/samsung/a52q/voltage_a52q.mk"

repo init -u https://github.com/VoltageOS/manifest.git -b 16.2 --git-lfs --no-clone-bundle

/opt/crave/resync.sh

if [ ! -d tmp ]; then
    mkdir tmp
    mv hardware/samsung/* tmp/
fi

git clone https://github.com/crdroidandroid/android_device_samsung_a52q device/samsung/a52q
git clone https://github.com/crdroidandroid/android_device_samsung_sm7125-common device/samsung/sm7125-common
git clone https://github.com/crdroidandroid/android_kernel_samsung_sm7125 kernel/samsung/sm7125
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_sm7125-common vendor/samsung/sm7125-common
git clone https://github.com/crdroidandroid/proprietary_vendor_samsung_a52q vendor/samsung/a52q
git clone https://github.com/crdroidandroid/android_hardware_samsung hardware/samsung
git clone https://github.com/crdroidandroid/hardware_samsung-extra_interfaces hardware/samsung-ext/interfaces

mv tmp/* hardware/samsung/
rm -r tmp

sed -i 's/lineage/voltage/g' device/samsung/a52q/AndroidProducts.mk
mv device/samsung/a52q/lineage_a52q.mk "$MK"
sed -i 's/lineage/voltage/g' "$MK"

grep -q 'TARGET_BOOT_ANIMATION_RES'    "$MK" || echo 'TARGET_BOOT_ANIMATION_RES := 1080'      >> "$MK"
grep -q 'TARGET_FACE_UNLOCK_SUPPORTED' "$MK" || echo 'TARGET_FACE_UNLOCK_SUPPORTED := true'   >> "$MK"
grep -q 'TARGET_ENABLE_BLUR'           "$MK" || echo 'TARGET_ENABLE_BLUR := true'             >> "$MK"
grep -q 'EXTRA_UDFPS_ANIMATIONS'       "$MK" || echo 'EXTRA_UDFPS_ANIMATIONS := true'         >> "$MK"
grep -q 'TORCH_STR_SUPPORTED'          "$MK" || echo 'TORCH_STR_SUPPORTED := true'            >> "$MK"

rm -rf vendor/voltage-priv/keys
git clone https://github.com/VoltageOS/vendor_voltage-priv_keys vendor/voltage-priv/keys
cd vendor/voltage-priv/keys
bash keys.sh
cd "$WORK_DIR"

touch .keys_generated

mkdir -p system/sepolicy/private
grep -q 'allow tee gatekeeper_vendor_data_file:dir' system/sepolicy/private/tee.te 2>/dev/null || \
    printf '\nallow tee gatekeeper_vendor_data_file:dir rw_dir_perms;\nallow tee gatekeeper_vendor_data_file:file create_file_perms;\n' \
    >> system/sepolicy/private/tee.te

OVERLAY_DIR="device/samsung/a52q/overlay-voltage/packages/apps/Settings/res/values"
mkdir -p "$OVERLAY_DIR"
[ -f "$OVERLAY_DIR/voltage_strings.xml" ] || printf '<?xml version="1.0" encoding="utf-8"?>\n<resources xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">\n    <string name="voltage_maintainer">wojtekojtek</string>\n</resources>\n' \
    > "$OVERLAY_DIR/voltage_strings.xml"

source build/envsetup.sh
croot
brunch a52q
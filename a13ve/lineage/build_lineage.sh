#!/bin/bash
# Build LineageOS for a13ve (Samsung A13 4G)

# Clean
echo "-> Cleaning"
rm -rf out
rm -rf device/samsung/a13ve
rm -rf device/samsung/a13ve-kernel
rm -rf kernel/samsung/a13ve
rm -rf vendor/samsung/a13ve
rm -rf hardware/samsung
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf prebuilts/clang/host/linux-x86/clang-r383902

# Clone trees
echo "-> Cloning trees"
git clone https://github.com/wojtekojtek/device_samsung_a13ve -b lineage-21-a13ve-1 device/samsung/a13ve
git clone https://github.com/wojtekojtek/device_samsung_a13ve-kernel device/samsung/a13ve-kernel -b a13ve_modules
git clone https://github.com/wojtekojtek/android_kernel_samsung_a13ve_1 -b A137FXXS8EXJ1 kernel/samsung/a13ve
git clone https://github.com/wojtekojtek/android_vendor_samsung_a13ve_1 -b a13ve_a32 vendor/samsung/a13ve
git clone https://github.com/LineageOS/android_hardware_samsung -b lineage-21 hardware/samsung
git clone https://github.com/LineageOS/android_hardware_samsung_nfc -b lineage-21.0 hardware/samsung/nfc
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-21 hardware/mediatek
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-21 device/mediatek/sepolicy_vndr
git clone https://github.com/A325F/android_prebuilts_clang_host_linux-x86_clang-6443078 prebuilts/clang/host/linux-x86/clang-r383902

# Build
echo "-> Build started!"
source build/envsetup.sh
croot
brunch a13ve

echo " "
echo ---------- CLONING TREES ----------
echo " "
rm -rf device/samsung/a52q
git clone https://github.com/wojtekojtek/android_device_samsung_a52q device/samsung/a52q -b derpfest
rm -rf device/samsung/sm7125-common
git clone https://github.com/wojtekojtek/android_device_samsung_sm7125-common device/samsung/sm7125-common -b derpfest
rm -rf kernel/samsung/sm7125
git clone https://github.com/Simon1511/android_kernel_samsung_sm7125 kernel/samsung/sm7125 -b lineage-21
rm -rf vendor/samsung/a52q
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_a52q vendor/samsung/a52q -b lineage-21
rm -rf vendor/samsung/sm7125-common
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_sm7125-common vendor/samsung/sm7125-common -b lineage-21
rm -rf hardware/samsung
git clone https://github.com/Lineageos/android_hardware_samsung hardware/samsung -b lineage-21 && cd vendor/support/res/values
echo " "
echo ---------- PATCH ATTRS.XML -------------
echo " "
rm -rf attrs.xml
curl https://pastebin.com/raw/aCi9YAvL --output attrs.xml
cd ../../../..
echo " "
echo --------- REMOVE DOZE, DAP -----------
echo " "
cd hardware/samsung
rm -rf doze
rm -rf dap
cd ../..
echo " "
echo ----------- BUILDING STARTED! -----------
echo " "
source build/envsetup.sh
lunch derp_a52q-user
mka derp

#!/bin/bash
set -e

ROOT=$(pwd)

rm -rf kernel/samsung/a13ve

git clone https://github.com/wojtekojtek/android_kernel_samsung_a13ve_1 kernel/samsung/a13ve > /dev/null 2>&1

cd kernel/samsung/a13ve

cat > arch/arm64/boot/dts/mediatek/Makefile << 'EOF'
# SPDX-License-Identifier: GPL-2.0
dtb-y += mt6768.dtb
dtb-y += a13ve/a13ve_eur_open_w00_r00.dtb

always := $(dtb-y)
subdir-y := $(dts-dirs)
clean-files := *.dtb*
EOF

export CROSS_COMPILE=$ROOT/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$ROOT/prebuilts/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y
export PATH=$ROOT/prebuilts/misc/linux-x86/libufdt:$PATH

OUT=$(pwd)/out

mkdir -p $OUT

make -C $(pwd) O=$OUT a13ve_defconfig
make -C $(pwd) O=$OUT -j$(nproc) Image.gz dtbs modules

cp $OUT/arch/arm64/boot/Image.gz $(pwd)/arch/arm64/boot/Image

cat $OUT/arch/arm64/boot/Image.gz $OUT/arch/arm64/boot/dts/mediatek/mt6768.dtb > Image.gz-dtb

if [ -f $OUT/arch/arm64/boot/dts/mediatek/a13ve/a13ve_eur_open_w00_r00.dtb ]; then
    mkdtimg create dtbo.img $OUT/arch/arm64/boot/dts/mediatek/a13ve/a13ve_eur_open_w00_r00.dtb
fi

find $OUT -name "*.ko" -exec cp {} . \;

echo "Success. Files:"
echo "cp Image.gz-dtb ../../device/samsung/a13ve/prebuilts/"
echo "cp dtbo.img ../../device/samsung/a13ve/prebuilts/"
echo "cp out/arch/arm64/boot/dts/mediatek/mt6768.dtb ../../device/samsung/a13ve/prebuilts/dtb/01_dtbdump_MT6768.dtb"
echo "find out -name '*.ko' -exec cp {} ../../device/samsung/a13ve/prebuilts/vendor-modules/ \;"
#!/bin/sh

mkdir -p /root
cd /root
test -f linux-${VERSION}.tar.xz || wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-${VERSION}.tar.xz

cd /usr/src
test -d linux-${VERSION} || tar xJvfp /root/linux-${VERSION}.tar.xz

cd /usr/src/linux-${VERSION}
test -f /data/config && cp /data/config .config
test -f .config || cp /root/config-D4C-20150519-minimal .config

patch --forward --strip=1 < /root/imx23.dtsi.diff

tty > /dev/null && make ARCH=arm CROSS_COMPILE=arm-none-eabi- menuconfig && cp .config /data/config

REL=$(make -s -j2 ARCH=arm CROSS_COMPILE=arm-none-eabi- kernelrelease)
mkdir -p /data/boot

make ARCH=arm CROSS_COMPILE=arm-none-eabi- imx23-olinuxino.dtb
mv arch/arm/boot/dts/imx23-olinuxino.dtb /data/boot/imx23-olinuxino-${REL}.dtb

make ARCH=arm CROSS_COMPILE=arm-none-eabi- zImage
mv arch/arm/boot/zImage /data/boot/zImage-${REL}

make ARCH=arm CROSS_COMPILE=arm-none-eabi- modules
make ARCH=arm CROSS_COMPILE=arm-none-eabi- modules_install INSTALL_MOD_PATH=/data

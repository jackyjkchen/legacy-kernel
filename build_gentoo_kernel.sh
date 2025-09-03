#!/bin/sh

arch=$(uname -m)

for ver in $@
do
  gcc -v && ld -v
  cd /usr/src/linux-$ver-gentoo && \
  make clean && rm -rf target_dir && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,usr/lib} && ln -sv usr/lib target_dir/lib && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=./target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_PATH=./target_dir/boot install && \
  rm -rfv  ../kernel-$ver-gentoo-cjk-${arch}.tar.xz target_dir/boot/vmlinux* && \
  tar -pcf ../kernel-$ver-gentoo-cjk-${arch}.tar -C ./target_dir ./ && \
  xz -z9ev ../kernel-$ver-gentoo-cjk-${arch}.tar || (echo Failed in kernel: $ver && exit -1)
done

echo Complete built $@.

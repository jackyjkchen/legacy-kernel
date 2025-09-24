#!/bin/sh

arch=$(uname -m)

export LANG=C

for ver in $@
do
  gcc -v && ld -v
  cd /usr/src/linux-$ver-gentoo && \
  make clean && rm -rf target_dir && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,lib} && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=./target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_PATH=./target_dir/boot install || (echo Failed in kernel: $ver && exit -1)
  [[ ${arch} == "mips64" ]] && rm -rf ./target_dir/boot/vmlinux*
  rm -rfv  ../kernel-$ver-gentoo-cjk-${arch}.tar.bz2 && \
  tar -pcf ../kernel-$ver-gentoo-cjk-${arch}.tar -C ./target_dir ./ && \
  bzip2 -z9v ../kernel-$ver-gentoo-cjk-${arch}.tar
done

echo Complete built $@.

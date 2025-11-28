#!/bin/sh

source /usr/lib/portage/*/version-functions.sh

arch=$(uname -m)
path_orig=$PATH

export LANG=C

for ver in $@
do
  kver=$(ver_cut 1-2 ${ver})
  export PATH=/usr/src/legacy-kernel/${kver}/toolchain-${arch}:${path_orig}
  gcc -v && ld -v
  cd /usr/src/linux-$ver-gentoo && \
  make clean && rm -rf target_dir && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,usr/lib} && ln -sv usr/lib target_dir/lib && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${PWD}/target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_PATH=${PWD}/target_dir/boot install || (echo Failed in kernel: $ver && exit -1)
  [[ ${arch} == "mips64" ]] && rm -rf ./target_dir/boot/vmlinux*
  rm -rfv  ../kernel-$ver-gentoo-cjk-${arch}.tar.xz && \
  tar -pcf ../kernel-$ver-gentoo-cjk-${arch}.tar -C ./target_dir ./ && \
  xz -z9ev ../kernel-$ver-gentoo-cjk-${arch}.tar
done

echo Complete built $@.

#!/bin/bash

for ver in $@
do
  if [[ ${ver} > "2.6.0" ]]
  then
    arch=x86_64
    gentoo="-gentoo"
    make_deps=true
	target=
  elif [[ ${ver} > "2.4.0" ]]
  then
    arch=i686pae
    gentoo=
    make_deps="make dep"
	target="bzImage modules"
  else
    arch=i686
    gentoo=
    make_deps="make dep"
	target="bzImage modules"
  fi
  gcc -v && ld -v
  cd /usr/src/linux-${ver}${gentoo} && \
  make clean && rm -rf target_dir && \
  ${make_deps} && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" ${target} -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,lib} && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${PWD}/target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_PATH=${PWD}/target_dir/boot install || (echo Failed in kernel: $ver && exit -1)
  rm -rfv ../kernel-${ver}${gentoo}-cjk-${arch}.tar.bz2 && \
  tar -pcf ../kernel-${ver}${gentoo}-cjk-${arch}.tar -C ./target_dir ./ && \
  bzip2 -z9v ../kernel-${ver}${gentoo}-cjk-${arch}.tar
done

echo Complete built $@.

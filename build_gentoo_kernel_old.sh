#!/bin/bash

for ver in $@
do
  if [[ ${ver} > "2.6.27" ]]
  then
    arch=x86_64
    compress=xz
    compress_args="-z9ev"
    gentoo="-gentoo"
    make_deps=true
  elif [[ ${ver} > "2.6.0" ]]
  then
    arch=i686pae
    compress=bzip2
    compress_args="-z9v"
    gentoo="-gentoo"
    make_deps=true
  elif [[ ${ver} > "2.4.0" ]]
  then
    arch=i686pae
    compress=bzip2
    compress_args="-z9v"
    gentoo=
    make_deps="make dep"
  else
    arch=i686
    compress=bzip2
    compress_args="-z9v"
    gentoo=
    make_deps="make dep"
  fi
  echo arch=${arch}
  echo compress=${compress}
  echo compress_args=${compress_args}
  echo gentoo=${gentoo}
  sleep 1
  gcc -v && ld -v
  cd /usr/src/linux-${ver}${gentoo} && \
  make clean && \
  ${make_deps} && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC=${HOSTCC-gcc} -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,lib} && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC=${HOSTCC-gcc} INSTALL_MOD_PATH=./target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC=${HOSTCC-gcc} INSTALL_PATH=./target_dir/boot install && \
  rm -rfv ../kernel-${ver}${gentoo}-cjk-${arch}.tar.xz && \
  tar -pcf ../kernel-${ver}${gentoo}-cjk-${arch}.tar -C ./target_dir ./ && \
  ${compress} ${compress_args} kernel-${ver}${gentoo}-cjk-${arch}.tar || (echo Failed in kernel: ${ver} && exit -1)
done

echo Complete built $@.

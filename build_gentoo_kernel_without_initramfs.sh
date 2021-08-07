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
  make -j`cat /proc/cpuinfo | grep process | wc -l` && \
  rm -rfv /lib/modules/*${ver}* && \
  make modules_install && \
  rm -rfv /boot/*${ver}* && \
  make install && \
  cd / && rm -rfv /usr/src/kernel-${ver}${gentoo}-cjk-${arch}.tar.xz && \
  tar -pcvf /usr/src/kernel-${ver}${gentoo}-cjk-${arch}.tar boot/config*${ver}* boot/System*${ver}* boot/vmlinuz*${ver}* lib/modules/${ver}${gentoo}-cjk-${arch} && \
  ${compress} ${compress_args} /usr/src/kernel-${ver}${gentoo}-cjk-${arch}.tar || (echo Failed in kernel: ${ver} && exit -1)
done

echo Complete built $@.

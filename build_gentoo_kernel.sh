#!/bin/sh

for ver in $@
do
  gcc -v && ld -v
  cd /usr/src/linux-$ver-gentoo && \
  make clean && \
  make -j`cat /proc/cpuinfo | grep process | wc -l` && \
  rm -rfv /lib/modules/*$ver* && \
  make modules_install && \
  rm -rfv /boot/*$ver* && \
  make install && \
  genkernel --install initramfs --kerneldir=/usr/src/linux-$ver-gentoo && \
  cd / && rm -rfv /usr/src/kernel-$ver-gentoo-cjk-x86_64.tar.xz && \
  tar -pcvf /usr/src/kernel-$ver-gentoo-cjk-x86_64.tar boot/config*$ver* boot/System*$ver* boot/vmlinuz*$ver* lib/modules/$ver-gentoo*-cjk-x86_64 && \
  xz -z9ev /usr/src/kernel-$ver-gentoo-cjk-x86_64.tar || (echo Failed in kernel: $ver && exit -1)
done

echo Complete built $@.

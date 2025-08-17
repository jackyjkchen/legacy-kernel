#!/bin/sh

case ${0} in
  *_loongson3.sh)
    arch="loongson3"
    ;;
  *)
    arch="x86_64"
    ;;
esac

mount -t tmpfs tmpfs /boot
for ver in $@
do
  [[ $ver < 3.0 ]] && nocompress="--no-compress-initramfs"
  gcc -v && ld -v
  cd /usr/src/linux-$ver-gentoo && \
  make clean && rm -rf target_dir && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" -j`cat /proc/cpuinfo | grep process | wc -l` && \
  mkdir -p target_dir/{boot,usr/lib} && ln -sv usr/lib target_dir/lib && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=./target_dir modules_install && \
  make CROSS_COMPILE=${CROSS_COMPILE} HOSTCC="${HOSTCC-gcc}" INSTALL_PATH=./target_dir/boot install && \
  genkernel initramfs --kernel-modules-prefix=./target_dir --kerneldir=/usr/src/linux-$ver-gentoo $nocompress && \
  if [[ $ver == 2.6.32.* ]]; then lzma -z9ev /boot/initramfs-$ver-gentoo-cjk-${arch}.img && mv /boot/initramfs-$ver-gentoo-cjk-${arch}.img.lzma /boot/initramfs-$ver-gentoo-cjk-${arch}.img; fi && \
  mv -v /boot/initramfs-$ver-gentoo-cjk-${arch}.img ./target_dir/boot/ && \
  rm -rfv  ../kernel-$ver-gentoo-cjk-${arch}.tar.xz && \
  tar -pcf ../kernel-$ver-gentoo-cjk-${arch}.tar -C ./target_dir ./ && \
  xz -z9ev ../kernel-$ver-gentoo-cjk-${arch}.tar || (echo Failed in kernel: $ver && exit -1)
done
umount /boot

echo Complete built $@.

#!/bin/bash

declare -A IMAGE_DICT

IMAGE_DICT=(
  ["x64"]="rootfs-gentoo-allgcc-sandybridge-x86_64"
  ["x86"]="rootfs-gentoo-allgcc-core2-x86"
  ["xfce"]="rootfs-gentoo-xfce-sandybridge-x86_64"
  ["aarch64"]="rootfs-gentoo-allgcc-generic-aarch64"
  ["armhf"]="rootfs-gentoo-allgcc-generic-armv7hf"
  ["armel"]="rootfs-gentoo-allgcc-generic-armv5tel"
  ["loong"]="rootfs-gentoo-allgcc-generic-loongarch"
  ["mips64el"]="rootfs-gentoo-allgcc-multilib-mips64el"
  ["mips64"]="rootfs-gentoo-allgcc-multilib-mips64"
  ["ppc64le"]="rootfs-gentoo-allgcc-power9-ppc64le"
  ["ppc64"]="rootfs-gentoo-allgcc-generic-ppc64"
  ["ppc"]="rootfs-gentoo-allgcc-generic-ppc"
  ["alpha"]="rootfs-gentoo-allgcc-generic-alpha"
  ["riscv64"]="rootfs-gentoo-allgcc-multilib-riscv64"
  ["sparc64"]="rootfs-gentoo-allgcc-multilib-sparc64"
  ["s390x"]="rootfs-gentoo-allgcc-ibm-s390x"
  ["hppa1.1"]="rootfs-gentoo-allgcc-generic-hppa1.1"
  ["sh4"]="rootfs-gentoo-allgcc-generic-sh4"
  ["m68k"]="rootfs-gentoo-allgcc-generic-m68k"
  ["debian"]="rootfs-debian-testing-x86_64"
  ["archlinux"]="rootfs-archlinux-x86_64"
  ["opensuse"]="rootfs-opensuse-tumbleweed-x86_64"
)

dir=$1
image=${IMAGE_DICT[$dir]}
find $dir/ | grep '\.pyc\|\.pyo\|\.keep\|\.bash_history\|\.nfs0' | xargs rm -v
setcap cap_net_raw=ep $dir/bin/arping
setcap cap_net_raw=ep $dir/bin/ping
setcap cap_net_raw=ep $dir/usr/bin/arping
setcap cap_net_raw=ep $dir/usr/bin/ping
setcap cap_dac_override=ep $dir/sbin/unix_chkpwd
rm -v $dir/usr/local/bin/qemu-*
dest=$2
if [[ $dest == "" ]]; then
    dest=.
fi
dlist=
cd $dir && dlist=$(echo *) && cd ..
rm -v $image.tar
tar --numeric-owner --xattrs -pcf $dest/$image.tar -C $dir $dlist
rm -v $image.tar.xz
exit 0

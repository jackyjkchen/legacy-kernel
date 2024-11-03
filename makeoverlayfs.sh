#!/bin/sh

kernel=$1
if [[ $kernel == "" ]]; then
    exit -1
fi
lower=linux-$kernel
tmpfs=$lower-tmpfs
upper=$tmpfs/upper
work=$tmpfs/work
merge=$tmpfs/merge
target=$lower-gentoo
umount -R $target $merge $tmpfs > /dev/null 2>&1
mkdir -p $tmpfs
mount -t tmpfs tmpfs $tmpfs
mkdir -p $upper $work $merge $target > /dev/null 2>&1
mount -t overlay overlay -o lowerdir=$lower,upperdir=$upper,workdir=$work $merge
mount --bind $merge $target

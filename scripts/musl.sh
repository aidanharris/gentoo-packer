#!/bin/bash

[[ -z "$STDLIB" ]] && exit 1

source "$STDLIB" || exit 1

mkdir -p /mnt/gentoo/var/lib/layman || errexit "error creating the /mnt/gentoo/var/lib/layman directory"

cd /mnt/gentoo/var/lib/layman || errexit "error changing directory to /mnt/gentoo/var/lib/layman"
wget -q "https://github.com/gentoo/musl/archive/master.tar.gz" || errexit "error downloading tarball"
tar xpf "master.tar.gz" --xattrs-include='*.*' --numeric-owner || errexit "error extracting tarball"
mv musl-master musl || errexit "error re-naming musl-master to portage"
rm -f "master.tar.gz"

mkdir -p /mnt/gentoo/etc/portage/repos.conf || errexit "error creating the /mnt/gentoo/etc/portage/repos.conf directory"

chroot /mnt/gentoo /bin/bash -e << EOF
cat >> /etc/portage/repos.conf/layman.conf <<'DATA'
[musl]
priority = 50
location = /var/lib/layman/musl
layman-type = git
auto-sync = No

DATA

emerge -uvNDq world
EOF

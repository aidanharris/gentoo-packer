#!/bin/bash

chroot /mnt/gentoo /bin/bash <<'EOF'
cd /usr/src/linux && make clean
emerge -C sys-kernel/gentoo-sources
emerge --depclean
EOF

rm -rf /mnt/gentoo/usr/portage
rm -rf /mnt/gentoo/tmp/*
rm -rf /mnt/gentoo/var/log/*
rm -rf /mnt/gentoo/var/tmp/*

chroot /mnt/gentoo /bin/bash <<'EOF'
mkdir zerofree
cd zerofree
wget https://github.com/aidanharris/gentoo-packer/releases/download/0.0.0-zerofree/zerofree-1.0.4.tar.bz
tar xvf zerofree-*.tar.bz
rm -rf ./*.tar.bz
EOF

mv /mnt/gentoo/zerofree* ./
cd zerofree*/

mount -o remount,ro /mnt/gentoo
./sbin/zerofree ${DISK}4

swapoff ${DISK}3
dd if=/dev/zero of=${DISK}3
mkswap ${DISK}3

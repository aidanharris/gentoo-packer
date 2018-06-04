#!/bin/bash

cp "$SCRIPTS/scripts/kernel.config" /mnt/gentoo/tmp/

genkernel="${genkernel:-sys-kernel/genkernel}"
genkernel_args="${genkernel_args:---install --symlink --no-zfs --no-btrfs --oldconfig all}"

chroot /mnt/gentoo /bin/bash <<"EOF"
set -e
mkdir -p /etc/portage/package.keywords
echo "$kernel ~amd64" >> /etc/portage/package.keywords/zz-autounmask
emerge "$kernel" $genkernel
cd /usr/src/linux || exit 1
mv /tmp/kernel.config .config
EOF


chroot /mnt/gentoo /bin/bash <<"EOF"
cd /usr/src/linux || exit 1
make olddefconfig || exit 1
genkernel $genkernel_args || {
  echo 'genkernel failed:'
  cat /var/log/genkernel.log
  exit 1
}
emerge -c sys-kernel/genkernel
EOF


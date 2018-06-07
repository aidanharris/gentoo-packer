#!/bin/bash

lsblk -a

chroot /mnt/gentoo /bin/bash <<'EOF'
sed -i 's/^#\s*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0"/' \
  /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# This is untested
# To Do:
#   * Test that networking works correctly with systemd
# Note: This takes an "either systemd or openrc" approach. What if both openrc and systemd are installed?
if chroot /mnt/gentoo /bin/bash -c 'command -v systemctl > /dev/null 2>&1'
then
  chroot /mnt/gentoo /bin/bash -c 'emerge net-misc/dhcpcd && systemctl enable dhcpcd.service'
else
chroot /mnt/gentoo /bin/bash <<'EOF'
ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
echo 'config_eth0=( "dhcp" )' >> /etc/conf.d/net
rc-update add net.eth0 default
EOF
fi

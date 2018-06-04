#!/bin/bash

[[ -z "$STDLIB" ]] && exit 1

source "$STDLIB" || exit 1

chroot /mnt/gentoo /bin/bash <<'EOF'
USE="-sendmail" emerge app-admin/sudo
emerge net-fs/nfs-utils net-fs/sshfs dev-vcs/git app-portage/layman app-portage/gentoolkit app-portage/genlop app-portage/pfl sys-process/htop app-misc/tmux app-misc/jq app-text/xmlstarlet sys-process/parallel
useradd -m -s /bin/bash vagrant
echo vagrant:vagrant | chpasswd
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
mkdir -p ~vagrant/.ssh
wget https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub \
  -O ~vagrant/.ssh/authorized_keys
chmod 0700 ~vagrant/.ssh
chmod 0600 ~vagrant/.ssh/authorized_keys
chown -R vagrant: ~vagrant/.ssh
EOF

enable_service sshd

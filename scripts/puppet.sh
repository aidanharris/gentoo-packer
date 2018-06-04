#!/bin/bash

chroot /mnt/gentoo /bin/bash <<'EOF'
emerge app-admin/puppet
puppet module install gentoo-portage
EOF

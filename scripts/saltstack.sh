#!/bin/bash

mkdir -p /mnt/gentoo/etc/portage/package.use
mkdir -p /mnt/gentoo/etc/portage/package.keywords

cat << 'EOF' >> /mnt/gentoo/etc/portage/package.keywords/salt
app-admin/salt ~amd64
EOF

chroot /mnt/gentoo /bin/bash <<'EOF'
emerge app-admin/salt
EOF

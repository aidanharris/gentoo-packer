#!/bin/bash

mkdir -p /mnt/gentoo/etc/portage/package.use
mkdir -p /mnt/gentoo/etc/portage/package.keywords

cat << 'EOF' >> /mnt/gentoo/etc/portage/package.keywords/ansible
dev-libs/libsodium ~amd64
dev-python/pynacl ~amd64
EOF

cat << 'EOF' >> /mnt/gentoo/etc/portage/package.use/python
dev-lang/python sqlite
EOF

chroot /mnt/gentoo /bin/bash <<'EOF'
emerge app-admin/ansible
EOF

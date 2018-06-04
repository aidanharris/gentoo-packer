#!/bin/bash

# Bye-bye nano...
chroot /mnt/gentoo /bin/bash <<'EOF'
ln -s /bin/busybox /bin/vi
eselect editor set vi
emerge -C nano
EOF

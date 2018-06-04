#!/bin/bash

# You can override the variables below in config.sh
chroot /mnt/gentoo /bin/bash <<EOF
cat > /etc/portage/make.conf <<DATA
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
CFLAGS="${CFLAGS:--Os -pipe}"
CXXFLAGS="${CXXFLAGS:--Os -pipe}"
MAKEOPTS="${MAKEOPTS:--j\$((\$(nproc)+1))}"

PYTHON_TARGETS="${PYTHON_TARGETS:-python2_7 python3_6}"

PORTDIR="${PORTDIR:-/usr/portage}"
DISTDIR="${DISTDIR:-/usr/portage/distfiles}"
PKGDIR="${PKGDIR:-/usr/portage/packages}"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=${LC_MESSAGES:-C}

USE="${USE:-minimal -doc ${SSL_LIB:-openssl}}"
DATA
EOF


#!/bin/bash

SSL_LIB="${SSL_LIB:-openssl}"

mkdir -p /mnt/gentoo/etc/portage/package.use
mkdir -p /mnt/gentoo/etc/portage/package.keywords

[[ "$SSL_LIB" == "openssl" ]] && {
cat << 'EOF' >> /mnt/gentoo/etc/portage/package.keywords/openssl
# required by net-misc/curl-7.60.0::gentoo
# required by app-crypt/gnupg-2.2.4-r2::gentoo
# required by dev-vcs/git-2.16.1::gentoo[gpg]
# required by app-portage/layman-2.4.2-r1::gentoo[git]
# required by layman (argument)
=dev-libs/openssl-1.0.2o-r2 ~amd64
EOF

cat << 'EOF' >> /mnt/gentoo/etc/portage/package.use/openssl
dev-libs/openssl -bindist
EOF

chroot /mnt/gentoo /bin/bash <<'EOF'
emerge dev-libs/openssl net-misc/curl net-misc/openssh
EOF
} || {
[[ "$SSL_LIB" == "libressl" ]] || exit 1
# https://wiki.gentoo.org/wiki/Project:LibreSSL
chroot /mnt/gentoo /bin/bash <<'EOF'
set -e
echo 'USE="${USE} libressl"' >> /etc/portage/make.conf
mkdir -p /etc/portage/package.mask
echo "dev-libs/openssl" >> /etc/portage/package.mask/openssl
emerge -f libressl
emerge -C openssl net-misc/curl
echo 'CURL_SSL="libressl"' >> /etc/portage/make.conf
emerge -1q openssh wget python:2.7 python:3.6 iputils net-misc/curl
emerge --tree @preserved-rebuild
EOF
}

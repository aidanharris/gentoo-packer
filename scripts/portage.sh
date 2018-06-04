#!/bin/bash

# Uncomment to use a snapshot instead of the latest tarball from github.
# Note: if you uncomment this you should comment out all of the other code
# below it.
#chroot /mnt/gentoo /bin/bash <<'EOF'
#mkdir /usr/portage
#emerge-webrsync
#EOF

[[ -z "$STDLIB" ]] && exit 1

source "$STDLIB" || exit 1

cd /mnt/gentoo/usr || errexit "error changing directory to /mnt/gentoo/usr"
wget -q "https://github.com/gentoo/gentoo/archive/master.tar.gz" || errexit "error downloading tarball"
tar xpf "master.tar.gz" --xattrs-include='*.*' --numeric-owner || errexit "error extracting tarball"
mv gentoo-master portage || errexit "error re-naming gentoo-master to portage"
rm -f "master.tar.gz"

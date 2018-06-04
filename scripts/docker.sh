#!/bin/bash

[[ -z "$STDLIB" ]] && exit 1

source "$STDLIB" || exit 1

_install_docker() {
chroot /mnt/gentoo /bin/bash <<'EOF'
emerge app-emulation/docker
EOF
}

_enable_docker() {
enable_service docker
}

_install_docker_compose() {
chroot /mnt/gentoo /bin/bash <<'EOF'
emerge app-emulation/docker-compose
EOF
}

_install_docker
_install_docker_compose
_enable_docker

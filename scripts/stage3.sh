#!/bin/bash

VERIFY_STAGE3="${VERIFY_STAGE3:-1}"

[[ -z "$STDLIB" ]] && exit 1

source "$STDLIB" || exit 1

if [[ "$VERIFY_STAGE3" -eq 1 ]]
then
  # https://wiki.gentoo.org/wiki/Project:RelEng#Keys
  GPG_KEYS="${GPG_KEYS:-DB6B8C1F96D8BF6D BB572E0E2D182910}"

  [[ -z "$GPG_KEYS" ]] && errexit "empty \$GPG_KEYS: $GPG_KEYS"

  # shellcheck disable=SC2086
  gpg --recv-keys $GPG_KEYS
fi

[[ -z "$tarball" ]] && errexit "tarball is not defined"
[[ -z "$tarball_url" ]] && errexit "tarball_url is not defined"

mount "${DISK}4" /mnt/gentoo

cd /mnt/gentoo || errexit "error changing directory to /mnt/gentoo"
wget -q "$tarball_url/$tarball" || errexit "error downloading tarball"
tar xpf "$tarball" --xattrs-include='*.*' --numeric-owner || errexit "error extracting tarball"
rm -f "$tarball"

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
  gpg --recv-keys $GPG_KEYS || errexit "failed to fetch the following gpg keys: $GPG_KEYS"
fi

[[ -z "$tarball" ]] && errexit "tarball is not defined"
[[ -z "$tarball_url" ]] && errexit "tarball_url is not defined"

mount "${DISK}4" /mnt/gentoo

cd /mnt/gentoo || errexit "error changing directory to /mnt/gentoo"
wget -q "$tarball_url/$tarball" || errexit "error downloading tarball"

if [[ "$VERIFY_STAGE3" -eq 1 ]]
then
  wget -q "$tarball_url/${tarball}.DIGESTS" || errexit "error downloading tarball DIGESTS"
  wget -q "$tarball_url/${tarball}.DIGESTS.asc" && {
    gpg --verify "${tarball}.DIGESTS.asc" || errexit "unable to verify tarball DIGESTS"
  } || errwarn "failed to download signature for DIGESTS continuing anyway.
NOTE: This may be expected in the case of certain experimental stages like musl which do not come with gpg signatures"

  if [[ -f "${tarball}.DIGESTS.asc" ]]
  then
    # The file isn't encrypted but `gpg --decrypt` strips the signature which is exactly what we want since we trust
    # the signed DIGESTS more than the un-signed DIGESTS
    gpg --decrypt "${tarball}.DIGESTS.asc" > "${tarball}.DIGESTS"
  fi

  SHA512_A="$(sha512sum "$tarball" | awk '{print $1}')"
  SHA512_B="$(grep -E '^# SHA512 HASH' -A1 "${tarball}.DIGESTS" | grep -oE '.*stage(3|4).*\.tar\.(bz(2)?|xz)$' | awk '{print $1}')"

  [[ "$SHA512_A" == "$SHA512_B" ]] || errexit "sha512sum ($SHA512_A) from $tarball does not match sha512sum ($SHA512_B) from ${tarball}.DIGESTS"
fi

tar xpf "$tarball" --xattrs-include='*.*' --numeric-owner || errexit "error extracting tarball"
rm -f "$tarball"

#!/bin/sh

# https://wiki.gentoo.org/wiki/Project:RelEng#Keys
GPG_KEYS="DB6B8C1F96D8BF6D BB572E0E2D182910"

gpg --recv-keys $GPG_KEYS # shellcheck disable=SC2086

TMP="$(mktemp -d)"

banner="================================================================"

cd "$TMP" || exit 1

curl -s -L https://gentoo.org/downloads | grep -oE 'http://distfiles.gentoo.org/releases/amd64/.*(.bz2|.xz|.iso)' | sed 's/".*//g' | while read -r line
do
  curl -s -O "${line}.DIGESTS" || {
    echo "Error fetching ${line}.DIGESTS" >&2
    continue
  }

  curl -s -O "${line}.DIGESTS.asc" || {
    echo "Error fetching ${line}.DIGESTS.asc" >&2
    continue
  }

  if gpg --verify "$(basename "${line}.DIGESTS.asc")" > /dev/null 2>&1
  then
    printf "\\n\\n%s\\n%s\\n%s\\n\\n%s\\n\\n%s\\n" "$banner" "$(basename "$line")" "$banner" "$line" "$(cat "$(basename "${line}.DIGESTS")")"
  else
    echo "Error verifying signature of $line" >&2
  fi
done

rm -rf "$TMP"

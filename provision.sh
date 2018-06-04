#!/bin/bash

[[ "$VM_TYPE" == "qemu" ]] && DISK=/dev/vda || DISK=/dev/sda

export DISK

if [[ -z "$STAGE3" ]]
then
  echo "STAGE3 environment variable must be set to a timestamp."
  exit 1
fi

if [[ -z "$SCRIPTS" ]]
then
  SCRIPTS=.
fi

chmod +x "$SCRIPTS/scripts/*.sh"

[[ -n "$_TARBALL" ]] && export tarball="$_TARBALL"
[[ -n "$_TARBALL_URL" ]] && export tarball_url="$_TARBALL_URL"

source "$SCRIPTS/scripts/config.sh" || exit 1

export STDLIB="$SCRIPTS/scripts/stdlib.sh"

. "$STDLIB"

for script in "${scripts[@]}"
  do
  [[ -f "$SCRIPTS/scripts/$script.sh" ]] && {
    "$SCRIPTS/scripts/$script.sh" || errexit "scripts/$script.sh failed to execute"
  }
done

echo "All done."

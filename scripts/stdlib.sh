#!/bin/bash

# Prints a message and exits with an error code
errexit() {
  [[ -n "$1" ]] && printf "%s\\n" "$1" > /dev/stderr
  [[ -z "$2" ]] && exitcode=1 || exitcode="$2"

  exit "$exitcode"
}

# Like errexit only just a warning
errwarn() {
  [[ -n "$1" ]] && printf "%s\\n" "$1" > /dev/stderr

  return 0
}

# shellcheck disable=SC2154
[[ -z "$enable_service_command" ]] && errexit "No enable_service_command is defined"

# Enables a service in the chroot using a pre-defined template
# This allows us to abstract away the logic for enabling a service
# For OpenRC enable_service_command should be as follows:
#   enable_service_command="rc-update add {{service}} default"
# For SystemD the following should be used:
#   enable_service_command="systemctl enable {{service}}"
# This command should be placed inside of config.sh
enable_service() {
  [[ "$#" -eq 0 ]] && return 1

  for service in "$@"
  do
    cmd="$(sed "s|{{service}}|$service|g" <<< "$enable_service_command")"
    chroot /mnt/gentoo /bin/bash -c "$cmd"
  done
}

#!/bin/bash

# shellcheck disable=SC2207

# To Do:
#   * Verify the checksum instead of blindly trusting the stage3

# AMD64-no-multilib
#[[ -z "$tarball" ]] && export tarball="$(wget -qO- http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-nomultilib.txt | tail -1 | xargs | awk '{print $1}' | rev | awk -F'/' '{print $1}' | rev)"
#[[ -z "$tarball_url" ]] && export tarball_url="${tarball_url:-http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-nomultilib}"

# Systemd AMD64
#export tarball_url="${tarball_url:-http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd}"
#export tarball="$(wget -qO- http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt | tail -1 | xargs | awk '{print $1}' | rev | awk -F'/' '{print $1}' | rev)"

# Vanilla Musl
#export tarball_url="http://distfiles.gentoo.org/experimental/amd64/musl"
#export tarball="$(wget -qO- http://distfiles.gentoo.org/experimental/amd64/musl | grep -ohE 'href=.*">' | grep -ohE 'stage3-.*\.tar.(bz2|xz)"' | sed 's/"//g' | grep vanilla | tail -1)"

# Vanilla Uclibc
#export tarball="$(wget -qO- http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-uclibc-vanilla.txt | tail -1 | xargs | awk '{print $1}' | rev | awk -F'/' '{print $1}' | rev)"
#export tarball_url="${tarball_url:-http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-uclibc-vanilla}"

#export SSL_LIB="${SSL_LIB:-openssl}"
export SSL_LIB="${SSL_LIB:-libressl}"
export kernel="${kernel:-=sys-kernel/gentoo-sources-4.14.48}"
if grep -q -i systemd <<< "$tarball"
then
  export enable_service_command="${enable_service_command:-systemctl enable {{service\}\}}"
else
  export enable_service_command="${enable_service_command:-rc-update add {{service\}\} default}"
fi

# Set to sys-kernel/genkernel-next if you want to use that instead
export genkernel=sys-kernel/genkernel

# Genkernel CANNOT build an initramfs when using genkernel. Luckily we don't need one anyway.
# To Do:
#   * It'd be nice to have an initramfs with busybox for recovery purposes. See if dracut works?
export genkernel_args="--install --symlink --no-zfs --no-btrfs --bootloader=grub --makeopts=-j$(($(nproc)+1)) --no-busybox --oldconfig kernel"

[[ -z "$scripts" ]] && scripts=(
  partition `# partitions the disk using ext4`
  stage3    `# downloads and extracts the stage3`
  mounts    `# mounts the proc,sys,dev,etc partitions for our chroot`
  resolv.conf `# copies /etc/resolv.conf so dns works`
  portage `# syncs the gentoo tree using emerge-webrsync`
  $(grep -q musl <<< "$tarball" && printf 'musl') `# This adds the musl overlay when using a musl stage3 - Important otherwise compile failures occur when upgrading`
  make.conf `# copies our modified make.conf to /etc/portage/make.conf`
  timezone `# sets the timezone to UTC`
  fstab `# creates the /etc/fstab file`
  kernel `# installs and builds the kernel`
  grub `# installs and configures grub`
  "$VM_TYPE" `# optional VM specific configuration e.g install virtualbox tools for virtualbox. Does nothing if the file scripts/$VM_TYPE doesn't exist`
  network `# Configures networking to use dhcp - To Do: Add systemd configuration`
  ssl `# Installs openssl/libressl`
  vagrant
  #saltstack
  #ansible
  #"$([[ "$SSL_LIB" == "openssl" ]] && printf 'puppet')"
  #docker
  editor `# Removes nano and replaces it with busybox's vi`
  cleanup
) || {
  read -a scripts <<< "${scripts[@]}"
}

export scripts

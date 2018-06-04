PACKER=packer
WGET=wget
BUILDER=qemu.json
ARCH=amd64

all: $(ARCH) $(ARCH)_nomultilib $(ARCH)_systemd $(ARCH)_musl $(ARCH)_uclibc

$(ARCH):
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH).txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)" $(BUILDER)

$(ARCH)_nomultilib:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-nomultilib.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-nomultilib" $(BUILDER)

$(ARCH)_systemd:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-systemd.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-systemd" $(BUILDER)

$(ARCH)_musl:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/experimental/$(ARCH)/musl | grep -ohE 'href=.*\">' | grep -ohE 'stage3-.*\.tar.(bz2|xz)"' | sed 's/\"//g' | grep vanilla | tail -1)" -var "tarball_url=http://distfiles.gentoo.org/experimental/$(ARCH)/musl" $(BUILDER)

$(ARCH)_uclibc:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-uclibc-vanilla.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-uclibc-vanilla" $(BUILDER)


PACKER=packer
WGET=wget
BUILDER=qemu.json
ARCH=amd64

.PHONY: clean

all: clean $(ARCH) $(ARCH)_nomultilib $(ARCH)_systemd $(ARCH)_musl $(ARCH)_uclibc

$(ARCH):
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH).txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)" $(BUILDER)

$(ARCH)_nomultilib:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-nomultilib.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-nomultilib" -var "box=-$(ARCH)_no-multilib" $(BUILDER)

$(ARCH)_systemd:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-systemd.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-systemd" -var "box=-$(ARCH)_systemd" $(BUILDER)

$(ARCH)_musl:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/experimental/$(ARCH)/musl | grep -ohE 'href=.*\">' | grep -ohE 'stage3-.*\.tar.(bz2|xz)"' | sed 's/\"//g' | grep vanilla | tail -1)" -var "tarball_url=http://distfiles.gentoo.org/experimental/$(ARCH)/musl" -var "box=-$(ARCH)_musl" $(BUILDER)

$(ARCH)_uclibc:
	$(PACKER) build -var "tarball=$$($(WGET) -qO- http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/latest-stage3-$(ARCH)-uclibc-vanilla.txt | tail -1 | xargs | awk '{print $$1}' | rev | awk -F'/' '{print $$1}' | rev)" -var "tarball_url=http://distfiles.gentoo.org/releases/$(ARCH)/autobuilds/current-stage3-$(ARCH)-uclibc-vanilla" -var "box=-$(ARCH)_uclibc" $(BUILDER)

sign:
	rm -rf *.box.sig
	find . -maxdepth 1 -type f -name "*.box" -print0 | xargs -r -0 --max-procs=$$(nproc) -I'{}' gpg --armor --output {}.sig --detach-sign {}
	find . -maxdepth 1 -type f -name "*.box" -print0 | xargs -r -0 --max-procs=$$(nproc) -I'{}' gpg --verify {}.sig {}

clean:
	rm -rf output-qemu

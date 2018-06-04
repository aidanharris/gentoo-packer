# Gentoo - A not so Minimal Vagrant Box

This is *not* the most minimal stage3 installation of Gentoo (amd64, nomultilib) that
is possible to package into a Vagrant box file. VirtualBox and VMWare versions
are provided (although untested). Qemu support is the primary reason for this fork.

> **Note:** Currently the VMWare Fusion version has no vmware-tools installed,
> but NFS mounts should work fine.

## Supported Profiles

You can change the stage3 used in config.sh the following have been tested and known to work:

* [AMD64 no-multilib](http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-nomultilib/)
* [AMD64 Systemd](http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/)
* [Vanilla Musl (AMD64)](http://distfiles.gentoo.org/experimental/amd64/musl/)
* [Vanilla Uclibc (AMD64)](http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-uclibc-vanilla/)

The following have **not** been tested but may work:

* Stage4's
* Hardened stage3's (e.g SELinux, the kernel is built with support for both AppArmor and SELinux but this configuration has not been tested)
* X32 and Multilib

## What's in the box

* sys-kernel/gentoo-sources (The latest [LTS Linux Kernel](https://www.kernel.org). You can choose the kernel to install in [config.sh](#) and edit the kernel config in [scripts/kernel.config](#). Before installing the kernel we do a `make olddefconfig` so in theory you should be able to change the kernel version in config.sh to an older or newer kernel and Linux's build system will "Do the right thing™")
* [app-emulation/virtualbox-guest-additions](https://packages.gentoo.org/packages/app-emulation/virtualbox-guest-additions) (only present in the virtualbox image)
* [app-admin/sudo](https://packages.gentoo.org/packages/app-admin/sudo)
* [app-emulation/docker](https://packages.gentoo.org/packages/app-emulation/docker) and [app-emulation/docker-compose](https://packages.gentoo.org/packages/app-emulation/docker-compose)
* [app-admin/salt](https://packages.gentoo.org/packages/app-admin/salt)
* [app-admin/ansible](https://packages.gentoo.org/packages/app-admin/ansible)
* [app-admin/puppet](https://packages.gentoo.org/packages/app-admin/puppet)
* [sys-process/htop](https://packages.gentoo.org/packages/sys-process/htop)
* [app-misc/tmux](https://packages.gentoo.org/packages/app-misc/tmux)
* [app-misc/jq](https://packages.gentoo.org/packages/app-misc/jq)
* [app-text/xmlstarlet](https://packages.gentoo.org/packages/app-text/xmlstarlet)
* [sys-apps/moreutils](https://packages.gentoo.org/packages/sys-apps/moreutils)
* [sys-process/parallel](https://packages.gentoo.org/packages/sys-process/parallel)
* [dev-vcs/git](https://packages.gentoo.org/packages/dev-vcs/git)
* [net-misc/curl](https://packages.gentoo.org/packages/net-misc/curl)
* [app-portage/layman](https://packages.gentoo.org/packages/app-portage/layman)
* [app-portage/gentoolkit](https://packages.gentoo.org/packages/app-portage/gentoolkit)
* [app-portage/genlop](https://packages.gentoo.org/packages/app-portage/genlop)
* [app-portage/pfl](https://packages.gentoo.org/packages/app-portage/pfl)
* [dev-libs/openssl](https://packages.gentoo.org/packages/dev-libs/openssl) (I have plans to include support for libressl too)
* [net-fs/nfs-utils](https://packages.gentoo.org/packages/net-fs/nfs-utils), [net-fs/sshfs](https://packages.gentoo.org/packages/net-fs/sshfs) and support for [VirtFS](https://wiki.qemu.org/Documentation/9psetup#Starting_the_Guest_directly)

All of the above is included in the provided base-box but you're free to modify provision.sh and build the image locally to exclude any tools you don't want/need (in fact I'd recommend you do that anyway to make sure things still work and can be built correctly, if not [file an issue](#)).

## Box URL

**To Do**

## Usage

This is a [Packer](https://packer.io/) template. Install the latest version of
Packer (if you're running Gentoo this is just a simple `emerge app-emulation/packer`), then:

    `packer build qemu.json`

This will chew for a bit and finally output a Vagrant box file.

You should run the `get_latest_releases.sh` script first which will print the latest stage3's and isos that are available (it also verifies the checksum file using `gpg` without actually downloading the isos and stage3's since these are likely to be large in size). You can then edit the .json and config.sh file with the stage3 and iso you'd like to use.

### Installation without Packer

If you have Vagrant installed, you can use the scripts provided here to build a
stage3 installation manually.

The following instructions are for VirtualBox, but are easy to translate for
VMWare.

  1. Download the amd64 stage3 ISO from http://distfiles.gentoo.org/
  2. Create a new "Gentoo64" virtual machine in VirtualBox, named "GentooBuild"
    - Memory 1024MB
    - Disk, 60GB dynamically allocated
    - Everything else default (unless you know what you're doing)
  3. Attach the downloaded ISO to the CD drive in the virtual machine settings
  4. Boot the virtual machine using "gentoo-nofb" and the default keymap.
  5. `wget https://github.com/d11wtq/gentoo-packer/archive/master.zip`
    - From the livecd prompt in the VM
  6. `unzip master.zip`
    - From the livecd prompt in the VM
  7. `cd gentoo-packer`
    - From the livecd prompt in the VM
  8. `export STAGE3=20140227`
    - From the livecd prompt in the VM
    - Change to whichever stage3 you want to use
  9. `./provision.sh`
    - From the livecd prompt in the VM
    - This does the heavy lifting
  10. `shutdown -hP now`
    - From the livecd prompt in the VM
  11. Back on the host machine, remove the ISO from the CD drive in the virtual
      machine settings.
  12. `vagrant package --base GentooBuild`
    - This will emit a package.box file.

## On your first boot

Because keeping the portage tree in the image would be costly in terms of file
size, and because it gets out of date quickly, it is not present in the image.
Perform an initial `emerge-webrsync` to generate the portage tree.

```
emerge-webrsync
```

Alternatively you can clone the [git repo](https://github.com/gentoo/gentoo):

```
cd /usr/portage
git clone --depth 1 https://github.com/gentoo/gentoo.git portage
```

**Do not** run `emerge --sync` before you do this, because you will add
unnecessary strain on the portage mirror and may even get yourself banned by
the mirror.

## Disk size

The disk is a 60GB sparse disk. You do not need 60GB of free space initially.
The disk will grow as disk usage increases.

## What's configured?

Everything is left as the defaults with a fex exceptions. The time zone is set to UTC. `nano` is removed with busybox's vi replacing it as the default editor (see: scripts/editor.sh). If you're one of those weird people that likes nano you can get it back via a simple `emerge nano` and `eselect editor set nano`. `/etc/portage/make.conf` is replaced (See: [scripts/make.conf.sh](#)) with some sensible defaults, also `-Os` is used to optimise for binary-size :)

## Preserving Precious CPU time

If you're regularly destroying and re-creating VM's, compiling the same packages over and over again can take a long time. Gentoo allows you to create binary packages of anything you've emerged. Then you can just copy these packages to the guest (either manually or using a shared folder) and emerge them with `emerge --usepkg y package` or `emerge --usepkgonly package` (to only use binary packages, emerge will fail if a binary isn't available when using `--usepkgonly`).

The easiest way to do this is to create a `packages` directory in the root of your project and then mount it at `/usr/portage/packages`:

`config.vm.synced_folder './packages', '/usr/portage/packages', type: '9p', disabled: false, accessmode: "mapped", mount: true, mount_options: ['trans=virtio', 'version=9p2000.L,posixacl','cache=loose']`

To create a binary of every single emerged package you can do the following:

`equery l '*' -F '$category/$name' | xargs -I'{}' quickpkg --include-config y {}`

You can also tell `emerge` to always build packages by using `FEATURES="buildpkg"` in `/etc/portage/make.conf` (see: `man make.conf`) or by passing the `--buildpkg y` parameters to `emerge`.

## To Do

* Re-Factoring
* Alternative root filesystem - Ext4 is tried and true but it'd be nice to provide support for other filesystems
* Continuous Delivery - It shouldn't be too difficult to setup a job to build and release images
* Docker support - I should in theory be able to use the scripts with a `chroot` and then package that neatly using the `FROM scratch` Docker image.
* LXC/LXD support - Same as above?
* Hyper-V - No idea how difficult this'd be to support but Windows deserves some love too
* Verify systemd works - I have a personal preference for OpenRC but the kernel is built with the necessary systemd options so it should *in theory* work
* Add an option to use clang instead of gcc as a system compiler (afaik gcc will still be needed for the kernel but we should be able to build most other software with clang and fallback to gcc if that fails)
* Hardening options (the kernel is compiled with support for SELinux and AppArmor, the hardened profiles should in theory work, what about a hardened kernel?)
* Make the project self-hosting - For no reason other than "because I can" it'd be cool to use KVM's nested virtualisation to build the image using a Vagrantfile that uses the previous image.

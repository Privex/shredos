# ShredOS

![ShredOS Serial vs VGA Screenshot](https://cdn.privex.io/github/shredos/shredos-serial-vga.png)

## About ShredOS

ShredOS is a USB bootable small linux distribution with the sole purpose of securely erasing your
disks using the program [nwipe](https://github.com/martijnvanbrummelen/nwipe).

ShredOS boots very quickly and depending upon the host system can boot in as little
as 2 seconds. Nwipe will then list the disks present on the host system. You can then
select the methods by which you want to securely erase the disk/s. Nwipe is able to
simultanuosly wipe multiple disks using a threaded software architecture.

**NOTE:** This is a fork of the original ShredOS repository, which was created / maintained
by Nicolas Adenis-Lamarre ( @nadenislamarre ). The original repository can be
found here: [github.com/nadenislamarre/shredos](https://github.com/nadenislamarre/shredos)

## Supported Wipe Methods and RNGs

For an upto date list of supported wipe methods see the [nwipe](https://github.com/martijnvanbrummelen/nwipe) page.

* Quick erase        - Fills the device with zeros, one round only.
* RCMP TSSIT OPS-II  - Royal Candian Mounted Police Technical Security Standard, OPS-II
* DoD Short          - The American Department of Defense 5220.22-M short 3 pass wipe. 1,2,& 7.
* DoD 5220.22M       - The American Department of Defense 5220.22-M full 7 pass wipe. 1-7
* Gutmann Wipe       - Peter Gutmann's method. (Secure Deletion of Data from Magnetic and Solid-State Memory)
* PRNG Stream        - Fills the device with a stream from the PRNG.
* Verify only        - This method only reads the device and checks that it is all zero.

Nwipe also includes the following pseudo random number generators:

* mersenne
* twister
* isaac

## Download Pre-built ShredOS images

Pre-build ShredOS images are made available by [Privex - a privacy focused server hosting company](https://www.privex.io), which
is the company that maintains this fork of ShredOS.

* [ShredOS Bootable ISO](https://files.privex.io/images/iso/shredos/v1.1/shredos.iso)
* [ShredOS Bootable Raw IMG File](https://files.privex.io/images/iso/shredos/v1.1/shredos.img)
* [ShredOS Self-contained Kernel Image](https://files.privex.io/images/iso/shredos/v1.1/shredos-kernel)
* [ShredOS Pre-configured PXE boot environment using PXELinux](https://files.privex.io/images/iso/shredos/v1.1/pxeboot.tar.gz)

## Using ShredOS with Syslinux (ISOLINUX/PXELINUX etc.) and other boot loaders

ShredOS was built to be self-contained in a single kernel image, so it doesn't require an initrd, a squashfs, or any other files
to work.

This means it can be easily used with bootloaders such as PXELINUX, ISOLINUX, GRUB and others - simply specify
point your bootloader to the [ShredOS Kernel Image](https://files.privex.io/images/iso/shredos/v1.1/shredos-kernel),
and add any [kernel boot flags](#Kernel_Boot_Flags) as required.

### Example ISOLINUX/PXELINUX Config

The below config should work with both ISOLINUX and PXELINUX. It's designed for use with a serial console, which is common
with dedicated servers via Serial-over-LAN using IPMI.

For use with a system that has a standard VGA/HDMI/Integrated monitor, remove the first `SERIAL` line, change the flag
`console=ttyS0,9600n8` to `console=tty0` and remove the word `simple` from the flags.

```s
SERIAL 0 9600 0x008

# search path for the c32 support libraries (libcom32, libutil etc.)
path sys/

UI menu.c32

DEFAULT shredos

LABEL shredos
  KERNEL shredos/shredos
  APPEND console=ttyS0,9600n8 simple quiet loglevel=0 console_baud=0
  # Fully automatic formatting of ALL DISKS
  # APPEND console=ttyS0,9600n8 simple autonuke method=zero rounds=1 nwipe_verify=last loglevel=0 console_baud=0

TIMEOUT 10
```

## Kernel Boot Flags

In this fork by Privex, we've added many kernel flags to assist with customisable automated formatting of servers / network attached systems, especially via PXE.

### Boot CMD options

* `runcmd="/bin/some_command"`   - Override the binary ran, instead of nwipe_launcher
* `nowipe|ttyshell|shelltty|usetty|enabletty`   - All of these boot flags are the same - they force
  a normal console to be launched on boot instead of nwipe_launcher
* `console_baud`                 - Override the console baud rate, which is normally auto-detected from the console= arg
* `simple|basic|vt100`           - Use the VT100 console, which disables fancy colours and symbols
* `term="vt100"`                 - Specify a custom console type to use, e.g. vt100

### NWIPE Options

* `autonuke|autowipe|autoformat|noninteractive|autoerase` - Automatically format ALL DRIVES on the system.

* `rounds=1`                      - Number of times to run 'method'

* `nwipe_verify=last`             - Whether to perform verification of erasure (default: last)

    ```yml
    off   - Do not verify
    last  - Verify after the last pass
    all   - Verify every pass
    ```

* `method=zero`                   - Method to use to auto-wipe the drives (default: zero)

    **Available Methods:**

    ```yml
    dod522022m / dod       - 7 pass DOD 5220.22-M method
    dodshort / dod3pass    - 3 pass DOD method
    gutmann                - Peter Gutmann's Algorithm
    ops2                   - RCMP TSSIT OPS-II
    random / prng / stream - PRNG Stream
    zero / quick           - Overwrite with zeros
    ```

## Compiling ShredOS and burning to USB stick

The ShredOS system is built using buildroot.
The final system size is about 12MB but due to minimim fat32 partition size, the ending image is about
37MB and can be burnt onto a USB memory stick with a tool such as dd or Etcher.

## Known requirements

For building on Ubuntu 18.04 Bionic, the following packages are known to be required:

* `build-essential`
* `wget`
* `libssl-dev`
* `libelf-dev`
* `autoconf`
* `autoconf-archive`
* `automake`
* `cmake`
* `m4`
* `mtools`
* `pkg-config`

Additional packages may be required, you may re-run `make` after installing any missing dependency that caused
the build to fail, and it should resume roughly from where it left off.

## Building ShredOS

You can build the image by doing:

```sh
git clone git@github.com:nadenislamarre/shredos.git
cd shredos
make shredos_defconfig
make
ls output/images/shredos*.img
```

### Building an ISO

First you'll need `genisoimage` which provides `mkisofs`

```sh
apt install genisoimage
```

Copy the kernel (`bzImage`) into the iso folder as the name `shredos`

```sh
cp output/images/bzImage iso/shredos
```

Now use mkisofs to generate an ISO image from the `iso` folder

```sh
mkisofs -o output/images/shredos.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table iso
```

You'll now have a bootable ISO inside of output/images

## Developer Notes

### Merging upstream Buildroot commits

First checkout the `buildroot` branch, add the buildroot remote, fetch the remote git data, set the tracking branch,
and pull in the commits

```sh
# Checkout the existing 'buildroot' branch
git checkout buildroot
# Add the buildroot upstream as a remote
git remote add buildroot https://github.com/buildroot/buildroot.git
# Download the Git metadata from buildroot's github repo, so we can reference their branches and tags
git fetch buildroot
# Set the local branch "buildroot" to track the remote origin's (buildroot/buildroot.git) branch "master"
git branch -u buildroot/master buildroot
# Merge in buildroot's commits
git pull
```

Now checkout the `mergebr` branch, merge in `master`, followed by `buildroot`

```sh
# Checkout the existing 'mergebr' branch
git checkout mergebr
# Merge in the latest master commits
git merge master
# Merge in the commits from buildroot
git merge buildroot
```

After handling any merge conflicts (if there were any), you can now merge `mergebr` into master using a squash commit.

```sh
git checkout master
git merge --squash mergebr
```

### How the mergebr / buildroot branches were originally created

The following instructions are for future reference, if for whatever reason the `mergebr` / `buildroot` branches can't be
obtained from this repository.

Create the `buildroot` branch containing ONLY buildroot commits

```sh
# Create the buildroot branch based off of the last buildroot commit before this repo started committing on top of it
git checkout -b buildroot 572c3f59a9e42c79934484d964b72a1905106d83
# Add the buildroot upstream as a remote
git remote add buildroot https://github.com/buildroot/buildroot.git
# Download the Git metadata from buildroot's github repo, so we can reference their branches and tags
git fetch buildroot
# Set the local branch "buildroot" to track the remote origin's (buildroot/buildroot.git) branch "master"
git branch -u buildroot/master buildroot
# Merge in buildroot's commits
git pull
```

Create the branch `mergebr` based on the current state of master, then merge in the branch `buildroot`

```sh
# Checkout master, so we can create a branch from it
git checkout master
# Create the mergebr branch based off of master
git checkout -b mergebr
# Merge in the commits from buildroot
git merge buildroot
```

Now we merge `mergebr` into master, with a squashed commit for clarity

```sh
git checkout master
git merge --squash mergebr
```

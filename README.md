# ShredOS

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

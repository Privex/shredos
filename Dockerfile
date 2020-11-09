FROM ubuntu:bionic AS shredos_deps

# * `build-essential`
# * `wget`
# * `libssl-dev`
# * `libelf-dev`
# * `autoconf`
# * `autoconf-archive`
# * `automake`
# * `cmake`
# * `m4`
# * `mtools`
# * `pkg-config`

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy build-essential autoconf autoconf-archive automake cmake gcc-multilib && \
    apt-get install -qy libssl-dev libelf-dev libncurses5-dev m4 mtools pkg-config wget curl && \
    apt-get install -qy bc file locales rsync cvs bzr git mercurial subversion cpio zip unzip && \
    apt-get install -qy qemu-system-arm qemu-system-x86 xz-utils liblz4-tool gzip && \
    apt-get clean -qy

RUN /usr/sbin/locale-gen

RUN sed -i 's/# \(en_US.UTF-8\)/\1/' /etc/locale.gen
RUN /usr/sbin/locale-gen



FROM shredos_deps AS shredos

VOLUME /shredos

COPY . /shredos
WORKDIR /shredos

ARG shredos_build=1
ENV shredos_build ${shredos_build}

ARG shredos_defconfig=1
ENV shredos_defconfig ${shredos_defconfig}

RUN (( shredos_build )) && (( shredos_defconfig )) && \
    make shredos_defconfig

RUN (( shredos_build )) && \
    make

RUN mkdir /entry
COPY docker/entrypoint.sh docker/colors.sh /entry/

ENTRYPOINT [ "/entry/entrypoint.sh" ]

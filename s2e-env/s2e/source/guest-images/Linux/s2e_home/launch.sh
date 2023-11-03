#!/bin/sh

# S2E Selective Symbolic Execution Platform
#
# Copyright (c) 2017, Dependable Systems Laboratory, EPFL
# Copyright (c) 2017, Cyberhaven
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -ex

export DEBIAN_FRONTEND=noninteractive

# libelf is required for s2e.so
COMMON_PACKAGES="gcc-multilib g++-multilib libc6-dev-i386 libelf1:i386"
DEBIAN9_PACKAGES="lib32stdc++-6-dev libstdc++6:i386"
DEBIAN12_PACKAGES="lib32stdc++-12-dev libdebuginfod-dev lib32stdc++6 libstdc++6:i386"

# systemtap
UBUNTU_PACKAGES="elfutils libdw-dev"

dist_version() {
    lsb_release -rs | cut -d '.' -f 1
}

dist_name() {
    lsb_release -is | tr '[:upper:]' '[:lower:]'
}

install_packages() {
    # Preserve environment (-E)
    DEBIAN_FRONTEND=noninteractive sudo -E apt-get -y install $*
}

remove_packages() {
    # Preserve environment (-E)
    DEBIAN_FRONTEND=noninteractive sudo -E apt-get purge -y cloud-init
}

remove_ubuntu_packages() {
    NAME=$(dist_name)
    if [ "x$NAME" = "xubuntu" ]; then
        remove_packages cloud-init
    fi
}

# Install 32-bit user space for 64-bit kernels
install_i386() {
    if uname -a | grep -q x86_64; then
        sudo dpkg --add-architecture i386
        sudo apt-get update

        install_packages ${COMMON_PACKAGES}

        NAME=$(dist_name)
        VER=$(dist_version)

        if [ "x$NAME" = "xdebian" ]; then
            if [ $VER -eq 9 ]; then
                install_packages ${DEBIAN9_PACKAGES}
            elif [ $VER -eq 12 ]; then
                install_packages ${DEBIAN12_PACKAGES}
            fi
        elif [ "x$NAME" = "xubuntu" ]; then
            install_packages ${DEBIAN12_PACKAGES} ${UBUNTU_PACKAGES}
        else
            echo "Unsupported distribution ${NAME} ${VER}"
            exit 1
        fi
    fi
}


# Install systemtap from source
# The one that's packaged does not support our kernel
# Note: systemtap requires a lot of memory to compile, so we need swap
install_systemtap() {
    git clone https://sourceware.org/git/systemtap.git
    cd systemtap
    git checkout release-4.9
    cd ..

    mkdir systemtap-build
    cd systemtap-build
    ../systemtap/configure --disable-docs
    make -j4
    sudo make install
    cd ..
}

# Install kernels last, the cause downgrade of libc,
# which will cause issues when installing other packages
install_kernel() {
    sudo dpkg -i linux-image*.deb linux-headers*.deb

    MENU_ENTRY="$(sudo grep menuentry /boot/grub/grub.cfg  | grep s2e | cut -d "'" -f 2 | head -n 1)"
    echo "Default menu entry: $MENU_ENTRY"
    echo "GRUB_DEFAULT=\"1>$MENU_ENTRY\"" | sudo tee -a /etc/default/grub
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0"' | sudo tee -a /etc/default/grub
    sudo update-grub
}

has_cgc_kernel() {
    if ls *.deb | grep -q ckt32-s2e; then
        echo 1
    else
        echo 0
    fi
}

# Install the prerequisites for cgc packages
install_apt_packages() {
    APT_PACKAGES="
    python-apt
    python-crypto
    python-daemon
    python-lockfile
    python-lxml
    python-matplotlib
    python-yaml
    tcpdump
    apache2
    apache2-dev
    autoconf
    bison
    re2c
    libxml2-dev
    libsqlite3-dev
    libonig-dev
    "

    install_packages ${APT_PACKAGES}

    # This package no longer exists on recent debian version
    wget http://archive.debian.org/debian-archive/debian/pool/main/p/python-support/python-support_1.0.15_all.deb
    sudo dpkg -i python-support_1.0.15_all.deb
}

# This works only on Debian 9, CGC packages are not compatible with
# more recent distributions.
install_cgc_packages() {
    CGC_PACKAGES="
    binutils-cgc-i386_2.24-10551-cfe-rc8_i386.deb
    cgc2elf_10551-cfe-rc8_i386.deb
    libcgcef0_10551-cfe-rc8_i386.deb
    libcgcdwarf_10551-cfe-rc8_i386.deb
    readcgcef_10551-cfe-rc8_i386.deb
    python-defusedxml_10551-cfe-rc8_all.deb
    libcgc_10551-cfe-rc8_i386.deb
    cgc-network-appliance_10551-cfe-rc8_all.deb
    cgc-service-launcher_10551-cfe-rc8_i386.deb
    poll-generator_10551-cfe-rc8_all.deb
    cb-testing_10551-cfe-rc8_all.deb
    cgc-release-documentation_10560-cfe-rc8_all.deb
    cgcef-verify_10551-cfe-rc8_all.deb
    cgc-pov-xml2c_10551-cfe-rc8_i386.deb
    strace-cgc_4.5.20-10551-cfe-rc8_i386.deb
    libpov_10551-cfe-rc8_i386.deb
    clang-cgc_3.4-10551-cfe-rc8_i386.deb
    cgc-virtual-competition_10551-cfe-rc8_all.deb
    magic-cgc_10551-cfe-rc8_all.deb
    services-cgc_10551-cfe-rc8_all.deb
    linux-image-3.13.11-ckt32-cgc_10551-cfe-rc8_i386.deb
    linux-libc-dev_10551-cfe-rc8_i386.deb
    "

    wget https://github.com/S2E/guest-images/releases/download/v2.0.0/cgc-packages.tar.gz
    tar xzvf cgc-packages.tar.gz

    # Install the CGC packages
    for PACKAGE in ${CGC_PACKAGES}; do
        sudo dpkg -i --force-confnew ${PACKAGE}
        rm -f ${PACKAGE}
    done

    rm -f cgc-packages.tar.gz
}

sudo apt-get update
install_packages wget lsb-release
remove_ubuntu_packages

install_i386

# Install CGC tools if we have a CGC kernel
if [ $(has_cgc_kernel) -eq 1 ]; then
    install_apt_packages
    install_cgc_packages
else
    install_systemtap
fi

install_kernel

# setup database here.
# bash dbsetup.sh

# QEMU will stop (-no-reboot)
sudo reboot

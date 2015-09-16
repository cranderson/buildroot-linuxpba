# buildroot-linuxpba
A Buildroot-based embedded Linux distro for MSED/LinuxPBA Pre-Boot Authorization of OPAL Self-Encrypting Drives

Copyright (c) 2015 Charles R. Anderson <cra@wpi.edu>

Description
-----------

Buildroot-linuxpba is a set of build configurations and scripts to use
the "Buildroot" build environment to build MSED and LinuxPBA into a
micro-sized embedded Linux distribution for loading into an Opal
2.0-compatible self-encrypting drive for use as a Pre-Boot
Authorization image.  The final image is 4MB in size, which is small
enough to allow MSED to load it onto Crucial SSDs which appear to have
timeout issues when attempting to load images larger than about 7MB.
Smaller images are also advantageous for any drives, not just Crucial,
because the loading process itself is fairly slow.  See here for more
information about the issue with Crucial SSDs:

https://github.com/r0m30/msed/issues/23

Buildroot (http://buildroot.uclibc.org/) is a set of Makefiles and
patches that makes it easy to generate a complete embedded Linux
system. Buildroot can generate any or all of a cross-compilation
toolchain, a root filesystem, a kernel image and a bootloader image.

MSED and LinuxPBA (http://www.r0m30.com/msed) are tools to manage the
activation and use of self encrypting drives that comply with the
Trusted Computing Group Opal 2.0 SSC.

License
-------

buildroot-linuxpba is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 2 of the
License, or (at your option) any later version.

buildroot-linuxpba is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Pre-built LinuxPBA image
------------------------

A pre-built LinuxPBA image is now included.  It is called
msedlinuxpba.img and is located in the same directory as this
README.md file.  To use it, see the "Loading the LinuxPBA image onto
your SED" section below.

Building the LinuxPBA image
---------------------------

Download and unpack buildroot:

    curl -L http://buildroot.uclibc.org/downloads/buildroot-2015.05.tar.gz | tar xvzf -

Download and unpack buildroot-linuxpba:

    curl -L https://github.com/cranderson/buildroot-linuxpba/archive/master.tar.gz | tar xvzf -

Copy the contents of buildroot-linuxpba into buildroot:

    cp -av buildroot-linuxpba-master/* buildroot-2015.05/

Go into the buildroot directory, load the config file, and build:

    cd buildroot-2015.05
    make linuxpba_defconfig
    make

Buildroot will download, unpack, patch, configure, and build
everything it needs.  This will take awhile.  When the build finishes,
you will have a msedlinuxpba.img file in the output/images directory:

    drwxr-x---. 4 cra cra    4096 Jul 19 03:50 ./
    drwxr-x---. 6 cra cra    4096 Jul 19 03:39 ../
    drwxr-x---. 3 cra cra    4096 Jul 19 03:47 bootfs/
    -rw-r-----. 1 cra cra 3145728 Jul 19 03:47 bootfs.img
    -rw-r-----. 1 cra cra 1436864 Jul 19 03:47 bzImage
    -rw-r-----. 1 cra cra 4194304 Jul 19 03:50 msedlinuxpba.img
    -rw-r-----. 1 cra cra 2044928 Jul 19 03:47 rootfs.cpio
    -rw-r-----. 1 cra cra  853489 Jul 19 03:47 rootfs.cpio.gz
    drwxr-xr-x. 2 cra cra    4096 Jul 19 03:46 syslinux/

Loading the LinuxPBA image onto your SED
----------------------------------------

You will need to use MSED to load the PBA image "msedlinuxpba.img"
onto your self-encrypting drive.

Fedora now includes MSED.  You can install it via:

    dnf install msed

For other systems, you can download a pre-built MSED from here:

http://www.r0m30.com/msed/files

You only need msed_LINUX.tgz or msed_WIN.zip, not any of the pba or
PBA images.

Or you can build it yourself.  You can skip the steps about building
syslinux/buildbiospba and LinuxPBA since you've already built the PBA:

http://www.r0m30.com/msed/documentation/building

Basically, just do:

    make CONF=Release_i686
    or
    make CONF=Release_x86_64

You can find the built "msed" tool under the "dist/Release_arch"
directory:

    cd dist/Release_i686 (or cd dist/Release_x86_64)
    ./msed

Finally, you need to use the "msed" tool to set up your drive and load
the PBA image.  See here for documentation:

http://www.r0m30.com/msed/documentation/managing

    ./msed --initialsetup <password> <drive>
    ./msed --loadPBAimage <password> msedlinuxpba.img  <drive>
    ./msed --enableLockingRange 0 <password> <drive>

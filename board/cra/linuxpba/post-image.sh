#!/bin/bash
set -x
#export PATH=${HOST_DIR}/bin:${HOST_DIR}/sbin:${HOST_DIR}/usr/bin:${HOST_DIR}/usr/sbin:${PATH}

# Assemble the boot filesystem
mkdir -p ${BINARIES_DIR}/bootfs/boot/syslinux
install -m644 ${BINARIES_DIR}/bzImage ${BINARIES_DIR}/bootfs/boot/vmlinuz
install -m644 ${BINARIES_DIR}/rootfs.cpio.gz ${BINARIES_DIR}/bootfs/boot/rootfs.gz
cat > ${BINARIES_DIR}/bootfs/boot/syslinux/syslinux.cfg <<CONF
default msed
prompt 0
noescape 1
quiet
label msed
    kernel /boot/vmlinuz
    initrd /boot/rootfs.gz
    append quiet loglevel=0 libata.allow_tpm=1
CONF
# copy these files in just to get the correct size of the image below
#install -m644 ${BUILD_DIR}/syslinux-*/bios/core/ldlinux.sys ${BINARIES_DIR}/bootfs/boot/syslinux/
#install -m644 ${BINARIES_DIR}/syslinux/ldlinux.c32 ${BINARIES_DIR}/bootfs/boot/syslinux/

# Create a filesystem image and install the bootloader
rm -f ${BINARIES_DIR}/bootfs.img
#${HOST_DIR}/usr/bin/mke2img -d ${BINARIES_DIR}/bootfs -G 2 -l MSEDLINUXPBA -o ${BINARIES_DIR}/bootfs.img
#virt-make-fs --format=raw --label=LINUXPBA --partition=mbr --type=vfat ${BINARIES_DIR}/bootfs/ ${BINARIES_DIR}/bootfs.img
PSIZE=3
dd if=/dev/zero of=${BINARIES_DIR}/bootfs.img bs=1M count=${PSIZE}
${HOST_DIR}/usr/sbin/mkfs.vfat -n LINUXPBA ${BINARIES_DIR}/bootfs.img
${HOST_DIR}/usr/bin/mcopy -i ${BINARIES_DIR}/bootfs.img -s -v ${BINARIES_DIR}/bootfs/* ::
#ISIZE=$(wc -c < ${BINARIES_DIR}/bootfs.img)
#PSIZE=$(( (${ISIZE} + (1024*1024)) / (1024*1024) ))
${HOST_DIR}/usr/bin/syslinux --directory /boot/syslinux --install ${BINARIES_DIR}/bootfs.img
#--offset 65536

# Create a partitioned image file and embed the filesystem and bootloader MBR images in it
rm -f ${BINARIES_DIR}/msedlinuxpba.img
DSIZE=$(( ${PSIZE} + 1 ))
dd if=/dev/zero of=${BINARIES_DIR}/msedlinuxpba.img bs=1M count=${DSIZE}
#(echo o;echo n;echo p;echo 1;echo 2048;echo "";echo "";echo a;echo 1;echo w) | fdisk ${BINARIES_DIR}/msedlinuxpba.img
${HOST_DIR}/usr/sbin/parted -s ${BINARIES_DIR}/msedlinuxpba.img mklabel msdos mkpart primary fat16 1 4 toggle 1 boot
dd if=${BINARIES_DIR}/bootfs.img of=${BINARIES_DIR}/msedlinuxpba.img conv=notrunc bs=1M count=${PSIZE} seek=1
dd if=${BINARIES_DIR}/syslinux/mbr.bin of=${BINARIES_DIR}/msedlinuxpba.img conv=notrunc bs=512 count=1

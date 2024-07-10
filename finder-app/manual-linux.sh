#!/bin/sh
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v6.1.14
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1  ]
then
	echo "Using default directory ${OUTDIR} for output"
else
  # absolute path
  OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

if [ ! -d "${OUTDIR}" ]; then
  echo "Creating directory ${OUTDIR}"
  mkdir -p "${OUTDIR}" || { echo "ERROR: The directory cannot be created ${OUTDIR}"; exit 1; }
fi

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone "$KERNEL_REPO" --depth 1 --single-branch --branch "$KERNEL_VERSION"
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "Clean the kernel build tree"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    
    echo "Configure the kernel"
    make $(nproc)ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    
    echo "Build a kernel image"
    make -j $(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

    echo "Build modules and devicetree"
    make -j $(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make -j $(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo "Adding the Image in outdir"

cd "${OUTDIR}"
echo "Copying the result files to the ${OUTDIR}"
cp "${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image" "${OUTDIR}"
#cp -a linux-stable/arch/${ARCH}/boot/dts "${OUTDIR}/"
#cp -a linux-stable/arch/${ARCH}/boot/dtb "${OUTDIR}/"
#cp -a linux-stable/.config "${OUTDIR}/"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p "${OUTDIR}"/rootfs
cd "${OUTDIR}"/rootfs

mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var 
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    
    # TODO:  Configure busybox
    
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX="$OUTDIR/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


cd "${OUTDIR}/rootfs"

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs

SYSROOT="/home/e4rror04/toolchain/install-lnx/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc"

LIBS=$(${CROSS_COMPILE}readelf -a "${OUTDIR}/rootfs/bin/busybox" | grep "Shared library" | awk '{print $5}' | sort | tr -d '[] ')

for LIB in $LIBS 
do
  LIB_PATH=$(find "$SYSROOT" -name "$LIB")
  #echo "LIB_PATH: ${LIB_PATH}"

  if [ -n "$LIB_PATH" ]
  then
    #echo "Copying $LIB_PATH to ${OUTDIR}/rootfs/lib64"
    cp "$LIB_PATH" "${OUTDIR}/rootfs/lib64/"
  else
    echo "Library $LIB not found"
  fi
done

INTERPR=$(${CROSS_COMPILE}readelf -a "${OUTDIR}/rootfs/bin/busybox" | grep "program interpreter" | awk -F: '{print $2}' | awk '{print $1}' | tr -d '[] ')
INTERPR=$(echo "$INTERPR" | sed 's|^/lib/||')
INTER_PATH=$(find "$SYSROOT" -name "$INTERPR")

if [ -n "$INTER_PATH" ]
then
  #echo "Copying $INTER_PATH to ${OUTDIR}/rootfs/lib"
  cp "$INTER_PATH" "${OUTDIR}/rootfs/lib/"
else
  echo "Interpreter $INTERPR not found"
fi 

# TODO: Make device nodes

sudo mknod -m 666 $OUTDIR/rootfs/dev/null c 1 3
sudo mknod -m 666 $OUTDIR/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd "${FINDER_APP_DIR}"
echo "Cleaning"
make clean
echo "Building the writer utility"
make CROSS_COMPILE=$CROSS_COMPILE

cd "${OUTDIR}"

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

MAIN_GIT=$(cd $(dirname $FINDER_APP_DIR) && pwd)

echo "Copy the finder related scripts to the home directory"
mv "$FINDER_APP_DIR"/writer "$OUTDIR/rootfs/home"
cp "$FINDER_APP_DIR"/finder-test.sh "$OUTDIR/rootfs/home"
cp "$FINDER_APP_DIR"/finder.sh "$OUTDIR/rootfs/home"
cp "$FINDER_APP_DIR/autorun-qemu.sh" "$OUTDIR/rootfs/home"
cp "$MAIN_GIT/conf/username.txt" "$OUTDIR/rootfs/home"
cp "$MAIN_GIT/conf/assignment.txt" "$OUTDIR/rootfs/home" 


# TODO: Chown the root directory

sudo chown -R root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
echo "Creating intiframfs"
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov > "$OUTDIR/initramfs.cpio"
gzip -f "${OUTDIR}/initramfs.cpio"
echo "Pack"

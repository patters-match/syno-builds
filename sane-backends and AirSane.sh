#-----New VirtualBox VM
#-----Name Synodev
#-----Type Red Hat (64 bit)
#-----512MB RAM for the Installer GUI (reduce later)
#-----Disable Floppy
#-----Chipset PIIX3
#-----SATA controller: Use Host I/O cache speeds up lots of small file I/O (e.g. compiling software/updating packages)
#-----20GB VDI file, tick Solid State Drive (attached to NAT)
#-----Port forwarding xxxx to 22 (leave host/guest IPs blank)
#-----Disable Audio
#-----Network: use virt.io (didn’t work on VirtualBox 5.0, working on 5.2)
#-----Disable USB
#-----Boot CentOS 7 Minimal Install DVD

sudo yum update
reboot
sudo yum group install "Development Tools"
#----add 32bit packages
sudo yum install ncurses-libs.i686 glibc.i686 libstdc++.i686

sudo yum install nano chrpath wget left git
sudo yum install epel-release
sudo yum install yasm

#-----cmake
sudo yum install cmake
sudo yum install cmake3
sudo alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 10 --slave /usr/local/bin/ctest ctest /usr/bin/ctest --slave /usr/local/bin/cpack cpack /usr/bin/cpack --slave /usr/local/bin/ccmake ccmake usr/bin/ccmake  --family cmake
sudo alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 --family cmake
#-----to switch version use 'sudo alternatives --config cmake'

wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2
tar xjvf nasm-2.13.02.tar.bz2
cd nasm-2.13.02
./autogen.sh
./configure
make
sudo make install
cd ..

#-----set up Synology toolchain
cd ~/Downloads
export DL_PATH="https://sourceforge.net/projects/dsgpl/files/DSM%206.0.2%20Tool%20Chains"


#----------------------------------------------------
#-----NOW PASTE ONE OF THE FOLLOWING 7 BLOCKS TO THE TERMINAL, DEPENDING ON YOUR TARGET CPU TYPE
#-----Marvell Kirkwood mv6281/mv6282 (ARMv5te)
#-----Marvell Armada 370/XP (ARMv7l FPU)
#-----Marvell Armada 375/385, Mindspeed Comcerto 2000, ST Microelectronics STiH412, Annapurna Labs Alpine AL-314, AL-514, & AL-212 (ARM Cortex-A9 NEON)
#-----Realtek RTD1296, Marvell Armada 3720 (64bit ARM Cortex-A53)
#-----Freescale PowerQUICC III MPC8533E/QorIQ P1022 (PPC e500v2 SPE)
#-----Intel Evansport (i686 Atom SSSE3)
#-----Intel x86_64 (all other Intel CPUs)




#-----Marvell Kirkwood mv6281/mv6282 SoC is based on the ARMv5TE core which has DSP and Thumb instruction support
#-----However using Thumb on ARMv5 results in worse performance
#-----http://www.arm.com/products/processors/technologies/dsp-simd.php
#-----http://www.marvell.com/embedded-processors/kirkwood/assets/88f6282-3_pb.pdf
#-----This CPU arch is not supported for AirSane since devkit GCC version is just too old for C++11 support (GCC 4.6.4, but 4.7 needed) https://gcc.gnu.org/projects/cxx-status.html#cxx11
wget "${DL_PATH}/Marvell%2088F628x%20Linux%202.6.32/6281-gcc464_glibc215_88f6281-GPL.txz"
tar xJf 6281-gcc464_glibc215_88f6281-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.6281-6.0.dev.txz"
export DEV_DL="ds.6281-6.0.dev.txz"
export DEV_DL_ROOT="libc"
export CROSS_PREFIX=arm-marvell-linux-gnueabi
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}
export TARGET=${CROSS_PREFIX}
export MARCH="-march=armv5te -mtune=marvell-f -mtune=xscale"




#-----Marvell Armada 370/XP SoC is based on a dual issue ARMv7 core with Thumb-2, VFPv3-16, but no NEON vector unit
#-----http://www.marvell.com/embedded-processors/armada-300/assets/Marvell_ARMADA_370_SoC.pdf
#-----http://www.arm.com/products/processors/technologies/vector-floating-point.php
#-----since DSM 6.0 hard float ABI is used
wget "${DL_PATH}/Marvell%20Armada%20370%20Linux%203.2.40/armada370-gcc493_glibc220_hard-GPL.txz"
tar xJf armada370-gcc493_glibc220_hard-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.armada370-6.0.dev.txz"
export DEV_DL="ds.armada370-6.0.dev.txz"
export DEV_DL_ROOT="sysroot"
export CROSS_PREFIX=arm-unknown-linux-gnueabi
export TARGET=${CROSS_PREFIX}
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}
#-----Tune for Marvell PJ4 dual issue core (two instructions per clock)
#-----Thumb-2 can be used on ARMv6 or newer with no performance drop
export MARCH="-march=armv7-a -mcpu=marvell-pj4 -mtune=marvell-pj4 -mhard-float -mfpu=vfpv3-d16 -mthumb"




#-----Marvell Armada 375, Armada 385, Mindspeed Comcerto 2000, ST Microelectronics STiH412, and Annapurna Labs Alpine SoCs are based on dual ARM Cortex-A9 cores with NEON vector unit
#-----http://www.marvell.com/embedded-processors/armada-300/assets/ARMADA_375_SoC-01_product_brief.pdf
#-----http://www.marvell.com/embedded-processors/armada-38x/assets/A38x-Functional-Spec-PU0A.pdf
#-----http://www.mindspeed.com/products/cpe-processors/comcertoreg-2000
#-----http://www.arm.com/products/processors/cortex-a/cortex-a9.php
#-----http://www.arm.com/products/processors/technologies/neon.php
#-----Since DSM 6.0 Armada 375 finally has hard float ABI and therefore gains NEON support
wget "${DL_PATH}/Marvell%20Armada%20375%20Linux%203.2.40/armada375-gcc493_glibc220_hard-GPL.txz"
tar xJf armada375-gcc493_glibc220_hard-GPL.txz
#-----Marvell gave all the ARMv7 toolchains the same name so rename to allow concurrent installations
mv arm-unknown-linux-gnueabi/ arm-cortexa9-linux-gnueabi/
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.armada375-6.0.dev.txz"
export DEV_DL="ds.armada375-6.0.dev.txz"
export DEV_DL_ROOT="sysroot"
export CROSS_PREFIX=arm-unknown-linux-gnueabi
export TARGET=${CROSS_PREFIX}
export TOOLCHAIN=/usr/local/arm-cortexa9-linux-gnueabi
#-----it seems that in general neon should be used as the fpu when present unless there's a specific reason not to use it
export MARCH="-march=armv7-a -mcpu=cortex-a9 -mfpu=neon -mhard-float -mthumb"




#-----Realtek RTD1296 and Marvell Armada 3720 SoCs are based on quad 64bit ARM Cortex-A53 cores
#-----https://developer.arm.com/products/processors/cortex-a/cortex-a53
export DL_PATH="https://sourceforge.net/projects/dsgpl/files/DSM%206.1%20Tool%20Chains"
wget "${DL_PATH}/Intel%20x86%20Linux%204.4.15%20%28Rtd1296%29/rtd1296-gcc494_glibc220_armv8-GPL.txz"
tar xJf rtd1296-gcc494_glibc220_armv8-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.1/ds.rtd1296-6.1.env.txz"
export DEV_DL="ds.rtd1296-6.1.env.txz"
export DEV_DL_ROOT="sysroot"
export CROSS_PREFIX=aarch64-unknown-linux-gnueabi
export TARGET=${CROSS_PREFIX}
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}
#-----it seems that in general neon should be used as the fpu when present unless there's a specific reason not to use it
export MARCH="-march=armv8-a -mcpu=cortex-a53"




#-----Freescale PowerQUICC III MPC8533E/QorIQ P1022 SoCs use the PowerPC e500v2 core with Signal Processing Engine (SPE) which is not a classic FPU design, but have no AltiVec vector unit 
#-----Some QorIQ models have e500mc cores with true FPUs but these are not used in 2013 series Synology NAS
#-----http://en.wikipedia.org/wiki/QorIQ
#-----http://cache.freescale.com/files/32bit/doc/fact_sheet/QP1022FS.pdf?fpsp=1
wget "${DL_PATH}/PowerPC%20QorIQ%20Linux%202.6.32/qoriq-gcc493_glibc220_hard_qoriq-GPL.txz"
tar xJf qoriq-gcc493_glibc220_hard_qoriq-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.qoriq-6.0.dev.txz"
export DEV_DL="ds.qoriq-6.0.dev.txz"
export DEV_DL_ROOT="sysroot"
export CROSS_PREFIX=powerpc-e500v2-linux-gnuspe
export TARGET=${CROSS_PREFIX}
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}
export MARCH="-mcpu=8548 -mhard-float -mfloat-gprs=double"




#-----Intel Evansport 32bit Atom-derived SoC with support for hardware decoding of VC-1, H.264, MPEG-4, MPEG2, AAC and hardware encoding of H.264
#-----http://www.anandtech.com/show/8020/synology-ds214play-intel-evansport-almost-done-right/9
wget "${DL_PATH}/Intel%20x86%20Linux%203.2.40%20%28Evansport%29/evansport-gcc493_glibc220_linaro_i686-GPL.txz"
tar xJf evansport-gcc493_glibc220_linaro_i686-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.evansport-6.0.dev.txz"
export DEV_DL="ds.evansport-6.0.dev.txz"
export DEV_DL_ROOT="sys-root"
export CROSS_PREFIX=i686-pc-linux-gnu
export TARGET=${CROSS_PREFIX}
export MARCH="-march=atom"
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}




#-----Since DSM 6.0 all other Intel CPUs use x86_64 toolchain with SSSE3
#-----unlike the others this toolchain has an external dependency on libz
#sudo apt-get install libz1:i386
wget "${DL_PATH}/Intel%20x86%20Linux%203.10.77%20%28Pineview%29/x64-gcc493_glibc220_linaro_x86_64-GPL.txz"
tar xJf x64-gcc493_glibc220_linaro_x86_64-GPL.txz
wget "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM6.0/ds.cedarview-6.0.dev.txz"
export DEV_DL="ds.cedarview-6.0.dev.txz"
export DEV_DL_ROOT="sys-root"
export CROSS_PREFIX=x86_64-pc-linux-gnu
export TARGET=x86_64-pc-linux-gnu
export TOOLCHAIN=/usr/local/${CROSS_PREFIX}




#----------------------------------------------------
#-----script continues
sudo mv `echo $TOOLCHAIN | sed -r "s%^.*/(.*$)%\1%"` /usr/local
#-----some of the toolchains have bad permissions
sudo chmod -R 0755 ${TOOLCHAIN}

export PATH=${TOOLCHAIN}/bin:$PATH
export AR=${TOOLCHAIN}/bin/${CROSS_PREFIX}-ar
export AS=${TOOLCHAIN}/bin/${CROSS_PREFIX}-as
export CC=${TOOLCHAIN}/bin/${CROSS_PREFIX}-gcc
export CXX=${TOOLCHAIN}/bin/${CROSS_PREFIX}-g++
export LD=${TOOLCHAIN}/bin/${CROSS_PREFIX}-ld
export LDSHARED="${TOOLCHAIN}/bin/${CROSS_PREFIX}-gcc -shared "
export RANLIB=${TOOLCHAIN}/bin/${CROSS_PREFIX}-ranlib
export CFLAGS="-I${TOOLCHAIN}/include -O3 ${MARCH}"
export LDFLAGS="-L${TOOLCHAIN}/lib"
export PKG_CONFIG_PATH="${TOOLCHAIN}/lib/pkgconfig"


#-----set up all our dependent libraries from the Synology dev environment
mkdir ${CROSS_PREFIX}-dev
cd ${CROSS_PREFIX}-dev
tar xfJ ../${DEV_DL}

mkdir $TOOLCHAIN/lib/pkgconfig/

cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/avahi-client/ $TOOLCHAIN/include/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/avahi-common/ $TOOLCHAIN/include/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/avahi-core/ $TOOLCHAIN/include/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/avahi-glib/ $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libavahi*.so $TOOLCHAIN/lib/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/avahi-*.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/avahi-*.pc
#-----pkgconfig manifests are not even consistent in the devkit - these ones need an additional edit
sed -i "s|^libdir=.*$|libdir=${TOOLCHAIN}/lib|" $TOOLCHAIN/lib/pkgconfig/avahi-*.pc

cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/dbus-1.0/ $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libdbus-1.so $TOOLCHAIN/lib/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/dbus-1.0/ $TOOLCHAIN/lib/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/dbus-1.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/dbus-1.pc
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/dbus-glib-1.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/dbus-glib-1.pc

cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/glib-2.0/ $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libglib-2.0.so $TOOLCHAIN/lib/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/glib-2.0/ $TOOLCHAIN/lib/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/glib-2.0.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/glib-2.0.pc

cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/png.h $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/pngconf.h $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/pnglibconf.h $TOOLCHAIN/include/
cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/libpng16/ $TOOLCHAIN/include/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libpng.so $TOOLCHAIN/lib/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libpng16.so $TOOLCHAIN/lib/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/libpng.pc $TOOLCHAIN/lib/pkgconfig/
cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/libpng16.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/libpng*.pc
#-----may break other builds so only do this where needed (from AirSane git readme)
cp -R $TOOLCHAIN/include/libpng16/ $TOOLCHAIN/include/libpng/

cd ..

wget https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/7321branch/evansport-source/libjpeg-turbo-1.x.txz
tar xJf libjpeg-turbo-1.x.txz
cd libjpeg-turbo-1.x
./configure --prefix=${TOOLCHAIN} --host=${TARGET} --build=x86_64-linux-gnu --enable-shared --disable-static --with-jpeg8
make
make install
cd ..

wget https://github.com/libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2
tar xjf libusb-1.0.23.tar.bz2
cd libusb-1.0.23
./configure --prefix=${TOOLCHAIN} --host=${TARGET} --build=x86_64-linux-gnu --enable-shared --disable-static --disable-udev
sed -i "s/^hardcode_into_libs=yes/hardcode_into_libs=no/" libtool
make
make install
cd ..

sudo rm -rf /var/packages/
sudo mkdir -p /var/packages/

wget https://gitlab.com/sane-project/backends/uploads/9e718daff347826f4cfe21126c8d5091/sane-backends-1.0.28.tar.gz
tar xzf sane-backends-1.0.28.tar.gz
cd sane-backends-1.0.28

#-----the dll loader for SANE backend drivers appears to ignore rpath, so we have to build with a fixed destination path appropriate for the Synology package
export SYNODEST=/var/packages/sane-backends/target

#-----Fix a plustek backend bug
#-----https://gitlab.com/sane-project/backends/issues/113
sed -r -i "s/(\(dev->adj\.glampoff != -1\) && \(dev->adj\.)r(lampoff != -1\)\) \{)/\1b\2/" backend/plustek-usbcal.c

#-----Removed avahi support as this caused random segmentation faults during device detection via libsane
#-----https://github.com/SimulPiscator/AirSane/issues/24
#CFLAGS=-I${TOOLCHAIN}/include CPPFLAGS=-I${TOOLCHAIN}/include LDFLAGS=-Wl,-L${TOOLCHAIN}/lib,-rpath,XORIGIN/../lib:XORIGIN,-rpath-link,${TOOLCHAIN}/lib ac_cv_func_mmap_fixed_mapped=yes ./configure --prefix=${SYNODEST} --host=${TARGET} --build=x86_64-linux-gnu --enable-shared --disable-static --sysconfdir=${SYNODEST}/etc --localstatedir=${SYNODEST}/var --enable-avahi
CFLAGS=-I${TOOLCHAIN}/include CPPFLAGS=-I${TOOLCHAIN}/include LDFLAGS=-Wl,-L${TOOLCHAIN}/lib,-rpath,XORIGIN/../lib:XORIGIN,-rpath-link,${TOOLCHAIN}/lib ac_cv_func_mmap_fixed_mapped=yes ./configure --prefix=${SYNODEST} --host=${TARGET} --build=x86_64-linux-gnu --enable-shared --disable-static --sysconfdir=${SYNODEST}/etc --localstatedir=${SYNODEST}/var
sed -i "s/^hardcode_into_libs=yes/hardcode_into_libs=no/" libtool
make
sudo make install
cd ..
sudo chrpath -r '$ORIGIN/../lib:$ORIGIN' ${SYNODEST}/bin/gamma4scanimage
sudo chrpath -r '$ORIGIN/../lib:$ORIGIN' ${SYNODEST}/bin/scanimage
sudo chrpath -r '$ORIGIN/../lib:$ORIGIN' ${SYNODEST}/bin/sane-find-scanner
sudo chrpath -r '$ORIGIN/../lib:$ORIGIN' ${SYNODEST}/sbin/saned
sudo chrpath -r '$ORIGIN' ${SYNODEST}/lib/libsane.so.1
mkdir -p sane-export/bin
mkdir -p sane-export/sbin
mkdir -p sane-export/lib/sane
cp ${SYNODEST}/bin/gamma4scanimage sane-export/bin/
cp ${SYNODEST}/bin/scanimage sane-export/bin/
cp ${SYNODEST}/bin/sane-find-scanner sane-export/bin/
cp ${SYNODEST}/sbin/saned sane-export/sbin/
cp ${SYNODEST}/lib/libsane.so.1 sane-export/lib/
cp ${TOOLCHAIN}/lib/libusb-1.0.so.0 sane-export/lib/
cp ${SYNODEST}/lib/sane/libsane-*.so.1 sane-export/lib/sane
cp -R ${SYNODEST}/etc sane-export/
sudo chown -R root:root sane-export/
cd sane-export
sudo XZ_OPT=-9 tar cvJf sane1.0.28-native-${CROSS_PREFIX}.tar.xz * 
cd ..

cp -R /var/packages/sane-backends/target/include/sane/ $TOOLCHAIN/include/
cp /var/packages/sane-backends/target/lib/libsane.so $TOOLCHAIN/lib/
cp -R /var/packages/sane-backends/target/lib/sane/ $TOOLCHAIN/lib/
cp /var/packages/sane-backends/target/lib/pkgconfig/sane-backends.pc $TOOLCHAIN/lib/pkgconfig/
sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/sane-backends.pc

#-----cmake toolchain file
#-----lots of conflicting info, good blog post here https://www.embeddeduse.com/2017/06/03/cmake-cross-compilation-based-on-yocto-sdk/
#-----also https://gitlab.kitware.com/cmake/community/wikis/doc/cmake/CrossCompiling
cat > cmakecross.txt <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR \$ENV{CROSS_PREFIX})
set(TOOLCHAIN_PREFIX \$ENV{TOOLCHAIN}/bin/\$ENV{CROSS_PREFIX}-)
set(CMAKE_C_COMPILER \${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER \${TOOLCHAIN_PREFIX}g++)
set(CMAKE_PREFIX_PATH \$ENV{TOOLCHAIN})
#set(CMAKE_STAGING_PREFIX /var/packages/airsane)
set(CMAKE_FIND_ROOT_PATH \$ENV{TOOLCHAIN})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
#CMAKE_FIND_ROOT_PATH settings above don't seem to work, so resorted to forcing individual flags for GCC tools below
set(COMPILER_FLAGS "-I\$ENV{TOOLCHAIN}/include -O3 \$ENV{MARCH}")
set(CMAKE_C_FLAGS "\${CMAKE_C_FLAGS} \${COMPILER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} \${COMPILER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-L\$ENV{TOOLCHAIN}/lib,-rpath,\'\\\$ORIGIN/../lib:\\\$ORIGIN\'")
EOF

wget https://www.dropbox.com/s/p8z3rcbryj4v77f/DSM5565-src.tar.xz
tar xvJf DSM5565-src.tar.xz zlib-1.x/
cd zlib-1.x
./configure --prefix=${TOOLCHAIN}
#-----owing to a bug in the configure script, libz cross compiles without a SONAME (check it with objdump -x)
#-----http://forums.gentoo.org/viewtopic-p-7156392.html
sed -i "s/\(^LDSHARED=.*$\)/\1 -Wl,-soname,libz.so.1,--version-script,zlib.map/" Makefile
make
make install
cd ..

#-----avahi as compiled by Synology for ppc has unusual additional library dependencies which cause issues during AirSane linking
#-----particularly libsynosdk with its own huge list of upstream dependencies - need to rebuild avahi from source to build AirSane even though AirSane will ultimately use the avahi libs from DSM
#-----Synology last published a full sourcecode bundle around DSM 5.2 I think (build 5644), however that version appears consistent with the binaries distributed the DSM 6.0 devkits (0.6.31)
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cd ${CROSS_PREFIX}-dev
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/expat.h $TOOLCHAIN/include/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/expat_external.h $TOOLCHAIN/include/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libexpat.* $TOOLCHAIN/lib/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/expat.pc $TOOLCHAIN/lib/pkgconfig/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/expat.pc

[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/libdaemon.a $TOOLCHAIN/lib/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp -R usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/include/libdaemon/ $TOOLCHAIN/include/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp usr/local/$TARGET/$TARGET/${DEV_DL_ROOT}/usr/lib/pkgconfig/libdaemon.pc $TOOLCHAIN/lib/pkgconfig/
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && sed -i "s|^prefix=.*$|prefix=${TOOLCHAIN}|" $TOOLCHAIN/lib/pkgconfig/libdaemon.pc
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] cd ..

[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && wget https://www.dropbox.com/s/qyjsvlczllx5o29/syno-avahi-0.6.31.tar.xz
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && tar xJf syno-avahi-0.6.31.tar.xz
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cd avahi-0.6.x
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && ./configure --prefix=${TOOLCHAIN} --host=${TARGET} --build=x86_64-linux-gnu --enable-shared --disable-static --with-gnu-ld --with-distro=none --disable-mono --disable-monodoc --disable-python --disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 --disable-python --disable-autoipd --disable-doxygen-doc --disable-doxygen-dot --disable-doxygen-xml --disable-doxygen-html --disable-manpages --disable-xmltoman --disable-gdbm --disable-gobject
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && make install
#-----fails when attempting to setup daemon but the libraries have been installed successfully
[ "${CROSS_PREFIX}" == "powerpc-e500v2-linux-gnuspe" ] && cp *.pc ${TOOLCHAIN}/lib/pkgconfig

git clone https://github.com/SimulPiscator/AirSane.git
mkdir AirSane-build
cd AirSane-build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmakecross.txt -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ../AirSane
make
#-----on error, make VERBOSE=1
#-----add -lz -ldbus-1 -lglib-2.0 to the linker parameters
#-----make

#-----check lib dependencies and rpath with objdump -x airsaned | more

#-----PERMISSIONS - both saned and airsaned must run as root on syno since there is no udev support

#-----connect to the syno to export the compiled binaries
sudo mount.nfs 192.168.1.x:/volume1/linux /mnt/syno

#-----to clean a source build folder: 'make distclean'




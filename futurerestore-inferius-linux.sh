#!/usr/bin/env bash
# Made by @Cryptiiiic, Cryptic#6293
# please build in this docker container:
# docker run -it --name debian debian:buster-slim
set -e
export FR_BASE=/tmp/build
export C_ARGS="-fPIC -static"
export CXX_ARGS="-fPIC -static"
export LD_ARGS="-Wl,--allow-multiple-definition -static -L/usr/lib/x86_64-linux-gnu -L/tmp/out/lib"
export C_ARGS2="-fPIC"
export CXX_ARGS2="-fPIC"
export LD_ARGS2="-Wl,--allow-multiple-definition -L/usr/lib/x86_64-linux-gnu -L/tmp/out/lib"
export PKG_CFG="/tmp/out/lib/pkgconfig"
export CC_ARGS="CC=/usr/bin/clang-13 CXX=/usr/bin/clang++-13 LD=/usr/bin/ld.lld-13 RANLIB=/usr/bin/ranlib AR=/usr/bin/ar"
export CONF_ARGS="--prefix=/tmp/out --disable-dependency-tracking --disable-silent-rules --disable-debug --without-cython --disable-shared"
export CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_CROSSCOMPILING=true -DCMAKE_C_FLAGS=${C_ARGS} -DCMAKE_CXX_FLAGS=${CXX_ARGS} -DCMAKE_SHARED_LINKER_FLAGS=${LD_ARGS} -DCMAKE_STATIC_LINKER_FLAGS=${LD_ARGS} -DCMAKE_INSTALL_PREFIX=/tmp/out -DBUILD_SHARED_LIBS=0 -Wno-dev"
export JNUM="-j$(nproc)"
export LNUM="-l$(nproc)"
export script_timer_start=$(date +%s)
export DIR=$(pwd)

function setupDIR () {
    echo "Setting up build location and permissions"
    rm -rf ${FR_BASE} || true
    mkdir ${FR_BASE}
    chown -R ${USER}:${USER} ${FR_BASE}
    cd ${FR_BASE}
    echo "Done"
}

function getAPTDeps () {
    echo "Downloading apt deps"
    sed -i 's/deb\.debian\.org/ftp.de.debian.org/g' /etc/apt/sources.list
    apt-get -qq update
    apt-get -yqq dist-upgrade
    apt-get install --no-install-recommends -yqq curl gnupg2 lsb-release wget software-properties-common build-essential git autoconf automake libtool-bin pkg-config cmake zlib1g-dev libminizip-dev libpng-dev libreadline-dev libbz2-dev libudev-dev libudev1 python3-dev
    cp -LRP /usr/bin/ld ~/
    rm -rf /usr/bin/ld /usr/lib/x86_64-linux-gnu/lib{usb-1.0,png*}.so*
    curl -sO https://apt.llvm.org/llvm.sh
    chmod 0755 llvm.sh
    ./llvm.sh 13
    ln -sf /usr/bin/ld.lld-13 /usr/bin/ld
    echo "Done"
}

function cloneRepos () {
    echo "Cloning git repos and other deps"
    mkdir ${FR_BASE}/openssl
    cd ${FR_BASE}/openssl
    git init
    git remote add -t OpenSSL_1_1_1-stable origin https://github.com/openssl/openssl.git
    git fetch origin OpenSSL_1_1_1-stable
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/curl
    cd ${FR_BASE}/curl
    git init
    git remote add -t curl-7_78_0 origin https://github.com/curl/curl.git
    git fetch origin curl-7_78_0
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/xpwn
    cd ${FR_BASE}/xpwn
    git init
    git remote add -t master origin https://github.com/nyuszika7h/xpwn.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libzip
    cd ${FR_BASE}/libzip
    git init
    git remote add -t master origin https://github.com/nih-at/libzip.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/lzfse
    cd ${FR_BASE}/lzfse
    git init
    git remote add -t master origin https://github.com/lzfse/lzfse.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libplist
    cd ${FR_BASE}/libplist
    git init
    git remote add -t master origin https://github.com/libimobiledevice/libplist.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libusbmuxd
    cd ${FR_BASE}/libusbmuxd
    git init
    git remote add -t master origin https://github.com/libimobiledevice/libusbmuxd.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libimobiledevice-glue
    cd ${FR_BASE}/libimobiledevice-glue
    git init
    git remote add -t master origin https://github.com/libimobiledevice/libimobiledevice-glue.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libimobiledevice
    cd ${FR_BASE}/libimobiledevice
    git init
    git remote add -t master origin https://github.com/libimobiledevice/libimobiledevice.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libusb
    cd ${FR_BASE}/libusb
    git init
    git remote add -t master origin https://github.com/libusb/libusb.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libirecovery
    cd ${FR_BASE}/libirecovery
    git init
    git remote add -t master origin https://github.com/libimobiledevice/libirecovery.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libgeneral
    cd ${FR_BASE}/libgeneral
    git init
    git remote add -t master origin https://github.com/tihmstar/libgeneral.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/img4tool
    cd ${FR_BASE}/img4tool
    git init
    git remote add -t master origin https://github.com/m1stadev/img4tool.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libinsn
    cd ${FR_BASE}/libinsn
    git init
    git remote add -t master origin https://github.com/tihmstar/libinsn.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libfragmentzip
    cd ${FR_BASE}/libfragmentzip
    git init
    git remote add -t master origin https://github.com/tihmstar/libfragmentzip.git
    git fetch origin master
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/liboffsetfinder64
    cd ${FR_BASE}/liboffsetfinder64
    git init
    git remote add -t cryptic origin https://github.com/Cryptiiiic/liboffsetfinder64.git
    git fetch origin main
    git reset --hard FETCH_HEAD
    mkdir ${FR_BASE}/libipatcher
    cd ${FR_BASE}/libipatcher
    git init
    git remote add -t main origin https://github.com/Cryptiiiic/libipatcher.git
    git fetch origin main
    git reset --hard FETCH_HEAD
    git submodule init && git submodule update --recursive
    mkdir ${FR_BASE}/futurerestore
    cd ${FR_BASE}/futurerestore
    git init
    git remote add -t test origin https://github.com/m1stadev/futurerestore.git
    git fetch origin test
    git reset --hard FETCH_HEAD
    git submodule init && git submodule update --recursive
    cd external/tsschecker
    git submodule init && git submodule update --recursive
    cd ${FR_BASE}
    curl -sO https://opensource.apple.com/tarballs/cctools/cctools-927.0.2.tar.gz
    tar xf cctools-927.0.2.tar.gz -C ${FR_BASE}/
    mv cctools-927.0.2 cctools
    cd ${FR_BASE}/cctools
    sed -i 's_#include_//_g' include/mach-o/loader.h
    sed -i -e 's=<stdint.h>=\n#include <stdint.h>\ntypedef int integer_t;\ntypedef integer_t cpu_type_t;\ntypedef integer_t cpu_subtype_t;\ntypedef integer_t cpu_threadtype_t;\ntypedef int vm_prot_t;=g' include/mach-o/loader.h
    mkdir -p /tmp/out/include
    cp -LRP include/* /tmp/out/include
    cd ${FR_BASE}
    echo "Done"
}

function build () {
    echo "Building all deps and futurerestore"
    echo "Building openssl..."
    #openssl
    cd ${FR_BASE}/openssl
    ./Configure -C linux-x86_64-clang --prefix=/tmp/out ${CC_ARGS}
    make ${JNUM} ${LNUM} ${CC_ARGS} CFLAGS="${C_ARGS}" CXXFLAGS="${CXX_ARGS}" LDFLAGS="${LD_ARGS}" install_dev
    unlink /tmp/out/lib/libssl.so
    unlink /tmp/out/lib/libcrypto.so
    rm /tmp/out/lib/lib{crypto,ssl}.so*
    echo "Building curl..."
    #curl
    cd ${FR_BASE}/curl
    autoreconf -vi
    ./configure -C --prefix=/tmp/out --disable-debug --disable-dependency-tracking --with-openssl ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} ${CC_ARGS} CFLAGS="${C_ARGS}" CXXFLAGS="${CXX_ARGS}" LDFLAGS="${LD_ARGS}" install
    rm -rf /tmp/out/lib/libcurl.la /tmp/out/bin
    echo "Building xpwn..."
    #xpwn
    cd ${FR_BASE}/xpwn
    cmake ${CMAKE_ARGS} ${CC_ARGS} .
    sed -i 's/ \-Wl,\-\-allow\-multiple\-definition//g' ipsw-patch/CMakeFiles/xpwn.dir/link.txt common/CMakeFiles/common.dir/link.txt
    make ${JNUM} ${LNUM} ${CC_ARGS} CFLAGS="${C_ARGS}" CXXFLAGS="${CXX_ARGS}" LDFLAGS="${LD_ARGS}" common/fast xpwn/fast
    cp -LRP includes/* /tmp/out/include/
    cp -LRP ipsw-patch/libxpwn.a common/libcommon.a /tmp/out/lib
    apt-get remove -yqq libbz2-dev
    echo "Building libzip..."
    #libzip
    cd ${FR_BASE}/libzip
    cmake ${CMAKE_ARGS} ${CC_ARGS} .
    sed -i 's/ \-Wl,\-\-allow\-multiple\-definition//g' lib/CMakeFiles/zip.dir/link.txt
    sed -i '77,78d' cmake_install.cmake
    make ${JNUM} ${LNUM} ${CC_ARGS} CFLAGS="${C_ARGS}" CXXFLAGS="${CXX_ARGS}" LDFLAGS="${LD_ARGS}" zip/fast
    make ${JNUM} ${LNUM} install/strip/fast
    rm -rf /tmp/out/lib/cmake
    echo "Building lzfse..."
    #lzfse
    cd ${FR_BASE}/lzfse
    make ${JNUM} ${LNUM} INSTALL_PREFIX=/tmp/out install
    echo "Building libplist..."
    #libplist
    cd ${FR_BASE}/libplist
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libplist*.la
    echo "Building libimobiledevice-glue..."
    #libimobiledevice-glue
    cd ${FR_BASE}/libimobiledevice-glue
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libimobiledevice-glue*.la /tmp/out/share
    echo "Building libusbmuxd..."
    #libusbmuxd
    cd ${FR_BASE}/libusbmuxd
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS} -lpthread" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libusbmuxd*.la
    echo "Building libimobiledevice..."
    #libimobiledevice
    cd ${FR_BASE}/libimobiledevice
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS} -ldl" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libimobiledevice*.la /tmp/out/{bin,share}
    cd ${FR_BASE}/libusb
    echo "Building libusb..."
    #libusb
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS2}" LDFLAGS="${LD_ARGS2}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm /tmp/out/lib/libusb-1.0.la
    cd ${FR_BASE}/libirecovery
    echo "Building libirecovery..."
    #libirecovery
    cd ${FR_BASE}/libirecovery
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS2}" LDFLAGS="${LD_ARGS2} -ludev -lpthread" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libirecovery*.la /tmp/out/bin
    echo "Building libgeneral..."
    #libgeneral
    cd ${FR_BASE}/libgeneral
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libgeneral*.la
    echo "Building libinsn..."
    #libinsn
    cd ${FR_BASE}/libinsn
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libinsn*.la
    echo "Building img4tool..."
    #img4tool
    cd ${FR_BASE}/img4tool
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS} -lpthread -ldl" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libimg4tool*.la /tmp/out/bin
    echo "Building liboffsetfinder64..."
    #liboffsetfinder64
    cd ${FR_BASE}/liboffsetfinder64
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/liboffsetfinder64*.la
    echo "Building libfragmentzip..."
    #libfragmentzip
    cd ${FR_BASE}/libfragmentzip
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libfragmentzip*.la
    echo "Building libipatcher..."
    #libipatcher
    cd ${FR_BASE}/libipatcher
    ./autogen.sh ${CONF_ARGS} ${CC_ARGS} CFLAGS="${C_ARGS}" LDFLAGS="${LD_ARGS}" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM} install
    rm -rf /tmp/out/lib/libipatcher*.la
    echo "Building futurerestore!"
    #futurerestore
    cd ${FR_BASE}/futurerestore
    ./autogen.sh ${CONF_ARGS} --enable-static ${CC_ARGS} CFLAGS="${C_ARGS2} -DIDEVICERESTORE_NOMAIN=1 -DTSSCHECKER_NOMAIN=1" LDFLAGS="${LD_ARGS2} -lpthread -ldl -lusb-1.0 -ludev -lusbmuxd-2.0 -llzfse -lcommon -lxpwn" PKG_CONFIG_PATH="${PKG_CFG}"
    make ${JNUM} ${LNUM}
    make ${JNUM} ${LNUM} install
    echo "Done!"
}

function futurerestoreBuild () {
    echo "Welcome to futurerestore static builder script for linux made by @Cryptiiiic !"
    echo "If prompted, enter your password"
    echo -n ""
    echo "Compiling..."
    echo -n "Step 1: "
    setupDIR
    echo -n "Step 2: "
    getAPTDeps
    echo -n "Step 3: "
    cloneRepos
    echo -n "Step 4: "
    build
    echo -e "End\n"
    cd $DIR
    /tmp/out/bin/futurerestore || true
    ldd /tmp/out/bin/futurerestore || true
    echo ""
    export script_timer_stop=$(date +%s)
    export script_timer_time=$((script_timer_stop-script_timer_start))
    export script_timer_minutes=$(((script_timer_time % (60*60)) / 60))
    export script_timer_seconds=$(((script_timer_time % (60*60)) % 60))
    echo "Build completed in ""$script_timer_minutes"" minutes and ""$script_timer_seconds"" seconds!"
    unset FR_BASE CC_ARGS CMAKE_ARGS CONF_ARGS CXX_ARGS CXX_ARGS2 C_ARGS C_ARGS2 LD_ARGS LD_ARGS2 JNUM LNUM PKG_CFG script_timer_start script_timer_stop script_timer_time script_timer_minutes script_timer_seconds DIR
}

futurerestoreBuild

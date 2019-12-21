#!/bin/sh -e

#This script will compile and install a static ffmpeg build with support for nvenc on Centos 7.
#See the prefix path and compile options if edits are needed to suit your needs.

# Based on:  https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
# Based on:  https://gist.github.com/Brainiarc7/3f7695ac2a0905b05c5b
# Based on:  https://github.com/ilyaevseev/ffmpeg-build-static

# Rewritten here: https://github.com/ing-iancu/Centos-7-ffmpeg-build-with-nvec-support

# Globals
NASM_VERSION="2.14.03rc2"
YASM_VERSION="1.3.0"
LAME_VERSION="3.100"
OPUS_VERSION="1.3.1"
CUDA_DIR="/usr/local/cuda-10.2"
WORK_DIR="$HOME/ffmpeg-build-static-sources"
DEST_DIR="$HOME/ffmpeg-build-static-binaries"

mkdir -p "$WORK_DIR" "$DEST_DIR" "$DEST_DIR/bin"

export PATH="$DEST_DIR/bin:$PATH"

####  Routines  ################################################

Wget() { wget -cN "$@"; }

installYumLibs() {
      sudo yum -y install autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel freetype freetype-devel \
      libass xz xz-libs xz-devel pxz libvpx-devel yum-utils wget fribidi* \
      unzip  patch fontconfig* libass-devel bzip2-devel pulseaudio-libs-devel soxr soxr-devel \
      libtheora-devel libvorbis-devel libva-devel openssl-devel speex speex-devel openal-soft openal-soft-devel
}

installNvidiaSDK() {
    echo "Installing the nVidia NVENC SDK."
    cd "$WORK_DIR/"
    test -d nv-codec-headers || git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
    cd nv-codec-headers
    git pull
    make
    make install PREFIX="$DEST_DIR"
    patch -d "$DEST_DIR" -p1 < "$(dirname "$0")/dynlink_cuda.h.patch"
}

compileNasm() {
    echo "Compiling nasm"
    cd "$WORK_DIR/"
    Wget "http://www.nasm.us/pub/nasm/releasebuilds/$NASM_VERSION/nasm-$NASM_VERSION.tar.gz"
    tar xzvf "nasm-$NASM_VERSION.tar.gz"
    cd "nasm-$NASM_VERSION"
    ./configure --prefix="$DEST_DIR" --bindir="$DEST_DIR/bin"
    make -j$(nproc)
    make install distclean
}

compileYasm() {
    echo "Compiling yasm"
    cd "$WORK_DIR/"
    Wget "http://www.tortall.net/projects/yasm/releases/yasm-$YASM_VERSION.tar.gz"
    tar xzvf "yasm-$YASM_VERSION.tar.gz"
    cd "yasm-$YASM_VERSION/"
    ./configure --prefix="$DEST_DIR" --bindir="$DEST_DIR/bin"
    make -j$(nproc)
    make install distclean
}

compileLibX264() {
    echo "Compiling libx264"
    cd "$WORK_DIR/"
    git clone --depth 1 https://code.videolan.org/videolan/x264.git
    cd x264
    ./configure --prefix="$DEST_DIR" --bindir="$DEST_DIR/bin" --enable-static --enable-pic
    make -j$(nproc)
    make install distclean
}

compileLibX265() {
    cd "$WORK_DIR/"
    hg clone https://bitbucket.org/multicoreware/x265
    cd "$WORK_DIR/x265/build/linux/"
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$DEST_DIR" -DENABLE_SHARED:bool=off ../../source
    make -j$(nproc)
    make install
}

compileLibAom() {
    cd "$WORK_DIR/"
    test -d aom/.git || git clone --depth 1 https://aomedia.googlesource.com/aom
    cd aom
    git pull
    mkdir ../aom_build
    cd ../aom_build
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$DEST_DIR" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom
    make -j$(nproc)
    make install
}

compileLibfdkcc() {
    echo "Compiling libfdk-cc"
    cd "$WORK_DIR/"
    Wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
    unzip -o fdk-aac.zip
    cd mstorsjo-fdk-aac*
    autoreconf -fiv
    ./configure --prefix="$DEST_DIR" --disable-shared
    make -j$(nproc)
    make install distclean
}

compileLibMP3Lame() {
    echo "Compiling libmp3lame"
    cd "$WORK_DIR/"
    Wget "http://downloads.sourceforge.net/project/lame/lame/$LAME_VERSION/lame-$LAME_VERSION.tar.gz"
    tar xzvf "lame-$LAME_VERSION.tar.gz"
    cd "lame-$LAME_VERSION"
    ./configure --prefix="$DEST_DIR" --enable-nasm --disable-shared
    make -j$(nproc)
    make install distclean
}

compileLibOpus() {
    echo "Compiling libopus"
    cd "$WORK_DIR/"
    Wget "http://downloads.xiph.org/releases/opus/opus-$OPUS_VERSION.tar.gz"
    tar xzvf "opus-$OPUS_VERSION.tar.gz"
    cd "opus-$OPUS_VERSION"
    #./autogen.sh
    ./configure --prefix="$DEST_DIR" --disable-shared
    make -j$(nproc)
    make install distclean
}

compileLibVpx() {
    echo "Compiling libvpx"
    cd "$WORK_DIR/"
    test -d libvpx || git clone https://chromium.googlesource.com/webm/libvpx
    cd libvpx
    git pull
    ./configure --prefix="$DEST_DIR" --disable-examples --enable-runtime-cpu-detect --enable-vp9 --enable-vp8 \
    --enable-postproc --enable-vp9-postproc --enable-multi-res-encoding --enable-webm-io --enable-better-hw-compatibility \
    --enable-vp9-highbitdepth --enable-onthefly-bitpacking --enable-realtime-only \
    --cpu=native --as=nasm
    make -j$(nproc)
    make install clean
}

compileFfmpeg(){
    echo "Compiling ffmpeg"
    cd "$WORK_DIR/"
    curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    tar xjvf ffmpeg-snapshot.tar.bz2
    cd ffmpeg
    export PATH="$CUDA_DIR/bin:$PATH"  # ..path to nvcc
    PKG_CONFIG_PATH="$DEST_DIR/lib/pkgconfig:$DEST_DIR/lib64/pkgconfig" \
    ./configure \
      --pkg-config-flags="--static" \
      --prefix="$DEST_DIR" \
      --bindir="$DEST_DIR/bin" \
      --extra-cflags="-I $DEST_DIR/include -I $CUDA_DIR/include/" \
      --extra-ldflags="-L $DEST_DIR/lib -L $CUDA_DIR/lib64/" \
      --extra-libs="-lpthread" \
      --extra-libs="-lm" \
      --extra-libs="-lssl" \
      --extra-libs="-lcrypto" \
      --enable-cuda-sdk \
      --enable-cuvid \
      --enable-cuda  \
      --enable-nvdec \
      --enable-nvenc \
      --enable-libnpp \
      --enable-gpl \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-vaapi \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nonfree \
      --enable-version3 \
      --enable-muxer=rtsp \
      --enable-protocol=rtp \
      --enable-demuxer=rtsp \
      --enable-static \
      --enable-runtime-cpudetect \
      --enable-bzlib \
      --enable-openal \
      --enable-libass \
      --enable-libpulse \
      --enable-libsoxr \
      --enable-libspeex \
      --enable-openssl \
      --disable-vdpau \
      --disable-doc \
      --disable-shared \
      --extra-cflags=-fopenmp \
      --extra-ldflags=-fopenmp \
      --disable-libmfx
    make -j$(nproc)
    make install distclean
    hash -r
}

installYumLibs
installNvidiaSDK
compileNasm
compileYasm
compileLibX264
compileLibX265
compileLibVpx
compileLibfdkcc
compileLibMP3Lame
compileLibOpus
compileFfmpeg

echo "Complete!"

## END ##

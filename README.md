# Centos 7 

# Build ffmpeg with NVEC support

Script for compile and install a static ffmpeg build with nvenc support in Centos 7

REQUIREMENTS:
# Fresh Centos 7 with DEVELOPMENT TOOLS (tested on Centos 7.6.1810 X64)

#uname -sr

Linux 3.10.0-957.el7.x86_64

1. Upgrade kernel to 4.XX

#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

#yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

#yum --enablerepo=elrepo-kernel install kernel-lt kernel-lt-devel

#reboot

#uname -sr

Linux 4.4.206-1.el7.elrepo.x86_64

#awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg

CentOS Linux (4.4.206-1.el7.elrepo.x86_64) 7 (Core)

CentOS Linux (3.10.0-1062.9.1.el7.x86_64) 7 (Core)

CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)

CentOS Linux (0-rescue-57cfab6b42da4c67a0bf4d95ed53251b) 7 (Core)


#nano -w /etc/default/grub

Add GRUB_DEFAULT=2 at end of this file as follow:

GRUB_TIMEOUT=5

GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"

GRUB_DEFAULT=saved

GRUB_DISABLE_SUBMENU=true

GRUB_TERMINAL_OUTPUT="console"

GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"

GRUB_DISABLE_RECOVERY="true"

GRUB_DEFAULT=0

Commit this change:

#grub2-mkconfig -o /boot/grub2/grub.cfg 

Reboot

#reboot

Check again your kernel version:

#uname -sr

Linux 4.4.206-1.el7.elrepo.x86_64

# Important: CUDA Toolkit doesn't work with any kernel more 5 

Install CUDA Toolkit 10.2 following instructions from: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=CentOS&target_version=7&target_type=runfilelocal

Attention: is biggest file, around 2,5 GB

#wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run

#sudo sh cuda_10.2.89_440.33.01_linux.run

Type accept and Install (with video driver)

Update database to search nvcc

#updatedb

#locate nvcc

[root@ns webmaster]# locate nvcc
/usr/local/cuda-10.2/bin/nvcc

On script install_ffmpeg_centos7.sh modify value as follow:

CUDA_DIR="/usr/local/cuda-10.2"

To install few libraries (libass, soxr and another) try:

#rpm -Uvh https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm

Now is time to run my script:

#bash install_ffmpeg_centos7.sh

After a lot of messages, finay must have:

...........

INSTALL libavutil/libavutil.pc

Complete!

You can job done as follow:

#cd /root/ffmpeg-build-static-binaries/bin/

#./ffmpeg

ffmpeg version N-96108-g191df4f Copyright (c) 2000-2019 the FFmpeg developers

  built with gcc 4.8.5 (GCC) 20150623 (Red Hat 4.8.5-39)
  
  configuration: --pkg-config-flags=--static --prefix=/root/ffmpeg-build-static-binaries --bindir=/root/ffmpeg-build-static-binaries/bin --extra-cflags='-I /root/ffmpeg-build-static-binaries/include -I /usr/local/cuda-10.2/include/' --extra-ldflags='-L /root/ffmpeg-build-static-binaries/lib -L /usr/local/cuda-10.2/lib64/' --extra-libs=-lpthread --extra-libs=-lm --extra-libs=-lssl --extra-libs=-lcrypto --enable-cuda-sdk --enable-cuvid --enable-cuda --enable-nvdec --enable-nvenc --enable-libnpp --enable-gpl --enable-libass --enable-libfdk-aac --enable-vaapi --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-version3 --enable-muxer=rtsp --enable-protocol=rtp --enable-demuxer=rtsp --enable-static --enable-runtime-cpudetect --enable-bzlib --enable-openal --enable-libass --enable-libpulse --enable-libsoxr --enable-libspeex --enable-openssl --disable-vdpau --disable-doc --disable-shared --extra-cflags=-fopenmp --extra-ldflags=-fopenmp --disable-libmfx
  
  libavutil      56. 36.101 / 56. 36.101
  
  libavcodec     58. 65.100 / 58. 65.100
  
  libavformat    58. 35.101 / 58. 35.101
  
  libavdevice    58.  9.101 / 58.  9.101
  
  libavfilter     7. 69.101 /  7. 69.101
  
  libswscale      5.  6.100 /  5.  6.100
  
  libswresample   3.  6.100 /  3.  6.100
  
  libpostproc    55.  6.100 / 55.  6.100
  
Hyper fast Audio and Video encoder

usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...

Use -h to get full help or, even better, run 'man ffmpeg'

# IMPORTANT! If you want to use more ffmpeg with nvec (ex: for video transcoding), think to follow steps from "Disable the Nvidia nouveau open source driver" In atother case, just ignore that.

Enjoy!







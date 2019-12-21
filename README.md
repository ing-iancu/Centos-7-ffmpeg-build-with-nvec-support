# Centos-7-ffmpeg-build-with-nvec-support
Script for compile and install a static ffmpeg build with nvenc support in Centos 7

REQUIREMENTS:
Fresh Centos 7 (tested on Centos 7.6.1810 X64)

#uname -sr

Linux 3.10.0-957.el7.x86_64

1. Upgrade kernel to 4.2X

#uname -sr

Linux 4.20.13-1.el7.elrepo.x86_64

Install CUDA Toolkit 10.2 following instructions from: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=CentOS&target_version=7&target_type=runfilelocal

#wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run

#sudo sh cuda_10.2.89_440.33.01_linux.run

Update database to search nvcc

#updatedb

#locate nvcc






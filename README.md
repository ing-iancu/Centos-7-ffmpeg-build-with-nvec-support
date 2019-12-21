# Centos-7-ffmpeg-build-with-nvec-support
Script for compile and install a static ffmpeg build with nvenc support in Centos 7

REQUIREMENTS:
Fresh Centos 7 with DEVELOPMENT TOOLS (tested on Centos 7.6.1810 X64)

#uname -sr

Linux 3.10.0-957.el7.x86_64

1. Upgrade kernel to 5.XX

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








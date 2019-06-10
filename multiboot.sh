#!/bin/bash
#
# base script by PMT, 3 Jan 2010 (contact via http://blog.p-mt.net/archives/644)
# Version 0.55
# updated and rewritten by Bzzz, 18. Apr 2013 (contact via http://de.hardware-wiki.org/wiki/Benutzer:Bzzz)
# Version 0.86
#
# this script generates a Multiboot flash drive
# using GRUB2 and direct access to iso files
#

# Hint:
# test usb flash drive: sudo qemu -m 1024 -hda /dev/sdb
# 64 bit guests need a 64 bit host system
# there are no known options for qemu to boot efi images like ubuntu 13.10 x64
#
# qemu somehow often needs a remount of the flash drive
# after a new grub.cfg has been written
# you can try
# sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
# instead of ejecting the drive (Kernel 2.6.16+)
# or enable this one to auto-drop caches:
DROPCACHES=1

# preparing usb flash drive
#
# create filesystem on flash drive: (length restriction of label!)
# DEVICE=/dev/sdb
# USB_LABEL="USBmulti"
# sudo mkfs.vfat -n $USB_LABEL ${DEVICE}1
#
# install grub2 on flash drive:
# sudo apt-get install grub2
# [ ! -d /media/$USB_LABEL ] && sudo mkdir /media/$USB_LABEL
# sudo mount ${DEVICE}1 /media/$USB_LABEL 
# sudo grub-install --no-floppy --root-directory=/media/$USB_LABEL ${DEVICE}


# ###### Script, menu, misc configuration ################################################
# flash drive label in /media directory
USB_LABEL="USBMULTI"
USERNAME=$(whoami)
MOUNTDIR=/media/$USERNAME/$USB_LABEL
# path on flash drive where the iso images shall reside (not safe to change atm!)
ISOPATH=/boot/iso
# Path to grub directory on pendrive (same here, please do not change)
GRUBPATH=/boot/grub
# uncomment the following line if iso's shall get md5sum check
# MD5SUM_CHECK=1 
# Background image for the boot menu (see notes on PMTs blog)
#SPLASH_IMAGE=/boot/grub/background.tga
# uncomment the following line if you also want broken/testing menu entries
#TESTING=1 

# for reference: wikipedia de and en, distrowatch
WP_DE_URL="http://de.wikipedia.org/wiki/"
WP_EN_URL="http://en.wikipedia.org/wiki/"
DW_URL="http://distrowatch.com/table.php?distribution="


# ###### Downloads ################################################
# Change the following lines to a number greater than zero if you want to auto-download 
# the respective files. Make sure you have enough free space on your flash drive and a fast
# internet connection. Setting the DOWNLOADALL parameter to 1 will download !ALL! files that are
# currently added in this script. This will eat some 20+ gigabytes and includes
# for example many different copies of ubuntu/kubuntu for x86 and x64 systems in both
# normal desktop and alternative installer versions. It is therefore recommended
# to just enable the things you really need!
# Files that already exist will not be downloaded again. However, if a download
# failed for any reason and the broken file is still present, you will need to delete it first.

#Limit parallel downloads and speed (bytes/s) per download here:
PARALLEL_DOWNLOADS=1
DL_SPEED=10000000

DOWNLOADALL=1
# GFX download gets some example backgrounds from PMTs blog and the required unicode.pf2
DL_GFX=0
# 32=i386, 64=AMD64
# -LTS- = LongTermStable with extended support; 1000 MB each
DL_UBUNTU32=0		#works
DL_UBUNTU64=0		#works
DL_UBUNTULTS32=0	#works
DL_UBUNTULTS64=0	#works
#Debian: C=CD version (700 MB), N=NetInstall (200 MB)############################
DL_DEBIAN32C=0		#no cd drive detected
DL_DEBIAN64C=0		#no cd drive detected
DL_DEBIAN32N=0		#no cd drive detected
DL_DEBIAN64N=0		#no cd drive detected
#Siduction: CInnamon, GNome, KDe, LXDe, LXQt, MAte, NOx, XFce, XOrg#######
DL_SIDUCTIONCI=0	
DL_SIDUCTIONGN=0	
DL_SIDUCTIONKD=0	
DL_SIDUCTIONLXD=0
DL_SIDUCTIONLQT=0	
DL_SIDUCTIONMA=0	
DL_SIDUCTIONNO=0	
DL_SIDUCTIONXF=0	
DL_SIDUCTIONXO=0	
#GRML: 32 / 64 (350 MB each), 96 (equals 32+64) (700 MB)########################
DL_GRML32=0		#works
DL_GRML64=0		#works
DL_GRML96=0		#works
#Slax (200MB)##################################################################
DL_SLAX=0		#works
#Puppy Linux: S = Slacko (120 MB), P=Precise (170 MB), W=Wary (140 MB)#############################
DL_PUPPYP=0		#puppy files not found
DL_PUPPYW=0		#puppy files not found
DL_PUPPYS=0		#puppy files not found
#Tiny Core Linux: Standard (12 MB), Plus (66 MB) ##################################
DL_TINYCORES=0		#works
DL_TINYCOREP=0		#works
#Linux Mint: 	C= Cinnamon (GNOME3 + Clutter, 900 MB each) M = Mate (GNOME2, 1000 MB each ),
#		K = KDE (KDE4, 1000 MB each), X = XFCE (900 MB each)
DL_MINTC32=0		#works
DL_MINTC64=0		#works
DL_MINTM32=0		#works
DL_MINTM64=0		#login loop
DL_MINTK32=0		#works
DL_MINTK64=0		#works
DL_MINTX32=0		#works
DL_MINTX64=0		#works
#Zenwalk (600 MB)######)#######################################################
DL_ZENWALKF=0		#unable to mount root fs
DL_ZENWALKC=0		#unable to mount root fs
#XBMC Live (420 MB)######)#######################################################
DL_XBMC=0		#unable to find a medium containing a live file system
#PLOP (Base = 90 MB, Full = 1000 MB, currently no x64 small version available)############################################
DL_PLOP32B=0		#works
DL_PLOP32F=0		#works
DL_PLOP64F=0		#works
#Parted Magic (320 MB)##########################################################
DL_PMAGIC686=0		#works
#Memtest (1MB)#################################################################
DL_MEMTEST=0		#works
#Clonezilla (110 MB)##########################################################
DL_CZILLA486=0		#works
DL_CZILLAX64=0		#works
#Phoronix Live (1400 MB)#)######################################################
DL_PHORONIX=0		#works, manual download only (softpedia block, 
#	visit http://www.softpedia.com/redir2.php?pid=500049794)
#Ultimate Boot CD (360 MB)######################################################
DL_UBCD=0		#needs extraction
#Knoppix (CD = 700 MB, DVD = 3900 MB)###############################################
DL_KNOPPIXC=0		#works
DL_KNOPPIXD=0		#works
#AntiX (Net = 150MB, Core= , Base= , Full = 800MB)###############################################
DL_ANTIXN32=0		#works
DL_ANTIXC32=0		#works
DL_ANTIXB32=0		#works
DL_ANTIXF32=0		#works
DL_ANTIXN64=0		#works
DL_ANTIXC64=0		#works
DL_ANTIXB64=0		#works
DL_ANTIXF64=0		#works
#System Rescue CD (370 MB)######################################################
DL_SYSRCD=0		#works
#GParted######################################################
DL_GPARTED32=0	 #works
DL_GPARTED64=0	#works
#Hardware Detection Tool HDTd######################################################
DL_HDT=1	 	 

################################
#create grub entry for windows 7 installer if there is a second partition on the drive
CREATE_W7=0

#########Version info of downloads ############################################
UBUNTU_NAME="(K)Ubuntu"
UBUNTU_DATE="2017-12-29"
UBUNTU_LOGO="http://upload.wikimedia.org/wikipedia/commons/9/9d/Ubuntu_logo.svg"
UBUNTU_VERSION="Kubuntu 17.10 Artful Aardvark"
UBUNTU_BASEURL="http://www.mirrorservice.org/sites/cdimage.ubuntu.com/cdimage/kubuntu/releases/17.10/release/"
UBUNTU_VERSIONURL="kubuntu-17.10"
UBUNTULTS_VERSION="Ubuntu 16.04.6 LTS Xenial Xerus"
UBUNTULTS_BASEURL="http://ftp.uni-kl.de/pub/linux/ubuntu.iso/16.04.6/"
UBUNTULTS_VERSIONURL="ubuntu-16.04.6"

DEBIAN_NAME="Debian"
DEBIAN_DATE="2017-12-29"
DEBIAN_LOGO=""
DEBIAN_VERSION="Debian 9.3.0 Stretch"
DEBIAN32_BASEURL="http://cdimage.debian.org/debian-cd/9.3.0/i386/iso-cd/"
DEBIAN64_BASEURL="http://cdimage.debian.org/debian-cd/9.3.0/amd64/iso-cd/"
DEBIAN_VERSIONURL="debian-9.3.0"

SIDUCTION_NAME="Siduction"
SIDUCTION_DATE="2017-12-29"
SIDUCTION_LOGO=""
SIDUCTION_VERSION="Siduction Patience 17.1.0"
SIDUCTION_BASEURL="http://ftp.spline.de/mirrors/siduction/iso/patience"
SIDUCTION_VERSIONURL="siduction-17.1.0-patience"
SIDUCTION_BUILDDATEYY="2017"
SIDUCTION_BUILDDATEMM="03"
SIDUCTION_BUILDDATEDD="05"
SIDUCTION_BUILDDATECI_HH="17"
SIDUCTION_BUILDDATECI_MM="34"
SIDUCTION_BUILDDATEGN_HH="17"
SIDUCTION_BUILDDATEGN_MM="48"
SIDUCTION_BUILDDATEKD_HH="17"
SIDUCTION_BUILDDATEKD_MM="55"
SIDUCTION_BUILDDATELXD_HH="18"
SIDUCTION_BUILDDATELXD_MM="24"
SIDUCTION_BUILDDATELQT_HH="18"
SIDUCTION_BUILDDATELQT_MM="30"
SIDUCTION_BUILDDATEMA_HH="18"
SIDUCTION_BUILDDATEMA_MM="54"
SIDUCTION_BUILDDATENO_HH="19"
SIDUCTION_BUILDDATENO_MM="00"
SIDUCTION_BUILDDATEXF_HH="19"
SIDUCTION_BUILDDATEXF_MM="04"
SIDUCTION_BUILDDATEXO_HH="19"
SIDUCTION_BUILDDATEXO_MM="10"

GRML_NAME="grml"
GRML_DATE="2017-12-29"
GRML_LOGO=""
GRML_VERSION="grml 2017.05"
GRML_BASEURL="http://download.grml.org/"
GRML_VERSIONURL="2017.05"

SLAX_NAME="Slax"
SLAX_DATE="2017-12-29"
SLAX_LOGO=""
SLAX_VERSION="Slax 9.3.0"
SLAX_BASEURL="http://ftp.sh.cvut.cz/slax/"
SLAX_VERSIONURL="Slax-9.x"

PUPPY_NAME="Puppy Linux"
PUPPY_DATE=""
PUPPY_LOGO="2017-12-29"
PUPPYP_VERSION="Puppy Linux 5.7"
PUPPYW_VERSION="Puppy Linux 5.7"
PUPPYS_VERSION="Puppy Linux 5.6"
PUPPY_BASEURL="http://distro.ibiblio.org/"
PUPPYP_VERSIONURL="quirky/precise-5.7.1/"
PUPPYW_VERSIONURL="quirky/wary-5.3/"
PUPPYS_VERSIONURL="puppylinux/puppy-5.6/"

TINYCORE_NAME="Tiny Core Linux"
TINYCORE_DATE="2017-12-29"
TINYCORE_LOGO=""
TINYCORE_VERSION="Tiny Core Linux 8.2.1"
TINYCORE_BASEURL="http://distro.ibiblio.org/tinycorelinux/"
TINYCORE_VERSIONURL="8.x/x86/release/"

MINT_NAME="Linux Mint"
MINT_DATE="2017-12-29"
MINT_LOGO=""
MINT_VERSION="Linux Mint 18.3 Sylvia"
MINT_BASEURL="http://ftp5.gwdg.de/pub/linux/debian/mint/stable/"
MINT_VERSIONURL="18.3/linuxmint-18.3-"
MINT_VFILEURL="linuxmint-18.3-"

ZENWALK_NAME="Zenwalk"
ZENWALK_DATE="2017-12-30"
ZENWALK_LOGO=""
ZENWALK_VERSION="Zenwalk 8.0"
ZENWALK_BASEURL="https://zen-repo.meticul.eu/x86_64"
ZENWALK_VERSIONURL="8.0"

XBMC_NAME="XBMC"
XBMC_DATE="2013-02-02"
XBMC_LOGO=""
XBMC_VERSION="XBMC 10.1 Dharma"
XBMC_BASEURL="http://mirrors.xbmc.org/releases/live/"

PLOP_NAME="PLOP"
PLOP_DATE="2017-12-29"
PLOP_LOGO=""
PLOP_VERSION="PLOP 4.3.3"
PLOP_BASEURL="http://download.plop.at/ploplinux/"
PLOP_VERSIONURL="4.3.3"

PMAGIC_NAME="Parted Magic"
PMAGIC_DATE="2013-05-04"
PMAGIC_LOGO=""
PMAGIC_VERSION="Parted Magic 2013_05_01"
PMAGIC_BASEURL="http://downloads.sourceforge.net/project/partedmagic/partedmagic/"
PMAGIC_VERSIONURL="Parted%20Magic%202013_05_01/"

MEMTEST_NAME="Memtest86+"
MEMTEST_DATE="2017-12-29"
MEMTEST_LOGO=""
MEMTEST_VERSION="Memtest86+ 5.01"
MEMTEST_BASEURL="http://www.memtest.org/download/"
MEMTEST_VERSIONURL="5.01"

CZILLA_NAME="Clonezilla"
CZILLA_DATE="2017-12-30"
CZILLA_LOGO=""
CZILLA_VERSION="Clonezilla Live 2.5.2-31"
CZILLA_BASEURL="http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/"
CZILLA_VERSIONURL="2.5.2-31/"

PHORONIX_NAME="Phoronix"
PHORONIX_DATE=""
PHORONIX_LOGO=""
PHORONIX_VERSION="Phoronix Live 2010.1"
PHORONIX_BASEURL="http://download.softpedia.ro/dl/41df9981792dcfc470d3a03e068d1fcb/502ac6c2/500049794/linux/"

UBCD_NAME="Ultimate Boot CD"
UBCD_DATE="2017-12-29"
UBCD_LOGO=""
UBCD_VERSION="Ultimate Boot CD 5.37"
UBCD_BASEURL="http://filemirror.hu/pub/ubcd/"

KNOPPIX_NAME="Knoppix"
KNOPPIX_DATE="2017-12-29"
KNOPPIX_LOGO=""
KNOPPIX_VERSION="Knoppix 7.2/8.1"
KNOPPIX_BASEURL="http://ftp.uni-kl.de/pub/linux"

ANTIX_NAME="AntiX"
ANTIX_DATE="2018-02-16"
ANTIX_LOGO=""
ANTIX_VERSION="antiX-17"
ANTIX_BASEURL="http://it.mxrepo.com/Final/antiX-17/"

SYSRCD_NAME="System Rescue CD"
SYSRCD_DATE="2017-12-30"
SYSRCD_LOGO=""
SYSRCD_VERSION="System Rescue CD 5.1.2"
SYSRCD_BASEURL="http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/"
SYSRCD_VERSIONURL="5.1.2"

GPARTED_NAME="GParted"
GPARTED_DATE="2018-03-25"
GPARTED_LOGO=""
GPARTED_VERSION="0.31.0-1"
GPARTED_BASEURL="https://netix.dl.sourceforge.net/project/gparted/gparted-live-stable/"

HDT_NAME="Hardware Detection Tool"
HDT_DATE="2018-03-25"
HDT_LOGO=""
HDT_VERSION="0.3.6"
HDT_BASEURL="http://www.serverelements.com/bin/"

# specimen
A_NAME=""
A_DATE=""
A_LOGO=""
A_VERSION=""
A_BASEURL=""
A_VERSIONURL=""

## ######Basic tasks ################################################

# below this point, no user changes should be necessary for most distributions

# on flash drive
[ ! -d $MOUNTDIR ] && sudo mkdir $MOUNTDIR
[ ! "`mount | grep  $USB_LABEL`" ] && sudo mount /dev/disk/by-label/$USB_LABEL $MOUNTDIR
DOWNLOADPATH=$MOUNTDIR$ISOPATH
[ ! -d $DOWNLOADPATH ] &&  mkdir $DOWNLOADPATH


#Ubuntu
UBUNTU_TITLE="$UBUNTU_VERSION"
UBUNTU32_TITLE="$UBUNTU_VERSION i386 Desktop"
UBUNTU64_TITLE="$UBUNTU_VERSION AMD64 Desktop"
UBUNTU32_FILE="desktop-i386.iso"
UBUNTU64_FILE="desktop-amd64.iso"
UBUNTU32_URL="$UBUNTU_BASEURL$UBUNTU_VERSIONURL-$UBUNTU32_FILE"
UBUNTU64_URL="$UBUNTU_BASEURL$UBUNTU_VERSIONURL-$UBUNTU64_FILE"
UBUNTU32_ISO=`basename $UBUNTU32_URL`
UBUNTU64_ISO=`basename $UBUNTU64_URL`  
#same procedure for Ubuntu LTS version
UBUNTULTSD_TITLE="$UBUNTULTS_VERSION Deskop"
UBUNTULTS32_TITLE="$UBUNTULTS_VERSION i386 Deskop"
UBUNTULTS64_TITLE="$UBUNTULTS_VERSION AMD64 Deskop"
UBUNTULTS32_FILE="desktop-i386.iso"
UBUNTULTS64_FILE="desktop-amd64.iso"
UBUNTULTS32_URL="$UBUNTULTS_BASEURL$UBUNTULTS_VERSIONURL-$UBUNTULTS32_FILE"
UBUNTULTS64_URL="$UBUNTULTS_BASEURL$UBUNTULTS_VERSIONURL-$UBUNTULTS64_FILE"
UBUNTULTS32_ISO=`basename $UBUNTULTS32_URL`
UBUNTULTS64_ISO=`basename $UBUNTULTS64_URL`  
#Debian
DEBIANS_TITLE="$DEBIAN_VERSION CD"
DEBIANN_TITLE="$DEBIAN_VERSION NetInstall"
DEBIAN32C_TITLE="$DEBIAN_VERSION i386 CD"
DEBIAN64C_TITLE="$DEBIAN_VERSION AMD64 CD"
DEBIAN32N_TITLE="$DEBIAN_VERSION i386 NetInstall"
DEBIAN64N_TITLE="$DEBIAN_VERSION AMD64 NetInstall"
DEBIAN32C_FILE="i386-xfce-CD-1.iso"
DEBIAN64C_FILE="amd64-xfce-CD-1.iso"
DEBIAN32N_FILE="i386-netinst.iso"
DEBIAN64N_FILE="amd64-netinst.iso"
DEBIAN32C_URL="$DEBIAN32_BASEURL$DEBIAN_VERSIONURL-$DEBIAN32C_FILE"
DEBIAN64C_URL="$DEBIAN64_BASEURL$DEBIAN_VERSIONURL-$DEBIAN64C_FILE"
DEBIAN32N_URL="$DEBIAN32_BASEURL$DEBIAN_VERSIONURL-$DEBIAN32N_FILE"
DEBIAN64N_URL="$DEBIAN64_BASEURL$DEBIAN_VERSIONURL-$DEBIAN64N_FILE"
DEBIAN32C_ISO=`basename $DEBIAN32C_URL`
DEBIAN64C_ISO=`basename $DEBIAN64C_URL`
DEBIAN32N_ISO=`basename $DEBIAN32N_URL`
DEBIAN64N_ISO=`basename $DEBIAN64N_URL`
#Siduction
SIDUCTIONCI_TITLE="$SIDUCTION_VERSION Cinnamon"
SIDUCTIONGN_TITLE="$SIDUCTION_VERSION GNOME"
SIDUCTIONKD_TITLE="$SIDUCTION_VERSION KDE"
SIDUCTIONLXD_TITLE="$SIDUCTION_VERSION LXDE"
SIDUCTIONLQT_TITLE="$SIDUCTION_VERSION LXQT"
SIDUCTIONMA_TITLE="$SIDUCTION_VERSION MATE"
SIDUCTIONNO_TITLE="$SIDUCTION_VERSION NOX"
SIDUCTIONXF_TITLE="$SIDUCTION_VERSION XFCE"
SIDUCTIONXO_TITLE="$SIDUCTION_VERSION Xorg"
SIDUCTIONCI_FILE="$SIDUCTION_VERSIONURL-cinnamon-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATECI_HH$SIDUCTION_BUILDDATECI_MM.iso"
SIDUCTIONGN_FILE="$SIDUCTION_VERSIONURL-gnome-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATEGN_HH$SIDUCTION_BUILDDATEGN_MM.iso"
SIDUCTIONKD_FILE="$SIDUCTION_VERSIONURL-kde-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATEKD_HH$SIDUCTION_BUILDDATEKD_MM.iso"
SIDUCTIONLXD_FILE="$SIDUCTION_VERSIONURL-lxde-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATELXD_HH$SIDUCTION_BUILDDATELXD_MM.iso"
SIDUCTIONLQT_FILE="$SIDUCTION_VERSIONURL-lxqt-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATELQT_HH$SIDUCTION_BUILDDATELQT_MM.iso"
SIDUCTIONMA_FILE="$SIDUCTION_VERSIONURL-mate-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATEMA_HH$SIDUCTION_BUILDDATEMA_MM.iso"
SIDUCTIONNO_FILE="$SIDUCTION_VERSIONURL-nox-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATENO_HH$SIDUCTION_BUILDDATENO_MM.iso"
SIDUCTIONXF_FILE="$SIDUCTION_VERSIONURL-xfce-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATEXF_HH$SIDUCTION_BUILDDATEXF_MM.iso"
SIDUCTIONXO_FILE="$SIDUCTION_VERSIONURL-xorg-amd64-$SIDUCTION_BUILDDATEYY$SIDUCTION_BUILDDATEMM$SIDUCTION_BUILDDATEDD$SIDUCTION_BUILDDATEXO_HH$SIDUCTION_BUILDDATEXO_MM.iso"
SIDUCTIONCI_URL="$SIDUCTION_BASEURL/cinnamon/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATECI_HH-$SIDUCTION_BUILDDATECI_MM/$SIDUCTIONCI_FILE"
SIDUCTIONGN_URL="$SIDUCTION_BASEURL/gnome/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATEGN_HH-$SIDUCTION_BUILDDATEGN_MM/$SIDUCTIONGN_FILE"
SIDUCTIONKD_URL="$SIDUCTION_BASEURL/kde/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATEKD_HH-$SIDUCTION_BUILDDATEKD_MM/$SIDUCTIONKD_FILE"
SIDUCTIONLXD_URL="$SIDUCTION_BASEURL/lxde/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATELXD_HH-$SIDUCTION_BUILDDATELXD_MM/$SIDUCTIONLXD_FILE"
SIDUCTIONLQT_URL="$SIDUCTION_BASEURL/lxqt/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATELQT_HH-$SIDUCTION_BUILDDATELQT_MM/$SIDUCTIONLQT_FILE"
SIDUCTIONMA_URL="$SIDUCTION_BASEURL/mate/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATEMA_HH-$SIDUCTION_BUILDDATEMA_MM/$SIDUCTIONMA_FILE"
SIDUCTIONNO_URL="$SIDUCTION_BASEURL/nox/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATENO_HH-$SIDUCTION_BUILDDATENO_MM/$SIDUCTIONNO_FILE"
SIDUCTIONXF_URL="$SIDUCTION_BASEURL/xfce/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATEXF_HH-$SIDUCTION_BUILDDATEXF_MM/$SIDUCTIONXF_FILE"
SIDUCTIONXO_URL="$SIDUCTION_BASEURL/xorg/amd64_$SIDUCTION_BUILDDATEYY-$SIDUCTION_BUILDDATEMM-$SIDUCTION_BUILDDATEDD'_'$SIDUCTION_BUILDDATEXO_HH-$SIDUCTION_BUILDDATEXO_MM/$SIDUCTIONXO_FILE"
SIDUCTIONCI_ISO=`basename $SIDUCTIONCI_URL`
SIDUCTIONGN_ISO=`basename $SIDUCTIONGN_URL`
SIDUCTIONKD_ISO=`basename $SIDUCTIONKD_URL`
SIDUCTIONLXD_ISO=`basename $SIDUCTIONLXD_URL`
SIDUCTIONLQT_ISO=`basename $SIDUCTIONLQT_URL`
SIDUCTIONMA_ISO=`basename $SIDUCTIONMA_URL`
SIDUCTIONNO_ISO=`basename $SIDUCTIONNO_URL`
SIDUCTIONXF_ISO=`basename $SIDUCTIONXF_URL`
SIDUCTIONXO_ISO=`basename $SIDUCTIONXO_URL`
#grml
GRML_TITLE="$GRML_VERSION"
GRML32_TITLE="$GRML_VERSION i386"
GRML64_TITLE="$GRML_VERSION AMD64"
GRML96_TITLE="$GRML_VERSION 96"
GRML32_FILE="grml32-full_$GRML_VERSIONURL.iso"
GRML64_FILE="grml64-full_$GRML_VERSIONURL.iso"
GRML96_FILE="grml96-full_$GRML_VERSIONURL.iso"
GRML32_URL="$GRML_BASEURL$GRML32_FILE"
GRML64_URL="$GRML_BASEURL$GRML64_FILE"
GRML96_URL="$GRML_BASEURL$GRML96_FILE"
GRML32_ISO=`basename $GRML32_URL`
GRML64_ISO=`basename $GRML64_URL`
GRML96_ISO=`basename $GRML96_URL`
#Slax
SLAX_TITLE="$SLAX_VERSION"
SLAX_FILE="slax-64bit-9.3.0.iso"
SLAX_URL="$SLAX_BASEURL$SLAX_VERSIONURL/$SLAX_FILE"
SLAX_ISO=`basename $SLAX_URL`
#Puppy
PUPPYP_TITLE="$PUPPYP_VERSION Precise"
PUPPYW_TITLE="$PUPPYW_VERSION Wary"
PUPPYS_TITLE="$PUPPYS_VERSION Slacko"
PUPPYP_FILE="precise-5.4.3.iso"
PUPPYW_FILE="wary-5.3.iso"
PUPPYS_FILE="slacko-5.4-firefox-4g.iso"
PUPPYP_URL="$PUPPY_BASEURL$PUPPYP_VERSIONURL/$PUPPYP_FILE"
PUPPYW_URL="$PUPPY_BASEURL$PUPPYW_VERSIONURL/$PUPPYW_FILE"
PUPPYS_URL="$PUPPY_BASEURL$PUPPYS_VERSIONURL/$PUPPYS_FILE"
PUPPYP_ISO=`basename $PUPPYP_URL`
PUPPYW_ISO=`basename $PUPPYW_URL`
PUPPYS_ISO=`basename $PUPPYS_URL`
#TinyCore
TINYCORES_TITLE="$TINYCORE_VERSION"
TINYCORES_FILE="TinyCore-8.2.1.iso"
TINYCORES_URL="$TINYCORE_BASEURL$TINYCORE_VERSIONURL$TINYCORES_FILE"
TINYCORES_ISO=`basename $TINYCORES_URL`
TINYCOREP_TITLE="$TINYCORE_VERSION Plus"
TINYCOREP_FILE="CorePlus-8.2.1.iso"
TINYCOREP_URL="$TINYCORE_BASEURL$TINYCORE_VERSIONURL$TINYCOREP_FILE"
TINYCOREP_ISO=`basename $TINYCOREP_URL`
#Mint
MINTC_TITLE="$MINT_VERSION Cinnamon"
MINTM_TITLE="$MINT_VERSION Mate"
MINTK_TITLE="$MINT_VERSION KDE"
MINTX_TITLE="$MINT_VERSION XFCE"
MINTC32_TITLE="$MINT_VERSION Cinnamon i386"
MINTC64_TITLE="$MINT_VERSION Cinnamon AMD64"
MINTM32_TITLE="$MINT_VERSION Mate i386"
MINTM64_TITLE="$MINT_VERSION Mate AMD64"
MINTK32_TITLE="$MINT_VERSION KDE i386"
MINTK64_TITLE="$MINT_VERSION KDE AMD64"
MINTX32_TITLE="$MINT_VERSION XFCE i386"
MINTX64_TITLE="$MINT_VERSION XFCE AMD64"
MINTC32_FILE="cinnamon-32bit.iso"
MINTC64_FILE="cinnamon-64bit.iso"
MINTM32_FILE="mate-32bit.iso"
MINTM64_FILE="mate-64bit.iso"
MINTK32_FILE="kde-32bit.iso"
MINTK64_FILE="kde-64bit.iso"
MINTX32_FILE="xfce-32bit.iso"
MINTX64_FILE="xfce-64bit.iso"
MINTC32_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTC32_FILE"
MINTC64_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTC64_FILE"
MINTM32_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTM32_FILE"
MINTM64_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTM64_FILE"
MINTK32_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTK32_FILE"
MINTK64_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTK64_FILE"
MINTX32_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTX32_FILE"
MINTX64_URL="$MINT_BASEURL$MINT_VERSIONURL$MINTX64_FILE"
MINTC32_ISO=`basename $MINTC32_URL`
MINTC64_ISO=`basename $MINTC64_URL`
MINTM32_ISO=`basename $MINTM32_URL`
MINTM64_ISO=`basename $MINTM64_URL`
MINTK32_ISO=`basename $MINTK32_URL`
MINTK64_ISO=`basename $MINTK64_URL`
MINTX32_ISO=`basename $MINTX32_URL`
MINTX64_ISO=`basename $MINTX64_URL`
#Zenwalk
ZENWALKF_TITLE="$ZENWALK_VERSION"
ZENWALKC_TITLE="$ZENWALK_VERSION Core"
ZENWALKF_FILE="zenwalk-8.0.iso"
ZENWALKC_FILE="zenwalk_core-8.0.iso"
ZENWALKF_URL="$ZENWALK_BASEURL/$ZENWALK_VERSIONURL/$ZENWALKF_FILE"
ZENWALKC_URL="$ZENWALK_BASEURL/$ZENWALK_VERSIONURL/$ZENWALKC_FILE"
ZENWALKF_ISO=`basename $ZENWALKF_URL`
ZENWALKC_ISO=`basename $ZENWALKC_URL`
#XBMC
XBMC_TITLE="$XBMC_VERSION"
XBMC_FILE="xbmc-10.1-live.iso"
XBMC_URL="$XBMC_BASEURL/$XBMC_FILE"
XBMC_ISO=`basename $XBMC_URL`
#PLOP
PLOPB_TITLE="$PLOP_VERSION Base"
PLOPF_TITLE="$PLOP_VERSION Full"
PLOP32B_TITLE="$PLOP_VERSION i386 Small"
PLOP64B_TITLE="$PLOP_VERSION x64 Small NOT AVAILABLE"
PLOP32F_TITLE="$PLOP_VERSION i386 Full"
PLOP64F_TITLE="$PLOP_VERSION x64 Full"
PLOP32B_FILE="ploplinux-$PLOP_VERSIONURL-S-i486.iso"
PLOP64B_FILE="ploplinux-$PLOP_VERSIONURL-Sx86_64.iso"
PLOP32F_FILE="ploplinux-$PLOP_VERSIONURL-i486.iso"
PLOP64F_FILE="ploplinux-$PLOP_VERSIONURL-x86_64.iso"
PLOP32B_URL="$PLOP_BASEURL$PLOP_VERSIONURL/live/small/$PLOP32B_FILE"
PLOP64B_URL="$PLOP_BASEURL$PLOP_VERSIONURL/live/small/$PLOP64B_FILE"
PLOP32F_URL="$PLOP_BASEURL$PLOP_VERSIONURL/live/$PLOP32F_FILE"
PLOP64F_URL="$PLOP_BASEURL$PLOP_VERSIONURL/live/$PLOP64F_FILE"
PLOP32B_ISO=`basename $PLOP32B_URL`
PLOP64B_ISO=`basename $PLOP64B_URL`
PLOP32F_ISO=`basename $PLOP32F_URL`
PLOP64F_ISO=`basename $PLOP64F_URL`
#Parted Magic
PMAGIC_TITLE="$PMAGIC_VERSION"
PMAGIC686_TITLE="$PMAGIC_VERSION i686"
PMAGIC686_FILE="pmagic_2013_05_01.iso"
PMAGIC686_URL="$PMAGIC_BASEURL$PMAGIC_VERSIONURL$PMAGIC686_FILE"
PMAGIC686_ISO=`basename $PMAGIC686_URL`
#Memtest
MEMTEST_TITLE="$MEMTEST_VERSION"
MEMTEST_FILE="memtest86+-5.01.bin"
MEMTEST_URL="$MEMTEST_BASEURL$MEMTEST_VERSIONURL/$MEMTEST_FILE"
MEMTEST_ISO=`basename $MEMTEST_URL`
#Clonezilla
CZILLA_TITLE="$CZILLA_VERSION"
CZILLAX64_TITLE="$CZILLA_VERSION x64"
CZILLA486_TITLE="$CZILLA_VERSION i486"
CZILLAX64_FILE="clonezilla-live-2.5.2-31-amd64.iso"
CZILLA486_FILE="clonezilla-live-2.5.2-31-i686.iso"
CZILLAX64_URL="$CZILLA_BASEURL$CZILLA_VERSIONURL$CZILLAX64_FILE"
CZILLA486_URL="$CZILLA_BASEURL$CZILLA_VERSIONURL$CZILLA486_FILE"
CZILLAX64_ISO=`basename $CZILLAX64_URL`
CZILLA486_ISO=`basename $CZILLA486_URL`
#Phoronix
PHORONIX_TITLE="$PHORONIX_VERSION"
PHORONIX_FILE="pts-desktop-live-2010.1-amd64.iso"
PHORONIX_URL="$PHORONIX_BASEURL/$PHORONIX_FILE"
PHORONIX_ISO=`basename $PHORONIX_URL`
#UBCD
UBCD_TITLE="$UBCD_VERSION"
UBCD_FILE="ubcd537.iso"
UBCD_URL="$UBCD_BASEURL/$UBCD_FILE"
UBCD_ISO=`basename $UBCD_URL`
#Knoppix
KNOPPIX_TITLE="$KNOPPIX_VERSION"
KNOPPIXC_TITLE="$KNOPPIX_VERSION CD"
KNOPPIXD_TITLE="$KNOPPIX_VERSION DVD"
KNOPPIXC_FILE="KNOPPIX_V7.2.0CD-2013-06-16-DE.iso"
KNOPPIXD_FILE="KNOPPIX_V8.1-2017-09-05-EN.iso"
KNOPPIXC_URL="$KNOPPIX_BASEURL/knoppix/$KNOPPIXC_FILE"
KNOPPIXD_URL="$KNOPPIX_BASEURL/knoppix-dvd/$KNOPPIXD_FILE"
KNOPPIXC_ISO=`basename $KNOPPIXC_URL`
KNOPPIXD_ISO=`basename $KNOPPIXD_URL`
#Antix
ANTIX_TITLE="$ANTIX_VERSION"
ANTIXN_TITLE="$ANTIX_VERSION Net"
ANTIXC_TITLE="$ANTIX_VERSION Core"
ANTIXB_TITLE="$ANTIX_VERSION Base"
ANTIXF_TITLE="$ANTIX_VERSION Full"
ANTIXN32_TITLE="$ANTIX_VERSION i386 Net"
ANTIXC32_TITLE="$ANTIX_VERSION i386 Core"
ANTIXB32_TITLE="$ANTIX_VERSION i386 Base"
ANTIXF32_TITLE="$ANTIX_VERSION i386 Full"
ANTIXN64_TITLE="$ANTIX_VERSION x64 Net"
ANTIXC64_TITLE="$ANTIX_VERSION x64 Core"
ANTIXB64_TITLE="$ANTIX_VERSION x64 Base"
ANTIXF64_TITLE="$ANTIX_VERSION x64 Full"
ANTIXN32_FILE="${ANTIX_VERSION}_386-net.iso"
ANTIXC32_FILE="${ANTIX_VERSION}_386-core.iso"
ANTIXB32_FILE="${ANTIX_VERSION}_386-base.iso"
ANTIXF32_FILE="${ANTIX_VERSION}_386-full.iso"
ANTIXN64_FILE="${ANTIX_VERSION}_x64-net.iso"
ANTIXC64_FILE="${ANTIX_VERSION}_x64-core.iso"
ANTIXB64_FILE="${ANTIX_VERSION}_x64-base.iso"
ANTIXF64_FILE="${ANTIX_VERSION}_x64-full.iso"
ANTIXN32_URL="$ANTIX_BASEURL/$ANTIXN32_FILE"
ANTIXC32_URL="$ANTIX_BASEURL/$ANTIXC32_FILE" 
ANTIXB32_URL="$ANTIX_BASEURL/$ANTIXB32_FILE" 
ANTIXF32_URL="$ANTIX_BASEURL/$ANTIXF32_FILE" 
ANTIXN64_URL="$ANTIX_BASEURL/$ANTIXN64_FILE"
ANTIXC64_URL="$ANTIX_BASEURL/$ANTIXC64_FILE" 
ANTIXB64_URL="$ANTIX_BASEURL/$ANTIXB64_FILE" 
ANTIXF64_URL="$ANTIX_BASEURL/$ANTIXF64_FILE" 
ANTIXN32_ISO=`basename $ANTIXN32_URL`
ANTIXC32_ISO=`basename $ANTIXC32_URL`
ANTIXB32_ISO=`basename $ANTIXB32_URL`
ANTIXF32_ISO=`basename $ANTIXF32_URL`
ANTIXN64_ISO=`basename $ANTIXN64_URL`
ANTIXC64_ISO=`basename $ANTIXC64_URL`
ANTIXB64_ISO=`basename $ANTIXB64_URL`
ANTIXF64_ISO=`basename $ANTIXF64_URL`
#Sysrcd
SYSRCD_TITLE="$SYSRCD_VERSION"
SYSRCD_FILE="systemrescuecd-x86-5.1.2.iso"
SYSRCD_URL="$SYSRCD_BASEURL$SYSRCD_VERSIONURL/$SYSRCD_FILE"
SYSRCD_ISO=`basename $SYSRCD_URL`
#GParted
GPARTED_TITLE="$GPARTED_NAME $GPARTED_VERSION"
GPARTED32_TITLE="$GPARTED_NAME $GPARTED_VERSION i686"
GPARTED64_TITLE="$GPARTED_NAME $GPARTED_VERSION x64"
GPARTED32_FILE="gparted-live-$GPARTED_VERSION-i686.iso"
GPARTED64_FILE="gparted-live-$GPARTED_VERSION-amd64.iso"
GPARTED32_URL="$GPARTED_BASEURL$GPARTED_VERSION/$GPARTED32_FILE"
GPARTED64_URL="$GPARTED_BASEURL$GPARTED_VERSION/$GPARTED64_FILE"
GPARTED32_ISO=`basename $GPARTED32_URL`
GPARTED64_ISO=`basename $GPARTED64_URL`
#HDT
HDT_TITLE="$HDT_VERSION"
HDT_FILE="CORE3_Hardware_Detection_Tool.iso"
HDT_URL="$HDT_BASEURL/$HDT_FILE"
HDT_ISO=`basename $HDT_URL`
#Win7
W7_TITLE="Windows 7"
CATTEST=$(sudo cat $(mount | grep "USBmulti " | cut -c1-8)2 | head)

########Downloading components ################################################
SKIPPED_MSG="\t[X]"
NEW_MSG="[X] -> in DL-Liste aufgenommen"
echo -e "\n#################### Downloads ####################\n"
echo -e "Neu\tVorhanden\n"
# GFX
if (( $DL_GFX + $DOWNLOADALL > 0 )); then
echo -e "\t\t\tGFX-Download aktiviert:"
  if [ ! -f $MOUNTDIR/$GRUBPATH/pmt.tga ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/pmt.tga -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/pmt.tga --si --time; fi
  if [ ! -f $MOUNTDIR/$GRUBPATH/jolie.tga ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/jolie.tga -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/jolie.tga --si --time; fi
  if [ ! -f $MOUNTDIR/$GRUBPATH/pitt.tga ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/pitt.tga -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/pitt.tga --si --time; fi
  if [ ! -f $MOUNTDIR/$GRUBPATH/monroe.tga ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/monroe.tga -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/monroe.tga --si --time; fi
  if [ ! -f $MOUNTDIR/$GRUBPATH/monroe2.tga ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/monroe2.tga -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/monroe2.tga --si --time; fi
  if [ ! -f $MOUNTDIR/$GRUBPATH/unicode.pf2 ] ; then sudo wget -c http://blog.p-mt.net/wp-content/uploads/2009/12/unicode.pf2 -P $MOUNTDIR/$GRUBPATH
 else echo -e -n "$SKIPPED_MSG\t"; du $MOUNTDIR/$GRUBPATH/unicode.pf2 --si --time; fi
fi
# Ubuntu Desktop
if (( $DL_UBUNTU32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu 32bit Desktop-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$UBUNTU32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU32_FILE  --si --time; fi; fi
if (( $DL_UBUNTU64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu 64bit Desktop-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$UBUNTU64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU64_FILE  --si --time; fi; fi
# Ubuntu LTS Desktop + Alternate
if (( $DL_UBUNTULTS32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu LTS 32bit Desktop-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$UBUNTULTS32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS32_FILE  --si --time; fi; fi
if (( $DL_UBUNTULTS64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu LTS 64bit Desktop-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	 $UBUNTULTS64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS64_FILE  --si --time; fi; fi
if (( $DL_UBUNTULTS32A + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu LTS 32bit Alternate-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS32A_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	 $UBUNTULTS32A_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS32A_FILE  --si --time; fi; fi
if (( $DL_UBUNTULTS64A + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUbuntu LTS 64bit Alternate-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS64A_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$UBUNTULTS64A_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS64A_FILE  --si --time; fi; fi
# Debian CD 1 + NetInstall
if (( $DL_DEBIAN32C + $DOWNLOADALL > 0 )); then echo -e "\t\t\tDebian 32bit CD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32C_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$DEBIAN32C_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32C_FILE  --si --time; fi; fi
if (( $DL_DEBIAN64C + $DOWNLOADALL > 0 )); then echo -e "\t\t\tDebian 64bit CD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64C_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$DEBIAN64C_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64C_FILE  --si --time; fi; fi
if (( $DL_DEBIAN32N + $DOWNLOADALL > 0 )); then echo -e "\t\t\tDebian 32bit NetInstall-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32N_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$DEBIAN32N_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32N_FILE  --si --time; fi; fi
if (( $DL_DEBIAN64N + $DOWNLOADALL > 0 )); then echo -e "\t\t\tDebian 64bit NetInstall-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64N_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$DEBIAN64N_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64N_FILE  --si --time; fi; fi

# Siduction
if (( $DL_SIDUCTIONCI + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction Cinnamon-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONCI_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONCI_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONCI_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONGN + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction GNOME-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONGN_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONGN_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONGN_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONKD + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction KDE-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONKD_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONKD_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONKD_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONLXD + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction LXDE-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONLXD_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONLXD_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONLXD_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONLQT + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction LXQT-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONLQT_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONLQT_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONLQT_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONMA + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction MATE-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONMA_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONMA_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONMA_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONNO + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction NOX-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONNO_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONNO_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONNO_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONXF + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction XFCE-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONXF_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONXF_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONXF_FILE  --si --time; fi; fi
if (( $DL_SIDUCTIONXO + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSiduction Xorg-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SIDUCTIONXO_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SIDUCTIONXO_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SIDUCTIONXO_FILE  --si --time; fi; fi

#grml
if (( $DL_GRML32 > 0 )); then echo -e "\t\t\tgrml 32bit-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$GRML32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$GRML32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$GRML32_FILE  --si --time; fi; fi
if (( $DL_GRML64 > 0 )); then echo -e "\t\t\tgrml 64bit-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$GRML64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$GRML64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$GRML64_FILE  --si --time; fi; fi
if (( $DL_GRML96 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tgrml96-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$GRML96_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$GRML96_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$GRML96_FILE  --si --time; fi; fi

# Slax
if (( $DL_SLAX + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSlax-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SLAX_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SLAX_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SLAX_FILE  --si --time; fi; fi

# Puppy Linux
if (( $DL_PUPPYP + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPuppy Precise-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PUPPYP_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PUPPYP_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PUPPYP_FILE  --si --time; fi; fi
if (( $DL_PUPPYW + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPuppy Wary aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PUPPYW_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PUPPYW_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PUPPYW_FILE  --si --time; fi; fi
if (( $DL_PUPPYS + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPuppy Slacko-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PUPPYS_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PUPPYS_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PUPPYS_FILE  --si --time; fi; fi

# TINYCORES
if (( $DL_TINYCORES + $DOWNLOADALL > 0 )); then echo -e "\t\t\tTiny Core Linux Standard-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$TINYCORES_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$TINYCORES_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$TINYCORES_FILE  --si --time; fi; fi
if (( $DL_TINYCOREP + $DOWNLOADALL > 0 )); then echo -e "\t\t\tTiny Core Linux Plus-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$TINYCOREP_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$TINYCOREP_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$TINYCOREP_FILE  --si --time; fi; fi

# Mint
if (( $DL_MINTC32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint GNOME 32bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTC32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTC32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTC32_FILE  --si --time; fi; fi
if (( $DL_MINTC64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint GNOME 64bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTC64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTC64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTC64_FILE  --si --time; fi; fi
if (( $DL_MINTM32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint GNOME 32bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTM32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTM32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTM32_FILE  --si --time; fi; fi
if (( $DL_MINTM64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint GNOME 64bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTM64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTM64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTM64_FILE  --si --time; fi; fi
if (( $DL_MINTK32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint KDE 32bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTK32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTK32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTK32_FILE  --si --time; fi; fi
if (( $DL_MINTK64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint KDE 64bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTK64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTK64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTK64_FILE  --si --time; fi; fi
if (( $DL_MINTX32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint XFCE 32bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTX32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTX32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTX32_FILE  --si --time; fi; fi
if (( $DL_MINTX64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tLinux Mint XFCE 64bit Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MINT_VFILEURL$MINTX64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MINTX64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MINT_VFILEURL$MINTX64_FILE  --si --time; fi; fi


# Zenwalk
if (( $DL_ZENWALKF + $DOWNLOADALL > 0 )); then echo -e "\t\t\tZenwalk-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ZENWALKF_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ZENWALKF_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ZENWALKF_FILE  --si --time; fi; fi
if (( $DL_ZENWALKC + $DOWNLOADALL > 0 )); then echo -e "\t\t\tZenwalk Core-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ZENWALKC_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ZENWALKC_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ZENWALKC_FILE  --si --time; fi; fi

# XBMC
if (( $DL_XBMC + $DOWNLOADALL > 0 )); then echo -e "\t\t\tXBMC-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$XBMC_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$XBMC_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$XBMC_FILE  --si --time; fi; fi

# PLOP
if (( $DL_PLOP32B + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPLOP i386 Base-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PLOP32B_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PLOP32B_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PLOP32B_FILE  --si --time; fi; fi
if (( $DL_PLOP64B + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPLOP x64 Base-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PLOP64B_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PLOP64B_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PLOP64B_FILE  --si --time; fi; fi
if (( $DL_PLOP32F + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPLOP i386 Full-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PLOP32F_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PLOP32F_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PLOP32F_FILE  --si --time; fi; fi
if (( $DL_PLOP64F + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPLOP x64 Full-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PLOP64F_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PLOP64F_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PLOP64F_FILE  --si --time; fi; fi

# Parted Magic
if (( $DL_PMAGIC686 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tParted Magic i686-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PMAGIC686_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PMAGIC686_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PMAGIC686_FILE  --si --time; fi; fi

# Memtest
if (( $DL_MEMTEST + $DOWNLOADALL > 0 )); then echo -e "\t\t\tMemtest-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$MEMTEST_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$MEMTEST_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$MEMTEST_FILE  --si --time; fi; fi

#Clonezilla
if (( $DL_CZILLA486 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tClonezilla i486-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$CZILLA486_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$CZILLA486_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$CZILLA486_FILE  --si --time; fi; fi
if (( $DL_CZILLAX64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tClonezilla x64-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$CZILLAX64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$CZILLAX64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$CZILLAX64_FILE  --si --time; fi; fi

# Phoronix
if (( $DL_PHORONIX + $DOWNLOADALL > 0 )); then echo -e "\t\t\tPhoronix-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$PHORONIX_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$PHORONIX_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$PHORONIX_FILE  --si --time; fi; fi

# UBCD
if (( $DL_UBCD + $DOWNLOADALL > 0 )); then echo -e "\t\t\tUBCD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$UBCD_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$UBCD_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$UBCD_FILE  --si --time; fi; fi

# Knoppix
if (( $DL_KNOPPIXC + $DOWNLOADALL > 0 )); then echo -e "\t\t\tKnoppix CD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$KNOPPIXC_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$KNOPPIXC_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$KNOPPIXC_FILE  --si --time; fi; fi
if (( $DL_KNOPPIXD + $DOWNLOADALL > 0 )); then echo -e "\t\t\tKnoppix DVD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$KNOPPIXD_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$KNOPPIXD_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$KNOPPIXD_FILE  --si --time; fi; fi

# antiX
if (( $DL_ANTIXN32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX 386 Net-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXN32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXN32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXN32_FILE  --si --time; fi; fi
if (( $DL_ANTIXC32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX 386 Core-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXC32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXC32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXC32_FILE  --si --time; fi; fi
if (( $DL_ANTIXB32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX 386 Base-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXB32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXB32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXB32_FILE  --si --time; fi; fi
if (( $DL_ANTIXF32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX 386 Full-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXF32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXF32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXF32_FILE  --si --time; fi; fi
if (( $DL_ANTIXN64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX x64 Net-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXN64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXN64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXN64_FILE  --si --time; fi; fi
if (( $DL_ANTIXC64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX x64 Core-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXC64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXC64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXC64_FILE  --si --time; fi; fi
if (( $DL_ANTIXB64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX x64 Base-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXB64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXB64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXB64_FILE  --si --time; fi; fi
if (( $DL_ANTIXF64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tantiX x64 Full-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$ANTIXF64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$ANTIXF64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$ANTIXF64_FILE  --si --time; fi; fi

  
# Sysrcd
if (( $DL_SYSRCD + $DOWNLOADALL > 0 )); then echo -e "\t\t\tSystem Rescue CD-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$SYSRCD_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$SYSRCD_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$SYSRCD_FILE  --si --time; fi; fi

  
  # GParted
if (( $DL_GPARTED32 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tGParted i686-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$GPARTED32_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$GPARTED32_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$GPARTED32_FILE  --si --time; fi; fi
if (( $DL_GPARTED64 + $DOWNLOADALL > 0 )); then echo -e "\t\t\tGParted x64-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$GPARTED64_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$GPARTED64_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$GPARTED64_FILE  --si --time; fi; fi


if (( $DL_HDT + $DOWNLOADALL > 0 )); then echo -e "\t\t\tHardware Detection Tool-Download aktiviert:"
  if [ ! -f $DOWNLOADPATH/$HDT_FILE ] ; then echo "$NEW_MSG"; DL_LIST="$DL_LIST	$HDT_URL"
  else echo -e -n "$SKIPPED_MSG \t"; du $DOWNLOADPATH/$HDT_FILE  --si --time; fi; fi

  
  
echo $DL_LIST
echo "Starte bis zu $PARALLEL_DOWNLOADS parallele Downloads:"
echo $DL_LIST | xargs -n 1 -P $PARALLEL_DOWNLOADS wget -c --limit-rate=$DL_SPEED -t 3 -P $DOWNLOADPATH
#--progress=dot:mega
#OLDPWD=$PWD
#cd $DOWNLOADPATH
#echo $DL_LIST | xargs -n 1 -P $PARALLEL_DOWNLOADS curl -O --progress-bar
#cd $OLDPWD
###########curl has problems with dynamic urls from sourceforge

#########Configuring GRUB2 ####################################################
#naming various stuff
CREATED_MSG="[X]"
NOTCREATED_MSG=" ~ "
ROWMESSAGE="\t<Distribution>\t\t\t\t\t\tx86\tx64\tgeneric"

UBUNTUSPACER="\t\t\t\t"
UBUNTULTSSPACER="\t\t\t"
DEBIANSSPACER="\t\t\t\t"
DEBIANNSPACER="\t\t\t"
SIDUCTIONCISPACER="\t\t\t\t\t"
SIDUCTIONGNSPACER="\t\t\t\t\t"
SIDUCTIONKDSPACER="\t\t\t\t\t\t"
SIDUCTIONLXDSPACER="\t\t\t\t\t\t"
SIDUCTIONLQTSPACER="\t\t\t\t\t\t"
SIDUCTIONMASPACER="\t\t\t\t\t\t"
SIDUCTIONNOSPACER="\t\t\t\t\t\t"
SIDUCTIONXFSPACER="\t\t\t\t\t\t"
SIDUCTIONXOSPACER="\t\t\t\t\t"
GRMLSPACER="\t\t\t\t\t\t"
SLAXSPACER="\t\t\t\t\t\t\t\t"
PUPPYPSPACER="\t\t\t\t\t\t"
PUPPYWSPACER="\t\t\t\t\t\t\t"
PUPPYSSPACER="\t\t\t\t\t\t\t"
TINYCORESSPACER="\t\t\t\t\t\t\t"
TINYCOREPSPACER="\t\t\t\t\t\t"
MINTCSPACER="\t\t\t"
MINTMSPACER="\t\t\t\t"
MINTKSPACER="\t\t\t\t"
MINTXSPACER="\t\t\t\t"
ZENWALKFSPACER="\t\t\t\t\t\t"
ZENWALKCSPACER="\t\t\t\t\t\t"
XBMCSPACER="\t\t\t\t\t\t\t"
PLOPBSPACER="\t\t\t\t\t"
PLOPFSPACER="\t\t\t\t\t"
PMAGICSPACER="\t\t\t\t\t\t"
MEMTESTSPACER="\t\t\t\t\t\t\t"
CZILLASPACER="\t\t\t\t"
UBCDSPACER="\t\t\t\t\t\t\t"
PHORONIXSPACER="\t\t\t\t\t\t\t"
KNOPPIXCSPACER="\t\t\t\t\t\t\t"
KNOPPIXDSPACER="\t\t\t\t\t\t\t"
ANTIXN32SPACER="\t\t\t\t\t\t"
ANTIXC32SPACER="\t\t\t\t\t\t"
ANTIXB32SPACER="\t\t\t\t\t\t"
ANTIXF32SPACER="\t\t\t\t\t\t"
ANTIXN64SPACER=""
ANTIXC64SPACER=""
ANTIXB64SPACER=""
ANTIXF64SPACER=""
SYSRCDSPACER="\t\t\t\t\t"
GPARTED32SPACER="\t\t\t\t\t"
GPARTED64SPACER=""
HDTSPACER="\t\t\t\t\t"
W7SPACER="\t\t\t\t\t\t\t\t"

echo -e "\n#################### GRUB2-Konfiguration schreiben ####################\n\n$ROWMESSAGE\n"
# check if there is a old version, if so, rename it
[ -f $MOUNTDIR/$GRUBPATH/grub.cfg ] && mv $MOUNTDIR/$GRUBPATH/grub.cfg $MOUNTDIR/$GRUBPATH/grub.cfg-`date  +"%Y-%m-%d-%H-%M-%S"`
cat <<EOF> $MOUNTDIR/$GRUBPATH/grub.cfg
# Settings if background file is present
if loadfont /boot/grub/unicode.pf2 ; then
  set gfxmode="640x480"
  insmod gfxterm
  insmod vbe
  terminal_output gfxterm
  if terminal_output gfxterm; then true ; else
     terminal gfxterm
  fi
fi
insmod tga
background_image $SPLASH_IMAGE
EOF

# create menu entries if the corresponding iso files are present
# echo -n seems not supported everywhere, maybe replace it by something else?

echo -n -e "\t$UBUNTU_TITLE:$UBUNTUSPACER"
if [ -f $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$UBUNTU32_TITLE (works)" {
 loopback loop $ISOPATH/$UBUNTU32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$UBUNTU32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$UBUNTU_VERSIONURL-$UBUNTU64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$UBUNTU64_TITLE (works)" {
 loopback loop $ISOPATH/$UBUNTU64_ISO
 linux (loop)/casper/vmlinuz.efi boot=casper iso-scan/filename=$ISOPATH/$UBUNTU64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$UBUNTULTSD_TITLE:$UBUNTULTSSPACER"
if [ -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$UBUNTULTS32_TITLE (works)" {
 loopback loop $ISOPATH/$UBUNTULTS32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$UBUNTULTS32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$UBUNTULTS_VERSIONURL-$UBUNTULTS64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$UBUNTULTS64_TITLE (works)" {
 loopback loop $ISOPATH/$UBUNTULTS64_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$UBUNTULTS64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG$UBUNTULTSDSPACER"
fi

echo -n -e "\t$DEBIANS_TITLE:"
if [ -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32C_FILE ] ; then echo -e -n "$DEBIANSSPACER$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$DEBIAN32C_TITLE" {
  loopback loop $ISOPATH/$DEBIAN32C_ISO
  linux (loop)/install.386/vmlinuz boot=/debian iso-scan/filename=$ISOPATH/$DEBIAN32C_ISO noeject noprompt vga=normal --
  initrd (loop)/install.386/initrd.gz
}
EOF
else echo -e -n "$DEBIANSSPACER$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64C_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$DEBIAN64C_TITLE" {
  loopback loop $ISOPATH/$DEBIAN64C_ISO
  linux (loop)/install.amd/vmlinuz boot=/debian iso-scan/filename=$ISOPATH/$DEBIAN32C_ISO noeject noprompt vga=normal --
  initrd (loop)/install.amd/initrd.gz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi
echo -n -e "\t$DEBIANN_TITLE:"
if [ -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN32N_FILE ] ; then echo -e -n "$DEBIANNSPACER$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$DEBIAN32N_TITLE" {
  loopback loop $ISOPATH/$DEBIAN32N_ISO
  linux (loop)/install.386/vmlinuz
  initrd (loop)/install.386/initrd.gz
}
EOF
else echo -e -n "$DEBIANNSPACER$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$DEBIAN_VERSIONURL-$DEBIAN64N_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$DEBIAN64N_TITLE" {
  loopback loop $ISOPATH/$DEBIAN64N_ISO
  linux (loop)/install.amd/vmlinuz
  initrd (loop)/install.amd/initrd.gz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONCI_TITLE:$SIDUCTIONCISPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONCI_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONCI_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONCI_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONCI_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONGN_TITLE:$SIDUCTIONGNSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONGN_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONGN_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONGN_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONGN_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONKD_TITLE:$SIDUCTIONKDSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONKD_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONKD_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONKD_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONKD_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONLXD_TITLE:$SIDUCTIONLXDSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONLXD_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONLXD_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONLXD_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONLXD_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONLQT_TITLE:$SIDUCTIONLQTSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONLQT_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONLQT_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONLQT_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONLQT_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONMA_TITLE:$SIDUCTIONMASPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONMA_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONMA_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONMA_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONMA_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONNO_TITLE:$SIDUCTIONNOSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONNO_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONNO_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONNO_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONNO_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONXF_TITLE:$SIDUCTIONXFSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONXF_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONXF_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONXF_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONXF_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$SIDUCTIONXO_TITLE:$SIDUCTIONXOSPACER"
if [ -f $DOWNLOADPATH/$SIDUCTIONXO_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SIDUCTIONXO_TITLE" {
  loopback loop $ISOPATH/$SIDUCTIONXO_ISO
  linux (loop)/boot/vmlinuz0.686 fromiso=$ISOPATH/$SIDUCTIONXO_ISO boot=fll noeject
  initrd (loop)/boot/initrd0.686
}
EOF
else echo -e "$NOTCREATED_MSG"
fi


echo -n -e "\t$GRML_TITLE$GRMLSPACER"
if [ -f $DOWNLOADPATH/$GRML96_FILE ] ; then echo -e "$CREATED_MSG\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$GRML32_TITLE (96) (works)" {
    loopback loop $ISOPATH/$GRML96_ISO
    linux (loop)/boot/grml32full/vmlinuz findiso=$ISOPATH/$GRML96_ISO boot=live toram=grml32-full.squashfs live-media-path=/live/grml32-full/ lang=de keyboard=de  noquick ignore_bootid
    initrd (loop)/boot/grml32full/initrd.img
}
menuentry "$GRML64_TITLE (96) (works)" {
    loopback loop $ISOPATH/$GRML96_ISO
    linux (loop)/boot/grml64full/vmlinuz findiso=$ISOPATH/$GRML96_ISO boot=live toram=grml64-full.squashfs live-media-path=/live/grml64-full/ lang=de keyboard=de  noquick ignore_bootid
    initrd (loop)/boot/grml64full/initrd.img
}
EOF
fi

if [ -f $DOWNLOADPATH/$GRML32_FILE ] && ! [ -f $DOWNLOADPATH/$GRML96_FILE ]; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$GRML32_TITLE (works)" {
    loopback loop $ISOPATH/$GRML32_ISO
    linux (loop)/boot/grml32full/vmlinuz findiso=$ISOPATH/$GRML32_ISO boot=live toram=grml32-full.squashfs live-media-path=/live/grml32-full/ lang=de keyboard=de  noquick ignore_bootid
    initrd (loop)/boot/grml32full/initrd.img 
}
EOF
elif ! [ -f $DOWNLOADPATH/$GRML96_FILE ]; then echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$GRML64_FILE ] && ! [ -f $DOWNLOADPATH/$GRML96_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$GRML64_TITLE (works)" {
    loopback loop $ISOPATH/$GRML64_ISO
    linux (loop)/boot/grml64full/vmlinuz findiso=$ISOPATH/$GRML64_ISO boot=live toram=grml64-full.squashfs live-media-path=/live/grml64-full/ lang=de keyboard=de  noquick ignore_bootid
    initrd (loop)/boot/grml64full/initrd.img
}
EOF
elif ! [ -f $DOWNLOADPATH/$GRML96_FILE ]; then echo -e "\t$NOTCREATED_MSG"
fi




echo -n -e "\t$SLAX_TITLE:$SLAXSPACER"
if [ -f $DOWNLOADPATH/$SLAX_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SLAX_TITLE (works)" {
  loopback loop $ISOPATH/$SLAX_ISO
  linux (loop)/boot/vmlinuz from=$ISOPATH/$SLAX_ISO ramdisk_size=7000 root=/dev/ram0 rw
  initrd (loop)/boot/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$PUPPYP_TITLE:$PUPPYPSPACER"
if [ -f $DOWNLOADPATH/$PUPPYP_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PUPPYP_TITLE" {
  loopback loop $ISOPATH/$PUPPYP_ISO
  linux (loop)/vmlinuz from=$ISOPATH/$PUPPYP_ISO root=/dev/ram0 PMEDIA=idecd
  initrd (loop)/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$PUPPYW_TITLE:$PUPPYWSPACER"
if [ -f $DOWNLOADPATH/$PUPPYW_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PUPPYW_TITLE" {
  loopback loop $ISOPATH/$PUPPYW_ISO
  linux (loop)/vmlinuz from=$ISOPATH/$PUPPYW_ISO root=/dev/ram0 PMEDIA=idecd
  initrd (loop)/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$PUPPYS_TITLE:$PUPPYSSPACER"
if [ -f $DOWNLOADPATH/$PUPPYS_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PUPPYS_TITLE" {
  loopback loop $ISOPATH/$PUPPYS_ISO
  linux (loop)/vmlinuz from=$ISOPATH/$PUPPYS_ISO root=/dev/ram0 PMEDIA=idecd
  initrd (loop)/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$TINYCORES_TITLE:$TINYCORESSPACER"
if [ -f $DOWNLOADPATH/$TINYCORES_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$TINYCORES_TITLE (works)" {
  loopback loop $ISOPATH/$TINYCORES_ISO
  linux (loop)/boot/vmlinuz
  initrd (loop)/boot/core.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$TINYCOREP_TITLE:$TINYCOREPSPACER"
if [ -f $DOWNLOADPATH/$TINYCOREP_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$TINYCOREP_TITLE (works)" {
  loopback loop $ISOPATH/$TINYCOREP_ISO
  linux (loop)/boot/vmlinuz
  initrd (loop)/boot/core.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$MINTC_TITLE:$MINTCSPACER"
if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTC32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTC32_TITLE (works)" {
  loopback loop $ISOPATH/$MINTC32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTC32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTC64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTC64_TITLE (works)" {
  loopback loop $ISOPATH/$MINTC64_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTC64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$MINTM_TITLE:$MINTMSPACER"
if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTM32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTM32_TITLE (works)" {
  loopback loop $ISOPATH/$MINTM32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTM32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTM64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTM64_TITLE" {
  loopback loop $ISOPATH/$MINTM64_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTM64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$MINTK_TITLE:$MINTKSPACER"
if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTK32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTK32_TITLE (works)" {
  loopback loop $ISOPATH/$MINTK32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTK32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTK64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTK64_TITLE (works)" {
  loopback loop $ISOPATH/$MINTK64_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTK64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$MINTX_TITLE:$MINTXSPACER"
if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTX32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTX32_TITLE (works)" {
  loopback loop $ISOPATH/$MINTX32_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTX32_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$MINT_VFILEURL$MINTX64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MINTX64_TITLE (works)" {
  loopback loop $ISOPATH/$MINTX64_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$MINTX64_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$ZENWALKF_TITLE:$ZENWALKFSPACER"
if [ -f $DOWNLOADPATH/$ZENWALKF_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ZENWALKF_TITLE" {
  loopback loop $ISOPATH/$ZENWALKF_ISO
  linux (loop)/kernel/bzImage load_ramdisk=1 prompt_ramdisk=0 rw root=/dev/null ZENWALK_KERNEL=auto nomodeset vga=791 
  initrd (loop)/kernel/bzImage initrd=initrd.img 
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ZENWALKC_TITLE:$ZENWALKCSPACER"
if [ -f $DOWNLOADPATH/$ZENWALKC_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ZENWALKC_TITLE" {
  loopback loop $ISOPATH/$ZENWALKC_ISO
  linux (loop)/kernel/bzImage load_ramdisk=1 prompt_ramdisk=0 rw root=/dev/null ZENWALK_KERNEL=auto nomodeset vga=791 
  initrd (loop)/kernel/bzImage initrd=initrd.img 
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$XBMC_TITLE:$XBMCSPACER"
if [ -f $DOWNLOADPATH/$XBMC_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$XBMC_TITLE" {
    loopback loop $ISOPATH/$XBMC_ISO
  set gfxpayload="800x600"
  linux (loop)/live/vmlinuz boot=live xbmc=autostart video=vesafb quickreboot quickusbmodules notimezone noaccessibility noapparmor noaptcdrom noautologin noxautologin noconsolekeyboard nofastboot nognomepanel nohosts nokpersonalizer nolanguageselector nolocales nonetworking nopowermanagement noprogramcrashes nojockey nosudo noupdatenotifier nouser nopolkitconf noxautoconfig noxscreensaver nopreseed toram iso-scan/filename=$XBMC_ISO
  initrd (loop)/live/initrd.img
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$PLOPB_TITLE:$PLOPBSPACER"
if [ -f $DOWNLOADPATH/$PLOP32B_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PLOP32B_TITLE (works)" {
    loopback loop $ISOPATH/$PLOP32B_ISO
    linux (loop)/syslinux/kernel/bzImage vga=1 iso_filename=$ISOPATH/$PLOP32B_ISO
    initrd (loop)/syslinux/kernel/initramfs.gz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$PLOP64B_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PLOP64B_TITLE (works)" {
    loopback loop $ISOPATH/$PLOP64B_ISO
    linux (loop)/syslinux/kernel/bzImage vga=1 iso_filename=$ISOPATH/$PLOP64B_ISO
    initrd (loop)/syslinux/kernel/initramfs.gz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$PLOPF_TITLE:$PLOPFSPACER"
if [ -f $DOWNLOADPATH/$PLOP32F_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PLOP32F_TITLE (works)" {
    loopback loop $ISOPATH/$PLOP32F_ISO
    linux (loop)/syslinux/kernel/bzImage vga=1 iso_filename=$ISOPATH/$PLOP32F_ISO
    initrd (loop)/syslinux/kernel/initramfs.gz
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$PLOP64F_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PLOP64F_TITLE (works)" {
    loopback loop $ISOPATH/$PLOP64F_ISO
    linux (loop)/syslinux/kernel/bzImage vga=1 iso_filename=$ISOPATH/$PLOP64F_ISO
    initrd (loop)/syslinux/kernel/initramfs.gz
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$PMAGIC_TITLE:$PMAGICSPACER"
if [ -f $DOWNLOADPATH/$PMAGIC686_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PMAGIC686_TITLE (works)" {
  loopback loop $ISOPATH/$PMAGIC686_ISO
  linux (loop)/pmagic/bzImage iso_filename=$ISOPATH/$PMAGIC686_ISO
  initrd (loop)/pmagic/initrd.img
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$MEMTEST_TITLE:$MEMTESTSPACER"
if [ -f $DOWNLOADPATH/$MEMTEST_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$MEMTEST_TITLE (works)" {
 linux16 $ISOPATH/$MEMTEST_FILE
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$CZILLA_TITLE:$CZILLASPACER"
if [ -f $DOWNLOADPATH/$CZILLA486_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$CZILLA486_TITLE (works)" {
  loopback loop $ISOPATH/$CZILLA486_ISO
  linux (loop)/live/vmlinuz iso_filename=$ISOPATH/$CZILLA486_ISO boot=live config noswap ip=frommedia toram=filesystem.squashfs findiso=$ISOPATH/$CZILLA486_ISO
  initrd (loop)/live/initrd.img
}
EOF
else echo -e -n "$NOTCREATED_MSG"
fi

if [ -f $DOWNLOADPATH/$CZILLAX64_FILE ] ; then echo -e "\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$CZILLAX64_TITLE (works)" {
  loopback loop $ISOPATH/$CZILLAX64_ISO
  linux (loop)/live/vmlinuz iso_filename=$ISOPATH/$CZILLAX64_ISO boot=live config noswap ip=frommedia toram=filesystem.squashfs findiso=$ISOPATH/$CZILLA486_ISO
  initrd (loop)/live/initrd.img
}
EOF
else echo -e "\t$NOTCREATED_MSG"
fi

echo -n -e "\t$UBCD_TITLE:$UBCDSPACER"
if [ -f $DOWNLOADPATH/$UBCD_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$UBCD_TITLE" {
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$PHORONIX_TITLE:$PHORONIXSPACER"
if [ -f $DOWNLOADPATH/$PHORONIX_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$PHORONIX_TITLE (works)" {
 loopback loop $ISOPATH/$PHORONIX_ISO
 linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$ISOPATH/$PHORONIX_ISO noeject noprompt --
 initrd (loop)/casper/initrd.lz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$KNOPPIXC_TITLE:$KNOPPIXCSPACER"
if [ -f $DOWNLOADPATH/$KNOPPIXC_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$KNOPPIXC_TITLE (works)" {
 loopback loop $ISOPATH/$KNOPPIXC_ISO
 linux (loop)/boot/isolinux/linux knoppix bootfrom=/dev/sda1/$ISOPATH/$KNOPPIXC_ISO ramdisk_size=100000 ramdisk_size=100000 vt.default_utf8=0 apm=power-off initrd=minirt.gz nomce libata.force=noncq hpsa.hpsa_allow_any=1 loglevel=1 tz=localtime
 initrd (loop)/boot/isolinux/minirt.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$KNOPPIXD_TITLE:$KNOPPIXDSPACER"
if [ -f $DOWNLOADPATH/$KNOPPIXD_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$KNOPPIXD_TITLE (works)" {
 loopback loop $ISOPATH/$KNOPPIXD_ISO
 linux (loop)/boot/isolinux/linux knoppix bootfrom=/dev/sda1/$ISOPATH/$KNOPPIXD_ISO ramdisk_size=100000 ramdisk_size=100000 vt.default_utf8=0 apm=power-off initrd=minirt.gz nomce libata.force=noncq hpsa.hpsa_allow_any=1 loglevel=1 tz=localtime
 initrd (loop)/boot/isolinux/minirt.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXN_TITLE:$ANTIXN32SPACER"
if [ -f $DOWNLOADPATH/$ANTIXN32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXN32_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXN32_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXN32_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXN64SPACER"
if [ -f $DOWNLOADPATH/$ANTIXN64_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXN64_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXN64_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXN64_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXC_TITLE:$ANTIXC32SPACER"
if [ -f $DOWNLOADPATH/$ANTIXC32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXC32_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXC32_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXC32_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXC64SPACER"
if [ -f $DOWNLOADPATH/$ANTIXC64_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXC64_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXC64_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXC64_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXB_TITLE:$ANTIXB32SPACER"
if [ -f $DOWNLOADPATH/$ANTIXB32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXB32_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXB32_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXB32_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXB64SPACER"
if [ -f $DOWNLOADPATH/$ANTIXB64_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXB64_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXB64_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXB64_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXF_TITLE:$ANTIXF32SPACER"
if [ -f $DOWNLOADPATH/$ANTIXF32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXF32_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXF32_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXF32_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$ANTIXF64SPACER"
if [ -f $DOWNLOADPATH/$ANTIXF64_FILE ] ; then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$ANTIXF64_TITLE (works)" {
 loopback loop $ISOPATH/$ANTIXF64_ISO
 linux (loop)/antiX/vmlinuz  fromiso=$ISOPATH/$ANTIXF64_ISO  blab=$USB_LABEL splash=v
 initrd (loop)/antiX/initrd.gz
}
EOF
else echo -e "$NOTCREATED_MSG"
fi


echo -n -e "\t$SYSRCD_TITLE:$SYSRCDSPACER"
if [ -f $DOWNLOADPATH/$SYSRCD_FILE ] ; then echo -e "$CREATED_MSG\t$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$SYSRCD_TITLE x86 (works)" {
 loopback loop $ISOPATH/$SYSRCD_ISO
 linux (loop)/isolinux/rescue32 isoloop=$ISOPATH/$SYSRCD_ISO
 initrd (loop)/isolinux/initram.igz
}
menuentry "$SYSRCD_TITLE x64 (works)" {
 loopback loop $ISOPATH/$SYSRCD_ISO
 linux (loop)/isolinux/rescue64 isoloop=$ISOPATH/$SYSRCD_ISO
 initrd (loop)/isolinux/initram.igz
}
EOF
else echo -e "$NOTCREATED_MSG\t$NOTCREATED_MSG"
fi



echo -n -e "\t$GPARTED_TITLE:$GPARTED32SPACER"
if [ -f $DOWNLOADPATH/$GPARTED32_FILE ] ; then echo -e -n "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$GPARTED32_TITLE (works)" {
 loopback loop $ISOPATH/$GPARTED32_ISO
   search --set -f (loop)/live/vmlinuz
  linux (loop)/live/vmlinuz boot=live union=overlay username=user config components noswap  toram=filesystem.squashfs ip= net.ifnames=0  nosplash findiso=$ISOPATH/$GPARTED32_ISO
  initrd (loop)/live/initrd.img
}
EOF
else echo -e "$NOTCREATED_MSG"
fi

echo -n -e "\t$GPARTED64SPACER"
if [ -f $DOWNLOADPATH/$GPARTED64_FILE ] ; then echo -e  "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$GPARTED64_TITLE (works)" {
 loopback loop $ISOPATH/$GPARTED64_ISO
   search --set -f /live/vmlinuz
  linux (loop)/live/vmlinuz boot=live union=overlay username=user config components noswap  toram=filesystem.squashfs ip= net.ifnames=0  nosplash findiso=$ISOPATH/$GPARTED64_ISO
  initrd (loop)/live/initrd.img
}
EOF
else echo -e "$NOTCREATED_MSG"
fi


echo -n -e "\t$HDT_TITLE:$HDTSPACER"
if [ -f $DOWNLOADPATH/$HDT_FILE ] ; then echo -e  "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$HDT_TITLE" {
 loopback loop $ISOPATH/$HDT_ISO
 linux16 (loop)/ISOLINUX/memtest iso-scan/filename=$HDT_ISO
}
EOF
else echo -e "$NOTCREATED_MSG"
fi


########### Windows 7 section ##############################
echo -n -e "\t$W7_TITLE:$W7SPACER"
if ! [[ -z $CATTEST ]] ;  then echo -e "$CREATED_MSG"
cat <<EOF >> $MOUNTDIR/$GRUBPATH/grub.cfg
menuentry "$W7_TITLE (works)" {
 insmod chain
 insmod ntfs
 set root=(hd0,msdos2)
 chainloader +1
}
EOF
else echo -e "$NOTCREATED_MSG"
fi
echo -e "\n$ROWMESSAGE"

######## Wiping Cache  ################################################
if (( $DROPCACHES > 0 )) ; then 
  echo -e "\n#################### Cache droppen ####################\n";
  echo "Datenträger syncen"
  sync;
  echo 3 | sudo tee /proc/sys/vm/drop_caches; 
  echo "-> /proc/sys/vm/drop_caches"
  echo "Pagecache, Dentries und Inodes überprüft"
fi

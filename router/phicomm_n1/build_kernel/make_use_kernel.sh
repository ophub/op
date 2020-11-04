#!/bin/bash

#========================================================================================================================
# https://github.com/ophub/op
# Description: Automatically Build OpenWrt firmware for Phicomm N1
# Function: Use Flippy's Armbian kernel files to build kernel.tar.xz & modules.tar.xz
# Copyright (C) 2020 Flippy's Armbian kernel for Phicomm N1
# Copyright (C) 2020 https://github.com/ophub/op
#========================================================================================================================
#
# example: ~/op/router/phicomm_n1/build_kernel/
# ├── flippy
# │   ├── boot-5.4.63-flippy-43+o.tar.gz
# │   ├── dtb-amlogic-5.4.63-flippy-43+o.tar.gz
# │   └── modules-5.4.63-flippy-43+o.tar.gz
# └── make_use_kernel.sh
#
# Usage: Use Ubuntu 18 LTS 64-bit
# 01. Log in to the home directory of the local Ubuntu system
# 02. git clone https://github.com/ophub/op.git
# 03. cd ~/op/router/phicomm_n1/build_kernel/
# 04. Put Flippy's ${build_boot}, ${build_dtb} & ${build_modules} three files into ${flippy_folder}
# 05. Run: sudo ./make_use_kernel.sh
# 06. The generated files path: ~/op/router/phicomm_n1/armbian/phicomm-n1/kernel/${build_save_folder}
# 07. git push to your github
# 08. Github.com Build openwrt: ~/op/.github/workflows/build-openwrt-phicomm_n1.yml
#
# Tips: If run 'sudo ./make_use_kernel.sh' is 'Command not found'. Run: sudo chmod +x make_use_kernel.sh
#
#========================================================================================================================


# Modify Flippy's kernel folder & version
flippy_folder=${PWD}/"flippy"
flippy_version="5.9.1-flippy-47+"

# Default setting ( Don't modify )
build_tmp_folder=${PWD}/"build_tmp"
build_boot="boot-${flippy_version}.tar.gz"
build_dtb="dtb-amlogic-${flippy_version}.tar.gz"
build_modules="modules-${flippy_version}.tar.gz"
build_save_folder=${flippy_version%-flippy*}

get_tree_status=$(dpkg --get-selections | grep tree)
[ $? = 0 ] || sudo apt install tree

# echo color codes
echo_color() {

    this_color=${1}
        case "${this_color}" in
        red)
            echo -e " \033[1;31m[ ${2} ]\033[0m ${3}"
            echo -e "--------------------------------------------"
            echo -e "Current path -PWD-: [ ${PWD} ]"
            echo -e "Situation -lsblk-: [ $(lsblk) ]"
            echo -e "Directory file list -ls-: [ $(ls .) ]"
            echo -e "--------------------------------------------"
            exit 1
            ;;
        green)
            echo -e " \033[1;32m[ ${2} ]\033[0m ${3}"
            ;;
        yellow)
            echo -e " \033[1;33m[ ${2} ]\033[0m ${3}"
            ;;
        blue)
            echo -e " \033[1;34m[ ${2} ]\033[0m ${3}"
            ;;
        purple)
            echo -e " \033[1;35m[ ${2} ]\033[0m ${3}"
            ;;
        *)
            echo -e " \033[1;30m[ ${2} ]\033[0m ${3}"
            ;;
        esac

}

# Check files
check_build_files() {

  if  (test ! -f ${flippy_folder}/${build_boot} || test ! -f ${flippy_folder}/${build_dtb} || test ! -f ${flippy_folder}/${build_modules}); then
    echo_color "red" "(1/4) Error: Files does not exist"  "\n \
    Please check if the following three files exist: \n \
    01. ${flippy_folder}/${build_boot} \n \
    02. ${flippy_folder}/${build_dtb} \n \
    03. ${flippy_folder}/${build_modules} "
  else
    # begin run the script
    echo_color "purple" "Start building"  "${build_save_folder}: kernel.tar.xz & modules.tar.xz ..."
    echo_color "green" "(1/4) End check_build_files"  "..."
  fi

}

# build kernel.tar.xz
build_kernel() {

     [ -d ${build_tmp_folder} ] && rm -rf ${build_tmp_folder} 2>/dev/null
     mkdir -p ${build_tmp_folder}/kernel/Temp_kernel/dtb/amlogic
     mkdir -p ${build_save_folder}

     cp -rf ${flippy_folder}/${build_boot} ${build_tmp_folder}/kernel
     cp -rf ${flippy_folder}/${build_dtb} ${build_tmp_folder}/kernel
     sync

  cd ${build_tmp_folder}/kernel

     echo_color "yellow" "Start Unzip ${build_boot}"  "..."
     if [ "${build_boot##*.}"c = "gz"c ]; then
        tar -xzf ${build_boot}
     elif [ "${build_boot##*.}"c = "xz"c ]; then
        tar -xJf ${build_boot}
     else
        echo_color "red" "(2/4) Error build_kernel ${build_boot}"  "The suffix of ${build_boot} must be .tar.gz or .tar.xz ..."
     fi

     [ -f config-${flippy_version} ] && cp -f config* Temp_kernel/ || echo_color "red" "(2/4) config* does not exist" "..."
     [ -f initrd.img-${flippy_version} ] && cp -f initrd.img* Temp_kernel/ || echo_color "red" "(2/4) initrd.img* does not exist" "..."
     [ -f System.map-${flippy_version} ] && cp -f System.map* Temp_kernel/ || echo_color "red" "(2/4) System.map* does not exist" "..."
     [ -f uInitrd-${flippy_version} ] && cp -f uInitrd* Temp_kernel/uInitrd || echo_color "red" "(2/4) uInitrd* does not exist" "..."
     [ -f vmlinuz-${flippy_version} ] && cp -f vmlinuz* Temp_kernel/zImage || echo_color "red" "(2/4) vmlinuz* does not exist" "..."
     sync

     echo_color "yellow" "Start Unzip ${build_dtb}"  "..."
     if [ "${build_dtb##*.}"c = "gz"c ]; then
        tar -xzf ${build_dtb}
     elif [ "${build_dtb##*.}"c = "xz"c ]; then
        tar -xJf ${build_dtb}
     else
        echo_color "red" "(2/4) Error build_kernel"  "The suffix of ${build_dtb} must be .tar.gz or .tar.xz ..."
     fi

     echo_color "yellow" "(2/4) Start Copy ${build_dtb} one files"  "..."
     [ -f meson-gxl-s905d-phicomm-n1.dtb ] && cp -rf *.dtb Temp_kernel/dtb/amlogic/ || echo_color "red" "(2/4) *phicomm-n1.dtb does not exist" "..."
     sync

  cd Temp_kernel
     echo_color "yellow" "(2/4) Start zip kernel.tar.xz"  "..."
     tar -cf kernel.tar *
     xz -z kernel.tar
     cp -rf kernel.tar.xz ../../../${build_save_folder}/kernel.tar.xz && sync

     echo_color "green" "(2/4) End build_kernel"  "The save path is /${build_save_folder}/kernel.tar.xz ..."

}

# build modules.tar.xz
build_modules() {

  cd ../../../
     rm -rf ${build_tmp_folder}
     mkdir -p ${build_tmp_folder}/modules/lib/modules

     cp -rf ${flippy_folder}/${build_modules} ${build_tmp_folder}/modules/lib/modules && sync

  cd ${build_tmp_folder}/modules/lib/modules

     echo_color "yellow" "(3/4) Start Unzip ${build_modules}"  "..."
     if [ "${build_modules##*.}"c = "gz"c ]; then
        tar -xzf ${build_modules}
     elif [ "${build_modules##*.}"c = "xz"c ]; then
        tar -xJf ${build_modules}
     else
        echo_color "red" "(3/4) Error build_modules"  "The suffix of ${build_modules} must be .tar.gz or .tar.xz ..."
     fi

  cd ${flippy_version}
     x=0
     for file in $(tree -i -f); do
         if [ "${file##*.}"c = "ko"c ]; then
             ln -s $file .
             x=$(($x+1))
         fi
     done
     echo_color "yellow" "(3/4) Have [ ${x} ] files make ko link"  "..."

  cd ../ && rm -rf ${build_modules} && cd ../../
     echo_color "yellow" "(3/4) Start zip modules.tar.xz"  "..."
     tar -cf modules.tar *
     xz -z modules.tar
     cp -rf modules.tar.xz ../../${build_save_folder}/modules.tar.xz && sync

  cd ../../ && rm -rf ${build_tmp_folder} 2>/dev/null
     echo_color "green" "(3/4) End build_modules"  "The save path is /${build_save_folder}/modules.tar.xz ..."

}

# copy kernel.tar.xz & modules.tar.xz to ~/op/router/phicomm_n1/armbian/phicomm-n1/kernel/${build_save_folder}
copy_kernel_modules() {

     cp -rf ${build_save_folder} ../armbian/phicomm-n1/kernel/ && sync
     rm -rf ${flippy_folder}/* ${build_save_folder} 2>/dev/null

     echo_color "green" "(4/4) End copy_kernel_modules"  "Copy /${build_save_folder}/kernel.tar.xz & modules.tar.xz to ../armbian/phicomm-n1/kernel/ ..."

}

check_build_files
build_kernel
build_modules
copy_kernel_modules

echo_color "purple" "Build completed"  "${build_save_folder} ..."
# end run the script


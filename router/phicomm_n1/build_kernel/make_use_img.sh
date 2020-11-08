#!/bin/bash

#========================================================================================================================
# https://github.com/ophub/op
# Description: Automatically Build OpenWrt firmware for Phicomm-N1 & S905x3-Boxs
# Function: Use Flippy's OpenWrt firmware for Phicomm N1 to build kernel.tar.xz & modules.tar.xz
# Copyright (C) 2020 Flippy's Core files for Phicomm-N1 & S905x3-Boxs
# Copyright (C) 2020 https://github.com/ophub/op
#========================================================================================================================
#
# example: ~/op/router/phicomm_n1/build_kernel/
# ├── flippy
# │   └── N1_Openwrt_R20.8.27_k5.4.63-flippy-43+o.img
# └── make_use_img.sh
#
# Usage: Use Ubuntu 18 LTS 64-bit
# 01. Log in to the home directory of the local Ubuntu system
# 02. git clone https://github.com/ophub/op.git
# 03. cd ~/op/router/phicomm_n1/build_kernel/
# 04. Prepare Flippy's ${flippy_file}, support: Armbian_*_Aml-s9xxx_buster*.img, N1_Openwrt*.img, S905x3_Openwrt*.img
#     Support to put the original Armbian_*_Aml-s9xxx_buster*.img.xz file into the directory and use it directly.
# 05. Put Flippy's ${flippy_file} file into ${flippy_folder}
# 06. Modify ${flippy_file} to kernel file name. E.g: flippy_file="Armbian_20.10_Aml-s9xxx_buster_5.8.16-flippy-46+.img"
#     If the file of ${flippy_file} is not found, Will search for other *.img files in the ${flippy_folder} directory.
# 07. Run: sudo ./make_use_img.sh
# 08. The generated files path: ~/op/router/phicomm_n1/armbian/phicomm-n1/kernel/${build_save_folder}
# 09. git push to your github
# 10. Github.com Build openwrt: ~/op/.github/workflows/build-openwrt-phicomm_n1.yml
#
# Tips: If run 'sudo ./make_use_img.sh' is 'Command not found'. Run: sudo chmod +x make_use_img.sh
#
#========================================================================================================================

# Modify Flippy's kernel folder & *.img file name
flippy_folder=${PWD}/"flippy"
flippy_file="Armbian_20.10_Aml-s9xxx_buster_5.9.2-flippy-47+.img"

# Default setting ( Don't modify )
build_tmp_folder=${PWD}/"build_tmp"
boot_tmp=${build_tmp_folder}/boot
root_tmp=${build_tmp_folder}/root
kernel_tmp=${build_tmp_folder}/kernel_tmp
modules_tmp=${build_tmp_folder}/modules_tmp/lib

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

      if  [ -f ${flippy_folder}/${flippy_file} ]; then
          echo_color "blue" "(1/7) The specified file exists." "USE: ${flippy_file} ..."
      elif [ $( ls ${flippy_folder}/*.img -l 2>/dev/null | grep "^-" | wc -l ) -ge 1 ]; then
          unset flippy_file
          flippy_file=$( ls ${flippy_folder}/*.img | head -n 1 )
          flippy_file=${flippy_file##*/}
          echo_color "yellow" "(1/7) Unset flippy_file is [ ${flippy_file} ]"  "\n \
          Try to extract the kernel using this file."
      elif [ $( ls ${flippy_folder}/*.img.xz -l 2>/dev/null | grep "^-" | wc -l ) -ge 1 ]; then
          xz_file=$( ls ${flippy_folder}/*.img.xz | head -n 1 )
          xz_file=${xz_file##*/}
          cd ${flippy_folder} && xz -d ${xz_file} && cd ../
          unset flippy_file
          flippy_file=$( ls ${flippy_folder}/*.img | head -n 1 )
          flippy_file=${flippy_file##*/}
          echo_color "yellow" "(1/7) Unset flippy_file is [ ${flippy_file} ]"  "\n \
          Try to extract the kernel using this file."
      else
          echo_color "red" "(1/7) Error: Please put the compiled files in the [ ${flippy_folder} ] directory." "..."
      fi

      # begin run the script
      echo_color "purple" "Start building" "..."
      echo_color "green" "(1/7) End check_build_files"  "..."

}

#losetup & mount ${flippy_file} boot:kernel.tar.xz root:modules.tar.xz
losetup_mount_img() {

   [ -d ${build_tmp_folder} ] && rm -rf ${build_tmp_folder} 2>/dev/null
   mkdir -p ${boot_tmp} ${root_tmp} ${kernel_tmp} ${modules_tmp}

   lodev=$(losetup -P -f --show ${flippy_folder}/${flippy_file})
   [ $? = 0 ] || echo_color "red" "(2/7) losetup ${flippy_file} failed!" "..."
   mount ${lodev}p1 ${boot_tmp}
   [ $? = 0 ] || echo_color "red" "(2/7) mount ${lodev}p1 failed!" "..."
   mount ${lodev}p2 ${root_tmp}
   [ $? = 0 ] || echo_color "red" "(2/7) mount ${lodev}p2 failed!" "..."

   echo_color "green" "(2/7) End losetup_mount_img"  "Use: ${lodev} ..."

}

#copy ${boot_tmp} & ${root_tmp} Related files to ${kernel_tmp} & ${modules_tmp}
copy_boot_root() {

   cp -rf ${boot_tmp}/{dtb,config*,initrd.img*,System.map*,uInitrd,zImage} ${kernel_tmp}
   cp -rf ${root_tmp}/lib/modules ${modules_tmp}
   sync

   #Check core files
   cd ${kernel_tmp}
   if [ ! -f "config*" -a ! -f "initrd.img*" -a ! -f "System.map*" -a ! -f "uInitrd" -a ! -f "zImage" ]; then
      echo_color "red" "(3.1/7) The five boot core files is Missing!" "..."
   fi

   cd ${kernel_tmp}/dtb/amlogic
   if [ ! -f "meson-gxl-s905d-phicomm-n1.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-gxl-s905d-phicomm-n1.dtb .
      echo_color "yellow" "(3/7) The phicomm-n1 .dtb files is Missing. Has been copied from the dtb library!" "..."
   fi

   if [ ! -f "meson-sm1-x96-max-plus-100m.dtb" -a ! -f "meson-sm1-x96-max-plus.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-x96-max-plus-100m.dtb .
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-x96-max-plus.dtb .
      echo_color "yellow" "(3/7) The X96 [1].dtb core files is Missing. Has been copied from the dtb library!" "..."
   fi

   if [ ! -f "meson-g12a-x96-max.dtb" -a ! -f "meson-g12a-x96-max-rmii.dtb" -a ! -f "meson-sm1-x96-max-plus-oc.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-g12a-x96-max.dtb .
      cp -f ../../../../../armbian/dtb-amlogic/meson-g12a-x96-max-rmii.dtb .
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-x96-max-plus-oc.dtb .
      echo_color "yellow" "(3/7) Some X96 [4,5,6].dtb files is Missing. Has been copied from the dtb library!" "..."
   fi

   if [ ! -f "meson-sm1-hk1box-vontar-x3.dtb" -a ! -f "meson-sm1-hk1box-vontar-x3-oc.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-hk1box-vontar-x3.dtb .
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-hk1box-vontar-x3-oc.dtb .
      echo_color "yellow" "(3/7) Some HX1 [2,7].dtb files is Missing. Has been copied from the dtb library!" "..."
   fi

   if [ ! -f "meson-sm1-h96-max-x3.dtb" -a ! -f "meson-sm1-h96-max-x3-oc.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-h96-max-x3.dtb .
      cp -f ../../../../../armbian/dtb-amlogic/meson-sm1-h96-max-x3-oc.dtb .
      echo_color "yellow" "(3/7) Some H96 [3,8].dtb files is Missing. Has been copied from the dtb library!" "..."
   fi

   if [ ! -f "meson-gxm-octopus-planet.dtb" ]; then
      cp -f ../../../../../armbian/dtb-amlogic/meson-gxm-octopus-planet.dtb .
      echo_color "yellow" "(3/7) The octopus-planet [9].dtb files is Missing. Has been copied from the dtb library!" "..."
   fi

   sync

   echo_color "green" "(3/7) End copy_boot_root"  "..."

}

#get version
get_flippy_version() {

  cd ${modules_tmp}/modules
     flippy_version=$(ls .)
     build_save_folder=$(echo ${flippy_version} | grep -oE '^[1-9].[0-9]{1,2}.[0-9]+')
     cd ../../../../
     mkdir -p ${build_save_folder}

     echo_color "green" "(4/7) End get_flippy_version"  "${build_save_folder} ..."

}

# build kernel.tar.xz & modules.tar.xz
build_kernel_modules() {

  cd ${kernel_tmp}
     tar -cf kernel.tar *
     xz -z kernel.tar
     mv -f kernel.tar.xz ../../${build_save_folder} && cd ../../

  cd ${modules_tmp}/modules/${flippy_version}/

     rm -f *.ko
     x=0
     for file in $(tree -i -f); do
         if [ "${file##*.}"c = "ko"c ]; then
             ln -s $file .
             x=$(($x+1))
         fi
     done
     if [ $x -eq 0 ]; then
        echo_color "red" "(5/7) Error *.KO Files not found"  "..."
     else
        echo_color "blue" "(5/7) Have [ ${x} ] files make ko link"  "..."
     fi

  cd ../../../
     tar -cf modules.tar *
     xz -z modules.tar
     mv -f modules.tar.xz ../../${build_save_folder} && cd ../../
     sync

     echo_color "green" "(5/7) End build_kernel_modules"  "..."

}

# copy kernel.tar.xz & modules.tar.xz to ~/op/router/phicomm_n1/armbian/phicomm-n1/kernel/${build_save_folder}
copy_kernel_modules() {

   cp -rf ${build_save_folder} ../armbian/phicomm-n1/kernel/ && sync

   echo_color "green" "(6/7) End copy_kernel_modules"  "Copy /${build_save_folder}/kernel.tar.xz & modules.tar.xz to ../armbian/phicomm-n1/kernel/ ..."

}

#umount& del losetup
umount_ulosetup() {

   umount -f ${boot_tmp} 2>/dev/null
   umount -f ${root_tmp} 2>/dev/null
   losetup -d ${lodev} 2>/dev/null

   rm -rf ${build_tmp_folder} ${build_save_folder} ${flippy_folder}/* 2>/dev/null

   echo_color "green" "(7/7) End umount_ulosetup"  "..."

}

check_build_files
losetup_mount_img
copy_boot_root
get_flippy_version
build_kernel_modules
copy_kernel_modules
umount_ulosetup

echo_color "purple" "Build completed"  "${build_save_folder} ..."

# end run the script


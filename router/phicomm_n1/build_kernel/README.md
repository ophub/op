# Build OpenWrt's Armbian kernel for Phicomm-N1 & S905x3-Boxs

If you use Phicomm N1 & S905x3-Boxs to install OpenWrt, you must know ‘Flippy’. He provides many versions of openwrt firmware for Phicomm-N1 & S905x3-Boxs and shares his series of Armbian kernels. If you have heard of ‘Flippy’ for the first time, you can find it through a search engine, E.g: ***` Flippy n1 `***

## Usage

You can install Flippy’s OpenWrt firmware and use it. If you want to define some plug-ins and make your own dedicated op firmware, you can use this script to generate a kernel package adapted to this github source code. You have two ways to get the kernel, one is to use the kernel file provided by Flippy to synthesize ***`(boot-${flippy_version}.tar.gz, dtb-amlogic-${flippy_version}.tar.gz & modules-${flippy_version}.tar.gz)`***, another way is to use the ***`Flippy’s kernel file`*** provided by him to extract. The operation of these two methods is as follows:

The first method: 
```shell script
Example: ~/op/router/phicomm_n1/build-kernel/
 ├── flippy
 │   ├── Armbian_20.10_Aml-s9xxx_buster_5.9.2-flippy-47+.img
 │   ├── OR: N1_Openwrt_R20.10.20_k5.4.73-flippy-47+o.img
 │   └── OR: S905x3_Openwrt_R20.10.20_k5.9.2-flippy-47+.img
 └── make_use_img.sh
```

Put the ***`Flippy’s kernel file`*** E.g: ***`Armbian_20.10_Aml-s9xxx_buster_5.9.2-flippy-47+.img`*** file into the ***`${flippy_folder}`*** folder, Modify ${flippy_file} to kernel file name. E.g: ***`flippy_file="Armbian_20.10_Aml-s9xxx_buster_5.9.2-flippy-47+.img"`***. then run the script:
```shell script
sudo ./make_use_img.sh
```

The second method: 
```shell script
Example: ~/op/router/phicomm_n1/build-kernel/
 ├── flippy
 │   ├── boot-5.4.63-flippy-43+o.tar.gz
 │   ├── dtb-amlogic-5.4.63-flippy-43+o.tar.gz
 │   └── modules-5.4.63-flippy-43+o.tar.gz
 └── make_use_kernel.sh
```

put ***`boot-${flippy_version}.tar.gz, dtb-amlogic-${flippy_version}.tar.gz & modules-${flippy_version}.tar.gz`*** the three files into the ***`${flippy_folder}`*** folder, Modify ${flippy_version} to kernel version. E.g: ***`flippy_version="5.9.1-flippy-47+"`***. then run the script:
```shell script
sudo ./make_use_kernel.sh
```

The generated files ***` kernel.tar.gz & modules.tar.gz `*** will be directly placed in the kernel directory of this github: ***` ~/op/router/phicomm_n1/armbian/phicomm-n1/kernel/${build_save_folder} `***

## Tips

Use this github's program for Phicomm N1: ***` ~/op/router/phicomm_n1 `*** , you can customize ` default IP, hostname, theme, add/remove software packages `, etc. to generate special firmware.

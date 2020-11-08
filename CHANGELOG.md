# Change Log
The version update instructions record each important update point for everyone to track and understand.

## Release Notes
- Date: Version update date.
- Importance: The difference between five stars, the more stars the more important.
- Types: ADD / UPDATE / TOOL / BUG
- description: Detailed description of the update.
- Path: Link to related files.
- Firmware: Targeted OpenWrt firmware.

| Date | Firmware | Types | Importance | Path | description |
| ---- | ---- | ---- | ---- | ---- | ---- |
| 2020.11.08 | N1, S905x3 | TOOL | ✩✩✩ | [dtb-amlogic](https://github.com/ophub/op/tree/main/router/phicomm_n1/armbian/dtb-amlogic) | The dtb library is added to facilitate the lack of corresponding boot files when compiling the firmware of related models with the old version of the kernel file. |
| - | N1, S905x3 | TOOL | ✩✩✩ | [update_dtb.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/build_kernel/update_dtb.sh) | Update kernel.tar.xz files in the kernel directory with the latest dtb file. |
| - | N1, S905x3 | UPDATE | ✩✩✩✩✩ | [kernel](https://github.com/ophub/op/tree/main/router/phicomm_n1/armbian/phicomm-n1/kernel) | Supplement the old version of the kernel with the latest dtb file. |
| - | N1, S905x3 | UPDATE | ✩✩✩ | [make_use_img.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/build_kernel/make_use_img.sh) | When the kernel is extracted, if the file lacks a key .dtb file, the supplement will be extracted from the dtb library. |
| - | N1, S905x3 | UPDATE | ✩✩✩ | [make_use_kernel.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/build_kernel/make_use_kernel.sh) | When the kernel is extracted, if the file lacks a key .dtb file, the supplement will be extracted from the dtb library. |
| - | N1, S905x3 | UPDATE | ✩✩ | [s905x3-install.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/install-program/files/s905x3-install.sh) | Added that if the dtb file is missing during installation, the download path will be prompted. |
| 2020.11.07 | N1, S905x3 | ADD | ✩✩ | [5.4.75](https://github.com/ophub/op/tree/main/router/phicomm_n1/armbian/phicomm-n1/kernel/5.4.75) | Add New kernel. |
| - | N1, S905x3 | ADD | ✩✩ | [5.9.5](https://github.com/ophub/op/tree/main/router/phicomm_n1/armbian/phicomm-n1/kernel/5.9.5) | Add New kernel. |
| - | N1, S905x3 | UPDATE | ✩✩ | [make_use_img.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/build_kernel/make_use_img.sh) | Add fuzzy matching function. When the version specified by the script is not found, other firmware will be searched from the flippy directory. Thus, you can directly put the kernel file you want to use into the flippy directory for extraction, without manually changing the relevant parameters each time. |
| - | N1, S905x3 | UPDATE | ✩✩ | [make_use_kernel.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/build_kernel/make_use_kernel.sh) | Add fuzzy matching function. When the version specified by the script is not found, other firmware will be searched from the flippy directory. Thus, you can directly put the kernel file you want to use into the flippy directory for extraction, without manually changing the relevant parameters each time. |
| 2020.11.05 | S905x3 | UPDATE | ✩✩ | [build-openwrt-s905x3.yml](https://github.com/ophub/op/blob/main/.github/workflows/build-openwrt-s905x3.yml) | Use the environment variable GITHUB_REPOSITORY to replace ophub/op, so that fork users can call their own compiled phicomm-n1 firmware to compile the s905x3-boxs series firmware instead of pointing to the releases of this warehouse. |
| - | N1 | UPDATE | ✩✩ | [test-build-phicomm_n1.yml](https://github.com/ophub/op/blob/main/.github/workflows/test-build-phicomm_n1.yml) | Use the environment variable GITHUB_REPOSITORY to replace ophub/op, so that fork users can call their own compiled phicomm-n1 firmware to compile the new version of the firmware instead of pointing to the releases in this warehouse. |
| 2020.11.03 | All | UPDATE | ✩✩ | [.config](https://github.com/ophub/op/blob/main/router/x64/.config) | Several software packages such as lsblk are integrated by default when the firmware is compiled, which supports later use in firmware maintenance. |
| 2020.11.01 | N1, S905x3 | ADD | ✩✩✩✩✩ | [s905x3-install.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/install-program/files/s905x3-install.sh) | Added the function of writing emmc partition to s905x3 series boxes. |
| - | N1, S905x3 | ADD | ✩✩✩✩✩ | [s905x3-update.sh](https://github.com/ophub/op/blob/main/router/phicomm_n1/install-program/files/s905x3-update.sh) | Added the function of updating emmc partition firmware to s905x3 series boxes. |
| 2020.10.25 | s905x3 | ADD | ✩✩ | [s905x3](https://github.com/ophub/op/tree/main/router/s905x3) | Add OpenWrt Firmware for S905x3. |
| 2020.10.01 | NanoPi-R2S | ADD | ✩✩ | [NanoPi-R2S](https://github.com/ophub/op/tree/main/router/nanopi_r2s) | Add OpenWrt Firmware for NanoPi-R2S. |
| 2020.09.01 | N1 | ADD | ✩✩ | [Phicomm-N1](https://github.com/ophub/op/tree/main/router/phicomm_n1) | Add OpenWrt Firmware for Phicomm-N1. |
| 2020.08.10 | WRT32X | ADD | ✩✩ | [WRT32X](https://https://github.com/ophub/op/tree/main/router/linksys_wrt32x) | Add OpenWrt Firmware for Linksys WRT32X. |
| 2020.08.10 | WRT3200ACM | ADD | ✩✩ | [WRT3200ACM](https://github.com/ophub/op/tree/main/router/linksys_wrt3200acm) | Add OpenWrt Firmware for Linksys WRT3200ACM. |
| 2020.08.10 | WRT1900ACS | ADD | ✩✩ | [WRT1900ACS](https://github.com/ophub/op/tree/main/router/linksys_wrt1900acs) | Add OpenWrt Firmware for Linksys WRT1900ACS. |
| 2020.08.01 | x64 | ADD | ✩✩ | [x64](https://github.com/ophub/op/tree/main/router/x64) | Add OpenWrt Firmware for x64. |
| 2020.07.23 | - | ADD | ✩ | [op](https://github.com/ophub/op) | Open this Github. |



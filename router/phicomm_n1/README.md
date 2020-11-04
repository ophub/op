# OpenWrt for Phicomm-N1


You can download the OpwnWrt for Phicomm N1 firmware from [Actions](https://github.com/ophub/op/actions). From the ` Build OpenWrt for Phicomm N1 `, Such as `***-phicomm-n1-v5.4.50-openwrt-firmware or other kernel versions.` Unzip to get the `***.img` file. Or download from [Releases](https://github.com/ophub/op/releases). Such as `OpenWrt_Phicomm_N1_${date}`. Then write the IMG file to the USB hard disk through software such as [balenaEtcher](https://www.balena.io/etcher/).

The firmware supports USB hard disk booting. You can also Install the OpenWrt firmware in the USB hard disk into the EMMC partition of Phicomm N1, and start using it from N1.

Insert the ***`USB hard disk`*** with the written openwrt firmware into the Phicomm N1, and then plug it into the ***`power supply`***. The Phicomm N1 will automatically start the openwrt system from the USB hard disk, wait for about 2 minutes, select ***`OpenWrt`*** in the wireless wifi list of your computer, no password, the computer will automatically obtain the IP, Enter OpwnWrt's IP Address: ***`192.168.1.1`***, Account: ***`root`***, Password: ***`password`***, and then log in OpenWrt system.

Install OpenWrt: `Login in to openwrt` → `system menu` → `TTYD terminal` → input command: 
```shell script
n1-install.sh
# Wait for the installation to complete. remove the USB hard disk, unplug/plug in the power again, reboot into EMMC.
```

Upgrading OpenWrt: `Login in to openwrt` → `system menu` → `file transfer` → upload ***`phicomm-n1-openwrt.zip`*** to ***`/tmp/upload/`***`, enter the `system menu` → `TTYD terminal` → input command: 
```shell script
mv -f /tmp/upload/phicomm-n1-openwrt.zip  /opt
cd /opt
unzip phicomm-n1-openwrt.zip     #Unzip the [ phicomm-n1-openwrt.zip ] file to get [ phicomm-n1-openwrt.img ]
cd /
n1-update.sh
reboot
```

If the partition fails and cannot be written, you can restore the bootloader, restart it, and run the relevant command again.
```shell script
dd if=/root/u-boot-2015-phicomm-n1.bin of=/dev/mmcblk1
sync
reboot
```

Note: If used as a bypass gateway, you can add custom firewall rules as needed (Network → Firewall → Custom Rules):
```shell script
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE        #If the interface is eth0.
iptables -t nat -I POSTROUTING -o br-lan -j MASQUERADE      #If the interface is br-lan bridged.
```

## Local compilation instructions
The software package supports Github Action cloud compilation, and the compiled firmware can be downloaded directly in [Action](https://github.com/ophub/op/actions) and [Releases](https://github.com/ophub/op/releases). You can also compile locally:
1. Clone the warehouse to the local. `git clone https://github.com/ophub/op`
2. Create an `openwrt` folder in the local `op/router/phicomm_n1` directory, and upload the compiled openwrt firmware of the ARM kernel to the openwrt directory
3. Enter the phicomm_n1 directory and run `sudo ./make -d` to complete the compilation. The generated openwrt firmware supporting Phicomm N1 is in the `out` directory under the root directory.

## Detailed make compile command
- `sudo ./make -d`: Compile all kernel versions of openwrt with the default configuration. This command is recommended.
- `sudo ./make -d -k latest`: Use the default configuration to compile the latest kernel version of the openwrt firmware.
- `sudo ./make -d -s 512 -k 5.7.15`: Use the default configuration and set the partition size to 512m, and only compile the openwrt firmware with the kernel version 5.7.15.
- `sudo ./make -h`: Display help information and view detailed description of each parameter.
- `sudo ./make`: If you are familiar with the relevant setting requirements of the phicomm_n1 firmware, you can follow the prompts, such as selecting the firmware you want to make, the kernel version, setting the ROOTFS partition size, etc. If you don’t know these settings, just press Enter.

## Compilation method

- Select ***`Build OpenWrt for Phicomm N1`*** on the [Action](https://github.com/ophub/op/actions) page.
- Click the ***`Run workflow`*** button.

## Configuration file function description

| Folder/file name | Features |
| ---- | ---- |
| .config | Firmware related configuration, such as firmware kernel, file type, software package, luci-app, luci-theme, etc. |
| files | Create a files directory under the root directory of the warehouse and put the relevant files in. You can use custom files such as network/dhcp/wireless by default when compiling. |
| feeds.conf.default | Just put the feeds.conf.default file into the root directory of the warehouse, it will overwrite the relevant files in the OpenWrt source directory. |
| diy-part1.sh | Execute before updating and installing feeds, you can write instructions for modifying the source code into the script, such as adding/modifying/deleting feeds.conf.default. |
| diy-part2.sh | After updating and installing feeds, you can write the instructions for modifying the source code into the script, such as modifying the default IP, host name, theme, adding/removing software packages, etc. |
| make | Phicomm N1 OpenWrt firmware build script. |
| armbian | Multi-version kernel file directory. |
| build-n1-kernel | Use the kernel file shared by Flippy to build this script to build the Armbian kernel of OpenWrt for Phicomm-N1. |
| install-program | Script to flash firmware to emmc. |


## .github/workflow/build-openwrt-phicomm_n1.yml related environment variable description

| Environment variable | Features |
| ---- | ---- |
| REPO_URL | Source code warehouse address |
| REPO_BRANCH | Source branch |
| FEEDS_CONF | Custom feeds.conf.default file name |
| CONFIG_FILE | Custom .config file name |
| DIY_P1_SH | Custom diy-part1.sh file name |
| DIY_P2_SH | Custom diy-part2.sh file name |
| UPLOAD_BIN_DIR | Upload the bin directory (all ipk files and firmware). Default false |
| UPLOAD_FIRMWARE | Upload firmware catalog. Default true |
| UPLOAD_RELEASE | Upload firmware to release. Default true |
| UPLOAD_COWTRANSFER | Upload the firmware to CowTransfer.com. Default false |
| UPLOAD_WERANSFER | Upload the firmware to WeTransfer.com. Default failure |
| RECENT_LASTEST | maximum retention days for release, artifacts and logs in GitHub Release and Actions. |
| TZ | Time zone setting |
| secrets.GITHUB_TOKEN | 1. Personal center: Settings → Developer settings → Personal access tokens → Generate new token ( Name: GITHUB_TOKEN, Select: public_repo, Copy GITHUB_TOKEN's Value ). 2. Op code center: Settings → Secrets → New secret ( Name: RELEASES_TOKEN, Value: Paste GITHUB_TOKEN's Value ). |

## Firmware compilation parameters

| Option | Value |
| ---- | ---- |
| Target System | QEMU ARM Virtual Machine |
| Subtarget | ARMv8 multiplatform |
| Target Profile | Default |
| Target Images | squashfs |
| Utilities  ---> |  <*> install-program |
| LuCI -> Applications | in the file: .config |

## Firmware information

| Name | Value |
| ---- | ---- |
| Default IP | 192.168.1.1 |
| Default username | root |
| Default password | password |
| Default WIFI name | OpenWrt |
| Default WIFI password | none |

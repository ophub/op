# OpenWrt for S905x3 ( X96-Max+, H96-Max-X3-Round & HK1-Box )

You can download the OpwnWrt for S905x3 firmware from [Actions](https://github.com/ophub/op/actions). From the ` Build OpenWrt for S905x3 `, Such as `openwrt_s905x3_${date}` Unzip to get the `***.img` file. Or download from [Releases](https://github.com/ophub/op/releases). Such as `openwrt_S905x3_${date}`. Then write the IMG file to the USB card/TF card  through software such as [balenaEtcher](https://www.balena.io/etcher/).

## Compilation instructions
1. Online automatic compilation: The script will regularly use the latest OpenWrt for phicomm-n1 firmware and modify ***` /boot/uEnv.txt `*** to build a compatible S905x3 series router.
2. Local manual compilation: First put the phicomm-n1 firmware into the ***` flippy `*** folder, and then run `sudo ./make ${firmware_key}`, the generated file is in the ***` out `*** directory.


## Firmware instructions

- `openwrt_x96_*.img`: Almost compatible with all S905x3 boxes to boot from USB hard disk, you can choose different box types when installing into EMMC.
- `openwrt_hk1_*.img`: For HK1-Box(S905x3).

## Install into emmc

The firmware supports USB hard disk booting. You can also Install the OpenWrt firmware in the USB hard disk into the EMMC partition of S905x3, and start using it from EMMC.

- Open the developer mode: Settings → About this machine → Version number (for example: X96max plus...), click on the version number for 7 times in quick succession, and you will see that the developer mode is turned on.

- Turn on USB debugging: After restarting, enter Settings → System → Advanced options → Developer options again (after entering, confirm that the status is on, and the USB debugging status in the list is also on)

- Boot from U disk: Unplug the power → insert the Usb disk → insert the thimble into the AV port (top reset button) → insert the power → release the thimble of the av port → the system will boot from the Usb disk.

- Log in to the system: Connect the computer and the s905x3 box with a network interface → turn off the wireless wifi on the computer → enable the wired connection → manually set the computer ip to the same network segment ip as openwrt, ipaddr such as ***`192.168.1.2`***. The netmask is ***`255.255.255.0`***, and others are not filled in. You can log in to the openwrt system from the browser, Enter OpwnWrt's IP Address: ***`192.168.1.1`***, Account: ***`root`***, Password: ***`password`***, and then log in OpenWrt system.

- Tips: When booting from USB, the network card is 100M, and it will automatically become Gigabit after writing into EMMC.

- Install OpenWrt: `Login in to openwrt` → `system menu` → `TTYD terminal` → input command: 
```shell script
cd /root
chmod 755 s905x3-install.sh
./s905x3-install.sh
reboot
```

Wait for the installation to complete. remove the USB hard disk, unplug/plug in the power again, reboot into EMMC.

Upgrading OpenWrt: `Login in to openwrt` → `system menu` → `file transfer` → upload ***`s905x3-openwrt.zip`*** to ***`/tmp/upload/`***, enter the `system menu` → `TTYD terminal` → input command: 
```shell script
mv -f /tmp/upload/s905x3-openwrt.zip /mnt/mmcblk2p4
cp -f /root/s905x3-update.sh /mnt/mmcblk2p4
cd /mnt/mmcblk2p4
unzip s905x3-openwrt.zip    #Unzip the [ s905x3-openwrt.zip ] file to get [ s905x3-openwrt.img ]
chmod 755 s905x3-update.sh
./s905x3-update.sh s905x3-openwrt.img
reboot
```

Note: If used as a bypass gateway, you can add custom firewall rules as needed (Network → Firewall → Custom Rules):
```shell script
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE        #If the interface is eth0.
iptables -t nat -I POSTROUTING -o br-lan -j MASQUERADE      #If the interface is br-lan bridged.
```

## Support firmware

Put phicomm_n1_firmware file into ${flippy_folder}. Support putting multiple phicomm_n1_firmware_*.img or phicomm_n1_firmware_*.zip files into compiling together.

```shell script
example: ~/op/router/s905x3/
 ├── flippy
 │   ├── phicomm_n1_firmware_01.img
 │   ├── phicomm_n1_firmware_02.img
 │   ├── phicomm_n1_firmware_more.img
 │   │
 │   └── or phicomm_n1_firmware.zip
 │
 └── make
 ```

## /boot/uEnv.txt FDT FILES

```shell script
#Phicomm-N1
#FDT=/dtb/amlogic/meson-gxl-s905d-phicomm-n1.dtb

# X96 Max+ [tag: x96] ( S905X3 Network: 100m / TF card: 30Mhz / CPU: 2124Mhz ) 
#The default DTB when the USB flash drive is started, almost compatible with all S905x3 boxes.
FDT=/dtb/amlogic/meson-sm1-x96-max-plus-100m.dtb

# X96 Max+ ( S905X3 Network: 1000M / TF card: 30Mhz / CPU: 2124Mhz )
#FDT=/dtb/amlogic/meson-sm1-x96-max-plus.dtb

# X96 Max+ ( S905X3 Network: 1000M / TF card: 30Mhz / CPU: 2244Mhz )
#FDT=/dtb/amlogic/meson-sm1-x96-max-plus-oc.dtb

# HK1 BoX [tag: hk1] ( S905X3 Network: 1000M / TF card: 25Mhz / CPU: 2124Mhz )
#FDT=/dtb/amlogic/meson-sm1-hk1box-vontar-x3.dtb

# HK1 BoX ( S905X3 Network: 1000M / TF card: 25Mhz / CPU: 2184Mhz )
#FDT=/dtb/amlogic/meson-sm1-hk1box-vontar-x3-oc.dtb

# H96 Max X3 ( S905X3 Network: 1000M / TF card: 50Mhz / CPU: 2124Mhz )
#FDT=/dtb/amlogic/meson-sm1-h96-max-x3.dtb

# H96 Max X3 ( S905X3 Network: 1000M / TF card: 50Mhz / CPU: 2208Mhz )
#FDT=/dtb/amlogic/meson-sm1-h96-max-x3-oc.dtb

# X96 Max ( S905X2 Network: 1000M / TF card: 50Mhz / CPU: 1944Mhz )
#Applicable to most S905x2, 4G memory Gigabit network card boxes.
#FDT=/dtb/amlogic/meson-g12a-x96-max.dtb

# X96 Max ( S905X2 Network: 100M / TF card: 50Mhz / CPU: 1944Mhz )
#Applicable to most S905x2, 2G memory 100M network card boxes.
#FDT=/dtb/amlogic/meson-g12a-x96-max-rmii.dtb

# octopus-planet ( S905X3 Network: 1000M / TF card: 30Mhz / CPU: 2124Mhz )
#FDT=/dtb/amlogic/meson-gxm-octopus-planet.dtb
````

Method: Add # in front of the dtb file path of Phicomm N1, and remove the # in front of the firmware you need. 

## Detailed make compile command

```shell script
sudo ./make x96  #Almost compatible with all S905x3 boxes to boot from USB hard disk, Choose box types when installing into EMMC.
sudo ./make hk1  #Build the OpenWrt firmware of HK1-Box according to the default configuration.
sudo ./make all  #Build All S905x3 OpenWrt firmware according to the default configuration firmware. 
````

## Compilation method

- Select ***`Build OpenWrt for S905x3`*** on the [Action](https://github.com/ophub/op/actions) page.
- Click the ***`Run workflow`*** button.

## Configuration file function description

| Folder/file name | Features |
| ---- | ---- |
| flippy | Store Phicomm-N1 firmware, support multiple .img to compile together. Support the Phicomm-N1 firmware zip file generated by this github to be directly put in for compilation. |
| make | s905x3 OpenWrt firmware build script. |


## .github/workflow/build-openwrt-s905x3.yml related environment variable description

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


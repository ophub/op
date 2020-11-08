# install-program

Install to emmc script for Phicomm N1 and S905x3 Box, which will help you to copy openwrt system to emmc.

## Usage for phicomm n1

The firmware supports USB hard disk booting. You can also Install the OpenWrt firmware in the USB hard disk into the EMMC partition of Phicomm N1, and start using it from EMMC.

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
reboot
```

## Usage for S905x3 Box

The firmware supports USB hard disk booting. You can also Install the OpenWrt firmware in the USB hard disk into the EMMC partition of S905x3 Box, and start using it from EMMC.

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


#!/bin/sh

# check cmd param
if  [ "$1" == "" ]; then
    echo "Usage: $0 xxx.img"
    exit 1
fi

# check image file
IMG_NAME=$1
if  [ ! -f "$IMG_NAME" ]; then
    echo "[ $IMG_NAME ] does not exist!"
    exit 1
fi

# find boot partition 
BOOT_PART_MSG=$(lsblk -l -o NAME,PATH,TYPE,UUID,MOUNTPOINT | awk '$3~/^part$/ && $5 ~ /^\/boot$/ {print $0}')
if  [ "${BOOT_PART_MSG}" == "" ]; then
    echo "Boot The partition does not exist or is not mounted correctly, so the upgrade cannot be continued!"
    exit 1
fi

BR_FLAG=1
echo -e "Do you want to backup the configuration of the old version and restore it to the upgraded system? y/n [y]\b\b"
read yn
case $yn in
     n*|N*) BR_FLAG=0;;
esac

BOOT_NAME=$(echo $BOOT_PART_MSG | awk '{print $1}')
BOOT_PATH=$(echo $BOOT_PART_MSG | awk '{print $2}')
BOOT_UUID=$(echo $BOOT_PART_MSG | awk '{print $4}')

# find root partition 
ROOT_PART_MSG=$(lsblk -l -o NAME,PATH,TYPE,UUID,MOUNTPOINT | awk '$3~/^part$/ && $5 ~ /^\/$/ {print $0}')
ROOT_NAME=$(echo $ROOT_PART_MSG | awk '{print $1}')
ROOT_PATH=$(echo $ROOT_PART_MSG | awk '{print $2}')
ROOT_UUID=$(echo $ROOT_PART_MSG | awk '{print $4}')
case $ROOT_NAME in 
  mmcblk2p2) NEW_ROOT_NAME=mmcblk2p3
	     NEW_ROOT_LABEL=EMMC_ROOTFS2
	     ;;
  mmcblk2p3) NEW_ROOT_NAME=mmcblk2p2
	     NEW_ROOT_LABEL=EMMC_ROOTFS1
	     ;;
          *) echo "ROOTFS The partition location is incorrect, so the upgrade cannot continue!"
             exit 1
             ;;
esac

# find new root partition
NEW_ROOT_PART_MSG=$(lsblk -l -o NAME,PATH,TYPE,UUID,MOUNTPOINT | grep "${NEW_ROOT_NAME}" | awk '$3 ~ /^part$/ && $5 !~ /^\/$/ && $5 !~ /^\/boot$/ {print $0}')
if  [ "${NEW_ROOT_PART_MSG}" == "" ]; then
    echo "The new ROOTFS partition does not exist, so the upgrade cannot continue!"
	  exit 1
fi
NEW_ROOT_NAME=$(echo $NEW_ROOT_PART_MSG | awk '{print $1}')
NEW_ROOT_PATH=$(echo $NEW_ROOT_PART_MSG | awk '{print $2}')
NEW_ROOT_UUID=$(echo $NEW_ROOT_PART_MSG | awk '{print $4}')
NEW_ROOT_MP=$(echo $NEW_ROOT_PART_MSG | awk '{print $5}')

# losetup
losetup -f -P $IMG_NAME
if  [ $? -eq 0 ]; then
    LOOP_DEV=$(losetup | grep "$IMG_NAME" | awk '{print $1}')
    if  [ "$LOOP_DEV" == "" ]; then
        echo "loop device not found!"
        exit 1
    fi
else
    echo "losetup [ $IMG_FILE ] failed!"
    exit 1
fi
WAIT=3
echo "The loopdev is [ $LOOP_DEV ], wait [ ${WAIT} ] seconds "
while [ $WAIT -ge 1 ]; do
      echo "."
      sleep 1
      WAIT=$(( WAIT - 1 ))
done
echo

# umount loop devices (openwrt will auto mount some partition)
MOUNTED_DEVS=$(lsblk -l -o NAME,PATH,MOUNTPOINT | grep "$LOOP_DEV" | awk '$3 !~ /^$/ {print $2}')
for dev in $MOUNTED_DEVS; do
    while : ; do
        echo "umount [ $dev ] ... "
        umount -f $dev
        sleep 1
        mnt=$(lsblk -l -o NAME,PATH,MOUNTPOINT | grep "$dev" | awk '$3 !~ /^$/ {print $2}')
        if  [ "$mnt" == "" ]; then
            echo "success."
            break
        else 
            echo "Retry ..."
        fi
    done
done

# mount src part
WORK_DIR=$PWD
P1=${WORK_DIR}/boot
P2=${WORK_DIR}/root
mkdir -p $P1 $P2
echo "Mount [ ${LOOP_DEV}p1 ] -> [ ${P1} ] ... "
mount -t vfat -o ro ${LOOP_DEV}p1 ${P1}
if  [ $? -ne 0 ]; then
    echo "Mount [ ${LOOP_DEV}p1 ] failed!"
    losetup -D
    exit 1
else 
    echo "success."
fi	

echo "Mount [ ${LOOP_DEV}p2 ] -> [ ${P2} ] ... "
mount -t btrfs -o ro,compress=zstd ${LOOP_DEV}p2 ${P2}
if  [ $? -ne 0 ]; then
    echo "Mount [ ${LOOP_DEV}p2 ] failed!"
    umount -f ${P1}
    losetup -D
    exit 1
else
    echo "success."
fi	

#format NEW_ROOT
echo "umount [ ${NEW_ROOT_MP} ]"
umount -f "${NEW_ROOT_MP}"
if  [ $? -ne 0 ]; then
    echo "Mount failed, Please restart and try again!"
    umount -f ${P1}
    umount -f ${P2}
    losetup -D
    exit 1
fi

echo "Format [ ${NEW_ROOT_PATH} ]"
NEW_ROOT_UUID=$(uuidgen)
mkfs.btrfs -f -U ${NEW_ROOT_UUID} -L ${NEW_ROOT_LABEL} -m single ${NEW_ROOT_PATH}
if  [ $? -ne 0 ]; then
    echo "Format [ ${NEW_ROOT_PATH} ] failed!"
    umount -f ${P1}
    umount -f ${P2}
    losetup -D
    exit 1
fi

echo "Mount [ ${NEW_ROOT_PATH} ] -> [ ${NEW_ROOT_MP} ]"
mount -t btrfs -o compress=zstd ${NEW_ROOT_PATH} ${NEW_ROOT_MP}
if  [ $? -ne 0 ]; then
    echo "Mount [ ${NEW_ROOT_PATH} ] -> [ ${NEW_ROOT_MP} ] failed!"
    umount -f ${P1}
    umount -f ${P2}
    losetup -D
    exit 1
fi

# begin copy rootfs
cd ${NEW_ROOT_MP}
echo "Start copying data， 从 [ ${P2} ] TO [ ${NEW_ROOT_MP} ] ..."
ENTRYS=$(ls)
for entry in $ENTRYS; do
    if  [ "$entry" == "lost+found" ]; then
        continue
    fi
    echo "Remove old [ $entry ] ... "
    rm -rf $entry 
    if  [ $? -eq 0 ]; then
        echo "success."
    else
        echo "failed."
        exit 1
    fi
done
echo

echo "Create folder ... "
mkdir -p .reserved bin boot dev etc lib opt mnt overlay proc rom root run sbin sys tmp usr www
ln -sf lib/ lib64
ln -sf tmp/ var
echo "success."
echo

COPY_SRC="root etc bin sbin lib opt usr www"
echo "Copy data ... "
for src in $COPY_SRC; do
    echo "Copy $src ... "
    (cd ${P2} && tar cf - $src) | tar xf -
    sync
    echo "success."
done
[ -d /mnt/mmcblk2p4/docker ] || mkdir -p /mnt/mmcblk2p4/docker
rm -rf opt/docker && ln -sf /mnt/mmcblk2p4/docker/ opt/docker

if  [ -f /mnt/${NEW_ROOT_NAME}/etc/config/AdGuardHome ]; then
    [ -d /mnt/mmcblk2p4/AdGuardHome/data ] || mkdir -p /mnt/mmcblk2p4/AdGuardHome/data
    if  [ ! -L /usr/bin/AdGuardHome ]; then
        [ -d /usr/bin/AdGuardHome ] && \
        cp -a /usr/bin/AdGuardHome/* /mnt/mmcblk2p4/AdGuardHome/
    fi
    ln -sf /mnt/mmcblk2p4/AdGuardHome /mnt/${NEW_ROOT_NAME}/usr/bin/AdGuardHome
fi

BOOTLOADER="./lib/u-boot/hk1box-bootloader.img"
if  [ -f ${BOOTLOADER} ]; then
    if dmesg | grep 'AMedia X96 Max+'; then
        echo "*** write u-boot ... "
        # write u-boot
        dd if=${BOOTLOADER} of=/dev/mmcblk2 bs=1 count=442 conv=fsync
        dd if=${BOOTLOADER} of=/dev/mmcblk2 bs=512 skip=1 seek=1 conv=fsync
        echo "*** success."
    fi
fi

rm -f /mnt/${NEW_ROOT_NAME}/root/s905x3-install.sh
sync
echo "Copy complete."
echo

BACKUP_LIST=$(${P2}/usr/sbin/flippy -p)
if  [ $BR_FLAG -eq 1 ]; then
    # restore old config files
    OLD_RELEASE=$(grep "DISTRIB_REVISION=" /etc/openwrt_release | awk -F "'" '{print $2}'|awk -F 'R' '{print $2}' | awk -F '.' '{printf("%02d%02d%02d\n", $1,$2,$3)}')
    NEW_RELEASE=$(grep "DISTRIB_REVISION=" ./etc/uci-defaults/99-default-settings | awk -F "'" '{print $2}'|awk -F 'R' '{print $2}' | awk -F '.' '{printf("%02d%02d%02d\n", $1,$2,$3)}')
    if  [ ${OLD_RELEASE} -le 200311 ] && [ ${NEW_RELEASE} -ge 200319 ]; then
        mv ./etc/config/shadowsocksr ./etc/config/shadowsocksr.${NEW_RELEASE}
    fi
    mv ./etc/config/qbittorrent ./etc/config/qbittorrent.orig
    
    echo "Start to restore the configuration file backed up from the old system ... "
    (
        cd /
        eval tar czf ${NEW_ROOT_MP}/.reserved/openwrt_config.tar.gz "${BACKUP_LIST}" 2>/dev/null
    )
    tar xzf ${NEW_ROOT_MP}/.reserved/openwrt_config.tar.gz
    if  [ ${OLD_RELEASE} -le 200311 ] && [ ${NEW_RELEASE} -ge 200319 ]; then
        mv ./etc/config/shadowsocksr ./etc/config/shadowsocksr.${OLD_RELEASE}
        mv ./etc/config/shadowsocksr.${NEW_RELEASE} ./etc/config/shadowsocksr
    fi
    if  grep 'config qbittorrent' ./etc/config/qbittorrent; then
        rm -f ./etc/config/qbittorrent.orig
    else
        mv ./etc/config/qbittorrent.orig ./etc/config/qbittorrent
    fi
    sed -e "s/option wan_mode 'false'/option wan_mode 'true'/" -i ./etc/config/dockerman 2>/dev/null
    sed -e 's/config setting/config verysync/' -i ./etc/config/verysync
    sync
    echo "complete."
    echo
fi

echo "Modify the configuration file ... "
rm -f "./etc/rc.local.orig" "./usr/bin/mk_newpart.sh" "./etc/part_size"
rm -rf "./opt/docker" && ln -sf "/mnt/mmcblk2p4/docker" "./opt/docker"
cat > ./etc/fstab <<EOF
UUID=${NEW_ROOT_UUID} / btrfs compress=zstd 0 1
LABEL=EMMC_BOOT /boot vfat defaults 0 2
#tmpfs /tmp tmpfs defaults,nosuid 0 0
EOF

cat > ./etc/config/fstab <<EOF
config global
        option anon_swap '0'
        option anon_mount '1'
        option auto_swap '0'
        option auto_mount '1'
        option delay_root '5'
        option check_fs '0'

config mount
        option target '/overlay'
        option uuid '${NEW_ROOT_UUID}'
        option enabled '1'
        option enabled_fsck '1'
        option fstype 'btrfs'
        option options 'compress=zstd'

config mount
        option target '/boot'
        option label 'EMMC_BOOT'
        option enabled '1'
        option enabled_fsck '0'
        option fstype 'vfat'
                
EOF

rm -f ./etc/bench.log
cat >> ./etc/crontabs/root << EOF
17 3 * * * /etc/coremark.sh
EOF

sed -e 's/ttyAMA0/ttyAML0/' -i ./etc/inittab
sed -e 's/ttyS0/tty0/' -i ./etc/inittab
sss=$(date +%s)
ddd=$((sss/86400))
sed -e "s/:0:0:99999:7:::/:${ddd}:0:99999:7:::/" -i ./etc/shadow
if  [ `grep "sshd:x:22:22" ./etc/passwd | wc -l` -eq 0 ]; then
    echo "sshd:x:22:22:sshd:/var/run/sshd:/bin/false" >> ./etc/passwd
    echo "sshd:x:22:sshd" >> ./etc/group
    echo "sshd:x:${ddd}:0:99999:7:::" >> ./etc/shadow
fi

if [ $BR_FLAG -eq 1 ]; then
    #cp ${P2}/etc/config/passwall_rule/chnroute ./etc/config/passwall_rule/ 2>/dev/null
    #cp ${P2}/etc/config/passwall_rule/gfwlist.conf ./etc/config/passwall_rule/ 2>/dev/null
    sync
    echo "complete."
    echo
fi
eval tar czf .reserved/openwrt_config.tar.gz "${BACKUP_LIST}" 2>/dev/null

rm -f ./etc/part_size ./usr/bin/mk_newpart.sh
if  [ -x ./usr/sbin/balethirq.pl ]; then
    if  grep "balethirq.pl" "./etc/rc.local"; then
        echo "balance irq is enabled"
    else
    echo "enable balance irq"
        sed -e "/exit/i\/usr/sbin/balethirq.pl" -i ./etc/rc.local
    fi
fi
mv ./etc/rc.local ./etc/rc.local.orig

cat > ./etc/rc.local <<EOF
if  [ ! -f /etc/rc.d/*dockerd ]; then
    /etc/init.d/dockerd enable
    /etc/init.d/dockerd start
fi
mv /etc/rc.local.orig /etc/rc.local
exec /etc/rc.local
exit
EOF

chmod 755 ./etc/rc.local*

cd ${WORK_DIR}
 
echo "Start copying data， from [ ${P1} ] to [ /boot ] ..."
cd /boot
echo "Delete the old boot file ..."
cp uEnv.txt /tmp/uEnv.txt
U_BOOT_EMMC=0
[ -f u-boot.emmc ] && U_BOOT_EMMC=1
rm -rf *
echo "complete."
echo "Copy the new boot file ... "
(cd ${P1} && tar cf - . ) | tar xf -
[ $U_BOOT_EMMC -eq 1 ] && cp u-boot.sd u-boot.emmc
rm -f aml_autoscript* s905_autoscript*
sync
echo "complete."
echo

echo "Update boot parameters ... "
if  [ -f /tmp/uEnv.txt ]; then
    lines=$(wc -l < /tmp/uEnv.txt)
    lines=$(( lines - 1 ))
    head -n $lines /tmp/uEnv.txt > uEnv.txt
    cat >> uEnv.txt <<EOF
APPEND=root=UUID=${NEW_ROOT_UUID} rootfstype=btrfs rootflags=compress=zstd console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
EOF
else
    cat > uEnv.txt <<EOF
LINUX=/zImage
INITRD=/uInitrd

FDT=/dtb/amlogic/meson-sm1-x96-max-plus.dtb

APPEND=root=UUID=${NEW_ROOT_UUID} rootfstype=btrfs rootflags=compress=zstd console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
EOF
fi

sync
echo "complete."
echo

cd $WORK_DIR
umount -f ${P1} ${P2}
losetup -D
rmdir ${P1} ${P2}
echo "The upgrade is complete, please [ restart ] the system!"
echo


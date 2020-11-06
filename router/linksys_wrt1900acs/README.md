# OpenWrt for Linksys WRT1900ACS


You can download the OpwnWrt for Linksys WRT1900ACS firmware from [Actions](https://github.com/ophub/op/actions). Such as ` Build OpenWrt for Linksys WRT1900ACS `. Unzip to get the `***.img` file. Or download from [Releases](https://github.com/ophub/op/releases). Such as `OpenWrt_Linksys_WRT1900ACS_${date}`.

This firmware supports Linksys WRT1900ACS v1 & v2 (shelby).

Install OpenWrt: 1. Login to Linksys WebUI (Default IP: 192.168.1.1; Password: admin). 2. `Access Router` (default password: admin) → `connectivity` → `Basic` → `Manual` - `Choose File`, select Install img file: `openwrt-mvebu-cortexa9-linksys_wrt1900acs-squashfs-factory.img`, click `install`, 3. wait for the installation to complete, the router will automatically restart and enter OpenWrt system.

Upgrading OpenWrt: 1. Login to the OpenWrt WebUI (Default IP: 192.168.1.1). 2. `System` → `Backup/Flash Firmware` → `Flash New Firmware Image` → Choose File
Select Sysupgrade bin file: ` openwrt-mvebu-cortexa9-linksys_wrt1900acs-squashfs-sysupgrade.bin `. 3.Untick Keep Settings, then select Flash Image.

The WRT AC series of routers uses a dual firmware flash layout. This means that two separate firmware partitions are included on the device and are flashed in an alternating fashion. If booting from the primary partition, the secondary (or alternate) partition will be flashed on next sysupgrade. The reverse logic is also true. See the Flash Layout section for more details. It is recommended that you keep the original firmware in one of the partitions and install the OPENWRT firmware in the other partition. If necessary, you can switch to the firmware of different partitions.

Enter the following command to view the partition (You can view it from OpenWrt `system menu` > `TTYD terminal`, or Using SSH tools such as `PuTTY` or `MAC Terminal`, etc.): 
```shell script
fw_printenv boot_part     #if it displays: boot_part=2, it means the current firmware is in the second partition. 
fw_setenv boot_part 1     #Enter the command, you can switch to the first partition,  
reboot                    #enter the restart command to enter the firmware.
````

Due to the dual-partition design mechanism of Linksys WRT1900ACS, the contents of another partition will be overwritten every time the firmware is installed (rather than the partition where the currently logged-in firmware is installed), so every time you install or update OpenWrt, ***` please switch to the official firmware partition first. Refer to the installation method to install `***.

If you accidentally install both partitions as OpenWrt and want to restore one partition to the original firmware, you can restore it by referring to the following method:

Sign in to openwrt > `system menu` > `file transfer` > `upload`, and upload [the original firmware file of Linksys wrt1900 ACS](https://www.linksys.com/us/support-article?articleNum=165487) as [FW_WRT1900ACSV2_2.0.3.201002_prod.img](https://downloads.linksys.com/support/assets/firmware/FW_WRT1900ACSV2_2.0.3.201002_prod.img), 
Upload to `/tmp/upload/`, in the `system menu` > `TTYD terminal` > enter the commands in sequence:
```shell script
cd /tmp/upload
sysupgrade -F -n -v FW_WRT1900ACSV2_2.0.3.201002_prod.img
reboot
````

## Compilation method

- Select ***`Build OpenWrt for Linksys WRT1900ACS`*** on the [Action](https://github.com/ophub/op/actions) page.
- Click the ***`Run workflow`*** button.

## Configuration file function description

| Folder/file name | Features |
| ---- | ---- |
| .config | Firmware related configuration, such as firmware kernel, file type, software package, luci-app, luci-theme, etc. |
| files | Create a files directory under the root directory of the warehouse and put the relevant files in. You can use custom files such as network/dhcp/wireless by default when compiling. |
| feeds.conf.default | Just put the feeds.conf.default file into the root directory of the warehouse, it will overwrite the relevant files in the OpenWrt source directory. |
| diy-part1.sh | Execute before updating and installing feeds, you can write instructions for modifying the source code into the script, such as adding/modifying/deleting feeds.conf.default. |
| diy-part2.sh | After updating and installing feeds, you can write the instructions for modifying the source code into the script, such as modifying the default IP, host name, theme, adding/removing software packages, etc. |


## .github/workflow/build-openwrt-linksys_wrt1900acs.yml related environment variable description

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
| GITHUB_REPOSITORY | Github.com Environment variables. The owner and repository name. For example, ophub/op. |
| secrets.GITHUB_TOKEN | 1. Personal center: Settings → Developer settings → Personal access tokens → Generate new token ( Name: GITHUB_TOKEN, Select: public_repo, Copy GITHUB_TOKEN's Value ). 2. Op code center: Settings → Secrets → New secret ( Name: RELEASES_TOKEN, Value: Paste GITHUB_TOKEN's Value ). |

## Firmware compilation parameters

| Option | Value |
| ---- | ---- |
| Target System | marvell EBU Armada |
| Subtarget | Marvell Armada 37x/38x/XP |
| Target Profile | Linksys WRT1900ACS (Shelby) |
| Target Images | squashfs |
| LuCI -> Applications | in the file: .config |


## Firmware information

| Name | Value |
| ---- | ---- |
| Default IP | 192.168.1.1 |
| Default username | root |
| Default password | password |
| Default WIFI name | OpenWrt |
| Default WIFI password | none |

# OpenWrt for x64

You can download the OpwnWrt for x64 firmware from [Actions](https://github.com/ophub/op/actions). Such as, ` Build OpenWrt for x64 `, Unzip to get the `***.img` file. Or download from [Releases](https://github.com/ophub/op/releases). Such as `OpenWrt_X64_${date}`.


The firmware can be followed to [VMware ESXi](https://www.vmware.com/products/esxi-and-esx.html), [Parallels Desktop](http://www.parallels.cn/products/desktop/), [Synology's Virtual Machine Manager](https://www.synology.cn/en-global/dsm/feature/virtual_machine_manager) and other virtual host systems, as well as various physical hosts of x64 architecture. For specific installation methods, please refer to the installation instructions of each system.

VMware ESXi Install OpenWrt firmware conversion commands:
```shell script
sudo apt-get install qemu               #mac: brew install qemu
qemu-img convert -f raw -O vmdk openwrt-x86-64-generic-ext4-combined.img openwrt-x86-64-generic-ext4-combined.vmdk
```

Parallels Desktop Install OpenWrt firmware conversion commands:
```shell script 
sudo apt-get install qemu               #mac: brew install qemu
qemu-img convert -f raw -O vmdk openwrt-x86-64-generic-ext4-combined.vmdk openwrt-x86-64-generic-ext4-combined.hdd
```
Synology's Virtual Machine Manager Install OpenWrt:
```text
Login in to Synology: Virtual Machine Manager → Image → Add → Upload the .img file (openwrt-x86-64-generic-squashfs-combined.img)
```
## Compilation method

- Select ***`Build OpenWrt for x64`*** on the [Action](https://github.com/ophub/op/actions) page.
- Click the ***`Run workflow`*** button.

## Configuration file function description

| Folder/file name | Features |
| ---- | ---- |
| .config | Firmware related configuration, such as firmware kernel, file type, software package, luci-app, luci-theme, etc. |
| files | Create a files directory under the root directory of the warehouse and put the relevant files in. You can use custom files such as network/dhcp/wireless by default when compiling. |
| feeds.conf.default | Just put the feeds.conf.default file into the root directory of the warehouse, it will overwrite the relevant files in the OpenWrt source directory. |
| diy-part1.sh | Execute before updating and installing feeds, you can write instructions for modifying the source code into the script, such as adding/modifying/deleting feeds.conf.default. |
| diy-part2.sh | After updating and installing feeds, you can write the instructions for modifying the source code into the script, such as modifying the default IP, host name, theme, adding/removing software packages, etc. |


## .github/workflow/build-openwrt-x64.yml related environment variable description

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
| Target System | x86 |
| Subtarget | x64 64bit |
| Target Profile | Generic |
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

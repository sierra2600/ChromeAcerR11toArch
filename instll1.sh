
echo "sgdisk is being used to create the partitions"
sgdisk -l /dev/mmcblk0
echo "If No such file or directory appears, there is something wrong"

echo "!!!WARNING!!! This Chromebook will be erased!"
dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=1 status=progress

echo "Creating UEFI Boot partition... (512MB because of compatibility with the old original EFI standard"
sgdisk -n 0:0:+524288K -t 0:ef00 /dev/mmcblk0

echo "Creating 4GiB Swap patition... (Trust me, any web browsing will need this)"
sgdisk -n 0:0:+4194304K -t 0:8200 /dev/mmcblk0

echo "Using the remaining disk for the Linux file system (as the Debian installer says [First time? Put it all in one] Bad idea? Likely)"
sgdisk -n 0:0:0 -t 0:8300 /dev/mmcblk0

echo "fdisk here should say: EFI System at 512M, Linux swap at 4G and Linux filesystem with the remaining disk space"
fdisk -l /dev/mmcblk0

echo "Formatting the UEFI partition with Microshafts FAT32..."
mkfs.vfat -F32 /dev/mmcblk0p1

echo "Formatting the Swap partition..."
mkswap /dev/mmcblk0p2

echo "Formatting the Linux file system partition..."
mkfs.ext4 /dev/mmcblk0p3

echo "mountING the Linux file system..."
mount /dev/mmcblk0p3 /mnt

echo "mAkINGdirECTORIES..."
mkdir -m 0755 -pv /mnt/{boot,dev,etc/systemd/network,home,run,var/{cache/pacman/pkg,lib/pacman,log}}
mkdir -m 0750 -pv /mnt/var/lib/iwd
mkdir -m 0555 -pv /mnt/{proc,sys}
mkdir -m 1777 -pv /mnt/tmp

echo "mountING the UEFI Boot Partiton"
mount /dev/mmcblk0p1 /mnt/boot

echo "Turning on the swap partition for use"
swapon /dev/mmcblk0p2

echo "What is the name of the WIFI device"
iwctl station list | grep disconnected

echo "Turn on the WIFI"
iwctl device wlan0 set-property Powered on && iwctl station wlan0 scan && iwctl station wlan0 get-networks

echo "much editing needed here:"
iwctl station wlan0 connect ESSID
sed '/^Passphrase=/d' /var/lib/iwd/ESSID.psk > /mnt/var/lib/iwd/ESSID.psk
cat > /mnt/etc/systemd/network/any-network-name.network << EOF
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF
ln -sv /mnt/etc/systemd/network/any-network-name.network /etc/systemd/network

systemctl start systemd-networkd && systemctl start systemd-resolved

mkdir -pv /var/lib/pacman/sync

pacstrap -K /mnt base linux linux-firmware intel-ucode iwd dhcpcd nfs-utils base-devel nano networkmanager

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
nano /mnt/etc/fstab # need to add rw,relatime,noatime,nodiratime,discard,errors=remount-ro 0 1

mkdir -pv /mnt/boot/{EFI/systemd,loader/entries}

cp /mnt/lib/systemd/boot/efi/systemd-bootx64.efi /mnt/boot/EFI/systemd

nano /mnt/boot/loader/loader.conf
#default Arch-Linux
#timeout 2

nano /mnt/boot/loader/entries/Arch-Linux.conf
#title Arch Linux
#linux /vmlinuz-linux
#initrd /intel-ucode.img
#initrd /initramfs-linux.img
#options root=/dev/mmcblk0p3 init=/usr/lib/systemd/systemd rw

efibootmgr --create --disk /dev/mmcblk0 --part 1 --loader /EFI/systemd/systemd-bootx64.efi --label "Arch Linux"

systemctl enable iwd systemd-networkd systemd-resolved networkmanager

ln -sfv /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

echo "n07chr0m3b00k" > /etc/hostname

nano /etc/locale.gen

locale-gen

echo "US/Central" > /etc/timezone

hwclock --hctosys --utc

sed -i 's/^#\(FallbackNTP=.\+\)/\1/' /etc/systemd/timesyncd.conf

systemctl enable systemd-timesyncd

sed -i 's/#\(Color\|VerbosePkgLists\)/\1/' /etc/pacman.conf

useradd -m -s /bin/bash -G systemd-journal,wheel -U owner

passwd owner

echo "owner n07chr0m3b00k=(root) /usr/bin/pacman" >> /etc/sudoers
echo "owner n07chr0m3b00k=(root) /usr/bin/su -ls /usr/bin/bash" >> /etc/sudoers

mkinitcpio -P

exit

umount -Rv /mnt

reboot


echo "You are going to want to make sure there is not a SD card inserted in to the computer"

echo "sgdisk is being used to create the partitions"
lsblk
sgdisk -l /dev/mmcblk0

#echo "!!!WARNING!!! This Chromebook will be erased!"
#dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=1 status=progress

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

echo "Turning swapon"
swapon /dev/mmcblk0p2

#Much much much editing is needed from here
echo "What is the name of the WIFI device"
iw dev | awk '$1=="Interface"{print $2}'

echo "Turn on the WIFI if it isn't already"
iwctl station wlan0 scan && iwctl station wlan0 get-networks

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
#to here

mkdir -pv /var/lib/pacman/sync

#Using linux-firmware-intel saves space in the disk and RAM, nano for your sanity (we're not using teletypes so vi/m isn't needed) and NetworkManager because it covers everything (iwd is its assistant for WIFI)
pacstrap -K /mnt base linux linux-firmware-intel intel-ucode base-devel nano networkmanager iwd

#We use -U since this its best to use a UUID to locate partitions raher than throwing caution to the wind guessing what device and partition mmcblk0p3 really is
genfstab -U /mnt >> /mnt/etc/fstab
nano /mnt/etc/fstab #need to add this to mmcblk0p3: rw,relatime,noatime,nodiratime,discard,errors=remount-ro 0 1

mkdir -pv /mnt/boot/{EFI/systemd,loader/entries}

cp /mnt/lib/systemd/boot/efi/systemd-bootx64.efi /mnt/boot/EFI/systemd

#I'm never ever using this ever again, even though it takes up the least amount of space, the mmcblk likes to jump between 0 and 1 even when the external SD card is in
#cat > /mnt/boot/loader/loader.conf << EOF
#default Arch-Linux
#timeout 2
#EOF

#cat > /mnt/boot/loader/entries/Arch-Linux.conf << EOF
#title Arch Linux
#linux /vmlinuz-linux
#initrd /intel-ucode.img
#initrd /initramfs-linux.img
#options root=/dev/mmcblk0p3 init=/usr/lib/systemd/systemd rw
#EOF

#efibootmgr --create --disk /dev/mmcblk0 --part 1 --loader /EFI/systemd/systemd-bootx64.efi --label "Arch Linux"

arch-chroot /mnt

systemctl enable iwd systemd-networkd systemd-resolved NetworkManager

ln -sfv /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

echo "US/Central" > /etc/timezone

echo "n07AChr0m3b00k" > /etc/hostname

sed -i 's/^#\(en_US.UTF-8.\+\)/\1/' /etc/locale.gen && cat /etc/locale.gen | grep en_US && locale-gen

hwclock --hctosys --utc

sed -i 's/^#\(FallbackNTP=.\+\)/\1/' /etc/systemd/timesyncd.conf

systemctl enable systemd-timesyncd

pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB && grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's/#\(Color\|VerbosePkgLists\)/\1/' /etc/pacman.conf

useradd -m -s /bin/bash -G systemd-journal,wheel -U owner

passwd owner

echo "owner n07chr0m3b00k=(root) /usr/bin/pacman" >> /etc/sudoers
echo "owner n07chr0m3b00k=(root) /usr/bin/su -ls /usr/bin/bash" >> /etc/sudoers

mkinitcpio -P

exit

umount -Rv /mnt

reboot

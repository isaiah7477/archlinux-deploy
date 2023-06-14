#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Get block device from user
devicelist=$(lsblk -dplnx size -o name,size | tac)
IFS=$'\n'
PS3="Block device for installation: "
select item in $devicelist; do
	device=$(echo "${item}" | awk '{print $1}')
	[[ ! -z $device ]] && break 
done

# Get hostname from user
while true; do
	printf "Enter hostname: "
	read hostname
	[[ ! -z $hostname ]] && break
done

# Get username from user
while true; do
	printf "Enter username: "
	read username
	[[ ! -z $username ]] && break
done

# Get user password from user
while true; do
	printf "Enter password for \"$username\": "
	read -s userpass
	echo
	printf "Repeat password: "
	read -s userpass2
	echo
	[[ "$userpass" == "$userpass2" ]] && break
	echo "Passwords did not match"
done

# Get root password from user
while true; do
	printf "Enter password for root: "
	read -s rootpass
	echo
	printf "Repeat password: "
	read -s rootpass2
	echo
	[[ "$rootpass" == "$rootpass2" ]] && break
	echo "Passwords did not match"
done

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

echo
echo "REVIEW CONFIG"
echo "------------------------------------------------------------"
echo "Hostname: $hostname"
echo "Username: $username"
echo "Device: $device"

if [[ $(yes_or_no "Proceed with installation?") ]]; then
	echo "Installation aborted"
	exit 1
else
	echo -e "\nStarting installation..."
fi

echo -e "\nCreating partitions..."
parted --script "${device}" -- mklabel msdos \
	mkpart primary ext4 1Mib 100%
mkfs.ext4 /dev/sda1 # Create root filesystem
mount /dev/sda1 /mnt # Mount root partition

echo -e "\nCreating swap file..."
dd if=/dev/zero of=/mnt/swapfile bs=1M count=8K status=progress # Create swap file
chmod 0600 /mnt/swapfile # Set proper permisions on swap file
mkswap -U clear /mnt/swapfile # Format swap file
swapon /mnt/swapfile # Activate the swap file

echo -e "\nGenerating fstab file"
mkdir /mnt/etc/ && touch /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab # Generate fstab file

echo -e "\nInstalling base packages..."
pacstrap -K /mnt base linux linux-firmware grub

arch-chroot /mnt ln -sf /usr/share/zoneinfo/MST /etc/localtime
arch-chroot /mnt hwclock --systohc

# Configure locale
cat >>/mnt/etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
EOF
locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf 

echo "${hostname}" > /mnt/etc/hostname #Set hostname

# Create users and set passwords
arch-chroot /mnt useradd -m -G wheel,uucp,video,audio,storage,input "$username"
echo "$username:$userpass" | chpasswd --root /mnt
echo "root:$rootpass" | chpasswd --root /mnt

echo -e "\nInstalling bootloader..."
arch-chroot /mnt grub-install "${device}" # Install grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg # Generate grub config

echo -e "\nCopying system files..."
cp -r files/* /mnt
chmod 0440 /mnt/etc/sudoers

echo -e "\nInstalling packages..."
arch-chroot /mnt pacman -S --needed --noconfirm - < pkglist.std

echo -e "\nInstallation complete!"

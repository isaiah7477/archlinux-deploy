if [[ -z $(pacman -Qs paru) ]]; then
	echo -e "\nInstalling aur helper..."
	git clone https://aur.archlinux.org/paru.git /tmp/paru
	cd /tmp/paru && makepkg -si --noconfirm
fi

echo -e "\nInstalling packages..."
paru -S --needed --noconfirm - < pkglist.std
paru -S --needed --noconfirm - < pkglist.aur

echo -e "\nUpdate complete!"

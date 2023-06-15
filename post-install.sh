systemctl enable --now \
	NetworkManager.service \
	bluetooth.service \
	sshd.service \
	cups.socket

echo -e "\nInstalling aur packages..."
mkdir $HOME/.builds
git clone https://aur.archlinux.org/paru.git $HOME/.builds/paru
cd /tmp/paru && makepkg -si --noconfirm
paru -S --needed --noconfirm - < pkglist.aur

echo -e "\nInstalling custom builds..."
git clone https://github.com/isaiah7477/dwm.git $HOME/.builds/dwm
cd $HOME/.builds/dwm && sudo make clean install
rm -rf $HOME/.dotfiles $HOME/.dotfiles.old

echo -e "\nCloning dotfiles..."
git clone --bare https://github.com/isaiah7477/dotfiles.git $HOME/.dotfiles
function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
config reset --hard
config checkout
config config status.showUntrackedFiles no

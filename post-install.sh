systemctl enable --now \
	NetworkManager.service \
	bluetooth.service \
	sshd.service \
	cups.socket

echo -e "\nCloning dotfiles..."
mkdir $HOME/dotfiles
git init --bare $HOME/dotfiles
git --git-dir=$HOME/dotfiles --work-tree=$HOME branch -M main
git --git-dir=$HOME/dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
rm -rf .config $HOME/.*
git --git-dir=$HOME/dotfiles --work-tree=$HOME pull --set-upstream https://github.com/isaiah7477/dotfiles

echo -e "\nInstalling aur packages..."
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm
paru -S --needed --noconfirm - < pkglist.aur

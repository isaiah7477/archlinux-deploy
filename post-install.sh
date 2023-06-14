systemctl enable --now NetworkManager.service
systemctl enable --now bluetooth.service
systemctl enable --now sshd.service
systemctl enable --now cups.socket

echo -e "\nCloning dotfiles..."
mkdir $HOME/dotfiles
git init --bare $HOME/dotfiles
cd $HOME/dotfiles && git config init.defaultBranch main
git --git-dir=$HOME/dotfiles --work-tree=$HOME config status.showUntrackedFiles no
rm -rf .config $HOME/.*
git --git-dir=$HOME/dotfiles --work-tree=$HOME pull --set-upstream https://github.com/isaiah7477/dotfiles

echo -e "\nInstalling aur packages..."
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm
paru -S --needed --noconfirm - < pkglist.aur

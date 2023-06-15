rm -rf $HOME/.dotfiles $HOME/.dotfiles.old
git clone --bare https://github.com/isaiah7477/dotfiles.git $HOME/.dotfiles
function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
config reset --hard
config checkout
config config status.showUntrackedFiles no

mkdir $HOME/dotfiles
git init --bare $HOME/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$/HOME'
config config status.showUntrackedFiles no
rm -rf .config $HOME/.*
config pull

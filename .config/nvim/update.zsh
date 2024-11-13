sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
mv -f nvim.appimage $HOME/.local/bin/nvim
sudo chmod u+x $HOME/.local/bin/nvim
cd ~/dotfiles
exec stow --adopt .

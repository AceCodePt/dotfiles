curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo tar -C /home/sagi/dotfiles/.local/bin -xzf nvim-linux64.tar.gz
rm -rf nvim-linux64.tar.gz
mv -f /home/sagi/dotfiles/.local/bin/nvim-linux64 /home/sagi/dotfiles/.local/bin/nvim

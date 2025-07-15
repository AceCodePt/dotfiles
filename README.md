# regular update
```bash
sudo apt-get update
```

# Better terminal
```bash
sudo apt install zsh
chsh -s $(which zsh)
```

# Automatic Stow on commit
In .git/hooks/post-commit
```bash
#!/bin/sh
exec stow --adopt -R .
```

# basic stuff
```bash
sudo apt-get install ripgrep
sudo apt install curl
sudo apt install fzf
```

# install neovim
```bash
sudo apt install neovim
```

# install clipboard tool
```bash
sudo apt-get install xsel
```

# swap capslock and escape
```bash
sudo nano /etc/default/keyboard
```
change -> `XKBOPTIONS="caps:swapescape"`

# pretty esenital stuff
```bash
sudo apt install git
sudo apt install build-essential libssl-dev
```

# install rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

# node version manager
```bash
SHELL=/bin/zsh
curl -fsSL https://fnm.vercel.app/install | bash
```

# lazy git
```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit
rm -rf lazygit.tar.gz

fnm install 22 
```

# Install font
```
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
```

# Install PNPM
```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
echo 'export PNPM_HOME="/home/sagi/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac' >> ~/.zshrc
```

# Install tiling Manager
```bash
sudo apt install i3
```

# Install Docker
```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt install docker.io
sudo apt-get install docker-compose-plugin
systemctl start docker
systemctl enable docker
sudo chmod 666 /var/run/docker.sock
```




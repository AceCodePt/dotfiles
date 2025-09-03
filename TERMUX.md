```bash
cd ~
pkg update -y
pkg upgrade -y
pkg install zsh -y
chsh -s zsh
SHELL=zsh
exec $SHELL
```

```bash
pkg install git make cmake ninja termux-tools gettext libtool unzip ripgrep curl wget fzf rust lazygit which stow pass getconf -y

git clone git@github.com:AceCodePt/dotfiles.git ~/dotfiles
echo "exec stow --adopt -R ." > ~/dotfiles/.git/hooks/post-commit
chmod +x ~/dotfiles/.git/hooks/post-commit
stow --adopt -R .


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
curl -fsSL https://pyenv.run | bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.zshenv

nvm install 22
nvm use 22

pyenv install 3.13
pyenv global 3.13

pip3 install neovim-remote
pnpm install -g yarn
```

# Install font
```bash
curl -o Hack.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
unzip Hack.zip -d Hack-Nerd-Font
mkdir -p ~/.termux
cp Hack-Nerd-Font/HackNerdFont-Regular.ttf ~/.termux/font.ttf
```

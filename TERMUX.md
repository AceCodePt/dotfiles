```bash
cd ~
pkg update -y
yes | pkg upgrade -y
pkg install zsh termux-api -y
chsh -s zsh
termux-setup-storage
cp -R ~/storage/shared/.ssh ~/
SHELL=zsh
exec $SHELL
```

```bash
pkg install git termux-tools build-essential unzip ripgrep curl wget fzf rust lazygit which stow pass getconf zlib golang nodejs neovim -y

git clone git@github.com:AceCodePt/dotfiles.git ~/dotfiles
echo "exec stow --adopt -R ." > ~/dotfiles/.git/hooks/post-commit
chmod +x ~/dotfiles/.git/hooks/post-commit
cd ./dotfiles
stow --adopt .
cd ../


curl -fsSL https://pyenv.run | bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.zshenv

pyenv install 3.12
pyenv global 3.12
pip3 install pipx

pipx install neovim-remote trash-cli
npm install -g yarn @antfu/ni

```

# Install font
```bash
curl -o Hack.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
unzip Hack.zip -d Hack-Nerd-Font
mkdir -p ~/.termux
cp Hack-Nerd-Font/HackNerdFont-Regular.ttf ~/.termux/font.ttf
```

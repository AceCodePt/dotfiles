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

source ~/.zshenv

pip3 install pipx

pipx install neovim-remote trash-cli
npm install -g pnpm yarn @antfu/ni

```

### for unsupported mason languages
```bash
curl -o /data/data/com.termux/files/usr/bin/install-in-mason  https://raw.githubusercontent.com/Amirulmuuminin/setup-mason-for-termux/main/install-in-mason
chmod +x /data/data/com.termux/files/usr/bin/install-in-mason
install-in-mason lua-language-server
```

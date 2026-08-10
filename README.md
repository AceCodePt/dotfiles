# dotfiles

My personal dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/)
and applied automatically on every commit via a `post-commit` hook.

## Target environment

- **OS:** Arch Linux
- **Wayland compositor:** Hyprland (via [Omarchy](https://github.com/omarchy-linux/omarchy))

> Note: Hyprland/Omarchy config lives under `~/.config/hypr/` and is managed by
> Omarchy itself, so it is intentionally **not** stowed from this repo. Any Hyprland
> tweaks should be made through Omarchy, not here.

## How this repo works

Clone into `~/dotfiles` and stow everything into your home directory:

```bash
git clone git@github.com:AceCodePt/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow --adopt .
```

To keep things in sync without thinking about it, a `post-commit` hook re-stows
the tree after every commit. It's already tracked in the repo at
`.git/hooks/post-commit`:

```bash
#!/bin/sh
stow --adopt -R .
```

If you don't already have it enabled, copy it into place:

```bash
echo -e '#!/bin/sh\nexec stow --adopt -R .' > ~/dotfiles/.git/hooks/post-commit
chmod +x ~/dotfiles/.git/hooks/post-commit
```

## Required packages (Arch)

Install these with `pacman` (or your preferred AUR helper) before stowing:

```bash
sudo pacman -S --needed \
  stow git zsh neovim tmux ripgrep fzf curl lazygit direnv \
  wl-clipboard kitty alacritty fontconfig
```

> **nvim-treesitter** on `main` requires `tree-sitter-cli` (≥ 0.26.1) to
> compile parsers, plus a C compiler (`cc`). Install it with your package
> manager, or via cargo when available:
>
> ```bash
> cargo install tree-sitter-cli
> ```

Run `zsh` as the default shell:

```bash
chsh -s "$(which zsh)"
```

### Language toolchains

These are managed by version managers (not by these dotfiles directly):

- **Node:** [fnm](https://github.com/Schniz/fnm) — `curl -fsSL https://fnm.vercel.app/install | bash`
- **Rust:** [rustup](https://rustup.rs) — `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Python:** [pyenv](https://github.com/pyenv/pyenv)
- **Package managers:** pnpm, bun, deno — see `.zshenv` for PATH entries

A lot of these are wired up on shell startup via `.zshenv` / `.zshrc` — the PATH
entries and `eval` hooks are only activated when the relevant binary exists, so
missing tools won't break shell startup.

## What's in here

| Path | What |
|------|------|
| `.zshrc` | Shell config: history, prompt, fzf, custom functions (`gwadd`, `mcd`, `convert_to_webp`, `convert_latest_recording_to_mp4`) |
| `.zshenv` | PATH setup for `~/.local/bin`, pyenv, fnm, pnpm, flutter |
| `.zsh_profile` | Prepends local `scripts/` and a custom nvim bin to PATH |
| `.zsh_alias` | Short aliases (`vim=nvim`, `lg=lazygit`, `ld=lazydocker`, ...) |
| `.config/nvim/` | Neovim config (Lua, lazy.nvim-based) |
| `.config/tmux/tmux.conf` | tmux config (prefix `M-;`, status bar off, focus events) |
| `.config/kitty/`, `.config/alacritty/` | Terminal emulators |
| `.config/lazygit/` | lazygit config |
| `.config/direnv/` | direnv config |
| `.config/fontconfig/` | Fontconfig tweaks |
| `.config/opencode/` | [opencode](https://opencode.ai) AI coding agent config |
| `.config/Vieb/` | Vieb (vim-like browser) config |
| `.config/systemd/` | User systemd units |
| `.local/bin/` | Personal scripts (`speak.sh`, `scripts/tmux-sessionizer`, `scripts/kill-by-port`, ...) |
| `.termux/` | Legacy Termux config (see `TERMUX.md`) |

### Leftover i3 config

`.config/i3/` is a leftover from the old i3 setup and is **not used anymore** —
Hyprland/Omarchy handles window management now. Kept only for reference; safe to
ignore (and eventually delete).

## Notes

- `~/.config/hypr/`, `waybar`, `walker`, `mako`, etc. are managed by Omarchy
  and intentionally excluded from this repo.
- The `wl-copy` placeholder at the repo root is just a stub; install
  `wl-clipboard` from the Arch repos for clipboard support.
- See `TERMUX.md` for setting these dotfiles up on an Android device via Termux.

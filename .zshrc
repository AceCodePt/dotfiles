# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# fnm
export PATH="/home/sagi/.local/share/fnm:$PATH"
eval "`fnm env`"

# Created by `pipx` on 2023-07-06 11:16:21
export PATH="$PATH:/home/sagi/.local/bin"

if [ -d "$HOME/Downloads/android-studio/bin" ] ; then
    export PATH="$PATH:$HOME/Downloads/android-studio/bin"
fi


export PNPM_HOME="/home/sagi/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias pnpx='pnpm dlx'

alias work="cd ~/Desktop/companies"

# bun completions
[ -s "/home/sagi/.bun/_bun" ] && source "/home/sagi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# deno
export DENO_INSTALL="/home/sagi/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# The next lines enables shell command completion for Stripe
fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

# pnpm
export PNPM_HOME="/home/sagi/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

mcd() { mkdir -p "$@" 2> >(sed s/mkdir/mcd/ 1>&2) && cd "$_"; }


convert_to_webp() {
  # Set a default quality level (0-100, higher is better)
  quality=100

  # Check if a custom quality level was provided as an argument
  if [ "$1" ]; then
    quality="$1"
  fi

  # Check if the 'cwebp' command is available
  if ! command -v cwebp &> /dev/null
  then
      echo "cwebp command not found. Please install WebP utilities."
      return 1 # Indicate error
  fi

  # Main loop - Iterate over all files
  for file in *; do
    if [ -f "$file" ]; then # Ensure it's a regular file
      case "${file##*.}" in 
        png|jpg|jpeg)
          output_file="${file%.*}.webp"
          cwebp -q "$quality" "$file" -o "$output_file"
          echo "$file converted to $output_file"
          ;;
        *) 
          echo "Skipping file $file (unsupported extension)" 
          ;;
      esac
    fi
  done
}



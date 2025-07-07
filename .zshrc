convert_latest_recording_to_mp4() {
  dir=~/Videos/Recordings
  latest_file=$(ls -t "$dir" | head -n 1)

  if [ -z "$latest_file" ]; then
    echo "No files found in $dir"
    return 1
  fi

  full_path="$dir/$latest_file"
  extension="${latest_file##*.}"
  filename="${latest_file%.*}"
  output_file="$dir/$filename.mp4"

  # Skip if it's already an mp4
  if [ "$extension" = "mp4" ]; then
    echo "The newest file is already an MP4: $latest_file"
    return 0
  fi

  echo "Converting '$latest_file' to '$output_file'..."
  ffmpeg -i "$full_path" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k "$output_file"
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

source ~/.zsh_profile
source ~/.zsh_alias

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


export PATH=$PATH:$(go env GOPATH)/bin
export PATH="$PATH:$HOME/.local/bin"

if [ -d "$HOME/Downloads/android-studio/bin" ] ; then
    export PATH="$PATH:$HOME/Downloads/android-studio/bin"
fi


alias pnpx='pnpm dlx'

alias work="cd ~/Desktop/companies"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# The next lines enables shell command completion for Stripe
fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
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



if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
  tmux new -A -s main
fi

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

alias ld='lazydocker'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/sagi/Desktop/companies/jutomate/google-cloud-sdk/path.zsh.inc' ]; then . '/home/sagi/Desktop/companies/jutomate/google-cloud-sdk/path.zsh.inc'; fi

export PATH="$PATH:/opt/mssql-tools18/bin"

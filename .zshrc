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

gwadd() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a branch name."
    return 1
  fi

  local RAW="$1"
  local SANITIZED="${(L)RAW}"
  SANITIZED="${SANITIZED//[^a-z0-9]/-}"

  local BRANCH_NAME="$SANITIZED"
  local DIR_NAME="$SANITIZED"
  local DIR_PATH="../$DIR_NAME"

  # 1. Cleanup stale directory if it exists but isn't a registered worktree
  # This prevents 'git worktree add' from failing due to an existing folder
  if [ -d "$DIR_PATH" ] && ! git worktree list | grep -q "$DIR_NAME"; then
    echo "⚠️  Cleaning up stale directory: $DIR_PATH"
    rm -rf "$DIR_PATH"
  fi

  # 2. Create/Add the worktree
  if git rev-parse --verify --quiet "$BRANCH_NAME" >/dev/null; then
    echo "🌿 Branch '$BRANCH_NAME' already exists. Adding worktree..."
    git worktree add "$DIR_PATH" "$BRANCH_NAME"
    if ! git config "branch.$BRANCH_NAME.remote" >/dev/null 2>&1; then
      echo "⚙️  Setting upstream tracking for '$BRANCH_NAME' -> 'origin/$BRANCH_NAME'..."
      git branch --set-upstream-to="origin/$BRANCH_NAME" "$BRANCH_NAME" 2>/dev/null || \
        echo "⚠️  Could not set upstream (origin/$BRANCH_NAME may not exist yet)."
    fi
  else
    echo "✨ Creating new branch '$BRANCH_NAME' and worktree..."
    git worktree add "$DIR_PATH" -b "$BRANCH_NAME"
  fi

  # 3. Provide absolute path for the Agent/User to switch context
  local ABS_PATH=$(cd "$DIR_PATH" && pwd)
  echo "✅ Worktree initialized at: $ABS_PATH"
  echo "👉 ACTION: cd $ABS_PATH"
}


export PATH="$PATH:$HOME/.local/bin"

export KEYTIMEOUT=1

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'V' edit-command-line

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

source ~/.zsh_profile
source ~/.zsh_alias

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory interactive_comments

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

if [ -d "$HOME/Downloads/android-studio/bin" ] ; then
    export PATH="$PATH:$HOME/Downloads/android-studio/bin"
fi


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


eval "$(direnv hook zsh)"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/sagi/Desktop/companies/jutomate/google-cloud-sdk/path.zsh.inc' ]; then . '/home/sagi/Desktop/companies/jutomate/google-cloud-sdk/path.zsh.inc'; fi

export PATH="$PATH:/opt/mssql-tools18/bin"
eval "$(mise activate zsh)"

export PATH="$PATH:$(go env GOPATH)/bin"

export PATH="/home/sagi/.cargo/bin:$PATH"

# opencode
export PATH=/home/sagi/.opencode/bin:$PATH

# Always start the opencode TUI with an HTTP port, so it can be observed.
#
# `opencode --help` claims `--port [default: 0]`, but that is misleading: omitting
# the flag starts NO server. Verified on 1.18.13 - a TUI launched as plain
# `opencode` has no listening socket, no unix socket, and no lock file, and its
# pending approvals live only in TUI memory (the `permission` table stays empty).
# Such a session cannot be inspected at all; only relaunching helps.
#
# Passing `--port 0` explicitly binds 4096 when free and an ephemeral port
# otherwise, so concurrent TUIs never collide.
#
# Subcommands are passed through untouched: `serve` takes its own --port, and the
# others have no use for one.
opencode() {
  case "${1-}" in
    completion|acp|mcp|attach|run|debug|providers|auth|agent|upgrade|uninstall|\
serve|web|models|stats|export|import|github|pr|session|plugin|plug|db|\
-h|--help|-v|--version)
      command opencode "$@"
      return
      ;;
  esac
  # Respect an explicit --port if the caller already passed one.
  if [[ "$*" == *--port* ]]; then
    command opencode "$@"
    return
  fi
  command opencode --port 0 "$@"
}

alias speak="$HOME/.local/bin/speak.sh"

. "$HOME/.local/share/../bin/env"


# export PATH=/home/sagi/bin:$PATH

# [[ -e "/home/sagi/lib/oracle-cli/lib/python3.12/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/sagi/lib/oracle-cli/lib/python3.12/site-packages/oci_cli/bin/oci_autocomplete.sh"

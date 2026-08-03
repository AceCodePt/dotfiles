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

eval "$(fzf --zsh)"

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



export PATH="$PATH:$HOME/go/bin"

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


command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v mise >/dev/null && eval "$(mise activate zsh)"

# Termux
alias shared='cd ~/storage/shared'
alias clip='termux-clipboard-set'
alias paste='termux-clipboard-get'
alias bat='termux-battery-status'

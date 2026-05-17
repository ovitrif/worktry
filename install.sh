#!/bin/bash

set -e

INSTALL_BIN="$HOME/.local/bin"
INSTALL_SHARE="$HOME/.local/share/worktry"
COMPLETION_DIR="$INSTALL_SHARE/completions"

# Ensure directory exists
mkdir -p "$INSTALL_BIN"
mkdir -p "$COMPLETION_DIR"

# Install script
echo "Installing wk to $INSTALL_BIN..."
cp src/wk "$INSTALL_BIN/wk"
chmod +x "$INSTALL_BIN/wk"

# Create worktry symlink
ln -sf "$INSTALL_BIN/wk" "$INSTALL_BIN/worktry"

# Install shell completions
echo "Installing completions to $COMPLETION_DIR..."
cp completions/wk.bash "$COMPLETION_DIR/wk.bash"
cp completions/wk.zsh "$COMPLETION_DIR/wk.zsh"

# Shell function
SHELL_FUNC='# wk (worktry) - cd wrapper for navigation commands
wk() {
  if [[ "$1" == "go" || "$1" == "back" || "$1" == "b" || "$1" =~ ^[0-9]$ ]]; then
    local target
    target=$(command wk "$@")
    if [[ -d "$target" ]]; then
      cd "$target" && echo "→ $target"
    fi
  else
    command wk "$@"
  fi
}
alias worktry=wk'

completion_source_line() {
  local shell_name="$1"

  case "$shell_name" in
    zsh)
      echo '[ -f "$HOME/.local/share/worktry/completions/wk.zsh" ] && source "$HOME/.local/share/worktry/completions/wk.zsh"'
      ;;
    bash)
      echo '[ -f "$HOME/.local/share/worktry/completions/wk.bash" ] && source "$HOME/.local/share/worktry/completions/wk.bash"'
      ;;
  esac
}

add_completion_source() {
  local rc_file="$1"
  local shell_name="$2"
  local source_line

  source_line=$(completion_source_line "$shell_name")
  [ -z "$source_line" ] && return

  if grep -q "worktry/completions/wk.${shell_name}" "$rc_file" 2>/dev/null; then
    echo "✓ Completions already sourced in $rc_file"
  else
    echo "" >> "$rc_file"
    echo "# wk completions" >> "$rc_file"
    echo "$source_line" >> "$rc_file"
    echo "✓ Added completions to $rc_file"
    echo "  Run 'source $rc_file' or restart your terminal to use completions"
  fi
}

# Detect shell rc file
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
  RC_FILE="$HOME/.zshrc"
  SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
  RC_FILE="$HOME/.bashrc"
  SHELL_NAME="bash"
else
  RC_FILE=""
  SHELL_NAME=""
fi

# Add shell function if not already present
if [ -n "$RC_FILE" ]; then
  # Check for wk() or old worktry() function
  if grep -qE "^(wk|worktry)\(\)" "$RC_FILE" 2>/dev/null || grep -q "# wk (worktry)" "$RC_FILE" 2>/dev/null; then
    echo "✓ Shell function already exists in $RC_FILE"
  else
    echo ""
    echo "Navigation commands (wk go/back/0-9) require a shell function."
    if [ -t 0 ]; then
      read -p "Add shell function to $RC_FILE? [Y/n] " -n 1 -r
      echo
    else
      REPLY=""
      echo "No interactive stdin; adding shell function to $RC_FILE by default."
    fi
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      echo "" >> "$RC_FILE"
      echo "$SHELL_FUNC" >> "$RC_FILE"
      echo "✓ Added wk function to $RC_FILE"
      echo "  Run 'source $RC_FILE' or restart your terminal to use navigation commands"
    else
      echo "Skipped. To add manually, append to $RC_FILE:"
      echo ""
      echo "$SHELL_FUNC"
    fi
  fi

  add_completion_source "$RC_FILE" "$SHELL_NAME"
else
  echo ""
  echo "Could not detect shell rc file. Add this function to your shell config:"
  echo ""
  echo "$SHELL_FUNC"

  if [ -f "$COMPLETION_DIR/wk.bash" ] || [ -f "$COMPLETION_DIR/wk.zsh" ]; then
    echo ""
    echo "To enable completions, source the file for your shell:"
    echo "  source ~/.local/share/worktry/completions/wk.bash"
    echo "  source ~/.local/share/worktry/completions/wk.zsh"
  fi
fi

echo ""
echo "✓ wk installed to $INSTALL_BIN (with 'worktry' alias and completions)"
echo ""
echo "Make sure '$INSTALL_BIN' is in your PATH."

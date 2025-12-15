#!/bin/bash

set -e

INSTALL_BIN="$HOME/.local/bin"

# Ensure directory exists
mkdir -p "$INSTALL_BIN"

# Install script
echo "Installing wk to $INSTALL_BIN..."
cp src/wk "$INSTALL_BIN/wk"
chmod +x "$INSTALL_BIN/wk"

# Create worktry symlink
ln -sf "$INSTALL_BIN/wk" "$INSTALL_BIN/worktry"

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

# Detect shell rc file
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
  RC_FILE="$HOME/.bashrc"
else
  RC_FILE=""
fi

# Add shell function if not already present
if [ -n "$RC_FILE" ]; then
  # Check for wk() or old worktry() function
  if grep -qE "^(wk|worktry)\(\)" "$RC_FILE" 2>/dev/null || grep -q "# wk (worktry)" "$RC_FILE" 2>/dev/null; then
    echo "✓ Shell function already exists in $RC_FILE"
  else
    echo ""
    echo "Navigation commands (wk go/back/0-9) require a shell function."
    read -p "Add shell function to $RC_FILE? [Y/n] " -n 1 -r
    echo
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
else
  echo ""
  echo "Could not detect shell rc file. Add this function to your shell config:"
  echo ""
  echo "$SHELL_FUNC"
fi

echo ""
echo "✓ wk installed to $INSTALL_BIN (with 'worktry' alias)"
echo ""
echo "Make sure '$INSTALL_BIN' is in your PATH."

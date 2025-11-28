#!/bin/bash

set -e

INSTALL_BIN="$HOME/.local/bin"
INSTALL_WORKFLOWS="$HOME/.warp/workflows"

# Ensure directories exist
mkdir -p "$INSTALL_BIN"
mkdir -p "$INSTALL_WORKFLOWS"

# Install script
echo "Installing worktry to $INSTALL_BIN..."
cp src/worktry "$INSTALL_BIN/worktry"
chmod +x "$INSTALL_BIN/worktry"

# Install workflow
echo "Installing workflow to $INSTALL_WORKFLOWS..."
cp workflows/worktry.yaml "$INSTALL_WORKFLOWS/worktry.yaml"

# Shell function for cd support (go/back commands)
SHELL_FUNC='# worktry - cd wrapper for navigation commands
worktry() {
  if [[ "$1" == "go" || "$1" == "back" ]]; then
    local target
    target=$(command worktry "$@")
    if [[ -d "$target" ]]; then
      cd "$target" && echo "→ $target"
    fi
  else
    command worktry "$@"
  fi
}'

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
  if ! grep -q "worktry()" "$RC_FILE" 2>/dev/null; then
    echo ""
    echo "Adding shell function to $RC_FILE for 'worktry go/back' commands..."
    echo "" >> "$RC_FILE"
    echo "$SHELL_FUNC" >> "$RC_FILE"
    echo "✓ Added worktry function to $RC_FILE"
    echo "  Run 'source $RC_FILE' or restart your terminal to use 'worktry go/back'"
  else
    echo "✓ Shell function already exists in $RC_FILE"
  fi
fi

echo ""
echo "Success! 'worktry' has been installed."
echo "Make sure '$INSTALL_BIN' is in your PATH."

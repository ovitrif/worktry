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

echo "Success! 'worktry' has been installed."
echo "Make sure '$INSTALL_BIN' is in your PATH."

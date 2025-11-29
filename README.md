# 🌳 worktry

> Companion tool for [worktree-cli](https://github.com/johnlindquist/worktree-cli) (`wt`) — quick navigation, config file copying, and Claude Code setup for git worktrees.

## ⚡ Quick Start

```bash
# Install worktree-cli (if not already)
npm install -g @johnlindquist/worktree

# Install worktry
git clone https://github.com/ovitrif/worktry.git
cd worktry && ./install.sh

# In your project
cd your-project
worktry init              # Setup worktrees.json
worktry keep              # Edit files to copy (.env, .idea/, etc.)
wt setup feature -c       # Create worktree with setup
worktry 1                 # Jump to worktree
worktry 0                 # Jump back to main
```

## 🤔 What is this?

**worktry** extends [worktree-cli](https://github.com/johnlindquist/worktree-cli) with:

- 🔧 **Auto-setup** — Creates `worktrees.json` config for `wt setup`
- 📁 **File copying** — Copies `.env`, `.idea/`, and other gitignored files to new worktrees
- 🤖 **Claude Code** — Auto-creates `.claude/settings.local.json` with sensible permissions
- 🚀 **Fast navigation** — Jump between worktrees with `worktry 0`, `worktry 1`, etc.

## 📦 Installation

### Prerequisites

- [worktree-cli](https://github.com/johnlindquist/worktree-cli) (`npm install -g @johnlindquist/worktree`)
- `~/.local/bin` in your PATH

### Install

```bash
git clone https://github.com/ovitrif/worktry.git
cd worktry
./install.sh
```

This installs:
- `worktry` script to `~/.local/bin/`
- Shell function to `~/.zshrc` (or `~/.bashrc`) for navigation
- Warp workflow to `~/.warp/workflows/`

## 📖 Usage

### 1. Initialize a repo

```bash
cd your-project
worktry init    # or: worktry i
```

Creates:
- `worktrees.json` — Config for `wt setup`
- `.worktree-setup.sh` — Setup script (Claude permissions + file copying)
- `.worktreekeep` — List of files to copy

### 2. Configure files to copy

```bash
worktry keep    # or: worktry k
```

Edit `.worktreekeep` to list files/directories:

```
.env
local.properties
.idea/
keystore.properties
```

### 3. Create worktrees

```bash
wt setup feature-name -c
```

Creates a worktree with:
- New branch `feature-name`
- `.claude/settings.local.json` with permissions
- Copies of files from `.worktreekeep`

### 4. Navigate

```bash
worktry 1                 # Jump to first worktree
worktry 2                 # Jump to second worktree
worktry 0                 # Jump back to main
worktry go feature-name   # Jump by branch name
worktry back              # Jump back to main (alias for 0)
```

## 🛠️ Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `worktry init` | `i` | Initialize repo with worktrees.json |
| `worktry go <name>` | — | Navigate to worktree by branch name |
| `worktry back` | `b` | Navigate back to main worktree |
| `worktry list` | `ls`, `l` | List all worktrees |
| `worktry keep` | `k` | Edit .worktreekeep file |
| `worktry new <name> [base]` | `n` | Create worktree directly |
| `worktry 0-9` | — | Navigate to worktree by index |
| `worktry --help` | `-h` | Show help |

## 📁 Files

| File | Description |
|------|-------------|
| `worktrees.json` | Config read by `wt setup` |
| `.worktree-setup.sh` | Runs in new worktrees (creates `.claude/`, copies files) |
| `.worktreekeep` | Files/dirs to copy (one per line, relative paths) |

## 🤝 Contributing

Contributions welcome! Feel free to:

1. Fork the repo
2. Create a feature branch
3. Submit a PR

## 📄 License

[The Unlicense](https://unlicense.org) — Public domain. Do whatever you want.

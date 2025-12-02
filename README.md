# 🌳 worktry

> Work on multiple features in parallel with AI agents and git worktrees.

![worktry screenshot](doc/img/worktry.png)

## 🤔 Why?

Work on multiple features in parallel — each in its own isolated worktree, each with Claude Code ready to go.

**worktry** sets up your repo for parallel AI development:
- 🤖 Auto-configures Claude Code permissions in each worktree
- 📁 Copies config files (`.env`, `.idea/`) to new worktrees
- 🚀 Jump between worktrees instantly (`worktry 1`, `worktry 2`, etc.)

## ⚡ Quick Start

```bash
# Install dependencies
npm install -g @johnlindquist/worktree

# Install worktry
git clone https://github.com/ovitrif/worktry.git
cd worktry && ./install.sh

# In your project
cd your-project
worktry init              # Setup worktrees.json
wt setup feature -c       # Create worktree with setup
worktry 1                 # Jump to worktree
worktry 0                 # Jump back to main
```

## 📦 Installation

### Prerequisites

- **Node.js** (v18+) — [nodejs.org](https://nodejs.org)
- **worktree-cli** — `npm install -g @johnlindquist/worktree`
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

### 1. Initialize A Repo

```bash
cd your-project
worktry init    # or: worktry i
```

Creates:
- `worktrees.json` — Config for `wt setup`
- `.worktree-setup.sh` — Setup script (Claude permissions + file copying)
- `.worktreekeep` — List of files to copy

### 2. Configure Files To Copy

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

### 3. Create Worktrees

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
| `worktry new <name> [-b BASE]` | `n` | Create worktree directly with optional base branch |
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

### AI Agents

This project supports vibe-coding with AI agents. See [AGENTS.md](AGENTS.md) for project context and coding rules.

## 📄 License

[The Unlicense](https://unlicense.org) — Public domain. Do whatever you want.

See [LICENSE](LICENSE).

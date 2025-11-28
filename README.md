# worktry

Companion tool for [@johnlindquist/worktree](https://github.com/johnlindquist/worktree-cli) (`wt`) that sets up Claude Code permissions and copies config files to new worktrees.

## Features

- **Claude Code setup** - Automatically creates `.claude/settings.local.json` with permissions
- **Config file copying** - Copy `.env`, `.idea/`, and other gitignored files to new worktrees
- **Navigation** - Quick `cd` to worktrees and back

## Installation

```bash
git clone https://github.com/ovitrif/worktry.git
cd worktry
./install.sh
```

This installs:
- `worktry` script to `~/.local/bin/`
- Shell function to `~/.zshrc` (or `~/.bashrc`) for navigation commands

Make sure `~/.local/bin` is in your PATH.

## Prerequisites

- [@johnlindquist/worktree](https://github.com/johnlindquist/worktree-cli) installed globally:
  ```bash
  npm install -g @johnlindquist/worktree
  ```

## Usage

### Initialize a repo

```bash
cd your-project
worktry init
```

This creates:
- `worktrees.json` - Config for `wt setup`
- `.worktree-setup.sh` - Setup script that runs in new worktrees
- `.worktreekeep` - List of files to copy to new worktrees

### Configure files to copy

Edit `.worktreekeep` to list files/directories to copy:

```
# Files/directories to copy to new worktrees
.env
local.properties
.idea/
keystore.properties
```

### Create a worktree

```bash
wt setup feature-name -c
```

This creates a new worktree with:
- A new branch `feature-name`
- `.claude/settings.local.json` with permissions
- Copies of files listed in `.worktreekeep`

### Navigate between worktrees

```bash
worktry go feature-name   # cd to worktree
worktry back              # cd back to main repo
worktry list              # list all worktrees
```

## Commands

| Command | Description |
|---------|-------------|
| `worktry init` | Initialize repo with worktree setup files |
| `worktry go <name>` | Navigate to worktree by branch name |
| `worktry back` | Navigate back to main worktree |
| `worktry list` | List all worktrees |
| `worktry new <name> [base]` | Create worktree directly (legacy) |
| `worktry -h, --help` | Show help |

## Files

| File | Description |
|------|-------------|
| `worktrees.json` | Config for `wt setup` command |
| `.worktree-setup.sh` | Script that runs in new worktrees |
| `.worktreekeep` | List of files to copy (one per line) |

## License

MIT

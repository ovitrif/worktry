# Worktry (wk CLI)

Manage parallel Claude Code sessions with git worktrees or clones.

```
██╗     ██╗                   ██╗   ██████████╗
██║     ██║                   ██║   ╚═══██╔═══╝
██║ ██╗ ██║  ██████╗  ██████╗ ██║ ██╗   ██║  ██████╗ ██╗   ██╗
██║████╗██║ ██╚═══██║ ██╔═══╝ █████╔╝   ██║  ██╔═══╝  ██╗ ██╔╝
 ███║ ███╔╝  ██████╔╝ ██║     ██╔═██╗   ██║  ██║       ████╔╝
 ╚══╝ ╚══╝   ╚═════╝  ╚═╝     ╚═╝ ╚═╝   ╚═╝  ╚═╝        ██╔╝
 ██ Vibe code in parallel using git worktrees or clones ██║
 █████████████████████████████████████████████████████████║
 ╚════════════════════════════════════════════════════════╝
```

## 🤔 Why?

Claude Code has built-in worktree support (`claude -w`), but **wk** adds what's missing:

- 🚀 Jump between worktrees or clones instantly (`wk 1`, `wk 2`, etc.)
- 📁 Copy config files (`.env`, `.idea/`) to new worktrees/clones via `.worktreeinclude`
- 🔀 Clone mode for repos that don't work well with worktrees
- 🤖 Auto-configures Claude Code permissions in each worktree/clone

Worktrees are created at `.claude/worktrees/<name>` — the same location Claude Code uses.

## ⚡ Quick Start

```bash
# Install wk
git clone https://github.com/ovitrif/worktry.git
cd worktry && ./install.sh

# In your project (worktree mode)
cd your-project
wk init                   # Setup .worktreeinclude
wk config                 # Edit files to copy
wk new feature            # Create worktree with setup
wk 1                      # Jump to worktree
wk 0                      # Jump back to main

# Or for clone mode
wk init --clone           # Setup for clones
gh repo clone user/repo repo-2
wk setup ../repo-2        # Apply setup to clone
```

## 📦 Installation

### Prerequisites

- **git**
- `~/.local/bin` in your PATH

### Install

```bash
git clone https://github.com/ovitrif/worktry.git
cd worktry
./install.sh
```

This installs:
- `wk` script to `~/.local/bin/` (with `worktry` alias)
- Shell function to `~/.zshrc` (or `~/.bashrc`) for navigation

## 📖 Usage

### 1. Initialize A Repo

```bash
cd your-project
wk init           # Worktree mode (default)
wk init --clone   # Clone mode
```

**Worktree mode** creates:
- `.worktreeinclude` — Patterns for files to copy (gitignore-style)
- `.worktree-setup.sh` — Setup script (Claude permissions + file copying)

**Clone mode** creates the same files, without worktree-specific hooks.

### 2. Configure Files To Copy

```bash
wk config    # or: wk c
```

Edit `.worktreeinclude` with gitignore-style patterns:

```
# Files to copy to new worktrees/clones
# Files must ALSO be in .gitignore to be copied

.env
.env.local
.env.*
.idea/
**/.claude/settings.local.json
```

**Note:** Only files matching BOTH `.worktreeinclude` AND `.gitignore` are copied. This prevents accidentally duplicating tracked files.

### 3. Create Worktrees

```bash
wk new feature-name              # From current HEAD
wk new feature-name -b develop   # From specific branch
```

Creates a worktree at `.claude/worktrees/feature-name` with:
- New branch `feature-name`
- `.claude/settings.local.json` with Claude Code permissions
- Copies of files matching `.worktreeinclude`

### 4. Setup Existing Clones

If you prefer cloning over worktrees:

```bash
gh repo clone user/repo repo-2    # Clone manually
wk setup ../repo-2                # Apply wk setup to clone
```

### 5. Navigate

```bash
wk 0                      # Jump to main repo
wk 1                      # Jump to first worktree/clone
wk 2                      # Jump to second worktree/clone
wk go feature-name        # Jump by branch name (worktree mode)
wk back                   # Jump back to main (alias: b)
```

## 🛠️ Commands

| Command | Alias | Description |
|---------|-------|--------------|
| `wk init` | `i` | Initialize for worktree mode |
| `wk init --clone` | `i -c` | Initialize for clone mode |
| `wk list` | `ls`, `l` | List worktrees or clones |
| `wk go <name>` | — | Navigate to worktree by branch name |
| `wk back` | `b` | Navigate back to main worktree |
| `wk config` | `c` | Edit .worktreeinclude config |
| `wk setup <dir>` | `s` | Apply wk setup to a clone |
| `wk new <name> [-b BASE]` | `n` | Create worktree with setup |
| `wk 0-9` | — | Navigate to worktree/clone by index |
| `wk --help` | `-h` | Show help |

> **Note:** `worktry` is also available as an alias for `wk`.

## 📁 Files

| File | Description |
|------|-------------|
| `.worktreeinclude` | Patterns for files to copy (gitignore-style) |
| `.worktree-setup.sh` | Setup script (Claude permissions, file copying) |

## 🤝 Contributing

Contributions welcome! Feel free to:

1. Fork the repo
2. Create a feature branch
3. Submit a PR

See [AGENTS.md](AGENTS.md) for project context and coding rules.

## 📄 License

[The Unlicense](https://unlicense.org) — Public domain. Do whatever you want.

See [LICENSE](LICENSE).

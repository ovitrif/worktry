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

![worktry screenshot](doc/img/screenshot.png)

## 🤔 Why?

Work on multiple features in parallel — each in its own isolated worktree or clone, with Claude Code ready to go.

**worktry** sets up your repo for parallel AI development:
- 🤖 Auto-configures Claude Code permissions in each worktree/clone
- 📁 Copies config files (`.env`, `.idea/`) to new worktrees/clones
- 🚀 Jump between worktrees or clones instantly (`worktry 1`, `worktry 2`, etc.)

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
worktry config            # Add files to copy-over list
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
- `worktrees.json` — Config for `wt setup` + `copy-over` list
- `.worktree-setup.sh` — Setup script (Claude permissions + file copying)

### 2. Configure Files To Copy

```bash
worktry config    # or: worktry c
```

Edit the `copy-over` array in `worktrees.json`:

```json
{
  "setup-worktree": ["bash $ROOT_WORKTREE_PATH/.worktree-setup.sh"],
  "copy-over": [
    ".env",
    "local.properties",
    ".idea/"
  ]
}
```

### 3. Create Worktrees

```bash
wt setup feature-name -c
```

Creates a worktree with:
- New branch `feature-name`
- `.claude/settings.local.json` with permissions
- Copies of files from `copy-over` list

### 4. Setup Existing Clones

If you prefer cloning over worktrees:

```bash
gh repo clone user/repo repo-2    # Clone manually
worktry setup ../repo-2           # Apply worktry setup to clone
```

### 5. Navigate

```bash
worktry 0                 # Jump to main repo
worktry 1                 # Jump to first worktree/clone
worktry 2                 # Jump to second worktree/clone
worktry go feature-name   # Jump by branch name (worktree mode)
worktry back              # Jump back to main (alias: b)
```

## 🛠️ Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `worktry init` | `i` | Initialize repo for worktry |
| `worktry list` | `ls`, `l` | List worktrees or clones |
| `worktry go <name>` | — | Navigate to worktree by branch name |
| `worktry back` | `b` | Navigate back to main worktree |
| `worktry config` | `c` | Edit worktrees.json config |
| `worktry setup <dir>` | `s` | Apply worktry setup to a clone |
| `worktry new <name> [-b BASE]` | `n` | Create worktree with setup |
| `worktry 0-9` | — | Navigate to worktree/clone by index |
| `worktry --help` | `-h` | Show help |

## 📁 Files

| File | Description |
|------|-------------|
| `worktrees.json` | Config for `wt setup` + `copy-over` list |
| `.worktree-setup.sh` | Setup script (Claude permissions, file copying) |

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

# Worktry (wk CLI)

Run parallel Claude Code sessions using git worktrees or clones.

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

## Why?

`claude -w` creates worktrees. `wk` adds navigation between them, config file copying, and clone support.

- Jump between worktrees or clones by index (`wk 1`, `wk 2`)
- Copy `.env`, `.idea/`, and other config files to new worktrees via `.worktreeinclude`
- Clone mode for repos where worktrees don't work well
- Set up Claude Code permissions in each worktree/clone

Worktrees go in `.claude/worktrees/<name>` -- same place Claude Code puts them.

## Quick start

```bash
# Install
git clone https://github.com/ovitrif/worktry.git
cd worktry && ./install.sh

# In your project
cd your-project
wk init                   # creates .worktreeinclude
wk config                 # edit which files get copied
wk new feature            # create worktree
wk 1                      # jump to it
wk 0                      # jump back

# Clone mode
wk init --clone
gh repo clone user/repo repo-2
wk setup ../repo-2
```

## Install

You need `git` and `~/.local/bin` in your PATH.

```bash
git clone https://github.com/ovitrif/worktry.git
cd worktry
./install.sh
```

This puts `wk` in `~/.local/bin/` (with a `worktry` alias) and adds a shell function to your `.zshrc` or `.bashrc` for navigation.

## Usage

### Initialize a repo

```bash
cd your-project
wk init           # worktree mode (default)
wk init --clone   # clone mode
```

Both create `.worktreeinclude` (patterns for files to copy) and `.worktree-setup.sh` (setup script that runs in new worktrees/clones).

### Configure files to copy

```bash
wk config    # or: wk c
```

Edit `.worktreeinclude` with gitignore-style patterns:

```
# Files must ALSO be in .gitignore to be copied
.env
.env.local
.env.*
.idea/
**/.claude/settings.local.json
```

Files must match both `.worktreeinclude` and `.gitignore` to be copied.

### Create worktrees

```bash
wk new feature-name              # from current HEAD
wk new feature-name -b develop   # from a specific branch
```

Creates a worktree at `.claude/worktrees/feature-name` with a new branch. Copies config files and sets up Claude Code permissions.

### Set up existing clones

If you'd rather clone than use worktrees:

```bash
gh repo clone user/repo repo-2
wk setup ../repo-2
```

### Navigate

```bash
wk 0                      # main repo
wk 1                      # first worktree/clone
wk 2                      # second worktree/clone
wk go feature-name        # by branch name
wk back                   # back to main (alias: b)
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `wk init` | `i` | Initialize for worktree mode |
| `wk init --clone` | `i -c` | Initialize for clone mode |
| `wk list` | `ls`, `l` | List worktrees or clones |
| `wk go <name>` | -- | Go to worktree by branch name |
| `wk back` | `b` | Back to main worktree |
| `wk config` | `c` | Edit .worktreeinclude |
| `wk setup <dir>` | `s` | Apply setup to a clone |
| `wk new <name> [-b BASE]` | `n` | Create worktree with setup |
| `wk 0-9` | -- | Go to worktree/clone by index |
| `wk --help` | `-h` | Show help |

`worktry` works as an alias for `wk`.

## Files

| File | What it does |
|------|-------------|
| `.worktreeinclude` | Gitignore-style patterns for files to copy |
| `.worktree-setup.sh` | Runs on new worktrees/clones (permissions + file copying) |

## Contributing

PRs welcome. See [AGENTS.md](AGENTS.md) for coding rules.

## License

[The Unlicense](https://unlicense.org) -- public domain.

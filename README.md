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
wk new feature            # create worktree (auto-creates .worktreeinclude)
wk 1                      # jump to it
wk 0                      # jump back

# Or clone instead
wk clone                  # create sibling clone with setup
wk clone -m ../existing   # apply setup to existing clone
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

### Configure files to copy

```bash
wk config    # or: wk c
```

Edit `.worktreeinclude` with gitignore-style patterns (auto-created if missing):

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

### Create clones

```bash
wk clone                  # auto-named sibling (repo-2, repo-3, etc.)
wk clone my-feature       # named sibling clone
wk clone -m ../repo-2     # apply setup to existing clone
```

Clones from `origin` as a sibling directory with Claude Code permissions and config files copied over.

### Navigate

```bash
wk 0                      # main repo
wk 1                      # first worktree/clone
wk 2                      # second worktree/clone
wk go feature-name        # by branch name
wk back                   # back to main (alias: b)
wk ls                     # list everything with indices
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `wk new <name> [-b BASE]` | `n` | Create worktree with setup |
| `wk clone [name]` | `cl` | Clone repo as sibling with setup |
| `wk clone -m <dir>` | -- | Apply setup to existing clone |
| `wk list` | `ls`, `l` | List all worktrees and clones |
| `wk go <name>` | -- | Go to worktree by branch name |
| `wk back` | `b` | Back to main worktree |
| `wk config` | `c` | Edit .worktreeinclude |
| `wk 0-9` | -- | Go to worktree/clone by index |
| `wk --help` | `-h` | Show help |

`worktry` works as an alias for `wk`.

## Files

| File | What it does |
|------|-------------|
| `.worktreeinclude` | Gitignore-style patterns for files to copy (auto-created) |

## Contributing

PRs welcome. See [AGENTS.md](AGENTS.md) for coding rules.

## License

[The Unlicense](https://unlicense.org) -- public domain.

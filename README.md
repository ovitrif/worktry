# Worktry (wk CLI)

Run parallel AI agent sessions using git worktrees or sibling clones.

AI coding agents are easier to run in parallel when every session has its own checkout, branch, ignored config, and local permissions. `wk` is a small setup and navigation layer for those agent workspaces.

- Create isolated worktrees or sibling clones for parallel agent sessions
- Jump between worktrees or clones by index (`wk 1`, `wk 2`)
- Pick source repos, source branches, and target branch names without leaving your shell
- Copy `.env`, `.idea/`, and other ignored config files via `.worktreeinclude`
- Set up Claude Code local permissions in each workspace

Worktrees go in `.claude/worktrees/<name>` under the selected repo, matching Claude Code's `claude -w` layout. Clone mode covers repos or tools that behave better with full sibling checkouts.

Forgot how it works? Run `worktry`, `wk`, or `wk --help`.

```sh
██╗     ██╗                   ██╗   ██████████╗
██║     ██║                   ██║   ╚═══██╔═══╝
██║ ██╗ ██║  ██████╗  ██████╗ ██║ ██╗   ██║  ██████╗ ██╗   ██╗
██║████╗██║ ██╚═══██║ ██╔═══╝ █████╔╝   ██║  ██╔═══╝  ██╗ ██╔╝
 ███║ ███╔╝  ██████╔╝ ██║     ██╔═██╗   ██║  ██║       ████╔╝
 ╚══╝ ╚══╝   ╚═════╝  ╚═╝     ╚═╝ ╚═╝   ╚═╝  ╚═╝        ██╔╝
 ██ Vibe code in parallel using git worktrees or clones ██║
 █████████████████████████████████████████████████████████║
 ╚════════════════════════════════════════════════════════╝

USAGE:
wk <command> [options]
wk <0-9>                        Quick navigation by index

COMMANDS:
new, n <name> [options]         Create worktree with setup
clone, c [name] [options]       Clone repo as sibling with setup
clone -m <dir>                  Apply setup to existing clone
list, ls, l                     List all worktrees and clones
go <name>                       Go to worktree by branch name
back, b                         Back to main worktree
config                          Edit .worktreeinclude config
-h, --help                      Show this help
-v, --version                   Show version

NEW OPTIONS:
-d, --dir <dir>                 Repo dir to create from (default: current repo)
-s, --src <branch>              Source branch (default: repo default branch)
-b, --branch <branch>           Branch to create or check out (default: <name>)
-i, --interactive               Prompt for new options

CLONE OPTIONS:
-d, --dir <dir>                 Repo dir to clone from (default: current repo)
-s, --src <branch>              Source branch (default: repo default branch)
-b, --branch <branch>           Branch to create or check out (default: --src)
-m, --manual <dir>              Apply setup to existing clone
-i, --interactive               Prompt for clone options

NAVIGATION:
wk 0                      Jump to main repo
wk 1                      Jump to first worktree/clone
wk 2-9                    Jump to 2nd-9th worktree/clone

FILES:
.worktreeinclude          Patterns for files to copy (gitignore-style)

ALIAS: worktry

VERSION: 0.2.1

See: https://github.com/ovitrif/worktry
```

## Quick start

```bash
# Install
git clone https://github.com/ovitrif/worktry.git
cd worktry && ./install.sh

# In a project you want to hand to multiple agents
cd your-project
wk new feature            # create an agent workspace from the repo default branch
wk 1                      # jump to it and start another agent session there
wk 0                      # jump back

# Or clone instead
wk clone                  # create a sibling checkout from the repo default branch
wk clone -m ../existing   # apply setup to existing clone
```

## Install

You need `git` and `~/.local/bin` in your PATH.

```bash
git clone https://github.com/ovitrif/worktry.git
cd worktry
./install.sh
```

This puts `wk` in `~/.local/bin/` (with a `worktry` alias) and adds a shell function to your `.zshrc` or `.bashrc` so navigation commands can change your current directory.

## Usage

### Configure files to copy

```bash
wk config
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

Files must match both `.worktreeinclude` and `.gitignore` to be copied. That keeps committed source separate from local agent/session config.

### Create worktrees

```bash
wk new feature-name                    # dir and branch: feature-name, from repo default branch
wk new feature-name -s develop         # dir and branch: feature-name, from develop
wk new work-dir -b feature-name        # dir: work-dir, branch: feature-name
wk new work-dir -d ../repo -s master   # create from another repo dir
wk new -i                             # prompt for each option
```

Creates a worktree at `.claude/worktrees/<name>` under the selected repo directory, then applies local setup. The positional `<name>` is the directory name; `--branch`/`-b` controls the branch name, and `--src`/`-s` controls what the branch is created from.

### Create clones

```bash
wk clone                         # auto-named sibling (repo-2, repo-3, etc.)
wk c my-feature                  # named sibling clone using the alias
wk clone my-feature              # named sibling clone
wk clone my-feature -s master    # clone from a source branch
wk clone my-feature -b try-this  # create a branch after cloning
wk clone -m ../repo-2            # apply setup to existing clone
wk clone -i                      # prompt for each option
```

Clones from `origin` as a sibling directory with local agent setup and copied config files. `--src`/`-s` chooses the branch to clone; `--branch`/`-b` creates or checks out a branch from that source.

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
| `wk new <name> [-d DIR] [-s SRC] [-b BRANCH]` | `n` | Create worktree with setup |
| `wk clone [name] [-d DIR] [-s SRC] [-b BRANCH]` | `c` | Clone repo as sibling with setup |
| `wk clone -m <dir>` | -- | Apply setup to existing clone |
| `wk list` | `ls`, `l` | List all worktrees and clones |
| `wk go <name>` | -- | Go to worktree by branch name |
| `wk back` | `b` | Back to main worktree |
| `wk config` | -- | Edit .worktreeinclude |
| `wk 0-9` | -- | Go to worktree/clone by index |
| `wk --version` | `-v` | Show version |
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

# AI Agents Guide

This document provides context and rules for AI agents contributing to worktry.

## Project Overview

**wk** (or `worktry`) helps you run multiple AI agents in parallel using git worktrees or repo clones. Built as a companion to [worktree-cli](https://github.com/johnlindquist/worktree-cli) (`wt`), it provides:

- Quick navigation between worktrees or clones (`wk 0`, `wk 1`, etc.)
- Automatic copying of config files (`.env`, `.idea/`, etc.) via `.worktreeinclude` (gitignore-style patterns)
- Auto-setup of Claude Code permissions (`.claude/settings.local.json`)
- Support for both worktree mode (`wk init`) and clone mode (`wk init --clone`)

## Project Structure

```
worktry/
├── src/wk               # Main bash script (all commands)
├── install.sh           # Installation script
├── README.md            # User documentation
├── LICENSE              # The Unlicense
└── AGENTS.md            # This file (AI agent rules)
```

## Key Files

### `src/wk`

Main bash script containing:
- `show_help()` — Help message with all commands
- `create_worktreeinclude()` — Creates `.worktreeinclude` template
- `create_setup_script()` — Creates `.worktree-setup.sh` with file copying logic
- `init_worktree_mode()` — Initialize for worktree mode (creates `worktrees.json`)
- `init_clone_mode()` — Initialize for clone mode (no `worktrees.json`)
- `create_worktree()` — Direct worktree creation
- `go_to_worktree()` — Navigate by branch name
- `go_back()` — Navigate to main worktree
- `go_to_index()` — Navigate by numeric index (0-9), supports clone mode
- `is_clone_mode()` — Detect if using clones vs worktrees
- `list_clones()` — Find sibling clone directories
- `setup_clone()` — Apply wk setup to existing clone
- `edit_config()` — Open `.worktreeinclude` in editor
- Case statement routing all commands and aliases

### Generated Files

- `.worktreeinclude` — Gitignore-style patterns for files to copy (must also be in `.gitignore`)
- `.worktree-setup.sh` — Setup script run when creating worktrees/clones
- `worktrees.json` — Hook for `wt setup` CLI (worktree mode only)

### `install.sh`

Installs:
- Script to `~/.local/bin/wk` (with `worktry` symlink)
- Shell function to `~/.zshrc` or `~/.bashrc` (for `cd` support on navigation commands)

## Coding Rules

### Shell Script Style

- Use `#!/bin/bash` shebang
- Use lowercase for local variables
- Use UPPERCASE for exported/environment variables
- Quote all variable expansions: `"$var"` not `$var`
- Use `[[ ]]` for conditionals in bash
- Redirect stderr with `>&2` for error messages
- Exit with non-zero status on errors

### Commands and Aliases

When adding new commands:
1. Add the function implementation
2. Add case entry with any aliases (e.g., `config|c)`)
3. Update `show_help()` with the new command
4. Update `install.sh` shell function if the command needs `cd` support
5. Update README.md Commands table
6. Update AGENTS.md Key Files section if adding new functions

### Commit Messages

Use concise, imperative mood:
- ✅ "Add command aliases"
- ✅ "Fix navigation for bare repos"
- ❌ "Added command aliases"
- ❌ "This commit adds command aliases"

### Documentation

- Keep README.md scannable with emojis in section headers
- Use title case for headings (capitalize each word)
- Avoid filler phrases ("This is a tool that...", "What this does is...")
- Be direct and concise

## Testing Changes

After modifying `src/wk`:

```bash
# Reinstall
./install.sh

# Source shell config (for navigation commands)
source ~/.zshrc

# Test commands
wk --help
wk list
```

## License

This project is in the public domain under [The Unlicense](https://unlicense.org). Contributions are also released into the public domain.

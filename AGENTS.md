# AI Agents Guide

This document provides context and rules for AI agents contributing to worktry.

## Project Overview

**worktry** is a companion tool for [worktree-cli](https://github.com/johnlindquist/worktree-cli) (`wt`) that provides:

- Quick navigation between git worktrees (`worktry 0`, `worktry 1`, etc.)
- Automatic copying of gitignored files (`.env`, `.idea/`, etc.) to new worktrees
- Claude Code setup with `.claude/settings.local.json`

## Project Structure

```
worktry/
├── src/worktry          # Main bash script (all commands)
├── install.sh           # Installation script
├── workflows/
│   └── worktry.yaml     # Warp workflow definition
├── README.md            # User documentation
├── LICENSE              # The Unlicense
└── AGENTS.md            # This file (AI agent rules)
```

## Key Files

### `src/worktry`

Main bash script containing:
- `show_help()` — Help message with all commands
- `create_worktrees_json()` — Creates config files for `wt setup`
- `create_worktree()` — Legacy direct worktree creation
- `go_to_worktree()` — Navigate by branch name
- `go_back()` — Navigate to main worktree
- `go_to_index()` — Navigate by numeric index (0-9)
- `edit_worktreekeep()` — Open `.worktreekeep` in editor
- Case statement routing all commands and aliases

### `install.sh`

Installs:
- Script to `~/.local/bin/worktry`
- Workflow to `~/.warp/workflows/worktry.yaml`
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
2. Add case entry with any aliases (e.g., `keep|k)`)
3. Update `show_help()` with the new command
4. Update `install.sh` shell function if the command needs `cd` support
5. Update README.md Commands table

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

After modifying `src/worktry`:

```bash
# Reinstall
./install.sh

# Source shell config (for navigation commands)
source ~/.zshrc

# Test commands
worktry --help
worktry list
```

## License

This project is in the public domain under [The Unlicense](https://unlicense.org). Contributions are also released into the public domain.

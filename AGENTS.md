# AI Agents Guide

## Project Overview

**wk** (or `worktry`) is a Claude Code companion CLI for managing parallel workspaces using git worktrees or repo clones. It provides:

- Quick navigation between worktrees or clones (`wk 0`, `wk 1`, etc.)
- Automatic copying of config files (`.env`, `.idea/`, etc.) via `.worktreeinclude` (gitignore-style patterns)
- Auto-setup of Claude Code permissions (`.claude/settings.local.json`)
- Support for both worktree mode (`wk init`) and clone mode (`wk init --clone`)

Worktrees are created at `.claude/worktrees/<name>`, the same location Claude Code uses with `claude -w`.

## Project Structure

```
worktry/
├── src/wk               # Main bash script (all commands)
├── install.sh           # Installation script
├── test/verify.sh       # End-to-end verification script
├── README.md            # User documentation
├── LICENSE              # The Unlicense
└── AGENTS.md            # This file (AI agent rules)
```

## Key Files

### `src/wk`

Main bash script containing:
- `show_help()` -- help message with all commands
- `create_worktreeinclude()` -- creates `.worktreeinclude` template
- `create_setup_script()` -- creates `.worktree-setup.sh` with file copying logic
- `init_worktree_mode()` -- initialize for worktree mode
- `init_clone_mode()` -- initialize for clone mode
- `create_worktree()` -- create worktree at `.claude/worktrees/<name>`
- `go_to_worktree()` -- navigate by branch name
- `go_back()` -- navigate to main worktree
- `collect_entries()` -- find all worktrees and sibling clones (unified, deduplicated)
- `go_to_index()` -- navigate by numeric index (0-9)
- `setup_clone()` -- apply wk setup to existing clone
- `edit_config()` -- open `.worktreeinclude` in editor
- Case statement routing all commands and aliases

### Generated files

- `.worktreeinclude` -- gitignore-style patterns for files to copy (must also be in `.gitignore`)
- `.worktree-setup.sh` -- setup script run when creating worktrees/clones

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

### Testing and Verification

After any changes to `src/wk` or `install.sh`:
1. Reinstall: `./install.sh && source ~/.zshrc`
2. Run `test/verify.sh` to exercise every command against a tmp repo
3. If any checks fail, fix and re-run until all pass
4. Update `test/verify.sh` if new commands or behaviors are added

### Commit Messages

Use concise, imperative mood:
- ✅ "Add command aliases"
- ✅ "Fix navigation for bare repos"
- ❌ "Added command aliases"
- ❌ "This commit adds command aliases"

### Documentation

- Use sentence case for headings (capitalize only first word)
- Avoid filler phrases ("This is a tool that...", "What this does is...")
- Be direct and concise

## Testing Changes

After modifying `src/wk`:

```bash
# Reinstall
./install.sh

# Source shell config (for navigation commands)
source ~/.zshrc

# Run verification
bash test/verify.sh
```

## License

This project is in the public domain under [The Unlicense](https://unlicense.org). Contributions are also released into the public domain.

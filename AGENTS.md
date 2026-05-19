# AI Agents Guide

## Project overview

**wk** (or `worktry`) is a Claude Code companion CLI for managing parallel workspaces using git worktrees or repo clones. It provides:

- Quick navigation between worktrees or clones by list index (`wk 0`, `wk 1`, `wk 11`, etc.)
- Automatic copying of config files (`.env`, `.idea/`, etc.) via `.worktreeinclude` (gitignore-style patterns)
- Auto-setup of Claude Code permissions (`.claude/settings.local.json`)
- Worktree and clone creation with one command (`wk new`, `wk clone`)
- Source directory, source branch, target branch, and interactive prompts for creation commands

Worktrees are created at `.claude/worktrees/<name>` under the selected repo directory, the same location Claude Code uses with `claude -w`.

## Project structure

```
worktry/
├── src/wk               # Main bash script (all commands)
├── completions/         # Bash and zsh shell completions
├── install.sh           # Installation script
├── test/verify.sh       # End-to-end verification script
├── README.md            # User documentation
├── LICENSE              # The Unlicense
└── AGENTS.md            # This file (AI agent rules)
```

## Key files

### `src/wk`

Main bash script containing:
- `show_help()` -- help message with all commands
- `create_worktreeinclude()` -- creates `.worktreeinclude` template
- `warn_if_navigation_wrapper_inactive()` -- explains when navigation can only print a path because the shell wrapper is stale or inactive
- `print_navigation_target()` -- prints navigation targets for the shell wrapper
- `ensure_worktreeinclude_defaults()` -- backfills new generated `.worktreeinclude` defaults into existing configs
- `ensure_worktreeinclude()` -- auto-creates `.worktreeinclude` if missing
- `resolve_repo_dir()` -- resolves `--dir` or the current directory to the git repository root
- `get_default_branch()` -- determines the repo default branch for creation commands
- `prompt_value()` -- reads interactive values with defaults
- `cancel_interactive()` -- exits interactive flows cleanly on Ctrl+C or Esc cancellation
- `read_interactive_line()` -- reads cancelable text prompts in terminal mode
- `auto_clone_name()` -- picks the next sibling clone name
- `sanitize_workspace_name()` -- converts branch or folder hints into safe workspace names
- `get_current_branch()` -- resolves the checked-out branch, falling back to the default branch for interactive defaults
- `auto_worktree_name()` -- picks an unused worktree directory and branch-friendly name
- `prompt_menu_choice()` -- reads numbered interactive menu choices, including arrow-key and Esc handling in terminal mode
- `prompt_repo_dir()` -- prompts for and resolves a source repository directory
- `run_interactive_worktree_menu()` -- guides common worktree creation flows
- `run_interactive_clone_menu()` -- guides common clone creation flows
- `run_interactive_menu()` -- top-level interactive setup menu
- `copy_worktree_files()` -- copies files matching `.worktreeinclude` and `.gitignore`
- `run_setup()` -- creates Claude Code permissions and copies config files
- `create_worktree()` -- create worktree at `.claude/worktrees/<name>` with setup
- `clone_repo()` -- clone repo as sibling or apply setup to existing clone
- `go_to_worktree()` -- navigate by branch name
- `go_back()` -- navigate to main worktree
- `collect_entries()` -- find all worktrees and sibling clones (unified, deduplicated)
- `go_to_index()` -- navigate by numeric list index
- `list_indexed()` -- list all with aligned columns, type labels, current marker
- `edit_config()` -- open `.worktreeinclude` in editor
- Case statement routing all commands and aliases

### Generated files

- `.worktreeinclude` -- gitignore-style patterns for files to copy (auto-created when needed)

### `completions/`

- `wk.bash` -- bash completion for commands, options, branches, dirs, and `wk go`
- `wk.zsh` -- zsh completion for commands, options, branches, dirs, and `wk go`

### `install.sh`

Installs:
- Script to `~/.local/bin/wk` (with `worktry` symlink)
- Shell completions to `~/.local/share/worktry/completions/`
- Shell function to `~/.zshrc` or `~/.bashrc` (for `cd` support on navigation commands)
- Completion source line to `~/.zshrc` or `~/.bashrc`

## Coding rules

### Shell script style

- Use `#!/bin/bash` shebang
- Use lowercase for local variables
- Use UPPERCASE for exported/environment variables
- Quote all variable expansions: `"$var"` not `$var`
- Use `[[ ]]` for conditionals in bash
- Redirect stderr with `>&2` for error messages
- Exit with non-zero status on errors

### Commands and aliases

When adding new commands:
1. Add the function implementation
2. Add case entry with any aliases (e.g., `config|c)`)
3. Update `show_help()` with the new command
4. Update `install.sh` shell function if the command needs `cd` support
5. Update README.md Commands table
6. Update AGENTS.md Key Files section if adding new functions

### Testing and verification

After any changes to `src/wk` or `install.sh`:
1. Reinstall: `./install.sh && source ~/.zshrc`
2. Run `test/verify.sh` to exercise every command against a tmp repo
3. If any checks fail, fix and re-run until all pass
4. Update `test/verify.sh` if new commands or behaviors are added

### Commit messages

Use concise, imperative mood:
- "Add command aliases"
- "Fix navigation for bare repos"

### Documentation

- Use sentence case for headings (capitalize only first word)
- Avoid filler phrases ("This is a tool that...", "What this does is...")
- Be direct and concise

## Testing changes

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

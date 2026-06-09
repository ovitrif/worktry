# Bash completion for wk/worktry.

_wk_branches() {
  git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null \
    | sed 's#^origin/##' \
    | sort -u
}

_wk_worktree_branches() {
  git worktree list --porcelain 2>/dev/null \
    | awk '/^branch / { name = $2; sub("^refs/heads/", "", name); print name }'
}

_wk_complete() {
  local cur prev command
  local commands="new n clone c list ls l go back b setup sync repair hook install-hook doctor config -i --interactive -h --help -v --version version 0 1 2 3 4 5 6 7 8 9"
  local new_options="-d --dir -s --src -b --branch --name -n -i --interactive"
  local clone_options="-d --dir -s --src -b --branch --name -n -m --manual -i --interactive"
  local setup_options="-d --dir -q --quiet"
  local hook_options="-d --dir"
  local hook_commands="install"

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"

  case "$prev" in
    -d|--dir|-m|--manual)
      COMPREPLY=($(compgen -d -- "$cur"))
      return
      ;;
    -s|--src|-b|--branch|--name|-n)
      COMPREPLY=($(compgen -W "$(_wk_branches)" -- "$cur"))
      return
      ;;
  esac

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    return
  fi

  command="${COMP_WORDS[1]}"
  case "$command" in
    new|n)
      COMPREPLY=($(compgen -W "$new_options" -- "$cur"))
      ;;
    clone|c)
      COMPREPLY=($(compgen -W "$clone_options" -- "$cur"))
      ;;
    setup|sync|repair)
      COMPREPLY=($(compgen -W "$setup_options" -- "$cur"))
      ;;
    install-hook|doctor)
      COMPREPLY=($(compgen -W "$hook_options" -- "$cur"))
      ;;
    hook)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$hook_commands" -- "$cur"))
      else
        COMPREPLY=($(compgen -W "$hook_options" -- "$cur"))
      fi
      ;;
    go)
      COMPREPLY=($(compgen -W "$(_wk_worktree_branches)" -- "$cur"))
      ;;
    *)
      COMPREPLY=($(compgen -W "$commands" -- "$cur"))
      ;;
  esac
}

complete -F _wk_complete wk worktry 2>/dev/null || true

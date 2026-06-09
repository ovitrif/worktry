#compdef wk worktry
# Zsh completion for wk/worktry.

_wk_branches() {
  git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null \
    | sed 's#^origin/##' \
    | sort -u
}

_wk_worktree_branches() {
  git worktree list --porcelain 2>/dev/null \
    | awk '/^branch / { name = $2; sub("^refs/heads/", "", name); print name }'
}

_wk() {
  local state
  local -a commands branches worktree_branches

  commands=(
    'new:Create worktree with setup'
    'n:Create worktree with setup'
    'clone:Clone repo as sibling with setup'
    'c:Clone repo as sibling with setup'
    'list:List all worktrees and clones'
    'ls:List all worktrees and clones'
    'l:List all worktrees and clones'
    'go:Go to worktree by branch name or index'
    'back:Back to main worktree'
    'b:Back to main worktree'
    'setup:Apply setup to an existing worktree or clone'
    'sync:Apply setup to all listed workspaces'
    'repair:Apply setup to all listed workspaces'
    'hook:Manage worktry git hooks'
    'install-hook:Install worktry git hook'
    'config:Edit .worktreeinclude config'
    '-i:Open interactive setup'
    '--interactive:Open interactive setup'
    '-h:Show help'
    '--help:Show help'
    '-v:Show version'
    '--version:Show version'
    'version:Show version'
    '0:Jump to main repo'
    '1:Jump to first worktree or clone'
    '2:Jump to second worktree or clone'
    '3:Jump to third worktree or clone'
    '4:Jump to fourth worktree or clone'
    '5:Jump to fifth worktree or clone'
    '6:Jump to sixth worktree or clone'
    '7:Jump to seventh worktree or clone'
    '8:Jump to eighth worktree or clone'
    '9:Jump to ninth worktree or clone'
  )

  branches=("${(@f)$(_wk_branches)}")
  worktree_branches=("${(@f)$(_wk_worktree_branches)}")

  if (( CURRENT == 2 )); then
    _describe -t commands 'wk command' commands
    return
  fi

  case "$words[2]" in
    new|n)
      _arguments \
        '(-d --dir)'{-d,--dir}'[repo dir to create from]:source directory:_files -/' \
        '(-s --src)'{-s,--src}'[source branch]:source branch:->branches' \
        '(-b --branch --name -n)'{-b,--branch,--name,-n}'[branch to create or check out]:branch:->branches' \
        '(-i --interactive)'{-i,--interactive}'[prompt for new options]' \
        '*:worktree name: ' && return
      ;;
    clone|c)
      _arguments \
        '(-d --dir)'{-d,--dir}'[repo dir to clone from]:source directory:_files -/' \
        '(-s --src)'{-s,--src}'[source branch]:source branch:->branches' \
        '(-b --branch --name -n)'{-b,--branch,--name,-n}'[branch to create or check out]:branch:->branches' \
        '(-m --manual)'{-m,--manual}'[apply setup to existing clone]:existing clone directory:_files -/' \
        '(-i --interactive)'{-i,--interactive}'[prompt for clone options]' \
        '*:clone name: ' && return
      ;;
    setup|sync|repair)
      _arguments \
        '(-d --dir)'{-d,--dir}'[source repo dir to copy setup files from]:source directory:_files -/' \
        '(-q --quiet)'{-q,--quiet}'[suppress setup output]' \
        '*:target directory:_files -/' && return
      ;;
    install-hook)
      _arguments \
        '(-d --dir)'{-d,--dir}'[source repo dir to copy setup files from]:source directory:_files -/' && return
      ;;
    hook)
      _arguments \
        '1:hook command:(install)' \
        '(-d --dir)'{-d,--dir}'[source repo dir to copy setup files from]:source directory:_files -/' && return
      ;;
    go)
      _describe -t worktrees 'worktree branch' worktree_branches
      return
      ;;
  esac

  case "$state" in
    branches)
      _describe -t branches 'branch' branches
      ;;
  esac
}

if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz compinit
  if ! whence -w compdef >/dev/null 2>&1; then
    compinit -i
  fi
  compdef _wk wk worktry
fi

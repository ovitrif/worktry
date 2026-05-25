#!/bin/bash
# End-to-end verification for wk CLI
# Run after any changes to src/wk or install.sh

FAILURES=0
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMPDIR=$(mktemp -d)

echo "=== script syntax ==="
bash -n "$SCRIPT_DIR/src/wk" || fail "src/wk has bash syntax errors"
bash -n "$SCRIPT_DIR/install.sh" || fail "install.sh has bash syntax errors"
bash -n "$SCRIPT_DIR/completions/wk.bash" || fail "bash completion has syntax errors"
BASH_COMPLETION_OUTPUT=$(bash -c "source '$SCRIPT_DIR/completions/wk.bash'; COMP_WORDS=(wk cl); COMP_CWORD=1; _wk_complete; printf '%s\n' \"\${COMPREPLY[@]}\"")
echo "$BASH_COMPLETION_OUTPUT" | grep -q "^clone$" || fail "bash completion did not complete clone command"
if command -v zsh >/dev/null 2>&1; then
  zsh -n "$SCRIPT_DIR/completions/wk.zsh" || fail "zsh completion has syntax errors"
  ZSH_COMPLETION_HOME="$TMPDIR/zsh-completion-home"
  mkdir -p "$ZSH_COMPLETION_HOME"
  HOME="$ZSH_COMPLETION_HOME" zsh -fc "source '$SCRIPT_DIR/completions/wk.zsh'; whence -w _wk >/dev/null" || fail "zsh completion did not register _wk"
fi

echo ""
echo "=== install completions (temp HOME) ==="
INSTALL_HOME="$TMPDIR/install-home"
mkdir -p "$INSTALL_HOME"
touch "$INSTALL_HOME/.bashrc" "$INSTALL_HOME/.zshrc"
cat > "$INSTALL_HOME/.bashrc" <<'EOF'
# wk (worktry) - cd wrapper for navigation commands
wk() {
  if [[ "$1" == "go" || "$1" == "back" || "$1" == "b" || "$1" =~ ^[0-9]$ ]]; then
    command wk "$@"
  else
    command wk "$@"
  fi
}
alias worktry=wk
EOF
(cd "$SCRIPT_DIR" && printf "y\n" | HOME="$INSTALL_HOME" SHELL=/bin/bash ./install.sh)
test -f "$INSTALL_HOME/.local/share/worktry/completions/wk.bash" || fail "bash completion not installed"
test -f "$INSTALL_HOME/.local/share/worktry/completions/wk.zsh" || fail "zsh completion not installed"
grep -Fq '^[0-9]+$' "$INSTALL_HOME/.bashrc" || fail "bash shell function was not updated for multi-digit indexes"
grep -Fq 'WK_SHELL_WRAPPER=1' "$INSTALL_HOME/.bashrc" || fail "bash shell function does not mark wrapper navigation calls"
grep -q "worktry/completions/wk.bash" "$INSTALL_HOME/.bashrc" || fail "bash completion source line not added"
bash -c "source '$INSTALL_HOME/.local/share/worktry/completions/wk.bash'; complete -p wk >/dev/null" || fail "bash completion did not register wk"
(cd "$SCRIPT_DIR" && printf "y\n" | HOME="$INSTALL_HOME" SHELL=/bin/zsh ./install.sh)
grep -Fq '^[0-9]+$' "$INSTALL_HOME/.zshrc" || fail "zsh shell function was not added for multi-digit indexes"
grep -Fq 'WK_SHELL_WRAPPER=1' "$INSTALL_HOME/.zshrc" || fail "zsh shell function does not mark wrapper navigation calls"
grep -q "worktry/completions/wk.zsh" "$INSTALL_HOME/.zshrc" || fail "zsh completion source line not added"
export PATH="$INSTALL_HOME/.local/bin:$PATH"

cd "$TMPDIR"
git init test-repo && cd test-repo
git config user.email "test@test.com"
git config user.name "Test"
git config commit.gpgsign false
echo "SECRET=123" > .env
mkdir -p app/src/mainnetRelease
echo '{"project_info":{"project_id":"test"}}' > app/google-services.json
echo '{"project_info":{"project_id":"test-mainnet"}}' > app/src/mainnetRelease/google-services.json
echo ".env" > .gitignore
echo "google-services.json" >> .gitignore
git add -A && git commit -m "init"
git branch -M main

echo "=== wk --help ==="
wk --help || fail "wk --help exited non-zero"
wk --help | grep -q "clone, c" || fail "wk --help missing clone c alias"
wk --help | grep -q "config                          Edit" || fail "wk --help should show config without c alias"
wk --help | grep -q "wk                              Open interactive setup" || fail "wk --help missing interactive usage"
wk --help | grep -q "wk new <name> \\[--dir <source-dir>\\]" || fail "wk --help missing new example"
wk --help | grep -q "wk clone \\[<name>\\] \\[--dir <source-dir>\\]" || fail "wk --help missing clone example"
wk --help | grep -q "Press Ctrl+C to quit, or press Esc twice to cancel." || fail "wk --help missing interactive quit hint"

echo ""
echo "=== wk --version ==="
wk --version | grep -q "wk 0.3.5" || fail "wk --version did not print 0.3.5"

echo ""
echo "=== wk new (no init needed) ==="
wk new test-feature
test -d .claude/worktrees/test-feature || fail "worktree not at .claude/worktrees/test-feature"
test -f .worktreeinclude || fail ".worktreeinclude not auto-created by wk new"
test ! -f .worktree-setup.sh || fail ".worktree-setup.sh should NOT be generated"
test -f .claude/worktrees/test-feature/.claude/settings.local.json || fail "Claude settings not created in worktree"
test -f .claude/worktrees/test-feature/app/google-services.json || fail "root app google-services.json not copied to worktree"
test -f .claude/worktrees/test-feature/app/src/mainnetRelease/google-services.json || fail "mainnetRelease google-services.json not copied to worktree"
git rev-parse --verify test-feature >/dev/null 2>&1 || fail "wk new did not create branch named after directory by default"

echo ""
echo "=== wk new with gitignore-style .worktreeinclude patterns ==="
mkdir -p .idea .ai tools/fcm-tester nested app
echo "<project />" > .idea/workspace.xml
echo "cache" > .ai/session.json
echo "KEY=1" > keystore.properties
echo "binary" > app/internal.keystore
echo '{"client_email":"test@example.com"}' > tools/fcm-tester/service-account.json
echo "LOCAL=1" > nested/example.local.json
cat >> .worktreeinclude <<'EOF'

# Extra gitignore-style pattern coverage
keystore.*
*.keystore
.idea
.ai
tools/fcm-tester/service-account.json
*.local.*
EOF
wk new include-patterns --src main
test -f .claude/worktrees/include-patterns/keystore.properties || fail "keystore.* did not copy root keystore.properties"
test -f .claude/worktrees/include-patterns/app/internal.keystore || fail "*.keystore did not copy nested keystore"
test -f .claude/worktrees/include-patterns/.idea/workspace.xml || fail ".idea directory pattern did not copy contents"
test -f .claude/worktrees/include-patterns/.ai/session.json || fail ".ai directory pattern did not copy contents"
test -f .claude/worktrees/include-patterns/tools/fcm-tester/service-account.json || fail "nested service-account path was not copied"
test -f .claude/worktrees/include-patterns/nested/example.local.json || fail "slashless glob did not copy unignored untracked file"

echo ""
echo "=== wk config (auto-creates .worktreeinclude) ==="
cd "$TMPDIR"
git init config-test && cd config-test
git config user.email "test@test.com"
git config user.name "Test"
git config commit.gpgsign false
git commit --allow-empty -m "init"
test ! -f .worktreeinclude || fail ".worktreeinclude should not exist yet"
EDITOR=cat wk config || fail "wk config failed"
test -f .worktreeinclude || fail ".worktreeinclude not auto-created by wk config"

echo ""
echo "=== wk ls (worktrees) ==="
cd "$TMPDIR/test-repo"
LS_OUTPUT=$(wk ls)
echo "$LS_OUTPUT"
echo "$LS_OUTPUT" | grep -q "\[worktree\]" || fail "wk ls missing [worktree] type label"
echo "$LS_OUTPUT" | grep -q "\*" || fail "wk ls missing * marker"

echo ""
echo "=== wk 1 ==="
OUTPUT=$(command wk 1)
echo "wk 1 -> $OUTPUT"
test -d "$OUTPUT" || fail "wk 1 output is not a valid directory"

echo ""
echo "=== wk go test-feature ==="
OUTPUT=$(command wk go test-feature)
echo "wk go -> $OUTPUT"
test -d "$OUTPUT" || fail "wk go output is not a valid directory"

echo ""
echo "=== wk back ==="
OUTPUT=$(command wk back)
echo "wk back -> $OUTPUT"
test -d "$OUTPUT" || fail "wk back output is not a valid directory"

echo ""
echo "=== wk new with --src ==="
wk new test-feature-2 --src main
test -d .claude/worktrees/test-feature-2 || fail "worktree with --src not created"

echo ""
echo "=== wk new from detached HEAD ==="
git checkout --detach main >/dev/null 2>&1
wk new detached-feature
test -d .claude/worktrees/detached-feature || fail "worktree from detached HEAD not created"
test "$(git -C .claude/worktrees/detached-feature branch --show-current)" = "detached-feature" || fail "worktree from detached HEAD did not create requested branch"
git checkout main >/dev/null 2>&1

echo ""
echo "=== wk new with separate directory and branch ==="
wk new dir-only --src main --branch branch-only
test -d .claude/worktrees/dir-only || fail "worktree did not use positional argument as directory"
test "$(git -C .claude/worktrees/dir-only branch --show-current)" = "branch-only" || fail "worktree did not use --branch as branch name"

echo ""
echo "=== wk new with --dir ==="
cd "$TMPDIR"
wk new from-other-dir --dir "$TMPDIR/test-repo" --src main --branch from-other-branch
test -d "$TMPDIR/test-repo/.claude/worktrees/from-other-dir" || fail "worktree with --dir not created under repo .claude/worktrees"
test "$(git -C "$TMPDIR/test-repo/.claude/worktrees/from-other-dir" branch --show-current)" = "from-other-branch" || fail "worktree with --dir did not use --branch"

echo ""
echo "=== wk new --interactive (piped input) ==="
cd "$TMPDIR/test-repo"
printf "interactive-dir\n%s\nmain\ninteractive-branch\n" "$TMPDIR/test-repo" | wk new --interactive
test -d .claude/worktrees/interactive-dir || fail "interactive wk new did not create worktree"
test "$(git -C .claude/worktrees/interactive-dir branch --show-current)" = "interactive-branch" || fail "interactive wk new did not create requested branch"

echo ""
echo "=== wk --interactive (worktree menu, piped input) ==="
cd "$TMPDIR/test-repo"
printf "1\n1\nmenu-dir\n%s\nmain\nmenu-branch\n" "$TMPDIR/test-repo" | wk --interactive
test -d .claude/worktrees/menu-dir || fail "interactive menu did not create worktree"
test "$(git -C .claude/worktrees/menu-dir branch --show-current)" = "menu-branch" || fail "interactive menu did not create requested branch"

echo ""
echo "=== wk clone -m (manual clone setup) ==="
cd "$TMPDIR"
git clone test-repo test-repo-2
cd "$TMPDIR/test-repo"
wk clone -m "$TMPDIR/test-repo-2"
test -f "$TMPDIR/test-repo-2/.claude/settings.local.json" || fail "clone -m didn't create Claude settings"

echo ""
echo "=== wk ls (unified: worktrees + clones) ==="
cd "$TMPDIR/test-repo"
LS_UNIFIED=$(wk ls)
echo "$LS_UNIFIED"
echo "$LS_UNIFIED" | grep -q "\[worktree\]" || fail "unified wk ls missing [worktree]"
echo "$LS_UNIFIED" | grep -q "\[clone\]" || fail "unified wk ls missing [clone]"

echo ""
echo "=== wk ls from clone sees everything ==="
cd "$TMPDIR/test-repo-2"
CLONE_LS=$(wk ls)
echo "$CLONE_LS"
echo "$CLONE_LS" | grep -q "\[worktree\]" || fail "wk ls from clone missing [worktree]"
echo "$CLONE_LS" | grep -q "\[clone\]" || fail "wk ls from clone missing [clone]"
echo "$CLONE_LS" | grep -q "\*" || fail "wk ls from clone missing * marker"

echo ""
echo "=== prepare clone origin ==="
cd "$TMPDIR/test-repo"
# Set origin to local path for testing
git remote remove origin 2>/dev/null
git remote add origin "$TMPDIR/test-repo"
# Simulate an older generated .worktreeinclude before Android defaults existed.
awk '$0 != "google-services.json"' .worktreeinclude > "$TMPDIR/old-worktreeinclude"
cp "$TMPDIR/old-worktreeinclude" .worktreeinclude

echo ""
echo "=== wk --interactive (clone menu, piped input) ==="
printf "2\n2\n%s\nmenu-clone\n" "$TMPDIR/test-repo" | wk --interactive
test -d "$TMPDIR/menu-clone" || fail "interactive menu did not create clone"
test -f "$TMPDIR/menu-clone/.claude/settings.local.json" || fail "interactive menu clone didn't create Claude settings"
grep -q "^google-services.json$" .worktreeinclude || fail "existing .worktreeinclude was not upgraded with google-services.json"
test -f "$TMPDIR/menu-clone/app/google-services.json" || fail "interactive menu clone did not copy app google-services.json"
test -f "$TMPDIR/menu-clone/app/src/mainnetRelease/google-services.json" || fail "interactive menu clone did not copy mainnetRelease google-services.json"

echo ""
echo "=== wk clone (auto-clone) ==="
cd "$TMPDIR/test-repo"
wk clone test-repo-auto --src main
test -d "$TMPDIR/test-repo-auto" || fail "wk clone did not create sibling"
test -f "$TMPDIR/test-repo-auto/.claude/settings.local.json" || fail "wk clone didn't create Claude settings"
test "$(git -C "$TMPDIR/test-repo-auto" branch --show-current)" = "main" || fail "wk clone did not checkout --src branch"

echo ""
echo "=== wk c (clone alias) ==="
cd "$TMPDIR/test-repo"
wk c test-repo-c --src main
test -d "$TMPDIR/test-repo-c" || fail "wk c did not create sibling clone"
test -f "$TMPDIR/test-repo-c/.claude/settings.local.json" || fail "wk c didn't create Claude settings"

echo ""
echo "=== wk clone with --branch ==="
cd "$TMPDIR/test-repo"
wk clone test-repo-branch --src main --branch cloned-branch
test -d "$TMPDIR/test-repo-branch" || fail "wk clone with --branch did not create sibling"
test "$(git -C "$TMPDIR/test-repo-branch" branch --show-current)" = "cloned-branch" || fail "wk clone did not create requested branch"

echo ""
echo "=== wk clone (auto-numbered) ==="
cd "$TMPDIR/test-repo"
wk clone
# Should create test-repo-3 (test-repo-2 exists, test-repo-auto doesn't match pattern)
FOUND_AUTO=false
for d in "$TMPDIR"/test-repo-[0-9]*; do
  if [ -d "$d" ] && [ "$d" != "$TMPDIR/test-repo-2" ]; then
    FOUND_AUTO=true
    echo "Auto-numbered clone: $d"
    break
  fi
done
$FOUND_AUTO || fail "wk clone auto-numbering failed"

echo ""
echo "=== wk multi-digit index ==="
LS_OUTPUT=$(wk ls)
echo "$LS_OUTPUT"
INDEX10_PATH=$(echo "$LS_OUTPUT" | awk '$1 == 10 { print $2 }')
test -n "$INDEX10_PATH" || fail "wk ls did not produce index 10 for multi-digit navigation test"
OUTPUT=$(command wk 10)
echo "wk 10 -> $OUTPUT"
test "$OUTPUT" = "$INDEX10_PATH" || fail "wk 10 did not navigate to listed index 10"
test -d "$OUTPUT" || fail "wk 10 output is not a valid directory"

OUTPUT=$(command wk go 10)
echo "wk go 10 -> $OUTPUT"
test "$OUTPUT" = "$INDEX10_PATH" || fail "wk go 10 did not navigate to listed index 10"

echo ""
echo "=== wk go numeric branch fallback ==="
wk new numeric-branch-dir --src main --branch 123
NUMERIC_BRANCH_PATH=$(cd "$TMPDIR/test-repo/.claude/worktrees/numeric-branch-dir" && pwd -P)
OUTPUT=$(command wk go 123)
echo "wk go 123 -> $OUTPUT"
test "$OUTPUT" = "$NUMERIC_BRANCH_PATH" || fail "wk go numeric fallback did not navigate to numeric branch name"
test -d "$OUTPUT" || fail "wk go numeric fallback output is not a valid directory"

# Cleanup
cd /
rm -rf "$TMPDIR"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "VERIFICATION FAILED: $FAILURES failure(s)"
  exit 1
fi
echo "ALL VERIFICATION PASSED"

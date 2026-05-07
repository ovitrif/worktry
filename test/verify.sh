#!/bin/bash
# End-to-end verification for wk CLI
# Run after any changes to src/wk or install.sh

FAILURES=0
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init test-repo && cd test-repo
git config user.email "test@test.com"
git config user.name "Test"
echo "SECRET=123" > .env
echo ".env" > .gitignore
git add -A && git commit -m "init"
git branch -M main

echo "=== wk --help ==="
wk --help || fail "wk --help exited non-zero"
wk --help | grep -q "clone, c" || fail "wk --help missing clone c alias"
wk --help | grep -q "config                          Edit" || fail "wk --help should show config without c alias"

echo ""
echo "=== wk --version ==="
wk --version | grep -q "wk 0.2.1" || fail "wk --version did not print 0.2.1"

echo ""
echo "=== wk new (no init needed) ==="
wk new test-feature
test -d .claude/worktrees/test-feature || fail "worktree not at .claude/worktrees/test-feature"
test -f .worktreeinclude || fail ".worktreeinclude not auto-created by wk new"
test ! -f .worktree-setup.sh || fail ".worktree-setup.sh should NOT be generated"
test -f .claude/worktrees/test-feature/.claude/settings.local.json || fail "Claude settings not created in worktree"
git rev-parse --verify test-feature >/dev/null 2>&1 || fail "wk new did not create branch named after directory by default"

echo ""
echo "=== wk config (auto-creates .worktreeinclude) ==="
cd "$TMPDIR"
git init config-test && cd config-test
git config user.email "test@test.com"
git config user.name "Test"
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
echo "=== wk clone (auto-clone) ==="
cd "$TMPDIR/test-repo"
# Set origin to local path for testing
git remote remove origin 2>/dev/null
git remote add origin "$TMPDIR/test-repo"
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

# Cleanup
cd /
rm -rf "$TMPDIR"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "VERIFICATION FAILED: $FAILURES failure(s)"
  exit 1
fi
echo "ALL VERIFICATION PASSED"

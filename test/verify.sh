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

echo "=== wk --help ==="
wk --help || fail "wk --help exited non-zero"

echo ""
echo "=== wk new (no init needed) ==="
wk new test-feature
test -d .claude/worktrees/test-feature || fail "worktree not at .claude/worktrees/test-feature"
test -f .worktreeinclude || fail ".worktreeinclude not auto-created by wk new"
test ! -f .worktree-setup.sh || fail ".worktree-setup.sh should NOT be generated"
test -f .claude/worktrees/test-feature/.claude/settings.local.json || fail "Claude settings not created in worktree"

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
echo "=== wk new with --base ==="
wk new test-feature-2 --base main
test -d .claude/worktrees/test-feature-2 || fail "worktree with --base not created"

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
wk clone test-repo-auto
test -d "$TMPDIR/test-repo-auto" || fail "wk clone did not create sibling"
test -f "$TMPDIR/test-repo-auto/.claude/settings.local.json" || fail "wk clone didn't create Claude settings"

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

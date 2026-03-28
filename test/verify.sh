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
git add -A && git commit -m "init"

echo "=== wk --help ==="
wk --help || fail "wk --help exited non-zero"

echo ""
echo "=== wk init ==="
wk init
test -f .worktreeinclude || fail ".worktreeinclude not created"
test -f .worktree-setup.sh || fail ".worktree-setup.sh not created"
test ! -f worktrees.json || fail "worktrees.json should NOT exist"

echo ""
echo "=== wk config ==="
EDITOR=cat wk config || fail "wk config failed"

echo ""
echo "=== wk new test-feature ==="
wk new test-feature
test -d .claude/worktrees/test-feature || fail "worktree not at .claude/worktrees/test-feature"

echo ""
echo "=== wk ls ==="
wk ls || fail "wk ls failed"

echo ""
echo "=== wk 1 ==="
OUTPUT=$(command wk 1)
echo "wk 1 → $OUTPUT"
test -d "$OUTPUT" || fail "wk 1 output is not a valid directory"

echo ""
echo "=== wk go test-feature ==="
OUTPUT=$(command wk go test-feature)
echo "wk go → $OUTPUT"
test -d "$OUTPUT" || fail "wk go output is not a valid directory"

echo ""
echo "=== wk back ==="
OUTPUT=$(command wk back)
echo "wk back → $OUTPUT"
test -d "$OUTPUT" || fail "wk back output is not a valid directory"

echo ""
echo "=== wk new test-feature-2 --base main ==="
wk new test-feature-2 --base main
test -d .claude/worktrees/test-feature-2 || fail "worktree with --base not created"

echo ""
echo "=== clone mode ==="
cd "$TMPDIR"
git clone test-repo test-repo-2
cd test-repo-2
command wk init --clone
test -f .worktreeinclude || fail "clone init missing .worktreeinclude"

# Cleanup
cd /
rm -rf "$TMPDIR"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "VERIFICATION FAILED: $FAILURES failure(s)"
  exit 1
fi
echo "ALL VERIFICATION PASSED"

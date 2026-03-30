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
echo "=== wk ls (worktree mode, from main) ==="
LS_OUTPUT=$(wk ls)
echo "$LS_OUTPUT"
echo "$LS_OUTPUT" | grep -q "\[worktree\]" || fail "wk ls missing [worktree] type label"
echo "$LS_OUTPUT" | grep -q "\*" || fail "wk ls missing * marker for current worktree"

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

echo ""
echo "=== wk ls (from clone, should see both repos) ==="
CLONE_LS=$(wk ls)
echo "$CLONE_LS"
echo "$CLONE_LS" | grep -q "\[clone\]" || fail "wk ls missing [clone] type label"
echo "$CLONE_LS" | grep -q "test-repo-2" || fail "wk ls from clone doesn't show self"
echo "$CLONE_LS" | grep -q "\*" || fail "wk ls from clone missing * marker"

echo ""
echo "=== wk ls (unified: worktrees + clones) ==="
cd "$TMPDIR/test-repo"
LS_UNIFIED=$(wk ls)
echo "$LS_UNIFIED"
echo "$LS_UNIFIED" | grep -q "\[worktree\]" || fail "unified wk ls missing [worktree]"
echo "$LS_UNIFIED" | grep -q "\[clone\]" || fail "unified wk ls missing [clone] for test-repo-2"
LINES=$(echo "$LS_UNIFIED" | wc -l | tr -d ' ')
[[ "$LINES" -ge 3 ]] || fail "unified wk ls should have at least 3 entries (main + worktree + clone), got $LINES"

echo ""
echo "=== wk ls column alignment ==="
# All [worktree] and [clone] labels should start at the same column
COLS=$(echo "$LS_UNIFIED" | sed -n 's/.*\(\[.*\]\).*/\1/p' | while read -r label; do
  echo "$LS_UNIFIED" | grep -n "$label" | head -1 | awk -v lab="$label" '{print index($0, lab)}'
done | sort -u | wc -l | tr -d ' ')
# With printf alignment, type labels should start at the same column
[[ "$COLS" -le 2 ]] || fail "wk ls columns not aligned (found $COLS distinct start positions for type labels)"

echo ""
echo "=== wk 2 (navigate to clone by index) ==="
cd "$TMPDIR/test-repo"
OUTPUT=$(command wk 2)
echo "wk 2 -> $OUTPUT"
test -d "$OUTPUT" || fail "wk 2 (clone navigation) output is not a valid directory"

# Cleanup
cd /
rm -rf "$TMPDIR"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "VERIFICATION FAILED: $FAILURES failure(s)"
  exit 1
fi
echo "ALL VERIFICATION PASSED"

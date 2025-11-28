#!/bin/bash

# Create Claude Code settings
mkdir -p .claude
cat > .claude/settings.local.json << 'JSON_EOF'
{
  "permissions": {
    "allow": [
      "Bash",
      "Read",
      "Edit",
      "Write",
      "WebFetch",
      "mcp__ide__getDiagnostics",
      "WebSearch",
      "mcp__github__pull_request_read",
      "mcp__github__search_pull_requests",
      "mcp__github__list_pull_requests"
    ],
    "deny": [],
    "ask": [
      "Bash(rm -rf:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)"
    ],
    "additionalDirectories": [
      "/Users/ovitrif/repos"
    ]
  }
}
JSON_EOF

# Copy files listed in .worktreekeep
if [ -f "$ROOT_WORKTREE_PATH/.worktreekeep" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    # Trim whitespace
    line=$(echo "$line" | xargs)
    src="$ROOT_WORKTREE_PATH/$line"
    if [ -e "$src" ]; then
      # Create parent directory if needed
      mkdir -p "$(dirname "$line")"
      cp -r "$src" "$line"
      echo "  Copied: $line"
    fi
  done < "$ROOT_WORKTREE_PATH/.worktreekeep"
fi

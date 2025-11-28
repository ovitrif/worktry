#!/bin/bash
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

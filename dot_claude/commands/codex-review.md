---
allowed-tools: mcp__codex__codex, mcp__codex__codex-reply, Bash, Read, Glob, Grep, Agent
description: Use Codex to review recent code changes
user-invocable: true
---

Run the codex-review skill. Get a `git diff` of recent changes (or unstaged changes), read the relevant files for context, then call the Codex MCP tool to perform an independent code review. Synthesize findings from both Claude and Codex into a unified review.

$ARGUMENTS

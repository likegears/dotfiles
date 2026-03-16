---
allowed-tools: Bash, Read, Glob, Grep, Agent
description: Multi-model code review using Codex CLI + Gemini CLI
user-invocable: true
---

Run the codex-review skill. Get recent code changes, then call both `codex review` and `gemini -p` via CLI in parallel for independent code reviews. Synthesize findings from Claude, Codex, and Gemini into a unified review.

$ARGUMENTS

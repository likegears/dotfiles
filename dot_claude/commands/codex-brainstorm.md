---
allowed-tools: Bash, Read, Glob, Grep, Agent
description: Multi-model brainstorm using Codex CLI + Gemini CLI
user-invocable: true
---

Run the codex-brainstorm skill. Send the design question to both `codex exec` and `gemini -p` via CLI in parallel. Synthesize perspectives from Claude, Codex, and Gemini into a comparison table with a final recommendation.

Topic: $ARGUMENTS

---
name: codex-review
description: |
  Use Codex CLI and Gemini CLI for multi-model code review. Invoke when:
  - User asks for code review, PR review, or quality check
  - User says "/codex-review", "codex review", "multi-model review"
  - After completing a significant code change that needs a second opinion

  Calls both Codex and Gemini via CLI (no MCP dependency), so it works in any
  session and multiple sessions can use it simultaneously.
---

# Multi-Model Code Review (Codex + Gemini CLI)

## Workflow

1. **Gather context**: Get the diff and relevant files.

```bash
git diff HEAD~1 > /tmp/review_diff.txt
# or for unstaged changes:
git diff > /tmp/review_diff.txt
```

2. **Call both models in parallel** via Bash:

### Codex CLI (has built-in review command):
```bash
cd <project_dir> && codex review --uncommitted "Focus on bugs, security, and performance. Skip trivial style." 2>&1
```
Or with a custom diff:
```bash
cd <project_dir> && codex exec "Review this diff for bugs, logic errors, security issues, and performance problems. Skip style comments.

$(cat /tmp/review_diff.txt)" 2>&1
```

### Gemini CLI:
```bash
cd <project_dir> && gemini -p "You are a senior code reviewer. Review the following diff for:
1. Bugs, logic errors, edge cases
2. Security vulnerabilities
3. Performance issues
4. Adherence to project conventions

Focus on actionable issues only. Skip trivial style comments.

$(cat /tmp/review_diff.txt)" 2>&1
```

3. **Run both in parallel**: Use the Agent tool to dispatch two subagents, one calling Codex and one calling Gemini, then synthesize.

4. **Synthesize**: Present a unified review:
   - Issues all models agree on (high confidence)
   - Issues only one model found (worth investigating)
   - Claude's own assessment

## Key Flags
- `codex review --uncommitted` — review all local changes
- `codex exec "<prompt>"` — non-interactive, returns result to stdout
- `gemini -p "<prompt>"` — non-interactive headless mode

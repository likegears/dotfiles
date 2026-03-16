---
name: codex-review
description: |
  Use Codex MCP to perform code review. Invoke when:
  - User asks for code review, PR review, or quality check
  - User says "/codex-review", "codex review", "let codex review"
  - After completing a significant code change that needs a second opinion

  This skill leverages OpenAI Codex as an independent reviewer to catch issues
  Claude might miss, providing a multi-model review perspective.
---

# Codex Code Review

You have access to the Codex MCP server. Use it to get an independent code review from Codex.

## Workflow

1. **Gather context**: Identify the files that were changed. Use `git diff` or read the relevant files.

2. **Prepare the review prompt**: Build a detailed prompt that includes:
   - The code diff or full file contents
   - The purpose of the changes
   - Any project conventions from CLAUDE.md

3. **Call Codex MCP**: Use the `codex` MCP tool with:
   - `prompt`: A review request with the code context
   - `approval-policy`: "on-failure"
   - `cwd`: The current project directory

4. **Synthesize**: Combine Codex's findings with your own analysis. Present a unified review that:
   - Highlights issues both models agree on (high confidence)
   - Notes issues only one model found (worth investigating)
   - Skips trivial style differences

## Prompt Template for Codex

```
Review the following code changes for:
1. Bugs, logic errors, edge cases
2. Security vulnerabilities
3. Performance issues
4. Adherence to project conventions

Focus on actionable issues. Skip trivial style comments.

[CODE DIFF / FILES HERE]
```

## Important
- Always read the code first before sending to Codex
- Include sufficient context (imports, related functions) for meaningful review
- If Codex and Claude disagree, present both perspectives to the user

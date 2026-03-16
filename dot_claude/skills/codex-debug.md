---
name: codex-debug
description: |
  Use Codex MCP to debug issues. Invoke when:
  - User asks to "codex debug", "let codex look at this bug"
  - User says "/codex-debug"
  - A bug is proving difficult to locate with standard debugging
  - Need a fresh perspective on error messages, stack traces, or unexpected behavior

  This skill sends debugging context to Codex for independent root cause analysis,
  especially useful when Claude's own analysis hasn't resolved the issue.
---

# Codex Debug

Use the Codex MCP server for independent bug analysis and root cause investigation.

## Workflow

1. **Collect evidence**: Gather all relevant debugging info:
   - Error messages / stack traces
   - Relevant source code (the failing function + callers)
   - Expected vs actual behavior
   - Steps to reproduce
   - Recent changes (git log / diff)

2. **Send to Codex**: Call the `codex` MCP tool with:
   - `prompt`: Structured debug request with all evidence
   - `approval-policy`: "on-failure"
   - `cwd`: The project directory (so Codex can read files if needed)

3. **Compare hypotheses**:
   - List Claude's suspected root causes
   - List Codex's suspected root causes
   - Identify overlap (high confidence) and unique findings

4. **Verify**: Test the most likely hypothesis before presenting the fix.

## Prompt Template for Codex

```
I'm debugging an issue:

**Symptom**: [what's going wrong]
**Expected**: [what should happen]
**Error**: [error message / stack trace if any]

**Relevant code**:
[paste code]

**Recent changes**:
[git diff or description]

Please:
1. Identify the most likely root cause
2. Explain WHY this causes the observed behavior
3. Suggest a fix
4. Note any other potential issues in this code
```

## When to Use
- After Claude's first debugging attempt doesn't resolve the issue
- For complex multi-file bugs where a fresh perspective helps
- When the bug involves unfamiliar libraries or runtime behavior
- For race conditions, memory issues, or other subtle bugs

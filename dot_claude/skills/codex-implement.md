---
name: codex-implement
description: |
  Use Codex MCP to implement backend features or complex algorithms. Invoke when:
  - User asks to "let codex implement", "codex write", "use codex for this"
  - User says "/codex-implement"
  - Task involves backend implementation where Codex may have stronger capabilities
  - Need to generate boilerplate, API endpoints, database queries, or system-level code
  - Complex algorithmic implementation that benefits from Codex's code generation

  This skill delegates implementation to Codex while Claude handles integration,
  review, and project-specific adaptation.
---

# Codex Implementation

Use the Codex MCP server to implement features, especially backend/systems code.

## Workflow

1. **Define the spec**: Before calling Codex, prepare:
   - Clear description of what to implement
   - Input/output contract (types, interfaces)
   - Project conventions (from CLAUDE.md)
   - Existing code patterns to follow (read examples from codebase)

2. **Call Codex**: Use the `codex` MCP tool with:
   - `prompt`: Implementation spec with conventions
   - `approval-policy`: "on-request" (review before executing)
   - `cwd`: The project directory
   - `sandbox`: "workspace-write" (allow file writes)

3. **Review output**: Claude reviews Codex's implementation for:
   - Adherence to project conventions
   - Security issues
   - Missing error handling
   - Integration with existing code

4. **Adapt and integrate**: Modify Codex's output if needed to fit the project, then apply.

## Prompt Template for Codex

```
Implement [FEATURE DESCRIPTION].

**Requirements**:
- [requirement 1]
- [requirement 2]

**Project conventions**:
- Language: [language]
- Naming: [conventions]
- Error handling: [pattern]
- File location: [where to create files]

**Existing patterns** (follow this style):
[paste example code from the project]

**Interface**:
[type definitions / function signatures]

Write production-ready code. Include error handling but skip tests.
```

## Best Practices
- Always provide existing code examples so Codex matches the project style
- Use "on-request" approval policy so you can review before Codex writes files
- For large features, break into smaller Codex calls
- Claude should always review and adapt the output before presenting to user

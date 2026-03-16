---
name: codex-brainstorm
description: |
  Use Codex MCP to brainstorm and discuss architecture decisions. Invoke when:
  - User asks to "discuss with codex", "ask codex", "codex opinion"
  - User says "/codex-brainstorm" or "/codex-discuss"
  - Facing a complex design decision that benefits from multi-model perspective
  - Need to evaluate trade-offs for architecture, API design, or tech stack choices

  This skill creates a collaborative discussion between Claude and Codex to
  explore design alternatives and reach better decisions.
---

# Codex Brainstorm / Architecture Discussion

Use the Codex MCP server to have a collaborative design discussion.

## Workflow

1. **Frame the problem**: Clearly define the design question, constraints, and goals.

2. **Get Codex's perspective**: Call the `codex` MCP tool with a prompt that:
   - Describes the problem and constraints
   - Asks for 2-3 alternative approaches
   - Requests trade-off analysis for each

3. **Multi-turn discussion** (if needed): Use `codex-reply` to follow up on specific points, ask Codex to elaborate on an approach, or challenge assumptions.

4. **Synthesize**: Present a comparison table to the user:
   - Claude's recommended approach + reasoning
   - Codex's recommended approach + reasoning
   - Where they agree / disagree
   - Final recommendation with rationale

## Prompt Template for Codex

```
I'm designing [FEATURE/SYSTEM]. Here are the constraints:
- [constraint 1]
- [constraint 2]

Current codebase uses: [relevant tech/patterns]

Please propose 2-3 approaches with trade-offs for each:
1. Performance implications
2. Maintainability
3. Complexity
4. Alignment with existing patterns

Which approach do you recommend and why?
```

## Tips
- Share relevant code snippets from the codebase so Codex has context
- Use `codex-reply` for follow-up questions — threads maintain conversation state
- When models disagree, ask each to critique the other's approach

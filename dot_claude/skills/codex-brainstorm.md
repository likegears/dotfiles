---
name: codex-brainstorm
description: |
  Use Codex CLI and Gemini CLI to brainstorm and discuss architecture decisions. Invoke when:
  - User asks to "discuss with codex", "ask gemini", "multi-model opinion"
  - User says "/codex-brainstorm" or "/codex-discuss"
  - Facing a complex design decision that benefits from multi-model perspective
  - Need to evaluate trade-offs for architecture, API design, or tech stack choices

  Calls both Codex and Gemini via CLI (no MCP dependency), so it works in any
  session and multiple sessions can use it simultaneously.
---

# Multi-Model Brainstorm (Codex + Gemini CLI)

## Workflow

1. **Frame the problem**: Prepare a clear prompt with constraints and context.

2. **Call both models in parallel** via Bash:

### Codex CLI:
```bash
cd <project_dir> && codex exec "I'm designing [FEATURE]. Constraints:
- [constraint 1]
- [constraint 2]

Current codebase uses: [tech/patterns]

Propose 2-3 approaches with trade-offs:
1. Performance
2. Maintainability
3. Complexity
4. Alignment with existing patterns

Which do you recommend and why?" 2>&1
```

### Gemini CLI:
```bash
cd <project_dir> && gemini -p "I'm designing [FEATURE]. Constraints:
- [constraint 1]
- [constraint 2]

Current codebase uses: [tech/patterns]

Propose 2-3 approaches with trade-offs:
1. Performance
2. Maintainability
3. Complexity
4. Alignment with existing patterns

Which do you recommend and why?" 2>&1
```

3. **Run both in parallel**: Use the Agent tool to dispatch two subagents, one for each model, then synthesize.

4. **Synthesize**: Present a comparison table:

| Aspect | Claude | Codex | Gemini |
|--------|--------|-------|--------|
| Recommended approach | ... | ... | ... |
| Key reasoning | ... | ... | ... |
| Unique insight | ... | ... | ... |

Then provide a final recommendation based on consensus or strongest reasoning.

## Tips
- Include relevant code snippets in the prompt so models have context
- If models disagree, have Claude evaluate each argument on technical merit
- For follow-up, you can run another round with more specific questions
- `codex exec` and `gemini -p` are both non-interactive — safe for subagent use

## Key Flags
- `codex exec "<prompt>"` — non-interactive execution
- `gemini -p "<prompt>"` — non-interactive headless mode
- `gemini -y -p "<prompt>"` — auto-approve actions (if gemini needs tool use)

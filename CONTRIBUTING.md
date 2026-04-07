# Contributing

## Adding a New Skill

Skills follow a consistent structure:

```
skills/skill-name/
└── skill-name.md
```

### Skill Format

Every skill file needs:

1. **YAML frontmatter** with `name` and `description`
2. **When to Use** section
3. **The workflow** (steps, prompts, templates)
4. **Anti-Patterns table** (common mistakes and why they fail)
5. **Verification checklist** (how to know you're done)

### Writing Guidelines

**Be prescriptive, not descriptive.** "Use .sheet with .presentationDetents" not "consider using sheets."

**Write for non-developers.** No code knowledge assumed. Prompts should be copy-pasteable plain language.

**Include prompt templates.** Show exactly what to tell Claude Code.

**Keep it under 200 lines.** If longer, split into a skill + reference file.

**Test it.** Use the skill to build something real before submitting.

## Adding an Agent Persona

Agent personas go in `agents/`. They define a specialist role Claude Code can assume.

Format:
- YAML frontmatter with `name` and `description`
- Role description and expertise areas
- Review/output format specification
- When to invoke the agent

## Modifying Existing Skills

- Keep changes focused (one concern per PR)
- Explain WHY in the PR description
- If adding a gotcha, include the scenario where you hit it
- Don't remove anti-patterns unless they're genuinely wrong

## What We're Looking For

- Skills for specific iOS patterns not yet covered (Widgets, Watch, App Clips)
- Generator skills for common features (auth, payments, onboarding)
- Platform gotchas from real development experience
- Improvements to the MCP setup process
- Mobile workflow enhancements

## What We're NOT Looking For

- Web development skills (this is iOS-native only)
- Skills that require writing code manually (target audience is non-developers)
- Tool-specific skills that don't work with Claude Code
- Theoretical advice without actionable steps

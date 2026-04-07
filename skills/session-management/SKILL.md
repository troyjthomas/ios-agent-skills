---
name: session-management
description: Manage Claude Code context windows, resume work across sessions, and maintain continuity when your Mac restarts or sessions expire. Use this skill when starting a new session on an existing project, when context feels stale, or when Claude Code starts making mistakes it shouldn't. Prevents the "Claude forgot everything" problem.
---

# Session Management

Claude Code has no memory between sessions. Every new session starts blank and reads your CLAUDE.md. This skill ensures continuity.

## Context Window Management

Claude Code's context window is large but finite. Everything loaded into it competes for attention. Overload it and quality drops.

### The 500-Line Rule

Your CLAUDE.md should stay under 500 lines. This is the file loaded into every session. If it's too long, Claude Code starts ignoring rules at the bottom.

**What belongs in CLAUDE.md (always loaded):**
- Core principles (native SwiftUI, iOS version, HIG)
- Navigation structure
- Architecture conventions
- Custom components list
- What NOT to do
- Known gotchas
- Build configuration
- .pbxproj safety rule

**What belongs in separate files (loaded when needed):**
- App spec (APP_SPEC.md)
- Design system (DESIGN_SYSTEM.md)
- Detailed component specs
- Reference documentation

### Per-Session Context Loading

At the start of each session, tell Claude Code what to focus on:

```
Read CLAUDE.md. Today we're working on the Settings flow.
Also read the Settings section of APP_SPEC.md. Ignore other
sections for now.
```

This focuses the context on what matters for THIS session rather than loading everything.

### Signs of Context Overload

- Claude Code starts ignoring rules from your CLAUDE.md
- It builds custom components when native ones exist
- It forgets the architecture pattern mid-session
- Responses get slower or less precise
- It repeats mistakes you've already corrected

**Fix:** Start a new session. Load only the CLAUDE.md and the specific section you're working on. Keep the scope narrow.

## Session Continuity

### The Problem

Claude Code sessions don't survive Mac restarts, long periods of inactivity, or network timeouts. When a session ends, all conversation context is lost. The code on disk is fine (it's committed to git), but Claude Code doesn't know what it was doing.

### The Solution: Git as Your Checkpoint System

Your git history IS your session memory. Every commit message tells the next session what happened.

**End of every work session:**
```
Commit all changes with a descriptive message that includes
what's done and what's next. Example:
"Settings main screen complete. Next: build notification
preferences sub-page."
```

**Start of the next session:**
```
Read CLAUDE.md. Check the git log for recent commits to
understand what's been done. We're continuing from where
the last session left off. The most recent commit message
describes what to do next.
```

### The Session Handoff Pattern

Before you close your laptop or end a session, tell Claude Code:

```
Write a brief session summary as a comment at the top of
CLAUDE.md under a "## Current Status" section. Include:
- What screens are complete
- What screen is in progress
- What's next
- Any unresolved issues
```

The next session reads this and picks up exactly where you left off. Update this section at the end of every session.

### Example Current Status Section

```markdown
## Current Status (Updated 2026-04-07)
- DONE: Scaffolding, Projects Home, New Project Sheet, Settings Main
- IN PROGRESS: Project Detail (stitch counter custom component)
- NEXT: Explore tab, Onboarding
- ISSUES: Liquid Glass on nav bar flickers during sheet dismiss (logged as gotcha)
```

## Conductor Session Management

Each Conductor workspace is an independent session. When managing multiple:

### Naming Convention
Name workspaces after their task, not generic labels:
- "build-project-detail" not "workspace-3"
- "fix-navigation-bug" not "hotfix"
- "polish-home-screen" not "updates"

### Workspace Lifecycle
1. Create workspace with descriptive name
2. Give it a focused task (one screen, one feature, one bug)
3. Let it work (monitor via Remote Control if away)
4. Review the output
5. Merge or request changes
6. Close the workspace

Don't keep stale workspaces open. Merge or close within 24 hours. Long-lived branches diverge from main and create painful merges.

## Resuming From Your Phone

If a Remote Control session times out:
1. Your Mac needs to be awake with Claude Code running
2. Start a new Remote Control session from the same workspace
3. The git state is preserved even if the conversation is lost
4. Tell Claude Code to read CLAUDE.md and check git log for context

If your Mac went to sleep:
1. You can't reconnect until someone (or a scheduled task) wakes it
2. Consider: macOS Energy Saver settings to prevent sleep when plugged in
3. Or use Dispatch to send a task that wakes the Mac

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Loading every reference file at session start | Overloads context, quality drops |
| Not committing until the end of a session | Mac crash = lost work |
| Keeping 5+ Conductor workspaces open for days | Branches diverge, merges become painful |
| Relying on conversation history instead of git | Conversations disappear. Git is permanent |
| Writing a 1000-line CLAUDE.md with every possible rule | Claude Code ignores rules past ~500 lines |

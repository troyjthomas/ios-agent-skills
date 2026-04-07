---
name: git-workflow
description: Git conventions for parallel Claude Code workstreams in Conductor. Covers branching strategy, merge order, conflict prevention, shared file protection, and the checkpoint pattern. Use this skill throughout the build phase, especially when running multiple Conductor workspaces. Prevents the merge conflicts and corrupted state that kill momentum.
---

# Git Workflow

Parallel workstreams are powerful until they step on each other. This skill prevents that.

## Branching Convention

Every Conductor workspace creates its own branch automatically. Name your workspaces descriptively:

```
workspace: build-projects-home     → branch: build-projects-home
workspace: build-settings-flow     → branch: build-settings-flow
workspace: build-explore-tab       → branch: build-explore-tab
```

## The Merge Order Rule

**Structural changes go first. Screen-specific changes go second.**

### Wave 0: Foundation (Single Workspace, Sequential)
Changes that touch shared files. Do these BEFORE parallel work:
- ContentView.swift (TabView setup, root navigation)
- App entry point ([AppName]App.swift)
- Shared models (if data models are defined early)
- Shared components in /Components
- Any file that multiple screens will import

Merge Wave 0 into main before starting parallel workspaces.

### Wave 1-3: Parallel Screen Work
Now branch out. Each workspace touches only its own screen files:
- Views/Projects/ProjectsHomeView.swift (Workspace 1)
- Views/Settings/SettingsView.swift (Workspace 2)
- Views/Explore/ExploreView.swift (Workspace 3)

These don't conflict because they're different files.

### Wave 4: Integration
After screens are merged, do integration work in a single workspace:
- Wire up cross-screen navigation that wasn't in the skeleton
- Add shared state that multiple screens need
- Resolve any inconsistencies between screens

## The Shared File Protection Rule

Add this to your CLAUDE.md:

```markdown
## Git Safety
- Do NOT modify ContentView.swift, [AppName]App.swift, or any
  file in /Models or /Components unless this is the only active
  workspace. Ask me before touching shared files.
- If you need to add an import or reference to a shared file,
  tell me what needs to change and I'll do it in a separate
  workspace after this one merges.
```

This prevents the most common Conductor conflict: two workspaces both adding a NavigationLink to ContentView.

## The Checkpoint Pattern

Commit frequently. Commits are your save points.

```
After every meaningful change (not every line):
git add . && git commit -m "Descriptive message"
```

Tell Claude Code:
```markdown
## Commit Frequency
Commit after completing each logical unit of work:
- After the view layout is done
- After interactions are wired up
- After edge cases (empty state, error state) are handled
- Before starting any risky refactor

Commit messages should describe WHAT changed, not HOW:
- "Add project list with progress rings and context menu"
- "Wire up New Project sheet with form fields"
- NOT "Update ProjectsHomeView.swift"
```

## Conflict Resolution

If you do get a merge conflict (it happens):

1. **Don't panic.** Git conflicts in SwiftUI files are usually straightforward.
2. **Tell Claude Code:** "There's a merge conflict in [filename]. The main branch has [describe]. My branch has [describe]. Resolve the conflict by keeping both changes."
3. **If the conflict is in .pbxproj:** Abort the merge. Revert to main. Re-do the work in a new workspace. Never manually resolve .pbxproj conflicts.

## Pre-Merge Checklist

Before merging any workspace:
- [ ] Build succeeds (via XcodeBuildMCP)
- [ ] All existing navigation still works (no broken paths)
- [ ] No changes to shared files (unless this is Wave 0 or Wave 4)
- [ ] Commit messages are descriptive
- [ ] Preview renders correctly (via Xcode MCP Bridge)

## Working with Remote Control

When managing merges from your phone:
- Review the diff in the Conductor PR view (visible on phone via GitHub)
- Tell Claude Code via Remote Control: "Merge this workspace and delete the branch"
- Switch to the next workspace that needs attention
- You can't see the full Conductor overview on your phone, so check workspaces one at a time via Remote Control and use GitHub's PR list as your dashboard

## Bridging Dispatch Sessions into Conductor

When you start a Claude Code session via Dispatch from your phone, it runs directly in your repo directory without Conductor's git worktree isolation. Without guardrails, this session could modify main directly, which is dangerous and invisible to Conductor.

### The Rule: Dispatch Sessions Always Branch First

Add this to your CLAUDE.md:

```markdown
## Dispatch Session Safety
If this session was NOT started from a Conductor workspace:
1. BEFORE making any code changes, create a new branch:
   git checkout -b dispatch/[descriptive-name]
2. Make all changes on this branch, never on main
3. Commit with descriptive messages as you work
4. When finished, push the branch:
   git push origin dispatch/[descriptive-name]
5. Create a pull request:
   gh pr create --title "[description]" --body "Dispatch session from phone"
6. Do NOT merge the PR. Leave it for review.
7. When done, check out main again:
   git checkout main
```

### What This Produces

A Dispatch session from your phone creates the exact same artifact as a Conductor workspace: a branch with a PR. The only difference is how it was started.

```
Conductor workspace    →  branch: build-settings-flow     →  PR #12
Dispatch session       →  branch: dispatch/fix-progress   →  PR #13
```

Both show up in GitHub's PR list. Both can be reviewed and merged the same way.

### The Handoff: Dispatch to Conductor

When you're back at your desk:

**Option A: Merge via GitHub (simplest)**
Open the PR on GitHub. Review the changes. Merge. Done. Conductor's next workspace will be based on the updated main.

**Option B: Pull into Conductor (if you want to iterate)**
If the Dispatch session got 80% of the way and needs more work:
1. Open Conductor
2. Create a new workspace from the dispatch branch (not from main)
3. Continue the work in Conductor with full isolation
4. Merge via Conductor's normal PR flow

**Option C: Review via Remote Control first**
From your phone, switch to the Dispatch session via Remote Control. Review what Claude Code built. If it looks good, tell it: "Push the branch and create a PR." If it needs changes, give feedback and let it iterate. Then handle the merge when you're at your desk.

### Preventing Main Branch Pollution

The critical risk with Dispatch is Claude Code making changes directly on main without branching. The CLAUDE.md rule prevents this, but as a safety net:

**Protect your main branch on GitHub:**
Settings > Branches > Add rule > Branch name pattern: `main`
- Require a pull request before merging
- Require status checks to pass (if you have CI/CD)

This means even if Claude Code accidentally tries to push to main, GitHub rejects it. All changes MUST go through a PR. This single GitHub setting makes the entire Dispatch workflow safe.

### The Complete Phone-to-Merge Flow

```
1. Phone: Open Dispatch
2. Phone: "Start a Claude Code session in Patchwork. Create a branch
   called dispatch/fix-dark-mode-tint. The progress ring is hard to
   see in dark mode. Make the ring color brighter in dark mode."
3. Mac: Claude Code creates branch, fixes the issue, commits, pushes, creates PR
4. Phone: Get notified the task is done (via Dispatch)
5. Phone: Open GitHub in browser, review the PR diff
6. Desk (later): Open Conductor, merge the PR, continue other work
   OR
   Phone: Approve and merge the PR directly on GitHub mobile
```

### Naming Convention for Dispatch Branches

```
dispatch/[action]-[target]

Examples:
dispatch/fix-progress-ring
dispatch/add-haptic-counter
dispatch/update-settings-layout
dispatch/bump-version-1.0.1
```

The `dispatch/` prefix makes it immediately clear in GitHub's branch list and Conductor which branches came from phone sessions vs. Conductor workspaces.


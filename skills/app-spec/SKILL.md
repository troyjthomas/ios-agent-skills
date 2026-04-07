---
name: app-spec
description: Turn an app vision into the two documents Claude Code needs to build the app - a CLAUDE.md rules file and a screen-by-screen app spec. Use this skill after completing app-vision, when you're ready to set up the project for Claude Code. This produces the contract that governs every Claude Code session.
---

# App Spec

Produce the two documents that govern your entire build. This still happens in Claude chat.

## When to Use

- You've completed the app-vision skill
- You're ready to create the project repo
- You need a CLAUDE.md and app spec before touching Claude Code

## Document 1: CLAUDE.md

This file lives in the root of your repo. Claude Code reads it automatically at the start of every session. It contains rules, not descriptions.

### Required Sections

```markdown
# [App Name] - Development Rules

## Core Principles
- Use native SwiftUI components exclusively unless explicitly told to build custom
- Target iOS [version]
- Follow Apple HIG for all spacing, typography, layout, and interaction patterns
- Use SF Symbols for all icons unless a custom asset is specified
- Use system fonts unless a specific typeface is called out

## Navigation
- [Tab-based / Single stack / Other] navigation pattern
- List every navigation path: what presents what, and how (push, sheet, menu)
- Define presentation rules:
  - Sheets for: [creation, editing, multi-step flows]
  - Menus for: [action lists, quick selections]
  - Pickers for: [constrained value selection]
  - Context menus for: [long-press actions on list items]

## Architecture
- SwiftUI + [SwiftData / Core Data / UserDefaults] for persistence
- [MVVM / other] pattern
- File structure conventions:
  - /Components for shared components
  - /Models for data models
  - /Views/[Feature] for feature-specific views

## Color and Theming
- Primary tint: [hex or semantic description]
- Support light and dark mode from day one
- Use semantic colors (Color.primary, Color.secondary) for text
- [Liquid Glass / Material / other] treatment for system chrome

## Custom Components (the exceptions)
- List ONLY the components that cannot be built with native SwiftUI
- Each one gets a name and a one-line description of what it does
- These will be specced in detail during the build phase

## What NOT to Do
- Do not wrap native components in custom abstractions
- Do not use UIKit unless SwiftUI has no equivalent
- Do not create custom navigation transitions unless specified
- Do not add animations beyond SwiftUI defaults unless specified
- Do not hardcode strings
```

### Writing Rules for CLAUDE.md

**Be prescriptive, not descriptive.** "Use .sheet with .presentationDetents" not "consider using sheets."

**Be specific about navigation.** Every screen-to-screen transition should be defined. "Plus button in toolbar opens New Project sheet" not "user can create projects."

**List custom components explicitly.** If it's not on the list, Claude Code should use native SwiftUI. This is the single most important rule for quality.

**Include a What NOT to Do section.** This prevents the most common Claude Code mistakes. Add to it as you discover patterns.

## Document 2: App Spec

A screen-by-screen map. One to three sentences per screen. Not a PRD. Not a 40-page document.

### Format

```markdown
# [App Name] App Spec

## [Screen Name]
- What the user sees (layout, content, key UI elements)
- What the user can do (interactions, gestures, buttons)
- Where it leads (navigation: what opens when you tap what)
- Edge cases (empty state, loading state, error state)

## [Next Screen]
...
```

### Per-Screen Checklist

Each screen entry should answer:
- [ ] What content is displayed?
- [ ] What are the primary actions?
- [ ] What secondary actions exist (context menu, toolbar menu)?
- [ ] What happens when the list is empty?
- [ ] What navigation paths lead TO this screen?
- [ ] What navigation paths lead FROM this screen?

### Example Entry

```markdown
## Projects Home (Tab 1)
- Scrollable list of active projects in a LazyVStack. Each row: project
  name (headline weight), circular progress ring (24pt), yarn color swatch.
- Long press on a row: context menu with Edit, Duplicate, Archive, Delete.
- Toolbar: plus button (top right) opens New Project sheet.
- Empty state: centered illustration + "Start your first project" CTA button.
- Tapping a row pushes to Project Detail.
```

## Verification

Your spec is ready when:
- [ ] Every screen from the vision is represented
- [ ] Every navigation path is defined (you can trace a path from any screen to any other screen)
- [ ] Empty states are called out for every screen that displays a list
- [ ] Custom components are listed in CLAUDE.md (and there are as few as possible)
- [ ] The CLAUDE.md could be handed to a stranger and they'd know the rules

## Output

Two files ready to drop into your repo:
1. `CLAUDE.md` (in project root)
2. `APP_SPEC.md` (in project root)

## Next Step

Create your Xcode project, drop both files in, commit, and move to the **scaffolding** skill.

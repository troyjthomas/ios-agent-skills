---
name: scaffolding
description: Build the complete app skeleton in a single Claude Code session. Every screen exists, all navigation works, but everything uses placeholder content. Use this skill immediately after creating your repo with CLAUDE.md and APP_SPEC.md. This is the one step you CAN one-shot because there's nothing to get wrong -- it's pure structure.
---

# Scaffolding

Build the entire app structure in one pass. Every screen, every navigation path, placeholder content everywhere. No detail, no styling, no data. Just the bones.

## When to Use

- You just created your Xcode project and dropped in CLAUDE.md + APP_SPEC.md
- You're starting a fresh rebuild of an existing app
- You have your spec and are ready for the first Claude Code session

## Prerequisites

- [ ] Xcode project created (File > New > App, SwiftUI, SwiftData)
- [ ] CLAUDE.md in project root
- [ ] APP_SPEC.md in project root
- [ ] Git initialized, initial commit made
- [ ] Claude Code running in the project directory

## The Prompt

One prompt. One session. One output.

```
Read CLAUDE.md and APP_SPEC.md. Build the full app skeleton.

Every screen from the spec should exist as a SwiftUI view with
placeholder content. Set up the tab navigation (if applicable),
NavigationStacks, and all navigation paths between screens.

No real data. No styling. No custom components. No persistence.
Just the structure so I can tap through every screen in the simulator.

Create the file structure defined in CLAUDE.md. Each view goes
in the correct directory.
```

## What Claude Code Should Produce

### File Structure
```
[AppName]/
├── [AppName]App.swift          (entry point with tab view or root navigation)
├── ContentView.swift           (root view with tab bar or initial navigation)
├── Models/                     (empty, populated later)
├── Components/                 (empty, populated later)
├── Views/
│   ├── Projects/
│   │   ├── ProjectsHomeView.swift
│   │   ├── ProjectDetailView.swift
│   │   └── NewProjectSheet.swift
│   ├── Explore/
│   │   ├── ExploreView.swift
│   │   └── ExploreDetailView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── [SubSettingsViews].swift
└── Assets.xcassets/
```

### Each View Should Contain
- A `NavigationStack` wrapper (if it's a root tab view)
- Placeholder text: "Projects Home" or "Settings will go here"
- Navigation links/sheets wired to their destinations with placeholder triggers
- The correct toolbar items (even if they're just Text placeholders)

### Navigation Should Be Complete
Every path in your APP_SPEC.md should work:
- Tab bar switches between root views
- Tapping a list item pushes to detail
- Plus button presents a sheet
- Back buttons and dismiss work correctly
- Menus open (even if options are placeholder)

## Verification Checklist

Run the app in the simulator and tap through everything:

- [ ] All tabs appear and switch correctly
- [ ] Every screen in the spec is reachable
- [ ] Sheets present and dismiss
- [ ] Navigation pushes and pops work
- [ ] No dead ends (every screen has a way back)
- [ ] File structure matches CLAUDE.md conventions
- [ ] No build errors or warnings

## Common Issues

**Claude Code creates a flat file structure.** Redirect: "Move views into the folder structure defined in CLAUDE.md. Views/Projects/, Views/Explore/, etc."

**Claude Code adds styling or real content.** Redirect: "Strip all styling. Placeholder content only. We'll build each screen individually."

**Claude Code misses a screen.** Check your APP_SPEC.md. If the screen is listed, point Claude Code to the specific entry: "You missed the Surprise Me sheet. Add it per the spec."

**Claude Code invents screens not in the spec.** Redirect: "Remove [ScreenName]. Only build screens listed in APP_SPEC.md."

## After Scaffolding

**Important:** After Claude Code creates all the .swift files, open Xcode and verify all files appear in the project navigator. If any files are missing from the project (but exist on disk), drag them into the correct group in Xcode. See the xcode-integration skill for why Claude Code should never modify .pbxproj directly.

If XcodeBuildMCP is set up, tell Claude Code:
```
Build the project using XcodeBuildMCP. Fix any compile errors.
Do not modify the .xcodeproj file. If errors are related to
missing file references, list the files I need to add in Xcode.
```

```bash
git add .
git commit -m "App skeleton with all screens and navigation"
git push
```

You now have a buildable, tappable app with zero functionality. Every screen is a placeholder waiting to be filled in. Move to **screen-by-screen** for the next phase.

## Time Estimate

30-45 minutes including review and any corrections.

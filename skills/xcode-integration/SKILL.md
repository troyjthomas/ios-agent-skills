---
name: xcode-integration
description: Safe patterns for Claude Code interacting with Xcode projects. Covers .pbxproj protection (critical), XcodeBuildMCP build/test patterns, the RenderPreview visual feedback loop, and when to use terminal Claude Code vs Xcode's built-in Claude Agent. Use this skill throughout the entire build process. The .pbxproj rule alone prevents hours of wasted debugging.
---

# Xcode Integration

Claude Code and Xcode work together through MCPs. But Xcode project files are fragile. This skill keeps you safe.

## The .pbxproj Rule (CRITICAL)

**Never let Claude Code modify .pbxproj files directly.**

The .pbxproj format is notoriously complex. Claude Code can read it but should never write to it. One corrupted project file wastes hours.

### Add This to Every CLAUDE.md

```markdown
## Xcode Project Safety
- NEVER modify .xcodeproj/project.pbxproj directly
- NEVER modify .xcworkspace files directly
- When creating new Swift files, create the file on disk.
  I will add it to the Xcode project manually.
- When deleting files, delete from disk. I will remove
  the reference in Xcode manually.
- If a build error is related to missing file references
  in the project, tell me to fix it in Xcode rather than
  attempting to edit the pbxproj.
```

### Why This Matters for You

As a non-developer, you might not immediately recognize a corrupted .pbxproj. The symptoms: Xcode refuses to open the project, or builds fail with cryptic errors about missing references. The fix is usually reverting the file in git, but if you didn't commit before the corruption, you lose work.

### The Workaround

Claude Code creates the .swift files in the correct directories. You open Xcode, drag the files into the project navigator, and Xcode handles the .pbxproj entries correctly. This takes 5 seconds per file and prevents hours of debugging.

**Alternative for Swift Package Manager projects:** If your project uses SPM exclusively (no .xcodeproj), this rule is less critical since SPM uses Package.swift which is more predictable. But most iOS apps still use .xcodeproj.

## Build Patterns with XcodeBuildMCP

### Building for Simulator

Tell Claude Code:
```
Build the project for the iPhone 16 Pro simulator.
If there are build errors, fix them.
```

Claude Code uses XcodeBuildMCP to run the build, reads the errors, and fixes them. This loop can happen multiple times without your intervention.

### Running Tests

```
Run all unit tests. If any fail, analyze the failures
and fix the code (not the tests, unless the tests are wrong).
```

### Build Before Merge

Add this rule to your CLAUDE.md:
```markdown
## Build Verification
Before presenting any screen as "done," build the project
using XcodeBuildMCP. If the build fails, fix the errors
before telling me the screen is ready for review.
```

This catches compile errors before you ever open Xcode.

## The Visual Preview Loop

With the Xcode MCP Bridge, Claude Code can render SwiftUI previews and see the result.

### How It Works

1. Claude Code writes/modifies a SwiftUI view
2. Claude Code calls RenderPreview to capture a screenshot
3. Claude Code examines the screenshot
4. If something looks wrong, it modifies the code and previews again
5. It repeats until the preview matches the intent

### When to Use Previews

- After building a new screen (verify layout)
- After making visual changes (verify the change worked)
- When matching a Figma design (compare preview to design)
- When fixing a visual bug (verify the fix)

### Limitations of RenderPreview

- Requires Xcode to be running
- Only works with views that have `#Preview` macros
- Can't test interactive behavior (taps, scrolls, navigation)
- Can't test dark mode or Dynamic Type (renders default settings)
- Still needs real device testing for the full experience

### Add to Your CLAUDE.md

```markdown
## Visual Verification
After building or modifying any SwiftUI view, use
RenderPreview to capture a preview screenshot. Verify
the layout looks correct before presenting the screen
as done. If you have a Figma reference frame, compare
the preview to the Figma design and iterate until they
match at the layout/hierarchy level.
```

## Terminal Claude Code vs Xcode Claude Agent

You now have two ways to use Claude for iOS development:

### Terminal Claude Code (via Conductor)
**Best for:**
- Parallel workstreams (multiple screens at once)
- Scaffolding and structural work
- Data model and persistence work
- Non-visual changes (logic, state management)
- Remote Control from your phone

**Limitations:**
- No live SwiftUI previews (RenderPreview requires Xcode open)
- Can't see your simulator
- .pbxproj restrictions apply

### Xcode 26.3 Claude Agent (built-in)
**Best for:**
- Single-screen visual iteration
- Polish and refinement (it can see previews natively)
- Debugging build errors in context
- Learning SwiftUI APIs (it searches Apple docs inline)

**Limitations:**
- One session at a time (no parallelism)
- Can't run from your phone
- Slower for bulk work

### The Hybrid Approach

Use Conductor with terminal Claude Code for building screens in parallel. Use Xcode's Claude Agent for polish and visual refinement on individual screens. This gives you speed (parallel builds) AND visual fidelity (preview verification).

## Platform-Specific Build Settings

Always specify in your CLAUDE.md:

```markdown
## Build Configuration
- Deployment target: iOS 26.0
- Supported devices: iPhone
- Supported orientations: Portrait
- Swift version: 6.x
- Xcode version: 26.3+
```

The exact OS version matters. Claude Code's suggestions change between iOS 17 and iOS 26. Being explicit prevents it from using deprecated APIs or missing new ones.

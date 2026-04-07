---
name: figma-to-code
description: Translate Figma designs into SwiftUI code using the Figma MCP, without exporting PNGs or screenshots. Use this skill when you have Figma frames you want Claude Code to match, when you're in the polish phase and want pixel-level accuracy, or when you're adding a new screen that was designed in Figma first. Requires Figma MCP connected to Claude Code.
---

# Figma to Code

Get Claude Code to read your Figma designs directly and translate them into native SwiftUI. No screenshots. No PNGs. No "look at the bottom right corner of this image."

## When to Use

- You designed a screen in Figma and want Claude Code to build it
- You're polishing an existing screen to match a refined Figma comp
- You're adding new screens that were designed before being built
- You want to batch-import multiple screens from a Figma project

## Prerequisites

- Figma MCP connected to Claude Code
- Your Figma file organized with named frames (not random artboards)
- Each screen in Figma should be a single, clearly named frame

## How to Reference Figma Frames

### Option 1: Frame URL
Copy the URL of a specific frame in Figma (right-click frame > Copy link). Paste it directly into your Claude Code prompt.

### Option 2: Node ID
In the Figma URL, the node ID appears after `node-id=`. You can reference this directly.

### Option 3: File + Frame Name
Reference the Figma file URL and frame name: "In my Figma file [URL], find the frame called 'Settings Main'."

## The Prompt Template

### For a New Screen

```
Build [Screen Name] based on this Figma frame: [URL or node ID].

Read the frame's layout, text content, spacing, and hierarchy.
Use native SwiftUI components for everything. Refer to CLAUDE.md
for component rules. The Figma design shows visual intent -- match
the layout and hierarchy, but use system-standard spacing and
native component behavior rather than pixel-exact replication of
every dimension.
```

### For Polishing an Existing Screen

```
Refine [Screen Name] to match this Figma frame: [URL or node ID].

The screen already exists and works. Adjust layout, spacing,
typography weight, and visual hierarchy to match the Figma design.
Do not change functionality or navigation. Do not replace native
components with custom ones.
```

### For Multiple Screens (Batch)

```
Here are the Figma frames for the Settings flow:
- Settings Main: [URL]
- Settings Notifications: [URL]
- Settings Appearance: [URL]
- Settings About: [URL]

Build all four screens. Each is a standard grouped List with
sections and rows. Refer to CLAUDE.md for navigation patterns.
The gear icon on the home screen is the entry point.
```

## What to Expect from the MCP

The Figma MCP provides Claude Code with:
- Frame dimensions and layout structure
- Text content and approximate typography
- Color values
- Component hierarchy (which elements are grouped)
- Layer names (if you named your layers well)

It does NOT provide:
- Interaction behavior (you must describe this)
- Navigation destinations (you must describe this)
- State changes (you must describe this)
- Animation details (you must describe this)

**This is why behavior descriptions still matter.** Figma gives the "what it looks like." You give the "what it does."

## The 80/20 Rule

Match the Figma design at the layout and hierarchy level. Don't fight SwiftUI to match every pixel. Specifically:

**Match:**
- Content hierarchy (what's bigger, what's smaller)
- Layout direction (horizontal vs vertical groupings)
- Text content and approximate weight
- Color values for branded elements
- Overall spacing feel (tight vs airy)

**Let SwiftUI handle:**
- Exact padding values (system defaults are usually right)
- List row heights (system standard looks better than forced values)
- Safe area insets
- Navigation bar and tab bar styling
- Keyboard avoidance

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| "Match every pixel exactly" | You'll fight SwiftUI's layout system and end up with brittle, non-adaptive UI |
| Exporting PNGs and uploading them | Loses all structure. The MCP gives you parseable layout data |
| Referencing frames by description ("the one with the green button") | Ambiguous. Use URLs or node IDs |
| Sending the entire Figma file without specifying frames | Too much context. Reference specific frames |
| Expecting Claude Code to infer interactions from static designs | Figma frames are static. Always describe what tapping/swiping does |

## Verification

After Claude Code builds from a Figma frame:
1. Run in simulator
2. Compare side by side with Figma (split screen)
3. Check: Does the hierarchy feel right? (Not pixel-perfect, but right)
4. Check: Are all text elements present?
5. Check: Is the tint/accent color correct?
6. Check: Does it use native components? (no custom views where SwiftUI has a built-in)

Iterate with specific feedback: "The section headers need more top padding" or "The progress ring should be smaller, about 24pt diameter." Small, targeted adjustments converge faster than re-prompting from scratch.

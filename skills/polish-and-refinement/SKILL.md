---
name: polish-and-refinement
description: Take a working app from "it works" to "it feels right." Covers Figma matching, Liquid Glass, animations, haptics, dark mode, and the subjective quality that separates a good app from a great one. Use this skill after all screens are built and data persistence is working. This is where Figma enters the workflow if you designed polished comps.
---

# Polish and Refinement

The app works. Data persists. Navigation flows. Now make it feel like YOUR app.

## When to Use

- All screens are built and functional
- Data persistence is working
- You're ready to move from "works" to "feels great"
- You have Figma comps you want to match (optional)

## The Polish Checklist

Work through these categories. Each one is a focused Claude Code session or Conductor workspace.

### 1. Color and Tinting

```
Apply the app's color system:
- Primary tint color: [hex] throughout the app
- Verify all interactive elements use the tint (buttons, links, toggles)
- Check that semantic colors (destructive red, success green) still
  use system defaults
- Verify dark mode: tint should still be readable and vibrant
```

### 2. Liquid Glass (iOS 26)

```
Apply Liquid Glass material to:
- Navigation bars
- Tab bar
- [Any other chrome elements you want]

Do not apply Liquid Glass to:
- Content areas
- Cards or list rows
- Sheets (use system default presentation)
```

**Use Sosumi MCP** to look up the latest Liquid Glass APIs. These are new and evolving. Tell Claude Code:
```
Search Sosumi for "glassEffect" and "Liquid Glass" to get the
latest API documentation before implementing.
```

See `references/liquid-glass.md` for known patterns and the AvdLee SwiftUI Agent Skill repo for comprehensive Liquid Glass guidance.

**Known gotchas:**
- `.glassEffect()` must be applied AFTER background modifiers, not before
- System chrome (nav bars, tab bars) gets Liquid Glass automatically in iOS 26
- Do NOT manually apply `.glassEffect` to system chrome (doubles the effect)
- Leave intensity and tinting at system defaults for v1

### 3. Typography Hierarchy

```
Review typography across all screens:
- Screen titles should use .largeTitle or .title weight
- Section headers should use .headline
- Body content should use .body
- Secondary info should use .subheadline or .caption in .secondary color
- Numbers and counts should use .monospacedDigit to prevent layout shifting
```

### 4. Haptics

```
Add haptic feedback to:
- Destructive actions (context menu delete): .notification(.warning)
- Successful actions (project created, item saved): .notification(.success)
- Stitch counter tap: .impact(.medium)
- Toggle switches: already handled by native Toggle
- Pull to refresh: already handled by native .refreshable
```

### 5. Animations and Transitions

```
Verify default animations are smooth:
- Sheet presentations: system default (do not customize)
- Navigation pushes: system default (do not customize)
- List item appearance: use .animation with .default curve
- State changes (progress ring updating): animate with .spring

Do not add custom transition animations unless specifically requested.
System defaults are almost always better.
```

### 6. Empty States

```
Review every screen that displays a list:
- [ ] Projects home: empty state with illustration + CTA
- [ ] Explore: search with no results message
- [ ] [Other list screens]

Empty states should feel intentional, not like a bug. Center the
content vertically, use .secondary text color, and include a clear
action button if the user can do something about it.
```

### 7. Loading States

```
Add loading indicators where data takes time:
- Initial data fetch: ProgressView centered
- Image loading: placeholder with ProgressView overlay
- Save operations: disable the save button, show spinner

Use native ProgressView for everything. No custom spinners.
```

### 8. Error States

```
Handle common errors gracefully:
- Network failure (if applicable): retry button
- Save failure: alert with error message
- Delete failure: alert with error message
- Data corruption: graceful fallback, don't crash
```

### 9. Dark Mode

Run every screen in dark mode (Shift+Cmd+A in simulator):
- [ ] Text is readable on dark backgrounds
- [ ] Tint color is vibrant enough
- [ ] Images/illustrations look correct (not inverted or washed out)
- [ ] Custom colors defined in asset catalog have dark variants
- [ ] No hardcoded Color(.white) or Color(.black) that breaks in opposite mode

### 10. Dynamic Type

Test with large accessibility font sizes (Settings > Accessibility > Larger Text in simulator):
- [ ] Text doesn't truncate or overlap
- [ ] Layouts adapt (stacks switch from horizontal to vertical if needed)
- [ ] Buttons remain tappable
- [ ] Nothing breaks at the largest size

## Figma Matching (Optional Phase)

If you designed polished screens in Figma, this is where they enter:

```
Match [Screen Name] to this Figma frame: [URL/node ID].
The screen already works. Adjust only visual presentation:
spacing, typography weight, hierarchy, and accent color.
Do not change functionality or replace native components.
```

See the **figma-to-code** skill for detailed guidance on this workflow.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Polishing before the app works | You'll polish screens that get rebuilt during development |
| Custom animation curves for everything | Inconsistent with iOS. System animations feel more native |
| Overriding system dark mode colors | Apple's semantic colors are carefully tuned. Trust them |
| Adding decorative elements (shadows, gradients) that iOS doesn't use | Your app should feel like an iOS app, not a Dribbble shot |
| Spending hours on Liquid Glass intensity values | Ship with reasonable defaults. Tune in a future update |

## Verification

The best test is the "hand it to someone" test:
1. Install on a real device (not simulator)
2. Hand it to someone who has never seen the app
3. Watch them use it without guidance
4. Note where they hesitate, get confused, or something feels off
5. Those notes become your final polish list

## Time Estimate

4-6 hours total, spread across multiple focused sessions.

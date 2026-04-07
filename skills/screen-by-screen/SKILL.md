---
name: screen-by-screen
description: Build one screen at a time with clear descriptions and review cycles. This is the core build loop that takes the most time and produces the most value. Use this skill for every screen after scaffolding is complete. Works perfectly with parallel Conductor workspaces -- each screen is one workspace.
---

# Screen by Screen

The core build loop. Pick a screen. Describe it. Build it. Review it. Move on.

## When to Use

- Scaffolding is complete and committed
- You're ready to give each screen real content and functionality
- You're working in Conductor with parallel workspaces
- Any time you need to build or rebuild a specific screen

## The Loop

```
1. Pick a screen
2. Open a Conductor workspace (or Claude Code session)
3. Describe what the screen needs
4. Claude Code builds it
5. Review in simulator
6. Give feedback (2-3 rounds max)
7. Commit and merge
8. Pick next screen
```

## The Prompt Template

You don't need to paste code snippets. You don't need to reference Apple docs. You don't need to say "use SwiftUI." Your CLAUDE.md handles all of that. Just describe what the screen does.

### Structure

```
Build out [Screen Name]. Here's what it needs:

[2-5 sentences describing what the user sees and what they can do]

[Any specific interaction details that aren't obvious]

[Edge cases: empty state, error state, loading state]
```

### Example: Projects Home

```
Build out the Projects home screen. It's a scrollable list of the
user's active projects using LazyVStack. Each row shows the project
name in headline weight, a small circular progress ring showing
percent complete, and the yarn color as a small swatch circle.

Long press on any row opens a context menu with Edit, Duplicate,
Archive, and Delete. Delete should have a destructive role.

The plus button in the top right toolbar opens the New Project sheet.

When there are no projects, show a centered empty state with a short
message like "No projects yet" and a prominent button that also opens
the New Project sheet.
```

### Example: Settings

```
Build out the Settings main screen. Standard iOS grouped list pattern
with the following sections:

Account section: Profile row showing user name and avatar placeholder.
Preferences section: Default units (metric/imperial picker), color
theme toggle, notification preferences (pushes to sub-page).
About section: Version number, Terms of Service link, Privacy Policy
link, rate the app link.
Support section: Send Feedback (opens mail compose), Help Center
(opens Safari).
```

## What NOT to Include in Your Prompt

- "Use SwiftUI" (CLAUDE.md says this)
- "Make sure it's native" (CLAUDE.md says this)
- "Use SF Symbols" (CLAUDE.md says this)
- "Follow HIG spacing" (CLAUDE.md says this)
- Code snippets (unless you want a specific API behavior)
- Apple documentation links (unless it's a non-obvious API)

## When to Get Specific

Add specificity ONLY when you want non-default behavior:

- "Use .medium detent on this sheet, not .large"
- "The progress ring should be 24pt diameter"
- "Add haptic feedback (.impact medium) on the counter tap"
- "This list should use .insetGrouped style"
- "The delete confirmation should use a .destructive alert button"

If you don't specify, Claude Code uses defaults. Defaults are usually right.

## Feedback Rounds

Expect 2-3 rounds of feedback per screen. Keep feedback specific and small.

### Good Feedback
- "The rows feel too tight. Add more vertical padding."
- "Move the progress ring to the trailing side of the row."
- "The empty state button should be borderedProminent, not bordered."
- "Add a divider between the sections."

### Bad Feedback
- "It doesn't look right." (What specifically?)
- "Make it more like the design." (Which part? What's different?)
- "Can you improve it?" (Improve what?)

## Parallel Workspaces (Conductor)

Each screen is an independent workspace. Rules:

1. **Don't run two workspaces that edit the same file.** Common conflict: both editing ContentView or a shared model. Do shared work first in one workspace.

2. **Build independent screens in parallel.** Settings and Projects Home don't touch the same files. Run them simultaneously.

3. **Build dependent screens sequentially.** Project Detail depends on the Projects Home data model. Build Home first, merge, then start Detail.

4. **Merge frequently.** Don't let workspaces diverge for too long. Build a screen, review, merge, then start the next.

### Suggested Build Order

**Wave 1 (parallel):** All list/home screens across tabs. These establish the data models.

**Wave 2 (parallel):** Detail views and sub-pages. These consume the data models from Wave 1.

**Wave 3 (parallel):** Sheets and creation flows. These write to the data models.

**Wave 4 (sequential):** Custom components that multiple screens share.

## Time Estimates

| Screen Type | Estimate |
|---|---|
| Simple list screen (Settings, basic lists) | 20-30 min |
| Standard detail view | 30-45 min |
| Form/creation sheet with multiple inputs | 45-60 min |
| Screen with custom component | 60-90 min |
| Complex interactive screen | 60-90 min |

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Building 3+ screens in one prompt | Too much scope. Quality drops. Iterate one at a time |
| Providing a screenshot instead of a description | Descriptions give Claude Code actionable structure. Images are ambiguous |
| Skipping the simulator review | You'll accumulate issues that compound across screens |
| Trying to make it perfect on the first pass | Get it to 85%, merge, polish later. Perfectionism kills momentum |
| Rewriting the entire screen instead of giving targeted feedback | Small edits converge faster than full rewrites |

## Visual Preview Verification (MCP-Powered)

If you have the Xcode MCP Bridge set up (see mcp-setup skill), Claude Code can verify its own work visually before presenting it to you.

### The Automated Loop

After building a screen, Claude Code should:
1. Build the project via XcodeBuildMCP (catch compile errors)
2. Render a preview via Xcode MCP Bridge (see the visual output)
3. If the preview doesn't match the intent, iterate
4. If you provided a Figma frame, compare preview to design
5. Only present the screen to you after it passes visual check

### Add to Your CLAUDE.md

```markdown
## Build and Preview Loop
After building or modifying any screen:
1. Build with XcodeBuildMCP. Fix any compile errors.
2. Render a preview with RenderPreview. Check the layout.
3. If the preview looks wrong, fix and re-render.
4. Only tell me the screen is ready after build succeeds
   and preview looks correct.
```

This reduces your feedback rounds from 2-3 to 0-1 for most screens. Claude Code catches its own layout issues before you ever see them.

### When This Doesn't Work

- Xcode must be running for RenderPreview
- Views without `#Preview` macros can't be previewed
- Interactive behavior (taps, navigation) can't be verified via preview
- Dark mode and Dynamic Type variants aren't tested by default preview

For these cases, you still review in the simulator manually.

## Verification Per Screen

Before merging each screen:
- [ ] Run in simulator, tap every interactive element
- [ ] Check empty state (if applicable)
- [ ] Check dark mode (toggle in simulator: Shift+Cmd+A)
- [ ] Check landscape (if your app supports it)
- [ ] Confirm all navigation TO and FROM this screen works
- [ ] No build warnings related to this screen

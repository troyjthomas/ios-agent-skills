---
name: data-persistence
description: Wire up SwiftData models, queries, and cross-screen state after screens are built with placeholder content. Use this skill when screens look right but have no real data, when you need to define your data models, or when you need to ensure state updates propagate across the app. Typically done as a single focused session after Wave 1-3 of screen building.
---

# Data Persistence

Replace placeholder content with real, persistent data. Screens should already be built and looking right before you do this.

## When to Use

- Screens are built with placeholder/mock data
- You're ready to make data persist across app launches
- You need to wire up creation flows to actually save data
- You need list screens to show real, queried data

## Prerequisites

- Screen-by-screen build is mostly complete (at least Wave 1-2)
- Screens are merged into main branch
- CLAUDE.md specifies the persistence approach (SwiftData recommended)

## The Prompt

```
Set up SwiftData models for the app based on what the views are
already displaying. Create models for [list your main entities].
Replace all placeholder data with real SwiftData queries. Creation
flows should save to SwiftData. Lists should query from SwiftData.
Deletion should delete from SwiftData with confirmation.
```

### Example for Patchwork

```
Set up SwiftData models for Project, Pattern, and YarnColor.

A Project has: name (String), pattern (relationship to Pattern),
yarn colors (array of YarnColor), hook size (String), current
stitch count (Int), total stitches (Int), notes (String),
creation date (Date), is archived (Bool).

A Pattern has: name (String), difficulty (enum: beginner,
intermediate, advanced), category (String), instructions (String),
thumbnail image name (String).

A YarnColor has: name (String), hex value (String).

Replace all placeholder data in every view with real SwiftData
queries. The New Project sheet should save a new Project.
The Projects list should show @Query results. Deleting from
the context menu should delete from SwiftData with a
confirmation dialog. The stitch counter should update the
project's current stitch count in SwiftData.
```

## Model Design Rules

Tell Claude Code:

1. **Keep models simple.** No computed properties that could be stored values. No unnecessary relationships.

2. **Use optionals sparingly.** If a field is always present, don't make it optional. Required fields fail fast on creation.

3. **Relationships should be explicit.** "A Project HAS one Pattern" and "A Pattern can belong to MANY Projects."

4. **Enums over strings for fixed values.** Difficulty should be an enum, not a freeform string.

5. **Dates for timestamps.** Creation date, last modified date. SwiftData handles these cleanly.

## Cross-Screen State

The critical question: when data changes on one screen, does it update everywhere?

### Test These Scenarios

- Create a project in the sheet. Does it appear in the list immediately?
- Update a stitch count in the detail view. Does the progress ring update on the list?
- Delete a project. Does it disappear from the list? Does navigating back work?
- Archive a project. Does it leave the active list? (If you have an archive view, does it appear there?)

### Common Fix

If state isn't propagating, the issue is almost always that Claude Code created separate instances of data instead of querying from the shared SwiftData container. The fix:

```
The [ScreenName] view is not reflecting changes made on
[OtherScreen]. Make sure both views query from the same
SwiftData model container, not from separate state variables.
Use @Query for list views and pass the model object to detail views.
```

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Adding persistence before screens are built | You'll redesign models as screens evolve, wasting time |
| Using UserDefaults for complex data | UserDefaults is for preferences (bool, string). Use SwiftData for models |
| Making every field optional | You'll get nil crashes everywhere. Be explicit about required fields |
| Storing images in SwiftData | Store file paths or asset names. Not image data |
| Complex relationship hierarchies for v1 | Keep it flat. You can normalize later |

## Verification

- [ ] Create a new item, kill the app, relaunch. Is it still there?
- [ ] Edit an item on one screen. Navigate to another screen that shows it. Is it updated?
- [ ] Delete an item. Is it gone everywhere?
- [ ] Check that empty states show when no data exists (first launch)
- [ ] Verify the app doesn't crash on first launch (no existing data)

## Time Estimate

2-3 hours for a typical app with 3-5 models.

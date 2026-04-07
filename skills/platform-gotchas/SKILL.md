---
name: platform-gotchas
description: A living document pattern for capturing iOS platform issues as you discover them. Every time Claude Code hits a wall with an iOS API, a SwiftUI quirk, or a Liquid Glass behavior, add it to your CLAUDE.md immediately so it never happens again. Use this skill at the start of every project to seed known gotchas, and throughout development to capture new ones.
---

# Platform Gotchas

iOS development has quirks that Claude Code's training data may not cover, especially for iOS 26 and Liquid Glass. When you hit one, document it immediately so you never hit it again.

## The Pattern

Add a `## Known Gotchas` section to your CLAUDE.md. Every time you or Claude Code discovers a platform-specific issue, add it as a one-liner. This section grows over the life of your project.

```markdown
## Known Gotchas
- NO .background() before .glassEffect() — causes rendering issues
- NavigationStack inside TabView, not the other way around
- @Query must be used in views, not in ViewModels
- SwiftData @Model classes must be final
- [Add new gotchas here as you discover them]
```

## Seed Gotchas (Known Issues as of iOS 26)

Start every new project CLAUDE.md with these. Sourced from community experience:

### SwiftUI

```
- Use @Observable macro, not ObservableObject (iOS 17+)
- @Query properties only work in SwiftUI views, not in standalone classes
- NavigationStack must be inside TabView, never wrap TabView in NavigationStack
- .searchable modifier must be inside NavigationStack to render correctly
- .sheet and .fullScreenCover retain their content view, beware of state leaks
- GeometryReader is rarely needed — use layout priorities and flexible frames first
- .task modifier cancels automatically on view disappear (preferred over .onAppear)
- List selection requires NavigationSplitView on iPad, NavigationStack on iPhone
```

### Liquid Glass (iOS 26)

```
- .glassEffect() must be applied AFTER background modifiers, not before
- Liquid Glass on custom shapes may need .clipShape before .glassEffect
- System navigation bars and tab bars get Liquid Glass automatically with iOS 26
- Do not manually apply .glassEffect to system chrome — it doubles the effect
- Liquid Glass intensity and tinting are best left at system defaults for v1
- Use Sosumi MCP to check latest Liquid Glass API docs — these APIs are new and changing
```

### SwiftData

```
- @Model classes must be marked final
- SwiftData model containers must be set up in the App struct, not in individual views
- Relationships need explicit inverse declarations for reliable behavior
- Migration is automatic for simple changes but manual for renames or type changes
- Preview crashes with SwiftData often mean the preview needs its own ModelContainer
```

### Xcode / Build

```
- NEVER let Claude Code modify .pbxproj files (see xcode-integration skill)
- Clean build folder (Shift+Cmd+K) fixes most phantom build errors
- SwiftUI Previews crash ≠ app crash — preview bugs are often preview-specific
- Minimum deployment target must match all SPM dependencies
- Archive builds (for TestFlight) use Release configuration, which may behave differently
```

### Concurrency

```
- Use async/await for all asynchronous work, not completion handlers
- @MainActor for all UI-related code and ViewModels
- Swift 6 strict concurrency checking may flag warnings — address them, don't suppress
- Task cancellation should be handled explicitly in long-running operations
```

## How to Capture New Gotchas

When you hit an issue during development:

1. Fix the immediate problem
2. Identify the root cause (API quirk, modifier order, platform limitation)
3. Write a one-line rule that prevents it
4. Add it to CLAUDE.md under `## Known Gotchas`
5. Commit the CLAUDE.md update

### Prompt for Claude Code

```
Add this to the Known Gotchas section of CLAUDE.md:
"[One-line description of the issue and the correct behavior]"
```

This compounds. By the end of your project, your CLAUDE.md has a battle-tested list of rules that prevents every mistake you've encountered. When you start your next project, copy the gotchas section over as your seed.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| "I'll remember this for next time" | You won't. Claude Code definitely won't |
| Writing long explanations in gotchas | Keep it to one line. Claude Code needs rules, not essays |
| Only adding gotchas at the end of the project | Add them the moment you discover them. Mid-session |
| Not committing CLAUDE.md changes | If you revert to a previous commit, you lose the gotcha |

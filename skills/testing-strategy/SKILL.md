---
name: testing-strategy
description: Comprehensive testing approach for iOS apps built with Claude Code. Covers what Claude Code can test automatically (unit tests, build verification), what requires manual testing (interactive behavior, visual feel), and how to set up CI/CD with GitHub Actions. Use this skill during and after the build phase, and especially before shipping. Becomes critical for post-v1 updates where regressions hide.
---

# Testing Strategy

Three layers of testing, from fully automated to fully manual. Use all three.

## Layer 1: Automated Build Verification (Claude Code Does This)

Every time Claude Code finishes work on a screen or feature:

```markdown
## Build Verification (add to CLAUDE.md)
After every change:
1. Build with XcodeBuildMCP for iPhone simulator
2. If build fails, fix errors and rebuild
3. Do not present work as "done" if the build fails
```

This catches: syntax errors, missing imports, type mismatches, broken references.

This does NOT catch: runtime crashes, visual bugs, interaction problems.

## Layer 2: Automated Unit Tests (Claude Code Writes and Runs These)

### When to Add Tests

For v1, you don't need tests on every view. Focus tests on:
- **Data models** — Does creating, updating, deleting work correctly?
- **Business logic** — Does the stitch counter increment properly? Does progress calculate correctly?
- **State management** — Does updating a value in one place propagate everywhere?

Don't test views directly for v1. View testing in SwiftUI is complex and low-ROI for a first release.

### Asking Claude Code to Write Tests

```
Write unit tests for the Project model. Test:
- Creating a project with all required fields
- Updating the stitch count and verifying progress calculates
- Archiving a project
- Deleting a project

Use Swift Testing framework (not XCTest).
Place tests in Tests/[AppName]Tests/
Run the tests with XcodeBuildMCP after writing them.
```

### Test Conventions for CLAUDE.md

```markdown
## Testing
- Use Swift Testing framework (@Test, #expect) not XCTest
- Test file naming: [ModelName]Tests.swift
- Test location: Tests/[AppName]Tests/
- Run tests after writing them. Fix failures before committing.
- Focus tests on models and business logic, not views.
- Every model should have tests for create, update, delete.
```

### Running Tests

Claude Code with XcodeBuildMCP:
```
Run all tests. Report results. If any fail, analyze
the failure and fix the code (not the test, unless the
test expectation is wrong).
```

## Layer 3: Manual Testing (You Do This)

### What Only Humans Can Test

**Interactive feel:**
- Does the haptic feedback feel right on the stitch counter?
- Does the sheet dismiss gesture feel natural?
- Is the scroll speed comfortable on a long list?
- Do animations feel smooth or janky?

**Visual judgment:**
- Does the overall layout feel balanced?
- Is the typography hierarchy clear at a glance?
- Does dark mode look good (not just "work")?
- Does the app feel like an iOS app or a web app wearing iOS clothes?

**Real-world usage:**
- Can your wife complete the core task without asking you how?
- Does the app survive being backgrounded for 30 minutes?
- Does it handle a phone call interruption gracefully?
- Does it work on your specific iPhone model?

See the `device-testing` skill for the complete manual testing script.

## CI/CD with GitHub Actions (Optional, Recommended Post-v1)

### Why

When you merge PRs from Conductor, nothing verifies the merge didn't break something. For v1, you catch this manually. For ongoing development, automate it.

### Setup

Create `.github/workflows/build-and-test.yml`:

```yaml
name: Build and Test
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_26.3.app
      - name: Build
        run: xcodebuild build -scheme [AppName] -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
      - name: Test
        run: xcodebuild test -scheme [AppName] -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Tell Claude Code:
```
Create a GitHub Actions workflow that builds and tests the
project on every push to main and on every pull request.
Use the configuration from the testing-strategy skill.
```

### What CI Catches

- Build failures from merge conflicts
- Test regressions from new code
- Missing files or broken imports after branch merges

### What CI Doesn't Catch

- Visual regressions (layout changes)
- Performance regressions
- Interactive behavior changes

## The Testing Pyramid for Your App

```
        /\
       /  \     Manual Testing (you + testers)
      /    \    Visual, interactive, real-world
     /------\
    /        \   Automated Tests (Claude Code)
   /          \  Models, logic, state
  /------------\
 /              \  Build Verification (XcodeBuildMCP)
/________________\ Every commit, every merge
```

Wide base (build verification on everything), narrower middle (tests on critical logic), small top (manual testing on feel and experience).

## Interactive Testing Limitations (The Honest Gap)

Claude Code cannot test interactive behavior. RenderPreview gives it eyes on static layout, but it can't:
- Tap buttons and see what happens
- Scroll lists and check performance
- Test gesture recognizers (swipe, long press, pinch)
- Verify sheet dismiss behavior
- Test keyboard appearance and dismissal
- Navigate between screens

This gap means YOUR manual testing is essential, especially for:
- Custom components (stitch counter, pattern viewer)
- Navigation flows (tab switches, push/pop, sheet present/dismiss)
- Edge cases (rotating device, split screen on iPad, accessibility sizes)

No workaround exists for this yet. Plan 2-3 hours of manual testing before every TestFlight release.

---
name: post-launch
description: Everything that happens after v1 ships. Crash reporting setup, TestFlight feedback processing, version management, the update cycle, and how to maintain an app without breaking what already works. Use this skill after your first App Store submission and for all subsequent updates.
---

# Post-Launch

Your app is live. Now keep it alive. This skill covers the ongoing lifecycle.

## Crash Reporting (Set Up Before v1 Launch)

You need to know when your app crashes in the wild. Set this up before TestFlight distribution.

### Option 1: Firebase Crashlytics (Recommended for Solo/Small)

Tell Claude Code:
```
Add Firebase Crashlytics to the project using Swift Package Manager.
Configure it in the App struct's init. Follow the Firebase iOS
setup guide. Do NOT modify the .xcodeproj file for build phases.
I'll add the build phase script in Xcode manually.
```

**Important:** Firebase requires a GoogleService-Info.plist file and a build phase script. Claude Code should create the Swift integration code, but you add the plist and build phase in Xcode manually (.pbxproj safety rule).

### Option 2: Apple's Built-In Crash Reports

App Store Connect > Your App > Analytics > Crashes. No setup required, but reports are delayed (24-48 hours) and less detailed. Good enough for v1 if you don't want to add Firebase.

## TestFlight Feedback Loop

### Collecting Feedback

TestFlight has built-in feedback: testers take a screenshot, it prompts them to send feedback with the screenshot attached. This arrives in App Store Connect > TestFlight > Feedback.

Tell your testers (your wife, friends):
- "If something feels wrong, screenshot it and submit feedback via TestFlight"
- "If something crashes, just tell me what you were doing when it crashed"

### Processing Feedback into Tasks

After collecting feedback, sit down with Claude:

```
Here's the feedback from TestFlight this week:
- [Tester] said the project list loads slowly with 20+ items
- [Tester] said the delete confirmation doesn't appear sometimes
- [Tester] said dark mode makes the progress ring hard to see

Turn these into specific, actionable tasks I can give to
Claude Code. Prioritize by severity (crashes > broken features
> visual issues > nice-to-haves).
```

Claude helps you triage. You take the prioritized list into Conductor.

### The Feedback-to-Fix Cycle

```
1. Collect TestFlight feedback (ongoing)
2. Triage with Claude chat (weekly or per batch)
3. Prioritize: crashes > bugs > polish > features
4. Create Conductor workspaces for each fix
5. Build, test, merge
6. Bump version, archive, upload to TestFlight
7. Notify testers of new build
8. Repeat
```

## Version Management

### Semantic Versioning

```
Major.Minor.Patch  (e.g., 1.2.3)

Major: Breaking changes or major redesign (2.0.0)
Minor: New features (1.1.0, 1.2.0)
Patch: Bug fixes (1.0.1, 1.0.2)
```

### Build Numbers

Build numbers increment with every TestFlight upload. They don't need to be meaningful:
- Version 1.0.0, Build 1 (first TestFlight)
- Version 1.0.0, Build 2 (fixed a bug, re-uploaded)
- Version 1.0.1, Build 3 (first patch release)

Tell Claude Code:
```
Bump the version to [X.Y.Z] and increment the build number
in the Xcode project settings. Update the "What's New" text
in APP_SPEC.md with a brief changelog.
```

## The Update Cycle

### Bug Fix Release (Patch)

```
1. Identify the bug (crash report, TestFlight feedback, your own testing)
2. Open one Conductor workspace
3. Describe the bug and expected behavior
4. Claude Code fixes, writes a test to prevent regression
5. Build and test via XcodeBuildMCP
6. Manual verification on device
7. Bump patch version (1.0.0 → 1.0.1)
8. Archive and upload to TestFlight
9. After tester verification: release to App Store
```

### Feature Addition (Minor)

```
1. Design the feature (Figma or description)
2. Update APP_SPEC.md with the new screen/flow
3. Update CLAUDE.md if new conventions are needed
4. Use the screen-by-screen build process (same as v1)
5. Add tests for new logic
6. Regression test: run full test suite, manual check of existing features
7. Bump minor version (1.0.1 → 1.1.0)
8. Archive, TestFlight, verify, release
```

### The Regression Risk

Every change can break something that already works. As your app grows:

**Automated regression prevention:**
- Unit tests on all models and business logic
- CI/CD runs tests on every PR (see testing-strategy skill)
- Build verification on every commit

**Manual regression prevention:**
- After every feature addition, test the core flow end-to-end
- Keep a "smoke test" checklist: create a project, edit it, delete it, navigate all tabs
- Run this checklist before every TestFlight upload

## App Store Updates

### Submitting an Update

Same process as initial submission but faster:
1. Bump version and build number
2. Archive and upload from Xcode
3. In App Store Connect: create a new version
4. Update "What's New" text
5. Update screenshots ONLY if UI changed significantly
6. Submit for review

### Review Times for Updates

Updates typically review faster than initial submissions (12-24 hours vs 24-48 hours). But plan for the worst case.

### Expedited Reviews

If you shipped a critical bug and need the fix live urgently, Apple offers expedited review requests. Use sparingly: one per year as a guideline.

## iCloud Sync (When You Need It)

If users need data to sync across devices:

Tell Claude Code:
```
Set up CloudKit sync for SwiftData. Enable the CloudKit
capability in the project. Use the automatic sync provided
by SwiftData + CloudKit. Test by installing on two devices
with the same Apple ID.
```

**Caveats:**
- Requires Apple Developer Program (paid)
- Requires CloudKit capability enabled in Xcode (manual step)
- Sync conflicts can occur with simultaneous edits
- Testing requires two real devices or a device + simulator

This is a feature addition, not a v1 requirement. Add it when users ask for it.

## Analytics (When You Want Insight)

For understanding how people use your app:

### Lightweight Option: App Store Connect Analytics
Free, built-in. Shows: downloads, sessions, retention, crash rate, device breakdown. No code required.

### More Detailed: Firebase Analytics or TelemetryDeck
Tell Claude Code:
```
Add [Firebase Analytics / TelemetryDeck] via SPM. Log these events:
- app_open
- project_created
- project_completed
- stitch_count_milestone (every 100 stitches)
- feature_used (with feature name parameter)
```

TelemetryDeck is privacy-friendly and lightweight. Good for indie apps.

## The Ongoing Mobile Workflow

Post-launch, your phone becomes more important:

**Morning (phone, Dispatch):**
"Check for new TestFlight feedback and crash reports. Summarize anything urgent."

**During the day (phone, Claude Chat):**
Plan the next update. Describe new features. Draft the changelog.

**Evening (Mac, Conductor):**
Build the fixes and features planned during the day.

**Before bed (phone, Remote Control):**
Monitor builds, approve merges, send to TestFlight.

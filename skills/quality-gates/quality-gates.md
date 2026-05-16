---
name: quality-gates
description: Session-end checklist that catches what commit-time hooks miss. Verifies the build passes, tests run, no binaries were accidentally staged, no Xcode project files were modified, and no force unwraps were introduced. Run before declaring a session done or before opening a PR.
---

# Quality Gates

The `automated-review` skill catches issues at commit time. This skill catches issues at session boundaries, which is a different problem.

A session can produce dozens of edits, then a single commit at the end. Or it can produce many commits across many files. Either way, there are checks that only make sense once, at the end, against the whole working tree:

- Does the project still build?
- Do the tests still pass?
- Did anything get staged that shouldn't be there?
- Did Claude touch files it should never touch?

This skill is the checklist for those questions. Run it before saying a session is done.

## What It Checks

Six gates, ordered by severity. Any gate can fail. The skill reports all failures, not just the first one, so you fix everything in one pass.

### Gate 1: Build

Runs `xcodebuild` (or via the XcodeBuildMCP if configured) against the project's primary scheme. Catches:

- Syntax errors that slipped past type-checking in the editor
- Missing imports
- Broken protocol conformances after refactors
- Project file references that point at deleted files

This is the most important gate. Everything else is moot if the project doesn't compile.

### Gate 2: Tests

Runs `swift test` on the project's test targets, or `xcodebuild test` for app-target tests. Catches:

- Regressions in behavior the tests were meant to lock in
- New code without test coverage where the project's `testing-strategy` skill says coverage is expected
- Tests that were broken in the editing session but never run

If the project has no tests, this gate is skipped with a NOTE.

### Gate 3: No `.pbxproj` modifications

The Xcode project file is a "never event" in this stack. Modifying it manually corrupts the project. Files should be added via XcodeBuildMCP or Xcode itself, not by Claude editing the pbxproj.

Runs `git status --porcelain | grep -E '\.pbxproj|\.xcodeproj/project\.xcworkspacedata'`. If anything matches, the gate fails with a BLOCKER.

### Gate 4: No force unwraps introduced

Runs a diff of all `.swift` files in the working tree and checks for new force unwraps (`!` operators outside of safe contexts like `try!` in tests or explicit `as!` casts that are clearly intentional).

The pattern is conservative because force unwraps in test code, in DI setup, and in some Swift type system corners are legitimate. The gate flags anything that looks new and lets you confirm or override.

### Gate 5: No accidentally staged binaries or junk

Scans staged and untracked files for:

- `.DS_Store`
- `*.xcuserstate` (Xcode user state files)
- Files larger than 1 MB that aren't in `Assets.xcassets` (likely binary artifacts that shouldn't be in git)
- Files in `build/`, `DerivedData/`, or other build output directories
- `.env` files or anything matching common secret patterns

This is the "did Claude commit something weird while I wasn't looking" gate.

### Gate 6: No TODOs without owners

Scans staged Swift files for `TODO` and `FIXME` comments without a trailing identifier (initials, ticket number, or username in parentheses). Comments like `// TODO: handle error case` are flagged; `// TODO(troy): handle error case in PATCH-204` are allowed.

This gate is a MINOR severity, not a blocker. It exists to keep technical debt visible.

## How to Run

**Manually**, at session end:

```
Use the quality-gates skill on the current working tree.
```

The agent will work through each gate, report results in a structured format, and tell you what to fix.

**Via the helper script:**

```bash
sh ./scripts/quality-gates.sh
```

The script runs the gates that don't require Claude (build, test, file checks) and prints results. Use this in CI or in a shell alias if you want a quick check without invoking the agent.

**As a session-end ritual:**

Add this to your project's CLAUDE.md:

```markdown
## Session-end checklist

Before declaring a session done, run the quality-gates skill. Do not say "Session complete" until all gates pass or every failure has an explicit override.
```

This trains the agent to invoke it without being asked. Especially useful for long autonomous sessions where you wake up to a PR and want confidence the work is shippable before you read a single line.

## Report Format

The skill produces a structured report:

```
═══ QUALITY GATES REPORT ═══

Gate 1: Build              ✅ PASS
Gate 2: Tests              ✅ PASS  (12 tests, 0 failures)
Gate 3: No .pbxproj edits  ✅ PASS
Gate 4: No new force unwraps  ❌ FAIL
  - Views/PatternEditor.swift:42  let pattern = patterns.first!
Gate 5: No staged binaries  ✅ PASS
Gate 6: TODOs have owners  ⚠️  WARN
  - Models/Stitch.swift:18  // TODO: support knitting
  - Views/PaletteRow.swift:9  // FIXME: color isn't propagating

═══ VERDICT ═══

1 BLOCKER, 2 WARN. Do not declare session done.

Fix Gate 4 before continuing. Decide on Gate 6 (add owner or remove TODO).
```

## When to Skip Gates

Gates can be overridden explicitly, but never silently.

- **Gate 1 (Build)** should never be skipped. A broken build is a broken session.
- **Gate 2 (Tests)** can be skipped with `--skip-tests` if you're mid-refactor and intend to fix tests in the next session. Note this in your commit.
- **Gate 3 (.pbxproj)** can be overridden if you genuinely added a new file via Xcode's UI mid-session and the change is intentional. Inspect the diff manually first.
- **Gate 4 (force unwraps)** can be overridden per-line with a `// quality-gates: force-unwrap-ok — <reason>` comment.
- **Gate 5 (junk files)** rarely needs an override. If something legitimately needs to be 5 MB and in git, add it to `.gitattributes` with `binary` and update the gate's allowlist.
- **Gate 6 (TODO owners)** can be skipped entirely if the project doesn't care; remove it from the gate list in `scripts/quality-gates.sh`.

## Companion Skills

- [`automated-review`](../automated-review/automated-review.md) — Commit-time hooks. Use both.
- [`testing-strategy`](../testing-strategy/testing-strategy.md) — Defines what good test coverage looks like for this project.
- [`code-reviewer`](../../agents/code-reviewer.md) — The eight-axis review the automated-review skill runs.

## Why a Separate Skill

`automated-review` runs on every commit. That's the right granularity for code-level checks but the wrong granularity for project-level checks. Running `xcodebuild` and the full test suite on every commit would be slow and noisy. Running them once at session-end is the right time.

Quality gates are also the place to put checks that are project-state-dependent rather than diff-dependent: "did the project lose a file it shouldn't have," "is the .gitignore still doing its job," "is there a build artifact in the wrong place." These don't fit a per-commit review model.

Two skills, two scopes. Use both.

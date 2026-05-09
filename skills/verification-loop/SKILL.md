---
name: verification-loop
description: How to actually prove a UI change works before claiming it does. Covers AX-coordinate snapshots over screenshots, tap-by-label over coordinates, simulator state resets between iterations, and the build → screenshot → AX → math-check loop. Use this skill alongside testing-strategy whenever you're verifying a UI fix on simulator. Required reading before claiming any visual fix is "done."
---

# Verification Loop

The **testing-strategy** skill covers automated build verification, unit tests, and manual testing — three layers that prove the code is correct, the logic is correct, and the user experience is correct on a real device.

This skill covers the layer in between: **the visual verification loop you run on simulator while iterating**. It's where most "I fixed it!" → "actually no you didn't" cycles happen, because eyeballing a screenshot is unreliable for layout bugs.

## When to Use

- Iterating on a layout, padding, alignment, or sizing fix
- Hooking up a new gesture and need to confirm it fires
- Diagnosing a visual bug from a user screenshot
- Before claiming any UI fix is "done" — required reading

## Why Screenshots Alone Aren't Enough

Humans cannot reliably eyeball:
- 16pt vs 21pt padding
- 2pt off-center drift
- 40pt vs 44pt button heights
- A view extending 4pt past where it should

Every one of those is a real bug that ships in apps that "looked fine on simulator." The verification loop replaces "looks fine" with "the AX frame says width 396.66pt, parent says width 402, so right margin is 5.34pt — symmetric with the left's 24pt? No, off by 19pt — fix it."

## The Four-Step Loop

After every UI change, before claiming a fix is done:

### 1. Build clean

```
Build with XcodeBuildMCP. If status is SUCCEEDED with zero errors,
proceed. If SourceKit reports phantom diagnostics that don't show
up in the actual build log (e.g. "Cannot find type X" while the
build log shows zero errors), ignore them — see the
xcode-integration skill for the SourceKit-lag distinction.
```

### 2. Screenshot

```
Capture the screen state. Useful for "does it look right?" gut-check
but NEVER sufficient on its own for layout claims.
```

### 3. AX snapshot — the critical step

XcodeBuildMCP's `snapshot_ui` returns the accessibility tree with **every visible element's `AXFrame` (x, y, width, height) in real screen coordinates.** Use this to verify layout numerically:

```
Get the AX snapshot. For the view you changed, locate its frame
in the output. Compare against:
- The parent's frame (is the child centered? offset? overlapping?)
- Sibling frames (is spacing equal? is alignment matching?)
- Screen bounds (is anything off-screen?)
- The expected values from the design (does padding match the spec?)
```

Worked example — verifying a button is centered on a 402pt-wide screen:

```
Button AXFrame: x=80, width=242
- Right edge: 80 + 242 = 322
- Distance from screen right (402): 402 - 322 = 80
- Distance from screen left: 80
- Difference: 0 → centered ✓
```

If the math doesn't check out, the fix isn't done. No "looks centered enough" — center is a number.

### 4. Math-check, then commit

```
If the AX numbers match the design spec, commit. Push. Open the PR.
If they don't match, the fix isn't done — go back to step 1 with
the next iteration.
```

## Tap by Label / ID, Never by Coordinates

When automating taps to verify a flow:

```
Prefer:
  tap by accessibility id (AXUniqueId)
  tap by accessibility label (AXLabel)

Avoid:
  tap at coordinates (x, y)
```

Coordinates break the moment layout changes. Labels survive layout changes — if the user-facing label is the same after your fix, the test still works. If the label changed, that's a UX-meaningful change worth a separate review.

When AX targeting fails (rare), THEN fall back to coordinates — but treat that as a temporary fallback, not a default.

## Resetting Simulator State Cleanly

Many UI flows (welcome screens, first-run prompts, onboarding) only fire on first launch. Verifying them iteratively means resetting the launch flag between iterations.

```bash
# Terminate the running app
xcrun simctl terminate <SIMULATOR_UDID> <BUNDLE_ID>

# Relaunch with a UserDefaults override that resets the first-run flag
xcrun simctl launch --terminate-running-process <SIMULATOR_UDID> <BUNDLE_ID> -hasSeenWelcome NO
```

`@AppStorage` keys can be overridden as launch arguments by prefixing with `-`. Use the same keys your `@AppStorage` properties use. The override only applies to the current launch — your normal first-launch detection logic still runs.

For state that's NOT in `@AppStorage` (in-memory state, SwiftData), use `xcrun simctl uninstall` followed by a fresh install — heavier, but guarantees a clean slate.

## A Verification-Loop Template

A reusable prompt to give your coding agent at the end of any UI fix:

```
Before claiming this fix is done:

1. Build with XcodeBuildMCP. Confirm SUCCEEDED with zero errors.
   (Phantom SourceKit diagnostics that don't appear in the build
   log are SourceKit lag — ignore.)
2. Screenshot the screen state. Attach to the verification report.
3. Run snapshot_ui. For each view you changed, report the AXFrame
   coordinates. Verify against the design spec or the parent
   container math (centered? aligned? padded equally?).
4. If the math doesn't check out, iterate. Don't claim "done" on
   a fix that hasn't been numerically verified.

Verification report format:
- Build status: [SUCCEEDED / FAILED]
- Screenshot path: [path]
- Modified view AXFrame: [x, y, width, height]
- Math check: [show your work — what was the expected number, what
  was the actual number, by how much do they differ]
- Result: [PASS / FAIL with next steps]
```

## When to Skip the AX Step

The AX step is required for layout claims (padding, alignment, sizing, position). It's optional for:

- Pure logic changes that don't touch layout (e.g. a state-management refactor)
- Non-UI changes (data layer, networking)
- Fixes where the visual result is binary (a view either appears or it doesn't)

If in doubt, run the AX step. It costs 30 seconds and catches bugs that ship.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Eyeballing the screenshot to decide if padding is symmetric | Humans see 16pt and 21pt as the same. The user reports the bug a week later |
| Tapping by coordinates because "label targeting is fiddly" | Layout changes break the test; labels survive layout changes |
| Skipping the AX step on "obvious" fixes | The "obvious" fix is where regressions hide |
| Claiming a fix is done before pushing | Reviewer can't reproduce; you've shipped a half-fix |
| Running verification only on the simulator you usually use | Mini, SE, and 17 Pro Max have different widths; layout bugs love smaller screens |

## Verification

For this skill itself:
1. Pick a recent UI fix you made and re-verify it using the four-step loop
2. Compare what the AX numbers tell you to what your initial gut-check said
3. If they disagree, the loop just paid for itself

## Time Estimate

The loop adds 1–3 minutes per iteration. Saves 30+ minutes of "I shipped it and the user found the bug" debugging downstream.

# Code Quality

## The Problem

AI agents write a lot of code. They write it fast. They write it confidently. And without a forcing function, they leave behind patterns that compound into problems:

- The same logic implemented three different ways across three files
- Defensive nil checks on values that are already non-optional
- Generic variable names (`data`, `result`, `item`) where domain-specific names would communicate intent
- Comments that restate the code instead of explaining why
- Force unwraps that work today and crash tomorrow
- Deprecated APIs that compile but won't survive the next iOS release
- Components inlined in views that should live in `/Components`

None of these are wrong in isolation. Each one is a small thing. Together, they make a codebase that a future human cannot maintain, that an agent six months from now cannot reason about cleanly, and that any tenured engineer can spot as AI-written within seconds.

If you're shipping to the App Store, that's a problem. If you're building something you care about, it's a bigger one.

## The Standard

The bar this repo holds for code quality is simple:

**A tenured iOS engineer reading the code should not be able to tell it was written by an agent.**

Not "indistinguishable from professional code in a vacuum." Indistinguishable from professional code in this specific codebase, by this specific team, working in this specific style. That's a higher bar than most agent-generated code clears, and it's the bar that matters if the code is going to keep working as the project grows.

## How These Skills Achieve It

Three layers, working together. Each one catches what the others miss.

### Layer 1: The code-reviewer agent

The eight-axis review. Manual or automated. Catches issues by reading the code and applying senior-engineer judgment.

- Correctness, readability, architecture, security, performance: the standard five
- Redundancy and DRY: catches the "you could trim thousands of lines if you merged these" problem
- Modernity: catches deprecated APIs and old idioms
- Agent smell: catches the patterns nobody else checks for, the ones that make AI code look like AI code

The agent's full prompt is in [`agents/code-reviewer.md`](../agents/code-reviewer.md). Read it. Edit it for your project's specific conventions. It's a contract between you and the reviewer.

### Layer 2: The automated-review skill

The discipline layer. Wires the code-reviewer agent into Claude Code hooks so it runs without anyone remembering to invoke it.

- After every Swift file edit: SwiftFormat and SwiftLint auto-fix trivial issues so they never reach the reviewer
- Before every `git commit`: the reviewer runs on staged changes and blocks the commit on BLOCKER-severity findings

Manual review is a habit. Habits erode. Hooks don't. See [`skills/automated-review/automated-review.md`](../skills/automated-review/automated-review.md).

### Layer 3: The quality-gates skill

The session-end checklist. Covers what the other two layers don't:

- Build verification before declaring a session done
- Test runs on affected targets
- Accidental binary commit detection
- `.pbxproj` modification detection (the "never event" in this stack)
- Force-unwrap diff check

These checks make sense at session boundaries, not at commit boundaries. See [`skills/quality-gates/quality-gates.md`](../skills/quality-gates/quality-gates.md) (coming in Round 2).

## Recommended Setup

For any project you intend to ship:

1. Read `agents/code-reviewer.md` and confirm the eight axes match what you care about. Edit if not.
2. Install the `automated-review` skill in the project. Verify hooks fire with a deliberate bad commit.
3. Add `.swiftformat` and `.swiftlint.yml` at the project root if your project has style preferences beyond defaults.
4. Run a manual full-tree review before each TestFlight build: "Use the code-reviewer agent on the entire project."

For prototypes and throwaway demos: skip all of this. Quality gates have a cost; small projects don't earn it back.

## What Quality Is Not

A few things this system deliberately does not do:

- **It does not enforce an architecture.** Not MVVM, not VIPER, not Clean. The repo's [design principles](../README.md#design-principles) lean native and pragmatic. Architecture flame wars are out of scope.
- **It does not measure test coverage.** Coverage is a poor proxy for confidence. The `testing-strategy` skill covers what to test and how; this layer doesn't gate on coverage numbers.
- **It does not block on style preferences.** SwiftFormat and SwiftLint handle style automatically. Style is solved. The reviewer focuses on substance.
- **It does not replace human judgment.** The reviewer is a forcing function, not a final authority. You still ship the code. The hooks just make sure you ship code you can defend.

## When Code Smell Is Acceptable

Sometimes the right thing is the dirty thing. Spike code, throwaway prototypes, last-minute demo polish. The system allows it: `git commit --no-verify` bypasses the hook entirely.

Use that escape hatch sparingly. If you find yourself reaching for it more than once a day, either the hook is too strict (relax it) or the work is below the standard the project deserves (slow down).

## Further Reading

- [`AvdLee/SwiftUI-Agent-Skill`](https://github.com/AvdLee/SwiftUI-Agent-Skill) — Antoine van der Lee's SwiftUI best-practices skill, including a bundled `xctrace` toolchain for Instruments-based performance review
- [`rshankras/claude-code-apple-skills`](https://github.com/rshankras/claude-code-apple-skills) — Ravi Shankar's 100+ skills, including a coding-best-practices reviewer with SwiftLint rule recommendations
- [Claude Code hooks documentation](https://docs.claude.com) — the underlying mechanism for the automated layer

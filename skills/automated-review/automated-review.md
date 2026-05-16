---
name: automated-review
description: Wires the code-reviewer agent into Claude Code hooks so quality checks run automatically. Auto-formats Swift files after every edit, and runs a full review on staged changes before any git commit. Blocks commits on BLOCKER-level findings.
---

# Automated Review

The code-reviewer agent is only as useful as the discipline behind invoking it. This skill removes the discipline requirement entirely. Two hooks, two scripts, one settings file, and quality checks happen on their own.

## What It Does

**After every Swift file edit:**
- Runs `swiftformat` to auto-fix style
- Runs `swiftlint --fix` to auto-fix lintable issues
- Silent unless something fails; never interrupts flow

**Before every `git commit`:**
- Runs the code-reviewer agent on staged Swift files
- Parses output for severity
- Blocks the commit if any BLOCKER-level issues are found
- Warns but allows commit on MAJOR-level issues
- Lets MINOR and NOTE through silently

The result: you cannot accidentally commit code that crashes, leaks secrets, or destroys data. You can still ship work in progress.

## Why This Matters

AI agents write fast and write often. Manual review is a discipline that erodes under time pressure. Hooks are deterministic. They run every time, in the same way, without anyone remembering to invoke them.

This is the difference between a codebase that drifts toward "AI slop" and one that stays shippable.

## Setup

Three steps. Once per project.

### 1. Install dependencies

```bash
# SwiftFormat and SwiftLint
brew install swiftformat swiftlint
```

If you're on a fresh MacBook, this is also a good moment to verify Xcode command-line tools are installed: `xcode-select --install`.

### 2. Copy the hook configuration

From the repo root of `ios-agent-skills`, copy the example settings into your project:

```bash
cp /path/to/ios-agent-skills/.claude/settings.toml.example \
   /path/to/your-project/.claude/settings.toml
```

Then copy the two helper scripts:

```bash
mkdir -p /path/to/your-project/scripts
cp /path/to/ios-agent-skills/scripts/pre-commit-review.sh \
   /path/to/your-project/scripts/
cp /path/to/ios-agent-skills/scripts/post-edit-format.sh \
   /path/to/your-project/scripts/
chmod +x /path/to/your-project/scripts/*.sh
```

### 3. Verify

Open Claude Code in your project and run:

```
/hooks
```

You should see both hooks listed: a `PostToolUse` matcher on Swift file edits, and a `PreToolUse` matcher on `git_commit`.

To test the commit hook is wired correctly, make a deliberately bad change (force-unwrap a nil optional in a non-critical file) and try to commit. It should be blocked with a BLOCKER message and a citation of the line.

## What Each Piece Does

### `.claude/settings.toml`

Two `[[hooks]]` entries. The first matches `tool_name = "edit_file"` and `file_paths = ["*.swift"]`, running `post-edit-format.sh` after the edit completes. The second matches `tool_name = "git_commit"` (PreToolUse), running `pre-commit-review.sh` before the commit is executed. If `pre-commit-review.sh` exits non-zero, the commit is blocked.

### `scripts/post-edit-format.sh`

Reads `$CLAUDE_FILE_PATHS`, filters to `.swift` files, runs `swiftformat` and `swiftlint --fix` on each. Exits zero unless something catastrophic happens (binary missing, permissions error). Designed to never block flow.

### `scripts/pre-commit-review.sh`

Captures `git diff --cached --name-only -- '*.swift'`. If the list is empty, exits zero. Otherwise, invokes the code-reviewer agent on those files using Claude Code's headless mode (`claude -p`). Parses the response for the string `BLOCKER`. If found, prints the review and exits 1. Otherwise prints a one-line OK and exits 0.

The full script is short enough to read end-to-end. If you want different severity gating (block on MAJOR too, or only on specific axes), edit the script directly.

## Configuration

### Block on MAJOR as well as BLOCKER

In `pre-commit-review.sh`, change:

```bash
if echo "$REVIEW" | grep -q "BLOCKER"; then
```

to:

```bash
if echo "$REVIEW" | grep -qE "BLOCKER|MAJOR"; then
```

### Skip the hook for work-in-progress commits

Use `git commit --no-verify` to bypass the hook entirely. Reserve this for actual WIP. If you find yourself reaching for it on real commits, the hook is wrong, not the work.

### Different format/lint rules

Drop a `.swiftformat` and `.swiftlint.yml` at your project root. Both tools pick them up automatically. The hook does not impose specific rules; it runs whichever rules your project defines.

## When to Skip This Skill

- You are building a throwaway prototype that will never ship and never be read by another human
- You are pairing live with Claude Code and reviewing every change yourself in real time
- The project is so small that the overhead of installing SwiftFormat and SwiftLint exceeds the value

For anything heading to TestFlight or the App Store: install it.

## Companion Skill

[`quality-gates`](../quality-gates/quality-gates.md) covers the broader hygiene that runs at session-end rather than at commit-time: build verification, test runs, accidental binary checks, pbxproj-modification detection. Use both together.

## Troubleshooting

**Hook doesn't fire.** Check `.claude/settings.toml` is at the project root, not inside any subdirectory. Run `/hooks` in Claude Code to verify it loaded.

**SwiftFormat or SwiftLint not found.** The hook script uses `command -v` to check. If the binaries are installed via Homebrew on Apple Silicon, ensure `/opt/homebrew/bin` is on the PATH inside the shell environment Claude Code uses. If in doubt, run `which swiftformat` from a terminal and hard-code that path in `post-edit-format.sh`.

**Pre-commit review takes too long.** The reviewer agent runs on staged diffs only, not the whole codebase, so this should be seconds, not minutes. If it's slow, you may be staging too many files at once. Break the commit into smaller logical pieces, which is good practice regardless.

**Claude Code headless mode prompts for input.** Make sure `claude -p` is run with the right flags in `pre-commit-review.sh`. Update the script's invocation if your Claude Code version uses different syntax; the broad pattern is to pipe the prompt and staged diff into a non-interactive review call.

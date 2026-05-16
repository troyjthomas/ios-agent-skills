#!/bin/bash
#
# pre-commit-review.sh
#
# Runs the code-reviewer agent on staged Swift files before a git commit.
# Invoked by the PreToolUse hook in .claude/settings.toml.
#
# Exits 1 (blocking the commit) if any BLOCKER-level issues are found.
# Exits 0 with a warning if only MAJOR issues are found.
# Exits 0 silently if no significant issues are found.
#
# To also block on MAJOR, change the grep on the BLOCK_PATTERN line below.

set -uo pipefail

# Add Homebrew's Apple Silicon path so the claude CLI is found.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Severity that should block a commit.
# To also block on MAJOR issues, change to: BLOCK_PATTERN="BLOCKER|MAJOR"
BLOCK_PATTERN="BLOCKER"

# Get staged Swift files.
STAGED_SWIFT=$(git diff --cached --name-only --diff-filter=ACMR -- '*.swift' 2>/dev/null)

if [ -z "$STAGED_SWIFT" ]; then
  # No Swift changes to review.
  exit 0
fi

# Verify claude CLI is available.
if ! command -v claude >/dev/null 2>&1; then
  echo "⚠️  pre-commit-review: claude CLI not found on PATH; skipping review."
  echo "    To enable automated review, install Claude Code and ensure it's on PATH."
  exit 0
fi

# Build the review prompt.
FILES_LIST=$(echo "$STAGED_SWIFT" | tr '\n' ' ')

PROMPT="Use the code-reviewer agent to review the staged changes in these files: $FILES_LIST

Focus on the staged diff (git diff --cached), not the entire file contents.
Report findings using the format defined in agents/code-reviewer.md.
End with a one-line verdict: 'Ready to merge', 'Ready to merge after fixes', or 'Do not merge'."

echo "🔍 Running code review on staged Swift files..."
echo ""

# Run Claude Code in headless mode.
REVIEW=$(claude -p "$PROMPT" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "⚠️  pre-commit-review: claude CLI returned non-zero exit code; allowing commit."
  echo "    Review output:"
  echo "$REVIEW"
  exit 0
fi

echo "$REVIEW"
echo ""

# Check for blocking severity.
if echo "$REVIEW" | grep -qE "$BLOCK_PATTERN"; then
  echo "❌ Commit blocked by code-reviewer ($BLOCK_PATTERN issues found)."
  echo "   Fix the issues above and try again."
  echo "   To bypass in genuine WIP cases: git commit --no-verify"
  exit 1
fi

# Warn on MAJOR but don't block.
if echo "$REVIEW" | grep -q "MAJOR"; then
  echo "⚠️  MAJOR issues found but not blocking. Consider addressing before TestFlight."
fi

echo "✅ Code review passed."
exit 0

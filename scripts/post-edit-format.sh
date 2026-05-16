#!/bin/bash
#
# post-edit-format.sh
#
# Runs swiftformat and swiftlint --fix on Swift files Claude Code just edited.
# Invoked by the PostToolUse hook in .claude/settings.toml.
#
# Designed to be silent on success and non-blocking on failure. Auto-fixing
# trivial style issues here means the code-reviewer agent never has to flag them.
#
# Expects: $CLAUDE_FILE_PATHS, a space-separated list of file paths Claude touched.

set -uo pipefail

# Add Homebrew's Apple Silicon path so binaries installed via brew are found.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Filter to Swift files only.
SWIFT_FILES=""
for file in $CLAUDE_FILE_PATHS; do
  case "$file" in
    *.swift)
      if [ -f "$file" ]; then
        SWIFT_FILES="$SWIFT_FILES $file"
      fi
      ;;
  esac
done

if [ -z "$SWIFT_FILES" ]; then
  exit 0
fi

# Run SwiftFormat if installed.
if command -v swiftformat >/dev/null 2>&1; then
  swiftformat $SWIFT_FILES --quiet 2>/dev/null || true
fi

# Run SwiftLint --fix if installed.
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --fix --quiet $SWIFT_FILES 2>/dev/null || true
fi

# Always exit 0; formatting failures should never block Claude's flow.
exit 0

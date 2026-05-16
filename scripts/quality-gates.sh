#!/bin/bash
#
# quality-gates.sh
#
# Session-end checklist. Runs the deterministic quality gates that don't
# require invoking Claude. Use this in CI, as a git pre-push hook, or as
# a manual check before declaring a session done.
#
# Gates that need Claude's judgment (force unwrap context, TODO owner detection
# beyond regex) are reported as findings for the quality-gates skill to review,
# not enforced here.
#
# Exit code:
#   0 = all gates passed (or only warnings)
#   1 = one or more BLOCKER gates failed

set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Configuration. Edit per-project as needed.
SCHEME="${QG_SCHEME:-}"                    # Xcode scheme; auto-detected if empty
SKIP_TESTS="${QG_SKIP_TESTS:-0}"           # Set to 1 to skip Gate 2
MAX_FILE_SIZE_MB="${QG_MAX_FILE_SIZE:-1}"  # Gate 5 threshold

BLOCKERS=0
WARNINGS=0
REPORT=""

add_pass() {
  REPORT+="$1  ✅ PASS\n"
}

add_fail() {
  REPORT+="$1  ❌ FAIL\n$2\n"
  BLOCKERS=$((BLOCKERS + 1))
}

add_warn() {
  REPORT+="$1  ⚠️  WARN\n$2\n"
  WARNINGS=$((WARNINGS + 1))
}

add_skip() {
  REPORT+="$1  ⏭️  SKIP  ($2)\n"
}

echo "═══ QUALITY GATES ═══"
echo ""

# ────────────────────────────────────────────────────────────────
# Gate 1: Build
# ────────────────────────────────────────────────────────────────

GATE="Gate 1: Build             "
if ! command -v xcodebuild >/dev/null 2>&1; then
  add_skip "$GATE" "xcodebuild not found"
else
  # Detect scheme if not provided.
  if [ -z "$SCHEME" ]; then
    SCHEME=$(xcodebuild -list 2>/dev/null | awk '/Schemes:/,0' | sed -n '2p' | xargs)
  fi

  if [ -z "$SCHEME" ]; then
    add_skip "$GATE" "no Xcode scheme detected; set QG_SCHEME"
  else
    BUILD_OUTPUT=$(xcodebuild -scheme "$SCHEME" -destination 'generic/platform=iOS Simulator' build 2>&1)
    BUILD_EXIT=$?
    if [ $BUILD_EXIT -eq 0 ]; then
      add_pass "$GATE"
    else
      LAST_ERRORS=$(echo "$BUILD_OUTPUT" | grep -E "error:" | head -5 | sed 's/^/  - /')
      add_fail "$GATE" "$LAST_ERRORS"
    fi
  fi
fi

# ────────────────────────────────────────────────────────────────
# Gate 2: Tests
# ────────────────────────────────────────────────────────────────

GATE="Gate 2: Tests             "
if [ "$SKIP_TESTS" = "1" ]; then
  add_skip "$GATE" "QG_SKIP_TESTS=1"
elif [ -z "$SCHEME" ]; then
  add_skip "$GATE" "no scheme"
elif [ ! -d "Tests" ] && ! ls -d *Tests >/dev/null 2>&1; then
  add_skip "$GATE" "no test target found"
else
  TEST_OUTPUT=$(xcodebuild -scheme "$SCHEME" -destination 'platform=iOS Simulator,name=iPhone 15' test 2>&1)
  TEST_EXIT=$?
  if [ $TEST_EXIT -eq 0 ]; then
    TEST_COUNT=$(echo "$TEST_OUTPUT" | grep -oE "Test Suite '[^']+' passed" | wc -l | xargs)
    add_pass "$GATE  ($TEST_COUNT suites passed)"
  else
    FAILURES=$(echo "$TEST_OUTPUT" | grep -E "failed|error:" | head -5 | sed 's/^/  - /')
    add_fail "$GATE" "$FAILURES"
  fi
fi

# ────────────────────────────────────────────────────────────────
# Gate 3: No .pbxproj modifications
# ────────────────────────────────────────────────────────────────

GATE="Gate 3: No .pbxproj edits "
PBXPROJ_CHANGES=$(git status --porcelain 2>/dev/null | grep -E '\.pbxproj|\.xcworkspacedata' || true)
if [ -z "$PBXPROJ_CHANGES" ]; then
  add_pass "$GATE"
else
  CITATIONS=$(echo "$PBXPROJ_CHANGES" | sed 's/^/  - /')
  add_fail "$GATE" "$CITATIONS"
fi

# ────────────────────────────────────────────────────────────────
# Gate 4: No new force unwraps
# ────────────────────────────────────────────────────────────────

GATE="Gate 4: No new force unwraps"
# Look at staged + unstaged Swift diffs for new lines containing force unwraps.
# Conservative pattern: matches `identifier!` followed by ., space, or end.
# Excludes try!, as!, !=, =!, and lines with quality-gates override comments.
FORCE_UNWRAPS=$(git diff HEAD -- '*.swift' 2>/dev/null \
  | grep -E '^\+' \
  | grep -v '^\+\+\+' \
  | grep -v 'quality-gates: force-unwrap-ok' \
  | grep -vE '!=|try!|as!|=!' \
  | grep -oE '\+.*[a-zA-Z_)]\![. ]' || true)

if [ -z "$FORCE_UNWRAPS" ]; then
  add_pass "$GATE"
else
  COUNT=$(echo "$FORCE_UNWRAPS" | wc -l | xargs)
  add_fail "$GATE" "  $COUNT new force unwrap(s) detected. Inspect with:\n  git diff HEAD -- '*.swift' | grep -E '^\\+.*!'"
fi

# ────────────────────────────────────────────────────────────────
# Gate 5: No staged binaries or junk
# ────────────────────────────────────────────────────────────────

GATE="Gate 5: No staged binaries"
JUNK=""

# .DS_Store
DS_STORES=$(git status --porcelain 2>/dev/null | grep '\.DS_Store' || true)
[ -n "$DS_STORES" ] && JUNK+="$DS_STORES\n"

# xcuserstate
XCUSER=$(git status --porcelain 2>/dev/null | grep 'xcuserstate' || true)
[ -n "$XCUSER" ] && JUNK+="$XCUSER\n"

# build/ or DerivedData/
BUILD_OUTPUT=$(git status --porcelain 2>/dev/null | grep -E 'build/|DerivedData/' || true)
[ -n "$BUILD_OUTPUT" ] && JUNK+="$BUILD_OUTPUT\n"

# .env files
ENV_FILES=$(git status --porcelain 2>/dev/null | grep -E '\.env($|\.)' || true)
[ -n "$ENV_FILES" ] && JUNK+="$ENV_FILES\n"

# Large files outside Assets.xcassets
SIZE_BYTES=$((MAX_FILE_SIZE_MB * 1024 * 1024))
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
if [ -n "$STAGED_FILES" ]; then
  while IFS= read -r file; do
    if [ -f "$file" ] && [[ "$file" != *Assets.xcassets* ]]; then
      FILE_SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
      if [ "$FILE_SIZE" -gt "$SIZE_BYTES" ]; then
        JUNK+="  large file: $file ($(($FILE_SIZE / 1024 / 1024)) MB)\n"
      fi
    fi
  done <<< "$STAGED_FILES"
fi

if [ -z "$JUNK" ]; then
  add_pass "$GATE"
else
  add_fail "$GATE" "$(echo -e "$JUNK" | sed 's/^/  - /')"
fi

# ────────────────────────────────────────────────────────────────
# Gate 6: TODOs have owners
# ────────────────────────────────────────────────────────────────

GATE="Gate 6: TODOs have owners "
# Find staged Swift files. Skip if none.
STAGED_SWIFT=$(git diff --cached --name-only --diff-filter=ACMR -- '*.swift' 2>/dev/null)

if [ -z "$STAGED_SWIFT" ]; then
  add_skip "$GATE" "no staged Swift files"
else
  # Match TODO or FIXME NOT immediately followed by ( or :
  # Owner format expected: TODO(name): or FIXME(ticket-123):
  UNOWNED=""
  while IFS= read -r file; do
    if [ -f "$file" ]; then
      MATCHES=$(grep -nE '//\s*(TODO|FIXME)(\s|:)' "$file" \
        | grep -vE '//\s*(TODO|FIXME)\([^)]+\)' || true)
      if [ -n "$MATCHES" ]; then
        UNOWNED+="$file: $MATCHES\n"
      fi
    fi
  done <<< "$STAGED_SWIFT"

  if [ -z "$UNOWNED" ]; then
    add_pass "$GATE"
  else
    add_warn "$GATE" "$(echo -e "$UNOWNED" | sed 's/^/  - /')"
  fi
fi

# ────────────────────────────────────────────────────────────────
# Report
# ────────────────────────────────────────────────────────────────

echo -e "$REPORT"

echo "═══ VERDICT ═══"
echo ""

if [ $BLOCKERS -gt 0 ]; then
  echo "$BLOCKERS BLOCKER(s), $WARNINGS WARN. Do not declare session done."
  echo ""
  echo "Fix the BLOCKERs above. Decide on WARNs (fix or override explicitly)."
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo "0 BLOCKERS, $WARNINGS WARN. Session can ship but review warnings."
  exit 0
else
  echo "All gates passed. Session is shippable."
  exit 0
fi

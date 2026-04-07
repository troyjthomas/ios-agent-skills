#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# iOS Agent Skills — One-Line Installer
# curl -fsSL https://raw.githubusercontent.com/troyjthomas/ios-agent-skills/main/install.sh | bash
# ─────────────────────────────────────────────────────────────

REPO_URL="https://github.com/troyjthomas/ios-agent-skills.git"
REPO_NAME="ios-agent-skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

check() { printf "${GREEN}✔${RESET} %s\n" "$1"; }
info()  { printf "${BLUE}▸${RESET} %s\n" "$1"; }
header(){ printf "\n${BOLD}${BLUE}%s${RESET}\n" "$1"; }
warn()  { printf "${RED}✘${RESET} %s\n" "$1"; }

# ── Banner ──────────────────────────────────────────────────
printf "\n${BOLD}${CYAN}"
cat << 'BANNER'
  ┌──────────────────────────────────────┐
  │   iOS Agent Skills Installer         │
  │   Production-grade skills for        │
  │   building iOS apps with AI agents   │
  └──────────────────────────────────────┘
BANNER
printf "${RESET}\n"

# ── Detect install directory ────────────────────────────────
header "Detecting environment..."

if command -v claude &>/dev/null; then
    SKILLS_DIR="$HOME/.claude/skills"
    check "Claude Code detected — installing to ~/.claude/skills/"
else
    SKILLS_DIR="$HOME/.agents/skills"
    info "Claude Code not found — installing to ~/.agents/skills/"
    info "You can move the skills later once Claude Code is set up."
fi

INSTALL_DIR="$SKILLS_DIR/$REPO_NAME"

# ── Handle existing installation ────────────────────────────
if [ -d "$INSTALL_DIR" ]; then
    printf "\n${BOLD}Found existing installation at:${RESET}\n"
    printf "  %s\n\n" "$INSTALL_DIR"
    printf "Reinstall? This will replace the current version. [y/N] "
    read -r REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        info "Installation cancelled. Your existing skills are unchanged."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
    check "Removed previous installation"
fi

# ── Clone ───────────────────────────────────────────────────
header "Installing skills..."

mkdir -p "$SKILLS_DIR"

if ! command -v git &>/dev/null; then
    warn "git is not installed. Please install git and try again."
    exit 1
fi

git clone --depth 1 --quiet "$REPO_URL" "$INSTALL_DIR"
check "Cloned repository (shallow)"

# Remove git metadata — these are standalone skill files
rm -rf "$INSTALL_DIR/.git"
check "Cleaned up git metadata"

# ── Summary ─────────────────────────────────────────────────
header "Installed successfully!"

SKILL_COUNT=$(find "$INSTALL_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find "$INSTALL_DIR/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
REF_COUNT=$(find "$INSTALL_DIR/references" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

printf "\n"
printf "  ${GREEN}%s${RESET} skills      (Setup → Build → Ship)\n" "$SKILL_COUNT"
printf "  ${GREEN}%s${RESET} agents       (SwiftUI reviewer, code reviewer, specialist)\n" "$AGENT_COUNT"
printf "  ${GREEN}%s${RESET} references   (Liquid Glass, community repos)\n" "$REF_COUNT"
printf "\n"
printf "  ${DIM}Installed to: %s${RESET}\n" "$INSTALL_DIR"

# ── Next steps ──────────────────────────────────────────────
header "Next steps"

printf "\n"
printf "  ${BOLD}1. Set up your MCP stack${RESET} ${DIM}(copy-paste these into your terminal)${RESET}\n"
printf "\n"
printf "  ${CYAN}claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp${RESET}\n"
printf "  ${CYAN}claude mcp add XcodeBuildMCP -s user -- npx -y xcodebuildmcp@latest mcp${RESET}\n"
printf "  ${CYAN}claude mcp add --transport stdio xcode -- xcrun mcpbridge${RESET}\n"
printf "\n"
printf "  ${DIM}Figma MCP (if you use Figma):${RESET}\n"
printf "  ${CYAN}claude mcp add figma${RESET}\n"
printf "\n"
printf "  ${BOLD}2. Enable Remote Control${RESET}\n"
printf "  Run ${CYAN}claude${RESET}, type ${CYAN}/config${RESET}, and set Remote Control to ${BOLD}enabled${RESET}\n"
printf "\n"
printf "  ${BOLD}3. Start building!${RESET}\n"
printf "  Open Claude Code and say: ${CYAN}\"Build me a [your idea] app for iOS\"${RESET}\n"
printf "\n"
printf "  ${DIM}Full guide: https://github.com/troyjthomas/ios-agent-skills/blob/main/QUICKSTART.md${RESET}\n"
printf "  ${DIM}Docs:       https://github.com/troyjthomas/ios-agent-skills/blob/main/docs/getting-started.md${RESET}\n"
printf "\n"

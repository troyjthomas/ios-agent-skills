---
name: mcp-setup
description: Set up the complete MCP stack for iOS development with Claude Code. Covers Figma MCP, Sosumi (Apple Docs), XcodeBuildMCP, and Apple's Xcode MCP Bridge. Use this skill when starting a new project, setting up a new machine, or when Claude Code can't access Apple documentation, build your project, or render SwiftUI previews. This is a one-time setup that makes every subsequent session dramatically better.
---

# MCP Setup

Four MCPs give Claude Code full access to your design files, Apple documentation, the Xcode build system, and visual preview rendering. Set these up once and every project benefits.

## The Stack

| MCP | What It Does | When Claude Uses It |
|---|---|---|
| **Figma MCP** | Reads your Figma designs directly | Building/matching designed screens |
| **Sosumi** | Apple docs, HIG, WWDC sessions as markdown | Looking up APIs, guidelines, Liquid Glass patterns |
| **XcodeBuildMCP** | Build, test, simulator, deploy (59 tools) | Building the project, running tests, deploying |
| **Xcode MCP Bridge** | SwiftUI previews, diagnostics, doc search | Visually verifying what it built, fixing errors |

## Setup Instructions

### 1. Figma MCP

You likely already have this connected. If not:

```bash
claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key YOUR_KEY
```

Or connect via OAuth in Claude Code settings. This lets Claude Code read frame layouts, text content, colors, spacing, and component hierarchy directly from your Figma files.

### 2. Sosumi (Apple Developer Documentation)

This is critical. Apple's docs are locked behind JavaScript, which means Claude Code can't read them by default. Sosumi translates Apple Developer docs, Human Interface Guidelines, and WWDC sessions into AI-friendly Markdown.

```bash
claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp
```

Or as a Claude Code skill (available in every project):
```bash
mkdir -p ~/.claude/skills/sosumi
curl -o ~/.claude/skills/sosumi/SKILL.md https://sosumi.ai/SKILL.md
```

**What this enables:**
- Claude Code can look up any SwiftUI modifier, any HIG guideline
- When building Liquid Glass effects, it reads the actual iOS 26 docs
- When you say "use the correct presentation style," it checks HIG
- WWDC session transcripts are searchable for implementation guidance

### 3. XcodeBuildMCP (Build System)

This gives Claude Code 59 tools for building, testing, and deploying without Xcode open.

```bash
claude mcp add XcodeBuildMCP \
  -s user \
  -e XCODEBUILDMCP_SENTRY_DISABLED=true \
  -- npx -y xcodebuildmcp@latest mcp
```

The `-s user` flag makes it global (available in every project).

**What this enables:**
- `build_sim_name_proj` — Build for simulator
- `test_sim_name_proj` — Run tests
- `clean` — Clean build folder
- Simulator management, device deployment, LLDB debugging

### 4. Apple's Xcode MCP Bridge (Visual Previews)

Requires Xcode 26.3+. This bridges into a running Xcode instance via XPC.

```bash
claude mcp add --transport stdio xcode -- xcrun mcpbridge
```

**Important:** Xcode must be running for this to work. XcodeBuildMCP works standalone; this one requires Xcode open.

**What this enables:**
- **RenderPreview** — Captures SwiftUI preview screenshots. Claude Code can SEE what it built.
- **DocumentationSearch** — Semantic search across Apple docs + WWDC transcripts
- **ExecuteSnippet** — Runs Swift code in a REPL-like context
- **Build, diagnostics, file operations** within Xcode

### Verification

After setup, verify all MCPs are connected:

```bash
claude mcp list
```

You should see: figma, sosumi, XcodeBuildMCP, and xcode.

Test each one:
- "Search Apple docs for presentationDetents" (Sosumi)
- "Build the project for iPhone 16 simulator" (XcodeBuildMCP)
- "Render a preview of ContentView" (Xcode MCP Bridge)
- "Read the frame at [Figma URL]" (Figma MCP)

## How They Work Together

The build loop with all four MCPs:

```
1. You describe what a screen should do
2. Claude Code reads the Figma frame (Figma MCP)
3. Claude Code checks the correct SwiftUI APIs (Sosumi)
4. Claude Code builds the screen
5. Claude Code builds the project (XcodeBuildMCP)
6. Claude Code renders a preview (Xcode MCP Bridge)
7. Claude Code compares preview to Figma design
8. Claude Code iterates on its own until it looks right
9. You review the final result
```

Steps 2-8 happen without your intervention. You describe and review. Claude Code handles the middle.

## When MCPs Overlap

XcodeBuildMCP and the Xcode MCP Bridge both can build projects. The difference:
- **XcodeBuildMCP** works without Xcode running. Use for CI-style builds and tests.
- **Xcode MCP Bridge** requires Xcode running. Use for previews and visual verification.

Sosumi and the Xcode MCP Bridge both search documentation. The difference:
- **Sosumi** returns full markdown documentation, HIG pages, and WWDC transcripts.
- **Xcode Bridge DocumentationSearch** uses Apple's semantic search with MLX embeddings. Better for "find me something related to X."

Both are useful. Don't choose one over the other. Let Claude Code pick the right tool.

## Troubleshooting

**Sosumi returns empty results:** Check your internet connection. Sosumi is a remote service.

**XcodeBuildMCP can't find the project:** Make sure you're in the project directory. Run `ls *.xcodeproj` to confirm.

**Xcode MCP Bridge won't connect:** Xcode must be running. Open Xcode, then try again. Also verify Xcode 26.3+ is installed.

**Figma MCP can't read frames:** Check your API key. Or if using OAuth, re-authenticate in Claude Code settings.

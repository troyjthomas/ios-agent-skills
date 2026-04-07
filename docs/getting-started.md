# Getting Started

## Step 0: MCP Setup (One-Time, 10 Minutes)

Before your first project, set up the four MCPs. This makes every project better.

```bash
# 1. Sosumi (Apple docs for AI)
claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp

# 2. XcodeBuildMCP (build/test from terminal)
claude mcp add XcodeBuildMCP -s user -e XCODEBUILDMCP_SENTRY_DISABLED=true -- npx -y xcodebuildmcp@latest mcp

# 3. Xcode MCP Bridge (SwiftUI previews)
claude mcp add --transport stdio xcode -- xcrun mcpbridge

# 4. Figma MCP (connect via Claude Code settings or API key)

# 5. Enable Remote Control for phone access
# In any Claude Code session: /config → Enable Remote Control: true
```

See `skills/mcp-setup/SKILL.md` for detailed instructions.

## Step 1: Vision (1 hour, Claude Chat)

Open the Claude app. Describe your app idea. Use the `skills/app-vision/SKILL.md` framework. Output: one-sentence pitch, target user, screen list, not-doing list.

## Step 2: Spec (30 min, Claude Chat)

Turn the vision into two documents using `skills/app-spec/SKILL.md`:
- `CLAUDE.md` — rules for Claude Code (under 500 lines)
- `APP_SPEC.md` — screen-by-screen map

Include the `.pbxproj` safety rule and known gotchas from `skills/platform-gotchas/SKILL.md`.

## Step 3: Repo Setup (10 min, Terminal + Xcode)

1. Create Xcode project (SwiftUI + SwiftData)
2. Drop CLAUDE.md and APP_SPEC.md in project root
3. `git init && git add . && git commit -m "Initial project with spec"`

## Step 4: Scaffolding (30-45 min, Claude Code)

One session. One prompt. Build the full skeleton. See `skills/scaffolding/SKILL.md`.

## Step 5: Screen by Screen (8-12 hours, Conductor)

Pick a screen. Open a Conductor workspace. Describe it in 2-5 sentences. Build. Review. Merge. Repeat. See `skills/screen-by-screen/SKILL.md`.

**Continue from your phone:** Open Remote Control to monitor progress, give feedback, and approve merges while away from your desk.

## Step 6: Persistence (2-3 hours, Claude Code)

Wire up SwiftData models. See `skills/data-persistence/SKILL.md`.

## Step 7: Polish (4-6 hours, Claude Code + Xcode)

Liquid Glass, haptics, dark mode, Figma matching. See `skills/polish-and-refinement/SKILL.md`.

## Step 8: Test and Ship (4-6 hours)

Automated tests via XcodeBuildMCP, manual testing on device, TestFlight, App Store. See `skills/device-testing/SKILL.md` and `skills/app-store-prep/SKILL.md`.

## Skill Quick Reference

| I want to... | Use this skill |
|---|---|
| Set up MCPs | mcp-setup |
| Figure out what my app should be | app-vision |
| Write the CLAUDE.md and spec | app-spec |
| Define visual identity | design-system |
| Translate Figma to code | figma-to-code |
| Build the app structure | scaffolding |
| Build each screen | screen-by-screen |
| Enforce native SwiftUI | swiftui-native-first |
| Keep Xcode safe | xcode-integration |
| Track platform issues | platform-gotchas |
| Add real data storage | data-persistence |
| Polish the app | polish-and-refinement |
| Test on real devices | device-testing |
| Submit to App Store | app-store-prep |

## Mobile Quick Reference

| I want to... | Use this |
|---|---|
| Continue a coding session from my phone | Remote Control |
| Send a task to my Mac while away | Dispatch |
| Brainstorm or plan on the go | Claude App Chat |

See `docs/mobile-workflow.md` for the complete mobile guide.

# iOS Agent Skills

> Production-grade skills for building native iOS apps with AI coding agents. No code required.

A skill pack for **designers and non-developers** who build SwiftUI apps using Claude Code. 18 skills encoding the workflows, quality gates, and native-first patterns that produce App Store-quality results.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-18-blue.svg)](#skill-map)
[![Agents](https://img.shields.io/badge/agents-3-purple.svg)](#agents)

## Why This Exists

AI coding agents default to the shortest path: custom implementations over native components, skipped specs, and UI that "works" but doesn't feel like iOS. These skills change that by encoding what senior iOS engineers know into structured, enforceable workflows that any AI agent can follow.

**Built for people who:**
- Design in Figma and build in Claude Code
- Target native iOS with SwiftUI (iOS 26+)
- Want pixel-level control without writing Swift
- Run parallel workstreams via Conductor or cmux
- Work from both Mac and phone

## Quick Start

**One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/troyjthomas/ios-agent-skills/main/install.sh | bash
```

**Set up your MCP stack:**

```bash
claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp
claude mcp add XcodeBuildMCP -s user -- npx -y xcodebuildmcp@latest mcp
claude mcp add --transport stdio xcode -- xcrun mcpbridge
```

See [QUICKSTART.md](QUICKSTART.md) for the full 5-minute walkthrough, or [docs/getting-started.md](docs/getting-started.md) for detailed documentation.

## The Definitive Guide: From Zero to App Store

This is the complete, step-by-step process for building a native iOS app without writing code. Follow it in order. Every step tells you exactly what to do, what to say, and what to expect.

### Prerequisites

Before you begin, you need:
- A Mac with macOS 14+ and Xcode 26.3+ installed
- A Claude Max or Pro subscription
- Node.js installed (for MCP servers): `brew install node` if you don't have it
- An Apple Developer account ($99/year, needed for App Store submission)
- Optional: Figma account (for design-first workflows)
- Optional: Conductor from [conductor.build](https://conductor.build) (for parallel workstreams)

---

### Phase 1: One-Time Setup

You do this once. It takes about 15 minutes. After this, every project you ever start benefits.

#### Step 1.1: Install Claude Code

Open Terminal and run:
```bash
npm install -g @anthropic-ai/claude-code
```

Verify it works:
```bash
claude --version
```

#### Step 1.2: Install the Skills

```bash
curl -fsSL https://raw.githubusercontent.com/troyjthomas/ios-agent-skills/main/install.sh | bash
```

This installs all 18 skills, 3 agent personas, and reference files into `~/.claude/skills/`.

#### Step 1.3: Set Up MCP Servers

MCPs give Claude Code superpowers: access to Apple documentation, the Xcode build system, SwiftUI preview rendering, and your Figma designs.

**Apple Documentation (Sosumi):**
```bash
claude mcp add sosumi -s user -- npx -y mcp-remote https://sosumi.ai/mcp
```
*This lets Claude Code look up any SwiftUI API, any HIG guideline, any WWDC session.*

**Xcode Build System (XcodeBuildMCP):**
```bash
claude mcp add XcodeBuildMCP -s user -e XCODEBUILDMCP_SENTRY_DISABLED=true -- npx -y xcodebuildmcp@latest mcp
```
*This lets Claude Code build your project, run tests, and catch errors without you touching Xcode.*

**Xcode Previews (Xcode MCP Bridge):**
```bash
claude mcp add --transport stdio -s user xcode -- xcrun mcpbridge
```
*This lets Claude Code render SwiftUI previews and see what it built. Requires Xcode 26.3+ and a project open in Xcode.*

**Figma (optional):**
```bash
claude mcp add figma -s user -- npx -y figma-developer-mcp --figma-api-key YOUR_FIGMA_API_KEY
```
*Replace YOUR_FIGMA_API_KEY with your actual key from Figma > Account > Personal access tokens.*

Verify everything is connected:
```bash
claude
/mcp
```
You should see green checkmarks next to sosumi, XcodeBuildMCP, and figma. The xcode bridge will show "failed" unless Xcode is open with a project — that's normal.

#### Step 1.4: Enable Remote Control

This lets you continue Claude Code sessions from your phone. Do it once, works forever.

Inside any Claude Code session:
```
/config
```
Find **"Enable Remote Control for all sessions"** and set it to **true**.

Now every Claude Code session you start is automatically accessible from the Claude mobile app.

#### Step 1.5: Save the Two Chat Skills

In the Claude app (not Claude Code), go to **Settings > Skills** and add these two skills from the repo. They're used during the planning phase:

- **app-vision** — `skills/app-vision/SKILL.md` ([view on GitHub](skills/app-vision/SKILL.md))
- **app-spec** — `skills/app-spec/SKILL.md` ([view on GitHub](skills/app-spec/SKILL.md))

You can save them by opening each SKILL.md file and clicking "Save skill" if your Claude interface supports it, or copy the contents into custom skills manually.

#### Step 1.6: Install Companion Skills (Recommended)

These community skills complement the core pack:

```bash
# SwiftUI Pro — catches subtle API mistakes
npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro

# iOS Accessibility — VoiceOver, Dynamic Type guidance
npx skills add https://github.com/dadederk/iOS-Accessibility-Agent-Skill --skill ios-accessibility
```

Also recommended (install manually):
- [Xcode 26 Agent Skills](https://github.com/harryworld/Xcode26-Agent-Skills) — validated iOS 26 API reference
- [App Store Preflight](https://github.com/truongduy2611/app-store-preflight-skills) — catches App Store rejection patterns
- [Agent Device](https://github.com/callstackincubator/agent-device) — interactive simulator testing

#### Step 1.7: Protect Your Main Branch

For every GitHub repo you create:

GitHub repo > **Settings** > **Branches** > **Add rule** > Branch name pattern: `main`
Check: **"Require a pull request before merging"**

This prevents any Claude Code session from accidentally pushing directly to main.

---

### Phase 2: Define Your App

This happens in the **Claude app** (chat), not Claude Code. You're having a conversation to define what you're building.

#### Step 2.1: Vision Session

Open Claude (the app, not Claude Code). Start a new conversation. Say something like:

```
I want to build an iOS app called [Your App Name]. It's for [who it's for]
and it [what it does in one sentence].

Use the app-vision skill to help me define it. Let's work through:
- The elevator pitch (one sentence)
- Who specifically will use it
- The core screens (aim for 5-12)
- What it will NOT do in v1
- Platform targets and constraints
```

Claude walks you through each section. Take your time. This is the foundation everything else builds on.

**You're done when you have:** A one-sentence pitch, a target user, a screen list, a not-doing list, and platform targets.

#### Step 2.2: Spec Session

Same conversation or a new one:

```
Now let's create the CLAUDE.md and APP_SPEC.md for this app using
the app-spec skill.

For CLAUDE.md, I need:
- Core principles (native SwiftUI, iOS version, HIG)
- Navigation structure (tabs, stacks, what presents what)
- Architecture (SwiftUI + SwiftData, file structure)
- Color and theming
- Custom components (list only the exceptions)
- What NOT to do section
- The .pbxproj safety rule
- The Dispatch session safety rule
- Build verification rule
- Known gotchas section

For APP_SPEC.md, I need 1-3 sentences per screen covering:
- What the user sees
- What the user can do
- Where it leads (navigation)
- Edge cases (empty state, error state)
```

Claude produces both documents. **Copy each one into a file on your Mac.** You'll drop them into your project next.

**Critical rules to include in every CLAUDE.md** (Claude should include these, but verify):

```markdown
## Xcode Project Safety
- NEVER modify .xcodeproj/project.pbxproj directly
- When creating new Swift files, create the file on disk.
  I will add it to the Xcode project manually.

## Dispatch Session Safety
If this session was NOT started from a Conductor workspace:
1. Create a branch: git checkout -b dispatch/[descriptive-name]
2. Make all changes on this branch, never on main
3. When finished, push and create a PR
4. Do NOT merge. Leave for review.

## Build Verification
After every change, build with XcodeBuildMCP. Fix errors before
presenting work as done.
```

---

### Phase 3: Set Up the Project

#### Step 3.1: Create the Xcode Project

1. Open Xcode
2. File > New > Project > App
3. Interface: **SwiftUI**, Storage: **SwiftData**
4. Name it, save it to your projects directory
5. Close Xcode (Claude Code handles files from here)

#### Step 3.2: Add Your Spec Files

Copy your CLAUDE.md and APP_SPEC.md into the project root directory (the folder that contains the .xcodeproj file).

#### Step 3.3: Initialize the Repo

```bash
cd /path/to/your/project
git init
git add .
git commit -m "Initial project with CLAUDE.md and app spec"
```

Create a repo on [github.com/new](https://github.com/new), then:
```bash
git remote add origin https://github.com/YOUR_USERNAME/your-app-name.git
git branch -M main
git push -u origin main
```

Don't forget to enable branch protection (Step 1.7).

---

### Phase 4: Build the Skeleton

Open Claude Code in your project directory:
```bash
cd /path/to/your/project
claude
```

Say:
```
Read CLAUDE.md and APP_SPEC.md. Build the full app skeleton.

Every screen from the spec should exist as a SwiftUI view with
placeholder content. Set up the tab navigation, NavigationStacks,
and all navigation paths between screens.

No real data, no styling, no custom components. Just the structure
so I can tap through every screen in the simulator.

Build with XcodeBuildMCP when done. List any files I need to add
to the Xcode project manually.
```

Claude Code reads your spec, creates all the view files, wires up navigation, and builds the project.

**After it finishes:**
1. Open Xcode
2. Drag any new .swift files into the project navigator (Claude Code can't modify .pbxproj)
3. Build and run in the simulator (Cmd+R)
4. Tap through every screen to verify navigation works

```bash
git add .
git commit -m "App skeleton with all screens and navigation"
git push
```

**Time: ~30-45 minutes**

---

### Phase 5: Build Screen by Screen

This is the core loop. Pick a screen, describe it, build it, review it, move on.

**If using Conductor:** Open Conductor, point it at your repo, create a workspace per screen. Each workspace gets its own branch.

**If using terminal:** Work one screen at a time in Claude Code.

#### The Prompt Template

For each screen, tell Claude Code:
```
Build out [Screen Name]. Here's what it needs:

[2-5 sentences describing what the user sees and can do.
Copy from your APP_SPEC.md and add detail.]

[Any specific interaction details]

[Edge cases: empty state, error state]
```

**Example:**
```
Build out the Projects home screen. It's a scrollable list of the
user's active projects using LazyVStack. Each row shows the project
name in headline weight, a small circular progress ring showing
percent complete, and the yarn color as a small swatch circle.

Long press on any row opens a context menu with Edit, Duplicate,
Archive, and Delete. Delete should have a destructive role.

The plus button in the top right toolbar opens the New Project sheet.

When there are no projects, show a centered empty state with
"No projects yet" and a prominent button to create the first project.
```

**What you DON'T need to say** (your CLAUDE.md handles it):
- "Use SwiftUI" — CLAUDE.md says this
- "Make it native" — CLAUDE.md says this
- "Use SF Symbols" — CLAUDE.md says this
- "Follow HIG spacing" — CLAUDE.md says this

**Review cycle:** After Claude Code builds the screen, run in the simulator. Give specific feedback:
- "The rows feel too tight. Add more vertical padding."
- "Move the progress ring to the trailing side."
- "The empty state button should be borderedProminent."

2-3 rounds of feedback per screen. Merge when it looks right.

#### Suggested Build Order

**Wave 1 (parallel if using Conductor):** Home/list screens across all tabs
**Wave 2 (parallel):** Detail views and sub-pages
**Wave 3 (parallel):** Creation sheets and forms
**Wave 4 (sequential):** Custom components used by multiple screens

**Time: ~30-60 minutes per screen, 8-12 hours total**

---

### Phase 6: Wire Up Data

Once screens look right with placeholder content:

```
Set up SwiftData models for [list your entities].

[Describe each model: name, fields, relationships]

Replace all placeholder data with real SwiftData queries.
Creation flows should save to SwiftData. Lists should query
from SwiftData. Deletion should delete with confirmation.
```

**Test:** Create an item, kill the app, relaunch. Is it still there? Edit on one screen, navigate to another — is it updated?

**Time: ~2-3 hours**

---

### Phase 7: Polish

Work through these one at a time:

```
Apply the app's tint color [hex value] throughout.
Apply Liquid Glass material to navigation bars and tab bar.
Add haptic feedback to [specific interactions].
Review typography hierarchy across all screens.
Verify dark mode on every screen.
Test Dynamic Type at the largest accessibility size.
Review empty states, loading states, and error states.
```

**If you have Figma designs:**
```
Match [Screen Name] to this Figma frame: [paste URL].
Adjust layout and hierarchy. Keep native components.
```

**Time: ~4-6 hours**

---

### Phase 8: Test

**Automated (Claude Code does this):**
```
Run all unit tests with XcodeBuildMCP. Report failures.
Build for iPhone 16 Pro simulator. Fix any warnings.
```

**Manual (you do this on your real iPhone):**
- Install via Xcode (Cmd+R with your phone selected)
- Test the complete user flow end to end
- Test interruptions (phone calls, backgrounding, lock/unlock)
- Test dark mode, Dynamic Type, VoiceOver
- Give it to your target user and watch them use it

See the **device-testing** skill for the complete checklist.

**Time: ~2-3 hours**

---

### Phase 9: Ship

```
Configure the Xcode project for release:
- Bundle identifier: com.[yourname].[appname]
- Display name: [App Name]
- Version: 1.0.0, Build: 1
- Add the app icon to Assets.xcassets
```

Then:
1. Archive in Xcode (Product > Archive)
2. Upload to App Store Connect
3. Add internal testers in TestFlight
4. Collect feedback, fix issues
5. Submit for App Store review

See the **app-store-prep** skill for the complete submission checklist.

**Time: ~2-3 hours plus 24-48 hours for Apple review**

---

### Phase 10: Maintain

After launch, switch to the maintenance workflow:

- **Morning (phone, Dispatch):** "Check for crash reports and TestFlight feedback"
- **Planning (phone, Claude Chat):** Triage bugs, plan features
- **Building (Mac, Conductor):** Fix and build
- **Shipping (Mac):** Archive, TestFlight, release

See the **post-launch** skill for crash reporting setup, version management, and the update cycle.

---

### Working from Your Phone

Three tools, three purposes:

| Tool | What It Does | When to Use |
|---|---|---|
| **Remote Control** | Mirror an active Claude Code session | Continuing work, reviewing, giving feedback |
| **Dispatch** | Send tasks to your Mac asynchronously | Quick fixes, status checks, file tasks |
| **Claude Chat** | Standard conversation | Planning, ideation, writing specs |

**Dispatch creates real code changes.** Your CLAUDE.md ensures Dispatch sessions always create a `dispatch/` branch and PR, so work integrates cleanly with your Conductor workflow. See the **git-workflow** and **mobile-workflow** docs for the full bridge pattern.

---

### Time Estimates

| Phase | Time |
|---|---|
| One-time setup | ~15 minutes |
| Define (vision + spec) | ~1.5 hours |
| Project setup | ~10 minutes |
| Scaffolding | ~30-45 minutes |
| Screen-by-screen build | ~8-12 hours |
| Data persistence | ~2-3 hours |
| Polish | ~4-6 hours |
| Testing | ~2-3 hours |
| App Store prep | ~2-3 hours |
| **Total** | **~20-30 hours across 2-3 weeks** |

---

## Skill Map

### Setup
| Skill | Purpose |
|---|---|
| [mcp-setup](skills/mcp-setup/SKILL.md) | Figma + Apple Docs + Xcode Build + Preview MCPs |

### Define
| Skill | Purpose |
|---|---|
| [app-vision](skills/app-vision/SKILL.md) | Refine a rough idea into a scoped app concept |
| [app-spec](skills/app-spec/SKILL.md) | CLAUDE.md rules + screen-by-screen spec |

### Design
| Skill | Purpose |
|---|---|
| [design-system](skills/design-system/SKILL.md) | Colors, typography, assets, brand rules |
| [figma-to-code](skills/figma-to-code/SKILL.md) | Figma frames to SwiftUI via MCP |

### Build
| Skill | Purpose |
|---|---|
| [scaffolding](skills/scaffolding/SKILL.md) | Full app skeleton in one session |
| [screen-by-screen](skills/screen-by-screen/SKILL.md) | Incremental build with preview verification |
| [swiftui-native-first](skills/swiftui-native-first/SKILL.md) | Native component enforcement (the most important skill) |
| [xcode-integration](skills/xcode-integration/SKILL.md) | .pbxproj safety, build/test/preview via MCP |
| [platform-gotchas](skills/platform-gotchas/SKILL.md) | Living document of iOS-specific quirks |
| [git-workflow](skills/git-workflow/SKILL.md) | Parallel workspace merge strategy |
| [session-management](skills/session-management/SKILL.md) | Context windows, continuity, resuming work |

### Persist, Test, Polish, Ship, Maintain
| Skill | Purpose |
|---|---|
| [data-persistence](skills/data-persistence/SKILL.md) | SwiftData models, queries, state propagation |
| [testing-strategy](skills/testing-strategy/SKILL.md) | Automated + manual testing, CI/CD |
| [polish-and-refinement](skills/polish-and-refinement/SKILL.md) | Liquid Glass, haptics, dark mode, accessibility |
| [device-testing](skills/device-testing/SKILL.md) | Real device testing checklist |
| [app-store-prep](skills/app-store-prep/SKILL.md) | TestFlight, metadata, App Store submission |
| [post-launch](skills/post-launch/SKILL.md) | Crash reporting, feedback loops, versioning |

## MCP Stack

Four MCPs give Claude Code full access to your design files, Apple documentation, the build system, and visual previews:

| MCP | Purpose | Setup |
|---|---|---|
| Figma | Read designs | `claude mcp add figma` |
| Sosumi | Apple docs as markdown | `claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp` |
| XcodeBuildMCP | Build, test, deploy | `claude mcp add XcodeBuildMCP -s user -- npx -y xcodebuildmcp@latest mcp` |
| Xcode Bridge | SwiftUI previews | `claude mcp add --transport stdio xcode -- xcrun mcpbridge` |

## Agents

| Agent | Purpose |
|---|---|
| [swiftui-reviewer](agents/swiftui-reviewer.md) | Catches custom code that should be native |
| [code-reviewer](agents/code-reviewer.md) | Five-axis code review |
| [swiftui-specialist](agents/swiftui-specialist.md) | Custom components, animations, complex layouts |

## The Process

```
0. Setup    ->  MCPs + Remote Control (one-time)
1. Vision   ->  Define the app in Claude Chat
2. Spec     ->  CLAUDE.md + screen map
3. Scaffold ->  Build skeleton in one session
4. Build    ->  Screen by screen via Conductor
5. Persist  ->  SwiftData models
6. Test     ->  Automated (XcodeBuildMCP) + manual (device)
7. Polish   ->  Liquid Glass, haptics, Figma matching
8. Ship     ->  TestFlight, then App Store
9. Maintain ->  Crash reports, feedback, updates
```

**Estimated time for a 10-screen app: 20-30 hours across 2-3 weeks.**

## Mobile Workflow

Continue from your phone via Remote Control (active sessions) and Dispatch (async tasks). See [docs/mobile-workflow.md](docs/mobile-workflow.md).

## Design Principles

1. **Native by default, custom by exception.** SwiftUI components always.
2. **Describe, don't code.** Written for plain language, not Swift syntax.
3. **Incremental over monolithic.** Never one-shot an entire app.
4. **MCP-powered verification.** Claude Code checks its own work before presenting.
5. **Parallel-friendly.** Every skill produces isolated, mergeable work.
6. **Phone-accessible.** Continue from anywhere via Remote Control and Dispatch.

## Community Resources

**Recommended companion skills** — install alongside this repo:
- [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/swiftui-agent-skill) (SwiftUI Pro) — Catches subtle SwiftUI API mistakes LLMs make. Complements swiftui-native-first.
- [harryworld/Xcode26-Agent-Skills](https://github.com/harryworld/Xcode26-Agent-Skills) — iOS 26 / Xcode 26 reference with authoritative Liquid Glass and Foundation Models guidance.
- [truongduy2611/app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) — Scans for App Store rejection patterns before submission.
- [callstackincubator/agent-device](https://github.com/callstackincubator/agent-device) — CLI for AI agents to control iOS simulators and real devices. Interactive testing from Claude Code.
- [dadederk/iOS-Accessibility-Agent-Skill](https://github.com/dadederk/iOS-Accessibility-Agent-Skill) — Deep accessibility guidance for VoiceOver, Dynamic Type, and assistive technologies.

For specialized needs beyond the core skills:
- [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) — Deep SwiftUI references
- [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) — 100+ skills, 52 generators
- [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) — Claude Code config and slash commands

## Contributing

Skills should be specific, verifiable, battle-tested, and minimal. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

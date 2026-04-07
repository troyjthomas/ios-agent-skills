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

```bash
git clone https://github.com/troyjthomas/ios-agent-skills.git

# Copy relevant skills into your project, or reference directly
# in your CLAUDE.md
```

See [docs/getting-started.md](docs/getting-started.md) for the full setup walkthrough.

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

For specialized needs beyond the core skills:
- [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) — Deep SwiftUI references
- [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) — 100+ skills, 52 generators
- [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) — Claude Code config and slash commands

## Contributing

Skills should be specific, verifiable, battle-tested, and minimal. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

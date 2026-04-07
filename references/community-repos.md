# Community Repos Reference

Curated list of repos with skills, reference files, and generators relevant to iOS development with Claude Code. Pull from these when you need specific capabilities beyond the core skills in this pack.

## Recommended Companion Skills

These three skills are designed to work alongside this repo. Install them for stronger coverage of SwiftUI correctness, iOS 26 APIs, and App Store compliance.

### SwiftUI Pro — twostraws

**Repo:** github.com/twostraws/swiftui-agent-skill
**Author:** Paul Hudson (Hacking with Swift)

Catches subtle SwiftUI API mistakes LLMs make. Complements our swiftui-native-first skill.

**Install:** `npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro`

---

### Xcode 26 Agent Skills — harryworld

**Repo:** github.com/harryworld/Xcode26-Agent-Skills
**Author:** harryworld

iOS 26 and Xcode 26 reference validated against Apple's hidden Xcode AI documentation. Authoritative Liquid Glass and Foundation Models guidance.

---

### App Store Preflight Skills — truongduy2611

**Repo:** github.com/truongduy2611/app-store-preflight-skills
**Author:** truongduy2611

Scans projects for App Store rejection patterns before submission.

---

## SwiftUI Expert Skill — AvdLee

**Repo:** github.com/AvdLee/SwiftUI-Agent-Skill
**Author:** Antoine van der Lee (SwiftLee blog)

Best for: Comprehensive SwiftUI reference files. Pull these into your project when you need deep guidance on specific topics.

**Key reference files:**
- `liquid-glass.md` — iOS 26 glass effects, fallback patterns
- `accessibility-patterns.md` — VoiceOver traits, grouping, Dynamic Type
- `animation-basics.md` / `animation-advanced.md` — Timing, interpolation, complex chains
- `animation-transitions.md` — View transitions, matchedGeometryEffect
- `layout-best-practices.md` — Layout patterns and GeometryReader alternatives
- `image-optimization.md` — AsyncImage usage, downsampling, caching
- `list-patterns.md` — ForEach identity and list performance
- `latest-apis.md` — Current SwiftUI API reference
- `charts.md` — Swift Charts, axes, selection, styling, Chart3D

**How to use:** Clone the repo and copy relevant reference files into your project's `/references` directory. Reference them from your CLAUDE.md when needed.

---

## Claude Code Apple Skills — rshankras

**Repo:** github.com/rshankras/claude-code-apple-skills
**Author:** rshankras

Best for: Code generators and product workflow skills. Massive collection (100+) covering the full Apple platform.

**Key generator skills (pull when needed):**
- `generators/auth-flow/` — Authentication flow generator
- `generators/paywall-generator/` — StoreKit/subscription paywall
- `generators/networking-layer/` — URLSession async/await networking
- `generators/analytics-setup/` — Analytics integration
- `generators/background-processing/` — Background tasks and refresh
- `generators/app-extensions/` — Widget, Watch, Share extensions
- `generators/data-export/` — Export data to CSV, JSON, PDF
- `generators/logging-setup/` — OSLog/Logger configuration

**Key product skills:**
- `product/` — 13 skills covering idea-to-App-Store workflow

**Key specialized skills:**
- `design/` — Liquid Glass, animation patterns
- `performance/` — Instruments profiling, SwiftUI debugging
- `security/` — Keychain, biometrics, network security, privacy manifests
- `legal/` — Privacy policies, terms of service, EULAs

**How to use:** Don't install the entire repo. Browse the README, identify the specific generator you need, and copy that single skill into your project.

---

## Claude Code iOS Dev Guide — keskinonur

**Repo:** github.com/keskinonur/claude-code-ios-dev-guide
**Author:** keskinonur

Best for: Claude Code configuration, slash commands, and agent personas for iOS development. PRD-driven workflow that aligns with this skill pack.

**Key slash commands:**
- `/refactor-view` — Extract and refactor SwiftUI views
- `/fix-build` — Diagnose and fix build errors with XcodeBuildMCP
- `/implement-feature` — Implement from spec using PRD workflow

**Key agent personas:**
- `ios-testing` — XCTest, Swift Testing, test strategy
- `swiftui-specialist` — Complex UI, custom layouts, animations
- `code-analyzer` — Read-only architecture review
- `iOS Mentor` — Teaching-focused style with explanations

**Key CLAUDE.md patterns:**
- XcodeBuildMCP integration block
- @Observable + MVVM architecture conventions
- Feature-based file structure (Sources/Features/)

**How to use:** Use as a reference for structuring your own CLAUDE.md and slash commands. Copy the persona definitions into your agents/ directory.

---

## Usage Pattern

Don't install everything at once. Your core workflow is covered by this skills pack. When you hit a specific need:

1. "I need a paywall" → pull from rshankras generators
2. "I need advanced animation patterns" → pull from AvdLee references
3. "I want slash commands for common tasks" → pull from keskinonur
4. "I need a privacy policy" → pull from rshankras legal skills

The community repos are your extended toolkit. This skills pack is your daily driver.

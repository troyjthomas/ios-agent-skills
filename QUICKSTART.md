# Quick Start Guide

> From zero to building your first iOS app in 5 minutes. No coding experience needed.

---

## What You'll Need

- A **Mac** with Xcode 26 installed (free from the App Store)
- **Claude Code** installed ([get it here](https://claude.ai/code))
- A free **GitHub** account
- *(Optional)* A **Figma** account if you want to build from designs

---

## The Big Picture

```
Install Skills ➜ Connect Tools ➜ Enable Remote ➜ Start Building
   (1 min)         (2 min)         (30 sec)        (you're in!)
```

---

## Step 1: Install the Skills

Open your terminal (search "Terminal" in Spotlight) and paste this:

```bash
curl -fsSL https://raw.githubusercontent.com/troyjthomas/ios-agent-skills/main/install.sh | bash
```

That's it. The installer will detect your setup and put everything in the right place.

**What just happened?** You gave Claude Code a set of expert-level iOS development skills. Think of it like hiring a senior iOS engineer to guide every decision Claude makes.

---

## Step 2: Connect Your Tools (MCPs)

MCPs let Claude Code talk directly to Xcode, Apple's documentation, and your design files. Paste these three commands one at a time:

**Apple Documentation** — so Claude knows the latest iOS APIs:
```bash
claude mcp add sosumi -- npx -y mcp-remote https://sosumi.ai/mcp
```

**Xcode Build** — so Claude can build, run, and test your app:
```bash
claude mcp add XcodeBuildMCP -s user -- npx -y xcodebuildmcp@latest mcp
```

**Xcode Previews** — so Claude can see what your app looks like:
```bash
claude mcp add --transport stdio xcode -- xcrun mcpbridge
```

**Figma** *(optional — only if you have Figma designs)*:
```bash
claude mcp add figma
```

---

## Step 3: Enable Remote Control

This lets you monitor and steer Claude while it works.

1. Open Claude Code by typing `claude` in your terminal
2. Type `/config`
3. Find **Remote Control** and set it to **enabled**
4. Done!

---

## Step 4: Start Building

### Option A: Start from Scratch

Open Claude Code in a new project folder and tell it what you want:

```
Build me a workout tracker app for iOS. It should track exercises,
sets, and reps. I want a clean, native iOS look with Liquid Glass.
```

Claude will use the skills you installed to:
- Define your app concept and create a spec
- Set up the Xcode project with the right structure
- Build each screen using native SwiftUI components
- Add data persistence with SwiftData
- Test and polish until it looks great

### Option B: Start from a Figma Design

If you have a Figma design ready:

```
Here's my Figma file: [paste your Figma link]
Build this as a native iOS app. Match the design exactly but
use native iOS components wherever possible.
```

Claude will read your Figma frames, extract colors and typography, and build each screen to match your design using native SwiftUI.

---

## What Happens Next?

Once you give Claude your idea, it follows a proven process:

```
 Your idea
   ↓
 App Vision     →  Refines your concept, asks clarifying questions
   ↓
 App Spec       →  Creates a detailed blueprint (CLAUDE.md + screen map)
   ↓
 Scaffolding    →  Builds the full project skeleton
   ↓
 Screen Build   →  Builds each screen one at a time, verifying as it goes
   ↓
 Data Layer     →  Adds SwiftData persistence
   ↓
 Polish         →  Liquid Glass effects, haptics, dark mode, accessibility
   ↓
 Test           →  Automated tests + device testing checklist
   ↓
 Ship           →  TestFlight beta → App Store submission
```

You stay in control at every step. Claude will ask you questions, show you previews, and wait for your approval before moving on.

---

## FAQ

### Do I need to know Swift?
**No.** That's the whole point. You describe what you want in plain language. Claude writes all the code. You review the results visually in Xcode previews and on your device.

### Do I need Figma?
**No.** Figma is completely optional. You can describe your app in words and Claude will design it using native iOS patterns. Figma is great if you already have designs, but it's not required.

### Do I need a Mac?
**Yes, for now.** Xcode only runs on macOS, and you need Xcode to build and preview iOS apps. You can do planning and design work from any device, but building requires a Mac.

### How long does it take to build an app?
A simple 3-5 screen app can be built in a few hours. A more complex 10+ screen app typically takes 20-30 hours spread across 2-3 weeks. The skills help Claude work efficiently so most of that time is Claude working while you review.

### Can I build from my phone?
**Yes, partially.** Once Remote Control is enabled, you can monitor progress and give feedback from your phone while Claude works on your Mac. You can also use Dispatch to queue tasks from your phone for Claude to work on later.

### What if Claude makes a mistake?
It happens! Claude builds incrementally — screen by screen — so mistakes stay small and easy to fix. Just tell Claude what's wrong in plain language and it will fix it. The skills include quality gates that catch most issues before you even see them.

### Can I use these skills with other AI tools?
The skills are written for Claude Code specifically, but the concepts and workflows work with any AI coding tool. The MCP integrations are Claude Code-specific.

---

## Getting Help

- **Full documentation:** [docs/getting-started.md](docs/getting-started.md)
- **Mobile workflow guide:** [docs/mobile-workflow.md](docs/mobile-workflow.md)
- **Community resources:** [references/community-repos.md](references/community-repos.md)
- **Issues or questions:** [Open an issue](https://github.com/troyjthomas/ios-agent-skills/issues)

---

*Built for designers and non-developers. No code required.*

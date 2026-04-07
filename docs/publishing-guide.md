# Publishing ios-agent-skills to GitHub

## Step-by-Step

### 1. Create the GitHub Repo

Go to github.com/new and create a new repository:
- Name: `ios-agent-skills`
- Description: "Production-grade skills for building native iOS apps with AI coding agents. No code required."
- Public
- Do NOT initialize with README (we already have one)
- License: MIT (already included)

### 2. Clone and Add Files

Open your terminal:

```bash
# Create a local directory and initialize git
mkdir ios-agent-skills
cd ios-agent-skills
git init

# Copy all files from the downloaded GitHub version into this directory
# (the ios-agent-skills-github folder you downloaded from Claude)
# Make sure the structure looks like:
#
# ios-agent-skills/
#   README.md
#   CLAUDE.md
#   CONTRIBUTING.md
#   LICENSE
#   agents/
#   docs/
#   references/
#   skills/

# Verify the structure
ls -la
ls skills/
```

### 3. Commit and Push

```bash
git add .
git commit -m "Initial release: 18 skills for building iOS apps with Claude Code"

# Connect to your GitHub repo
git remote add origin https://github.com/YOUR_USERNAME/ios-agent-skills.git
git branch -M main
git push -u origin main
```

### 4. Add GitHub Topics

Go to your repo on GitHub. Click the gear icon next to "About" on the right sidebar. Add these topics:

```
claude-code
swiftui
ios-development
agent-skills
ai-coding
swift
xcode
figma
apple
mobile-development
```

### 5. Write the About Description

In the same About section:
- Description: "18 production-grade skills for building native iOS apps with Claude Code. Designed for designers and non-developers."
- Website: (leave blank or add your site)

### 6. Verify

Your repo should show:
- Clean README with badges and skill map
- 18 skill directories under /skills
- 3 agent files under /agents
- 2 reference files under /references
- 2 doc files under /docs
- CONTRIBUTING.md and LICENSE at root

### 7. Optional: Add a Release

Go to Releases > Create a new release:
- Tag: v1.0.0
- Title: "v1.0.0 - Initial Release"
- Description: "18 skills covering the full iOS app lifecycle: idea to App Store to ongoing maintenance. Includes MCP setup (Figma, Sosumi, XcodeBuildMCP, Xcode Bridge), SwiftUI native-first enforcement, Conductor parallel workflow, mobile Remote Control/Dispatch workflow, and post-launch maintenance."

### 8. Share

The repo URL to share: `https://github.com/YOUR_USERNAME/ios-agent-skills`

Relevant communities to post in:
- r/SwiftUI
- r/iOSProgramming
- Hacker News (Show HN)
- Swift Forums
- X/Twitter with #ClaudeCode #SwiftUI #iOSDev tags
- Claude Code community channels

## How Others Use It

Once published, others can:

```bash
# Clone the full repo
git clone https://github.com/YOUR_USERNAME/ios-agent-skills.git

# Or reference specific skills in their CLAUDE.md:
# "Follow the conventions in /path/to/ios-agent-skills/skills/swiftui-native-first/SKILL.md"

# Or install as Claude Code skills:
# Copy the skills/ directory into their project's .claude/skills/
```

## Keeping It Updated

As you discover new gotchas, refine skills, or add new ones:

```bash
# Make changes locally
# Commit with descriptive messages
git add .
git commit -m "Add gotcha: .glassEffect requires iOS 26 availability check"
git push

# For significant updates, create a new release
# Tag: v1.1.0 for new skills, v1.0.1 for fixes
```

# Mobile Workflow

Everything you can do from your phone, what you can't, and the setup for each.

## The Three Mobile Tools

| Tool | What It Does | Best For |
|---|---|---|
| **Remote Control** | Mirror a Claude Code terminal session to your phone | Continuing active coding sessions |
| **Dispatch** | Send tasks to your desktop Claude from your phone | Fire-and-forget work while you're away |
| **Claude App Chat** | Standard Claude conversation on your phone | Strategy, ideation, writing, brainstorming |

## Remote Control (Claude Code Sessions)

### What It Is
Remote Control mirrors your local Claude Code session to the Claude mobile app. The session runs on your Mac. Your phone is the remote.

### Setup (One-Time)
In any Claude Code session:
```
/config
→ Enable Remote Control for all sessions: true
```

Now every Claude Code session (including Conductor workspaces) is automatically available on your phone.

### How to Connect
1. In Claude Code, press spacebar to show the QR code (or run `/rc`)
2. Scan with your phone camera
3. The session opens in the Claude mobile app
4. Send messages from your phone, see responses on both devices

### What You CAN Do from Your Phone via Remote Control
- Send prompts to an active Claude Code session
- Review what Claude Code built
- Give feedback ("make the rows taller", "add haptic to the button")
- Approve file changes when Claude Code asks
- Monitor multiple Conductor workspaces (switch between sessions)
- Tell Claude Code to build, test, or render previews via MCPs

### What You CANNOT Do from Your Phone via Remote Control
- Start a NEW Claude Code session (must be started on Mac first)
- Open Xcode or interact with the simulator
- Drag files into Xcode project navigator (.pbxproj rule)
- Run the app on your physical phone for testing
- Access the file system directly

### Practical Scenarios
**In bed, can't sleep:** Open Remote Control on your phone. Check which Conductor workspace needs attention. Send feedback. "The settings screen looks good, merge it. Start building the onboarding flow next."

**On the couch:** Monitor Claude Code building a screen. When it finishes, review the preview screenshot it rendered. Say "the spacing feels too tight on the list rows" and let it iterate while you watch TV.

**Waiting for coffee:** Quick check on a long-running build or test suite. Approve any permission prompts Claude Code is waiting on.

### Limitations
- If your Mac sleeps or loses network for ~10 minutes, the session times out
- You need to start a fresh Remote Control session after a timeout
- Permission approvals still required (Claude Code can't auto-approve from remote)
- Screen is small — reviewing diffs is possible but not comfortable

## Dispatch (Async Tasks from Phone)

### What It Is
Dispatch lets you text tasks to your Mac from your phone. Claude works on your desktop using local files, connectors, and apps. It messages you when done. This is DIFFERENT from Remote Control. Remote Control is synchronous (you're watching and interacting). Dispatch is asynchronous (you send a task and walk away).

### Setup
1. Open Claude Desktop app on your Mac
2. Sidebar → Dispatch → Get started
3. Toggle on: file access + keep computer awake
4. On your phone: open Claude mobile app → Dispatch section
5. Scan QR code to pair

### What You CAN Do from Your Phone via Dispatch
- Start a Claude Code session in your repo (creates a branch, makes changes, pushes)
- "Create a summary of my project's current state"
- "Search my files for the settings screen design and tell me what's there"
- "Draft App Store metadata based on the app spec"
- "Check my email for any TestFlight feedback and summarize it"
- Trigger Cowork skills and scheduled tasks you've set up
- Non-code file tasks: organize, search, summarize, draft

### What You CANNOT Do from Dispatch
- Open or manage Conductor workspaces directly
- Run parallel coding sessions (Dispatch is one session at a time)
- See the Conductor dashboard or workspace overview

### Dispatch + Claude Code + Conductor: The Bridge

Dispatch CAN start Claude Code sessions. This means you can initiate real coding work from your phone. The key is making sure that work integrates cleanly with your Conductor-based workflow.

**How it works:**

Your CLAUDE.md has a "Dispatch Session Safety" rule (see git-workflow skill) that forces every Dispatch-initiated Claude Code session to:
1. Create a `dispatch/` prefixed branch before touching any code
2. Make all changes on that branch
3. Commit, push, and create a PR when done

This produces the same output as a Conductor workspace: a branch with a PR. When you're back at your desk, you can merge the PR via GitHub or pull it into a Conductor workspace for further iteration.

**Example from your phone:**

```
"Start a Claude Code session in the Patchwork repo. Create a branch
called dispatch/fix-dark-mode-ring. The progress ring is hard to see
in dark mode. Make the ring stroke brighter in dark mode. Commit,
push, and create a PR when done."
```

Your Mac executes this. When finished, you have a PR on GitHub that you can review from your phone and merge whenever you're ready.

**Protecting main:** Enable branch protection on GitHub (Settings > Branches > Require PR before merging to main). This prevents any session, Dispatch or otherwise, from accidentally pushing directly to main.

### Practical Scenarios
**Morning before you sit down:** "Summarize what I was working on yesterday. List which screens are done and which still need work based on the git log."

**Quick bug fix from the couch:** "Start Claude Code in Patchwork. Branch dispatch/fix-keyboard-dismiss. The keyboard doesn't dismiss when tapping outside the text field on the New Project sheet. Fix it, test via XcodeBuildMCP, commit, push, create PR."

**Before bed:** "Check if there are any open PRs from today's Conductor work. Summarize what each one changes."

### Limitations
- Mac must be awake with Claude Desktop open
- One continuous thread (no multiple conversations)
- No MCP access (can't build, test, or preview)
- Research preview: capabilities are still expanding

## Claude App Chat (Strategy and Ideation)

### What It Is
Standard Claude conversation. No desktop connection required. Works anywhere, anytime.

### What You CAN Do
- App vision conversations (app-vision skill)
- App spec drafting (app-spec skill)
- Design system discussions
- Screen descriptions and interaction planning
- Writing App Store copy
- Brainstorming features
- Reviewing and refining your CLAUDE.md
- Planning your next build session

### What You CANNOT Do
- Access your project files
- Run Claude Code
- Build or test anything
- See your Figma designs (unless you screenshot and upload)

### Practical Scenarios
**Inspiration strikes at 2am:** Open Claude chat. Describe the new feature idea. Draft the screen descriptions. Save the conversation. When you're back at your desk, feed those descriptions into Claude Code.

**Commute:** Refine your app spec. Think through edge cases for a screen. Write the prompt you'll use in your next Claude Code session.

## The Combined Daily Workflow

```
Morning (phone, Dispatch):
  "What's the state of my project? What did I merge yesterday?"

Commute (phone, Claude Chat):
  Refine screen descriptions for today's build session

Desk (Mac, Conductor):
  Build screens in parallel using Claude Code
  Open 2-3 workspaces, monitor progress

Lunch break (phone, Remote Control):
  Check workspace progress, give feedback on completed screens
  "Merge the settings screen. Start on the Explore tab next."

Afternoon (Mac, Conductor + Xcode):
  Polish completed screens using Xcode's Claude Agent
  Visual refinement with RenderPreview
  Device testing on physical iPhone

Evening (phone, Remote Control):
  Monitor any long-running tasks
  Review and approve Claude Code's work
  Send final feedback before closing for the night

Bed (phone, Claude Chat):
  Brainstorm tomorrow's screens
  Draft descriptions for the next build session
```

## What's NOT Possible from Your Phone (Yet)

These are current limitations:

1. **Managing Conductor workspaces** — Conductor is a Mac-only GUI. You can't create, view, or manage workspaces from your phone. Workaround: use GitHub's PR list as your dashboard for tracking branches.
2. **Parallel coding sessions** — Dispatch starts one session at a time. For true parallelism, you need Conductor on your Mac. Workaround: start Conductor workspaces before leaving your desk.
3. **Running the app on your phone for testing** — Requires Xcode + USB/Wi-Fi connection to your Mac.
4. **Viewing SwiftUI previews** — RenderPreview output stays on your Mac. You can ask Claude Code to describe what it sees, but you can't view the image on your phone.
5. **Editing .pbxproj / Xcode project settings** — Mac-only, always manual.

**What IS possible from your phone (that you might think isn't):**
- Starting Claude Code sessions (via Dispatch)
- Making real code changes that produce PRs (via Dispatch + branching rule)
- Reviewing and merging PRs (via GitHub mobile)
- Monitoring active sessions (via Remote Control)
- Building and testing (via Remote Control commanding XcodeBuildMCP)

The gap is narrower than it looks. The main thing you can't do is parallel work and visual verification. Everything else works from your phone.

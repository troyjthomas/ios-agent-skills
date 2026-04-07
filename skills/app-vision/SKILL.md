---
name: app-vision
description: Refine a rough app idea into a clear concept with goals, audience, scope, and core screens. Use this skill when starting a new iOS app from scratch, when you have a vague idea but need structure, or when someone says "I want to build an app that..." This is always the first step before writing any spec or touching Claude Code.
---

# App Vision

Turn a rough idea into a concrete app concept. This happens in Claude chat, not Claude Code.

## When to Use

- You have an app idea but haven't defined scope
- You're starting a brand new project
- You need to articulate what the app is before building anything

## The Conversation

Work through these questions. You don't need to answer them all at once. The goal is a clear picture, not a formal document.

### 1. The Elevator Pitch
What does this app do in one sentence? If you can't say it in one sentence, the scope is too big for v1. Examples:
- "Track crochet projects and count stitches"
- "Split restaurant bills with friends"
- "Log daily mood with a single tap"

### 2. Who Is It For
One specific person, not "everyone." Ideally someone you know.
- Who will use this every day?
- What are they doing RIGHT NOW without your app? (Paper? Spreadsheet? A worse app?)
- What's the one thing they'd thank you for?

### 3. Core Screens (The 80/20)
List every screen you can imagine. Then cut it in half. Then cut it again. What remains is v1.

**The test:** If you removed this screen, would the app still work? If yes, it's not v1.

V1 should have 5-12 screens. More than that and you're building v2 before v1 ships.

### 4. What It's NOT
Defining boundaries prevents scope creep. Write down 3-5 things this app will NOT do in v1.

### 5. Platform and Constraints
- iPhone only? iPad too? Mac?
- Offline-first or requires internet?
- Needs backend/server or local-only?
- Any third-party integrations? (HealthKit, CloudKit, Sign in with Apple)

## Output

By the end of this conversation, you should have:

1. **One-sentence pitch**
2. **Target user** (a real person or archetype)
3. **Screen list** (5-12 screens with one-line descriptions)
4. **Not-doing list** (3-5 things explicitly out of scope)
5. **Platform targets** and key constraints

This output feeds directly into the **app-spec** skill. Do not open Claude Code until this is done.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| "Let me just start building and see what happens" | You'll build 60% of an incoherent app and have to start over |
| "I want it to do everything the competitor does" | You'll never ship. Pick the 3 things you do better |
| "I'll figure out navigation later" | Navigation IS the app. Define it now |
| "It should work on iPhone, iPad, Mac, and Watch" | Ship on iPhone first. Expand after v1 |
| "I don't need to write this down, it's all in my head" | Claude Code can't read your head. Write it down |

## Verification

You're done when you can hand your output to someone who knows nothing about the app and they understand what it does, who it's for, and what screens it has. If they have questions about basic scope, you're not done.

# iOS Agent Skills v2 - Repository Configuration

## What This Is
A collection of production-grade skills for building native iOS apps with AI coding agents. Designed for designers and non-developers who use Claude Code, Conductor, and the full MCP stack (Figma, Sosumi, XcodeBuildMCP, Xcode Bridge).

## Structure
- /skills/ — 14 skills covering Setup → Define → Design → Build → Persist → Polish → Verify → Ship
- /agents/ — 3 reusable agent personas (swiftui-reviewer, code-reviewer, swiftui-specialist)
- /references/ — Liquid Glass patterns, community repo directory
- /docs/ — Getting started guide, mobile workflow guide

## Conventions
- Skills are plain Markdown with YAML frontmatter (name, description)
- Each SKILL.md is self-contained
- All skills assume SwiftUI-native development targeting iOS 26+
- All skills assume the user does not write code manually
- All skills assume the MCP stack is connected (Figma, Sosumi, XcodeBuildMCP, Xcode Bridge)

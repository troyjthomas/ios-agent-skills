---
name: design-system
description: Document the visual identity of your app in a format Claude Code can reference. Covers brand colors, typography choices, custom assets, and design tokens. Use this skill when your app has specific brand requirements beyond iOS defaults, when you have Figma designs with a defined visual language, or when you want consistent aesthetics across all screens. Optional for apps that use pure iOS defaults.
---

# Design System

Capture your app's visual identity in a Claude Code-readable format. This is optional. If your app uses default iOS styling with just a tint color, you don't need this. If you have brand colors, custom typography, or specific visual treatments, this keeps Claude Code consistent.

## When to Use

- Your app has a specific color palette beyond a single tint
- You're using non-system fonts
- You have custom illustrations, icons, or assets
- Your Figma designs establish a visual language you want preserved
- You want consistent spacing, radius, or shadow values across screens

## When to Skip

- You're using system fonts, a single tint color, and default iOS styling
- Your CLAUDE.md already covers the minimal theming needs
- You're building an MVP where aesthetics will be refined later

## The Design System Document

Create `DESIGN_SYSTEM.md` in your project root alongside CLAUDE.md.

### Colors

```markdown
## Colors

### Primary Palette
- Tint: #3A7D5C (Clover) - used for buttons, links, active states
- Tint Dark: #2D5F47 (Moss) - used for dark mode tint adjustment
- Background: system default (do not override)
- Surface: system default (do not override)

### Semantic Usage
- Success: system green (do not customize)
- Warning: system orange (do not customize)
- Error: system red (do not customize)
- Use Color.primary and Color.secondary for all text unless specified

### Rule
If a color is not listed here, use the iOS system default. Do not invent colors.
```

**Key principle:** Only define what diverges from iOS defaults. Everything undefined inherits system behavior. This prevents Claude Code from generating arbitrary color values.

### Typography

```markdown
## Typography

### Font Stack
- Primary: SF Pro (system default) OR [Custom Font Name]
- Monospace: SF Mono (system default)

### If Using a Custom Font:
- Ensure .otf/.ttf files are in /Resources/Fonts
- Register in Info.plist under "Fonts provided by application"
- Define a FontManager or extension for consistent access:
  - .heading: [Font]-Bold, 28pt
  - .subheading: [Font]-Medium, 20pt
  - .body: [Font]-Regular, 17pt
  - .caption: [Font]-Regular, 13pt

### Rule
Use SwiftUI's native text styles (.title, .headline, .body, .caption)
as the foundation. Custom fonts should map to these roles, not replace
the hierarchy.
```

### Spacing and Layout

```markdown
## Spacing

Use iOS standard spacing unless a specific value is called out:
- Content padding: 16pt (system default)
- Section spacing: 24pt
- Card corner radius: 12pt (or system default for grouped lists)

### Rule
Do not define custom spacing tokens unless you have a specific reason.
SwiftUI's default padding and spacing handles 90% of cases correctly.
```

### Custom Assets

```markdown
## Assets

### App Icon
- Location: /Assets.xcassets/AppIcon
- [Description of the icon design]

### Custom Illustrations
- Empty state: /Assets.xcassets/EmptyState (used on Projects home)
- Onboarding: /Assets.xcassets/Onboarding1, Onboarding2, Onboarding3

### SF Symbols Used
- Projects tab: square.stack.3d.up
- Settings tab: gearshape
- Add button: plus
- [List all symbols used in the app]

### Rule
Use SF Symbols for everything unless a custom asset is explicitly
listed here. Never generate or use third-party icon sets.
```

### Liquid Glass / Material Treatments

```markdown
## Materials

### Liquid Glass (iOS 26+)
- Navigation bars: apply Liquid Glass material
- Tab bar: apply Liquid Glass material
- Sheets: default system presentation (do not customize material)

### Blur and Vibrancy
- Do not apply custom blur effects. Use system materials only.
- If a specific material treatment is needed, define it here explicitly.
```

## Integration with CLAUDE.md

Your CLAUDE.md should reference this file:

```markdown
## Visual Design
See DESIGN_SYSTEM.md for colors, typography, and asset specifications.
When in doubt, use iOS system defaults. Only apply custom values
when DESIGN_SYSTEM.md explicitly defines them.
```

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Defining every possible color token | Claude Code invents uses for tokens you defined but didn't need |
| Custom spacing scale (4, 8, 12, 16, 24, 32...) | SwiftUI's default spacing is already good. Over-specifying creates inconsistency |
| Multiple font weights beyond 3-4 | Complexity with no payoff. Stick to regular, medium, bold |
| "Use this exact hex for dark mode too" | Dark mode colors need separate values. Use Color asset catalogs |

## Verification

Your design system is ready when:
- [ ] Every custom value is justified (you can explain why it's not the iOS default)
- [ ] System defaults are explicitly preserved (not overridden without reason)
- [ ] SF Symbol names are listed for all icons
- [ ] Custom assets have file paths and usage locations
- [ ] A new Claude Code session reading this file would produce visually consistent screens

# Liquid Glass Reference (iOS 26)

## Overview

Liquid Glass is the primary visual language introduced in iOS 26. It applies a translucent, refractive material effect to UI elements, creating depth and hierarchy.

## System-Applied Glass

These elements receive Liquid Glass automatically in iOS 26. Do NOT manually apply glass effects to them:
- Navigation bars
- Tab bars
- Toolbars
- Sidebars (iPad)
- Search bars when embedded in navigation

## Manual Glass Application

Use `.glassEffect()` modifier for custom elements that should have glass treatment.

### Modifier Order (Critical)

```swift
// CORRECT: background THEN glass
MyView()
    .background(Color.blue.opacity(0.1))
    .glassEffect()

// WRONG: glass THEN background (causes rendering issues)
MyView()
    .glassEffect()
    .background(Color.blue.opacity(0.1))
```

### With Custom Shapes

```swift
MyView()
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .glassEffect()
```

## When to Use Glass

**Use glass for:**
- Floating action buttons or toolbars
- Card overlays on media content
- Custom bottom sheets or panels
- Sidebar/panel chrome on iPad

**Do NOT use glass for:**
- Content areas (text, images, lists)
- Every card in a list (visual noise)
- Backgrounds of standard screens
- Small UI elements (buttons, badges)

## Tinting

Glass can be tinted with your app's accent color. For v1, use system defaults:

```swift
.glassEffect() // System default, no tinting
```

Custom tinting and intensity are tunable but should be deferred to polish phase.

## Fallback for Earlier iOS Versions

If supporting iOS versions before 26:

```swift
if #available(iOS 26, *) {
    content.glassEffect()
} else {
    content.background(.ultraThinMaterial)
}
```

## Resources

- Use Sosumi MCP: `sosumi fetch /documentation/swiftui/view/glasseffect`
- AvdLee SwiftUI Agent Skill: `references/liquid-glass.md` in their repo
- Apple HIG on Materials: search Sosumi for "materials human interface guidelines"

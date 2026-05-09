---
name: dark-mode-legibility
description: Test every screen in BOTH light and dark mode every iteration. The most common iOS legibility bugs only show in one mode, including a specific class of vibrancy-on-pastel-tint failures that produce illegible labels on glass buttons. Use this skill alongside polish-and-refinement during the polish phase, and as a checklist any time you change colors, tints, or glass surfaces.
---

# Dark Mode Legibility

Dark mode isn't a polish-pass nice-to-have — it's a correctness concern. The most common dark-mode bugs:

- Are invisible in light mode (you'll never spot them eyeballing the simulator with default appearance)
- Only show on specific tint colors (often pale pastels, especially cream / yellow / pale orange)
- Slip through code review because the code looks identical to the light-mode case that works

This skill is a checklist for catching them.

## When to Use

- Every iteration that touches colors, tints, glass surfaces, or button styles
- Once during the polish phase as a deliberate full-app pass
- After any user reports "this looks wrong" — first question: was it light or dark mode?

## The First Rule

**Test every screen in BOTH modes every iteration.** Toggle dark mode in the simulator (`Shift + Cmd + A`) before claiming any UI fix is done.

If your verification loop only checks one mode, half your screens are unverified.

## The Vibrancy-on-Pale-Tint Pitfall

This one is responsible for more "the Continue button is unreadable in dark mode" bugs than any other cause.

**The failure mode:**
1. You apply `.glassProminent` button style with `.tint(SomePaleColor)` — e.g. cream, pale yellow, pale orange
2. In light mode, the system's vibrancy treatment picks a darker contrast color for the label — looks great
3. In dark mode, the system's vibrancy picks a *tinted-white* — which against a cream / yellow / pale-orange pill is illegible

The fix is NOT to force `.foregroundStyle(.white)` everywhere — that kills vibrancy and produces flat painted-on glyphs (see the **polish-and-refinement** skill's glass-button rules). The fix is to override the foreground in dark mode only:

```swift
Group {
    if systemColorScheme == .dark {
        Text("Continue")
            .foregroundStyle(Color.black)
    } else {
        Text("Continue")
        // light mode: no override, system vibrancy handles it
    }
}
.font(.headline)
.frame(maxWidth: .infinity)
```

The `Group { if/else }` wrapper lets `@ViewBuilder` type-erase the two branches so `.font()` and `.frame()` can be attached once outside both. Cleaner than a ternary on `AnyShapeStyle`.

This pattern is acceptable specifically for solving dark-mode legibility on a glass button. The "never apply `.foregroundStyle(.white)` on glass" rule is about WHITE killing vibrancy — explicit `.black` for legibility is a different concern.

## Semantic Colors vs Explicit Colors

Apple's semantic colors (`Color.primary`, `Color.secondary`, `Color.label`, `Color.systemBackground`, etc.) automatically adapt between modes. Use them by default for body text, secondary text, and surfaces.

| You Want | Use This | Why |
|---|---|---|
| Body text | `Color.primary` | Adapts: black in light, white in dark |
| De-emphasized text | `Color.secondary` | Adapts: gray in light, lighter gray in dark |
| Foreground for accent surfaces | `.foregroundStyle(.white)` ONLY when contrast is correct in BOTH modes | Otherwise see the conditional pattern above |
| Background tint | Asset catalog color with light + dark variants | Defines once, adapts automatically |
| Hardcoded brand color | Direct `Color(hex: …)` | Adapt manually if needed; document in DESIGN_SYSTEM.md |

If you find yourself writing `Color.black` or `Color.white` outside of:
1. The dark-mode-only override pattern above
2. A hardcoded brand element that's intentionally fixed across modes

…you probably want a semantic color or an asset-catalog color instead.

## The Dark-Mode Audit Checklist

Run this every iteration that touches color, and as a deliberate pass before shipping:

- [ ] **Toggle to dark mode in simulator** (`Shift + Cmd + A`) — confirm the screen actually re-renders (sometimes a stale preview lies)
- [ ] **All text legible** — body, secondary, captions, button labels
- [ ] **Tint color readable** against both light and dark surfaces
- [ ] **Glass buttons readable** — especially with pale tints; see the vibrancy pitfall above
- [ ] **Asset catalog colors** have dark variants where needed
- [ ] **Custom strokes / borders** — what was a 1pt black line in light mode might need to be a 1pt gray in dark
- [ ] **Images** — line-art logos may need a dark variant; photos usually don't
- [ ] **No hardcoded `Color.white` or `Color.black`** that breaks in opposite mode (audit with `grep -rn "Color\.white\|Color\.black" .`)
- [ ] **Shadows visible** — black-on-black shadows disappear; consider a colored shadow or skip shadows in dark
- [ ] **Selection / hover states** — a 0.18-opacity tint over a white surface is invisible over a dark surface; bump opacity or use a different recipe
- [ ] **Toasts and badges** — color-coded affordances need to read against both surfaces

## Token Pairs vs Single Tokens

When defining design tokens (in your `DESIGN_SYSTEM.md` or asset catalog):

**Single token (one value, both modes):** Use when:
- The semantic color already adapts (`Color.primary`)
- The brand requirement is "this exact color in both modes"

**Token pair (separate light + dark values):** Use when:
- The same semantic role needs different concrete values per mode (e.g. "primary action surface" = `#3D8F5E` in light, `#5FB37C` in dark for legibility)
- You're divergent from system semantic colors but still want adaptive behavior

Document the rationale next to each token. "Why is this a pair?" is a question every reviewer should be able to answer from the code.

## Verifying Dark-Mode Fixes

After any dark-mode fix:

1. **Toggle the simulator's appearance** — `Shift + Cmd + A`
2. **Take a screenshot in BOTH modes** and put them side-by-side
3. **Compare contrast deliberately** — squint, or zoom out 50 % on your screen; legibility issues are obvious at lower visual fidelity
4. **Check the AX snapshot** for any conditional foreground / background — make sure both branches actually fire when the system trait changes (the **verification-loop** skill covers this)

For glass-button label color overrides specifically: verify by RAPIDLY toggling appearance several times. If the label flashes white before settling to black (or vice versa), your override isn't tied tightly enough to the color scheme — likely missing `.id(systemColorScheme)` or pulling from a stale cached environment value.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| "I'll check dark mode at the end" | The bugs you'd catch early compound; every later screen built on the bad pattern needs revisiting |
| `.foregroundStyle(.white)` on every glass button "to be safe" | Kills vibrancy; produces flat painted-on glyphs; the rule against this is in CLAUDE.md for a reason |
| Writing `Color(red: …, green: …, blue: …)` instead of using asset catalog colors | No automatic dark variant; ships a single value to both modes |
| Trusting the SwiftUI Preview's appearance toggle | Previews lie; verify on simulator |
| Skipping verification on "simple" color tweaks | The vibrancy pitfall hits "simple" tint changes; complexity is irrelevant |

## Verification

For this skill itself:
1. Open any screen you've already shipped
2. Toggle dark mode
3. Run through the checklist above

If you find anything, the skill paid for itself.

## Time Estimate

5 minutes per screen during normal iteration. 30–60 minutes for a deliberate full-app polish pass on a 10-screen app.

---
name: pixel-and-stroke-geometry
description: How strokes, anti-aliasing, and pixel boundaries actually behave in SwiftUI Canvas and Shape rendering. Covers stroke centering, inset-vs-outset, anti-alias-induced flicker on animating strokes, and 1pt vs 0.5pt strokes on retina displays. Use this skill for any app that draws on a grid or canvas — pattern designers, illustration tools, charting, finger-paint, whiteboards, image editors, gauge / dial UIs.
---

# Pixel and Stroke Geometry

If your app draws on a grid, canvas, or any pixel-aligned surface, the rendering rules below are non-obvious and produce a class of bugs that are otherwise mysterious. This skill covers the rules and the recipes that prevent the bugs.

## When to Use

- Building a pattern editor, illustration tool, or any pixel-grid drawing app
- Implementing selection rectangles, marching ants, or grid overlays
- Drawing custom gauges, dials, charts, or progress rings
- Stroking paths in `SwiftUI.Canvas` or as `Shape` overlays
- Diagnosing "phantom pixel flicker" or "selection edge looks wrong" bugs

If your app is purely text-and-form-based, you can skip this skill.

## The One Rule That Causes 80 % of Stroke Bugs

**SwiftUI's `.stroke(lineWidth: N)` paints CENTERED on the path.** A 2pt stroke covers 1pt INSIDE the path and 1pt OUTSIDE.

For `Rectangle().path(in: rect).stroke(lineWidth: 2)`:
- Inside the rect: 1pt of stroke covers the rect's edge cells
- Outside the rect: 1pt of stroke extends past the rect's edge

This is correct rendering — exactly what CGPath does — but it's almost never what you want when you draw a border around a region.

## Outset vs Inset — Which to Use

You have three choices for where the stroke sits relative to the rect's logical boundary:

| You Want | Recipe |
|---|---|
| Stroke entirely OUTSIDE the rect | `rect.insetBy(dx: -lineWidth/2, dy: -lineWidth/2)` then stroke |
| Stroke entirely INSIDE the rect | `rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)` then stroke |
| Stroke centered on the rect's edge (default) | No inset — `.stroke(lineWidth: N)` |

The most common case for app developers: a selection border that should NOT visually overlap the cells inside the selection. That's "stroke entirely outside" — `insetBy(dx: -lineWidth/2, dy: -lineWidth/2)` to outset before stroking.

```swift
let strokeWidth: CGFloat = 2
let strokeRect = cellRect.insetBy(
    dx: -strokeWidth / 2,
    dy: -strokeWidth / 2
)
Rectangle()
    .path(in: strokeRect)
    .stroke(Color.white, lineWidth: strokeWidth)
```

## Marching Ants and Animating Dash Phase

A common pattern: an animated dashed border (marching ants) for a selection. The animation is implemented via a `TimelineView` that updates `StrokeStyle.dashPhase` over time.

When the stroke is centered on the path AND anti-aliasing is enabled (the default for SwiftUI Canvas), the sub-pixel coverage of the stroke at the cell boundary changes every frame as `dashPhase` shifts. The result: **diagonal pixel flicker emanating from the corners of the selection**, looking exactly like a Core Animation rendering bug.

It's not a Core Animation bug. It's the stroke painting 1pt INSIDE the cell, combined with anti-aliased sub-pixel coverage of the cell's edge changing every frame.

The fix:

```swift
TimelineView(.animation) { timeline in
    let phase = CGFloat(timeline.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: 1.0)) * 10.0
    let strokeWidth: CGFloat = 2
    let outsetRect = cellRect.insetBy(
        dx: -strokeWidth / 2,
        dy: -strokeWidth / 2
    )
    ZStack {
        Rectangle()
            .path(in: outsetRect)   // OUTSET so stroke draws outside the cells
            .stroke(.white,
                    style: StrokeStyle(lineWidth: strokeWidth,
                                       dash: [6, 4],
                                       dashPhase: phase))
        Rectangle()
            .path(in: outsetRect)
            .stroke(.black,
                    style: StrokeStyle(lineWidth: strokeWidth,
                                       dash: [6, 4],
                                       dashPhase: phase + 5))
    }
}
```

The black layer is offset by 5pt of dash phase so its dashes fall in the gaps of the white dashes — the marching ants stay legible against any background.

## 1pt vs 0.5pt Strokes on Retina Displays

iOS devices since iPhone 6 are 2× or 3× retina. A 1pt stroke is 2 or 3 device pixels wide; a 0.5pt stroke is 1 device pixel wide on @2x displays (and 1.5 device pixels on @3x).

When to choose what:

| Stroke Use | Recommended lineWidth |
|---|---|
| Hairline separator (List rows, Form sections) | 0.5pt — the iOS system separator |
| Subtle outline that should read as "1 pixel" | 0.5pt on @2x, 1pt elsewhere — usually just `1.0 / UIScreen.main.scale` clamped |
| Visible outline / button border | 1pt minimum |
| Selection / interaction affordance | 2pt minimum (visible without squinting) |
| Hero stroke (chart axes, large gauges) | 3pt+ |

If you find yourself using `0.5` for a stroke that should be visible at arm's length, you're solving for retina but ignoring legibility. Bump to 1pt.

## Anti-Aliasing — When to Embrace, When to Disable

SwiftUI's `Canvas` and `Shape` views use anti-aliasing by default. AA is correct for:
- Curves (circles, rounded rectangles, paths)
- Diagonals (any non-axis-aligned line)
- Anything that needs to look smooth at small sizes

AA is the problem for:
- Pixel-art-style apps drawing 1×1 cells (you want hard edges, not soft)
- Grid overlays where alignment is the whole point

To disable AA on a SwiftUI Canvas, draw with the `Canvas` rendering closure's `context.stroke(...)` and set the path's blend mode or use the `context.withCGContext` escape hatch to call `cgContext.setShouldAntialias(false)` directly:

```swift
Canvas { context, size in
    context.withCGContext { cgContext in
        cgContext.setShouldAntialias(false)
        cgContext.setLineWidth(1)
        // … draw paths …
    }
}
```

For most apps, leave AA on. Only disable if you've confirmed AA is the source of a specific visual problem.

## Pixel Alignment for Hairline Strokes

A 1pt stroke at a non-pixel-aligned coordinate produces a 2-pixel-wide soft line on @2x retina (the stroke's center falls between pixels, AA spreads the coverage). Aligning the stroke to a half-pixel makes it land exactly on one device row:

```swift
let scale = UIScreen.main.scale       // 2 or 3
let pixelAligned = round(coord * scale) / scale
```

Use this for hairline separators, chart gridlines, and any 1pt stroke where you want a crisp single-pixel line. Skip for thicker strokes — the AA benefit is invisible past 2pt.

## Common Symptoms → Likely Cause

| Symptom | Likely Cause |
|---|---|
| Selection border appears to "eat" the edge cells of the selection | Stroke is centered, not outset; `insetBy(-lineWidth/2)` |
| Animated dashed border has diagonal pixel flicker emanating from corners | Stroke + AA + animating dashPhase + cell-boundary path |
| 1pt line looks 2pt wide and blurry | Stroke center falls between pixels; pixel-align |
| Pixel-art cells look soft / blurred | AA enabled on a render meant to be pixel-perfect |
| Stroke disappears entirely on @3x devices | lineWidth < 1.0 / 3.0 ≈ 0.33pt; bump to 0.5 minimum |

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Trusting `.stroke()` defaults for selection borders | Strokes are centered on the path; for selection borders you want outset |
| Eyeballing whether a stroke is "off" by a pixel | Verify with a 10× zoom on simulator; sub-pixel issues are invisible at 1× |
| Disabling AA "to be safe" | AA is correct 99 % of the time. Disable only with evidence |
| Using `0.5pt` for a button border | Reads as a hairline ghost; bump to 1pt for legibility |

## Verification

For any custom drawing code:
1. Render at 1× and at 5–10× zoom on simulator. Pixel issues are invisible at 1×.
2. Switch to dark mode and re-check — strokes that "looked fine" in light may have insufficient contrast in dark.
3. Animate any animating strokes for 5 seconds and watch for flicker. Flicker means stroke + AA + boundary issue.

## Time Estimate

15 minutes to read and internalize. Saves multiple hours of debugging when the bugs in the symptoms table inevitably show up.

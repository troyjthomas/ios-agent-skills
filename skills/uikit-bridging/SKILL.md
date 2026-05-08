---
name: uikit-bridging
description: How to bridge UIKit into a SwiftUI app correctly when SwiftUI's API is genuinely insufficient. Covers UIViewRepresentable lifecycle, sizeThatFits, font-design inheritance, animation suppression, and the small set of legitimate use cases. Use this skill whenever the swiftui-native-first skill points you here for a documented escape hatch.
---

# UIKit Bridging

SwiftUI is the default. But there are a small number of API gaps where SwiftUI in iOS 26 is genuinely insufficient and a UIKit bridge via `UIViewRepresentable` is the correct path. This skill covers HOW to bridge correctly when the **swiftui-native-first** skill has already established that you should.

## When to Use This Skill

You're here because:
- The **swiftui-native-first** skill named one of the three documented escape hatches (absolute line-height, `UIColorPickerViewController` eyedropper, or vertical-axis `TextField` keyboard dismissal)
- You hit a SwiftUI API gap not yet documented and want to bridge — read the "Before You Bridge" section below first

If you're reaching for `UIViewRepresentable` because it's familiar, stop. SwiftUI usually has a way. The bridge is for when SwiftUI provably doesn't.

## Before You Bridge — A Three-Question Checklist

1. **Can you name the specific SwiftUI API gap that forces the bridge?** "I want fine-grained control" is not a gap. "`Text(AttributedString)` silently drops `paragraphStyle` so absolute line height is impossible" is a gap.
2. **Have you searched for an iOS 26 native solution?** Use the **mcp-setup** skill's Sosumi MCP to check Apple docs for the latest API. SwiftUI gains capabilities every year.
3. **Have you posted the gap as a `## Known Gotchas` entry in CLAUDE.md?** Future agents need to see why the bridge exists, or someone will "simplify" it back to a broken pure-SwiftUI version.

If you can't answer all three, don't bridge.

## The UIViewRepresentable Lifecycle

The minimum viable bridge:

```swift
struct MyBridgedView: UIViewRepresentable {
    let text: String
    let color: Color

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.text = text
        label.textColor = UIColor(color)
    }
}
```

What each method does:

- **`makeUIView`** runs once when the SwiftUI view first appears. Set up properties that don't depend on the SwiftUI inputs (numberOfLines, accessibility traits, gesture recognizers, etc.) here. NEVER do work that depends on inputs in `makeUIView` — those go in `updateUIView`.
- **`updateUIView`** runs every time SwiftUI invalidates the view (state change, environment change, parent re-render). It must apply the current input values to the UIView. Make this body shallow: setting properties, rebuilding `attributedText`, etc. AVOID doing layout, measurement, or expensive work here.
- **`sizeThatFits`** (optional but usually needed) tells SwiftUI's layout system the intrinsic size your UIView wants for a given proposed size. Without it, parent layouts often surprise you.

## sizeThatFits — Always Override for UILabel / UITextView

SwiftUI's default `UIViewRepresentable` sizing leaks the UIView's horizontal greedy growth and reports surprising heights. For text-rendering UIViews, override `sizeThatFits` so the parent VStack reserves exactly the right space:

```swift
func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
    let width = proposal.width ?? UIView.layoutFittingExpandedSize.width
    let fitted = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    return CGSize(width: width, height: fitted.height)
}
```

The pattern: take the parent's proposed width, ask the UIView what height it wants for that width, return both. This makes the bridge behave like any other SwiftUI text view in a VStack.

## Font Design Inheritance Gap

If your SwiftUI app sets `.fontDesign(.rounded)` at the scene level, every SwiftUI `Text` view inherits SF Pro Rounded automatically. **UIKit does not pick up scene-level font design.** A `UILabel` inside a `UIViewRepresentable` will render in default SF Pro and look out of place.

Fix it explicitly when you build the font:

```swift
let baseFont = UIFont.systemFont(ofSize: 56, weight: .bold)
let font: UIFont
if let roundedDescriptor = baseFont.fontDescriptor.withDesign(.rounded) {
    font = UIFont(descriptor: roundedDescriptor, size: 56)
} else {
    font = baseFont   // fallback if .rounded isn't available on this OS
}
```

This applies to any `UIFont.systemFont(...)` you build inside a bridge. The fallback to the base font is important — `.rounded` design exists on iOS 13+, but be defensive.

## Animation Suppression During Transitions

When a bridge re-runs `updateUIView` inside a transition (e.g. presentation, focus state change), implicit UIKit animations can interfere with the SwiftUI animation that's already in flight. To guarantee an immediate, non-animated property change:

```swift
UIView.performWithoutAnimation {
    label.attributedText = attributed
}
```

Wrap any property mutation that needs to take effect "right now" inside `performWithoutAnimation`. The most common case: setting alpha to 0 inside a `viewWillDisappear` hook on a presented `UIViewController` to suppress a transition flash.

## When updateUIView Runs Every Frame

If your bridge sits inside a SwiftUI `TimelineView` (e.g. a color-cycling welcome screen), `updateUIView` runs every frame because each frame produces a new SwiftUI body evaluation. This is fine — SwiftUI is designed for it — IF the body of `updateUIView` stays cheap.

Cheap means:
- Setting properties (`label.textColor`, `label.text`, `label.attributedText`)
- Rebuilding an `NSAttributedString` (no layout, no measurement)
- Updating gesture recognizer parameters

Expensive means:
- Calling `layoutIfNeeded` or `setNeedsLayout`
- Measuring text via `boundingRect(...)`
- Allocating new subviews
- Synchronous network or disk I/O

If you must do expensive work, gate it on input changes (compare to a stored previous value and bail if unchanged).

## A Worked Example — Fixed Line-Height Title

This bridge implements the most common documented-escape-hatch case: a multi-line title with an absolute line-height lock.

```swift
struct LineHeightLockedTitle: UIViewRepresentable {
    let text: String
    let fontSize: CGFloat
    let weight: UIFont.Weight
    let lineHeight: CGFloat
    let color: Color

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight

        // SwiftUI Text picks up SF Pro Rounded automatically because
        // .fontDesign(.rounded) is on the App scene; UIKit does not.
        // Resolve the rounded design from the descriptor.
        let baseFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let font: UIFont
        if let roundedDescriptor = baseFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: roundedDescriptor, size: fontSize)
        } else {
            font = baseFont
        }

        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor(color),
                .paragraphStyle: paragraph,
            ]
        )
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        let width = proposal.width ?? UIView.layoutFittingExpandedSize.width
        let fitted = uiView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )
        return CGSize(width: width, height: fitted.height)
    }
}
```

Use it like any SwiftUI view:

```swift
LineHeightLockedTitle(
    text: "Welcome to\nMyApp",
    fontSize: 56,
    weight: .bold,
    lineHeight: 54,   // 96 % of font size — dense headline
    color: .primary
)
```

## When to Use UIViewControllerRepresentable Instead

Some UIKit APIs are presented as view controllers, not views. The classic case: `UIColorPickerViewController` with the eyedropper feature. Wrapping it in a SwiftUI `.sheet` breaks the eyedropper round-trip (`_pickerDidDismissEyedropper` → `presentViewController:` throws `NSInternalInconsistencyException` and crashes the app).

For these, present the UIKit view controller directly via a coordinator class that:
1. Owns the `UIViewController` instance and the delegate
2. Calls `topViewController.present(_:animated:)` from a SwiftUI Button action
3. Handles delegate callbacks and forwards them to a SwiftUI closure

A coordinator skeleton:

```swift
@MainActor
final class ColorPickerPresenter: NSObject, UIColorPickerViewControllerDelegate {
    private var onPick: ((Color) -> Void)?

    func present(initialColor: Color, onPick: @escaping (Color) -> Void) {
        self.onPick = onPick
        let picker = UIColorPickerViewController()
        picker.selectedColor = UIColor(initialColor)
        picker.delegate = self
        picker.modalPresentationStyle = .pageSheet
        Self.topViewController()?.present(picker, animated: true)
    }

    func colorPickerViewController(
        _ vc: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        guard !continuously else { return }
        onPick?(Color(color))
    }

    private static func topViewController() -> UIViewController? {
        // Walk the key window's rootViewController.presentedViewController chain
        // … (full implementation in your coordinator)
    }
}
```

Hold the coordinator as `@State` in the SwiftUI view that triggers it so it's not deallocated mid-presentation.

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Bridging because UIKit is "more powerful" | SwiftUI is the default. Name the gap or stay native |
| Doing layout / measurement in `updateUIView` | Every state change re-layouts; performance dies |
| Skipping `sizeThatFits` for a text-rendering bridge | SwiftUI will guess wrong; parent VStacks misbehave |
| Forgetting `.fontDesign(.rounded)` inheritance | Bridge looks out of place against the rest of the app |
| Animating UIKit properties during a SwiftUI transition | Animation systems fight; users see jitter |
| Creating coordinators inside `makeUIView` | They get deallocated; delegate callbacks never fire |

## Verification

For any new bridge:
1. Build clean — no `Cannot find type` errors that aren't SourceKit lag (see **xcode-integration** for that distinction)
2. Render in light AND dark mode
3. Render in a `TimelineView` if the bridge will sit inside one — confirm `updateUIView` doesn't drop frames
4. Verify with `snapshot_ui` (see the **verification-loop** skill) that the bridge's frame matches what the parent SwiftUI layout expects

## Time Estimate

A new bridge for a documented escape hatch: 30–60 minutes including verification. A bridge for an undocumented gap: budget 2–4 hours for research, the bridge itself, and writing the gotcha entry.

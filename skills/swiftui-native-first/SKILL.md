---
name: swiftui-native-first
description: The single most important quality skill. Enforces native SwiftUI components and rejects unnecessary custom code. Use this skill as a reference throughout the entire build process. Include its core rules in every CLAUDE.md. This is what prevents Claude Code from building janky custom UI when a native component exists.
---

# SwiftUI Native First

This is not a build phase. This is a philosophy that governs every phase. The rule is simple: if SwiftUI has a native component for it, use the native component. Period.

## Why This Matters

Claude Code's default behavior is to build custom implementations. It will create a custom tab bar instead of using TabView. It will build a custom dropdown instead of using Menu. It will construct a hand-rolled list instead of using List. Every custom component is a liability: it won't animate correctly, it won't support Dynamic Type, it won't respect system appearance, and it won't feel like iOS.

Native components inherit all of this for free.

## The Decision Framework

For every UI element Claude Code produces, apply this test:

```
1. Does SwiftUI have a built-in component for this? → Use it
2. Does SwiftUI have a modifier for this? → Use it
3. Can this be achieved with a combination of native components? → Do that
4. Is there truly no native way? → Build custom, but justify it
```

If the answer to question 4 is "yes," the custom component must be:
- Listed in CLAUDE.md under Custom Components
- Specced with all interaction states
- Built once, in its own file, in /Components
- Referenced by other screens, never rebuilt

## Component Map

When you describe what you want, Claude Code should reach for these:

| You Describe | Claude Code Uses | NOT |
|---|---|---|
| "A list of items" | `List` or `LazyVStack` | Custom ScrollView with VStack |
| "Tabs at the bottom" | `TabView` | Custom HStack with buttons |
| "A button that opens options" | `Menu` | Custom popover or action sheet |
| "A sliding toggle" | `Toggle` | Custom switch view |
| "A selection from fixed options" | `Picker` | Custom segmented control |
| "A text input field" | `TextField` / `TextEditor` | Custom input component |
| "A date selection" | `DatePicker` | Custom calendar |
| "A page that slides up" | `.sheet` modifier | Custom modal presentation |
| "Long press options" | `.contextMenu` modifier | Custom long-press gesture handler |
| "A toolbar button" | `.toolbar` modifier | Custom top bar |
| "A search bar" | `.searchable` modifier | Custom search field |
| "A pull to refresh" | `.refreshable` modifier | Custom pull gesture |
| "A progress indicator" | `ProgressView` | Custom loading spinner |
| "A popup alert" | `.alert` modifier | Custom alert view |
| "A confirmation dialog" | `.confirmationDialog` | Custom action sheet |
| "A navigation title" | `.navigationTitle` | Custom header text |
| "A labeled value" | `LabeledContent` | Custom HStack with spacer |
| "A grouped settings list" | `Form` or `List` with `.insetGrouped` | Custom grouped VStack |
| "An image from SF Symbols" | `Image(systemName:)` | Bundled icon assets |
| "A share button" | `ShareLink` | Custom share implementation |
| "A color selection" | `ColorPicker` | Custom color grid |
| "A stepper for numbers" | `Stepper` | Custom plus/minus buttons |
| "A gauge or meter" | `Gauge` | Custom progress bar |
| "A disclosure group" | `DisclosureGroup` | Custom expandable section |
| "Content behind a paywall" | `.subscriptionStoreView` | Custom purchase UI |

## Presentation Components

| You Describe | Claude Code Uses |
|---|---|
| "A configuration or creation flow" | `.sheet` with `.presentationDetents` |
| "Quick action selection" | `Menu` anchored to a button |
| "Contextual options on an item" | `.contextMenu` |
| "A choice between fixed values" | `Picker` (inline, wheel, or menu style) |
| "A properties panel (iPad)" | `.inspector` |
| "A confirmation before destructive action" | `.confirmationDialog` or `.alert` |

## What "Free" Behavior You Get from Native Components

When Claude Code uses native SwiftUI, these behaviors come automatically:

- **Dynamic Type**: Text scales with user's accessibility settings
- **Dark Mode**: Colors adapt to light/dark appearance
- **Haptics**: Toggles, pickers, and certain interactions have system haptics
- **Animations**: State changes animate with system spring curves
- **VoiceOver**: Components announce themselves correctly
- **Safe Areas**: Content respects notch, home indicator, keyboard
- **Localization**: RTL language support, text measurement
- **Focus management**: Keyboard navigation (iPad + external keyboard)

Every custom component you build must manually implement ALL of these. That's why native is always the first choice.

## Red Flags in Claude Code Output

If you see these in the code (even if you can't read Swift), something's wrong:

- `UIHostingController` or `UIViewRepresentable` (UIKit bridge, usually unnecessary)
- `GeometryReader` used for basic layouts (overcomplication)
- `Custom[ComponentName]` when a native equivalent exists
- Hardcoded frame sizes like `.frame(width: 375)` (not adaptive)
- Custom gesture recognizers for tap, long press, or swipe (use native modifiers)
- `@State var isShowingCustomPopover` alongside a hand-built popover (use `Menu` or `.popover`)

## How to Enforce This

### In Your CLAUDE.md (always include):
```markdown
## Component Rules
- Use native SwiftUI components for everything unless a custom
  component is explicitly listed in the Custom Components section below.
- If you're about to create a custom view, check if SwiftUI has a
  built-in component first. If it does, use that instead.
- Do not wrap native components in custom abstractions.
```

### In Your Prompts (when you spot violations):
```
This screen has a custom [component]. SwiftUI's native [alternative]
does the same thing. Replace the custom implementation with the
native component.
```

### After Review (if it keeps happening):
Add to your CLAUDE.md's "What NOT to Do" section:
```markdown
- Do not build a custom [component]. Use SwiftUI's [native alternative].
```

## Additional Rules

### State Management (iOS 17+)

| Use This | NOT This | Why |
|---|---|---|
| `@Observable` macro | `ObservableObject` protocol | @Observable is the modern pattern, less boilerplate, better performance |
| `@State` for local view state | `@StateObject` for simple local state | @State works with @Observable classes now |
| `@Binding` for passed-down state | Custom callback closures | Bindings are the SwiftUI way |
| `@Query` for SwiftData | Manual fetch requests | @Query is reactive and automatic |
| `@Environment` for shared state | Singletons or global variables | Environment is SwiftUI-native dependency injection |

### Concurrency

- Use `async/await` for all asynchronous work, not completion handlers
- Mark ViewModels with `@MainActor` to ensure UI updates happen on the main thread
- Use `.task` modifier instead of `.onAppear` for async work (it auto-cancels)
- Handle `Task` cancellation explicitly in long-running operations

### Project Safety

- **NEVER let Claude Code modify .pbxproj files.** See the xcode-integration skill for details.
- Keep your CLAUDE.md under 500 lines. Claude Code loads the entire file every session. Overly long files dilute important instructions.

## The Custom Component Exception

Some things genuinely don't exist in SwiftUI. For those:

1. List them in CLAUDE.md before building
2. Give each one a dedicated file in /Components
3. Spec the interaction states: default, pressed, disabled, loading
4. Spec the accessibility: VoiceOver label, traits, actions
5. Test it in isolation before integrating into a screen

Examples of legitimately custom components:
- A circular stitch counter with tap-to-increment
- A pattern row highlighter that tracks reading position
- A knitting gauge calculator with custom input
- An interactive color wheel for yarn selection

Examples of things that are NOT custom components:
- A "custom" tab bar (use TabView)
- A "custom" settings row (use LabeledContent in a List)
- A "custom" pull-to-refresh (use .refreshable)
- A "custom" bottom sheet (use .sheet with detents)

## When to Bridge to UIKit

Native-first does NOT mean SwiftUI-only. There are a small number of places where SwiftUI's API is genuinely insufficient as of iOS 26 and bridging to UIKit (`UIViewRepresentable` / `UIViewControllerRepresentable`) is the correct path. These are escape hatches, not preferences — the rule is "use SwiftUI unless you can name the specific API gap that forces a bridge."

The escape hatches discovered in production builds, with their narrow scope:

1. **Absolute line-height locks.** SwiftUI's `.lineSpacing(N)` only adds to the font's natural line height — there's no API to pin multi-line text to an exact value (e.g. "56pt type, 54pt line height" for a dense headline). `Text(AttributedString)` with `NSParagraphStyle.minimumLineHeight` / `maximumLineHeight` looks like it should work but SwiftUI silently drops the paragraph style. Bridge a `UILabel` via `UIViewRepresentable` and set `attributedText` with the paragraph style — UILabel honors it correctly.

2. **`UIColorPickerViewController` with the eyedropper feature.** Wrapping it in a SwiftUI `.sheet` breaks the eyedropper round-trip (`_pickerDidDismissEyedropper` → `presentViewController:` throws `NSInternalInconsistencyException` and crashes the app). Present it via UIKit's `topViewController.present(_:animated:)` directly and own the lifecycle from a coordinator class.

3. **Reliable keyboard dismissal of vertical-axis `TextField`s.** SwiftUI's `@FocusState` on `TextField(axis: .vertical)` is unreliable for dismissing the keyboard — setting it to `false` doesn't always lower the keyboard. Pair the `@FocusState` mutation with `window.endEditing(true)` via UIKit's responder chain as a fallback.

When you bridge:
- See the **uikit-bridging** skill for `UIViewRepresentable` lifecycle, `sizeThatFits`, animation suppression, and font-design inheritance
- Inherit scene-level `.fontDesign(.rounded)` explicitly — UIKit doesn't pick it up automatically (`fontDescriptor.withDesign(.rounded)`)
- Document the bridge in CLAUDE.md with the API gap that forced it, so future agents don't try to "simplify" it back to SwiftUI

Frame UIKit bridges as "documented exceptions," not "give up on SwiftUI." The above three are the only ones I've ever needed; if your build hits a fourth, document it before reaching for a bridge.

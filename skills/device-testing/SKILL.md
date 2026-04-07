---
name: device-testing
description: Test your app on real devices, catch edge cases, and verify accessibility before shipping. Use this skill after polish is complete and you're preparing for TestFlight or App Store submission. This is the final quality gate before real users touch the app.
---

# Device Testing

Simulator is not enough. Real devices reveal real problems.

## When to Use

- Polish phase is complete
- You're preparing for TestFlight distribution
- You want to verify the app before showing it to anyone
- You're doing a final check before App Store submission

## Prerequisites

- iPhone connected to your Mac via USB or on the same Wi-Fi
- Apple Developer account (free account works for personal device testing)
- Device added in Xcode (Window > Devices and Simulators)

## Automated Testing with XcodeBuildMCP

Before manual device testing, run automated checks via Claude Code:

```
Run all unit tests using XcodeBuildMCP. Report any failures.
Build for the iPhone 16 Pro simulator and verify no warnings.
```

This catches regressions and compile issues before you invest time in manual testing. Claude Code can also fix failing tests and re-run them in a loop.

### What Automated Tests Catch
- Compile errors across all build configurations
- Unit test failures (logic, data model, state management)
- Missing file references or broken imports

### What Only Manual Testing Catches
- Visual layout issues on real hardware
- Touch interaction feel (haptics, gesture responsiveness)
- Performance on actual iPhone hardware (not Mac CPU)
- Camera, GPS, and sensor-dependent features
- Real keyboard behavior vs simulator keyboard passthrough

## Installing on Device

In Xcode:
1. Select your connected iPhone as the run destination
2. Press Cmd+R to build and run
3. First time: trust the developer certificate on the iPhone (Settings > General > VPN & Device Management)

Tell Claude Code if you need help:
```
Help me configure Xcode to run the app on my physical iPhone.
Set the development team in Signing & Capabilities.
```

## The Testing Script

Work through these systematically. Take notes on anything that feels wrong.

### Core Flow Testing

1. **First launch experience**
   - Kill the app. Delete it. Reinstall fresh
   - Does the onboarding appear?
   - Can you complete setup without confusion?
   - After onboarding, is the empty state clear?

2. **Primary use case end to end**
   - Create the main item (project, entry, whatever your app's core object is)
   - Fill in all fields
   - Save it
   - View it in the list
   - Open the detail view
   - Edit it
   - Delete it
   - Confirm it's gone

3. **Navigation completeness**
   - Visit every screen
   - Test every back button and dismiss gesture
   - Test every sheet dismiss (swipe down)
   - Test every tab switch
   - Deep link if applicable (press a notification, open from widget)

### Edge Cases

4. **Interruptions**
   - Receive a phone call while using the app
   - Send the app to background and bring it back
   - Lock the phone and unlock it
   - Rotate the device (if you support landscape)
   - Pull down notification center while interacting

5. **Data edge cases**
   - Very long text in every text field (100+ characters for names)
   - Special characters and emoji in text fields
   - Maximum number of items in a list (create 20+ items)
   - Minimum data (create an item with only required fields)

6. **System integration**
   - Does the app respect system font size (Dynamic Type)?
   - Does dark/light mode switch correctly while the app is open?
   - Does the keyboard dismiss properly on every text field?
   - Do system sheets (share, mail compose) present and dismiss correctly?

### Performance

7. **Speed check**
   - App launch time (cold start, not from background)
   - Navigation between screens (any lag?)
   - Scrolling long lists (any stutter?)
   - Sheet presentation (smooth or janky?)

### Accessibility (Basic)

8. **VoiceOver spot check**
   - Turn on VoiceOver (Settings > Accessibility > VoiceOver)
   - Navigate through the main screen
   - Can VoiceOver read every element?
   - Are buttons labeled clearly? ("Add Project" not just "Plus")
   - Can you complete the primary use case with VoiceOver?

## Reporting Issues to Claude Code

When you find issues, report them specifically:

```
Bug: When I type a very long project name (50+ characters),
the text overlaps the progress ring on the Projects home list row.
Fix: Ensure the project name truncates with an ellipsis
when it's too long for the available space.
```

```
Bug: After dismissing the New Project sheet by swiping down
(without saving), the plus button stops responding until I
switch tabs and come back.
Fix: Check that the sheet dismiss callback properly resets state.
```

```
Polish: The keyboard covers the notes field when editing a
project. The view should scroll up when the keyboard appears.
Fix: Wrap the form content in a ScrollView, or use
.scrollDismissesKeyboard(.interactively).
```

## Common Device-Only Issues

Things that work in simulator but break on device:

- **Haptics don't fire** (simulator has no haptic engine)
- **Camera/photo picker crashes** (simulator has limited camera support)
- **Performance is different** (simulator uses Mac CPU, not iPhone chip)
- **Safe area varies** by device model (notch vs Dynamic Island vs SE)
- **Keyboard behavior** is different with a real touch keyboard vs Mac keyboard passthrough

## Verification

Your app is ready for TestFlight when:
- [ ] Every item in the testing script passes or has a known, accepted limitation
- [ ] No crashes during normal use
- [ ] No data loss (create, kill app, relaunch, data is intact)
- [ ] VoiceOver can navigate the primary flow
- [ ] Dark mode and Dynamic Type don't break layouts
- [ ] You'd be comfortable handing the phone to the target user

## Time Estimate

2-3 hours for a thorough first pass. Bug fixes add 1-3 hours depending on findings.

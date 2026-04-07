---
name: app-store-prep
description: Everything needed to submit your app to TestFlight and the App Store. Covers bundle ID, icons, screenshots, metadata, TestFlight distribution, and App Store submission. Use this skill when your app passes device testing and you're ready to ship. This is the final phase.
---

# App Store Prep

Your app works. It's tested. Now ship it.

## When to Use

- Device testing is complete
- All critical bugs are fixed
- You're ready for TestFlight or App Store submission

## Prerequisites

- Apple Developer Program membership ($99/year)
- Xcode with a valid signing certificate
- App icon designed and exported at required sizes
- Screenshots from iPhone (and iPad if you support it)

## Phase 1: Xcode Configuration

Tell Claude Code:

```
Configure the Xcode project for release:
- Bundle identifier: com.[yourname].[appname]
- Display name: [App Name]
- Version: 1.0.0
- Build: 1
- Deployment target: iOS [version]
- Supported orientations: Portrait (or specify)
- Supported devices: iPhone (or iPhone + iPad)
- Add the app icon to Assets.xcassets/AppIcon
- Ensure all required Info.plist entries are present
```

### App Icon Requirements

You need a single 1024x1024px PNG (no transparency, no rounded corners, the system adds those). Design this in Figma or your preferred tool.

Tell Claude Code:
```
Add the app icon from [path or describe where it is].
Verify it's configured correctly in the asset catalog.
```

### Required Info.plist Entries

If your app uses any of these, you need usage description strings:
- Camera: NSCameraUsageDescription
- Photo Library: NSPhotoLibraryUsageDescription
- Location: NSLocationWhenInUseUsageDescription
- Notifications: no plist entry needed, but permission request in code
- Health: NSHealthShareUsageDescription

Tell Claude Code:
```
Add the following privacy usage descriptions to Info.plist:
- [List only the ones your app actually uses]
Use clear, user-friendly language that explains why the app needs access.
```

## Phase 2: TestFlight

### Create the App in App Store Connect

1. Go to appstoreconnect.apple.com
2. My Apps > + (New App)
3. Fill in: name, primary language, bundle ID, SKU
4. Save

### Archive and Upload

In Xcode:
1. Select "Any iOS Device" as build destination (not a specific simulator or device)
2. Product > Archive
3. When archive completes, click "Distribute App"
4. Select "App Store Connect"
5. Follow the prompts to upload

### TestFlight Distribution

1. In App Store Connect, go to your app > TestFlight
2. The build will appear after processing (5-30 minutes)
3. Add internal testers (your Apple ID, your wife's Apple ID)
4. Testers receive a TestFlight invitation via email
5. They install TestFlight from App Store, then install your app

## Phase 3: App Store Metadata

### What You Need

Tell Claude to help you draft these:

```
Write App Store metadata for [App Name]:
- Subtitle (30 characters max): catchy one-liner
- Description (4000 characters max): what the app does,
  key features, who it's for
- Keywords (100 characters max, comma-separated):
  search terms people would use to find this app
- What's New (for updates): brief changelog
- Category: [primary] and [secondary]
- Content Rating: fill out the questionnaire honestly
```

### Screenshots

You need screenshots from:
- iPhone 6.7" (iPhone 15 Pro Max / 16 Pro Max)
- iPhone 6.1" (iPhone 15 Pro / 16 Pro)
- iPad 12.9" (if you support iPad)

**Fastest method:** Run the app in the simulator at each required size. Take screenshots with Cmd+S. No fancy frames needed for v1.

**Better method:** Take simulator screenshots, then use a tool to add device frames and marketing text. This can be done in Figma.

You need 3-10 screenshots per device size. Show:
1. The main screen (first impression)
2. The core feature in use
3. A detail or secondary feature
4. Any unique/special interaction

### Privacy Policy

Required even for free apps with no data collection.

```
Help me draft a simple privacy policy for [App Name].
The app [does / does not] collect user data.
The app [does / does not] use analytics.
Data is stored [locally on device only / in iCloud].
```

Host this on a simple webpage (GitHub Pages, Notion public page, or your personal site). You need the URL for App Store Connect.

## Phase 4: Submission

In App Store Connect:
1. Go to your app > App Store tab
2. Fill in all metadata fields
3. Upload screenshots for each device size
4. Select the build from TestFlight
5. Fill out the App Review questionnaire
6. Submit for review

### Common Rejection Reasons (Avoid These)

- **Missing privacy policy URL**: Required for all apps
- **Broken functionality**: Reviewer found a crash or dead end
- **Placeholder content**: Any "Lorem ipsum" or "Coming soon" screens
- **Missing usage descriptions**: Camera/photos access without plist strings
- **Misleading metadata**: Description promises features the app doesn't have
- **Login wall without demo account**: If your app requires sign-in, provide test credentials

## Post-Submission

- Review typically takes 24-48 hours
- You'll get an email if rejected (with specific reasons)
- Fix the issues, re-upload, re-submit
- Once approved, you choose when to release (immediately or manual release)

## Anti-Patterns

| Temptation | Why It Fails |
|---|---|
| Skipping TestFlight and going straight to App Store | You miss real-world testing with actual users |
| Using placeholder screenshots | Apple will reject you |
| Writing a novel for the description | Nobody reads it. Be concise |
| Submitting with known bugs "to fix later" | Reviewers will find them and reject you |
| Forgetting the privacy policy | Instant rejection |

## Verification

Ready to submit when:
- [ ] App icon is set and looks correct
- [ ] Bundle ID and version are configured
- [ ] All Info.plist usage descriptions are present (if needed)
- [ ] TestFlight build works on real devices
- [ ] At least 1-2 people besides you have tested it
- [ ] Screenshots captured for all required device sizes
- [ ] App Store metadata is complete
- [ ] Privacy policy is hosted and URL works
- [ ] No placeholder content anywhere in the app
- [ ] No crashes during normal use

## Time Estimate

2-3 hours for the full submission process (configuration, screenshots, metadata, upload). Plus 24-48 hours for Apple review.

# iOS Deployment Guide for MIDI Controller App

This guide provides step-by-step instructions for deploying the MIDI Controller app to an iOS device.

## Prerequisites

1. **macOS Computer**: iOS apps can only be built and deployed from a Mac
2. **Xcode**: Latest version installed from the Mac App Store
3. **Apple Developer Account**: Either free (limited testing) or paid ($99/year)
4. **Physical iOS Device**: iPhone or iPad with iOS 12.0 or later
5. **USB Cable**: To connect your iOS device to your Mac

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/TheConstructorsBand/MobileMidiCtl.git
cd MobileMidiCtl
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Open the iOS Project in Xcode

```bash
cd ios
open Runner.xcworkspace
```

If you encounter the error "Module 'flutter_midi_command' not found", try the following:

```bash
flutter clean
flutter pub get
cd ios
pod install
```

### 4. Configure Signing in Xcode

1. In Xcode, select the "Runner" project in the left sidebar
2. Select the "Runner" target
3. Go to the "Signing & Capabilities" tab
4. Select your Team from the dropdown
5. Update the Bundle Identifier to a unique name (e.g., com.yourname.midicontrollerapp)

### 5. Configure Device Settings

1. Connect your iOS device to your Mac via USB
2. In Xcode, select your device from the device dropdown in the toolbar
3. On your iOS device, go to Settings > General > Device Management
4. Trust your developer certificate

### 6. Build and Run

1. In Xcode, click the Run button (play icon) or press Cmd+R
2. Wait for the app to build and install on your device

## Troubleshooting

### Module 'flutter_midi_command' Not Found

If you encounter this error:

1. Ensure you've run `flutter pub get` in the project root
2. Run `pod install` in the iOS directory
3. Close and reopen Xcode
4. Clean the build folder (Cmd+Shift+K)
5. Try building again

### Win32 Package Errors

If you encounter errors related to the win32 package:

1. The app includes platform-specific implementations to handle this
2. Ensure you're using the latest version of the app from the repository
3. If issues persist, try running `flutter pub upgrade` to update dependencies

### Bluetooth Permissions

If Bluetooth functionality doesn't work:

1. Ensure your device has Bluetooth enabled
2. Go to Settings > Privacy > Bluetooth on your iOS device
3. Make sure the MIDI Controller app has permission to use Bluetooth

## Distribution

### TestFlight (Internal Testing)

1. In Xcode, select Product > Archive
2. Once archiving is complete, click "Distribute App"
3. Select "App Store Connect" and follow the prompts
4. In App Store Connect, add testers in the TestFlight section

### App Store (Public Release)

1. Create an app listing in App Store Connect
2. Fill in all required metadata, screenshots, and app information
3. Submit your app for review following the same archiving process as TestFlight
4. Wait for Apple's review (typically 1-3 business days)

## Support

If you encounter any issues not covered in this guide, please open an issue on the GitHub repository or contact the development team.

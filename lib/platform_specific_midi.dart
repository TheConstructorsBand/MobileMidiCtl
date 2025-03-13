import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:io' show Platform;

// This file provides a platform-specific implementation for iOS
// that avoids importing the win32 package directly
MidiCommand getMidiCommand() {
  // Initialize MidiCommand with platform-specific settings
  if (Platform.isIOS) {
    // iOS-specific initialization
    return MidiCommand();
  } else {
    // Default initialization for other platforms
    return MidiCommand();
  }
}

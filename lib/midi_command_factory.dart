import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:io' show Platform;

/// Factory class to create platform-specific MidiCommand instances
/// This helps avoid direct imports of platform-specific packages on iOS
class MidiCommandFactory {
  /// Creates a MidiCommand instance appropriate for the current platform
  static MidiCommand createMidiCommand() {
    // Use the default MidiCommand implementation
    return MidiCommand();
  }
  
  /// Returns true if the current platform supports MIDI over Bluetooth
  static bool supportsBluetooth() {
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }
  
  /// Returns true if the current platform is iOS
  static bool isIOS() {
    return Platform.isIOS;
  }
}

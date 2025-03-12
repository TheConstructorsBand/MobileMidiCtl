// This is a basic Flutter widget test for the MIDI Controller app.
//
// Note: Full testing of MIDI functionality requires a real device with Bluetooth
// capabilities. This test only verifies basic UI structure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:midi_controller_app/main.dart';

void main() {
  testWidgets('MIDI Controller basic UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app title is present somewhere in the widget tree
    expect(find.textContaining('MIDI Controller'), findsWidgets);
    
    // Verify app has a scaffold and app bar
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}

/* 
MANUAL TESTING PLAN:

1. UI Verification:
   - Verify all 6 buttons are displayed with correct labels:
     * "Dry"
     * "Wet"
     * "Crunch"
     * "Dist"
     * "Solo"
     * "Big Solo"
   - Verify MIDI channel selector shows channels 1-10
   - Verify device connection UI elements are present

2. Bluetooth MIDI Connection:
   - Enable Bluetooth on test device
   - Press scan button to discover MIDI devices
   - Select a MIDI device from the dropdown
   - Verify connection status changes to "Connected"

3. MIDI Program Change Testing:
   - With a connected MIDI device, select channel 1
   - Press each button and verify correct PC messages are sent:
     * "Dry" button sends PC 1
     * "Wet" button sends PC 2
     * "Crunch" button sends PC 3
     * "Dist" button sends PC 4
     * "Solo" button sends PC 5
     * "Big Solo" button sends PC 6
   - Change to channel 5 and verify PC messages are sent on channel 5
   - Test with other channels to verify channel selection works

4. Error Handling:
   - Try pressing buttons without a connected device
   - Verify appropriate error messages are shown
   - Disconnect the MIDI device and verify the app handles it gracefully

Note: Full testing requires a real iOS device with Bluetooth capabilities and a
compatible MIDI device that can receive Bluetooth MIDI messages.
*/

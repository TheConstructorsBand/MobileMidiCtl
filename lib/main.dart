import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:typed_data';
import 'midi_command_factory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIDI Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MidiControllerPage(title: 'MIDI Controller'),
    );
  }
}

class MidiControllerPage extends StatefulWidget {
  const MidiControllerPage({super.key, required this.title});

  final String title;

  @override
  State<MidiControllerPage> createState() => _MidiControllerPageState();
}

class _MidiControllerPageState extends State<MidiControllerPage> {
  final MidiCommand _midiCommand = MidiCommandFactory.createMidiCommand();
  List<MidiDevice>? _devices;
  MidiDevice? _selectedDevice;
  int _selectedChannel = 1;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupMidi();
  }

  void _setupMidi() async {
    // Listen for MIDI setup changes (devices connecting/disconnecting)
    _midiCommand.onMidiSetupChanged?.listen((data) async {
      final devices = await _midiCommand.devices;
      setState(() {
        _devices = devices;
      });
      
      // If our selected device is no longer available, update the connection status
      if (_selectedDevice != null && devices != null && 
          !devices.any((device) => device.id == _selectedDevice!.id)) {
        setState(() {
          _isConnected = false;
          _selectedDevice = null;
        });
        
        // Use a local context variable to avoid BuildContext across async gap warning
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('MIDI device disconnected')),
          );
        }
      }
    });
    
    // Set up connection status change listener
    _midiCommand.onMidiDataReceived?.listen((_) {
      // This indicates the connection is working
      if (!_isConnected && _selectedDevice != null) {
        setState(() {
          _isConnected = true;
        });
      }
    });
    
    // Initial device scan
    try {
      final devices = await _midiCommand.devices;
      setState(() {
        _devices = devices;
      });
      
      if (devices != null && devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No MIDI devices found. Please enable Bluetooth and try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning for MIDI devices: $e')),
        );
      }
    }
  }

  void _connectToDevice(MidiDevice device) {
    try {
      // Disconnect from current device if any
      if (_selectedDevice != null) {
        _midiCommand.disconnectDevice(_selectedDevice!);
        setState(() {
          _isConnected = false;
        });
      }
      
      // Connect to new device
      _midiCommand.connectToDevice(device);
      
      setState(() {
        _selectedDevice = device;
        // We'll set _isConnected to true when we actually receive data
        // or when the connection is confirmed
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecting to ${device.name}...')),
      );
      
      // Set a timeout to check connection status
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _selectedDevice == device && !_isConnected) {
          // If we haven't received data after 3 seconds, assume connection is established
          setState(() {
            _isConnected = true;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to MIDI device: $e')),
      );
    }
  }

  void _sendProgramChange(int program) {
    if (_selectedDevice != null && _isConnected) {
      try {
        // MIDI Program Change: 0xC0 is the status byte for program change
        // Channel is zero-indexed in MIDI protocol (0-15 for channels 1-16)
        final statusByte = 0xC0 | (_selectedChannel - 1);
        
        // Program numbers are 0-127 in MIDI, but we're using 1-6 for our buttons
        // Subtract 1 to convert to MIDI program number (0-5)
        final programByte = program - 1;
        
        // Convert List<int> to Uint8List
        final data = Uint8List.fromList([statusByte, programByte]);
        _midiCommand.sendData(data);
        
        // Show feedback to user
        final programName = _getProgramName(program);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent $programName (PC $program) on channel $_selectedChannel'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending MIDI message: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a MIDI device first')),
      );
    }
  }
  
  String _getProgramName(int program) {
    switch (program) {
      case 1: return 'Dry';
      case 2: return 'Wet';
      case 3: return 'Crunch';
      case 4: return 'Dist';
      case 5: return 'Solo';
      case 6: return 'Big Solo';
      default: return 'Unknown';
    }
  }

  // Scan for Bluetooth MIDI devices
  void _scanForDevices() async {
    setState(() {
      _devices = null; // Clear devices to show loading state
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning for MIDI devices...')),
    );
    
    try {
      await _midiCommand.startScanningForBluetoothDevices();
      
      // Wait a bit to allow devices to be discovered
      await Future.delayed(const Duration(seconds: 2));
      
      final devices = await _midiCommand.devices;
      setState(() {
        _devices = devices;
      });
      
      if (devices != null) {
        if (devices.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No MIDI devices found. Make sure Bluetooth is enabled.')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Found ${devices.length} MIDI device(s)')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning for devices: $e')),
        );
      }
    } finally {
      _midiCommand.stopScanningForBluetoothDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanForDevices,
            tooltip: 'Scan for MIDI devices',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // MIDI Device Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MIDI Device',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<MidiDevice>(
                      isExpanded: true,
                      hint: const Text('Select MIDI Device'),
                      value: _selectedDevice,
                      items: _devices?.map((device) {
                        return DropdownMenuItem<MidiDevice>(
                          value: device,
                          child: Text(device.name),
                        );
                      }).toList() ?? [],
                      onChanged: (device) {
                        if (device != null) {
                          _connectToDevice(device);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        Text(
                          _isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // MIDI Channel Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MIDI Channel',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedChannel,
                      items: List.generate(10, (index) {
                        final channelNumber = index + 1;
                        return DropdownMenuItem<int>(
                          value: channelNumber,
                          child: Text('Channel $channelNumber'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedChannel = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Program Change Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildProgramButton('Dry', 1, Colors.blue.shade100),
                  _buildProgramButton('Wet', 2, Colors.blue.shade200),
                  _buildProgramButton('Crunch', 3, Colors.blue.shade300),
                  _buildProgramButton('Dist', 4, Colors.blue.shade400),
                  _buildProgramButton('Solo', 5, Colors.blue.shade500),
                  _buildProgramButton('Big Solo', 6, Colors.blue.shade600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramButton(String label, int program, Color color) {
    return ElevatedButton(
      onPressed: () => _sendProgramChange(program),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  @override
  void dispose() {
    if (_selectedDevice != null) {
      _midiCommand.disconnectDevice(_selectedDevice!);
    }
    super.dispose();
  }
}

import 'package:dyslearn/home_page.dart';
import 'package:dyslearn/parent/font_settings.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = fontSettingsNotifier.value.fontSize;
  String _fontStyle = fontSettingsNotifier.value.fontFamily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF7F1E1), // Set the background color
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Font Size Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Font Size',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black), // Change text color to black
                ),
              ),
              Slider(
                value: _fontSize,
                min: 10.0,
                max: 30.0,
                divisions: 20,
                label: '${_fontSize.toStringAsFixed(0)}',
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Selected Font Size: ${_fontSize.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: _fontSize, color: Colors.black), // Change text color to black
                ),
              ),
              SizedBox(height: 20),

              // Font Style Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Font Style',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black), // Change text color to black
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _fontStyle,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'LexieReadable', child: Text('LexieReadable')),
                    DropdownMenuItem(value: 'OpenDyslexic', child: Text('OpenDyslexic')),
                    // Add other fonts here
                  ],
                  onChanged: (value) {
                    setState(() {
                      _fontStyle = value!;
                    });
                  },
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),

              // Save Settings Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Save the settings to SharedPreferences
                    FontSettings settings = FontSettings(fontSize: _fontSize, fontFamily: _fontStyle);
                    await settings.saveToPreferences();

                    // Update the fontSettingsNotifier
                    fontSettingsNotifier.value = settings;

                    // Notify listeners
                    fontSettingsNotifier.notifyListeners();

                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Settings saved successfully!')),
                    );


                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.orange.withOpacity(0.5),
                    elevation: 6,
                  ),
                  child: Text(
                    'SAVE SETTINGS',
                    style: TextStyle(fontSize: _fontSize, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

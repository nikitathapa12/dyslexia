import 'package:flutter/material.dart';
import 'FontSettings.dart';

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
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Size Slider
            Text(
              'Font Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  fontSettingsNotifier.value = FontSettings(
                    fontSize: _fontSize,
                    fontFamily: _fontStyle,
                  );
                  fontSettingsNotifier.notifyListeners(); // Notify listeners on live update
                });
              },
            ),
            Text(
              'Selected Font Size: ${_fontSize.toStringAsFixed(0)}',
              style: TextStyle(fontSize: _fontSize),
            ),
            SizedBox(height: 20),

            // Font Style Dropdown
            Text(
              'Font Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _fontStyle,
              items: [
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                DropdownMenuItem(value: 'OpenDyslexic', child: Text('OpenDyslexic')),
                // Add other fonts here
              ],
              onChanged: (value) {
                setState(() {
                  _fontStyle = value!;
                  fontSettingsNotifier.value = FontSettings(
                    fontSize: _fontSize,
                    fontFamily: _fontStyle,
                  );
                  fontSettingsNotifier.notifyListeners(); // Notify listeners on live update
                });
              },
            ),
            SizedBox(height: 20),

            // Save Settings Button
            ElevatedButton(
              onPressed: () {
                fontSettingsNotifier.value = FontSettings(
                  fontSize: _fontSize,
                  fontFamily: _fontStyle,
                );
                fontSettingsNotifier.notifyListeners(); // Explicitly notify listeners
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings saved successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'SAVE SETTINGS',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

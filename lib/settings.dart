import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _fontSize = 16.0; // Default font size
  String _difficultyLevel = 'Easy';

  Future<void> _saveSettings(String userId) async {
    await _firestore.collection('settings').doc(userId).set({
      'fontSize': _fontSize,
      'difficultyLevel': _difficultyLevel,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Settings saved successfully!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final String userId = 'child_user_id'; // Replace with the actual user ID

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Font Size: ${_fontSize.toStringAsFixed(1)}'),
            Slider(
              value: _fontSize,
              min: 10.0,
              max: 30.0,
              divisions: 20,
              label: _fontSize.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _difficultyLevel,
              items: <String>['Easy', 'Medium', 'Hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _difficultyLevel = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveSettings(userId),
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

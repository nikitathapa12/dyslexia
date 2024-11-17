import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Notifications Setting
            ListTile(
              title: Text('Notifications'),
              leading: Icon(Icons.notifications),
              trailing: Switch(
                value: true, // Should be based on actual user preference
                onChanged: (bool value) {
                  // Save notification preference
                },
              ),
            ),
            Divider(),

            // Language Setting
            ListTile(
              title: Text('Language'),
              leading: Icon(Icons.language),
              trailing: DropdownButton<String>(
                value: 'English', // Current language
                onChanged: (String? newValue) {
                  // Save language preference
                },
                items: <String>['English', 'Spanish', 'French']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Divider(),

            // Dark Mode Setting
            ListTile(
              title: Text('Dark Mode'),
              leading: Icon(Icons.brightness_6),
              trailing: Switch(
                value: false, // Should be based on actual user preference
                onChanged: (bool value) {
                  // Save dark mode preference
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

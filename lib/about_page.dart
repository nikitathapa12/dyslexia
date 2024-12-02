

import 'package:dyslearn/settings.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final double fontSize;
  final String fontStyle;
  AboutPage({required this.fontSize, required this.fontStyle});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About DysLearn'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF7F1E1), // Light beige background color
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'About DysLearn',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'DysLearn is an educational application designed to assist children with dyslexia. It provides engaging activities to help children improve their learning skills through interactive games and tasks.',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. Select a child profile to start.\n'
                  '2. Play interactive learning games.\n'
                  '3. Track progress through the dashboard.\n'
                  '4. Navigate through the application using the menu.',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Privacy Policy:',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We value your privacy. All user data is securely stored and never shared with third parties.',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Terms of Use:',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'By using DysLearn, you agree to our terms of service and privacy policy.',
              style: TextStyle(
                fontSize: fontSize, fontFamily: fontStyle, // Use OpenDyslexic font
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




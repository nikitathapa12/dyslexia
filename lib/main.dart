import 'package:dyslearn/parent/font_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'loading_page.dart';  // Assuming your loading page


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Load saved font settings from SharedPreferences
  FontSettings savedSettings = await FontSettings.loadFromPreferences();
  fontSettingsNotifier.value = savedSettings;  // Set the saved font settings

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FontSettings>(
      valueListenable: fontSettingsNotifier,
      builder: (context, fontSettings, child) {
        return MaterialApp(
          title: 'Dyslearn',
          theme: ThemeData(
            fontFamily: fontSettings.fontFamily,  // Apply the font family globally
            textTheme: TextTheme(
              bodySmall: TextStyle(fontSize: fontSettings.fontSize),
              bodyMedium: TextStyle(fontSize: fontSettings.fontSize),
              displayLarge: TextStyle(fontSize: fontSettings.fontSize + 10),
              titleLarge: TextStyle(fontSize: fontSettings.fontSize + 2),
            ),
          ),
          home: GameLoadingScreen(),  // Replace with your actual homepage
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'LoadingPage.dart';  // Assuming your loading page
import 'Parent/FontSettings.dart'; // Import your FontSettings file here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize Firebase
  await Firebase.initializeApp();
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
            fontFamily: fontSettings.fontFamily,  // Apply the font family
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: fontSettings.fontSize),
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

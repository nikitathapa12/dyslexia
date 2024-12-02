import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSettings {
  final double fontSize;
  final String fontFamily;

  FontSettings({required this.fontSize, required this.fontFamily});

  // Save settings to SharedPreferences
  Future<void> saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setString('fontFamily', fontFamily);
  }

  // Load settings from SharedPreferences
  static Future<FontSettings> loadFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double fontSize = prefs.getDouble('fontSize') ?? 14.0;  // Default font size
    String fontFamily = prefs.getString('fontFamily') ?? 'OpenDyslexic';  // Default font family
    return FontSettings(fontSize: fontSize, fontFamily: fontFamily);
  }
}

// Global ValueNotifier for font settings
ValueNotifier<FontSettings> fontSettingsNotifier = ValueNotifier<FontSettings>(
    FontSettings(fontSize: 14.0, fontFamily: 'OpenDyslexic')
);

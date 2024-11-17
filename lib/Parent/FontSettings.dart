import 'package:flutter/material.dart';

class FontSettings {
  double fontSize;
  String fontFamily;

  FontSettings({required this.fontSize, required this.fontFamily});
}

final ValueNotifier<FontSettings> fontSettingsNotifier = ValueNotifier(
  FontSettings(fontSize: 16.0, fontFamily: 'OpenDyslexic'),
);

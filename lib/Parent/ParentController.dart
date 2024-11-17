import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../childProfile.dart';


class ParentController {
  static const String profileKey = 'child_profiles';

  // Save a new child profile
  Future<void> saveChildProfile(ChildProfile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> profiles = prefs.getStringList(profileKey) ?? [];

    profiles.add(jsonEncode(profile.toMap()));
    await prefs.setStringList(profileKey, profiles);
  }

  // Load all saved child profiles
  Future<List<ChildProfile>> loadChildProfiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> profiles = prefs.getStringList(profileKey) ?? [];

    return profiles.map((profile) {
      final Map<String, dynamic> data = jsonDecode(profile);
      return ChildProfile.fromMap(data);
    }).toList();
  }

  // Clear all profiles (for testing/reset purposes)
  Future<void> clearProfiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(profileKey);
  }
}

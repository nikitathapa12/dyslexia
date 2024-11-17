import 'dart:convert';

class ChildProfile {
  final String userId;
  final String username;
  final String parentEmail;  // Added parent email field
  final String parentPassword;  // Added parent password field

  // Constructor with parent email and password
  ChildProfile({
    required this.userId,
    required this.username,
    required this.parentEmail,
    required this.parentPassword,
  });

  // Convert a profile to a Map to save in SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'parentEmail': parentEmail,
      'parentPassword': parentPassword,
    };
  }

  // Convert Map back to ChildProfile
  static ChildProfile fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      userId: map['userId'],
      username: map['username'],
      parentEmail: map['parentEmail'] ?? '',  // Default to empty string if null
      parentPassword: map['parentPassword'] ?? '',  // Default to empty string if null
    );
  }
}

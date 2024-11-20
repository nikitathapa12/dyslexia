// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ChildProfile {
//   final String userId;
//   final String username;
//   final String parentEmail;  // Added parent email field
//   final String parentPassword;  // Added parent password field
//   final int progress; // Progress percentage
//   final int timeSpent; // Time spent in minutes
//
//   // Constructor with parent email and password, and new fields for progress and timeSpent
//   ChildProfile({
//     required this.userId,
//     required this.username,
//     required this.parentEmail,
//     required this.parentPassword,
//     this.progress = 0,
//     this.timeSpent = 0,
//   });
//
//   // Convert a profile to a Map to save in SharedPreferences
//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'username': username,
//       'parentEmail': parentEmail,
//       'parentPassword': parentPassword,
//       'progress': progress,
//       'timeSpent': timeSpent,
//     };
//   }
//
//   // Convert Map back to ChildProfile
//   static ChildProfile fromMap(Map<String, dynamic> map) {
//     return ChildProfile(
//       userId: map['userId'],
//       username: map['username'],
//       parentEmail: map['parentEmail'] ?? '',  // Default to empty string if null
//       parentPassword: map['parentPassword'] ?? '',  // Default to empty string if null
//       progress: map['progress'] ?? 0,  // Default to 0 if null
//       timeSpent: map['timeSpent'] ?? 0,  // Default to 0 if null
//     );
//   }
//
//   // Update the progress in Firestore
//   Future<void> updateProgress(String parentId, String childId, int newProgress) async {
//     try {
//       // Ensure the user is authenticated
//       if (FirebaseAuth.instance.currentUser != null) {
//         // Update the progress in Firestore
//         await FirebaseFirestore.instance
//             .collection('parents')
//             .doc(parentId)  // The parent document ID
//             .collection('children')
//             .doc(childId)  // The child's document ID
//             .update({
//           'progress': newProgress,  // Update progress field
//         });
//         print("Progress updated successfully!");
//       } else {
//         print('User not authenticated');
//       }
//     } catch (e) {
//       print('Error updating progress: $e');
//     }
//   }
// }

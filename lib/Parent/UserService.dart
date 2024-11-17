import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save the username to Firestore with parent's email
  Future<void> saveUserName(String username) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? ''; // Use parent's email
      DocumentReference userDoc = _firestore.collection('users').doc(email);

      // Check if the username already exists for this parent
      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        List<String> existingUsernames = List.from(docSnapshot['usernames'] ?? []);

        if (!existingUsernames.contains(username)) {
          // Add username if it's not already in the list
          existingUsernames.add(username);
          await userDoc.update({
            'usernames': existingUsernames,
          });
        }
      } else {
        // If the document doesn't exist, create it and save the username
        await userDoc.set({
          'usernames': [username], // Store as a list of usernames
        });
      }
    }
  }

  // Fetch all usernames associated with the parent's email
  Future<List<String>> getUserNames() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? ''; // Use parent's email
      DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(email).get();

      if (docSnapshot.exists) {
        List<dynamic> usernames = docSnapshot['usernames'] ?? [];
        return List<String>.from(usernames);
      }
    }
    return []; // Return empty list if no usernames found
  }
}

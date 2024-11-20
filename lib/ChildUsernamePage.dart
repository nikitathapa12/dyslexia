// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AddChildUsernamePage extends StatelessWidget {
//   final TextEditingController _usernameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.indigo.shade800,
//         title: Text('Add Child Username'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: InputDecoration(
//                 labelText: 'Child Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 String username = _usernameController.text.trim();
//                 if (username.isNotEmpty) {
//                   User? user = FirebaseAuth.instance.currentUser;
//                   if (user != null) {
//                     // Save to Firestore
//                     await FirebaseFirestore.instance
//                         .collection('usernames')
//                         .doc(user.email)
//                         .set({'username': username});
//
//                     // Navigate back
//                     Navigator.pop(context);
//                   }
//                 }
//               },
//               child: Text('Save Username'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

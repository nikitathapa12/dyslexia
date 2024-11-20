// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dyslearn/Parent/FeedbackPage.dart';
// import 'package:dyslearn/Parent/ParentLoginPage.dart';
// import 'package:dyslearn/Parent/ProgressReportPage.dart';
// import 'package:dyslearn/settings.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ParentDashboardPage extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.indigo.shade800,
//         title: Text(
//           'Parent Dashboard',
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.exit_to_app),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => ParentLoginPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/roads.jpg'),
//             fit: BoxFit.cover,
//             alignment: Alignment.center,
//           ),
//         ),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: _firestore
//               .collection('parents')
//               .doc(user?.uid)
//               .collection('children')
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No child profiles found.',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               );
//             }
//
//             List<DocumentSnapshot> children = snapshot.data!.docs;
//
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     // Welcome Text
//                     Center(
//                       child: Text(
//                         'Welcome, ${user?.displayName ?? "Parent"}!',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//
//                     // Child Profiles Section
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: children.length,
//                       itemBuilder: (context, index) {
//                         var child = children[index];
//                         var childData = child.data() as Map<String, dynamic>;
//
//                         // Safely access fields with null checks
//                         var childId = child.id;  // Assuming childId is the document ID
//                         var childName = childData['username'] ?? "Unknown";
//
//                         return FutureBuilder(
//                           future: checkChildProgress(childId),
//                           builder: (context, progressSnapshot) {
//                             if (progressSnapshot.connectionState == ConnectionState.waiting) {
//                               return SizedBox.shrink();
//                             }
//
//                             // Only show child progress if they have played games or completed assignments
//                             if (!progressSnapshot.hasData || !progressSnapshot.data!) {
//                               return SizedBox.shrink();
//                             }
//
//                             return Card(
//                               color: Colors.white.withOpacity(0.85),
//                               elevation: 10,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               shadowColor: Colors.black45,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Child Username: $childName',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.indigo.shade700,
//                                       ),
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       'Progress: ${childData['progress'] ?? 'N/A'}%',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       'Time Spent: ${childData['timeSpent'] ?? 'N/A'} mins',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(height: 20),
//                                     Row(
//                                       children: [
//                                         ElevatedButton(
//                                           onPressed: () async {
//                                             // Fetch games and submissions data for child
//                                             await updateChildData(user);
//
//                                             // Pass the correct childId and childName to ProgressPage
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) => ProgressPage(
//                                                   parentId: user?.uid ?? "",  // pass parentId if needed
//                                                   childId: childId,
//                                                   userId: user?.uid ?? "",    // pass userId if needed
//                                                   childName: childName,
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.indigo.shade700,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                           ),
//                                           child: Text('View Progress'),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                     SizedBox(height: 20),
//
//                     // Additional Options
//                     Card(
//                       color: Colors.white.withOpacity(0.85),
//                       elevation: 10,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       shadowColor: Colors.black45,
//                       child: Column(
//                         children: [
//                           // Settings Option
//                           ListTile(
//                             leading: Icon(
//                               Icons.settings,
//                               color: Colors.indigo.shade700,
//                             ),
//                             title: Text(
//                               'Settings',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.indigo.shade700,
//                               ),
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               color: Colors.indigo.shade700,
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SettingsPage(),
//                                 ),
//                               );
//                             },
//                           ),
//                           Divider(color: Colors.indigo.shade300),
//
//                           // Feedback Option
//                           ListTile(
//                             leading: Icon(
//                               Icons.feedback,
//                               color: Colors.indigo.shade700,
//                             ),
//                             title: Text(
//                               'Feedback',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.indigo.shade700,
//                               ),
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               color: Colors.indigo.shade700,
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => FeedbackPage(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // Function to check if the child has any progress (games or assignments)
//   Future<bool> checkChildProgress(String childId) async {
//     try {
//       // Check if the child has any games or assignments
//       var gamesSnapshot = await _firestore
//           .collection('parents')
//           .doc(FirebaseAuth.instance.currentUser?.uid)
//           .collection('children')
//           .doc(childId)
//           .collection('gamePlayed')
//           .get();
//
//       var assignmentsSnapshot = await _firestore
//           .collection('parents')
//           .doc(FirebaseAuth.instance.currentUser?.uid)
//           .collection('children')
//           .doc(childId)
//           .collection('assignments')
//           .get();
//
//       // Return true if the child has either played games or completed assignments
//       return gamesSnapshot.docs.isNotEmpty || assignmentsSnapshot.docs.isNotEmpty;
//     } catch (e) {
//       print("Error checking child progress: $e");
//       return false;
//     }
//   }
//
//   // Function to fetch and update child data for gamePlayed and assignments
//   Future<void> updateChildData(User? user) async {
//     if (user == null) return;
//
//     try {
//       // Fetch children under the current parent
//       final childrenSnapshot = await _firestore
//           .collection('parents')
//           .doc(user.uid)
//           .collection('children')
//           .get();
//
//       for (var childDoc in childrenSnapshot.docs) {
//         final childId = childDoc.id;
//
//         // Fetch games and submissions data
//         final gamesSnapshot = await _firestore.collection('games').get();
//         final submissionsSnapshot = await _firestore
//             .collection('submissions')
//             .where('childId', isEqualTo: childId)
//             .get();
//
//         // Update `gamePlayed` subcollection for the child
//         for (var gameDoc in gamesSnapshot.docs) {
//           final gameId = gameDoc.id;
//           final submissionsForGame = submissionsSnapshot.docs
//               .where((sub) => sub['gameId'] == gameId)
//               .toList();
//
//           int attempts = submissionsForGame.length;
//           int totalScore = submissionsForGame.fold<int>(
//             0, (sum, sub) => sum + (sub['score'] as int? ?? 0),
//           );
//           int lastScore = submissionsForGame.isNotEmpty
//               ? (submissionsForGame.last['score'] as int? ?? 0)
//               : 0;
//
//           await _firestore
//               .collection('parents')
//               .doc(user.uid)
//               .collection('children')
//               .doc(childId)
//               .collection('gamePlayed')
//               .doc(gameId)
//               .set({
//             'attempts': attempts,
//             'totalScore': totalScore,
//             'lastScore': lastScore,
//           });
//         }
//
//         // Update assignments subcollection for the child
//         for (var submissionDoc in submissionsSnapshot.docs) {
//           final assignmentId = submissionDoc['assignmentId'];
//           final assignmentTitle = submissionDoc['title'] ?? 'Unknown Title';
//           final submissionDate = submissionDoc['submissionDate']?.toDate();
//           final correctAnswers = submissionDoc['correctAnswers'] as int? ?? 0;
//           final incorrectAnswers = submissionDoc['incorrectAnswers'] as int? ?? 0;
//
//           await _firestore
//               .collection('parents')
//               .doc(user.uid)
//               .collection('children')
//               .doc(childId)
//               .collection('assignments')
//               .doc(assignmentId)
//               .set({
//             'assignmentTitle': assignmentTitle,
//             'submissionDate': submissionDate,
//             'correctAnswers': correctAnswers,
//             'incorrectAnswers': incorrectAnswers,
//           });
//         }
//       }
//     } catch (e) {
//       print("Error updating child data: $e");
//     }
//   }
// }

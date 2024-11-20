// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dyslearn/MenuPage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ForParentsPage extends StatefulWidget {
//   @override
//   _ForParentsPageState createState() => _ForParentsPageState();
// }
//
// class _ForParentsPageState extends State<ForParentsPage> {
//   TextEditingController _usernameController = TextEditingController();
//   User? parentUser = FirebaseAuth.instance.currentUser;
//   List<Map<String, dynamic>> childrenData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchChildrenData();
//   }
//
//   // Fetch children profiles, their games, and assignments
//   Future<void> fetchChildrenData() async {
//     if (parentUser == null) return;
//
//     try {
//       QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
//           .collection('parents')
//           .doc(parentUser!.uid)
//           .collection('children')
//           .get();
//
//       List<Map<String, dynamic>> fetchedData = [];
//       for (var childDoc in childrenSnapshot.docs) {
//         Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
//         String childId = childDoc.id;
//
//         // Fetch games played by the child
//         QuerySnapshot gamesSnapshot = await FirebaseFirestore.instance
//             .collection('parents')
//             .doc(parentUser!.uid)
//             .collection('children')
//             .doc(childId)
//             .collection('gamesPlayed')
//             .get();
//
//         List<Map<String, dynamic>> games = gamesSnapshot.docs.map((doc) {
//           Map<String, dynamic> gameData = doc.data() as Map<String, dynamic>;
//           return {
//             'gameName': gameData['gameName'],
//             'score': gameData['score'],
//           };
//         }).toList();
//
//         // Fetch assignments submitted by the child
//         QuerySnapshot assignmentsSnapshot = await FirebaseFirestore.instance
//             .collection('parents')
//             .doc(parentUser!.uid)
//             .collection('children')
//             .doc(childId)
//             .collection('assignments')
//             .get();
//
//         List<Map<String, dynamic>> assignments = assignmentsSnapshot.docs.map((doc) {
//           Map<String, dynamic> assignmentData = doc.data() as Map<String, dynamic>;
//           return {
//             'assignmentTitle': assignmentData['assignmentTitle'],
//             'submissionDate': assignmentData['submissionDate'],
//           };
//         }).toList();
//
//         // Add child data with games and assignments
//         fetchedData.add({
//           'username': childData['username'],
//           'progress': childData['progress'] ?? 0,
//           'gamesPlayed': games,
//           'assignments': assignments,
//         });
//       }
//
//       setState(() {
//         childrenData = fetchedData;
//       });
//     } catch (e) {
//       print('Error fetching children data: $e');
//     }
//   }
//
//   // Create child profile
//   void _createChildProfile() async {
//     String userName = _usernameController.text.trim();
//
//     if (userName.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please enter a username'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }
//
//     if (parentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('No parent logged in'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }
//
//     // Check if a child profile with the given username already exists
//     QuerySnapshot childSnapshot = await FirebaseFirestore.instance
//         .collection('parents')
//         .doc(parentUser!.uid)
//         .collection('children')
//         .where('username', isEqualTo: userName)
//         .get();
//
//     if (childSnapshot.docs.isNotEmpty) {
//       // If a child profile with the same username exists, use the existing one
//       DocumentSnapshot existingChild = childSnapshot.docs.first;
//       String childUid = existingChild.id;
//
//       // Navigate to the child's dashboard with existing data
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MenuPage(
//             userId: parentUser!.uid,
//             userName: userName,
//             childUid: childUid, // Pass childUid for reference
//             progress: existingChild['progress'],
//             assignments: existingChild['assignments'] ?? [], // Safe access to assignments
//           ),
//         ),
//       );
//     } else {
//       // If no child profile exists, create a new one
//       String childUid = FirebaseFirestore.instance.collection('dummy').doc().id;
//
//       // Save the new child profile in the 'children' subcollection under this parent
//       await FirebaseFirestore.instance
//           .collection('parents')
//           .doc(parentUser!.uid)
//           .collection('children')
//           .doc(childUid)
//           .set({
//         'username': userName,
//         'progress': 0,
//         'assignments': [], // Initialize assignments as an empty list
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Child profile created successfully'),
//         backgroundColor: Colors.green,
//       ));
//
//       // Navigate to menu or dashboard for the new child
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MenuPage(
//             userId: parentUser!.uid,
//             userName: userName,
//             childUid: childUid,
//             progress: 0, // Start with initial progress
//             assignments: [],
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('For Parents'),
//         backgroundColor: Colors.lightBlue,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: InputDecoration(
//                 labelText: 'Enter Child Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _createChildProfile,
//               child: Text('Create or Use Existing Child Profile'),
//             ),
//             SizedBox(height: 30),
//             Expanded(
//               child: childrenData.isEmpty
//                   ? Center(child: Text('No children profiles available.'))
//                   : ListView.builder(
//                 itemCount: childrenData.length,
//                 itemBuilder: (context, index) {
//                   final child = childrenData[index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 8.0),
//                     child: ListTile(
//                       title: Text("Username: ${child['username']}"),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Progress: ${child['progress']}%"),
//                           Text("Games Played:"),
//                           ...child['gamesPlayed']
//                               .map<Widget>((games) => Text("- ${games['gameName']}: ${games['score']} points"))
//                               .toList(),
//                           Text("Assignments Submitted:"),
//                           ...child['assignments']
//                               .map<Widget>((assignment) => Text(
//                               "- ${assignment['assignmentTitle']} (Submitted: ${assignment['submissionDate']})"))
//                               .toList(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

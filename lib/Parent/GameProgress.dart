// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class GameProgressPage extends StatefulWidget {
//   final String selectedChildName;  // The selected child's name
//
//   GameProgressPage({required this.selectedChildName});
//
//   @override
//   _GameProgressPageState createState() => _GameProgressPageState();
// }
//
// class _GameProgressPageState extends State<GameProgressPage> {
//   late String parentId;
//   late String childId;
//   bool isLoading = true;
//   List<Map<String, dynamic>> progressList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       parentId = user.uid; // Set Parent ID
//       fetchChildData();
//     } else {
//       print("User not logged in");
//       setState(() => isLoading = false);
//     }
//   }
//
//   // Fetch child data based on the selected child's name
//   Future<void> fetchChildData() async {
//     try {
//       final parentDoc = await FirebaseFirestore.instance.collection('parents').doc(parentId).get();
//       if (parentDoc.exists) {
//         final childDocs = await FirebaseFirestore.instance
//             .collection('parents')
//             .doc(parentId)
//             .collection('children')
//             .where('name', isEqualTo: widget.selectedChildName)  // Use the selected child's name
//             .get();
//
//         if (childDocs.docs.isNotEmpty) {
//           final childDoc = childDocs.docs.first;
//           childId = childDoc.id;
//           print("Child ID: $childId");
//           await fetchProgressData();
//         } else {
//           print("No child found with name: ${widget.selectedChildName}");
//         }
//       }
//     } catch (e) {
//       print("Error fetching child data: $e");
//     }
//   }
//
//   // Fetch progress data for games based on the child ID
//   Future<void> fetchProgressData() async {
//     try {
//       final childRef = FirebaseFirestore.instance
//           .collection('parents')
//           .doc(parentId)
//           .collection('children')
//           .doc(childId);
//
//       final gameCategories = [
//         'Cat Word Game',
//         'Cherry Counting',
//         'Color Matching',
//         'Game Recognition',
//       ];
//
//       for (String category in gameCategories) {
//         final progressDocs = await childRef.collection(category).get();
//
//         for (var doc in progressDocs.docs) {
//           progressList.add({
//             'gameCategory': category,
//             'gameName': doc.id,
//             'lastScore': doc.data()['lastScore'] ?? 0,
//             'totalScore': doc.data()['totalScore'] ?? 0,
//             'attempts': doc.data()['attempts'] ?? 0,
//             'lastUpdated': (doc.data()['lastUpdated'] as Timestamp).toDate(),
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching progress data: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Game Progress - ${widget.selectedChildName}"),  // Show the selected child's name
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : progressList.isEmpty
//           ? Center(child: Text("No progress data available."))
//           : ListView.builder(
//         itemCount: progressList.length,
//         itemBuilder: (context, index) {
//           final progress = progressList[index];
//           return Card(
//             margin: EdgeInsets.all(8),
//             elevation: 5,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Category: ${progress['gameCategory']}",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Game: ${progress['gameName']}",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Last Score: ${progress['lastScore']}",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Total Score: ${progress['totalScore']}",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Attempts: ${progress['attempts']}",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Last Updated: ${progress['lastUpdated']}",
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

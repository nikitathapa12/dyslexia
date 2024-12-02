// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AssignmentReportPage extends StatelessWidget {
//   final String parentId;
//   final String childId;
//   final String childUsername;
//
//   AssignmentReportPage({
//     required this.parentId,
//     required this.childId,
//     required this.childUsername,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$childUsername - Assignment Report'),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('submissions')
//             .where('childId', isEqualTo: childId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No assignments submitted yet.'));
//           }
//
//           final submissions = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: submissions.length,
//             itemBuilder: (context, index) {
//               var submission = submissions[index];
//               String assignmentId = submission['assignmentID'];
//               String answer = submission['answer'];
//               Timestamp submittedAt = submission['submittedAt'];
//
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('assignments')
//                     .doc(assignmentId)
//                     .get(),
//                 builder: (context, assignmentSnapshot) {
//                   if (assignmentSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (assignmentSnapshot.hasError) {
//                     return Center(child: Text('Error: ${assignmentSnapshot.error}'));
//                   }
//                   if (!assignmentSnapshot.hasData) {
//                     return Center(child: Text('Assignment not found.'));
//                   }
//
//                   var assignment = assignmentSnapshot.data!;
//                   String title = assignment['title'];
//                   String description = assignment['description'];
//
//                   return Card(
//                     margin: EdgeInsets.all(8.0),
//                     child: ListTile(
//                       title: Text(title),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Description: $description'),
//                           Text('Answer: $answer'),
//                           Text('Submitted At: ${submittedAt.toDate()}'),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

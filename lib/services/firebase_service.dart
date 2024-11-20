// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseService {
//   Future<void> initializeChildData({
//     required String parentId,
//     required String childId,
//   }) async {
//     final firestore = FirebaseFirestore.instance;
//
//     try {
//       // Create the `gamePlayed` subcollection
//       await firestore
//           .collection('parents')
//           .doc(parentId)
//           .collection('children')
//           .doc(childId)
//           .collection('gamePlayed')
//           .doc('initialGame') // Optional: Add an initial document
//           .set({'placeholder': true});
//
//       // Create the `assignmentSubmitted` subcollection
//       await firestore
//           .collection('parents')
//           .doc(parentId)
//           .collection('children')
//           .doc(childId)
//           .collection('assignmentSubmitted')
//           .doc('initialAssignment') // Optional: Add an initial document
//           .set({'placeholder': true});
//
//       print("Subcollections created successfully for child $childId.");
//     } catch (e) {
//       print("Error initializing child subcollections: $e");
//     }
//   }
//
// }
//

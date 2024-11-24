import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add game progress to the individual child's gameProgress collection
  Future<void> addGameProgress({
    required String childId,
    required String gameName,
    required int lastScore,
    required int totalScore,
    required int attempts,
  }) async {
    try {
      // Reference to the gameProgress collection of the specific child
      DocumentReference progressDoc = _firestore
          .collection('children')  // Directly under 'children' collection
          .doc(childId)
          .collection('gameProgress')  // Game progress collection for each child
          .doc(gameName);  // Use the game name as the document ID

      // Set or update the progress for this game
      await progressDoc.set({
        'lastScore': lastScore,
        'totalScore': totalScore,
        'attempts': attempts,
        'lastUpdated': Timestamp.now(),
      });
      print('Game progress saved successfully');
    } catch (e) {
      print('Error saving game progress: $e');
    }
  }

  // Fetch game progress for a specific child
  Future<List<Map<String, dynamic>>> fetchChildProgress({
    required String childId,
  }) async {
    try {
      // Reference to the gameProgress collection of the specific child
      QuerySnapshot snapshot = await _firestore
          .collection('children')  // Directly under 'children' collection
          .doc(childId)
          .collection('gameProgress')  // Game progress collection
          .get();

      List<Map<String, dynamic>> progressData = snapshot.docs.map((doc) {
        return {
          'gameName': doc.id, // Game name is the document ID
          'lastScore': doc['lastScore'],
          'totalScore': doc['totalScore'],
          'attempts': doc['attempts'],
        };
      }).toList();

      return progressData;
    } catch (e) {
      print('Error fetching progress data: $e');
      return [];
    }
  }








  // Add assignment submission to the individual child's assignments collection
  Future<void> addAssignmentSubmission({
    required String childId,
    required String assignmentId,
    required String answer,
  }) async {
    try {
      DocumentReference submissionDoc = _firestore
          .collection('parents')
          .doc('parentuid')
          .collection('children')
          .doc(childId)
          .collection('submissions')
          .doc(assignmentId);

      await submissionDoc.set({
        'answer': answer,
        'submittedAt': Timestamp.now(),
      });
      print('Assignment submission saved successfully');
    } catch (e) {
      print('Error saving assignment submission: $e');
    }
  }


  // Fetch assignment submissions for a specific child
  Future<List<Map<String, dynamic>>> fetchChildAssignments({
    required String childId,
  }) async {
    try {
      // Reference to the assignmentSubmissions collection of the specific child
      QuerySnapshot snapshot = await _firestore
          .collection('children') // Directly under 'children' collection
          .doc(childId) // Specific child document
          .collection('assignments') // Subcollection for assignments
          .get();

      List<Map<String, dynamic>> assignmentData = snapshot.docs.map((doc) {
        return {
          'assignmentId': doc.id, // Assignment ID is the document ID
          'answer': doc['answer'],
          'submittedAt': doc['submittedAt'],
        };
      }).toList();

      return assignmentData;
    } catch (e) {
      print('Error fetching assignment data: $e');
      return [];
    }
  }
}

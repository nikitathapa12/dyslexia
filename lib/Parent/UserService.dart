import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add or update game data for a specific child
  Future<void> addGamePlayed({
    required String parentId,
    required String childId,
    required String gameName,
    required int lastScore,
  }) async {
    try {
      // Reference to the parents collection
      DocumentReference parentDoc = _firestore.collection('parents').doc(parentId);

      // Reference to the games collection under parent
      DocumentReference gameDoc = parentDoc
          .collection('games')
          .doc(gameName)  // Use the game name as a document ID
          .collection('gameData')
          .doc(childId);  // Use the childId as the document ID in the gameData collection

      // Fetch existing game data if it exists
      DocumentSnapshot snapshot = await gameDoc.get();

      if (snapshot.exists) {
        // If game data exists, update it
        Map<String, dynamic> existingData = snapshot.data() as Map<String, dynamic>;

        int updatedTotalScore = existingData['totalScore'] + lastScore;
        int updatedAttempts = existingData['attempts'] + 1;

        // Update the document with new values
        await gameDoc.update({
          'lastScore': lastScore,
          'totalScore': updatedTotalScore,
          'attempts': updatedAttempts,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Game data updated for child: $childId');
      } else {
        // If game data does not exist, create a new document
        await gameDoc.set({
          'childId': childId,
          'gameName': gameName,
          'lastScore': lastScore,
          'totalScore': lastScore,  // Set totalScore to lastScore initially
          'attempts': 1,  // Set initial attempts to 1
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('New game data added for child: $childId');
      }
    } catch (e) {
      print('Error updating game data for child $childId: $e');
      throw e;
    }
  }

  // Method to fetch game data for a specific child
  Future<Map<String, dynamic>?> fetchGameData({
    required String parentId,
    required String childId,
    required String gameName,
  }) async {
    try {
      DocumentReference gameDoc = _firestore
          .collection('parents')
          .doc(parentId)
          .collection('games')
          .doc(gameName)
          .collection('gameData')
          .doc(childId);

      DocumentSnapshot snapshot = await gameDoc.get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print('No game data found for child $childId in game $gameName');
        return null;
      }
    } catch (e) {
      print('Error fetching game data: $e');
      throw e;
    }
  }

  fetchChildProgress({required String parentId, required String childId}) {}
}

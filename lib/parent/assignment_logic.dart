import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_service.dart';

class AssignmentLogic {
  final UserService _userService = UserService();

  // Save assignment submission
  Future<void> saveAssignmentSubmission({
    required String childId,
    required String assignmentId,
    required String answer,
  }) async {
    await _userService.addAssignmentSubmission(
      childId: childId,
      assignmentId: assignmentId,
      answer: answer,
    );
  }

  // Fetch and display submitted assignments
  Future<void> displayChildAssignments({
    required String childId,
  }) async {
    List<Map<String, dynamic>> assignmentData = await _userService.fetchChildAssignments(
      childId: childId,
    );

    if (assignmentData.isNotEmpty) {
      for (var assignment in assignmentData) {
        print('Assignment ID: ${assignment['assignmentId']}');
        print('Answer: ${assignment['answer']}');
        print('Submitted At: ${assignment['submittedAt']}');
      }
    } else {
      print('No assignments submitted yet.');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:dyslearn/ViewAssignmentPage.dart';
import 'package:dyslearn/Parent/UserService.dart'; // Correct import of UserService
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsPage extends StatelessWidget {




  final String parentId;
  final String childId;
  final String childUsername;
  final String parentEmail;

  AssignmentsPage({
    required this.parentId,
    required this.childId,
    required this.childUsername,
    required this.parentEmail,

  });

  final UserService _userService = UserService();  // Initialize UserService

  // Function to handle the submission of the assignment
  Future<void> submitAssignment(String parentId, String childId, String assignmentId, String answer) async {
    print("Submitting the assignment...");
    try {
      if (parentId.isEmpty || childId.isEmpty) {
        print('Error: Parent ID or Child ID is empty');
        return;
      }

      // Check if the parent document exists
      final parentDoc = await FirebaseFirestore.instance.collection('parents').doc(parentId).get();
      if (!parentDoc.exists) {
        print('Error: Parent document does not exist for ID $parentId');
        return;
      }

      // Check if the child document exists
      final childDoc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .get();
      if (!childDoc.exists) {
        print('Error: Child document does not exist for ID $childId');
        return;
      }

      // Prepare data to be saved
      Map<String, dynamic> submissionData = {
        'childId': childId,
        'parentId': parentId,
        'assignmentId': assignmentId,
        'answer': answer,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // Save the submission
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('submissions')
          .add(submissionData);

      print("Assignment submitted successfully!");
    } catch (e) {
      print("Error submitting assignment: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No assignments available.'));
          }

          final assignments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              var assignment = assignments[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(assignment['title']),
                  subtitle: Text(assignment['description']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAssignmentPage(
                          assignmentId: assignment.id,
                          parentId: parentId,
                          childId: childId,
                          childUsername: childUsername,
                          parentEmail: parentEmail,
                          submitAssignment: submitAssignment,  // Pass the submit function here with assignment ID
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

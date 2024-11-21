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
  Future<void> submitAssignment(String assignmentId, String answer) async {
    try {
      if (parentId.isEmpty || childId.isEmpty) {
        print('Error: Parent ID or Child ID is empty');
        return;  // Don't proceed if IDs are invalid
      }

      print('Submitting answer for Parent ID: $parentId, Child ID: $childId');

      // Example: Save the answer to Firestore in a 'submissions' collection
      await FirebaseFirestore.instance.collection('parents')
          .doc(parentId)  // Use the correct parent ID
          .collection('children')
          .doc(childId)   // Use the correct child ID
          .collection('submissions')
          .add({
        'childId': childId,
        'parentId': parentId,
        'assignmentId': assignmentId,  // Storing assignment ID as reference
        'answer': answer,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      print("Answer submitted successfully");
    } catch (e) {
      print("Error submitting answer: $e");
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
                          submitAssignment: (answer) {
                            submitAssignment(assignment.id, answer);
                          },  // Pass the submit function here with assignment ID
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

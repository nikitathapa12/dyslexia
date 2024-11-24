import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslearn/ViewAssignmentPage.dart';
import 'package:dyslearn/Parent/UserService.dart'; // Correct import of UserService
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsPage extends StatelessWidget {
  final String? selectedChildName;

  AssignmentsPage({
    this.selectedChildName,
  });

  final UserService _userService = UserService(); // Initialize UserService

  // Function to handle the submission of the assignment
  Future<void> submitAssignment(String assignmentId, String answer, String assignmentType) async {
    // Get the currently logged-in parent's ID
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      // Access the parent's document
      DocumentReference parentDoc = FirebaseFirestore.instance.collection('parents').doc(parent.uid);

      // Retrieve the first child document in the 'children' subcollection
      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();
      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      final childDocs = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: selectedChildName)  // Use the selected child's name
          .get();

      String childId = childDocs.docs.first.id; // Extract the childId
      print("retrieved child id: $childId");

      // Prepare submission data with 'assignmentType' passed as a parameter
      Map<String, dynamic> submissionData = {
        'assignmentType': assignmentType, // Now assignmentType is correctly assigned
        'assignmentId': assignmentId,
        'answer': answer,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // Save submission data to Firestore
      await parentDoc
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
            .collection('assignments') // Assuming global assignments collection
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

              // Cast the assignment data to Map<String, dynamic>
              var assignmentData = assignment.data() as Map<String, dynamic>;

              // Safely access the 'type' field, checking if it exists
              String assignmentType = assignmentData.containsKey('type')
                  ? assignmentData['type']
                  : 'No Type'; // Default value if 'type' is missing

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(assignmentData['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignmentData['description'] ?? 'No Description'),
                      SizedBox(height: 4),
                      Text(
                        'Type: $assignmentType', // Display the assignment type
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Ensure you pass the correct IDs before navigating
                    User? parent = FirebaseAuth.instance.currentUser;
                    if (parent != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewAssignmentPage(
                            assignmentId: assignment.id,
                            assignmentType: assignmentType, // Passing assignmentType here
                            submitAssignment: (assignmentId, answer) {
                              submitAssignment(assignmentId, answer, assignmentType); // Pass assignmentType
                            },
                            selectedChildName: selectedChildName, // Use the parameter
                          ),
                        ),
                      );
                    } else {
                      print("No parent logged in. Cannot navigate.");
                    }
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

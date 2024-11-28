import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslearn/user/ViewAssignmentPage.dart';
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
        title: Text('Assignments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'OpenDyslexic')),
        backgroundColor: Colors.teal, // Teal color for the app bar
        elevation: 4,
      ),
      backgroundColor: Colors.teal[50], // Light teal background color
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
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No assignments available.', style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14)));
          }

          final assignments = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              var assignment = assignments[index];

              // Cast the assignment data to Map<String, dynamic>
              var assignmentData = assignment.data() as Map<String, dynamic>;

              // Safely access the 'type' field, checking if it exists
              String assignmentType = assignmentData.containsKey('assignmentType')
                  ? assignmentData['assignmentType']
                  : 'No Type'; // Default value if 'assignmentType' is missing
// Default value if 'type' is missing

              return Card(
                color: Colors.white, // White background for cards
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  title: Text(
                    assignmentData['title'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'OpenDyslexic'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        assignmentData['description'] ?? 'No Description',
                        style: TextStyle(color: Colors.grey[700], fontFamily: 'OpenDyslexic', fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Type: $assignmentType', // Display the assignment type
                        style: TextStyle(fontSize: 14, color: Colors.teal[700], fontFamily: 'OpenDyslexic'),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward, color: Colors.teal),
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

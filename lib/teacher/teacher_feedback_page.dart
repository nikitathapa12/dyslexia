import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeacherFeedbackPage extends StatefulWidget {
  @override
  _TeacherFeedbackPageState createState() => _TeacherFeedbackPageState();
}

class _TeacherFeedbackPageState extends State<TeacherFeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedbacks') // Updated to correct collection name
            .orderBy('timestamp', descending: true) // Sort by timestamp for latest feedback first
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final feedbackDocs = snapshot.data!.docs;

          if (feedbackDocs.isEmpty) {
            return Center(
              child: Text(
                'No feedback available yet.',
                style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback = feedbackDocs[index];

              // Extract the feedback details
              String? childUsername = feedback['childUsername'] ?? 'Unknown'; // Fetch the child username
              String? parentEmail = feedback['parentEmail'] ?? 'Unknown Parent'; // Fetch the parent email
              String? feedbackText = feedback['feedback'] ?? 'No feedback provided'; // Fetch the feedback text

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[50], // Light teal background for the card
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Child: $childUsername',
                          style: TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          feedbackText!,
                          style: TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'From: $parentEmail',
                            style: TextStyle(
                              fontFamily: 'OpenDyslexic',
                              fontSize: 14,
                              color: Colors.teal[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

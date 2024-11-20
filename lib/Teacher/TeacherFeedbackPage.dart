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
      appBar: AppBar(
        title: Text(
          'Parent Feedback',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 20),
        ),
        backgroundColor: Colors.teal,
      ),
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
                style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback = feedbackDocs[index];

              // Extract the feedback details
              String? childUsername = feedback['childUsername'] ?? 'Unknown'; // Fetch the child username
              String? parentEmail = feedback['parentEmail'] ?? 'Unknown Parent'; // Fetch the parent email
              String? feedbackText = feedback['feedback'] ?? 'No feedback provided'; // Fetch the feedback text

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    'Child: $childUsername',
                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 18),
                  ),
                  subtitle: Text(
                    feedbackText!,
                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
                  ),
                  trailing: Text(
                    'From: $parentEmail',
                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 12),
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

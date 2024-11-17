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
            .collection('feedback') // Feedback collection
            .orderBy('timestamp', descending: true)
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
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    'Child: ${feedback['username'] ?? 'Unknown'}',
                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 18),
                  ),
                  subtitle: Text(
                    feedback['feedback'] ?? '',
                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
                  ),
                  trailing: Text(
                    feedback['parentEmail'] ?? '',
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

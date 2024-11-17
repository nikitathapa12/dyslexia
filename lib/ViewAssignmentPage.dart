import 'dart:io'; // For handling files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
import 'MenuPage.dart';

class ViewAssignmentPage extends StatefulWidget {
  final String assignmentId; // Declare assignmentId here

  // Constructor to accept assignmentId as a parameter
  ViewAssignmentPage({required this.assignmentId});

  @override
  _ViewAssignmentPageState createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  late DocumentSnapshot assignment;
  late String assignmentType;
  late String title;
  late String description;
  late String imageUrl;
  late String audioUrl;

  final Map<String, TextEditingController> answerControllers = {};

  @override
  void initState() {
    super.initState();
    fetchAssignmentData();
  }

  // Fetch assignment data from Firestore using assignmentId
  Future<void> fetchAssignmentData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentId) // Use widget.assignmentId here
          .get();

      setState(() {
        assignment = snapshot;
        assignmentType = snapshot['assignmentType'];
        title = snapshot['title'];
        description = snapshot['description'];
        imageUrl = snapshot['imageUrl'] ?? '';
        audioUrl = snapshot['audioUrl'] ?? '';

        // Add a controller for each answer field dynamically
        answerControllers['answer'] = TextEditingController();
      });
    } catch (e) {
      print("Error fetching assignment data: $e");
    }
  }

  // Submit the child's answers
  Future<void> submitAssignment() async {
    try {
      final Map<String, dynamic> submittedData = {
        'assignmentId': widget.assignmentId, // Use widget.assignmentId here
        'answer': answerControllers['answer']!.text,
        'submittedAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('submissions').add(submittedData);

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment Submitted!')));
    } catch (e) {
      print("Error submitting assignment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: assignment == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(description),
              SizedBox(height: 20),

              // Display image if available
              if (imageUrl.isNotEmpty)
                Image.network(imageUrl),
              SizedBox(height: 20),

              // Display audio if available
              if (audioUrl.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    // Play audio logic goes here
                  },
                ),
              SizedBox(height: 20),

              // TextField for answers
              TextField(
                controller: answerControllers['answer'],
                decoration: InputDecoration(labelText: 'Enter your answer'),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: submitAssignment,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

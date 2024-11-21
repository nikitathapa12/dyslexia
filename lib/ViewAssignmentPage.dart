import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAssignmentPage extends StatefulWidget {
  final String assignmentId;
  final String parentEmail;
  final String childUsername;
  final String childId;
  final String parentId;
  final Function(String) submitAssignment; // Single argument (answer)

  ViewAssignmentPage({
    required this.assignmentId,
    required this.parentEmail,
    required this.childUsername,
    required this.childId,
    required this.parentId,
    required this.submitAssignment,  // Pass submitAssignment function
  });

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

  Future<void> fetchAssignmentData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentId)
          .get();

      setState(() {
        assignment = snapshot;
        assignmentType = snapshot['assignmentType'];
        title = snapshot['title'];
        description = snapshot['description'];
        imageUrl = snapshot['imageUrl'] ?? '';
        audioUrl = snapshot['audioUrl'] ?? '';

        answerControllers['answer'] = TextEditingController();
      });
    } catch (e) {
      print("Error fetching assignment data: $e");
    }
  }

  Future<void> submitAssignment() async {
    try {
      final answer = answerControllers['answer']!.text;
      widget.submitAssignment(answer);  // Call the passed function to submit answer

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

              if (imageUrl.isNotEmpty)
                Image.network(imageUrl),
              SizedBox(height: 20),

              if (audioUrl.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    // Play audio logic goes here
                  },
                ),
              SizedBox(height: 20),

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

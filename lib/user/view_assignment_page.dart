import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ViewAssignmentPage extends StatefulWidget {
  final String? selectedChildName;


  final String assignmentId;
  final String assignmentType;

  final Function(String, String, ) submitAssignment;

  ViewAssignmentPage({
    required this.assignmentId,
    required this.assignmentType,
    required this.submitAssignment,
    required this.selectedChildName,
  });

  @override
  _ViewAssignmentPageState createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  String title = 'Untitled Assignment';
  String description = 'No description available.';
  List<Map<String, dynamic>> questions = [];

  // Map to track selected answers for each question
  final Map<String, String> selectedAnswers = {};

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

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          title = data['title'] ?? 'Untitled Assignment';
          description = data['description'] ?? 'No description available.';
          questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        });
      } else {
        print("Assignment does not exist in Firestore.");
      }
    } catch (e) {
      print("Error fetching assignment data: $e");
    }
  }

  Widget buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return SizedBox.shrink();
    } else if (imagePath.startsWith('/data/user/')) {
      return Image.file(
        File(imagePath),
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox.shrink();
        },
      );
    } else if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 250,
        height: 250,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox.shrink();
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Future<void> submitAssignment() async {
    try {
      Map<String, String> answers = {};

      questions.forEach((question) {
        if (question.containsKey('question')) {
          answers[question['question']] = selectedAnswers[question['question']] ?? '';
        }
      });

      widget.submitAssignment(
        widget.assignmentId,
        answers.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment Submitted!')));
    } catch (e) {
      print("Error submitting assignment: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text('View Assignment', style: TextStyle(color: Colors.white)),  // White text color for contrast
        backgroundColor: Colors.teal,  // Teal background color
       ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenDyslexic',
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 15),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'OpenDyslexic',
                  height: 1.5,
                  color: Colors.teal[700],
                ),
              ),
              SizedBox(height: 25),

              // Display questions with options
              for (var question in questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question['question'] ?? 'No question available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenDyslexic',
                              color: Colors.teal[900],
                            ),
                          ),
                          SizedBox(height: 15),


                          for (var option in question['options'] ?? [])
                            if (option['image'] != null && option['image'] is String && option['image'].isNotEmpty)
                              Row(
                                children: [
                                  Radio<String>(
                                    value: option['image'],
                                    groupValue: selectedAnswers[question['question']] ?? '',
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[question['question']] = value ?? '';
                                      });
                                    },
                                  ),
                                  buildImage(option['image']),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Radio<String>(
                                    value: option['text'],
                                    groupValue: selectedAnswers[question['question']] ?? '',
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[question['question']] = value ?? '';
                                      });
                                    },
                                  ),
                                  Text(
                                    option['text'] ?? 'No text available',
                                    style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: submitAssignment,
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 14, horizontal: 30)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

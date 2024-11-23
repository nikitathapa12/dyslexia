import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAssignmentPage extends StatefulWidget {
  final String assignmentId;
  final String parentEmail;
  final String childUsername;
  final String childId;
  final String parentId;
  final Function(String, String, String, String) submitAssignment;

  ViewAssignmentPage({
    required this.assignmentId,
    required this.parentEmail,
    required this.childUsername,
    required this.childId,
    required this.parentId,
    required this.submitAssignment,
  });

  @override
  _ViewAssignmentPageState createState() => _ViewAssignmentPageState();
}

class _ViewAssignmentPageState extends State<ViewAssignmentPage> {
  String title = 'Untitled Assignment';
  String description = 'No description available.';
  String imageUrl = '';
  String audioUrl = '';
  List<Map<String, dynamic>> questions = [];
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

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          title = data['title'] ?? 'Untitled Assignment';
          description = data['description'] ?? 'No description available.';
          imageUrl = data['imageUrl'] ?? '';
          audioUrl = data['audioUrl'] ?? '';

          // Safely retrieve 'questions' array
          if (data.containsKey('questions')) {
            questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
            // Initialize controllers for each question's answer
            for (var question in questions) {
              if (question.containsKey('question')) {
                answerControllers[question['question']] = TextEditingController();
              }
            }
          }
        });
      } else {
        print("Assignment does not exist in Firestore.");
      }
    } catch (e) {
      print("Error fetching assignment data: $e");
    }
  }

  Future<void> submitAssignment() async {
    try {
      Map<String, String> answers = {};

      // Collect answers for each question
      questions.forEach((question) {
        if (question.containsKey('question')) {
          answers[question['question']] = answerControllers[question['question']]!.text;
        }
      });

      widget.submitAssignment(widget.parentId, widget.childId, widget.assignmentId, answers.toString());

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(description),
              SizedBox(height: 20),

              if (imageUrl.isNotEmpty) Image.network(imageUrl),
              SizedBox(height: 20),

              if (audioUrl.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    // Play audio logic
                  },
                ),
              SizedBox(height: 20),

              // Display questions and options
              for (var question in questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'] ?? 'No question available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      // Display options as either text or image
                      for (var option in question['options'] ?? [])
                        if (option.containsKey('text') && option['text'] is String)
                        // Text Option
                          Row(
                            children: [
                              Radio<String>(
                                value: option['text'],
                                groupValue: answerControllers[question['question']]!.text,
                                onChanged: (value) {
                                  setState(() {
                                    answerControllers[question['question']]!.text = value ?? '';
                                  });
                                },
                              ),
                              Text(option['text']),
                            ],
                          )
                        else if (option.containsKey('image') && option['image'] is String && option['image'].isNotEmpty)
                        // Image Option
                          Row(
                            children: [
                              Radio<String>(
                                value: option['image'],
                                groupValue: answerControllers[question['question']]!.text,
                                onChanged: (value) {
                                  setState(() {
                                    answerControllers[question['question']]!.text = value ?? '';
                                  });
                                },
                              ),
                              Image.network(option['image'], width: 50, height: 50),
                            ],
                          ),
                    ],
                  ),
                ),

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

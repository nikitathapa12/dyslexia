import 'dart:io'; // To handle file operations
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // For local file storage

class TeacherAddAssignmentPage extends StatefulWidget {
  @override
  _TeacherAddAssignmentPageState createState() =>
      _TeacherAddAssignmentPageState();
}

class _TeacherAddAssignmentPageState extends State<TeacherAddAssignmentPage> {
  String selectedAssignmentType = 'Matching Words with Images'; // Default type
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> questions = [];

  final List<String> assignmentTypes = [
    'Matching Words with Images',


    'Games and Quizzes',
    'Matching Word with Picture',
    'Fill the First Letter',
    'Number Fill-In',
    'Food Fill-In with Picture',
    'Letter Recognition Fill-In',
    'Body Part Fill-In',
  ];

  // Function to upload files locally
  Future<String?> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return null;

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      // Save file locally
      Directory appDir = await getApplicationDocumentsDirectory();
      String localPath = '${appDir.path}/$fileName';

      File file = File(filePath);
      await file.copy(localPath);

      return localPath;
    } catch (e) {
      print("ERROR: File save failed: $e");
      return null;
    }
  }

  // Function to submit assignment data to Firestore
  Future<void> submitAssignment() async {
    final assignmentData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'assignmentType': selectedAssignmentType,
      'questions': questions,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('assignments').add(assignmentData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment added successfully!')),
      );

      await createNotification();

      // Clear all fields
      titleController.clear();
      descriptionController.clear();
      setState(() {
        questions = [];
      });
    } catch (e) {
      print("ERROR: Failed to add assignment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add assignment!')),
      );
    }
  }

  // Function to create a notification for users and parents
  Future<void> createNotification() async {
    final notificationData = {
      'title': 'New Assignment Uploaded',
      'message': 'A new assignment has been uploaded: ${titleController.text}',
      'userType': 'user', // Can set this dynamically based on user type
      'read': false,
      'timestamp': Timestamp.now(),
    };

    try {
      // Add notification for users
      await FirebaseFirestore.instance.collection('notifications').add(notificationData);

      // Optionally, add notification for parents (if needed)
      notificationData['userType'] = 'parent'; // Adjust for parent type
      await FirebaseFirestore.instance.collection('notifications').add(notificationData);
    } catch (e) {
      // Handle errors (e.g., network issues)
      print("Error creating notification: $e");
    }
  }

  // Widget to dynamically add questions
  Widget buildQuestionCard(int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Question ${index + 1}',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                questions[index]['question'] = value;
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Hint (Optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                questions[index]['hint'] = value;
              },
            ),
            SizedBox(height: 8),
            ...List.generate(
              questions[index]['options'].length,
                  (optionIndex) => Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Option ${optionIndex + 1}',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        questions[index]['options'][optionIndex]['text'] = value;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.teal),
                    onPressed: () async {
                      String? localImagePath = await uploadFile();
                      if (localImagePath != null) {
                        setState(() {
                          questions[index]['options'][optionIndex]['image'] =
                              localImagePath;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        questions[index]['options'].removeAt(optionIndex);
                      });
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  questions[index]['options'].add({'text': '', 'image': ''});
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Add Option'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  questions.removeAt(index);
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Remove Question'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Assignment',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Assignment Title',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14,)
            ),
            SizedBox(height: 16),
            // Description
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Assignment Description',
                border: OutlineInputBorder(),
              ),
                style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14,)
            ),
            SizedBox(height: 16),
            // Assignment Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedAssignmentType,
              items: assignmentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAssignmentType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Assignment Type',
              ),
                style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14,)
            ),
            SizedBox(height: 16),
            // Questions
            ...List.generate(
              questions.length,
                  (index) => buildQuestionCard(index),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  questions.add({
                    'question': '',
                    'hint': '',
                    'options': [{'text': '', 'image': ''}]
                  });
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Add Question',  style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14)),
            ),
            SizedBox(height: 16),
            // Submit Button
            ElevatedButton(
              onPressed: submitAssignment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Submit Assignment', style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

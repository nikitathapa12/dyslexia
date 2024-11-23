import 'dart:io'; // To handle file operations
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

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
    'Sentence Construction',
    'Fill-in-the-Blank with Audio Support',
    'Games and Quizzes',
    'Matching Word with Picture',
    'Fill the First Letter',
    'Number Fill-In',
    'Food Fill-In with Picture',
    'Letter Recognition Fill-In',
    'Body Part Fill-In',
  ];

  // Function to upload files to Firebase Storage
  Future<String?> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return null;

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;
      File file = File(filePath);

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${fileName.replaceAll(RegExp(r"[^\w\-\.]"), "_")}');

      UploadTask uploadTask = storageRef.putFile(file);
      await uploadTask;

      return await storageRef.getDownloadURL();
    } catch (e) {
      print("ERROR: File upload failed: $e");
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
                      String? imageUrl = await uploadFile();
                      if (imageUrl != null) {
                        setState(() {
                          questions[index]['options'][optionIndex]['image'] =
                              imageUrl;
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
        title: Text('Add Assignment'),
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
            ),
            SizedBox(height: 16),
            // Description
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Assignment Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Assignment Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedAssignmentType,
              items: assignmentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
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
              child: Text('Add Question'),
            ),
            SizedBox(height: 16),
            // Submit Button
            ElevatedButton(
              onPressed: submitAssignment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Submit Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}

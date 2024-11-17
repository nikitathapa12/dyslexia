import 'dart:io'; // Import to work with File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
import 'package:file_picker/file_picker.dart'; // File picker package

class TeacherAddAssignmentPage extends StatefulWidget {
  @override
  _TeacherAddAssignmentPageState createState() =>
      _TeacherAddAssignmentPageState();
}

class _TeacherAddAssignmentPageState extends State<TeacherAddAssignmentPage> {
  String selectedAssignmentType = 'Matching Words with Images'; // Default assignment type
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController shortAnswerController = TextEditingController();

  // Audio and Image File Variables
  String audioUrl = '';
  String imageUrl = '';

  // List of assignment types
  List<String> assignmentTypes = [
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

  // Function to add assignment data to Firestore
  Future<void> addAssignment() async {
    final Map<String, dynamic> assignmentData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'assignmentType': selectedAssignmentType,
      'question': questionController.text,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
    };

    try {
      // Save assignment data to Firebase Firestore
      await FirebaseFirestore.instance.collection('assignments').add(assignmentData);

      // Create a notification for both users and parents
      await createNotification();

      // Clear form after submission
      titleController.clear();
      descriptionController.clear();
      questionController.clear();
      shortAnswerController.clear();
      setState(() {
        audioUrl = '';
        imageUrl = '';
      });
    } catch (e) {
      // Handle errors (e.g., network issues)
      print("Error adding assignment: $e");
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

  // Function to upload files (image/audio) to Firebase Storage
  Future<void> uploadFile(String fileType) async {
    try {
      // Pick a file (image or audio) using FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        // Get the file path and name
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        // Create a File object from the file path
        File file = File(filePath);

        // Create a reference to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

        // Upload the file
        UploadTask uploadTask = storageRef.putFile(file);

        // Wait for the upload to complete
        await uploadTask.whenComplete(() async {
          // Get the URL of the uploaded file
          String fileUrl = await storageRef.getDownloadURL();

          // Update the imageUrl or audioUrl based on fileType
          if (fileType == 'audio') {
            audioUrl = fileUrl; // Update audio URL
          } else if (fileType == 'image') {
            imageUrl = fileUrl; // Update image URL
          }

          setState(() {
            // Optionally update the UI with success message or image/audio preview
          });
        });
      } else {
        // Handle case where no file was selected
        print("No file selected");
      }
    } catch (e) {
      // Handle any error
      print("Error uploading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Assignment Title', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: InputDecoration(hintText: 'Enter assignment title')),
              SizedBox(height: 20),

              // Description
              Text('Assignment Description', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: descriptionController, decoration: InputDecoration(hintText: 'Enter assignment description')),
              SizedBox(height: 20),

              // Assignment Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedAssignmentType,  // Ensure this value is correctly initialized
                items: assignmentTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedAssignmentType = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Assignment Type'),
              ),
              SizedBox(height: 20),

              // Show dynamic fields based on assignment type
              if (selectedAssignmentType == 'Reading Comprehension' ||
                  selectedAssignmentType == 'Audio-based Assignments') ...[
                // Text/Audio Upload for Comprehension or Listening
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Enter passage or audio-based question',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => uploadFile('audio'),  // Upload audio file
                  child: Text('Upload Audio'),
                ),
              ] else if (selectedAssignmentType == 'Simple Word Fill with Picture' ||
                  selectedAssignmentType == 'Food Fill-In with Picture' ||
                  selectedAssignmentType == 'Matching Word with Picture') ...[
                // Upload image for matching
                ElevatedButton(
                  onPressed: () => uploadFile('image'),  // Upload image
                  child: Text('Upload Image'),
                ),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Enter word for matching with image',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else if (selectedAssignmentType == 'Fill the First Letter' ||
                  selectedAssignmentType == 'Number Fill-In') ...[
                // Fill the first letter or number
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Enter the fill-in-the-blank question',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else if (selectedAssignmentType == 'Letter Recognition Fill-In' ||
                  selectedAssignmentType == 'Body Part Fill-In') ...[
                // Letter Recognition or Body Part fill-in
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Enter the question for recognition or body part',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addAssignment,
                child: Text('Add Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

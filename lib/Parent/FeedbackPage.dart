import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController _feedbackController = TextEditingController();
  String? selectedUsername; // Selected username
  List<String> usernames = []; // Usernames associated with the parent

  @override
  void initState() {
    super.initState();
    _fetchUsernames(); // Fetch usernames when the page loads
  }

  // Fetch all usernames associated with the parent's email
  void _fetchUsernames() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usernames')
          .where('parentEmail', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          usernames = querySnapshot.docs
              .map((doc) => doc['username'] as String)
              .toList();
        });
      }
    }
  }

  // Submit feedback
  void _submitFeedback() async {
    if (selectedUsername == null || selectedUsername!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a child\'s username'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback cannot be empty'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    // Save feedback to Firestore
    await FirebaseFirestore.instance.collection('feedback').add({
      'parentEmail': user?.email,
      'username': selectedUsername,
      'feedback': _feedbackController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Feedback submitted successfully!'),
      backgroundColor: Colors.green,
    ));

    // Clear the feedback field after submission
    _feedbackController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 18),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for selecting a username
            Text(
              'Select Child\'s Username:',
              style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedUsername,
              items: usernames
                  .map((username) => DropdownMenuItem<String>(
                value: username,
                child: Text(username),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedUsername = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Feedback text field
            Text(
              'Enter Feedback:',
              style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                hintText: 'Write your feedback here...',
              ),
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitFeedback,
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

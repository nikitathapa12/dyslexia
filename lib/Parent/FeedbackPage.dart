import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  String? selectedUsername; // Selected child's username
  List<String> usernames = []; // List of children usernames
  bool isLoading = true; // Loading indicator while fetching usernames

  @override
  void initState() {
    super.initState();
    _fetchChildrenUsernames(); // Fetch children usernames when the page loads
  }

  // Fetch all children profiles associated with the logged-in parent
  Future<void> _fetchChildrenUsernames() async {
    User? parentUser = FirebaseAuth.instance.currentUser;
    if (parentUser != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('parents') // Parent collection
            .doc(parentUser.uid) // Get the parent document
            .collection('children') // Children subcollection
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            usernames = querySnapshot.docs
                .map((doc) => doc['name'] as String) // Assuming 'name' field exists
                .toList();
          });
        } else {
          setState(() {
            usernames = [];
          });
        }
      } catch (e) {
        print('Error fetching children: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching children: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Submit feedback for the selected child
  Future<void> _submitFeedback() async {
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

    User? parentUser = FirebaseAuth.instance.currentUser;

    if (parentUser != null) {
      try {
        // Save feedback to Firestore
        await FirebaseFirestore.instance.collection('feedbacks').add({
          'parentEmail': parentUser.email,
          'childUsername': selectedUsername,
          'feedback': _feedbackController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Feedback submitted successfully!'),
          backgroundColor: Colors.green,
        ));

        // Clear the feedback field after submission
        _feedbackController.clear();
        setState(() {
          selectedUsername = null; // Reset the dropdown
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error submitting feedback: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submit Feedback',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for selecting the child's username
            Text(
              'Select Child\'s Username:',
              style: TextStyle(fontSize: 16),
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
              hint: Text('Choose a child'),
            ),
            SizedBox(height: 16),

            // Feedback text field
            Text(
              'Enter Feedback:',
              style: TextStyle(fontSize: 16),
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
                onPressed: _submitFeedback,
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenDyslexic', // Use OpenDyslexic font here
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          color: Color(0xFFE0F7FA), // Soft pastel blue background for dyslexic-friendly design
        ),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select child's username
                  Text(
                    'Select Child\'s Username:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenDyslexic',
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedUsername,
                    items: usernames
                        .map((username) => DropdownMenuItem<String>(
                      value: username,
                      child: Text(
                        username,
                        style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic'),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUsername = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.teal[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.teal[300]!,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'Choose a child',
                      hintStyle: TextStyle(fontSize: 16, color: Colors.teal[400]),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Feedback text field
                  Text(
                    'Enter Feedback:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenDyslexic',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.teal[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.teal[300]!,
                          width: 1,
                        ),
                      ),
                      hintText: 'Write your feedback here...',
                      hintStyle: TextStyle(color: Colors.teal[400]),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'OpenDyslexic',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

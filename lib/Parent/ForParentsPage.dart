import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslearn/MenuPage.dart';

class ForParentsPage extends StatefulWidget {
  @override
  _ForParentsPageState createState() => _ForParentsPageState();
}

class _ForParentsPageState extends State<ForParentsPage> {
  TextEditingController _usernameController = TextEditingController();
  List<String> existingUsernames = []; // To store all existing usernames

  @override
  void initState() {
    super.initState();
    _getExistingUsernames();  // Fetch existing usernames when the page loads
  }

  // Fetch all existing usernames associated with the logged-in parent's email
  void _getExistingUsernames() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Logged in as: ${user.email}');  // Debugging: Check the logged-in user's email

      // Fetch documents from Firestore where parentEmail matches the logged-in parent's email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usernames')
          .where('parentEmail', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          existingUsernames = querySnapshot.docs
              .map((doc) => doc['username'] as String) // Ensure each username is treated as a String
              .toList();
          print('Existing usernames: $existingUsernames');  // Debugging: Check the fetched usernames
        });
      } else {
        print('No existing usernames found for this parent.');  // Debugging: No usernames found
      }
    } else {
      print('No user is logged in.');  // Debugging: If the user is not logged in
    }
  }

  // Function to create or update the username
  void _createUserProfile() async {
    String userName = _usernameController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Please enter a username',
          style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic'),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Check if the current user already has a username
    if (!existingUsernames.contains(userName)) {
      // If no username exists or the entered username is new, save the new one
      await FirebaseFirestore.instance.collection('usernames').add({
        'username': userName,
        'parentEmail': user?.email,  // Storing the parent email as well
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile created with username: $userName'),
        backgroundColor: Colors.green,
      ));
    } else {
      // Username exists, do not create a new one
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Username already exists. Using the existing one.'),
        backgroundColor: Colors.green,
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPage(
          userId: user?.uid ?? '',
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          'For Parents',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cartoon.gif'), // Replace with your image
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display message based on whether the username exists or not
                  existingUsernames.isEmpty
                      ? Text(
                    'Enter Child\'s Username:',
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : Column(
                    children: [
                      Text(
                        'Existing Usernames:',
                        style: TextStyle(
                          fontFamily: 'OpenDyslexic',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Display all existing usernames as clickable items
                      Wrap(
                        children: existingUsernames
                            .map((username) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuPage(
                                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                  userName: username, // Use the selected username
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Chip(
                              label: Text(username),
                              backgroundColor: Colors.blueGrey,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),

                  // Show TextField for creating a new username even if existing usernames exist
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      labelText: 'New Username',
                      labelStyle: TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Button to either create a new profile or use the existing profile
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      String userName = _usernameController.text.trim();
                      if (userName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Please enter a new username',
                            style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic'),
                          ),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        // Create new profile with the entered username
                        _createUserProfile();
                      }
                    },
                    child: Text(
                      'Create New Profile',
                      style: TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 14,
                        color: Colors.white,
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

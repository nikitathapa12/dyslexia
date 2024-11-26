
import 'package:dyslearn/Parent/ProgressReportPage.dart';
import 'package:dyslearn/Parent/ViewChildList.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ChildProfilePage extends StatefulWidget {
  @override
  _ChildProfilePageState createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  File? _imageFile; // For storing profile picture
  bool _isLoading = false;
  String? _gameData;  // To store and display game data

  @override
  void initState() {
    super.initState();
    _fetchGameData(); // Fetch game data when the profile is loaded
  }

  Future<void> _fetchGameData() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      return;
    }

    DocumentReference parentDoc = FirebaseFirestore.instance.collection('parents').doc(parent.uid);
    CollectionReference children = parentDoc.collection('children');

    try {
      // Fetch all children under the parent
      QuerySnapshot childSnapshot = await children.get();

      for (var childDoc in childSnapshot.docs) {
        String childId = childDoc.id; // Now this is dynamically fetched
        print("Retrieved childId: $childId");

        DocumentSnapshot child = await childDoc.reference.get();
        if (child.exists) {
          // Fetch gameData directly from the child’s collection
          CollectionReference gameDataCollection = child.reference.collection('gameData');
          QuerySnapshot gameDataSnapshot = await gameDataCollection.get();

          if (gameDataSnapshot.docs.isNotEmpty) {
            var gameData = gameDataSnapshot.docs[0].data() as Map<String, dynamic>?;
            if (gameData != null) {
              setState(() {
                _gameData = gameData['lastScore']?.toString() ?? 'No score available';
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching game data: $e');
    }
  }



  Future<void> _createChildProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Get the current user (parent)
      User? parent = FirebaseAuth.instance.currentUser;

      if (parent == null) {
        // If no user is logged in, show a message to log in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to create a child profile.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        // Reference to the specific parent document
        DocumentReference parentDoc = FirebaseFirestore.instance.collection('parents').doc(parent.uid);

        // Reference to Firestore subcollection 'children' under the parent
        CollectionReference children = parentDoc.collection('children');

        // Prepare child profile data
        DocumentReference childDoc = await children.add({
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          // 'level': _levelController.text,
          // 'preferences': _preferencesController.text,
          'profilePic': _imageFile != null ? await _uploadProfilePic() : null,
          'createdAt': Timestamp.now(),
        });

        // Create the gameData subcollection under this child's document
        CollectionReference gameDataCollection = childDoc.collection('gameData');

        // Prepare game data to store in Firestore
        Map<String, dynamic> gameData = {
          'lastScore': 0, // Set initial score or previous score if available
          'totalScore': 0, // Set initial total score
          'attempts': 0, // Set initial attempts
          'lastUpdated': Timestamp.now(),
        };

        // Add gameData document to the 'gameData' subcollection
        await gameDataCollection.add(gameData);

        // Clear fields after submission
        _nameController.clear();
        _ageController.clear();
        _levelController.clear();
        _preferencesController.clear();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Child profile created successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating child profile: $e')));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadProfilePic() async {
    if (_imageFile == null) return null;

    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pics/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageReference.putFile(_imageFile!);
      await uploadTask;
      final downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Child Profile',
          style: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.child_care),
            tooltip: 'View Children',
            onPressed: () {
              // Navigate to the ViewChildList page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewChildList()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Text(
                'Child\'s Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Child\'s Name',
                  labelStyle: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Child\'s Age',
                  labelStyle: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.cake, color: Colors.teal),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),



              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createChildProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Profile',
                  style: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // if (_gameData != null)
              //   Text(
              //     'Last Game Score: $_gameData',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontFamily: 'OpenDyslexic',
              //       fontSize: 14,
              //       color: Colors.teal.shade800,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

}


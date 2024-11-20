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
        DocumentReference parentDoc =
        FirebaseFirestore.instance.collection('parents').doc(parent.uid);

        // Reference to Firestore subcollection 'children' under the parent
        CollectionReference children = parentDoc.collection('children');

        // Prepare data to store in Firestore
        await children.add({
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'level': _levelController.text,
          'preferences': _preferencesController.text,
          'profilePic': _imageFile != null ? await _uploadProfilePic() : null,
          'createdAt': Timestamp.now(),
        });

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
    // Code to upload image to Firebase Storage if needed
    // Returns the URL of the uploaded image
    if (_imageFile == null) return null;

    // Assuming Firebase Storage setup is done and a reference to a folder is available
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
        title: Text('Create Child Profile'),
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
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Child\'s Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Child\'s Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _levelController,
                decoration: InputDecoration(labelText: 'Dyslexia Level'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dyslexia level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _preferencesController,
                decoration: InputDecoration(labelText: 'Learning Preferences'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter learning preferences';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createChildProfile,
                child: Text('Create Profile'),
              ),
              SizedBox(height: 16),


            ],
          ),
        ),
      ),
    );
  }
}

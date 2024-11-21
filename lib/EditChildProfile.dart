import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditChildProfile extends StatefulWidget {
  final String childName; // The parameter to receive the child's name

  EditChildProfile({Key? key, required this.childName}) : super(key: key);


  @override
  _EditChildProfileState createState() => _EditChildProfileState();
}

class _EditChildProfileState extends State<EditChildProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  String? selectedLearningPreference;
  List<String> learningPreferences = [
    'Visual',
    'Auditory',
    'Kinesthetic',
    'Reading/Writing',
  ];
  File? _imageFile; // For profile picture
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? parent = FirebaseAuth.instance.currentUser;
      if (parent == null) return;

      DocumentReference childDoc = FirebaseFirestore.instance
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .doc(widget.childName);

      DocumentSnapshot snapshot = await childDoc.get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          _nameController.text = data['name'] ?? '';
          _ageController.text = (data['age'] ?? '').toString();
          _levelController.text = data['level'] ?? '';
          selectedLearningPreference = data['preferences'] ?? 'Not specified';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load child data: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateChildProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? parent = FirebaseAuth.instance.currentUser;
        if (parent == null) return;

        DocumentReference childDoc = FirebaseFirestore.instance
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(widget.childName);

        await childDoc.update({
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'level': _levelController.text,
          'preferences': selectedLearningPreference ?? 'Not specified',
          'profilePic': _imageFile != null ? await _uploadProfilePic() : null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update child profile: $e')),
        );
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
        title: Text('Edit Child Profile'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  // Implement image picker here
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal[100],
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.teal[700],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Child\'s Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Child\'s Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Level Field
              TextFormField(
                controller: _levelController,
                decoration: InputDecoration(
                  labelText: 'Child\'s Level',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s level';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Learning Preference Dropdown
              DropdownButtonFormField<String>(
                value: selectedLearningPreference,
                decoration: InputDecoration(
                  labelText: 'Learning Preference',
                  border: OutlineInputBorder(),
                ),
                items: learningPreferences.map((preference) {
                  return DropdownMenuItem(
                    value: preference,
                    child: Text(preference),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLearningPreference = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Update Profile Button
              ElevatedButton(
                onPressed: _updateChildProfile,
                child: Text('Update Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

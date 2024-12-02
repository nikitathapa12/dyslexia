import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication


class EditChildProfile extends StatefulWidget {
  final String childId;
  final String name;
  final int age;


  const EditChildProfile({
    Key? key,
    required this.childId,
    required this.name,
    required this.age,

  }) : super(key: key);

  @override
  _EditChildProfileState createState() => _EditChildProfileState();
}

class _EditChildProfileState extends State<EditChildProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age.toString());
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Update child details in Firestore
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('children')
          .doc(widget.childId)
          .update({
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child profile updated successfully')),
      );
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Child Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

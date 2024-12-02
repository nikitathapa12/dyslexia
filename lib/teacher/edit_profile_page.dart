import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                       AssetImage('assets/images/profile_placeholder.png'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
                    prefixIcon: Icon(Icons.email),
                  ),
                  style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await user!.updateDisplayName(_nameController.text);
                        await user.updateEmail(_emailController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Profile updated successfully',
                              style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),)));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update profile',
                            style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),)),
                        );
                      }
                    }
                  },
                  child: Text('Save Changes',
                      style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

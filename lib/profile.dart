import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final String userId;

  Profile({required this.userId}); // Only userId is required

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  String? _name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 24),
        ),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("User data not found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(userData),
                const SizedBox(height: 20),
                _buildAchievementsSection(userData),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showUpdateProfileDialog(context, userData),
                  icon: Icon(Icons.edit),
                  label: Text("Update Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build the profile section showing only the username
  Widget _buildProfileSection(Map<String, dynamic> userData) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Details",
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Username: ${userData['username'] ?? 'N/A'}", // Only show username
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Build the achievements section (if any)
  Widget _buildAchievementsSection(Map<String, dynamic> userData) {
    List achievements = userData['achievements'] ?? [];

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Achievements",
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            achievements.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text(achievements[index]),
                );
              },
            )
                : Text("No achievements yet."),
          ],
        ),
      ),
    );
  }

  // Show the update profile dialog to edit the username
  void _showUpdateProfileDialog(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Profile"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: userData['username'],
                  decoration: InputDecoration(labelText: "Username"),
                  onSaved: (value) => _name = value,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Username cannot be empty" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _updateProfile();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Update the username in Firestore
  void _updateProfile() {
    FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'username': _name,  // Only update the username
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslearn/MenuPage.dart'; // Import MenuPage

class ViewChildList extends StatelessWidget {
  const ViewChildList({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getChildren() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      throw Exception("User not logged in");
    }

    // Retrieve children from Firestore
    QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parent.uid)
        .collection('children')
        .get();

    // Map Firestore data to a list of maps
    return childrenSnapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'age': doc['age'],
        'level': doc['level'],
        'preferences': doc['preferences'],
        'profilePic': doc['profilePic'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Children List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No children added yet.'));
          }

          List<Map<String, dynamic>> children = snapshot.data!;
          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return ListTile(
                leading: child['profilePic'] != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(child['profilePic']),
                )
                    : CircleAvatar(
                  child: Icon(Icons.child_care),
                ),
                title: Text(child['name']),
                subtitle: Text(
                    'Age: ${child['age']} | Level: ${child['level']} | Preferences: ${child['preferences']}'),
                onTap: () {
                  // Navigate to MenuPage with the selected child's name
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPage(selectedChildName: child['name']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

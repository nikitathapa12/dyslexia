import 'package:dyslearn/user/edit_child_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslearn/menu_page.dart'; // Import MenuPage

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
        'id': doc.id, // Include document ID for deletion
        'name': doc['name'],
        'age': doc['age'],
        'profilePic': doc['profilePic'],
      };
    }).toList();
  }

  Future<void> _deleteChild(String childId) async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      throw Exception("User not logged in");
    }

    // Delete the child's data from Firestore
    await FirebaseFirestore.instance
        .collection('parents')
        .doc(parent.uid)
        .collection('children')
        .doc(childId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Children List',
          style: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 14,
                  color: Colors.redAccent,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No children added yet.',
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 14,
                  color: Colors.teal,
                ),
              ),
            );
          }

          List<Map<String, dynamic>> children = snapshot.data!;
          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 8, // Add shadow to the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.teal.shade50,
                  child: ListTile(
                    leading: child['profilePic'] != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(child['profilePic']),
                    )
                        : CircleAvatar(
                      child: Icon(
                        Icons.child_care,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    title: Text(
                      child['name'],
                      style: TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    subtitle: Text(
                      'Age: ${child['age']} ',
                      style: TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 14,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditChildProfile(
                                  childId: child['id'], // Pass child ID
                                  name: child['name'],  // Pass child name
                                  age: child['age'],    // Pass child age
                                  // Pass profile picture URL
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Child'),
                                content: Text('Are you sure you want to delete ${child['name']}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ?? false;

                            if (confirm) {
                              await _deleteChild(child['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${child['name']} has been deleted.'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                              (context as Element).reassemble(); // Refresh the widget
                            }
                          },
                        ),
                      ],
                    ),

                    onTap: () {
                      // Navigate to MenuPage with the selected child's name
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MenuPage(selectedChildName: child['name']),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

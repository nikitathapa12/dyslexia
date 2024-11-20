import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentViewPage extends StatefulWidget {
  @override
  _StudentViewPageState createState() => _StudentViewPageState();
}

class _StudentViewPageState extends State<StudentViewPage> {
  List<Map<String, dynamic>> _children = [];  // To store children data

  // Fetch children profiles along with their parents' email IDs
  Future<void> _fetchChildren() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? teacherUser = auth.currentUser;

    if (teacherUser == null) return;

    QuerySnapshot parentsSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .get(); // Fetch all parents

    List<Map<String, dynamic>> childrenData = [];

    // Loop through each parent and their children
    for (var parentDoc in parentsSnapshot.docs) {
      String parentEmail = parentDoc['email'] ?? 'No Email';

      QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentDoc.id)
          .collection('children')
          .get();  // Fetch all children for this parent

      for (var childDoc in childrenSnapshot.docs) {
        var childData = {
          'childId': childDoc.id,
          'username': childDoc['username'] ?? 'No Username',
          'parentEmail': parentEmail,
        };
        childrenData.add(childData);
      }
    }

    setState(() {
      _children = childrenData;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchChildren();  // Call fetch on init
  }

  // Show the progress of the selected child
  void _showChildProgress(String childId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? teacherUser = auth.currentUser;
    if (teacherUser == null) return;

    DocumentSnapshot childDoc = await FirebaseFirestore.instance
        .collection('parents')
        .doc(teacherUser.uid)
        .collection('children')
        .doc(childId)
        .get();

    if (childDoc.exists) {
      var childData = childDoc.data() as Map<String, dynamic>;
      int progress = childData['progress'] ?? 0;
      int timeSpent = childData['timeSpent'] ?? 0;
      List achievements = childData['achievements'] ?? [];

      // Show the progress in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Progress of ${childData['username']}'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress: $progress%'),
                Text('Time Spent: $timeSpent minutes'),
                Text('Achievements: ${achievements.join(', ')}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Students: ${_children.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _children.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _children.length,
                itemBuilder: (context, index) {
                  var child = _children[index];
                  String username = child['username'];
                  String parentEmail = child['parentEmail'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(username),
                      subtitle: Text('Parent Email: $parentEmail'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        _showChildProgress(child['childId']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

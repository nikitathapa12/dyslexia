import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentViewPage extends StatefulWidget {
  @override
  _StudentViewPageState createState() => _StudentViewPageState();
}

class _StudentViewPageState extends State<StudentViewPage> {
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = false;

  Future<void> _fetchChildren() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? teacherUser = auth.currentUser;

    if (teacherUser == null) return;

    try {
      QuerySnapshot parentsSnapshot =
      await FirebaseFirestore.instance.collection('parents').get();

      List<Map<String, dynamic>> childrenData = [];

      for (var parentDoc in parentsSnapshot.docs) {
        String parentEmail = parentDoc['email'] ?? 'No Email';

        QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
            .collection('parents')
            .doc(parentDoc.id)
            .collection('children')
            .get();

        for (var childDoc in childrenSnapshot.docs) {
          String childName = childDoc['name'] ?? 'No Username';

          var childData = {
            'childId': childDoc.id,
            'username': childName,
            'parentEmail': parentEmail,
            'parentId': parentDoc.id,
          };
          childrenData.add(childData);
        }
      }

      setState(() {
        _children = childrenData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _deleteChild(String parentId, String childId) async {
    try {
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .delete();

      setState(() {
        _children.removeWhere((child) => child['childId'] == childId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting child: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  void _navigateToProgressPage(String parentId, String childId, String childName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressPage(parentId: parentId, childId: childId, childName: childName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Students: ${_children.length}',
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
                    color: Colors.teal[50],
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        username,
                        style: TextStyle(
                          fontFamily: 'OpenDyslexic',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Parent Email: $parentEmail',
                        style: TextStyle(fontFamily: 'OpenDyslexic'),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteChild(
                                  child['parentId'], child['childId']);
                            },
                          ),
                          SizedBox(width: 4),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _navigateToProgressPage(
                                  child['parentId'],
                                  child['childId'],
                                  username);
                            },
                            child: Text(
                              'View',
                              style: TextStyle(
                                fontFamily: 'OpenDyslexic',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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


class ProgressPage extends StatefulWidget {
  final String parentId;
  final String childId;
  final String childName;

  ProgressPage({
    required this.parentId,
    required this.childId,
    required this.childName,
  });

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> _progressList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    try {
      final childRef = FirebaseFirestore.instance
          .collection('parents')
          .doc(widget.parentId)
          .collection('children')
          .doc(widget.childId);

      List<Map<String, dynamic>> progressList = [];

      // Fetch assignments
      final submissionsDocs = await childRef.collection('submissions').get();
      for (var doc in submissionsDocs.docs) {
        progressList.add({
          'category': 'Assignments',
          'assignmentType': doc.data()['assignmentType'] ?? 'No Type',
          'questionsAndAnswers': doc.data()['answers'] ?? {},
          'submittedAt': (doc.data()['submittedAt'] as Timestamp).toDate(),
        });
      }

      // Fetch games
      final gameCategories = [
        'Game Recognition',
        'Gift Matching',
        'Color Matching',
        'Letter Selection',
        'Word Game',
        'Cat Word Game',
        'Monkey Word Selection',
        'Cherry Counting',
        'Star Counting',
      ];

      for (String category in gameCategories) {
        final progressDocs = await childRef.collection(category).get();
        for (var doc in progressDocs.docs) {
          progressList.add({
            'category': 'Games',
            'gameCategory': category,
            'lastScore': doc.data()['lastScore'] ?? 0,
            'totalScore': doc.data()['totalScore'] ?? 0,
            'attempts': doc.data()['attempts'] ?? 0,
            'lastUpdated': (doc.data()['lastUpdated'] as Timestamp).toDate(),
          });
        }
      }

      setState(() {
        _progressList = progressList;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching progress data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showAssignmentDetails(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assignment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type: ${assignment['assignmentType']}"),
                SizedBox(height: 8),
                if (assignment['questionsAndAnswers'] != null)
                  ...assignment['questionsAndAnswers'].entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Q: ${entry.key}"),
                        Text("A: ${entry.value}"),
                        Divider(),
                      ],
                    );
                  }).toList(),
                Text(
                  "Submitted At: ${assignment['submittedAt']}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Report - ${widget.childName}"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _progressList.isEmpty
          ? Center(
        child: Text("No progress data available."),
      )
          : ListView.builder(
        itemCount: _progressList.length,
        itemBuilder: (context, index) {
          final progress = _progressList[index];
          if (progress['category'] == 'Assignments') {
            return Card(
              child: ListTile(
                leading: Icon(Icons.assignment),
                title: Text(
                    "Assignment: ${progress['assignmentType']}"),
                subtitle: Text(
                    "Submitted At: ${progress['submittedAt']}"),
                onTap: () => showAssignmentDetails(progress),
              ),
            );
          } else if (progress['category'] == 'Games') {
            return Card(
              child: ListTile(
                leading: Icon(Icons.videogame_asset),
                title: Text("Game: ${progress['gameCategory']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Last Score: ${progress['lastScore']}"),
                    Text("Total Score: ${progress['totalScore']}"),
                    Text("Attempts: ${progress['attempts']}"),
                    Text("Updated: ${progress['lastUpdated']}"),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}



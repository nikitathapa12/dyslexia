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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                        onPressed: () {
                          _navigateToProgressPage(child['parentId'], child['childId'], username);
                        },
                        child: Text(
                          'View Progress',
                          style: TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 14,
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

  ProgressPage({required this.parentId, required this.childId, required this.childName});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> _progressList = [];
  bool _isLoading = true;

  Future<void> _fetchProgressData() async {
    try {
      final childRef = FirebaseFirestore.instance
          .collection('parents')
          .doc(widget.parentId)
          .collection('children')
          .doc(widget.childId);

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

      List<Map<String, dynamic>> progressData = [];

      // Fetching progress for games
      for (String category in gameCategories) {
        final progressDocs = await childRef.collection(category).get();

        for (var doc in progressDocs.docs) {
          progressData.add({
            'category': 'Game',
            'gameCategory': category,
            'gameName': doc.id,
            'lastScore': doc.data()['lastScore'] ?? 0,
            'totalScore': doc.data()['totalScore'] ?? 0,
            'attempts': doc.data()['attempts'] ?? 0,
            'lastUpdated': (doc.data()['lastUpdated'] as Timestamp).toDate(),
          });
        }
      }

      // Fetching progress for assignments
      final submissionsDocs = await childRef.collection('submissions').get();
      for (var doc in submissionsDocs.docs) {
        final answerData = doc.data()['answer'] as String;
        final answerMap = _parseAnswerData(answerData);  // Parse answer data

        progressData.add({
          'category': 'Assignment',
          'assignmentId': doc.data()['assignmentId'],
          'answer': answerMap,
          'submittedAt': (doc.data()['submittedAt'] as Timestamp).toDate(),
        });
      }

      setState(() {
        _progressList = progressData;
      });
    } catch (e) {
      print('Error fetching progress data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to parse the answer string into assignment types and questions
  Map<String, String> _parseAnswerData(String answerData) {
    Map<String, String> parsedAnswer = {};
    final regex = RegExp(r'Assignment: "(.*?)" Question: "(.*?)"');
    final matches = regex.allMatches(answerData);

    for (final match in matches) {
      final assignmentType = match.group(1) ?? "Unknown Type";
      final question = match.group(2) ?? "No Question";
      parsedAnswer[assignmentType] = question;
    }

    return parsedAnswer;
  }



  @override
  void initState() {
    super.initState();
    _fetchProgressData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.childName}\'s Progress',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
        ),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _progressList.isEmpty
          ? Center(
        child: Text(
          'No progress data available',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
        ),
      )
          : ListView.builder(
        itemCount: _progressList.length,
        itemBuilder: (context, index) {
          var progress = _progressList[index];
          if (progress['category'] == 'Game') {
            // Rendering game progress
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  '${progress['gameCategory']} - ${progress['gameName']}',
                  style: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Last Score: ${progress['lastScore']}\nTotal Score: ${progress['totalScore']}\nAttempts: ${progress['attempts']}\nLast Updated: ${progress['lastUpdated']}',
                  style: TextStyle(fontFamily: 'OpenDyslexic',fontSize: 14),
                ),
              ),
            );
          } else if (progress['category'] == 'Assignment') {
            // Rendering assignment progress
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assignment ID: ${progress['assignmentId']}",
                      style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Assignment Types and Questions:",
                      style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', fontWeight: FontWeight.bold),
                    ),
                    ...progress['answer'].entries.map((entry) {
                      return Row(
                        children: [
                          Text("Type: ${entry.key}, Question: ${entry.value}", style: TextStyle(fontSize: 14)),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 8),
                    Text(
                      "Submitted At: ${progress['submittedAt']}",
                      style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

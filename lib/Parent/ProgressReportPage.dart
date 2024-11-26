import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressReportPage extends StatefulWidget {
  final String selectedChildName;  // The selected child's name

  ProgressReportPage({required this.selectedChildName});

  @override
  _ProgressReportPageState createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  late String parentId;
  late String childId;
  bool isLoading = true;
  List<Map<String, dynamic>> progressList = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      parentId = user.uid; // Set Parent ID
      fetchChildData();
    } else {
      print("User not logged in");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchChildData() async {
    print("fetchChildData function called");
    try {
      final parentDoc = await FirebaseFirestore.instance.collection('parents').doc(parentId).get();
      final childDocs = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)  // Use the selected child's name
          .get();

      if (childDocs.docs.isNotEmpty) {
        final childDoc = childDocs.docs.first;
        childId = childDoc.id;
        print("Child ID: $childId");
        await fetchProgressData();
      } else {
        print("No child found with name: ${widget.selectedChildName}");
      }
    } catch (e) {
      print("Error fetching child data: $e");
    }
  }

  Future<void> fetchProgressData() async {
    try {
      final childRef = FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId);

      // Fetch assignments data
      final submissionsDocs = await childRef.collection('submissions').get();
      for (var doc in submissionsDocs.docs) {
        final answerData = doc.data()['answer'] as String;
        final answerMap = parseAnswerData(answerData); // Parse the answer data

        // Add to the progress list under 'Assignments' category
        progressList.add({
          'category': 'Assignments', // Category for assignment
          'assignmentId': doc.data()['assignmentId'], // Directly add assignment ID
          'answer': answerMap, // Assignment type questions
          'submittedAt': (doc.data()['submittedAt'] as Timestamp).toDate(), // Submission timestamp
        });
      }

      // Fetch games data (assuming you have a games collection or category)
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
            'category': 'Games', // Category for games
            'gameCategory': category, // Game category name
            // 'gameName': doc.id, // Game name (ID)
            'lastScore': doc.data()['lastScore'] ?? 0,
            'totalScore': doc.data()['totalScore'] ?? 0,
            'attempts': doc.data()['attempts'] ?? 0,
            'lastUpdated': (doc.data()['lastUpdated'] as Timestamp).toDate(),
          });
        }
      }
    } catch (e) {
      print("Error fetching progress data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Helper function to parse the answer string into assignment types and questions
  Map<String, String> parseAnswerData(String answerData) {
    Map<String, String> parsedAnswer = {};
    final regex = RegExp(r'Assignment: "(.*?)" Question: "(.*?)"');  // Adjusted to find assignment types and questions
    final matches = regex.allMatches(answerData);

    for (final match in matches) {
      final assignmentType = match.group(1) ?? "Unknown Type";
      final question = match.group(2) ?? "No Question";
      parsedAnswer[assignmentType] = question;
    }

    return parsedAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Progress Report - ${widget.selectedChildName}",
          style: TextStyle(fontFamily: 'OpenDyslexic'),
        ),
        backgroundColor: Colors.teal, // Soothing color for app bar
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : progressList.isEmpty
          ? Center(
        child: Text(
          "No progress data available.",
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'OpenDyslexic',
            color: Colors.grey[700],
          ),
        ),
      )
          : ListView.builder(
        itemCount: progressList.length,
        itemBuilder: (context, index) {
          final progress = progressList[index];

          // Card for Assignments
          if (progress['category'] == 'Assignments') {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Assignment Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenDyslexic',
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "Assignment ID: ${progress['assignmentId']}",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Questions and Answers:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    ...progress['answer'].entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.question_answer,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Type: ${entry.key}, Question: ${entry.value}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'OpenDyslexic',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 8),
                    Text(
                      "Submitted At: ${progress['submittedAt']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Card for Games
          if (progress['category'] == 'Games') {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videogame_asset, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Game Progress",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenDyslexic',
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "Game Category: ${progress['gameCategory']}",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Game Name: ${progress['gameName']}",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          "Last Score: ${progress['lastScore']}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'OpenDyslexic',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.leaderboard, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Total Score: ${progress['totalScore']}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'OpenDyslexic',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Attempts: ${progress['attempts']}",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Last Updated: ${progress['lastUpdated']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
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

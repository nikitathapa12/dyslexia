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
            'gameName': doc.id, // Game name (ID)
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
        title: Text("Progress Report - ${widget.selectedChildName}"),  // Show the selected child's name
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : progressList.isEmpty
          ? Center(child: Text("No progress data available."))
          : ListView.builder(
        itemCount: progressList.length,
        itemBuilder: (context, index) {
          final progress = progressList[index];

          // Check if it's from Games or Assignments category
          if (progress['category'] == 'Assignments') {
            return Card(
              margin: EdgeInsets.all(8),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assignment ID: ${progress['assignmentId']}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Display assignment type questions
                    Text("Assignment Types and Questions:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          } else if (progress['category'] == 'Games') {
            return Card(
              margin: EdgeInsets.all(8),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Game Category: ${progress['gameCategory']}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Game Name: ${progress['gameName']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Last Score: ${progress['lastScore']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Score: ${progress['totalScore']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Attempts: ${progress['attempts']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Last Updated: ${progress['lastUpdated']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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

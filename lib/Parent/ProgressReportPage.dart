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
      // final documents = await FirebaseFirestore.instance.collection('parents').get();
      // print("documents: ");
      // for (var doc in documents.docs) {
      //   print(doc.id); // Access the document ID
      // }
      //
      // print("parentDocs: ");
      // print(parentDoc.id); // Access the document ID
      //
      // print("doc exists: " + parentDoc.exists.toString());
      // if (parentDoc.exists) {
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
          print("child lists fetched");
          print(childDocs);
          print("alert: No child found with name: ${widget.selectedChildName}");
        }
      // }
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
            'gameCategory': category,
            'gameName': doc.id,
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
          return Card(
            margin: EdgeInsets.all(8),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category: ${progress['gameCategory']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Game: ${progress['gameName']}",
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
        },
      ),
    );
  }
}
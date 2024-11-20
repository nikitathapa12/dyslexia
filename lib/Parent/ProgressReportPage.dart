import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressReportPage extends StatelessWidget {
  final String childId;

  ProgressReportPage({required this.childId});

  Future<List<Map<String, dynamic>>> fetchGameData() async {
    return await FirebaseFirestore.instance
        .collection('games')
        .where('childId', isEqualTo: childId)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<List<Map<String, dynamic>>> fetchAssignmentData() async {
    return await FirebaseFirestore.instance
        .collection('submissions')
        .where('childId', isEqualTo: childId)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress Report')),
      body: FutureBuilder(
        future: Future.wait([fetchGameData(), fetchAssignmentData()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final gameData = snapshot.data![0] as List<Map<String, dynamic>>;
            final assignmentData = snapshot.data![1] as List<Map<String, dynamic>>;

            return ListView(
              children: [
                Text('Games:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...gameData.map((game) => ListTile(
                  title: Text(game['gameName']),
                  subtitle: Text('Score: ${game['score']}'),
                  trailing: Text('Played At: ${game['playedAt'].toDate()}'),
                )),
                SizedBox(height: 20),
                Text('Assignments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...assignmentData.map((assignment) => ListTile(
                  title: Text(assignment['assignmentName']),
                  subtitle: Text('Score: ${assignment['score']}'),
                  trailing: Text('Submitted At: ${assignment['submissionDate'].toDate()}'),
                )),
              ],
            );
          }
        },
      ),
    );
  }
}

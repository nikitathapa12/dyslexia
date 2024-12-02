import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            return ListTile(
              title: Text(task['title']),
              subtitle: Text(task['description']),
            );
          },
        );
      },
    );
  }
}

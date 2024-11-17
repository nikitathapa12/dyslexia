import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskAssignmentPage extends StatefulWidget {
  @override
  _TaskAssignmentPageState createState() => _TaskAssignmentPageState();
}

class _TaskAssignmentPageState extends State<TaskAssignmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _taskTitle = '';
  String _taskDescription = '';

  Future<void> _assignTask(String userId) async {
    await _firestore.collection('tasks').add({
      'title': _taskTitle,
      'description': _taskDescription,
      'dueDate': DateTime.now().add(Duration(days: 7)), // Example due date
      'isCompleted': false,
      'userId': userId, // Child's user ID
    });

    // Clear input fields
    setState(() {
      _taskTitle = '';
      _taskDescription = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task assigned successfully!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final String userId = 'child_user_id'; // Replace with the actual user ID

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Task Title'),
              onChanged: (value) {
                setState(() {
                  _taskTitle = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Task Description'),
              onChanged: (value) {
                setState(() {
                  _taskDescription = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _assignTask(userId),
              child: Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }
}

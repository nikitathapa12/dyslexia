import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:date_format/date_format.dart'; // Using date_format package

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Stream<List<AssignmentModel>> assignmentsStream;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenForNewAssignments();
    assignmentsStream = _firestore
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AssignmentModel.fromFirestore(doc)).toList();
    });
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
          // Navigate to a details page or perform another action
        }
      },
    );
  }

  void _listenForNewAssignments() {
    _firestore
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newAssignment = AssignmentModel.fromFirestore(change.doc);
          _showLocalNotification(newAssignment);
        }
      }
    });
  }

  Future<void> _showLocalNotification(AssignmentModel assignment) async {
    const androidDetails = AndroidNotificationDetails(
      'assignment_channel', // Channel ID
      'Assignments', // Channel Name
      channelDescription: 'Notifications for new assignments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      assignment.id.hashCode, // Unique ID for the notification
      'New Assignment: ${assignment.title}', // Notification title
      assignment.description, // Notification body
      notificationDetails,
      payload: assignment.id, // Pass assignment ID as payload
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: Colors.teal.shade50,
      body: StreamBuilder<List<AssignmentModel>>(
        stream: assignmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No new assignments.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final assignments = snapshot.data!;
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: Colors.teal.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Type: ${assignment.assignmentType}',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Question: ${assignment.question}',
                        style: TextStyle(fontSize: 16, color: Colors.teal.shade800),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${assignment.description}',
                        style: TextStyle(fontSize: 14, color: Colors.teal.shade600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Created At: ${_formatDate(assignment.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.teal.shade500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return formatDate(
      dateTime,
      [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ' ', am],
    );
  }
}

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String assignmentType;
  final String question;
  final Timestamp createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignmentType,
    required this.question,
    required this.createdAt,
  });

  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    return AssignmentModel(
      id: doc.id,
      title: doc['title'] ?? 'Untitled',
      description: doc['description'] ?? 'No description available.',
      assignmentType: doc['assignmentType'] ?? 'General',
      question: doc['question'] ?? 'No question provided.',
      createdAt: doc['createdAt'] ?? Timestamp.now(),
    );
  }
}

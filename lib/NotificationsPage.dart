import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<NotificationModel>> notificationsStream;

  @override
  void initState() {
    super.initState();
    notificationsStream = _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No new notifications.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: Icon(notification.read ? Icons.check : Icons.markunread),
                onTap: () {
                  // Mark the notification as read
                  _firestore.collection('notifications').doc(notification.id).update({
                    'read': true,
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    return NotificationModel(
      id: doc.id,
      title: doc['title'],
      message: doc['message'],
      read: doc['read'],
    );
  }
}

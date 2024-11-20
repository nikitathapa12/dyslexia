import 'package:dyslearn/Parent/FeedbackPage.dart';
import 'package:dyslearn/Parent/ParentLoginPage.dart';
import 'package:dyslearn/Parent/ProgressReportPage.dart';
import 'package:dyslearn/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import is present
import 'package:dyslearn/AssignmentPage.dart';
import 'package:dyslearn/games.dart';

class MenuPage extends StatefulWidget {
  final String selectedChildName; // Added field to store the selected child's name

  MenuPage({Key? key, required this.selectedChildName}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _userEmail = ''; // Initially empty, to be filled after fetching from Firebase

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // Method to fetch user email from Firebase
  Future<void> _loadUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'No email available';
      });
    }
  }

  // Method to logout the user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _userEmail = ''; // Clear user email after logout
    });
    // Navigate directly to login page after logging out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ParentLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 24),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount =
              snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      _showNotificationDialog(context);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.teal[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 50, color: Colors.white),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'OpenDyslexic',
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _userEmail,  // Displaying the user email below the welcome text
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'OpenDyslexic',
                          ),
                          overflow: TextOverflow.ellipsis, // This will ensure long email doesn't overflow
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Child: ${widget.selectedChildName}',  // Display selected child's name
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'OpenDyslexic',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            title: 'View Progress',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressReportPage(childId: '',),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            title: 'Child Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildProfilePage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            title: 'Send Feedback to Teachers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackPage(),
                ),
              );
            },
          ),
          Divider(),
          // Login/Signup or Logout button
          _buildDrawerItem(
            context: context,
            title: _userEmail.isEmpty ? 'Login/Signup' : 'Logout',
            onTap: () {
              if (_userEmail.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentLoginPage(),
                  ),
                );
              } else {
                _logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueGrey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnimatedCard(
              context: context,
              icon: Icons.videogame_asset_rounded,
              title: 'Games',
              subtitle: 'Play educational games',
              color: Colors.teal.shade900,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamesPage()),
                );
              },
            ),
            SizedBox(height: 30),
            _buildAnimatedCard(
              context: context,
              icon: Icons.assignment,
              title: 'Assignments',
              subtitle: 'View your assignments',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentsPage(
                      parentId: '',
                      childId: '',
                      childUsername: '',
                      parentEmail: '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    // Notification dialog logic
  }

  Widget _buildAnimatedCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Icon(icon, size: 60, color: Colors.white),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'OpenDyslexic',
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 30, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}

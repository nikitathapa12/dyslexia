import 'package:dyslearn/user/edit_child_profile.dart';
import 'package:dyslearn/notifications_page.dart';
import 'package:dyslearn/Parent/feedback_page.dart';
import 'package:dyslearn/Parent/parent_login_page.dart';
import 'package:dyslearn/Parent/progress_report_page.dart';
import 'package:dyslearn/home_page.dart';
import 'package:dyslearn/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslearn/User/assignment_page.dart';
import 'package:dyslearn/games.dart';

class MenuPage extends StatefulWidget {
  final String selectedChildName;

  MenuPage({Key? key, required this.selectedChildName}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _userEmail = '';
  String _parentId = '';
  Map<String, dynamic> childData = {};

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'No email available';
        _parentId = user.uid;
      });
    }
  }

  Future<void> _loadChildData() async {
    await _loadUserEmail();
    if (widget.selectedChildName.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('parents')
            .doc(_parentId)
            .collection('children')
            .where('name', isEqualTo: widget.selectedChildName)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            childData = querySnapshot.docs.first.data();
          });
        } else {
          print('No child found with name: ${widget.selectedChildName}');
        }
      } catch (e) {
        print('Error loading child data: $e');
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _userEmail = ''; // Clear email to indicate logout
    });

    // Show a snackbar or dialog to indicate successful logout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully'),
        duration: Duration(seconds: 2),
      ),
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
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
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
                    Expanded( // Ensures text doesn't overflow
                      child: Column(
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
                            _userEmail.isEmpty
                                ? 'Please login/signup'
                                : _userEmail,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'OpenDyslexic',
                            ),
                            overflow: TextOverflow.ellipsis, // Prevents overflow
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Child: ${widget.selectedChildName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'OpenDyslexic',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          if (!_userEmail.isEmpty) ...[
            _buildDrawerItem(
              context: context,
              title: 'View Progress',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressReportPage(
                      selectedChildName: widget.selectedChildName,
                    ),
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
                  MaterialPageRoute(builder: (context) => ChildProfilePage()),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              title: 'Send Feedback to Teachers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              },
            ),
          ] else
            _buildDrawerItem(
              context: context,
              title: 'Login/Signup',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParentLoginPage()),
                );
              },
            ),
          Divider(),
          if (!_userEmail.isEmpty)
            _buildDrawerItem(
              context: context,
              title: 'Logout',
              onTap: _logout,
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
                  MaterialPageRoute(
                      builder: (context) => GamesPage(
                          selectedChildName: widget.selectedChildName)),

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
                      selectedChildName: widget.selectedChildName,
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

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontFamily: 'OpenDyslexic'),
      ),
      onTap: onTap,
    );
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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

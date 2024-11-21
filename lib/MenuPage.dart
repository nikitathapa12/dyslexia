import 'package:dyslearn/EditChildProfile.dart';
import 'package:dyslearn/NotificationsPage.dart';
import 'package:dyslearn/Parent/FeedbackPage.dart';
import 'package:dyslearn/Parent/ParentLoginPage.dart';
import 'package:dyslearn/Parent/ProgressReportPage.dart';
import 'package:dyslearn/home_page.dart';
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
  String _userEmail = '';
  Map<String, dynamic> childData = {}; // To store child data fetched from Firestore

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadChildData();
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

  // Method to fetch child data from Firestore based on selectedChildName
  Future<void> _loadChildData() async {
    try {
      if (widget.selectedChildName.isEmpty) {
        throw Exception("Child name is empty");
      }

      var querySnapshot = await FirebaseFirestore.instance
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
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(), // Navigate to your NotificationsPage
                ),
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
                MaterialPageRoute(
                  builder: (context) => ChildProfilePage(),
                ),
              );
            },
          ),

          // _buildDrawerItem(
          //   context: context,
          //   title: 'Edit Profile',
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => EditChildProfile(childName: '',),
          //       ),
          //     );
          //   },
          // ),
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
                print('Navigating with: parentId=${childData['parentId']}, childId=${childData['childId']}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentsPage(
                      parentId: childData['parentId'] ?? '',
                      childId: childData['childId'] ?? '',
                      childUsername: widget.selectedChildName,
                      parentEmail: _userEmail,
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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 60,
                  ),
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
                    textAlign: TextAlign.center,
                  ),
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
        style: TextStyle(fontSize: 18, fontFamily: 'OpenDyslexic'),
      ),
      onTap: onTap,
    );
  }
}

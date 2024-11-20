import 'package:dyslearn/Teacher/AddTaskPage.dart';
import 'package:dyslearn/Teacher/Addassignmentpage.dart';
import 'package:dyslearn/Teacher/ProfilePage.dart';
import 'package:dyslearn/Teacher/TeacherFeedbackPage.dart';
import 'package:dyslearn/Teacher/ViewStudents.dart';
import 'package:dyslearn/Teacher/WelcomePage.dart';
import 'package:dyslearn/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [

    TeacherWelcomePage(), // Welcome page
    TeacherAddAssignmentPage(), // Add Assignment
    StudentViewPage(), // View Students
    ProfilePage(), // Teacher Profile
    TeacherFeedbackPage(), // View Feedback
    LoginPage(),
  ];

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Dashboard',
          style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 24),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[700]!, Colors.teal[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[500]!, Colors.teal[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Teacher Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'OpenDyslexic',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Welcome',
                icon: Icons.home,
                index: 0,
              ),
              _buildDrawerItem(
                context: context,
                title: 'Add Assignment',
                icon: Icons.assignment,
                index: 1,
              ),
              _buildDrawerItem(
                context: context,
                title: 'View Students',
                icon: Icons.people,
                index: 2,
              ),
              _buildDrawerItem(
                context: context,
                title: 'Your Profile',
                icon: Icons.person,
                index: 3,
              ),
              _buildDrawerItem(
                context: context,
                title: 'Feedback',
                icon: Icons.feedback,
                index: 4,
              ),
              _buildDrawerItem(
                context: context,
                title: 'Logout',
                icon: Icons.logout,
                index: -1, // Logout
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int index,
  }) {
    return ListTile(
      tileColor: _selectedIndex == index ? Colors.teal[100] : Colors.transparent,
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Colors.teal[900] : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'OpenDyslexic',
          fontSize: 18,
          color: _selectedIndex == index ? Colors.teal[900] : Colors.white,
        ),
      ),
      onTap: () {
        if (index == -1) {
          // Handle Logout
          Navigator.pop(context); // Close the drawer
        } else {
          _onDrawerItemTap(index);
        }
      },
    );
  }
}
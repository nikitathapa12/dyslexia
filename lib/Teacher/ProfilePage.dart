import 'package:dyslearn/Parent/SettingPage.dart';
import 'package:dyslearn/Teacher/ChangePasswordPage.dart';
import 'package:dyslearn/Teacher/EditProfilePage.dart';
import 'package:dyslearn/home_page.dart';
import 'package:dyslearn/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Section (Subtle gradient overlay effect)
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade200, Colors.green.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Profile Info Title with gradient shadow
                Text(
                  'Welcome, ${user?.displayName ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'OpenDyslexic',
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.4), offset: Offset(1, 1), blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    fontFamily: 'OpenDyslexic',
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(1, 1), blurRadius: 3),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // User Info Section
                if (user != null)
                  Column(
                    children: [
                      _buildInfoTile('Name:', user.displayName ?? 'No Name'),
                      _buildInfoTile('Email:', user.email ?? 'No Email'),
                    ],
                  )
                else
                  Text(
                    'No user logged in',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                SizedBox(height: 20),

                // Navigation Buttons with Icons
                _buildNavigationButton(
                  context,
                  'Edit Profile',
                  Icons.edit, // Edit icon
                  Colors.blueGrey.shade200, // Light blue for action
                  EditProfilePage(),
                ),
                SizedBox(height: 12),
                _buildNavigationButton(
                  context,
                  'Change Password',
                  Icons.lock, // Lock icon
                  Colors.blueGrey.shade200, // Warm orange for caution
                  ChangePasswordPage(),
                ),
                SizedBox(height: 12),
                _buildNavigationButton(
                  context,
                  'Settings',
                  Icons.settings, // Settings icon
                  Colors.blueGrey.shade200, // Cool blue-grey for settings
                  SettingsPage(),
                ),
                SizedBox(height: 30),

                // Logout Button with Icon
                _buildNavigationButton(
                  context,
                  'Logout',
                  Icons.exit_to_app, // Logout icon
                  Colors.redAccent.shade200, // Bold red for logout
                  LoginPage(),
                  isLogout: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to create Info Tiles with subtle styling
  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create stylish navigation buttons with gradient effect and icons
  Widget _buildNavigationButton(BuildContext context, String label, IconData icon, Color color, Widget destinationPage, {bool isLogout = false}) {
    return ElevatedButton(
      onPressed: () {
        if (isLogout) {
          // Sign out the user from Firebase
          FirebaseAuth.instance.signOut();

          // Navigate to LoginPage (home or login page)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // LoginPage
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(label),
        ],
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 60),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),  // Slightly rounded for a smooth feel
        ),
        elevation: 6.0,
        shadowColor: Colors.black.withOpacity(0.2),
        side: BorderSide(color: Colors.black26, width: 0.5),  // Subtle border effect
      ),
    );
  }

}

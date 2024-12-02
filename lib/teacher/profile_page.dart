import 'package:dyslearn/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.green.shade200],
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
                // Profile Picture Section with Glow Effect
                Container(
                  margin: EdgeInsets.only(top: 40),
                  width: 160,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade300, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : AssetImage('assets/images/img.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Profile Welcome Text
                Text(
                  'Hello, ${user?.displayName ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenDyslexic',
                    color: Colors.teal.shade900,
                    shadows: [
                      Shadow(color: Colors.teal.shade700, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome to your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal.shade700,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
                SizedBox(height: 40),

                // Profile Information
                if (user != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile('Name:', user.displayName ?? 'No Name'),
                      _buildInfoTile('Email:', user.email ?? 'No Email'),
                    ],
                  )
                else
                  Text(
                    'No user logged in',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontFamily: 'OpenDyslexic'),
                  ),
                SizedBox(height: 40),

                // Navigation Buttons
                _buildNavigationButton(
                  context,
                  'Edit Profile',
                  Icons.edit,
                  Colors.teal.shade900,
                  EditProfilePage(),
                ),
                SizedBox(height: 40),
                _buildNavigationButton(
                  context,
                  'Change Password',
                  Icons.lock,
                  Colors.teal.shade900,
                  ChangePasswordPage(),
                ),
                SizedBox(height: 40),
                _buildNavigationButton(
                  context,
                  'Logout',
                  Icons.exit_to_app,
                  Colors.redAccent,
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

  // Helper widget for displaying profile information
  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.teal.shade700),
          SizedBox(width: 10),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
              fontFamily: 'OpenDyslexic',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'OpenDyslexic',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for navigation buttons
  Widget _buildNavigationButton(BuildContext context, String label, IconData icon, Color color, Widget destinationPage, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenDyslexic',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

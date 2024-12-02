import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class TeacherWelcomePage extends StatefulWidget {
  @override
  _TeacherWelcomePageState createState() => _TeacherWelcomePageState();
}

class _TeacherWelcomePageState extends State<TeacherWelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..forward();
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homepge.gif'), // Background image
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.6), // Soft overlay for better visibility
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              FadeTransition(
                opacity: _opacity, // Animation for fade-in effect
                child: Column(
                  children: [
                    Text(
                      'Welcome to Teacher Dashboard',
                      style: TextStyle(
                        fontSize: 32, // Increased font size for better visibility
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50), // Soft blue color for text
                        fontFamily: 'OpenDyslexic', // Dyslexic-friendly font
                        letterSpacing: 2.0, // Slight letter spacing to improve readability
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0), // Shadow for text to improve contrast
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20), // Space between the title and the button
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Navigate to the teacher dashboard or another page
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Color(0xFF3498DB), // Blue background for the button
                    //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    //     ),
                    //   ),
                    //   child: Text(
                    //     'Go to Dashboard',
                    //     style: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

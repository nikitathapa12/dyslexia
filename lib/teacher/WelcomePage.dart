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
            image: AssetImage('assets/images/homepge.gif'), // Add your background image here
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.6), // To overlay a soft color over the image, improving text visibility
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10), // Add a small space above the text to move it upwards
              FadeTransition(
                opacity: _opacity, // Apply the animation here
                child: Text(
                  'Welcome to Teacher Dashboard',
                  style: TextStyle(

                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50), // Soft blue color for text, more readable for dyslexic users
                    fontFamily: 'OpenDyslexic', // Ensure dyslexic-friendly font
                  ),
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

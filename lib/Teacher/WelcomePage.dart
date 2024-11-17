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
      // appBar: AppBar(
      //   title: Text(
      //     'Welcome to Teacher Dashboard',
      //     style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 24),
      //   ),
      //   backgroundColor: Colors.teal,
      //   elevation: 0,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.teal[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacity, // Apply the animation here
            child: Text(
              'Welcome to Teacher Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
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

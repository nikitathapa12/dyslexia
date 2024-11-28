import 'package:dyslearn/AboutPage.dart';
import 'package:flutter/material.dart';
import 'package:dyslearn/MenuPage.dart';
import 'package:dyslearn/Teacher/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _boardSlideAnimation;

  double _boardPosition = 30.0; // Start at the rope's position
  double _ropePosition = 64.0; // Initial position of the rope
  bool _isBoardVisible = false;

  // Define the board height and slide distance
  final double _boardHeight = 200.0; // Height of the board
  final double _slideDownDistance = 10.0; // Distance to slide down (adjust as needed)

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Duration of the slide animation
    );

    // Animation for sliding the blackboard down
    _boardSlideAnimation = Tween<double>(begin: _ropePosition, end: _ropePosition + _slideDownDistance).animate(_controller)
      ..addListener(() {
        setState(() {
          _boardPosition = _boardSlideAnimation.value; // Update position based on animation
        });
      });
  }

  void _toggleBoard() {
    if (_isBoardVisible) {
      // Pulling the rope up: move the board back up
      _controller.reverse().then((_) {
        setState(() {
          _isBoardVisible = false; // Update visibility state after animation
          _ropePosition = 60.0; // Reset rope position to original
        });
      });
    } else {
      // Pulling the rope down: move the board down
      _controller.forward();
      setState(() {
        _isBoardVisible = true; // Set visibility state before starting the animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.png'), // Replace with your actual background
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Rope in the top right corner
          Positioned(
            top: _ropePosition, // Adjust rope position
            right: -100,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < 0 && !_isBoardVisible) {
                  _toggleBoard(); // Pulling the rope down
                } else if (details.primaryDelta! > 0 && _isBoardVisible) {
                  _toggleBoard(); // Pulling the rope up
                }
              },
              child: Image.asset(
                'assets/images/rope.png', // Replace with a rope image
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blackboard that moves with the rope
          Positioned(
            top: _boardPosition, // Moves the blackboard up and down
            left: 10,
            child: Opacity(
              opacity: _isBoardVisible ? 1.0 : 0.0, // Show the board only when it is down
              child: Container(
                width: 300,
                height: _boardHeight, // Set the height dynamically
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/board.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Teacher\'s Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenDyslexic',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'OpenDyslexic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // App logo in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_logo.png', // Replace with your app logo or title
                  width: 300,
                ),
                SizedBox(height: 20),
                // Play button below the app logo
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(selectedChildName: '',)), // Navigate to MenuPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Play', style: TextStyle(fontSize: 24, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Google Play and Settings buttons
          Positioned(
            bottom: 5, // Adjusted to allow space for the Play button
            left: 10,
            child: IconButton(
              onPressed: () {
                // Open Google Play
              },
              icon: Image.asset(
                'assets/images/google-play-games.png', // Add the Google Play icon
                width: 50,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 20,
            child: IconButton(
                onPressed: () {
                  // Navigate to AboutPage when settings button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()), // Navigate to AboutPage
                  );
                },
                icon: Icon(Icons.settings, size: 50, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

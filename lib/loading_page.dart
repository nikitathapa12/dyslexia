import 'package:dyslearn/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class GameLoadingScreen extends StatefulWidget {
  @override
  _GameLoadingScreenState createState() => _GameLoadingScreenState();
}

class _GameLoadingScreenState extends State<GameLoadingScreen>
    with TickerProviderStateMixin {
  double _progressValue = 0.0; // Initial progress value
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _progressFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the fade-in animation for the logo
    _logoAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _logoFadeAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeIn,
    );

    // Set up the fade-in animation for the progress bar
    _progressAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _progressFadeAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeIn,
    );

    _logoAnimationController.forward(); // Start the logo animation
    Future.delayed(Duration(milliseconds: 500), () {
      _progressAnimationController.forward(); // Delay and start the progress bar animation
    });

    // Simulate loading progress
    _simulateLoading();

    // After 3 seconds, navigate to your desired page
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace with your target page
      );
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  // Function to simulate loading progress
  void _simulateLoading() {
    Timer.periodic(Duration(milliseconds: 300), (Timer timer) {
      setState(() {
        if (_progressValue >= 1.0) {
          timer.cancel(); // Stop the timer once progress is complete
        } else {
          _progressValue += 0.1; // Increment progress
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (You can uncomment and use your background image)
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/game_background.png'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
         //logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Game Logo
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Image.asset(
                    'assets/images/app_logo.png', // Your game logo
                    width: 400, // Adjust logo size
                    height: 300,
                  ),
                ),
                SizedBox(height: 30), // Spacing between logo and loading indicator
                // Loading text with fade transition
                FadeTransition(
                  opacity: _progressFadeAnimation,
                  child: Column(
                    children: [
                      // Progress bar with percentage
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Linear Progress Indicator (Progress Bar)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), // Rounded edges
                                  color: Colors.white.withOpacity(0.3), // Background color of the progress bar
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20), // Rounded edges for the progress
                                  child: LinearProgressIndicator(
                                    value: _progressValue, // Set progress value
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                    minHeight: 10, // Height of the progress bar
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15), // Spacing between progress bar and percentage
                            // Animated percentage text
                            Text(
                              '${(_progressValue * 100).toInt()}%', // Convert progress to percentage
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Caveat',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Loading text
                      Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

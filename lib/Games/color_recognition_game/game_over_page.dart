import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final VoidCallback onPlayAgain;
  final VoidCallback onNextGame;

  const GameOverScreen({
    required this.score,
    required this.onPlayAgain,
    required this.onNextGame,
  });

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> with TickerProviderStateMixin {
  late AnimationController _starController;
  late Animation<double> _star1, _star2, _star3;

  @override
  void initState() {
    super.initState();
    // Initialize the star animation controller
    _starController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation timings for each star
    _star1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starController, curve: Interval(0.0, 0.33)),
    );
    _star2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starController, curve: Interval(0.33, 0.66)),
    );
    _star3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starController, curve: Interval(0.66, 1.0)),
    );

    // Start the animation
    _starController.forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  Widget _buildStar(Animation<double> animation, int starIndex) {
    return ScaleTransition(
      scale: animation,
      child: Icon(
        Icons.star,
        color: widget.score >= starIndex ? Colors.yellow : Colors.grey,
        size: 80,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.png'), // Fun background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Badge or Character
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/cartoon.gif', // Cute character
                    width: 200,
                    height: 180,
                  ),
                ),
                SizedBox(height: 30),

                // Animated Stars based on Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStar(_star1, 1),
                    SizedBox(width: 10),
                    _buildStar(_star2, 2),
                    SizedBox(width: 10),
                    _buildStar(_star3, 3),
                  ],
                ),
                SizedBox(height: 30),

                // Score Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Score',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenDyslexic',
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${widget.score}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Play Again & Next Game Buttons (Image Buttons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play Again Button
                    GestureDetector(
                      onTap: widget.onPlayAgain,
                      child: Image.asset(
                        'assets/images/reload_button.png', // Replace with your play again image button
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(width: 20),
                    // Next Game Button
                    GestureDetector(
                      onTap: widget.onNextGame,
                      child: Image.asset(
                        'assets/images/next.gif', // Replace with your next game image button
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

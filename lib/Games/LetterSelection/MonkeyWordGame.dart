import 'package:dyslearn/Games/LetterSelection/BallWordGame.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MonkeyWordGame extends StatefulWidget {
  @override
  _MonkeyWordGameState createState() => _MonkeyWordGameState();
}

class _MonkeyWordGameState extends State<MonkeyWordGame> with SingleTickerProviderStateMixin {
  final String word = "MONKEY"; // The new word to fill
  List<String> letters = ['Y', 'N', 'E', 'M', 'O', 'K']; // Letters to drag
  late List<String?> filledLetters; // Track filled letters
  late AnimationController _controller;
  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer(); // Background music player

  int score = 0;
  int lastScore = 0;

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null); // Initialize filled letters
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _playBackgroundMusic(); // Start background music
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    _audioPlayer.dispose(); // Dispose of audio player for sound effects
    _backgroundMusicPlayer.stop(); // Stop background music
    _backgroundMusicPlayer.dispose(); // Dispose background music player
    super.dispose();
  }

  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'), volume: 0.5);
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop); // Loop the background music
  }

  // Play letter sound (phonics) or word sound
  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3')); // Play sound from assets
  }

  // Handle the drop event
  void _onLetterDropped(String letter, int index) {
    setState(() {
      filledLetters[index] = letter; // Fill the letter in the word
      letters.remove(letter); // Remove the letter from the pool
      score += 0; // Increase score

      // Play phonics sound for the dropped letter
      _playSound(letter.toLowerCase());

      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward(); // Start waving animation

        // Wait for the last phonics sound to finish before playing "monkey" and navigating
        Future.delayed(Duration(seconds: 1), () {
          _playSound('monkey'); // Play the "monkey" sound after a short delay

          // Update scores
          setState(() {
            lastScore = score;
            score += 1; // Increase score by 10 points when word is completed
          });

          // Navigate to the ball game after a short delay
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BallWordGame()));
          });
        });
      }
    });
  }

  // Check if the word is completed
  bool _isWordCompleted() {
    return !filledLetters.contains(null);
  }

  // Use hint functionality: Automatically place one correct letter
  void _useHint() {
    for (int i = 0; i < word.length; i++) {
      if (filledLetters[i] == null) {
        String correctLetter = word[i];
        if (letters.contains(correctLetter)) {
          _onLetterDropped(correctLetter, i);
          break; // Use only one hint at a time
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // Background container (GIF can be used here)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/monkey-7751_512.gif"), // GIF as background
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scoreboard and hint row
          Positioned(
            top: 50,
            left: 0,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scoreboard displaying score and last score
                  Column(
                    children: [
                      Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  // Hint icon
                  IconButton(
                    icon: Icon(Icons.lightbulb, color: Colors.yellow), // Hint icon
                    onPressed: _useHint, // Use hint when clicked
                  ),
                ],
              ),
            ),
          ),
          // Main game content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the word with hints and completion icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(word.length, (index) {
                    return DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: filledLetters[index] != null ? Colors.lightGreen : Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              filledLetters[index] ?? word[index], // Show hint if empty
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                      onWillAccept: (data) => data == word[index], // Only accept if letter matches
                      onAccept: (data) => _onLetterDropped(data, index), // Handle letter drop
                    );
                  }),
                ],
              ),
              SizedBox(height: 20),
              // Display draggable letters
              Wrap(
                spacing: 10,
                children: letters.map((letter) {
                  return Draggable<String>(
                    data: letter,
                    child: _buildLetterWidget(letter),
                    feedback: _buildLetterWidget(letter, isFeedback: true),
                    childWhenDragging: _buildLetterWidget(letter, isFeedback: true), // Placeholder while dragging
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              // Display waving icons if the word is completed
              if (_isCompleted) _buildWavingIcons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterWidget(String letter, {bool isFeedback = false}) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFeedback ? Colors.blue : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildWavingIcons() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tag_faces, size: 50, color: Colors.green), // Waving icon
          SizedBox(width: 10),
          Text(
            "MONKEY!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.green), // Waving icon
        ],
      ),
    );
  }
}

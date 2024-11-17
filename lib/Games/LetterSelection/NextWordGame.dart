import 'package:dyslearn/Games/LetterSelection/CatWordGame.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NextWordGame extends StatefulWidget {
  @override
  _NextWordGameState createState() => _NextWordGameState();
}

class _NextWordGameState extends State<NextWordGame> with SingleTickerProviderStateMixin {
  final String word = "WORLD"; // The word to fill
  List<String> letters = ['R', 'O', 'W', 'D', 'L']; // Letters to drag
  late List<String?> filledLetters; // Track filled letters
  late AnimationController _controller;
  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  int score = 0; // Track score
  int lastScore = 0; // Last game score

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null); // Initialize filled letters
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _playBackgroundMusic(); // Play background music on game start
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    _audioPlayer.dispose(); // Dispose of audio player
    super.dispose();
  }

  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/background_music.mp3')); // Set the background music
    _audioPlayer.setVolume(0.5); // Adjust volume if needed
    _audioPlayer.resume(); // Start playing
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
      score += 0; // Increase the score

      // Play phonics sound for the dropped letter
      _playSound(letter.toLowerCase());

      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward(); // Start waving animation

        // Wait for the last phonics sound to finish before playing "world"
        Future.delayed(Duration(seconds: 1), () {
          _playSound('world'); // Play the "world" sound after a short delay
          setState(() {
            lastScore = score;
            score = 0;
          });

          // Navigate to the CatWordGame after a brief delay
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatWordGame()), // Navigate to CatWordGame
            );
          });
        });
      }
    });
  }

  // Check if the word is completed
  bool _isWordCompleted() {
    return !filledLetters.contains(null);
  }

  // Hint functionality: Automatically place one correct letter
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
      // appBar: AppBar(
      //   title: Text(
      //     'Next Word Game',
      //     style: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: Stack(
        children: [
          // Background GIF or Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/earth-2768_512.gif', // Path to your GIF file
              fit: BoxFit.cover,
            ),
          ),
          // Game content layered on top of the background
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scoreboard and Hint side by side
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Score display
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    // Last score display
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    // Hint Icon
                    IconButton(
                      icon: Icon(Icons.lightbulb, color: Colors.yellow), // Hint icon
                      onPressed: _useHint, // Use hint when clicked
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
        color: isFeedback ? Colors.blue : Colors.blueGrey,
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
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey), // Waving icon
          SizedBox(width: 10),
          Text(
            "WORLD!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey), // Waving icon
        ],
      ),
    );
  }
}

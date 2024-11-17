import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'NextWordGame.dart';

class LetterSelectionGame extends StatefulWidget {
  @override
  _LetterSelectionGameState createState() => _LetterSelectionGameState();
}

class _LetterSelectionGameState extends State<LetterSelectionGame>
    with SingleTickerProviderStateMixin {
  final String word = "HELLO"; // The word to fill
  List<String> letters = ['E', 'H', 'O', 'L', 'L']; // Letters to drag
  late List<String?> filledLetters; // Track filled letters
  late AnimationController _controller;
  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance

  int score = 0; // Current game score
  int lastScore = 0; // Last game score

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null); // Initialize filled letters
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _playBackgroundMusic(); // Play background music
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    _audioPlayer.dispose(); // Dispose of audio player
    super.dispose();
  }

  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.resume();
  }

  // Play letter sound (phonics) or word sound
  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3'));
  }

  // Handle the drop event
  void _onLetterDropped(String letter, int index) {
    setState(() {
      filledLetters[index] = letter;
      letters.remove(letter);
      score += 0; // Increase score on correct drop

      // Play phonics sound for the dropped letter
      _playSound(letter.toLowerCase());

      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward();

        Future.delayed(Duration(seconds: 1), () {
          _playSound('hello');
          setState(() {
            lastScore = score; // Save current score to last score
            score = 0; // Reset score for next game
          });

          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NextWordGame()),
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
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       Text('Letter Selection Game', style: TextStyle(fontFamily: 'ChalkStyle')),
      //     ],
      //   ),
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hello.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Scoreboard and hint icon section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Score: $score   ',
                            style: TextStyle(fontSize: 16, fontFamily: 'ChalkStyle'),
                          ),
                          Text(
                            'Last Score: $lastScore',
                            style: TextStyle(fontSize: 16, fontFamily: 'ChalkStyle'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.lightbulb, color: Colors.yellow),
                      onPressed: _useHint,
                    ),
                  ],
                ),
              ),
              // Main game content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Keep the word "HELLO" in place and do not move it
                        ...List.generate(word.length, (index) {
                          return DragTarget<String>( // Target for each letter
                            builder: (context, candidateData, rejectedData) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: filledLetters[index] != null
                                      ? Colors.lightGreen
                                      : Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    filledLetters[index] ?? word[index],
                                    style: TextStyle(fontSize: 24, fontFamily: 'ChalkStyle'),
                                  ),
                                ),
                              );
                            },
                            onWillAccept: (data) => data == word[index],
                            onAccept: (data) => _onLetterDropped(data, index),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      children: letters.map((letter) {
                        return Draggable<String>(
                          data: letter,
                          child: _buildLetterWidget(letter),
                          feedback: _buildLetterWidget(letter, isFeedback: true),
                          childWhenDragging: _buildLetterWidget(letter, isFeedback: true),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    if (_isCompleted) _buildWavingIcons(),
                  ],
                ),
              ),
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
        color: isFeedback ? Colors.blue.withOpacity(0.5) : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'ChalkStyle'),
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
          Icon(Icons.tag_faces, size: 50, color: Colors.green),
          SizedBox(width: 10),
          Text(
            "HELLO!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green, fontFamily: 'ChalkStyle'),
          ),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.green),
        ],
      ),
    );
  }
}

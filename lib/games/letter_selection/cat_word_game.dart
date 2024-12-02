import 'package:dyslearn/games/letter_selection/monkey_word_game.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatWordGame extends StatefulWidget {
  final String? selectedChildName;

  CatWordGame({this.selectedChildName});

  @override
  _CatWordGameState createState() => _CatWordGameState();
}

class _CatWordGameState extends State<CatWordGame> with SingleTickerProviderStateMixin {
  final String word = "CAT"; // The word to fill
  List<String> letters = ['A', 'T', 'C']; // Letters to select
  late List<String?> filledLetters; // Track filled letters
  late AnimationController _controller;
  late FirebaseFirestore firestore; // Firestore instance

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

    firestore = FirebaseFirestore.instance;
    _playBackgroundMusic(); // Start background music
    fetchLastScore(); // Fetch the last score from Firestore
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    _audioPlayer.dispose(); // Dispose of audio player for sound effects
    _backgroundMusicPlayer.dispose(); // Dispose background music
    super.dispose();
  }

  // Fetch the last score from Firebase
  Future<void> fetchLastScore() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) return;

    try {
      final childDocs = await firestore
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)
          .get();

      if (childDocs.docs.isNotEmpty) {
        String childId = childDocs.docs.first.id;

        final gameDoc = await firestore
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(childId)
            .collection('Cat Word Game')
            .doc('gameData')
            .get();

        if (gameDoc.exists) {
          setState(() {
            lastScore = gameDoc['lastScore'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error fetching last score: $e");
    }
  }

  // Save the current score to Firebase
  Future<void> saveScoreToFirebase() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      final childDocs = await firestore
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)
          .get();

      if (childDocs.docs.isNotEmpty) {
        String childId = childDocs.docs.first.id;

        DocumentReference gameDoc = firestore
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(childId)
            .collection('Cat Word Game')
            .doc('gameData');

        await gameDoc.set({
          'lastScore': score,
          'totalScore': FieldValue.increment(score),
          'attempts': FieldValue.increment(1),
          'lastUpdated': Timestamp.now(),
        }, SetOptions(merge: true));

        print("Score saved to Firebase successfully!");
      }
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'), volume: 0.5);
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.resume();
  }

  // Play letter sound (phonics) or word sound
  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3')); // Play sound from assets
  }

  // Handle letter tap event
  void _onLetterTapped(String letter, int _) {
    setState(() {
      // Find the correct index for the letter in the word
      for (int i = 0; i < word.length; i++) {
        if (word[i] == letter && filledLetters[i] == null) {
          filledLetters[i] = letter; // Place the letter in the correct position
          letters.remove(letter); // Remove the letter from the pool
          score += 1;

          // Play phonics sound for the tapped letter
          _playSound(letter.toLowerCase());
          break;
        }
      }

      // Check if the word is completed
      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward(); // Start waving animation

        saveScoreToFirebase(); // Save score to Firestore

        // Wait for the last phonics sound to finish before playing "cat"
        Future.delayed(Duration(seconds: 1), () {
          _playSound('cat'); // Play the "cat" sound after a short delay

          // Update scores
          setState(() {
            lastScore = score;
            score = 0;
          });

          // After playing sound, navigate to the next word task
          Future.delayed(Duration(seconds: 2), () {
            _navigateToNextGame(); // Navigate to the next game
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
          _onLetterTapped(correctLetter, i); // Use the hint
          break; // Use only one hint at a time
        }
      }
    }
  }

  // Navigate to the next game
  void _navigateToNextGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MonkeyWordGame(selectedChildName: widget.selectedChildName)),
    );
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
                image: AssetImage("assets/images/cat.gif"), // GIF as background
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scoreboard and hint row
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', color: Colors.black),
                      ),
                      Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.lightbulb, color: Colors.yellow),
                    onPressed: _useHint,
                  ),
                ],
              ),
            ),
          ),
          // Main game content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(word.length, (index) {
                    return GestureDetector(
                      onTap: () => _onLetterTapped(letters.firstWhere((letter) => letter == word[index]), index),
                      child: AnimatedContainer(
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
                            filledLetters[index] ?? word[index],
                            style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic'),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 20),
              // Letters to choose from (below the word)
              Wrap(
                spacing: 10,
                children: List.generate(letters.length, (index) {
                  return GestureDetector(
                    onTap: () => _onLetterTapped(letters[index], filledLetters.indexOf(null)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        letters[index],
                        style: TextStyle(fontSize: 18, fontFamily: 'OpenDyslexic', color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterWidget(String letter) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(letter, style: TextStyle(color: Colors.white)),
    );
  }
  Widget _buildWavingIcons() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tag_faces, size: 50, color: Colors.green),
          SizedBox(width: 10),
          Text("CAT!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.green),
        ],
      ),
    );
  }
}




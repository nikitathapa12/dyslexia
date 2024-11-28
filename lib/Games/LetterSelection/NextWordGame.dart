import 'package:dyslearn/Games/LetterSelection/CatWordGame.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NextWordGame extends StatefulWidget {
  final String? selectedChildName;

  NextWordGame({this.selectedChildName});
  @override
  _NextWordGameState createState() => _NextWordGameState();
}

class _NextWordGameState extends State<NextWordGame> with SingleTickerProviderStateMixin {
  final String word = "WORLD"; // The word to fill
  List<String> letters = ['R', 'O', 'W', 'D', 'L']; // Letters to tap
  late List<String?> filledLetters; // Track filled letters

  late FirebaseFirestore firestore; // Firestore instance
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

    firestore = FirebaseFirestore.instance;
    _playBackgroundMusic(); // Play background music
    fetchLastScore(); // Fetch the last score from Firestore
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    _audioPlayer.dispose(); // Dispose of audio player
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
            .collection('Word Game')
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

        DocumentReference gameDoc = firestore
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(childId)
            .collection('Word Game')
            .doc('gameData');

        await gameDoc.set({
          'lastScore': score,
          'totalScore': FieldValue.increment(score),
          'attempts': FieldValue.increment(1),
          'lastUpdated': Timestamp.now(),
        }, SetOptions(merge: true));

        print("Score saved successfully!");
      }
    } catch (e) {
      print("Error saving score: $e");
    }
  }



  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
    _audioPlayer.setVolume(0.5);
    _audioPlayer.resume();
  }

  // Play letter sound (phonics) or word sound
  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3'));
  }

  // Handle the tap event
  void _onLetterTapped(String letter) {
    setState(() {
      // Check if there is an empty spot
      for (int i = 0; i < word.length; i++) {
        if (filledLetters[i] == null) {
          filledLetters[i] = letter;
          letters.remove(letter);
          score += 1; // Increase score on correct tap
          _playSound(letter.toLowerCase());
          break;
        }
      }

      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward();

        saveScoreToFirebase(); // Save score to Firestore

        Future.delayed(Duration(seconds: 1), () {
          _playSound('world');
          setState(() {
            lastScore = score;
            score = 0;
          });

          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatWordGame(selectedChildName: widget.selectedChildName,)),
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
          _onLetterTapped(correctLetter);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/earth-2768_512.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic',  color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.lightbulb, color: Colors.yellow),
                      onPressed: _useHint,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(word.length, (index) {
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
                          filledLetters[index] ?? word[index],
                          style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic',),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: letters.map((letter) {
                  return GestureDetector(
                    onTap: () => _onLetterTapped(letter),
                    child: _buildLetterWidget(letter),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
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
        style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', color: Colors.white),
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
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text(
            "WORLD!",
            style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic', fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey),
        ],
      ),
    );
  }
}

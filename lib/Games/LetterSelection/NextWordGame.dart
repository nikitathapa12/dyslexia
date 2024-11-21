import 'package:dyslearn/Games/LetterSelection/CatWordGame.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Firebase Firestore instance
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null); // Initialize filled letters
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
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
    if (parent == null) return; // No user logged in

    try {
      DocumentSnapshot doc = await firestore
          .collection('parents')
          .doc(parent.uid)
          .collection('Word Game')
          .doc('GameData')
          .get();

      if (doc.exists) {
        setState(() {
          lastScore = doc['lastScore'] ?? 0;
        });
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
      DocumentReference parentDoc = firestore.collection('parents').doc(parent.uid);
      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();

      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      DocumentSnapshot childDoc = childrenSnapshot.docs.first;
      String childId = childDoc.id;

      CollectionReference gameDataCollection = parentDoc
          .collection('children')
          .doc(childId)
          .collection('Word Game');

      Map<String, dynamic> gameData = {
        'lastScore': score,
        'totalScore': FieldValue.increment(score),
        'attempts': FieldValue.increment(1),
        'lastUpdated': Timestamp.now(),
      };

      await gameDataCollection.add(gameData);

      print("Score saved to Firebase successfully!");
    } catch (e) {
      print("Error saving score to Firebase: $e");
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

  // Handle the drop event
  void _onLetterDropped(String letter, int index) {
    setState(() {
      filledLetters[index] = letter;
      letters.remove(letter);
      score += 1; // Increase score on correct drop

      _playSound(letter.toLowerCase());

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
              MaterialPageRoute(builder: (context) => CatWordGame()),
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 24, color: Colors.white),
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
                              filledLetters[index] ?? word[index],
                              style: TextStyle(fontSize: 24),
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
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text(
            "WORLD!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.blueGrey),
        ],
      ),
    );
  }
}

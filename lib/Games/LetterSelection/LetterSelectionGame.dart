import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NextWordGame.dart';

class LetterSelectionGame extends StatefulWidget {
  final String? selectedChildName;

  LetterSelectionGame({this.selectedChildName});

  @override
  _LetterSelectionGameState createState() => _LetterSelectionGameState();
}

class _LetterSelectionGameState extends State<LetterSelectionGame> with SingleTickerProviderStateMixin {
  final String word = "HELLO"; // The word to fill
  List<String> letters = ['E', 'H', 'O', 'L', 'L']; // Letters to drag
  late List<String?> filledLetters; // Track filled letters
  late AnimationController _controller;
  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance

  int score = 0; // Current game score
  int lastScore = 0; // Last game score

  late FirebaseFirestore firestore; // Firestore instance

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
    final doc = await firestore.collection('games').doc('letterSelection').get();
    if (doc.exists) {
      setState(() {
        lastScore = doc['lastScore'] ?? 0;  // Use a default value if lastScore doesn't exist
      });
    }
  }

  // Save the current score to Firebase
  Future<void> saveScoreToFirebase() async {
    // Get the currently logged-in parent's ID
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      // Access the parent's document
      DocumentReference parentDoc = firestore.collection('parents').doc(parent.uid);

      // Retrieve the first child document in the 'children' subcollection
      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();
      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      // Assuming you want to use the first child (or modify as needed)
      print("child name: ");
      print(widget.selectedChildName);

      final childDocs = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)  // Use the selected child's name
          .get();

      String childId = childDocs.docs.first.id; // Extract the childId
      print("retrieved child id: $childId");


      // Reference to the gameData subcollection under the child's document
      CollectionReference gameDataCollection =
      parentDoc.collection('children').doc(childId).collection('Letter Selection');
      print("childId: $childId");
      // Prepare game data to store in Firestore
      Map<String, dynamic> gameData = {
        'lastScore': score,  // Current score
        'totalScore': FieldValue.increment(score),  // Increment total score by the current score
        'attempts': FieldValue.increment(1),  // Increment attempts by 1
        'lastUpdated': Timestamp.now(),
      };

      // Add or update game data document in the 'gameData' subcollrrection
      await gameDataCollection.add(gameData);

      print("Score saved to Firebase successfully!");
    } catch (e) {
      print("Error saving score to Firebase: $e");
    }
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
      score += 1; // Increase score on correct drop

      // Play phonics sound for the dropped letter
      _playSound(letter.toLowerCase());

      if (_isWordCompleted()) {
        _isCompleted = true;
        _controller.forward();

        saveScoreToFirebase(); // Save score to Firestore

        Future.delayed(Duration(seconds: 1), () {
          _playSound('hello');
          setState(() {
            lastScore = score; // Save current score to last score
            score = 0; // Reset score for next game
          });

          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NextWordGame(selectedChildName: widget.selectedChildName,)),
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
                          return DragTarget<String>(
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

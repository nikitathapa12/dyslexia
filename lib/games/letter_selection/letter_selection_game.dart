import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'next_word_game.dart';

class LetterSelectionGame extends StatefulWidget {
  final String? selectedChildName;

  LetterSelectionGame({this.selectedChildName});

  @override
  _LetterSelectionGameState createState() => _LetterSelectionGameState();
}

class _LetterSelectionGameState extends State<LetterSelectionGame>
    with SingleTickerProviderStateMixin {
  final String word = "HELLO";
  List<String> letters = ['E', 'H', 'O', 'L', 'L'];
  late List<String?> filledLetters;
  late AnimationController _controller;
  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  int score = 0;
  int lastScore = 0;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    firestore = FirebaseFirestore.instance;
    _playBackgroundMusic();
    fetchLastScore();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

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
            .collection('Letter Selection')
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
            .collection('Letter Selection')
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

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.resume();
  }

  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3'));
  }

  void _onLetterTapped(String letter) {
    // Find the correct index for the tapped letter
    for (int i = 0; i < word.length; i++) {
      if (word[i] == letter && filledLetters[i] == null) {
        setState(() {
          filledLetters[i] = letter; // Place the letter in its correct position
          letters.remove(letter);   // Remove the letter from the options
          score += 1;               // Increment the score
        });

        _playSound(letter.toLowerCase());

        if (_isWordCompleted()) {
          _isCompleted = true;
          _controller.forward();

          saveScoreToFirebase();

          Future.delayed(Duration(seconds: 1), () {
            _playSound('hello');
            setState(() {
              lastScore = score;
              score = 0;
            });

            Future.delayed(Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NextWordGame(selectedChildName: widget.selectedChildName),
                ),
              );
            });
          });
        }
        return; // Stop searching once the letter is placed
      }
    }

    // If the letter doesn't match any unfilled position, provide feedback
    _playSound('error'); // Play an error sound or provide visual feedback
  }


  bool _isWordCompleted() {
    return !filledLetters.contains(null);
  }

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
              'assets/images/hello.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
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
                        children: [
                          Text('Score: $score   '),
                          Text('Last Score: $lastScore'),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.lightbulb, color: Colors.yellow),
                      onPressed: _useHint,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(word.length, (index) {
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
                            ),
                          ),
                        );
                      }),
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
          Text("HELLO!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.tag_faces, size: 50, color: Colors.green),
        ],
      ),
    );
  }
}
